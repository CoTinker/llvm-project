// RUN: mlir-opt --transform-interpreter --split-input-file  -canonicalize -cse %s | FileCheck %s

!type = memref<2 x 32 x f32>
!type1d = memref<32 x f32>

// CHECK-LABEL: func.func @blocks_3d(
// CHECK-SAME:    %[[ARGX:[0-9a-z]+]]: memref<2x32xf32>
// CHECK-SAME:    %[[ARGY:[0-9a-z]+]]: memref<2x32xf32>
// CHECK-SAME:    %[[ARGT:[0-9a-z]+]]: memref<32xf32>
func.func @blocks_3d(%x: !type, %y: !type, %t: !type1d, %alpha : f32, %stream : !gpu.async.token) -> !type {
  %c9 = arith.constant 9 : index
  %c7 = arith.constant 7 : index
  %one = arith.constant 1 : index
//      CHECK:   gpu.launch
//      CHECK:   %[[BLKX:.*]] = gpu.block_id  x
//      CHECK:   %[[BLKY:.*]] = gpu.block_id  y
//      CHECK:   memref.load %[[ARGX]][%[[BLKX]], %[[BLKY]]]
//      CHECK:   memref.load %[[ARGY]][%[[BLKX]], %[[BLKY]]]
  %name = gpu.launch async[%stream] blocks(%arg3, %arg4, %arg5) in (%arg9 = %one, %arg10 = %one, %arg11 = %one)
            threads(%arg6, %arg7, %arg8) in (%arg12 = %one, %arg13 = %one, %arg14 = %one)
  {
    scf.forall (%i, %j) in (%c7, %c9) {
        %4 = memref.load %x[%i, %j] : !type
        %5 = memref.load %y[%i, %j] : !type
        %6 = math.fma %alpha, %4, %5 : f32
        memref.store %6, %y[%i, %j] : !type
     }  { mapping = [#gpu.block<x>, #gpu.block<y>]}
    gpu.terminator
  }
  return %y : !type
}

module attributes {transform.with_named_sequence} {
  transform.named_sequence @__transform_main(%arg0: !transform.any_op {transform.readonly}) {
    %funcop = transform.structured.match ops{["gpu.launch"]} in %arg0 : (!transform.any_op) -> !transform.any_op
    transform.gpu.map_forall_to_blocks %funcop grid_dims = [12, 9, 1] : (!transform.any_op) -> !transform.any_op
    transform.yield
  }
}

// -----

!type = memref<2 x 32 x f32>
!type1d = memref<32 x f32>

// CHECK-DAG: #[[$MAP:.*]] = affine_map<()[s0] -> (s0 floordiv 128)>

// CHECK-LABEL: func.func @warpgroup_3d(
// CHECK-SAME:    %[[ARGX:[0-9a-z]+]]: memref<2x32xf32>
// CHECK-SAME:    %[[ARGY:[0-9a-z]+]]: memref<2x32xf32>
// CHECK-SAME:    %[[ARGT:[0-9a-z]+]]: memref<32xf32>
func.func @warpgroup_3d(%x: !type, %y: !type, %t: !type1d, %alpha : f32, %stream : !gpu.async.token) -> !type {
  %c1 = arith.constant 1 : index
  %c3 = arith.constant 3 : index
  %one = arith.constant 1 : index
  // CHECK-DAG: %[[C1:.*]] = arith.constant 1 : index
  // CHECK-DAG: %[[C2:.*]] = arith.constant 2 : index
  // CHECK-DAG: %[[C384:.*]] = arith.constant 384 : index
  // CHECK-DAG: %[[C512:.*]] = arith.constant 512 : index

//      CHECK:   gpu.launch
//      CHECK:   %[[TIDX:.*]] = gpu.thread_id  x
//      CHECK:   %[[TIDY:.*]] = gpu.thread_id  y
//  CHECK-DAG:   %[[WG:.*]] = affine.apply #[[$MAP]]()[%[[TIDX]]]
//  CHECK-DAG:   %[[CMPX:.*]] = arith.cmpi ult, %[[TIDX]], %[[C384]] : index
//  CHECK-DAG:   %[[CMPY:.*]] = arith.cmpi ult, %[[TIDY]], %[[C1]] : index
//      CHECK:   %[[COND:.*]] = arith.andi %[[CMPX]], %[[CMPY]] : i1
//      CHECK:   scf.if %[[COND]]
//      CHECK:     memref.load %[[ARGX]][%[[WG]], %[[TIDY]]]
//      CHECK:     memref.load %[[ARGY]][%[[WG]], %[[TIDY]]]
  %name = gpu.launch async[%stream] blocks(%arg3, %arg4, %arg5) in (%arg9 = %one, %arg10 = %one, %arg11 = %one)
            threads(%arg6, %arg7, %arg8) in (%arg12 = %one, %arg13 = %one, %arg14 = %one)
  {
    scf.forall (%i, %j) in (%c3, %c1) {
        %4 = memref.load %x[%i, %j] : !type
        %5 = memref.load %y[%i, %j] : !type
        %6 = math.fma %alpha, %4, %5 : f32
        memref.store %6, %y[%i, %j] : !type
     }  { mapping = [#gpu.warpgroup<x>, #gpu.warpgroup<y>]}
    gpu.terminator
  }
  return %y : !type
}

module attributes {transform.with_named_sequence} {
  transform.named_sequence @__transform_main(%arg0: !transform.any_op {transform.readonly}) {
    %funcop = transform.structured.match ops{["gpu.launch"]} in %arg0 : (!transform.any_op) -> !transform.any_op
    transform.gpu.map_nested_forall_to_threads %funcop block_dims = [512, 2, 1] : (!transform.any_op) -> !transform.any_op
    transform.yield
  }
}

// -----

!type = memref<2 x 32 x f32>
!type1d = memref<32 x f32>

// CHECK-DAG: #map = affine_map<()[s0] -> (s0 floordiv 16)>

// CHECK-LABEL: func.func @warp_3d(
// CHECK-SAME:    %[[ARGX:[0-9a-z]+]]: memref<2x32xf32>
// CHECK-SAME:    %[[ARGY:[0-9a-z]+]]: memref<2x32xf32>
// CHECK-SAME:    %[[ARGT:[0-9a-z]+]]: memref<32xf32>
func.func @warp_3d(%x: !type, %y: !type, %t: !type1d, %alpha : f32, %stream : !gpu.async.token) -> !type {
  %c2 = arith.constant 2 : index
  %c3 = arith.constant 3 : index
  %one = arith.constant 1 : index
  // CHECK-DAG: %[[C1:.*]] = arith.constant 1 : index
  // CHECK-DAG: %[[C3:.*]] = arith.constant 3 : index
  // CHECK-DAG: %[[C4:.*]] = arith.constant 4 : index
  // CHECK-DAG: %[[C32:.*]] = arith.constant 32 : index
  // CHECK-DAG: %[[c64:.*]] = arith.constant 64 : index

//      CHECK:   gpu.launch
//      CHECK:   %[[TIDX:.*]] = gpu.thread_id  x
//      CHECK:   %[[TIDY:.*]] = gpu.thread_id  y
//  CHECK-DAG:   %[[W:.*]] = affine.apply #[[$MAP]]()[%[[TIDX]]]
//  CHECK-DAG:   %[[CMPX:.*]] = arith.cmpi ult, %[[TIDX]], %[[C32]] : index
//  CHECK-DAG:   %[[CMPY:.*]] = arith.cmpi ult, %[[TIDY]], %[[C3]] : index
//      CHECK:   %[[COND:.*]] = arith.andi %[[CMPX]], %[[CMPY]] : i1
//      CHECK:   scf.if %[[COND]]
//      CHECK:     memref.load %[[ARGX]][%[[W]], %[[TIDY]]]
//      CHECK:     memref.load %[[ARGY]][%[[W]], %[[TIDY]]]
  %name = gpu.launch async[%stream] blocks(%arg3, %arg4, %arg5) in (%arg9 = %one, %arg10 = %one, %arg11 = %one)
            threads(%arg6, %arg7, %arg8) in (%arg12 = %one, %arg13 = %one, %arg14 = %one)
  {
    scf.forall (%i, %j, %k) in (%c2, %c3, %c3) {
        %4 = memref.load %x[%i, %j] : !type
        %5 = memref.load %y[%i, %j] : !type
        %6 = math.fma %alpha, %4, %5 : f32
        memref.store %6, %y[%i, %j] : !type
     }  { mapping = [#gpu.warp<x>, #gpu.warp<y>, #gpu.warp<z>]}
    gpu.terminator
  }
  return %y : !type
}

module attributes {transform.with_named_sequence} {
  transform.named_sequence @__transform_main(%arg0: !transform.any_op {transform.readonly}) {
    %funcop = transform.structured.match ops{["gpu.launch"]} in %arg0 : (!transform.any_op) -> !transform.any_op
    transform.gpu.map_nested_forall_to_threads %funcop block_dims = [64, 4, 3] warp_size = 16: (!transform.any_op) -> !transform.any_op
    transform.yield
  }
}

// -----

!type = memref<2 x 32 x f32>
!type1d = memref<32 x f32>

// CHECK-LABEL: func.func @threads_3d(
// CHECK-SAME:    %[[ARGX:[0-9a-z]+]]: memref<2x32xf32>
// CHECK-SAME:    %[[ARGY:[0-9a-z]+]]: memref<2x32xf32>
// CHECK-SAME:    %[[ARGT:[0-9a-z]+]]: memref<32xf32>
func.func @threads_3d(%x: !type, %y: !type, %t: !type1d, %alpha : f32, %stream : !gpu.async.token) -> !type {
  %one = arith.constant 1 : index
  %c12 = arith.constant 12 : index
  %c9 = arith.constant 9 : index
  %c7 = arith.constant 7 : index
//      CHECK:   %[[C1:.*]] = arith.constant 1 : index
//      CHECK:   %[[C12:.*]] = arith.constant 12 : index
//      CHECK:   %[[C9:.*]] = arith.constant 9 : index
//      CHECK:   %[[C7:.*]] = arith.constant 7 : index
//      CHECK:   gpu.launch async [%{{.*}}] blocks(%{{.*}}, %{{.*}}, %{{.*}}) in (%{{.*}} = %[[C1]], %{{.*}} = %[[C1]], %{{.*}} = %[[C1]]) threads(%{{.*}}, %{{.*}}, %{{.*}}) in (%{{.*}} = %[[C12]], %{{.*}} = %[[C9]], %{{.*}} = %[[C1]])
//      CHECK:   %[[TIDX:.*]] = gpu.thread_id  x
//      CHECK:   %[[TIDY:.*]] = gpu.thread_id  y
//      CHECK:   arith.cmpi ult, %[[TIDX]], %[[C9]] : index
//      CHECK:   arith.cmpi ult, %[[TIDY]], %[[C7]] : index
//      CHECK:   memref.load %[[ARGX]][%[[TIDY]], %[[TIDX]]]
//      CHECK:   memref.load %[[ARGY]][%[[TIDY]], %[[TIDX]]]
//      CHECK:   gpu.barrier
//      CHECK:   arith.cmpi ult, %[[TIDY]], %[[C1]] : index
//      CHECK:   memref.load %[[ARGT]][%[[TIDX]]]
//      CHECK:   gpu.barrier
  %name = gpu.launch async[%stream] blocks(%arg3, %arg4, %arg5) in (%arg9 = %one, %arg10 = %one, %arg11 = %one)
            threads(%arg6, %arg7, %arg8) in (%arg12 = %one, %arg13 = %one, %arg14 = %one)
  {
    scf.forall (%i, %j) in (%c7, %c9) {
        %4 = memref.load %x[%i, %j] : !type
        %5 = memref.load %y[%i, %j] : !type
        %6 = math.fma %alpha, %4, %5 : f32
        memref.store %6, %y[%i, %j] : !type
     }  { mapping = [#gpu.thread<y>, #gpu.thread<x>]}
     scf.forall (%i) in (%c12) {
        %7 = memref.load %t[%i] : !type1d
        %8 = arith.addf %alpha, %7 : f32
        memref.store %8, %t[%i] : !type1d
     }  {mapping = [#gpu.thread<x>] }
    gpu.terminator
  }
  return %y : !type
}

module attributes {transform.with_named_sequence} {
  transform.named_sequence @__transform_main(%arg0: !transform.any_op {transform.readonly}) {
    %funcop = transform.structured.match ops{["gpu.launch"]} in %arg0 : (!transform.any_op) -> !transform.any_op
    transform.gpu.map_nested_forall_to_threads %funcop block_dims = [12, 9, 1] : (!transform.any_op) -> !transform.any_op
    transform.yield
  }
}

// -----

!type4d = memref<32x64x4x32xf32>

// CHECK-LABEL: func.func @saxpy4d(
// CHECK-SAME:    %[[ARGX:[0-9a-z]+]]: memref<32x64x4x32xf32>
// CHECK-SAME:    %[[ARGY:[0-9a-z]+]]: memref<32x64x4x32xf32>
func.func @saxpy4d(%x: !type4d, %y: !type4d, %alpha : f32) -> !type4d {
  %c32 = arith.constant 32 : index
  %c64 = arith.constant 64 : index
  %c4 = arith.constant 4 : index
//      CHECK:   %[[C32:.*]] = arith.constant 32 : index
//      CHECK:   %[[C64:.*]] = arith.constant 64 : index
//      CHECK:   %[[C4:.*]] = arith.constant 4 : index
//      CHECK:   %[[C1:.*]] = arith.constant 1 : index
//      CHECK:   gpu.launch blocks(%{{.*}}, %{{.*}}, %{{.*}}) in (%{{.*}} = %[[C32]], %{{.*}} = %[[C64]], %{{.*}} = %[[C1]]) threads(%{{.*}}, %{{.*}}, %{{.*}}) in (%{{.*}} = %[[C32]], %{{.*}} = %[[C4]], %{{.*}} = %[[C1]])
//      CHECK:   %[[BLKX:.*]] = gpu.block_id  x
//      CHECK:   %[[BLKY:.*]] = gpu.block_id  y
//      CHECK:   %[[TIDX:.*]] = gpu.thread_id  x
//      CHECK:   %[[TIDY:.*]] = gpu.thread_id  y
//      CHECK:   memref.load %[[ARGX]][%[[BLKX]], %[[BLKY]], %[[TIDY]], %[[TIDX]]]
//      CHECK:   memref.load %[[ARGY]][%[[BLKX]], %[[BLKY]], %[[TIDY]], %[[TIDX]]]
  scf.forall (%i, %j) in (%c32, %c64) {
    scf.forall (%k, %l) in (%c4, %c32) {
      %4 = memref.load %x[%i, %j, %k, %l] : !type4d
      %5 = memref.load %y[%i, %j, %k, %l] : !type4d
      %6 = math.fma %alpha, %4, %5 : f32
      memref.store %6, %y[%i, %j, %k, %l] : !type4d
    }  { mapping = [#gpu.thread<y>, #gpu.thread<x>] }
  }  { mapping = [#gpu.block<x>, #gpu.block<y>] }
  return %y : !type4d
}

module attributes {transform.with_named_sequence} {
  transform.named_sequence @__transform_main(%arg0: !transform.any_op {transform.readonly}) {
    %funcop = transform.structured.match ops{["func.func"]} in %arg0 : (!transform.any_op) -> !transform.any_op
    %gpuLaunch = transform.gpu.map_forall_to_blocks %funcop { generate_gpu_launch } : (!transform.any_op) -> !transform.any_op
    transform.gpu.map_nested_forall_to_threads %gpuLaunch block_dims = [32, 4, 1] : (!transform.any_op) -> !transform.any_op
    transform.yield
  }
}

// -----

!type = memref<2 x 32 x f32>
!type1d = memref<32 x f32>

// CHECK-LABEL: func.func @saxpy2d_no_barrier(
func.func @saxpy2d_no_barrier(%x: !type, %y: !type, %t: !type1d, %alpha : f32, %stream : !gpu.async.token) -> !type {
  %one = arith.constant 1 : index
  %c12 = arith.constant 12 : index
  %c9 = arith.constant 9 : index
  %c7 = arith.constant 7 : index
//  CHECK-NOT:   gpu.barrier
//      CHECK:   return
  %name = gpu.launch async[%stream] blocks(%arg3, %arg4, %arg5) in (%arg9 = %one, %arg10 = %one, %arg11 = %one)
            threads(%arg6, %arg7, %arg8) in (%arg12 = %one, %arg13 = %one, %arg14 = %one)
  {
    scf.forall (%i, %j) in (%c7, %c9) {
        %4 = memref.load %x[%i, %j] : !type
        %5 = memref.load %y[%i, %j] : !type
        %6 = math.fma %alpha, %4, %5 : f32
        memref.store %6, %y[%i, %j] : !type
     }  { mapping = [#gpu.thread<y>, #gpu.thread<x>] }
    gpu.terminator
  }
  return %y : !type
}

module attributes {transform.with_named_sequence} {
  transform.named_sequence @__transform_main(%arg0: !transform.any_op {transform.readonly}) {
    %funcop = transform.structured.match ops{["gpu.launch"]} in %arg0 : (!transform.any_op) -> !transform.any_op
    transform.gpu.map_nested_forall_to_threads %funcop block_dims = [12, 9, 1] sync_after_distribute = false : (!transform.any_op) -> !transform.any_op
    transform.yield
  }
}

// -----

!type = memref<32x32xf32>
// CHECK-LABEL: func.func @saxpy2d_singleloop(
// CHECK-SAME:    %[[ARGX:[0-9a-z]+]]: memref<32x32xf32>
// CHECK-SAME:    %[[ARGY:[0-9a-z]+]]: memref<32x32xf32>
func.func @saxpy2d_singleloop(%x: !type, %y: !type, %stream : !gpu.async.token) -> !type {
  %c32 = arith.constant 32 : index
  %one = arith.constant 1 : index
  %name = gpu.launch async[%stream] blocks(%arg3, %arg4, %arg5) in (%arg9 = %one, %arg10 = %one, %arg11 = %one)
            threads(%arg6, %arg7, %arg8) in (%arg12 = %one, %arg13 = %one, %arg14 = %one)
  {
//      CHECK:   %[[TIDX:.*]] = gpu.thread_id  x
//      CHECK:   memref.load %[[ARGX]][%[[TIDX]], %[[TIDX]]]
//      CHECK:   memref.load %[[ARGY]][%[[TIDX]], %[[TIDX]]]
    scf.forall (%i) in (%c32) {
        %4 = memref.load %x[%i, %i] : !type
        %5 = memref.load %y[%i, %i] : !type
        %6 = arith.mulf %4, %5 : f32
        memref.store %6, %y[%i, %i] : !type
     }  { mapping = [#gpu.thread<x>] }
    gpu.terminator
  }
  return %y : !type
}

module attributes {transform.with_named_sequence} {
  transform.named_sequence @__transform_main(%arg0: !transform.any_op {transform.readonly}) {
    %funcop = transform.structured.match ops{["gpu.launch"]} in %arg0 : (!transform.any_op) -> !transform.any_op
    transform.gpu.map_nested_forall_to_threads %funcop block_dims = [32, 1, 1] : (!transform.any_op) -> !transform.any_op
    transform.yield
  }
}

// -----

!type = memref<3 x 2 x 32 x f32>
!type1d = memref<32 x f32>

// CHECK-LABEL: func.func @saxpy3d_fold_id_z(
func.func @saxpy3d_fold_id_z(%x: !type, %y: !type, %t: !type1d, %alpha : f32, %stream : !gpu.async.token) -> !type {
  %one = arith.constant 1 : index
  %c12 = arith.constant 12 : index
  %c9 = arith.constant 9 : index
  %c7 = arith.constant 7 : index
//  CHECK: %[[C0:.+]] = arith.constant 0 : index
//  CHECK-NOT:   gpu.thread_id  z
  %name = gpu.launch async[%stream] blocks(%arg3, %arg4, %arg5) in (%arg9 = %one, %arg10 = %one, %arg11 = %one)
            threads(%arg6, %arg7, %arg8) in (%arg12 = %one, %arg13 = %one, %arg14 = %one)
  {
    scf.forall (%i, %j, %k) in (%one, %c7, %c9) {
//      CHECK:   memref.load %{{.*}}[%[[C0]],
//      CHECK:   memref.load %{{.*}}[%[[C0]],
        %4 = memref.load %x[%i, %j, %k] : !type
        %5 = memref.load %y[%i, %j, %k] : !type
        %6 = math.fma %alpha, %4, %5 : f32
//      CHECK:   memref.store %{{.*}}, %{{.*}}[%[[C0]]
        memref.store %6, %y[%i, %j, %k] : !type
     }  { mapping = [#gpu.thread<z>, #gpu.thread<y>, #gpu.thread<x>] }
    gpu.terminator
  }
  return %y : !type
}

module attributes {transform.with_named_sequence} {
  transform.named_sequence @__transform_main(%arg0: !transform.any_op {transform.readonly}) {
    %funcop = transform.structured.match ops{["gpu.launch"]} in %arg0 : (!transform.any_op) -> !transform.any_op
    transform.gpu.map_nested_forall_to_threads %funcop block_dims = [12, 9, 1] sync_after_distribute = false : (!transform.any_op) -> !transform.any_op
    transform.yield
  }
}


// -----

!type = memref<2 x 32 x f32>
!type1d = memref<32 x f32>

// CHECK-DAG: #[[$MAPWGLIN:.*]] = affine_map<()[s0, s1, s2] -> (s0 + s1 * 32 + s2 * 256)>
// CHECK-DAG: #[[$MAPWGX:.*]] = affine_map<()[s0, s1] -> (((s0 + s1 * 32) floordiv 128) mod 2)>
// CHECK-DAG: #[[$MAPWGY:.*]] = affine_map<()[s0, s1, s2] -> (s2 + ((s0 + s1 * 32) floordiv 128) floordiv 2)>

// CHECK-LABEL: func.func @warpgroup_linear(
// CHECK-SAME:    %[[ARGX:[0-9a-z]+]]: memref<2x32xf32>
// CHECK-SAME:    %[[ARGY:[0-9a-z]+]]: memref<2x32xf32>
// CHECK-SAME:    %[[ARGT:[0-9a-z]+]]: memref<32xf32>
func.func @warpgroup_linear(%x: !type, %y: !type, %t: !type1d, %alpha : f32, %stream : !gpu.async.token) -> !type {
  %c2 = arith.constant 2 : index
  %c3 = arith.constant 3 : index
  %one = arith.constant 1 : index

// CHECK-DAG: %[[C1:.*]] = arith.constant 1 : index
// CHECK-DAG: %[[C768:.*]] = arith.constant 768 : index
// CHECK-DAG: %[[C32:.*]] = arith.constant 32 : index
// CHECK-DAG: %[[C8:.*]] = arith.constant 8 : index
// CHECK-DAG: %[[C4:.*]] = arith.constant 4 : index

// CHECK-DAG: %[[TIDX:.*]] = gpu.thread_id  x
// CHECK-DAG: %[[TIDY:.*]] = gpu.thread_id  y
// CHECK-DAG: %[[TIDZ:.*]] = gpu.thread_id  z
// CHECK-DAG: %[[WIDLIN:.*]] = affine.apply #[[$MAPWGLIN]]()[%[[TIDX]], %[[TIDY]], %[[TIDZ]]]
// CHECK-DAG: %[[WIDX:.*]] = affine.apply #[[$MAPWGX]]()[%[[TIDX]], %[[TIDY]]]
// CHECK-DAG: %[[WIDY:.*]] = affine.apply #[[$MAPWGY]]()[%[[TIDX]], %[[TIDY]], %[[TIDZ]]]
// CHECK-DAG: %[[CMPLIN:.*]] = arith.cmpi ult, %[[WIDLIN]], %[[C768]] : index
//     CHECK: scf.if %[[CMPLIN]]
//      CHECK:   memref.load %[[ARGX]][%[[WIDX]], %[[WIDY]]]
//      CHECK:   memref.load %[[ARGY]][%[[WIDX]], %[[WIDY]]]
  %name = gpu.launch async[%stream] blocks(%arg3, %arg4, %arg5) in (%arg9 = %one, %arg10 = %one, %arg11 = %one)
            threads(%arg6, %arg7, %arg8) in (%arg12 = %one, %arg13 = %one, %arg14 = %one)
  {
    scf.forall (%i, %j) in (%c2, %c3) {
        %4 = memref.load %x[%i, %j] : !type
        %5 = memref.load %y[%i, %j] : !type
        %6 = math.fma %alpha, %4, %5 : f32
        memref.store %6, %y[%i, %j] : !type
     }  { mapping = [#gpu.warpgroup<linear_dim_0>, #gpu.warpgroup<linear_dim_1>]}
    gpu.terminator
  }
  return %y : !type
}

module attributes {transform.with_named_sequence} {
  transform.named_sequence @__transform_main(%arg0: !transform.any_op {transform.readonly}) {
    %funcop = transform.structured.match ops{["gpu.launch"]} in %arg0 : (!transform.any_op) -> !transform.any_op
    transform.gpu.map_nested_forall_to_threads %funcop block_dims = [32, 8, 4] : (!transform.any_op) -> !transform.any_op
    transform.yield
  }
}

// -----

!type = memref<2 x 32 x f32>
!type1d = memref<32 x f32>

// CHECK-DAG: #[[$MAPWLIN:.*]] = affine_map<()[s0, s1, s2] -> (s0 + s1 * 32 + s2 * 256)>
// CHECK-DAG: #[[$MAPWX:.*]] = affine_map<()[s0, s1, s2] -> ((s1 + s2 * 8 + s0 floordiv 32) mod 2)>
// CHECK-DAG: #[[$MAPWY:.*]] = affine_map<()[s0, s1, s2] -> ((s1 + s2 * 8 + s0 floordiv 32) floordiv 2)>

// CHECK-LABEL: func.func @warp_linear(
// CHECK-SAME:    %[[ARGX:[0-9a-z]+]]: memref<2x32xf32>
// CHECK-SAME:    %[[ARGY:[0-9a-z]+]]: memref<2x32xf32>
// CHECK-SAME:    %[[ARGT:[0-9a-z]+]]: memref<32xf32>
func.func @warp_linear(%x: !type, %y: !type, %t: !type1d, %alpha : f32, %stream : !gpu.async.token) -> !type {
  %c2 = arith.constant 2 : index
  %c3 = arith.constant 3 : index
  %one = arith.constant 1 : index

// CHECK-DAG: %[[C1:.*]] = arith.constant 1 : index
// CHECK-DAG: %[[C32:.*]] = arith.constant 32 : index
// CHECK-DAG: %[[C8:.*]] = arith.constant 8 : index
// CHECK-DAG: %[[C4:.*]] = arith.constant 4 : index
// CHECK-DAG: %[[C192:.*]] = arith.constant 192 : index

// CHECK-DAG: %[[TIDX:.*]] = gpu.thread_id  x
// CHECK-DAG: %[[TIDY:.*]] = gpu.thread_id  y
// CHECK-DAG: %[[TIDZ:.*]] = gpu.thread_id  z
// CHECK-DAG: %[[WIDLIN:.*]] = affine.apply #[[$MAPWLIN]]()[%[[TIDX]], %[[TIDY]], %[[TIDZ]]]
// CHECK-DAG: %[[WIDX:.*]] = affine.apply #[[$MAPWX]]()[%[[TIDX]], %[[TIDY]], %[[TIDZ]]]
// CHECK-DAG: %[[WIDY:.*]] = affine.apply #[[$MAPWY]]()[%[[TIDX]], %[[TIDY]], %[[TIDZ]]]
// CHECK-DAG: %[[CMPLIN:.*]] = arith.cmpi ult, %[[WIDLIN]], %[[C192]] : index
//     CHECK: scf.if %[[CMPLIN]]
//      CHECK:   memref.load %[[ARGX]][%[[WIDX]], %[[WIDY]]]
//      CHECK:   memref.load %[[ARGY]][%[[WIDX]], %[[WIDY]]]
  %name = gpu.launch async[%stream] blocks(%arg3, %arg4, %arg5) in (%arg9 = %one, %arg10 = %one, %arg11 = %one)
            threads(%arg6, %arg7, %arg8) in (%arg12 = %one, %arg13 = %one, %arg14 = %one)
  {
    scf.forall (%i, %j) in (%c2, %c3) {
        %4 = memref.load %x[%i, %j] : !type
        %5 = memref.load %y[%i, %j] : !type
        %6 = math.fma %alpha, %4, %5 : f32
        memref.store %6, %y[%i, %j] : !type
     }  { mapping = [#gpu.warp<linear_dim_0>, #gpu.warp<linear_dim_1>]}
    gpu.terminator
  }
  return %y : !type
}

module attributes {transform.with_named_sequence} {
  transform.named_sequence @__transform_main(%arg0: !transform.any_op {transform.readonly}) {
    %funcop = transform.structured.match ops{["gpu.launch"]} in %arg0 : (!transform.any_op) -> !transform.any_op
    transform.gpu.map_nested_forall_to_threads %funcop block_dims = [32, 8, 4] : (!transform.any_op) -> !transform.any_op
    transform.yield
  }
}

// -----

!type = memref<2 x 32 x f32>
!type1d = memref<32 x f32>

// CHECK-DAG: #[[$MAPWX:.*]] = affine_map<()[s0, s1] -> (((s0 + s1 * 18) floordiv 32) mod 3)>
// CHECK-DAG: #[[$MAPWY:.*]] = affine_map<()[s0, s1] -> ((((s0 + s1 * 18) floordiv 32) mod 6) floordiv 3)>

// CHECK-DAG: #[[$MAPLIN:.*]] = affine_map<()[s0, s1] -> (s0 + s1 * 18)>
// CHECK-DAG: #[[$MAPLX:.*]] = affine_map<()[s0, s1] -> ((s0 + s1 * 18) mod 10)>
// CHECK-DAG: #[[$MAPLY:.*]] = affine_map<()[s0, s1] -> ((s0 + s1 * 18) floordiv 10)>

// CHECK-LABEL: func.func @map_multi_level_linear(
func.func @map_multi_level_linear(%x: !type, %y: !type, %t: !type1d, %alpha : f32, %stream : !gpu.async.token) -> !type {
  %one = arith.constant 1 : index
  %c10 = arith.constant 10 : index
  %c9 = arith.constant 9 : index
  %c7 = arith.constant 7 : index
  %c1 = arith.constant 1 : index
  %c2 = arith.constant 2 : index
  %c3 = arith.constant 3 : index

  // CHECK-DAG: %[[C1:.*]] = arith.constant 1 : index
  // CHECK-DAG: %[[C11:.*]] = arith.constant 11 : index
  // CHECK-DAG: %[[C18:.*]] = arith.constant 18 : index
  // CHECK-DAG: %[[C20:.*]] = arith.constant 20 : index
  // CHECK-DAG: %[[C192:.*]] = arith.constant 192 : index

  // check that both the thread level and the warp level got distributed.
  //  CHECK-NOT: #gpu.thread
  //  CHECK-NOT: #gpu.warp
  %name = gpu.launch async[%stream] blocks(%arg3, %arg4, %arg5) in (%arg9 = %one, %arg10 = %one, %arg11 = %one)
            threads(%arg6, %arg7, %arg8) in (%arg12 = %one, %arg13 = %one, %arg14 = %one)
  {
    // CHECK-DAG: %[[TIDX:.*]] = gpu.thread_id  x
    // CHECK-DAG: %[[TIDY:.*]] = gpu.thread_id  y
    scf.forall (%i, %j) in (%c7, %c9) {
      %4 = memref.load %x[%i, %j] : !type
      %5 = memref.load %y[%i, %j] : !type
      %6 = math.fma %alpha, %4, %5 : f32
      memref.store %6, %y[%i, %j] : !type
    }  { mapping = [#gpu.thread<y>, #gpu.thread<x>]}

    // CHECK-DAG: %[[LIN:.*]] = affine.apply #[[$MAPLIN]]()[%[[TIDX]], %[[TIDY]]]
    // CHECK-DAG: %[[WIDX:.*]] = affine.apply #[[$MAPWX]]()[%[[TIDX]], %[[TIDY]]]
    // CHECK-DAG: %[[WIDY:.*]] = affine.apply #[[$MAPWY]]()[%[[TIDX]], %[[TIDY]]]
    // CHECK-DAG: %[[CMPLIN:.*]] = arith.cmpi ult, %[[LIN]], %[[C192]] : index
    //     CHECK: scf.if %[[CMPLIN]]
    scf.forall (%i, %j, %k) in (%c3, %c2, %c1) {
        %7 = memref.load %x[%i, %j] : !type
        %8 = arith.addf %alpha, %7 : f32
        memref.store %8, %y[%i, %j] : !type
     }  {mapping = [#gpu.warp<linear_dim_0>, #gpu.warp<linear_dim_1>, #gpu.warp<linear_dim_2>] }

    // CHECK-DAG: %[[LIDX:.*]] = affine.apply #[[$MAPLX]]()[%[[TIDX]], %[[TIDY]]]
    // CHECK-DAG: %[[LIDY:.*]] = affine.apply #[[$MAPLY]]()[%[[TIDX]], %[[TIDY]]]
    // CHECK-DAG: %[[COND:.*]] = arith.cmpi ult, %[[LIN]], %[[C20]] : index
    //     CHECK: scf.if %[[COND]]
    //     CHECK:   memref.load %{{.*}}[%[[LIDX]]] : memref<32xf32>
    //     CHECK:   memref.store %{{.*}}[%[[LIDY]]] : memref<32xf32>
    scf.forall (%i, %j) in (%c10, %c2) {
        %7 = memref.load %t[%i] : !type1d
        %8 = arith.addf %alpha, %7 : f32
        memref.store %8, %t[%j] : !type1d
     }  {mapping = [#gpu.thread<linear_dim_0>, #gpu.thread<linear_dim_1>] }
    gpu.terminator
  }
  return %y : !type
}

module attributes {transform.with_named_sequence} {
  transform.named_sequence @__transform_main(%arg0: !transform.any_op {transform.readonly}) {
    %funcop = transform.structured.match ops{["gpu.launch"]} in %arg0 : (!transform.any_op) -> !transform.any_op
    transform.gpu.map_nested_forall_to_threads %funcop
      block_dims = [18, 11, 1] : (!transform.any_op) -> !transform.any_op
      transform.yield
  }
}

// -----

!type = memref<2 x 32 x f32>
!type1d = memref<32 x f32>

// CHECK-DAG: #[[$MAPBLIN:.*]] = affine_map<()[s0, s1, s2] -> (s0 + s1 * 12 + s2 * 108)> 
// CHECK-DAG: #[[$MAPBX:.*]] = affine_map<()[s0, s1, s2] -> ((s0 + s1 * 12 + s2 * 108) mod 7)>
// CHECK-DAG: #[[$MAPBY:.*]] = affine_map<()[s0, s1, s2] -> ((s0 + s1 * 12 + s2 * 108) floordiv 7)>

// CHECK-LABEL: func.func @block_linear_existing_launch(
// CHECK-SAME:    %[[ARGX:[0-9a-z]+]]: memref<2x32xf32>
// CHECK-SAME:    %[[ARGY:[0-9a-z]+]]: memref<2x32xf32>
// CHECK-SAME:    %[[ARGT:[0-9a-z]+]]: memref<32xf32>
func.func @block_linear_existing_launch(
    %x: !type, %y: !type, %t: !type1d, %alpha : f32, %stream : !gpu.async.token) -> !type {
  %c9 = arith.constant 9 : index
  %c7 = arith.constant 7 : index
  %one = arith.constant 1 : index
  // CHECK-DAG: %[[C1:.*]] = arith.constant 1 : index
  // CHECK-DAG: %[[C9:.*]] = arith.constant 9 : index
  // CHECK-DAG: %[[C12:.*]] = arith.constant 12 : index
  // CHECK-DAG: %[[C63:.*]] = arith.constant 63 : index
//      CHECK:   gpu.launch async [{{.*}}] blocks({{.*}}) in (%{{.*}} = %[[C12]], %{{.*}} = %[[C9]], %{{.*}} = %[[C1]]) threads
//  CHECK-DAG: %[[BIDX:.*]] = gpu.block_id  x
//  CHECK-DAG: %[[BIDY:.*]] = gpu.block_id  y
//  CHECK-DAG: %[[BIDZ:.*]] = gpu.block_id  z
//  CHECK-DAG: %[[BIDLIN:.*]] = affine.apply #[[$MAPBLIN]]()[%[[BIDX]], %[[BIDY]], %[[BIDZ]]]
//  CHECK-DAG: %[[BLX:.*]] = affine.apply #[[$MAPBX]]()[%[[BIDX]], %[[BIDY]], %[[BIDZ]]]
//  CHECK-DAG: %[[BLY:.*]] = affine.apply #[[$MAPBY]]()[%[[BIDX]], %[[BIDY]], %[[BIDZ]]]
//  CHECK-DAG: %[[CMPLIN:.*]] = arith.cmpi ult, %[[BIDLIN]], %[[C63]] : index
//     CHECK: scf.if %[[CMPLIN]]
//      CHECK:   memref.load %[[ARGX]][%[[BLX]], %[[BLY]]]
//      CHECK:   memref.load %[[ARGY]][%[[BLX]], %[[BLY]]]
  %name = gpu.launch async[%stream] blocks(%arg3, %arg4, %arg5) in (%arg9 = %one, %arg10 = %one, %arg11 = %one)
            threads(%arg6, %arg7, %arg8) in (%arg12 = %one, %arg13 = %one, %arg14 = %one)
  {
    scf.forall (%i, %j) in (%c7, %c9) {
        %4 = memref.load %x[%i, %j] : !type
        %5 = memref.load %y[%i, %j] : !type
        %6 = math.fma %alpha, %4, %5 : f32
        memref.store %6, %y[%i, %j] : !type
     }  { mapping = [#gpu.block<linear_dim_0>, #gpu.block<linear_dim_1>]}
    gpu.terminator
  }
  return %y : !type
}

module attributes {transform.with_named_sequence} {
  transform.named_sequence @__transform_main(%arg0: !transform.any_op {transform.readonly}) {
    %funcop = transform.structured.match ops{["gpu.launch"]} in %arg0 : (!transform.any_op) -> !transform.any_op
    transform.gpu.map_forall_to_blocks %funcop grid_dims = [12, 9, 1] : (!transform.any_op) -> !transform.any_op
    transform.yield
  }
}

// -----

!type = memref<2 x 32 x f32>
!type1d = memref<32 x f32>

// CHECK-DAG: #[[$MAPBX:.*]] = affine_map<()[s0] -> (s0 mod 7)>
// CHECK-DAG: #[[$MAPBY:.*]] = affine_map<()[s0, s1, s2] -> (s1 + s2 * 9 + s0 floordiv 7)>

// CHECK-LABEL: func.func @block_linear_generate_launch(
// CHECK-SAME:    %[[ARGX:[0-9a-z]+]]: memref<2x32xf32>
// CHECK-SAME:    %[[ARGY:[0-9a-z]+]]: memref<2x32xf32>
// CHECK-SAME:    %[[ARGT:[0-9a-z]+]]: memref<32xf32>
func.func @block_linear_generate_launch(
    %x: !type, %y: !type, %t: !type1d, %alpha : f32, %stream : !gpu.async.token) -> !type {
  %c9 = arith.constant 9 : index
  %c7 = arith.constant 7 : index
  %one = arith.constant 1 : index

  // CHECK-DAG: %[[C1:.*]] = arith.constant 1 : index
  // CHECK-DAG: %[[C7:.*]] = arith.constant 7 : index
  // CHECK-DAG: %[[C9:.*]] = arith.constant 9 : index
//      CHECK:   gpu.launch blocks({{.*}}) in (%{{.*}} = %[[C7]], %{{.*}} = %[[C9]], %{{.*}} = %[[C1]]) threads
//  CHECK-DAG: %[[BIDX:.*]] = gpu.block_id  x
//  CHECK-DAG: %[[BIDY:.*]] = gpu.block_id  y
//  CHECK-DAG: %[[BIDZ:.*]] = gpu.block_id  z
//  CHECK-DAG: %[[BLX:.*]] = affine.apply #[[$MAPBX]]()[%[[BIDX]]]
//  CHECK-DAG: %[[BLY:.*]] = affine.apply #[[$MAPBY]]()[%[[BIDX]], %[[BIDY]], %[[BIDZ]]]
//      CHECK:   memref.load %[[ARGX]][%[[BLX]], %[[BLY]]]
//      CHECK:   memref.load %[[ARGY]][%[[BLX]], %[[BLY]]]
  scf.forall (%i, %j) in (%c7, %c9) {
    %4 = memref.load %x[%i, %j] : !type
    %5 = memref.load %y[%i, %j] : !type
    %6 = math.fma %alpha, %4, %5 : f32
    memref.store %6, %y[%i, %j] : !type
  }  { mapping = [#gpu.block<linear_dim_0>, #gpu.block<linear_dim_1>]}

  return %y : !type
}

module attributes {transform.with_named_sequence} {
  transform.named_sequence @__transform_main(%arg0: !transform.any_op {transform.readonly}) {
    %funcop = transform.structured.match ops{["func.func"]} in %arg0 : (!transform.any_op) -> !transform.any_op
    transform.gpu.map_forall_to_blocks %funcop generate_gpu_launch : (!transform.any_op) -> !transform.any_op
    transform.yield
  }
}

// -----

#map = affine_map<(d0) -> (d0 *  128)>
#map1 = affine_map<(d0) -> (d0 * 32)>

// CHECK-DAG: #[[$MAPB:.*]] = affine_map<()[s0] -> (s0 * 128)>
// CHECK-DAG: #[[$MAPW:.*]] = affine_map<()[s0, s1, s2] -> (s2 * 32 + ((s0 + s1 * 4) floordiv 32) * 32)>

// CHECK-LABEL: func.func @simple_fill(
func.func @simple_fill(%arg0: memref<128xf32>) -> memref<128xf32> {
  %c0 = arith.constant 0 : index
  %cst = arith.constant dense<0.000000e+00> : vector<32xf32>
//       CHECK:   %[[C1:.*]] = arith.constant 1 : index
//       CHECK:   %[[C4:.*]] = arith.constant 4 : index
//       CHECK:   %[[C8:.*]] = arith.constant 8 : index
//       CHECK:   gpu.launch
  scf.forall (%arg1) in (1) {
//       CHECK:     %[[BIDX:.*]] = gpu.block_id  x
//       CHECK:     %[[BLX:.*]] = affine.apply #[[$MAPB]]()[%[[BIDX]]]
    %0 = affine.apply #map(%arg1)
    %subview = memref.subview %arg0[%0] [128] [1] : memref<128xf32> to memref<128xf32, strided<[1], offset: ?>>
    scf.forall (%arg2) in (4) {
//       CHECK:     %[[TIDX:.*]] = gpu.thread_id  x
//       CHECK:     %[[TIDY:.*]] = gpu.thread_id  y
//       CHECK:     %[[TIDZ:.*]] = gpu.thread_id  z
//       CHECK:     %[[THX:.*]] = affine.apply #[[$MAPW]]()[%[[TIDX]], %[[TIDY]], %[[TIDZ]]]
//   CHECK-NOT:     scf.if
//       CHECK:       memref.subview %{{.*}}[%[[THX]]]
      %1 = affine.apply #map1(%arg2)
      %subview_0 = memref.subview %subview[%1] [32] [1] : memref<128xf32, strided<[1], offset: ?>> to memref<32xf32, strided<[1], offset: ?>>
      vector.transfer_write %cst, %subview_0[%c0] {in_bounds = [true]} : vector<32xf32>, memref<32xf32, strided<[1], offset: ?>>
      memref.copy %subview_0, %subview_0 : memref<32xf32, strided<[1], offset: ?>> to memref<32xf32, strided<[1], offset: ?>>
    } {mapping = [#gpu.warp<linear_dim_0>]}
    memref.copy %subview, %subview : memref<128xf32, strided<[1], offset: ?>> to memref<128xf32, strided<[1], offset: ?>>
  } {mapping = [#gpu.block<x>]}
  return %arg0 : memref<128xf32>
}

module attributes {transform.with_named_sequence} {
  transform.named_sequence @__transform_main(%module_op: !transform.any_op {transform.readonly}) {
    %func = transform.structured.match ops{["func.func"]} in %module_op
      : (!transform.any_op) -> !transform.any_op
    %gpu_launch = transform.gpu.map_forall_to_blocks %func generate_gpu_launch
      : (!transform.any_op) -> !transform.any_op
    transform.gpu.map_nested_forall_to_threads %gpu_launch block_dims = [4, 8, 4]
      : (!transform.any_op) -> !transform.any_op
      transform.yield
  }
}

// -----

#map = affine_map<(d0) -> (d0 * 128)>
#map1 = affine_map<(d0) -> (d0 * 32)>

// CHECK-DAG: #[[$MAPB:.*]] = affine_map<()[s0] -> (s0 * 128)>
// CHECK-DAG: #[[$MAPLANE:.*]] = affine_map<()[s0, s1] -> ((s0 + s1 * 73) mod 32)>
// CHECK-DAG: #[[$MAPI:.*]] = affine_map<()[s0, s1] -> (s0 * 32 + s1 * 2336 - ((s0 + s1 * 73) floordiv 2) * 64)>
// CHECK-DAG: #[[$MAPJ:.*]] = affine_map<()[s0, s1] -> ((((s0 + s1 * 73) mod 32) floordiv 2) * 32)>

// CHECK-LABEL: func.func @simple_fill(
func.func @simple_fill(%arg0: memref<128x256xf32>) -> memref<128x256xf32> {
  %c0 = arith.constant 0 : index
  %cst = arith.constant dense<0.000000e+00> : vector<16x32xf32>
    //   CHECK:   %[[C6:.*]] = arith.constant 6 : index
    //   CHECK:   gpu.launch
  scf.forall (%arg1) in (1) {
    //   CHECK:     %[[BIDX:.*]] = gpu.block_id  x
    //   CHECK:     %[[BLX:.*]] = affine.apply #[[$MAPB]]()[%[[BIDX]]]
    %0 = affine.apply #map(%arg1)
    %subview = memref.subview %arg0[%0, 0] [128, 256] [1, 1]
      : memref<128x256xf32> to memref<128x256xf32, strided<[256, 1], offset: ?>>

    // %arg2 and %arg3 map to lanes [0, 6) and are turned into epxressions
    // involving threadIdx.x/y by the map_nested_forall_to_threads
    // transformation. This results in a if (linear_thread_id < 6) conditional.
    scf.forall (%arg2, %arg3) in (2, 3) {
      //       CHECK:     %[[TIDX:.*]] = gpu.thread_id  x
      //       CHECK:     %[[TIDY:.*]] = gpu.thread_id  y
      //       CHECK:     %[[LID:.*]] = affine.apply #[[$MAPLANE]]()[%[[TIDX]], %[[TIDY]]]
      //       CHECK:     %[[COND:.*]] = arith.cmpi ult, %[[LID]], %[[C6]]
      //       CHECK:     scf.if %[[COND]]
      //       CHECK:       %[[I:.*]] = affine.apply #[[$MAPI]]()[%[[TIDX]], %[[TIDY]]]
      //       CHECK:       %[[J:.*]] = affine.apply #[[$MAPJ]]()[%[[TIDX]], %[[TIDY]]]
      //       CHECK:       memref.subview %{{.*}}[%[[I]], %[[J]]]
      %1 = affine.apply #map1(%arg2)
      %2 = affine.apply #map1(%arg3)
      %subview_0 = memref.subview %subview[%1, %2] [16, 32] [1, 1] 
        : memref<128x256xf32, strided<[256, 1], offset: ?>> to memref<16x32xf32, strided<[256, 1], offset: ?>>
      vector.transfer_write %cst, %subview_0[%c0, %c0] {in_bounds = [true, true]} 
        : vector<16x32xf32>, memref<16x32xf32, strided<[256, 1], offset: ?>>

    // This could be obtained e.g. if a previous transformation mapped this loop
    // to lanes. This can aslo be written by hand as valid IR.
    } {mapping = [#gpu.lane<linear_dim_0>, #gpu.lane<linear_dim_1>]}
  } {mapping = [#gpu.block<x>]}
  return %arg0 : memref<128x256xf32>
}

module attributes {transform.with_named_sequence} {
  transform.named_sequence @__transform_main(%module_op: !transform.any_op {transform.readonly}) {
    %func = transform.structured.match ops{["func.func"]} in %module_op
      : (!transform.any_op) -> !transform.any_op
    %gpu_launch = transform.gpu.map_forall_to_blocks %func generate_gpu_launch
      : (!transform.any_op) -> !transform.any_op

    // This transformation maps scf.forall ivs to a particular mapping of thread
    // ids (laneid, threadid, warpid or warpgroupid).
    transform.gpu.map_nested_forall_to_threads %gpu_launch block_dims = [73, 5, 1]
      : (!transform.any_op) -> !transform.any_op
      transform.yield
  }
}

// -----

#map = affine_map<(d0) -> (d0 *  128)>
#map1 = affine_map<(d0) -> (d0 * 32)>

// CHECK-DAG: #[[$MAPB:.*]] = affine_map<()[s0] -> (s0 * 128)>
// CHECK-DAG: #[[$MAP_LIN_W:.*]] = affine_map<()[s0, s1] -> ((s0 + s1 * 73) floordiv 32)>
// CHECK-DAG: #[[$MAP_W0:.*]] = affine_map<()[s0] -> (s0 * 32 - (s0 floordiv 2) * 64)>
// CHECK-DAG: #[[$MAP_W1:.*]] = affine_map<()[s0] -> ((s0 floordiv 2) * 32)>

// CHECK-LABEL: func.func @simple_fill(
func.func @simple_fill(%arg0: memref<128xf32>) -> memref<128xf32> {
  %c0 = arith.constant 0 : index
  %cst = arith.constant dense<0.000000e+00> : vector<32xf32>
//   CHECK-DAG:   %[[C0_i64:.*]] = arith.constant 0 : i64
//   CHECK-DAG:   %[[C1_i64:.*]] = arith.constant 1 : i64
/// 0x2f1 is 753
//   CHECK-DAG:   %[[C753_i64:.*]] = arith.constant 753 : i64

//       CHECK:   gpu.launch
  scf.forall (%arg1) in (1) {
//       CHECK:     %[[BIDX:.*]] = gpu.block_id  x
//       CHECK:     %[[BLX:.*]] = affine.apply #[[$MAPB]]()[%[[BIDX]]]
    %0 = affine.apply #map(%arg1)
    %subview = memref.subview %arg0[%0] [128] [1] : memref<128xf32> to memref<128xf32, strided<[1], offset: ?>>

    // %arg2 and %arg3 map to lanes [0, 6) and are turned into epxressions
    // involving threadIdx.x/y by the map_nested_forall_to_threads
    // transformation. This results in a if (linear_thread_id < 6) conditional.
    scf.forall (%arg2, %arg3) in (2, 3) {
      //       CHECK:     %[[TIDX:.*]] = gpu.thread_id  x
      //       CHECK:     %[[TIDY:.*]] = gpu.thread_id  y

      //       CHECK:     %[[LIN_W:.*]] = affine.apply #[[$MAP_LIN_W]]()[%[[TIDX]], %[[TIDY]]]
      //
      // Compute the active warps below using the mask + popcnt
      //       CHECK:     %[[LIN_W_i64:.*]] = arith.index_castui %[[LIN_W]] : index to i64
      //       CHECK:     %[[TWO_POW_W:.*]] = arith.shli %[[C1_i64]], %[[LIN_W_i64]] : i64
      //       CHECK:     %[[FILTER_TILL_W:.*]] = arith.subi %[[TWO_POW_W]], %[[C1_i64]] : i64
      //       CHECK:     %[[ACTIVE_TILL_W:.*]] = arith.andi %[[FILTER_TILL_W]], %[[C753_i64]] : i64
      //       CHECK:     %[[LOGICAL_ID_W_i64:.*]] = math.ctpop %[[ACTIVE_TILL_W]] : i64
      //       CHECK:     %[[LOGICAL_ID_W:.*]] = arith.index_castui %[[LOGICAL_ID_W_i64]] : i64 to index
      //
      // Dynamically compute whether this warp is active below using the mask + popcnt
      //       CHECK:     %[[IS_ACTIVE_W_MASK:.*]] = arith.andi %[[TWO_POW_W]], %[[C753_i64]] : i64
      //       CHECK:     %[[IS_ACTIVE_W:.*]] = arith.cmpi ne, %[[IS_ACTIVE_W_MASK]], %[[C0_i64]] : i64
      //       CHECK:     scf.if %[[IS_ACTIVE_W]] {

      //       CHECK:       %[[W0:.*]] = affine.apply #[[$MAP_W0]]()[%[[LOGICAL_ID_W]]]
      //       CHECK:       %[[W1:.*]] = affine.apply #[[$MAP_W1]]()[%[[LOGICAL_ID_W]]]
      //       CHECK:       memref.subview %{{.*}}[%[[W0]]] [%[[W1]]]
      %1 = affine.apply #map1(%arg2)
      %2 = affine.apply #map1(%arg3)
      %subview_0 = memref.subview %subview[%1] [%2] [1] : memref<128xf32, strided<[1], offset: ?>> to memref<?xf32, strided<[1], offset: ?>>
      vector.transfer_write %cst, %subview_0[%c0] {in_bounds = [true]} : vector<32xf32>, memref<?xf32, strided<[1], offset: ?>>

    // This could be obtained e.g. if a previous transformation mapped this loop
    // to lanes. This can aslo be written by hand as valid IR.
    // This additionally uses the hex mask: 0x 10 1111 0001
    } {mapping = [#gpu.warp<linear_dim_0>, #gpu.warp<linear_dim_1>, #gpu.mask<0x2f1>]}

    memref.copy %subview, %subview : memref<128xf32, strided<[1], offset: ?>> to memref<128xf32, strided<[1], offset: ?>>
  } {mapping = [#gpu.block<x>]}
  return %arg0 : memref<128xf32>
}

module attributes {transform.with_named_sequence} {
  transform.named_sequence @__transform_main(%module_op: !transform.any_op {transform.readonly}) {
    %func = transform.structured.match ops{["func.func"]} in %module_op
      : (!transform.any_op) -> !transform.any_op
    %gpu_launch = transform.gpu.map_forall_to_blocks %func generate_gpu_launch
      : (!transform.any_op) -> !transform.any_op

    // This transformation maps scf.forall ivs to a particular mapping of thread
    // ids (laneid, threadid, warpid or warpgroupid).
    transform.gpu.map_nested_forall_to_threads %gpu_launch block_dims = [73, 5, 1]
      : (!transform.any_op) -> !transform.any_op
      transform.yield
  }
}
