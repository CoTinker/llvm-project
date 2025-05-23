; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 2
; FIXME: Enable f16 promotion
; XUN: llc -global-isel=0 -mtriple=amdgcn -mcpu=tahiti < %s | FileCheck -check-prefixes=GCN,GFX6,GFX6-SDAG %s
; RUN: llc -global-isel=0 -mtriple=amdgcn -mcpu=tonga < %s | FileCheck -check-prefixes=GCN,GFX8,GFX8-SDAG %s
; RUN: llc -global-isel=0 -mtriple=amdgcn -mcpu=gfx900 < %s | FileCheck -check-prefixes=GCN,GFX9,GFX9-SDAG %s
; RUN: llc -global-isel=0 -mtriple=amdgcn -mcpu=gfx1100 -mattr=+real-true16 < %s | FileCheck -check-prefixes=GCN,GFX11,GFX11-SDAG,GFX11-SDAG-TRUE16 %s
; RUN: llc -global-isel=0 -mtriple=amdgcn -mcpu=gfx1100 -mattr=-real-true16 < %s | FileCheck -check-prefixes=GCN,GFX11,GFX11-SDAG,GFX11-SDAG-FAKE16 %s

; XUN: llc -global-isel=1 -mtriple=amdgcn -mcpu=tahiti < %s | FileCheck -check-prefixes=GCN,GFX6,GFX6-GISEL %s
; RUN: llc -global-isel=1 -mtriple=amdgcn -mcpu=tonga < %s | FileCheck -check-prefixes=GCN,GFX8,GFX8-GISEL %s
; RUN: llc -global-isel=1 -mtriple=amdgcn -mcpu=gfx900 < %s | FileCheck -check-prefixes=GCN,GFX9,GFX9-GISEL %s
; RUN: llc -global-isel=1 -mtriple=amdgcn -mcpu=gfx1100 -mattr=+real-true16 < %s | FileCheck -check-prefixes=GCN,GFX11,GFX11-GISEL,GFX11-GISEL-TRUE16 %s
; RUN: llc -global-isel=1 -mtriple=amdgcn -mcpu=gfx1100 -mattr=-real-true16 < %s | FileCheck -check-prefixes=GCN,GFX11,GFX11-GISEL,GFX11-GISEL-FAKE16 %s

; define half @test_ldexp_f16_i16(ptr addrspace(1) %out, half %a, i16 %b) #0 {
;   %result = call half @llvm.experimental.constrained.ldexp.f16.i16(half %a, i16 %b, metadata !"round.dynamic", metadata !"fpexcept.strict")
;   ret half %result
; }

define half @test_ldexp_f16_i32(ptr addrspace(1) %out, half %a, i32 %b) #0 {
; GFX8-SDAG-LABEL: test_ldexp_f16_i32:
; GFX8-SDAG:       ; %bb.0:
; GFX8-SDAG-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-SDAG-NEXT:    s_movk_i32 s4, 0x8000
; GFX8-SDAG-NEXT:    v_mov_b32_e32 v0, 0x7fff
; GFX8-SDAG-NEXT:    v_med3_i32 v0, v3, s4, v0
; GFX8-SDAG-NEXT:    v_ldexp_f16_e32 v0, v2, v0
; GFX8-SDAG-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-SDAG-LABEL: test_ldexp_f16_i32:
; GFX9-SDAG:       ; %bb.0:
; GFX9-SDAG-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-SDAG-NEXT:    s_movk_i32 s4, 0x8000
; GFX9-SDAG-NEXT:    v_mov_b32_e32 v0, 0x7fff
; GFX9-SDAG-NEXT:    v_med3_i32 v0, v3, s4, v0
; GFX9-SDAG-NEXT:    v_ldexp_f16_e32 v0, v2, v0
; GFX9-SDAG-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-SDAG-TRUE16-LABEL: test_ldexp_f16_i32:
; GFX11-SDAG-TRUE16:       ; %bb.0:
; GFX11-SDAG-TRUE16-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-SDAG-TRUE16-NEXT:    s_movk_i32 s0, 0x8000
; GFX11-SDAG-TRUE16-NEXT:    s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(VALU_DEP_1)
; GFX11-SDAG-TRUE16-NEXT:    v_med3_i32 v0, v3, s0, 0x7fff
; GFX11-SDAG-TRUE16-NEXT:    v_ldexp_f16_e32 v0.l, v2.l, v0.l
; GFX11-SDAG-TRUE16-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-SDAG-FAKE16-LABEL: test_ldexp_f16_i32:
; GFX11-SDAG-FAKE16:       ; %bb.0:
; GFX11-SDAG-FAKE16-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-SDAG-FAKE16-NEXT:    s_movk_i32 s0, 0x8000
; GFX11-SDAG-FAKE16-NEXT:    s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(VALU_DEP_1)
; GFX11-SDAG-FAKE16-NEXT:    v_med3_i32 v0, v3, s0, 0x7fff
; GFX11-SDAG-FAKE16-NEXT:    v_ldexp_f16_e32 v0, v2, v0
; GFX11-SDAG-FAKE16-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-GISEL-LABEL: test_ldexp_f16_i32:
; GFX8-GISEL:       ; %bb.0:
; GFX8-GISEL-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-GISEL-NEXT:    v_mov_b32_e32 v0, 0xffff8000
; GFX8-GISEL-NEXT:    v_mov_b32_e32 v1, 0x7fff
; GFX8-GISEL-NEXT:    v_med3_i32 v0, v3, v0, v1
; GFX8-GISEL-NEXT:    v_ldexp_f16_e32 v0, v2, v0
; GFX8-GISEL-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-GISEL-LABEL: test_ldexp_f16_i32:
; GFX9-GISEL:       ; %bb.0:
; GFX9-GISEL-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-GISEL-NEXT:    v_mov_b32_e32 v0, 0xffff8000
; GFX9-GISEL-NEXT:    v_mov_b32_e32 v1, 0x7fff
; GFX9-GISEL-NEXT:    v_med3_i32 v0, v3, v0, v1
; GFX9-GISEL-NEXT:    v_ldexp_f16_e32 v0, v2, v0
; GFX9-GISEL-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-GISEL-TRUE16-LABEL: test_ldexp_f16_i32:
; GFX11-GISEL-TRUE16:       ; %bb.0:
; GFX11-GISEL-TRUE16-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-GISEL-TRUE16-NEXT:    v_mov_b32_e32 v0, 0x7fff
; GFX11-GISEL-TRUE16-NEXT:    s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
; GFX11-GISEL-TRUE16-NEXT:    v_med3_i32 v0, 0xffff8000, v3, v0
; GFX11-GISEL-TRUE16-NEXT:    v_ldexp_f16_e32 v0.l, v2.l, v0.l
; GFX11-GISEL-TRUE16-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-GISEL-FAKE16-LABEL: test_ldexp_f16_i32:
; GFX11-GISEL-FAKE16:       ; %bb.0:
; GFX11-GISEL-FAKE16-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-GISEL-FAKE16-NEXT:    v_mov_b32_e32 v0, 0x7fff
; GFX11-GISEL-FAKE16-NEXT:    s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
; GFX11-GISEL-FAKE16-NEXT:    v_med3_i32 v0, 0xffff8000, v3, v0
; GFX11-GISEL-FAKE16-NEXT:    v_ldexp_f16_e32 v0, v2, v0
; GFX11-GISEL-FAKE16-NEXT:    s_setpc_b64 s[30:31]
  %result = call half @llvm.experimental.constrained.ldexp.f16.i32(half %a, i32 %b, metadata !"round.dynamic", metadata !"fpexcept.strict")
  ret half %result
}

; define <2 x half> @test_ldexp_v2f16_v2i16(ptr addrspace(1) %out, <2 x half> %a, <2 x i16> %b) #0 {
;   %result = call <2 x half> @llvm.experimental.constrained.ldexp.v2f16.v2i16(<2 x half> %a, <2 x i16> %b, metadata !"round.dynamic", metadata !"fpexcept.strict")
;   ret <2 x half> %result
; }

define <2 x half> @test_ldexp_v2f16_v2i32(ptr addrspace(1) %out, <2 x half> %a, <2 x i32> %b) #0 {
; GFX8-SDAG-LABEL: test_ldexp_v2f16_v2i32:
; GFX8-SDAG:       ; %bb.0:
; GFX8-SDAG-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-SDAG-NEXT:    s_movk_i32 s4, 0x8000
; GFX8-SDAG-NEXT:    v_mov_b32_e32 v0, 0x7fff
; GFX8-SDAG-NEXT:    v_med3_i32 v1, v3, s4, v0
; GFX8-SDAG-NEXT:    v_med3_i32 v0, v4, s4, v0
; GFX8-SDAG-NEXT:    v_ldexp_f16_e32 v1, v2, v1
; GFX8-SDAG-NEXT:    v_ldexp_f16_sdwa v0, v2, v0 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
; GFX8-SDAG-NEXT:    v_or_b32_e32 v0, v1, v0
; GFX8-SDAG-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-SDAG-LABEL: test_ldexp_v2f16_v2i32:
; GFX9-SDAG:       ; %bb.0:
; GFX9-SDAG-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-SDAG-NEXT:    s_movk_i32 s4, 0x8000
; GFX9-SDAG-NEXT:    v_mov_b32_e32 v0, 0x7fff
; GFX9-SDAG-NEXT:    v_med3_i32 v1, v3, s4, v0
; GFX9-SDAG-NEXT:    v_med3_i32 v0, v4, s4, v0
; GFX9-SDAG-NEXT:    v_ldexp_f16_e32 v1, v2, v1
; GFX9-SDAG-NEXT:    v_ldexp_f16_sdwa v0, v2, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
; GFX9-SDAG-NEXT:    s_mov_b32 s4, 0x5040100
; GFX9-SDAG-NEXT:    v_perm_b32 v0, v0, v1, s4
; GFX9-SDAG-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-SDAG-TRUE16-LABEL: test_ldexp_v2f16_v2i32:
; GFX11-SDAG-TRUE16:       ; %bb.0:
; GFX11-SDAG-TRUE16-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-SDAG-TRUE16-NEXT:    s_movk_i32 s0, 0x8000
; GFX11-SDAG-TRUE16-NEXT:    s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)
; GFX11-SDAG-TRUE16-NEXT:    v_med3_i32 v0, v3, s0, 0x7fff
; GFX11-SDAG-TRUE16-NEXT:    v_med3_i32 v1, v4, s0, 0x7fff
; GFX11-SDAG-TRUE16-NEXT:    v_ldexp_f16_e32 v0.l, v2.l, v0.l
; GFX11-SDAG-TRUE16-NEXT:    s_delay_alu instid0(VALU_DEP_2)
; GFX11-SDAG-TRUE16-NEXT:    v_ldexp_f16_e32 v0.h, v2.h, v1.l
; GFX11-SDAG-TRUE16-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-SDAG-FAKE16-LABEL: test_ldexp_v2f16_v2i32:
; GFX11-SDAG-FAKE16:       ; %bb.0:
; GFX11-SDAG-FAKE16-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-SDAG-FAKE16-NEXT:    s_movk_i32 s0, 0x8000
; GFX11-SDAG-FAKE16-NEXT:    s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)
; GFX11-SDAG-FAKE16-NEXT:    v_med3_i32 v0, v3, s0, 0x7fff
; GFX11-SDAG-FAKE16-NEXT:    v_med3_i32 v1, v4, s0, 0x7fff
; GFX11-SDAG-FAKE16-NEXT:    v_lshrrev_b32_e32 v3, 16, v2
; GFX11-SDAG-FAKE16-NEXT:    v_ldexp_f16_e32 v0, v2, v0
; GFX11-SDAG-FAKE16-NEXT:    s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)
; GFX11-SDAG-FAKE16-NEXT:    v_ldexp_f16_e32 v1, v3, v1
; GFX11-SDAG-FAKE16-NEXT:    v_perm_b32 v0, v1, v0, 0x5040100
; GFX11-SDAG-FAKE16-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-GISEL-LABEL: test_ldexp_v2f16_v2i32:
; GFX8-GISEL:       ; %bb.0:
; GFX8-GISEL-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-GISEL-NEXT:    v_mov_b32_e32 v0, 0xffff8000
; GFX8-GISEL-NEXT:    v_mov_b32_e32 v1, 0x7fff
; GFX8-GISEL-NEXT:    v_med3_i32 v3, v3, v0, v1
; GFX8-GISEL-NEXT:    v_med3_i32 v0, v4, v0, v1
; GFX8-GISEL-NEXT:    v_ldexp_f16_e32 v3, v2, v3
; GFX8-GISEL-NEXT:    v_ldexp_f16_sdwa v0, v2, v0 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
; GFX8-GISEL-NEXT:    v_or_b32_e32 v0, v3, v0
; GFX8-GISEL-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-GISEL-LABEL: test_ldexp_v2f16_v2i32:
; GFX9-GISEL:       ; %bb.0:
; GFX9-GISEL-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-GISEL-NEXT:    v_mov_b32_e32 v0, 0xffff8000
; GFX9-GISEL-NEXT:    v_mov_b32_e32 v1, 0x7fff
; GFX9-GISEL-NEXT:    v_med3_i32 v3, v3, v0, v1
; GFX9-GISEL-NEXT:    v_med3_i32 v0, v4, v0, v1
; GFX9-GISEL-NEXT:    v_ldexp_f16_e32 v3, v2, v3
; GFX9-GISEL-NEXT:    v_ldexp_f16_sdwa v0, v2, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
; GFX9-GISEL-NEXT:    v_lshl_or_b32 v0, v0, 16, v3
; GFX9-GISEL-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-GISEL-TRUE16-LABEL: test_ldexp_v2f16_v2i32:
; GFX11-GISEL-TRUE16:       ; %bb.0:
; GFX11-GISEL-TRUE16-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-GISEL-TRUE16-NEXT:    v_mov_b32_e32 v0, 0x7fff
; GFX11-GISEL-TRUE16-NEXT:    s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)
; GFX11-GISEL-TRUE16-NEXT:    v_med3_i32 v1, 0xffff8000, v3, v0
; GFX11-GISEL-TRUE16-NEXT:    v_med3_i32 v3, 0xffff8000, v4, v0
; GFX11-GISEL-TRUE16-NEXT:    v_ldexp_f16_e32 v0.l, v2.l, v1.l
; GFX11-GISEL-TRUE16-NEXT:    s_delay_alu instid0(VALU_DEP_2)
; GFX11-GISEL-TRUE16-NEXT:    v_ldexp_f16_e32 v0.h, v2.h, v3.l
; GFX11-GISEL-TRUE16-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-GISEL-FAKE16-LABEL: test_ldexp_v2f16_v2i32:
; GFX11-GISEL-FAKE16:       ; %bb.0:
; GFX11-GISEL-FAKE16-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-GISEL-FAKE16-NEXT:    v_mov_b32_e32 v0, 0x7fff
; GFX11-GISEL-FAKE16-NEXT:    s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)
; GFX11-GISEL-FAKE16-NEXT:    v_med3_i32 v1, 0xffff8000, v3, v0
; GFX11-GISEL-FAKE16-NEXT:    v_lshrrev_b32_e32 v3, 16, v2
; GFX11-GISEL-FAKE16-NEXT:    v_med3_i32 v0, 0xffff8000, v4, v0
; GFX11-GISEL-FAKE16-NEXT:    v_ldexp_f16_e32 v1, v2, v1
; GFX11-GISEL-FAKE16-NEXT:    s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)
; GFX11-GISEL-FAKE16-NEXT:    v_ldexp_f16_e32 v0, v3, v0
; GFX11-GISEL-FAKE16-NEXT:    v_and_b32_e32 v1, 0xffff, v1
; GFX11-GISEL-FAKE16-NEXT:    s_delay_alu instid0(VALU_DEP_1)
; GFX11-GISEL-FAKE16-NEXT:    v_lshl_or_b32 v0, v0, 16, v1
; GFX11-GISEL-FAKE16-NEXT:    s_setpc_b64 s[30:31]
  %result = call <2 x half> @llvm.experimental.constrained.ldexp.v2f16.v2i32(<2 x half> %a, <2 x i32> %b, metadata !"round.dynamic", metadata !"fpexcept.strict")
  ret <2 x half> %result
}

define <3 x half> @test_ldexp_v3f16_v3i32(ptr addrspace(1) %out, <3 x half> %a, <3 x i32> %b) #0 {
; GFX8-SDAG-LABEL: test_ldexp_v3f16_v3i32:
; GFX8-SDAG:       ; %bb.0:
; GFX8-SDAG-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-SDAG-NEXT:    s_movk_i32 s4, 0x8000
; GFX8-SDAG-NEXT:    v_mov_b32_e32 v1, 0x7fff
; GFX8-SDAG-NEXT:    v_med3_i32 v0, v4, s4, v1
; GFX8-SDAG-NEXT:    v_med3_i32 v4, v5, s4, v1
; GFX8-SDAG-NEXT:    v_ldexp_f16_e32 v0, v2, v0
; GFX8-SDAG-NEXT:    v_ldexp_f16_sdwa v2, v2, v4 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
; GFX8-SDAG-NEXT:    v_med3_i32 v1, v6, s4, v1
; GFX8-SDAG-NEXT:    v_or_b32_e32 v0, v0, v2
; GFX8-SDAG-NEXT:    v_ldexp_f16_e32 v1, v3, v1
; GFX8-SDAG-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-SDAG-LABEL: test_ldexp_v3f16_v3i32:
; GFX9-SDAG:       ; %bb.0:
; GFX9-SDAG-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-SDAG-NEXT:    s_movk_i32 s4, 0x8000
; GFX9-SDAG-NEXT:    v_mov_b32_e32 v1, 0x7fff
; GFX9-SDAG-NEXT:    v_med3_i32 v0, v4, s4, v1
; GFX9-SDAG-NEXT:    v_med3_i32 v4, v5, s4, v1
; GFX9-SDAG-NEXT:    v_ldexp_f16_e32 v0, v2, v0
; GFX9-SDAG-NEXT:    v_ldexp_f16_sdwa v2, v2, v4 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
; GFX9-SDAG-NEXT:    s_mov_b32 s5, 0x5040100
; GFX9-SDAG-NEXT:    v_med3_i32 v1, v6, s4, v1
; GFX9-SDAG-NEXT:    v_perm_b32 v0, v2, v0, s5
; GFX9-SDAG-NEXT:    v_ldexp_f16_e32 v1, v3, v1
; GFX9-SDAG-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-SDAG-TRUE16-LABEL: test_ldexp_v3f16_v3i32:
; GFX11-SDAG-TRUE16:       ; %bb.0:
; GFX11-SDAG-TRUE16-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-SDAG-TRUE16-NEXT:    s_movk_i32 s0, 0x8000
; GFX11-SDAG-TRUE16-NEXT:    s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)
; GFX11-SDAG-TRUE16-NEXT:    v_med3_i32 v0, v4, s0, 0x7fff
; GFX11-SDAG-TRUE16-NEXT:    v_med3_i32 v1, v5, s0, 0x7fff
; GFX11-SDAG-TRUE16-NEXT:    v_med3_i32 v4, v6, s0, 0x7fff
; GFX11-SDAG-TRUE16-NEXT:    v_ldexp_f16_e32 v0.l, v2.l, v0.l
; GFX11-SDAG-TRUE16-NEXT:    s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)
; GFX11-SDAG-TRUE16-NEXT:    v_ldexp_f16_e32 v0.h, v2.h, v1.l
; GFX11-SDAG-TRUE16-NEXT:    v_ldexp_f16_e32 v1.l, v3.l, v4.l
; GFX11-SDAG-TRUE16-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-SDAG-FAKE16-LABEL: test_ldexp_v3f16_v3i32:
; GFX11-SDAG-FAKE16:       ; %bb.0:
; GFX11-SDAG-FAKE16-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-SDAG-FAKE16-NEXT:    s_movk_i32 s0, 0x8000
; GFX11-SDAG-FAKE16-NEXT:    s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)
; GFX11-SDAG-FAKE16-NEXT:    v_med3_i32 v0, v4, s0, 0x7fff
; GFX11-SDAG-FAKE16-NEXT:    v_med3_i32 v1, v5, s0, 0x7fff
; GFX11-SDAG-FAKE16-NEXT:    v_lshrrev_b32_e32 v4, 16, v2
; GFX11-SDAG-FAKE16-NEXT:    v_ldexp_f16_e32 v0, v2, v0
; GFX11-SDAG-FAKE16-NEXT:    v_med3_i32 v2, v6, s0, 0x7fff
; GFX11-SDAG-FAKE16-NEXT:    s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_1)
; GFX11-SDAG-FAKE16-NEXT:    v_ldexp_f16_e32 v1, v4, v1
; GFX11-SDAG-FAKE16-NEXT:    v_perm_b32 v0, v1, v0, 0x5040100
; GFX11-SDAG-FAKE16-NEXT:    s_delay_alu instid0(VALU_DEP_3)
; GFX11-SDAG-FAKE16-NEXT:    v_ldexp_f16_e32 v1, v3, v2
; GFX11-SDAG-FAKE16-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-GISEL-LABEL: test_ldexp_v3f16_v3i32:
; GFX8-GISEL:       ; %bb.0:
; GFX8-GISEL-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-GISEL-NEXT:    v_mov_b32_e32 v0, 0xffff8000
; GFX8-GISEL-NEXT:    v_mov_b32_e32 v1, 0x7fff
; GFX8-GISEL-NEXT:    v_med3_i32 v4, v4, v0, v1
; GFX8-GISEL-NEXT:    v_med3_i32 v5, v5, v0, v1
; GFX8-GISEL-NEXT:    v_ldexp_f16_e32 v4, v2, v4
; GFX8-GISEL-NEXT:    v_ldexp_f16_sdwa v2, v2, v5 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
; GFX8-GISEL-NEXT:    v_med3_i32 v0, v6, v0, v1
; GFX8-GISEL-NEXT:    v_ldexp_f16_e32 v1, v3, v0
; GFX8-GISEL-NEXT:    v_or_b32_e32 v0, v4, v2
; GFX8-GISEL-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-GISEL-LABEL: test_ldexp_v3f16_v3i32:
; GFX9-GISEL:       ; %bb.0:
; GFX9-GISEL-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-GISEL-NEXT:    v_mov_b32_e32 v0, 0xffff8000
; GFX9-GISEL-NEXT:    v_mov_b32_e32 v1, 0x7fff
; GFX9-GISEL-NEXT:    v_med3_i32 v4, v4, v0, v1
; GFX9-GISEL-NEXT:    v_med3_i32 v5, v5, v0, v1
; GFX9-GISEL-NEXT:    v_ldexp_f16_e32 v4, v2, v4
; GFX9-GISEL-NEXT:    v_ldexp_f16_sdwa v2, v2, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
; GFX9-GISEL-NEXT:    v_med3_i32 v0, v6, v0, v1
; GFX9-GISEL-NEXT:    v_ldexp_f16_e32 v1, v3, v0
; GFX9-GISEL-NEXT:    v_lshl_or_b32 v0, v2, 16, v4
; GFX9-GISEL-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-GISEL-TRUE16-LABEL: test_ldexp_v3f16_v3i32:
; GFX11-GISEL-TRUE16:       ; %bb.0:
; GFX11-GISEL-TRUE16-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-GISEL-TRUE16-NEXT:    v_mov_b32_e32 v0, 0x7fff
; GFX11-GISEL-TRUE16-NEXT:    s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)
; GFX11-GISEL-TRUE16-NEXT:    v_med3_i32 v1, 0xffff8000, v6, v0
; GFX11-GISEL-TRUE16-NEXT:    v_med3_i32 v4, 0xffff8000, v4, v0
; GFX11-GISEL-TRUE16-NEXT:    v_med3_i32 v5, 0xffff8000, v5, v0
; GFX11-GISEL-TRUE16-NEXT:    v_ldexp_f16_e32 v1.l, v3.l, v1.l
; GFX11-GISEL-TRUE16-NEXT:    s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)
; GFX11-GISEL-TRUE16-NEXT:    v_ldexp_f16_e32 v0.l, v2.l, v4.l
; GFX11-GISEL-TRUE16-NEXT:    v_ldexp_f16_e32 v0.h, v2.h, v5.l
; GFX11-GISEL-TRUE16-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-GISEL-FAKE16-LABEL: test_ldexp_v3f16_v3i32:
; GFX11-GISEL-FAKE16:       ; %bb.0:
; GFX11-GISEL-FAKE16-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-GISEL-FAKE16-NEXT:    v_mov_b32_e32 v0, 0x7fff
; GFX11-GISEL-FAKE16-NEXT:    s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)
; GFX11-GISEL-FAKE16-NEXT:    v_med3_i32 v1, 0xffff8000, v4, v0
; GFX11-GISEL-FAKE16-NEXT:    v_lshrrev_b32_e32 v4, 16, v2
; GFX11-GISEL-FAKE16-NEXT:    v_med3_i32 v5, 0xffff8000, v5, v0
; GFX11-GISEL-FAKE16-NEXT:    v_ldexp_f16_e32 v1, v2, v1
; GFX11-GISEL-FAKE16-NEXT:    s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_3)
; GFX11-GISEL-FAKE16-NEXT:    v_ldexp_f16_e32 v2, v4, v5
; GFX11-GISEL-FAKE16-NEXT:    v_med3_i32 v4, 0xffff8000, v6, v0
; GFX11-GISEL-FAKE16-NEXT:    v_and_b32_e32 v1, 0xffff, v1
; GFX11-GISEL-FAKE16-NEXT:    s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_3)
; GFX11-GISEL-FAKE16-NEXT:    v_lshl_or_b32 v0, v2, 16, v1
; GFX11-GISEL-FAKE16-NEXT:    v_ldexp_f16_e32 v1, v3, v4
; GFX11-GISEL-FAKE16-NEXT:    s_setpc_b64 s[30:31]
  %result = call <3 x half> @llvm.experimental.constrained.ldexp.v3f16.v3i32(<3 x half> %a, <3 x i32> %b, metadata !"round.dynamic", metadata !"fpexcept.strict")
  ret <3 x half> %result
}

define <4 x half> @test_ldexp_v4f16_v4i32(ptr addrspace(1) %out, <4 x half> %a, <4 x i32> %b) #0 {
; GFX8-SDAG-LABEL: test_ldexp_v4f16_v4i32:
; GFX8-SDAG:       ; %bb.0:
; GFX8-SDAG-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-SDAG-NEXT:    s_movk_i32 s4, 0x8000
; GFX8-SDAG-NEXT:    v_mov_b32_e32 v0, 0x7fff
; GFX8-SDAG-NEXT:    v_med3_i32 v1, v7, s4, v0
; GFX8-SDAG-NEXT:    v_med3_i32 v6, v6, s4, v0
; GFX8-SDAG-NEXT:    v_med3_i32 v5, v5, s4, v0
; GFX8-SDAG-NEXT:    v_med3_i32 v0, v4, s4, v0
; GFX8-SDAG-NEXT:    v_ldexp_f16_sdwa v1, v3, v1 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
; GFX8-SDAG-NEXT:    v_ldexp_f16_e32 v3, v3, v6
; GFX8-SDAG-NEXT:    v_ldexp_f16_sdwa v5, v2, v5 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
; GFX8-SDAG-NEXT:    v_ldexp_f16_e32 v0, v2, v0
; GFX8-SDAG-NEXT:    v_or_b32_e32 v0, v0, v5
; GFX8-SDAG-NEXT:    v_or_b32_e32 v1, v3, v1
; GFX8-SDAG-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-SDAG-LABEL: test_ldexp_v4f16_v4i32:
; GFX9-SDAG:       ; %bb.0:
; GFX9-SDAG-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-SDAG-NEXT:    s_movk_i32 s4, 0x8000
; GFX9-SDAG-NEXT:    v_mov_b32_e32 v0, 0x7fff
; GFX9-SDAG-NEXT:    v_med3_i32 v1, v6, s4, v0
; GFX9-SDAG-NEXT:    v_med3_i32 v6, v7, s4, v0
; GFX9-SDAG-NEXT:    v_med3_i32 v4, v4, s4, v0
; GFX9-SDAG-NEXT:    v_med3_i32 v0, v5, s4, v0
; GFX9-SDAG-NEXT:    v_ldexp_f16_e32 v1, v3, v1
; GFX9-SDAG-NEXT:    v_ldexp_f16_sdwa v3, v3, v6 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
; GFX9-SDAG-NEXT:    v_ldexp_f16_e32 v4, v2, v4
; GFX9-SDAG-NEXT:    v_ldexp_f16_sdwa v0, v2, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
; GFX9-SDAG-NEXT:    s_mov_b32 s4, 0x5040100
; GFX9-SDAG-NEXT:    v_perm_b32 v0, v0, v4, s4
; GFX9-SDAG-NEXT:    v_perm_b32 v1, v3, v1, s4
; GFX9-SDAG-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-SDAG-TRUE16-LABEL: test_ldexp_v4f16_v4i32:
; GFX11-SDAG-TRUE16:       ; %bb.0:
; GFX11-SDAG-TRUE16-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-SDAG-TRUE16-NEXT:    s_movk_i32 s0, 0x8000
; GFX11-SDAG-TRUE16-NEXT:    s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_3) | instid1(VALU_DEP_4)
; GFX11-SDAG-TRUE16-NEXT:    v_med3_i32 v0, v6, s0, 0x7fff
; GFX11-SDAG-TRUE16-NEXT:    v_med3_i32 v4, v4, s0, 0x7fff
; GFX11-SDAG-TRUE16-NEXT:    v_med3_i32 v5, v5, s0, 0x7fff
; GFX11-SDAG-TRUE16-NEXT:    v_med3_i32 v6, v7, s0, 0x7fff
; GFX11-SDAG-TRUE16-NEXT:    v_ldexp_f16_e32 v1.l, v3.l, v0.l
; GFX11-SDAG-TRUE16-NEXT:    s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)
; GFX11-SDAG-TRUE16-NEXT:    v_ldexp_f16_e32 v0.l, v2.l, v4.l
; GFX11-SDAG-TRUE16-NEXT:    v_ldexp_f16_e32 v0.h, v2.h, v5.l
; GFX11-SDAG-TRUE16-NEXT:    s_delay_alu instid0(VALU_DEP_4)
; GFX11-SDAG-TRUE16-NEXT:    v_ldexp_f16_e32 v1.h, v3.h, v6.l
; GFX11-SDAG-TRUE16-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-SDAG-FAKE16-LABEL: test_ldexp_v4f16_v4i32:
; GFX11-SDAG-FAKE16:       ; %bb.0:
; GFX11-SDAG-FAKE16-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-SDAG-FAKE16-NEXT:    s_movk_i32 s0, 0x8000
; GFX11-SDAG-FAKE16-NEXT:    s_delay_alu instid0(SALU_CYCLE_1)
; GFX11-SDAG-FAKE16-NEXT:    v_med3_i32 v0, v6, s0, 0x7fff
; GFX11-SDAG-FAKE16-NEXT:    v_med3_i32 v1, v7, s0, 0x7fff
; GFX11-SDAG-FAKE16-NEXT:    v_med3_i32 v4, v4, s0, 0x7fff
; GFX11-SDAG-FAKE16-NEXT:    v_med3_i32 v5, v5, s0, 0x7fff
; GFX11-SDAG-FAKE16-NEXT:    v_lshrrev_b32_e32 v6, 16, v2
; GFX11-SDAG-FAKE16-NEXT:    v_lshrrev_b32_e32 v7, 16, v3
; GFX11-SDAG-FAKE16-NEXT:    v_ldexp_f16_e32 v3, v3, v0
; GFX11-SDAG-FAKE16-NEXT:    v_ldexp_f16_e32 v0, v2, v4
; GFX11-SDAG-FAKE16-NEXT:    s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)
; GFX11-SDAG-FAKE16-NEXT:    v_ldexp_f16_e32 v2, v6, v5
; GFX11-SDAG-FAKE16-NEXT:    v_ldexp_f16_e32 v1, v7, v1
; GFX11-SDAG-FAKE16-NEXT:    s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)
; GFX11-SDAG-FAKE16-NEXT:    v_perm_b32 v0, v2, v0, 0x5040100
; GFX11-SDAG-FAKE16-NEXT:    v_perm_b32 v1, v1, v3, 0x5040100
; GFX11-SDAG-FAKE16-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-GISEL-LABEL: test_ldexp_v4f16_v4i32:
; GFX8-GISEL:       ; %bb.0:
; GFX8-GISEL-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-GISEL-NEXT:    v_mov_b32_e32 v0, 0xffff8000
; GFX8-GISEL-NEXT:    v_mov_b32_e32 v1, 0x7fff
; GFX8-GISEL-NEXT:    v_med3_i32 v4, v4, v0, v1
; GFX8-GISEL-NEXT:    v_med3_i32 v5, v5, v0, v1
; GFX8-GISEL-NEXT:    v_ldexp_f16_e32 v4, v2, v4
; GFX8-GISEL-NEXT:    v_ldexp_f16_sdwa v2, v2, v5 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
; GFX8-GISEL-NEXT:    v_med3_i32 v5, v6, v0, v1
; GFX8-GISEL-NEXT:    v_med3_i32 v0, v7, v0, v1
; GFX8-GISEL-NEXT:    v_ldexp_f16_e32 v5, v3, v5
; GFX8-GISEL-NEXT:    v_ldexp_f16_sdwa v1, v3, v0 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
; GFX8-GISEL-NEXT:    v_or_b32_e32 v0, v4, v2
; GFX8-GISEL-NEXT:    v_or_b32_e32 v1, v5, v1
; GFX8-GISEL-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-GISEL-LABEL: test_ldexp_v4f16_v4i32:
; GFX9-GISEL:       ; %bb.0:
; GFX9-GISEL-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-GISEL-NEXT:    v_mov_b32_e32 v0, 0xffff8000
; GFX9-GISEL-NEXT:    v_mov_b32_e32 v1, 0x7fff
; GFX9-GISEL-NEXT:    v_med3_i32 v4, v4, v0, v1
; GFX9-GISEL-NEXT:    v_med3_i32 v5, v5, v0, v1
; GFX9-GISEL-NEXT:    v_ldexp_f16_e32 v4, v2, v4
; GFX9-GISEL-NEXT:    v_ldexp_f16_sdwa v2, v2, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
; GFX9-GISEL-NEXT:    v_med3_i32 v5, v6, v0, v1
; GFX9-GISEL-NEXT:    v_med3_i32 v0, v7, v0, v1
; GFX9-GISEL-NEXT:    v_ldexp_f16_e32 v5, v3, v5
; GFX9-GISEL-NEXT:    v_ldexp_f16_sdwa v1, v3, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
; GFX9-GISEL-NEXT:    v_lshl_or_b32 v0, v2, 16, v4
; GFX9-GISEL-NEXT:    v_lshl_or_b32 v1, v1, 16, v5
; GFX9-GISEL-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-GISEL-TRUE16-LABEL: test_ldexp_v4f16_v4i32:
; GFX11-GISEL-TRUE16:       ; %bb.0:
; GFX11-GISEL-TRUE16-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-GISEL-TRUE16-NEXT:    v_mov_b32_e32 v0, 0x7fff
; GFX11-GISEL-TRUE16-NEXT:    s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_3) | instid1(VALU_DEP_4)
; GFX11-GISEL-TRUE16-NEXT:    v_med3_i32 v1, 0xffff8000, v4, v0
; GFX11-GISEL-TRUE16-NEXT:    v_med3_i32 v4, 0xffff8000, v5, v0
; GFX11-GISEL-TRUE16-NEXT:    v_med3_i32 v5, 0xffff8000, v6, v0
; GFX11-GISEL-TRUE16-NEXT:    v_med3_i32 v6, 0xffff8000, v7, v0
; GFX11-GISEL-TRUE16-NEXT:    v_ldexp_f16_e32 v0.l, v2.l, v1.l
; GFX11-GISEL-TRUE16-NEXT:    s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)
; GFX11-GISEL-TRUE16-NEXT:    v_ldexp_f16_e32 v0.h, v2.h, v4.l
; GFX11-GISEL-TRUE16-NEXT:    v_ldexp_f16_e32 v1.l, v3.l, v5.l
; GFX11-GISEL-TRUE16-NEXT:    s_delay_alu instid0(VALU_DEP_4)
; GFX11-GISEL-TRUE16-NEXT:    v_ldexp_f16_e32 v1.h, v3.h, v6.l
; GFX11-GISEL-TRUE16-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-GISEL-FAKE16-LABEL: test_ldexp_v4f16_v4i32:
; GFX11-GISEL-FAKE16:       ; %bb.0:
; GFX11-GISEL-FAKE16-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-GISEL-FAKE16-NEXT:    v_mov_b32_e32 v0, 0x7fff
; GFX11-GISEL-FAKE16-NEXT:    v_lshrrev_b32_e32 v1, 16, v2
; GFX11-GISEL-FAKE16-NEXT:    v_lshrrev_b32_e32 v8, 16, v3
; GFX11-GISEL-FAKE16-NEXT:    s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_3) | instid1(VALU_DEP_4)
; GFX11-GISEL-FAKE16-NEXT:    v_med3_i32 v4, 0xffff8000, v4, v0
; GFX11-GISEL-FAKE16-NEXT:    v_med3_i32 v6, 0xffff8000, v6, v0
; GFX11-GISEL-FAKE16-NEXT:    v_med3_i32 v5, 0xffff8000, v5, v0
; GFX11-GISEL-FAKE16-NEXT:    v_med3_i32 v0, 0xffff8000, v7, v0
; GFX11-GISEL-FAKE16-NEXT:    v_ldexp_f16_e32 v2, v2, v4
; GFX11-GISEL-FAKE16-NEXT:    s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)
; GFX11-GISEL-FAKE16-NEXT:    v_ldexp_f16_e32 v3, v3, v6
; GFX11-GISEL-FAKE16-NEXT:    v_ldexp_f16_e32 v1, v1, v5
; GFX11-GISEL-FAKE16-NEXT:    s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_4)
; GFX11-GISEL-FAKE16-NEXT:    v_ldexp_f16_e32 v4, v8, v0
; GFX11-GISEL-FAKE16-NEXT:    v_and_b32_e32 v0, 0xffff, v2
; GFX11-GISEL-FAKE16-NEXT:    s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_2)
; GFX11-GISEL-FAKE16-NEXT:    v_and_b32_e32 v2, 0xffff, v3
; GFX11-GISEL-FAKE16-NEXT:    v_lshl_or_b32 v0, v1, 16, v0
; GFX11-GISEL-FAKE16-NEXT:    s_delay_alu instid0(VALU_DEP_2)
; GFX11-GISEL-FAKE16-NEXT:    v_lshl_or_b32 v1, v4, 16, v2
; GFX11-GISEL-FAKE16-NEXT:    s_setpc_b64 s[30:31]
  %result = call <4 x half> @llvm.experimental.constrained.ldexp.v4f16.v4i32(<4 x half> %a, <4 x i32> %b, metadata !"round.dynamic", metadata !"fpexcept.strict")
  ret <4 x half> %result
}

declare half @llvm.experimental.constrained.ldexp.f16.i16(half, i16, metadata, metadata) #1
declare half @llvm.experimental.constrained.ldexp.f16.i32(half, i32, metadata, metadata) #1
declare <2 x half> @llvm.experimental.constrained.ldexp.v2f16.v2i16(<2 x half>, <2 x i16>, metadata, metadata) #1
declare <2 x half> @llvm.experimental.constrained.ldexp.v2f16.v2i32(<2 x half>, <2 x i32>, metadata, metadata) #1
declare <3 x half> @llvm.experimental.constrained.ldexp.v3f16.v3i32(<3 x half>, <3 x i32>, metadata, metadata) #1
declare <4 x half> @llvm.experimental.constrained.ldexp.v4f16.v4i32(<4 x half>, <4 x i32>, metadata, metadata) #1

attributes #0 = { strictfp }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite) }
;; NOTE: These prefixes are unused and the list is autogenerated. Do not add tests below this line:
; GCN: {{.*}}
; GFX11: {{.*}}
; GFX11-GISEL: {{.*}}
; GFX11-SDAG: {{.*}}
; GFX8: {{.*}}
; GFX9: {{.*}}
