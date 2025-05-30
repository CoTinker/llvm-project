// This test checks that the SEH directives emit the correct unwind data.

// RUN: llvm-mc -triple aarch64-pc-win32 -filetype=obj %s | llvm-readobj -S -r -u - | FileCheck %s

// Check that the output assembler directives also can be parsed, and
// that they produce equivalent output:

// RUN: llvm-mc -triple aarch64-pc-win32 -filetype=asm %s | llvm-mc -triple aarch64-pc-win32 -filetype=obj - | llvm-readobj -S -r -u - | FileCheck %s

// CHECK:      Sections [
// CHECK:        Section {
// CHECK:          Name: .text
// CHECK:          RelocationCount: 0
// CHECK:          Characteristics [
// CHECK-NEXT:       ALIGN_4BYTES
// CHECK-NEXT:       CNT_CODE
// CHECK-NEXT:       MEM_EXECUTE
// CHECK-NEXT:       MEM_READ
// CHECK-NEXT:     ]
// CHECK-NEXT:   }
// CHECK:        Section {
// CHECK:          Name: .xdata
// CHECK:          RawDataSize: 100
// CHECK:          RelocationCount: 1
// CHECK:          Characteristics [
// CHECK-NEXT:       ALIGN_4BYTES
// CHECK-NEXT:       CNT_INITIALIZED_DATA
// CHECK-NEXT:       MEM_READ
// CHECK-NEXT:     ]
// CHECK-NEXT:   }
// CHECK:        Section {
// CHECK:          Name: .pdata
// CHECK:          RelocationCount: 2
// CHECK:          Characteristics [
// CHECK-NEXT:       ALIGN_4BYTES
// CHECK-NEXT:       CNT_INITIALIZED_DATA
// CHECK-NEXT:       MEM_READ
// CHECK-NEXT:     ]
// CHECK-NEXT:   }
// CHECK-NEXT: ]

// CHECK-NEXT: Relocations [
// CHECK-NEXT:   Section (4) .xdata {
// CHECK-NEXT:     0x58 IMAGE_REL_ARM64_ADDR32NB __C_specific_handler
// CHECK-NEXT:   }
// CHECK-NEXT:   Section (5) .pdata {
// CHECK-NEXT:     0x0 IMAGE_REL_ARM64_ADDR32NB .text
// CHECK-NEXT:     0x4 IMAGE_REL_ARM64_ADDR32NB .xdata
// CHECK-NEXT:   }
// CHECK-NEXT: ]

// CHECK-NEXT: UnwindInformation [
// CHECK-NEXT:   RuntimeFunction {
// CHECK-NEXT:     Function: func
// CHECK-NEXT:     ExceptionRecord: .xdata
// CHECK-NEXT:     ExceptionData {
// CHECK-NEXT:       FunctionLength: 172
// CHECK:            Prologue [
// CHECK-NEXT:         0xe716c3            ; str p6, [sp, #3, mul vl]
// CHECK-NEXT:         0xe703c5            ; str z11, [sp, #5, mul vl]
// CHECK-NEXT:         0xdf05              ; addvl sp, #-5
// CHECK-NEXT:         0xe76983            ; stp q9, q10, [sp, #-64]!
// CHECK-NEXT:         0xe73d83            ; str q29, [sp, #-64]!
// CHECK-NEXT:         0xe76243            ; stp d2, d3, [sp, #-64]!
// CHECK-NEXT:         0xe73f43            ; str d31, [sp, #-64]!
// CHECK-NEXT:         0xe77d03            ; stp x29, x30, [sp, #-64]!
// CHECK-NEXT:         0xe73e03            ; str x30, [sp, #-64]!
// CHECK-NEXT:         0xe74384            ; stp q3, q4, [sp, #64]
// CHECK-NEXT:         0xe71e84            ; str q30, [sp, #64]
// CHECK-NEXT:         0xe74444            ; stp d4, d5, [sp, #64]
// CHECK-NEXT:         0xe71d48            ; str d29, [sp, #64]
// CHECK-NEXT:         0xe74104            ; stp x1, x2, [sp, #64]
// CHECK-NEXT:         0xe70008            ; str x0, [sp, #64]
// CHECK-NEXT:         0xfc                ; pacibsp
// CHECK-NEXT:         0xec                ; clear unwound to call
// CHECK-NEXT:         0xeb                ; EC context
// CHECK-NEXT:         0xea                ; context
// CHECK-NEXT:         0xe9                ; machine frame
// CHECK-NEXT:         0xe8                ; trap frame
// CHECK-NEXT:         0xe3                ; nop
// CHECK-NEXT:         0xe202              ; add fp, sp, #16
// CHECK-NEXT:         0xdd41              ; str d13, [sp, #8]
// CHECK-NEXT:         0xde83              ; str d12, [sp, #-32]!
// CHECK-NEXT:         0xd884              ; stp d10, d11, [sp, #32]
// CHECK-NEXT:         0xda05              ; stp d8, d9, [sp, #-48]!
// CHECK-NEXT:         0x83                ; stp x29, x30, [sp, #-32]!
// CHECK-NEXT:         0x46                ; stp x29, x30, [sp, #48]
// CHECK-NEXT:         0xd141              ; str x24, [sp, #8]
// CHECK-NEXT:         0xd483              ; str x23, [sp, #-32]!
// CHECK-NEXT:         0xe6                ; save next
// CHECK-NEXT:         0xc882              ; stp x21, x22, [sp, #16]
// CHECK-NEXT:         0xd6c2              ; stp x25, lr, [sp, #16]
// CHECK-NEXT:         0x24                ; stp x19, x20, [sp, #-32]!
// CHECK-NEXT:         0xcc83              ; stp x21, x22, [sp, #-32]!
// CHECK-NEXT:         0x83                ; stp x29, x30, [sp, #-32]!
// CHECK-NEXT:         0xe1                ; mov fp, sp
// CHECK-NEXT:         0x01                ; sub sp, #16
// CHECK-NEXT:         0xe4                ; end
// CHECK-NEXT:       ]
// CHECK-NEXT:       EpilogueScopes [
// CHECK-NEXT:         EpilogueScope {
// CHECK-NEXT:           StartOffset: 41
// CHECK-NEXT:           EpilogueStartIndex: 77
// CHECK-NEXT:           Opcodes [
// CHECK-NEXT:             0x01                ; add sp, #16
// CHECK-NEXT:             0xe4                ; end
// CHECK-NEXT:           ]
// CHECK-NEXT:         }
// CHECK-NEXT:       ]
// CHECK-NEXT:       ExceptionHandler [
// CHECK-NEXT:         Routine: __C_specific_handler (0x0)
// CHECK-NEXT:         Parameter: 0x0
// CHECK-NEXT:       ]
// CHECK-NEXT:     }
// CHECK-NEXT:   }
// CHECK-NEXT: ]


    .text
    .globl func
    .def func
    .scl 2
    .type 32
    .endef
    .seh_proc func
func:
    sub sp, sp, #24
    .seh_stackalloc 24
    mov x29, sp
    .seh_set_fp
    stp x29, x30, [sp, #-32]!
    .seh_save_fplr_x 32
    stp x21, x22, [sp, #-32]!
    .seh_save_regp_x x21, 32
    stp x19, x20, [sp, #-32]!
    .seh_save_r19r20_x 32
    stp x25, x30, [sp, #16]
    .seh_save_lrpair x25, 16
    stp x21, x22, [sp, #16]
    .seh_save_regp x21, 16
    stp x23, x24, [sp, #32]
    .seh_save_next
    str x23, [sp, #-32]!
    .seh_save_reg_x x23, 32
    str x24, [sp, #8]
    .seh_save_reg x24, 8
    stp x29, x30, [sp, #48]
    .seh_save_fplr 48
    stp x29, x30, [sp, #-32]!
    .seh_save_fplr_x 32
    stp d8, d9, [sp, #-48]!
    .seh_save_fregp_x d8, 48
    stp d10, d11, [sp, #32]
    .seh_save_fregp d10, 32
    str d12, [sp, #-32]!
    .seh_save_freg_x d12, 32
    str d13, [sp, #8]
    .seh_save_freg d13, 8
    add x29, sp, #16
    .seh_add_fp 16
    nop
    .seh_nop
    nop
    .seh_trap_frame
    nop
    .seh_pushframe
    nop
    .seh_context
    nop
    .seh_ec_context
    nop
    .seh_clear_unwound_to_call
    pacibsp
    .seh_pac_sign_lr
    nop
    .seh_save_any_reg x0, 64
    nop
    .seh_save_any_reg_p x1, 64
    nop
    .seh_save_any_reg d29, 64
    nop
    .seh_save_any_reg_p d4, 64
    nop
    .seh_save_any_reg q30, 64
    nop
    .seh_save_any_reg_p q3, 64
    nop
    .seh_save_any_reg_x lr, 64
    nop
    .seh_save_any_reg_px fp, 64
    nop
    .seh_save_any_reg_x d31, 64
    nop
    .seh_save_any_reg_px d2, 64
    nop
    .seh_save_any_reg_x q29, 64
    nop
    .seh_save_any_reg_px q9, 64
    nop
    .seh_allocz 5
    nop
    .seh_save_zreg z11, 5
    nop
    .seh_save_preg p6, 3
    nop
    .seh_endprologue
    nop
    .seh_startepilogue
    add sp, sp, #24
    .seh_stackalloc 24
    .seh_endepilogue
    ret
    .seh_handler __C_specific_handler, @except
    .seh_handlerdata
    .long 0
    .text
    .seh_endproc

    // Function with no .seh directives; no pdata/xdata entries are
    // generated.
    .globl smallFunc
    .def smallFunc
    .scl 2
    .type 32
    .endef
    .seh_proc smallFunc
smallFunc:
    ret
    .seh_endproc

    // Function with no .seh directives, but with .seh_handlerdata.
    // No xdata/pdata entries are generated, but the custom handler data
    // (the .long after .seh_handlerdata) is left orphaned in the xdata
    // section.
    .globl handlerFunc
    .def handlerFunc
    .scl 2
    .type 32
    .endef
    .seh_proc handlerFunc
handlerFunc:
    ret
    .seh_handler __C_specific_handler, @except
    .seh_handlerdata
    .long 0
    .text
    .seh_endproc
