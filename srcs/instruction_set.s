BITS 64

%include "disassembler.s"

section .data:
    global instruction_set0x00
    global instruction_set0x01
    global instruction_set0x02
    global instruction_set0x03
    global instruction_set0x04
    global instruction_set0x05
    global instruction_set0x06
    global instruction_set0x07
    global instruction_set0x08
    global instruction_set0x09
    global instruction_set0x0a
    global instruction_set0x0b
    global instruction_set0x0c
    global instruction_set0x0d
    global instruction_set0x0e
    global instruction_set0x0f
    global instruction_set0x10
    global instruction_set0x11
    global instruction_set0x12
    global instruction_set0x13
    global instruction_set0x14
    global instruction_set0x15
    global instruction_set0x16
    global instruction_set0x17
    global instruction_set0x18
    global instruction_set0x19
    global instruction_set0x1a
    global instruction_set0x1b
    global instruction_set0x1c
    global instruction_set0x1d
    global instruction_set0x1e
    global instruction_set0x1f
    global instruction_set0x20
    global instruction_set0x21
    global instruction_set0x22
    global instruction_set0x23
    global instruction_set0x24
    global instruction_set0x25
    global instruction_set0x26
    global instruction_set0x27
    global instruction_set0x28
    global instruction_set0x29
    global instruction_set0x2a
    global instruction_set0x2b
    global instruction_set0x2c
    global instruction_set0x2d
    global instruction_set0x2e
    global instruction_set0x2f
    global instruction_set0x30
    global instruction_set0x31
    global instruction_set0x32
    global instruction_set0x33
    global instruction_set0x34
    global instruction_set0x35
    global instruction_set0x36
    global instruction_set0x37
    global instruction_set0x38
    global instruction_set0x39
    global instruction_set0x3a
    global instruction_set0x3b
    global instruction_set0x3c
    global instruction_set0x3d
    global instruction_set0x3e
    global instruction_set0x3f
    global instruction_set0x40
    global instruction_set0x41
    global instruction_set0x42
    global instruction_set0x43
    global instruction_set0x44
    global instruction_set0x45
    global instruction_set0x46
    global instruction_set0x47
    global instruction_set0x48
    global instruction_set0x49
    global instruction_set0x4a
    global instruction_set0x4b
    global instruction_set0x4c
    global instruction_set0x4d
    global instruction_set0x4e
    global instruction_set0x4f
    global instruction_set0x50
    global instruction_set0x51
    global instruction_set0x52
    global instruction_set0x53
    global instruction_set0x54
    global instruction_set0x55
    global instruction_set0x56
    global instruction_set0x57
    global instruction_set0x58
    global instruction_set0x59
    global instruction_set0x5a
    global instruction_set0x5b
    global instruction_set0x5c
    global instruction_set0x5d
    global instruction_set0x5e
    global instruction_set0x5f
    global instruction_set0x60
    global instruction_set0x61
    global instruction_set0x62
    global instruction_set0x63
    global instruction_set0x64
    global instruction_set0x65
    global instruction_set0x66
    global instruction_set0x67
    global instruction_set0x68
    global instruction_set0x69
    global instruction_set0x6a
    global instruction_set0x6b
    global instruction_set0x6c
    global instruction_set0x6d
    global instruction_set0x6e
    global instruction_set0x6f
    global instruction_set0x70
    global instruction_set0x71
    global instruction_set0x72
    global instruction_set0x73
    global instruction_set0x74
    global instruction_set0x75
    global instruction_set0x76
    global instruction_set0x77
    global instruction_set0x78
    global instruction_set0x79
    global instruction_set0x7a
    global instruction_set0x7b
    global instruction_set0x7c
    global instruction_set0x7d
    global instruction_set0x7e
    global instruction_set0x7f
    global instruction_set0x80
    global instruction_set0x81
    global instruction_set0x82
    global instruction_set0x83
    global instruction_set0x84
    global instruction_set0x85
    global instruction_set0x86
    global instruction_set0x87
    global instruction_set0x88
    global instruction_set0x89
    global instruction_set0x8a
    global instruction_set0x8b
    global instruction_set0x8c
    global instruction_set0x8d
    global instruction_set0x8e
    global instruction_set0x8f
    global instruction_set0x90
    global instruction_set0x91
    global instruction_set0x92
    global instruction_set0x93
    global instruction_set0x94
    global instruction_set0x95
    global instruction_set0x96
    global instruction_set0x97
    global instruction_set0x98
    global instruction_set0x99
    global instruction_set0x9a
    global instruction_set0x9b
    global instruction_set0x9c
    global instruction_set0x9d
    global instruction_set0x9e
    global instruction_set0x9f
    global instruction_set0xa0
    global instruction_set0xa1
    global instruction_set0xa2
    global instruction_set0xa3
    global instruction_set0xa4
    global instruction_set0xa5
    global instruction_set0xa6
    global instruction_set0xa7
    global instruction_set0xa8
    global instruction_set0xa9
    global instruction_set0xaa
    global instruction_set0xab
    global instruction_set0xac
    global instruction_set0xad
    global instruction_set0xae
    global instruction_set0xaf
    global instruction_set0xb0
    global instruction_set0xb1
    global instruction_set0xb2
    global instruction_set0xb3
    global instruction_set0xb4
    global instruction_set0xb5
    global instruction_set0xb6
    global instruction_set0xb7
    global instruction_set0xb8
    global instruction_set0xb9
    global instruction_set0xba
    global instruction_set0xbb
    global instruction_set0xbc
    global instruction_set0xbd
    global instruction_set0xbe
    global instruction_set0xbf
    global instruction_set0xc0
    global instruction_set0xc1
    global instruction_set0xc2
    global instruction_set0xc3
    global instruction_set0xc4
    global instruction_set0xc5
    global instruction_set0xc6
    global instruction_set0xc7
    global instruction_set0xc8
    global instruction_set0xc9
    global instruction_set0xca
    global instruction_set0xcb
    global instruction_set0xcc
    global instruction_set0xcd
    global instruction_set0xce
    global instruction_set0xcf
    global instruction_set0xd0
    global instruction_set0xd1
    global instruction_set0xd2
    global instruction_set0xd3
    global instruction_set0xd4
    global instruction_set0xd5
    global instruction_set0xd6
    global instruction_set0xd7
    global instruction_set0xd8
    global instruction_set0xd9
    global instruction_set0xda
    global instruction_set0xdb
    global instruction_set0xdc
    global instruction_set0xdd
    global instruction_set0xde
    global instruction_set0xdf
    global instruction_set0xe0
    global instruction_set0xe1
    global instruction_set0xe2
    global instruction_set0xe3
    global instruction_set0xe4
    global instruction_set0xe5
    global instruction_set0xe6
    global instruction_set0xe7
    global instruction_set0xe8
    global instruction_set0xe9
    global instruction_set0xea
    global instruction_set0xeb
    global instruction_set0xec
    global instruction_set0xed
    global instruction_set0xee
    global instruction_set0xef
    global instruction_set0xf0
    global instruction_set0xf1
    global instruction_set0xf2
    global instruction_set0xf3
    global instruction_set0xf4
    global instruction_set0xf5
    global instruction_set0xf6
    global instruction_set0xf7
    global instruction_set0xf8
    global instruction_set0xf9
    global instruction_set0xfa
    global instruction_set0xfb
    global instruction_set0xfc
    global instruction_set0xfd
    global instruction_set0xfe
    global instruction_set0xff
    global ModRM_tab


instruction_set0x00: db NOP, 0
instruction_set0x01: db NOP, 0
instruction_set0x02: db NOP, 0
instruction_set0x03: db NOP, 0
instruction_set0x04: db NOP, 0
instruction_set0x05: db NOP, 0
instruction_set0x06: db NOP, 0
instruction_set0x07: db NOP, 0
instruction_set0x08: db NOP, 0
instruction_set0x09: db NOP, 0
instruction_set0x0a: db NOP, 0
instruction_set0x0b: db NOP, 0
instruction_set0x0c: db NOP, 0
instruction_set0x0d: db NOP, 0
instruction_set0x0e: db NOP, 0
instruction_set0x0f: db SYSCALL, NO
instruction_set0x10: db NOP, 0
instruction_set0x11: db NOP, 0
instruction_set0x12: db NOP, 0
instruction_set0x13: db NOP, 0
instruction_set0x14: db NOP, 0
instruction_set0x15: db NOP, 0
instruction_set0x16: db NOP, 0
instruction_set0x17: db NOP, 0
instruction_set0x18: db NOP, 0
instruction_set0x19: db NOP, 0
instruction_set0x1a: db NOP, 0
instruction_set0x1b: db NOP, 0
instruction_set0x1c: db NOP, 0
instruction_set0x1d: db NOP, 0
instruction_set0x1e: db NOP, 0
instruction_set0x1f: db NOP, 0
instruction_set0x20: db NOP, 0
instruction_set0x21: db NOP, 0
instruction_set0x22: db NOP, 0
instruction_set0x23: db NOP, 0
instruction_set0x24: db NOP, 0
instruction_set0x25: db NOP, 0
instruction_set0x26: db NOP, 0
instruction_set0x27: db NOP, 0
instruction_set0x28: db NOP, 0
instruction_set0x29: db NOP, 0
instruction_set0x2a: db NOP, 0
instruction_set0x2b: db NOP, 0
instruction_set0x2c: db NOP, 0
instruction_set0x2d: db NOP, 0
instruction_set0x2e: db NOP, 0
instruction_set0x2f: db NOP, 0
instruction_set0x30: db NOP, 0
instruction_set0x31: db NOP, 0
instruction_set0x32: db NOP, 0
instruction_set0x33: db NOP, 0
instruction_set0x34: db NOP, 0
instruction_set0x35: db NOP, 0
instruction_set0x36: db NOP, 0
instruction_set0x37: db NOP, 0
instruction_set0x38: db NOP, 0
instruction_set0x39: db NOP, 0
instruction_set0x3a: db NOP, 0
instruction_set0x3b: db NOP, 0
instruction_set0x3c: db NOP, 0
instruction_set0x3d: db NOP, 0
instruction_set0x3e: db NOP, 0
instruction_set0x3f: db NOP, 0
instruction_set0x40: db NOP, 0
instruction_set0x41: db NOP, 0
instruction_set0x42: db NOP, 0
instruction_set0x43: db NOP, 0
instruction_set0x44: db NOP, 0
instruction_set0x45: db NOP, 0
instruction_set0x46: db NOP, 0
instruction_set0x47: db NOP, 0
instruction_set0x48: db NOP, 0
instruction_set0x49: db NOP, 0
instruction_set0x4a: db NOP, 0
instruction_set0x4b: db NOP, 0
instruction_set0x4c: db NOP, 0
instruction_set0x4d: db NOP, 0
instruction_set0x4e: db NOP, 0
instruction_set0x4f: db NOP, 0
instruction_set0x50: db NOP, 0
instruction_set0x51: db NOP, 0
instruction_set0x52: db NOP, 0
instruction_set0x53: db NOP, 0
instruction_set0x54: db NOP, 0
instruction_set0x55: db NOP, 0
instruction_set0x56: db NOP, 0
instruction_set0x57: db NOP, 0
instruction_set0x58: db NOP, 0
instruction_set0x59: db NOP, 0
instruction_set0x5a: db NOP, 0
instruction_set0x5b: db NOP, 0
instruction_set0x5c: db NOP, 0
instruction_set0x5d: db NOP, 0
instruction_set0x5e: db NOP, 0
instruction_set0x5f: db NOP, 0
instruction_set0x60: db NOP, 0
instruction_set0x61: db NOP, 0
instruction_set0x62: db NOP, 0
instruction_set0x63: db NOP, 0
instruction_set0x64: db NOP, 0
instruction_set0x65: db NOP, 0
instruction_set0x66: db NOP, 0
instruction_set0x67: db NOP, 0
instruction_set0x68: db NOP, 0
instruction_set0x69: db NOP, 0
instruction_set0x6a: db NOP, 0
instruction_set0x6b: db NOP, 0
instruction_set0x6c: db NOP, 0
instruction_set0x6d: db NOP, 0
instruction_set0x6e: db NOP, 0
instruction_set0x6f: db NOP, 0
instruction_set0x70: db NOP, 0
instruction_set0x71: db NOP, 0
instruction_set0x72: db NOP, 0
instruction_set0x73: db NOP, 0
instruction_set0x74: db NOP, 0
instruction_set0x75: db NOP, 0
instruction_set0x76: db NOP, 0
instruction_set0x77: db NOP, 0
instruction_set0x78: db NOP, 0
instruction_set0x79: db NOP, 0
instruction_set0x7a: db NOP, 0
instruction_set0x7b: db NOP, 0
instruction_set0x7c: db NOP, 0
instruction_set0x7d: db NOP, 0
instruction_set0x7e: db NOP, 0
instruction_set0x7f: db NOP, 0
instruction_set0x80: dd NOP, 0
instruction_set0x81: dd NOP, 0
instruction_set0x82: dd NOP, 0
instruction_set0x83: dd NOP, 0
instruction_set0x84: dd NOP, 0
instruction_set0x85: dd NOP, 0
instruction_set0x86: dd NOP, 0
instruction_set0x87: dd NOP, 0
instruction_set0x88: dd NOP, 0
instruction_set0x89: dd MOV, MR
instruction_set0x8a: dd NOP, 0
instruction_set0x8b: dd MOV, RM
instruction_set0x8c: dd NOP, 0
instruction_set0x8d: dd LEA, RM
instruction_set0x8e: dd NOP, 0
instruction_set0x8f: dd NOP, 0
instruction_set0x90: db NOP, 0
instruction_set0x91: db NOP, 0
instruction_set0x92: db NOP, 0
instruction_set0x93: db NOP, 0
instruction_set0x94: db NOP, 0
instruction_set0x95: db NOP, 0
instruction_set0x96: db NOP, 0
instruction_set0x97: db NOP, 0
instruction_set0x98: db NOP, 0
instruction_set0x99: db NOP, 0
instruction_set0x9a: db NOP, 0
instruction_set0x9b: db NOP, 0
instruction_set0x9c: db NOP, 0
instruction_set0x9d: db NOP, 0
instruction_set0x9e: db NOP, 0
instruction_set0x9f: db NOP, 0
instruction_set0xa0: db NOP, 0
instruction_set0xa1: db NOP, 0
instruction_set0xa2: db NOP, 0
instruction_set0xa3: db NOP, 0
instruction_set0xa4: db NOP, 0
instruction_set0xa5: db NOP, 0
instruction_set0xa6: db NOP, 0
instruction_set0xa7: db NOP, 0
instruction_set0xa8: db NOP, 0
instruction_set0xa9: db NOP, 0
instruction_set0xaa: db NOP, 0
instruction_set0xab: db NOP, 0
instruction_set0xac: db NOP, 0
instruction_set0xad: db NOP, 0
instruction_set0xae: db NOP, 0
instruction_set0xaf: db NOP, 0
instruction_set0xb0: db MOV, OI
instruction_set0xb1: db MOV, OI
instruction_set0xb2: db MOV, OI
instruction_set0xb3: db MOV, OI
instruction_set0xb4: db MOV, OI
instruction_set0xb5: db MOV, OI
instruction_set0xb6: db MOV, OI
instruction_set0xb7: db MOV, OI
instruction_set0xb8: db MOV, OI
instruction_set0xb9: db MOV, OI
instruction_set0xba: db MOV, OI
instruction_set0xbb: db MOV, OI
instruction_set0xbc: db MOV, OI
instruction_set0xbd: db MOV, OI
instruction_set0xbe: db MOV, OI
instruction_set0xbf: db MOV, OI
instruction_set0xc0: db NOP, 0
instruction_set0xc1: db NOP, 0
instruction_set0xc2: db NOP, 0
instruction_set0xc3: dd RET, NO
instruction_set0xc4: db NOP, 0
instruction_set0xc5: db NOP, 0
instruction_set0xc6: db NOP, 0
instruction_set0xc7: db NOP, 0
instruction_set0xc8: db NOP, 0
instruction_set0xc9: db NOP, 0
instruction_set0xca: db NOP, 0
instruction_set0xcb: db NOP, 0
instruction_set0xcc: db NOP, 0
instruction_set0xcd: db NOP, 0
instruction_set0xce: db NOP, 0
instruction_set0xcf: db NOP, 0
instruction_set0xd0: db NOP, 0
instruction_set0xd1: db NOP, 0
instruction_set0xd2: db NOP, 0
instruction_set0xd3: db NOP, 0
instruction_set0xd4: db NOP, 0
instruction_set0xd5: db NOP, 0
instruction_set0xd6: db NOP, 0
instruction_set0xd7: db NOP, 0
instruction_set0xd8: db NOP, 0
instruction_set0xd9: db NOP, 0
instruction_set0xda: db NOP, 0
instruction_set0xdb: db NOP, 0
instruction_set0xdc: db NOP, 0
instruction_set0xdd: db NOP, 0
instruction_set0xde: db NOP, 0
instruction_set0xdf: db NOP, 0
instruction_set0xe0: db NOP, 0
instruction_set0xe1: db NOP, 0
instruction_set0xe2: db NOP, 0
instruction_set0xe3: db NOP, 0
instruction_set0xe4: db NOP, 0
instruction_set0xe5: db NOP, 0
instruction_set0xe6: db NOP, 0
instruction_set0xe7: db NOP, 0
instruction_set0xe8: db NOP, 0
instruction_set0xe9: db NOP, 0
instruction_set0xea: db NOP, 0
instruction_set0xeb: db NOP, 0
instruction_set0xec: db NOP, 0
instruction_set0xed: db NOP, 0
instruction_set0xee: db NOP, 0
instruction_set0xef: db NOP, 0
instruction_set0xf0: db NOP, 0
instruction_set0xf1: db NOP, 0
instruction_set0xf2: db NOP, 0
instruction_set0xf3: db NOP, 0
instruction_set0xf4: db NOP, 0
instruction_set0xf5: db NOP, 0
instruction_set0xf6: db NOP, 0
instruction_set0xf7: db NOP, 0
instruction_set0xf8: db NOP, 0
instruction_set0xf9: db NOP, 0
instruction_set0xfa: db NOP, 0
instruction_set0xfb: db NOP, 0
instruction_set0xfc: db NOP, 0
instruction_set0xfd: db NOP, 0
instruction_set0xfe: db NOP, 0
instruction_set0xff: db NOP, 0

;;; Mod/RM Tab

;                   0               1               2               3               4               5               6               7
ModRM_tab: db       MODRM_RM,       MODRM_RM,       MODRM_RM,       MODRM_RM,       MODRM_SIB,      MODRM_REL_32,   MODRM_RM,       MODRM_RM
ModRM_tab_01: db    MODRM_RM_8,     MODRM_RM_8,     MODRM_RM_8,     MODRM_RM_8,     MODRM_SIB_8,    MODRM_RM_8,     MODRM_RM_8,     MODRM_RM_8
ModRM_tab_10: db    MODRM_RM_32,    MODRM_RM_32,    MODRM_RM_32,    MODRM_RM_32,    MODRM_SIB_32,   MODRM_RM_32,    MODRM_RM_32,    MODRM_RM_32
ModRM_tab_11: db    MODRM_RM,       MODRM_RM,       MODRM_RM,       MODRM_RM,       MODRM_RM,       MODRM_RM,       MODRM_RM,       MODRM_RM

; ;;; SIB Tab For Mod == 00b

; ;                   0               1               2               3               4               5               6               7
; SIB_tab_adx: db     SIB_BASE_SI,    SIB_BASE_SI,    SIB_BASE_SI,    SIB_BASE_SI,    SIB_BASE_SI,    SIB_SI_DISP_32, SIB_BASE_SI,    SIB_BASE_SI
; SIB_tab_rsp: db     SIB_BASE,       SIB_BASE,      SIB_BASE,        SIB_BASE,       SIB_BASE,       SIB_DISP_32,    SIB_BASE,       SIB_BASE
