BITS 64

%include "disassembler.s"

section .data:
    global instruction_set0x00
    global ModRM_tab


instruction_set0x00: db ADD, MR, SIZE_8, 0
instruction_set0x01: db ADD, MR, SIZE_32, 0
instruction_set0x02: db ADD, RM, SIZE_8, 0
instruction_set0x03: db ADD, RM, SIZE_32, 0
instruction_set0x04: db ADD, AI, SIZE_8, 0
instruction_set0x05: db ADD, AI, SIZE_32, 0
instruction_set0x06: db NOP, 0, SIZE_32, 0
instruction_set0x07: db NOP, 0, SIZE_32, 0
instruction_set0x08: db OR, MR, SIZE_8, 0
instruction_set0x09: db OR, MR, SIZE_32, 0
instruction_set0x0a: db OR, RM, SIZE_8, 0
instruction_set0x0b: db OR, RM, SIZE_32, 0
instruction_set0x0c: db OR, AI, SIZE_8, 0
instruction_set0x0d: db OR, AI, SIZE_32, 0
instruction_set0x0e: db NOP, 0, SIZE_32, 0
instruction_set0x0f: db DOUBLE, NO, SIZE_32, 0
instruction_set0x10: db NOP, 0, SIZE_32, 0
instruction_set0x11: db NOP, 0, SIZE_32, 0
instruction_set0x12: db NOP, 0, SIZE_32, 0
instruction_set0x13: db NOP, 0, SIZE_32, 0
instruction_set0x14: db NOP, 0, SIZE_32, 0
instruction_set0x15: db NOP, 0, SIZE_32, 0
instruction_set0x16: db NOP, 0, SIZE_32, 0
instruction_set0x17: db NOP, 0, SIZE_32, 0
instruction_set0x18: db NOP, 0, SIZE_32, 0
instruction_set0x19: db NOP, 0, SIZE_32, 0
instruction_set0x1a: db NOP, 0, SIZE_32, 0
instruction_set0x1b: db NOP, 0, SIZE_32, 0
instruction_set0x1c: db NOP, 0, SIZE_32, 0
instruction_set0x1d: db NOP, 0, SIZE_32, 0
instruction_set0x1e: db NOP, 0, SIZE_32, 0
instruction_set0x1f: db NOP, 0, SIZE_32, 0
instruction_set0x20: db AND, MR, SIZE_8, 0
instruction_set0x21: db AND, MR, SIZE_32, 0
instruction_set0x22: db AND, RM, SIZE_8, 0
instruction_set0x23: db AND, RM, SIZE_32, 0
instruction_set0x24: db AND, AI, SIZE_8, 0
instruction_set0x25: db AND, AI, SIZE_32, 0
instruction_set0x26: db NOP, 0, SIZE_32, 0
instruction_set0x27: db NOP, 0, SIZE_32, 0
instruction_set0x28: db SUB, MR, SIZE_8, 0
instruction_set0x29: db SUB, MR, SIZE_32, 0
instruction_set0x2a: db SUB, RM, SIZE_8, 0
instruction_set0x2b: db SUB, RM, SIZE_32, 0
instruction_set0x2c: db SUB, AI, SIZE_8, 0
instruction_set0x2d: db SUB, AI, SIZE_32, 0
instruction_set0x2e: db NOP, 0, SIZE_32, 0
instruction_set0x2f: db NOP, 0, SIZE_32, 0
instruction_set0x30: db XOR, MR, SIZE_8, 0
instruction_set0x31: db XOR, MR, SIZE_32, 0
instruction_set0x32: db XOR, RM, SIZE_8, 0
instruction_set0x33: db XOR, RM, SIZE_32, 0
instruction_set0x34: db XOR, AI, SIZE_8, 0
instruction_set0x35: db XOR, AI, SIZE_32, 0
instruction_set0x36: db NOP, 0, SIZE_32, 0
instruction_set0x37: db NOP, 0, SIZE_32, 0
instruction_set0x38: db CMP, MR, SIZE_8, 0
instruction_set0x39: db CMP, MR, SIZE_32, 0
instruction_set0x3a: db CMP, RM, SIZE_8, 0
instruction_set0x3b: db CMP, RM, SIZE_32, 0
instruction_set0x3c: db CMP, AI, SIZE_8, 0
instruction_set0x3d: db CMP, AI, SIZE_32, 0
instruction_set0x3e: db NOP, 0, SIZE_32, 0
instruction_set0x3f: db NOP, 0, SIZE_32, 0
instruction_set0x40: db NOP, 0, SIZE_32, 0
instruction_set0x41: db NOP, 0, SIZE_32, 0
instruction_set0x42: db NOP, 0, SIZE_32, 0
instruction_set0x43: db NOP, 0, SIZE_32, 0
instruction_set0x44: db NOP, 0, SIZE_32, 0
instruction_set0x45: db NOP, 0, SIZE_32, 0
instruction_set0x46: db NOP, 0, SIZE_32, 0
instruction_set0x47: db NOP, 0, SIZE_32, 0
instruction_set0x48: db NOP, 0, SIZE_32, 0
instruction_set0x49: db NOP, 0, SIZE_32, 0
instruction_set0x4a: db NOP, 0, SIZE_32, 0
instruction_set0x4b: db NOP, 0, SIZE_32, 0
instruction_set0x4c: db NOP, 0, SIZE_32, 0
instruction_set0x4d: db NOP, 0, SIZE_32, 0
instruction_set0x4e: db NOP, 0, SIZE_32, 0
instruction_set0x4f: db NOP, 0, SIZE_32, 0
instruction_set0x50: db PUSH, O, SIZE_64, 0
instruction_set0x51: db PUSH, O, SIZE_64, 0
instruction_set0x52: db PUSH, O, SIZE_64, 0
instruction_set0x53: db PUSH, O, SIZE_64, 0
instruction_set0x54: db PUSH, O, SIZE_64, 0
instruction_set0x55: db PUSH, O, SIZE_64, 0
instruction_set0x56: db PUSH, O, SIZE_64, 0
instruction_set0x57: db PUSH, O, SIZE_64, 0
instruction_set0x58: db POP, O, SIZE_64, 0
instruction_set0x59: db POP, O, SIZE_64, 0
instruction_set0x5a: db POP, O, SIZE_64, 0
instruction_set0x5b: db POP, O, SIZE_64, 0
instruction_set0x5c: db POP, O, SIZE_64, 0
instruction_set0x5d: db POP, O, SIZE_64, 0
instruction_set0x5e: db POP, O, SIZE_64, 0
instruction_set0x5f: db POP, O, SIZE_64, 0
instruction_set0x60: db NOP, 0, SIZE_32, 0
instruction_set0x61: db NOP, 0, SIZE_32, 0
instruction_set0x62: db NOP, 0, SIZE_32, 0
instruction_set0x63: db NOP, 0, SIZE_32, 0
instruction_set0x64: db NOP, 0, SIZE_32, 0
instruction_set0x65: db NOP, 0, SIZE_32, 0
instruction_set0x66: db NOP, 0, SIZE_32, 0
instruction_set0x67: db NOP, 0, SIZE_32, 0
instruction_set0x68: db PUSH, I, SIZE_32, 0
instruction_set0x69: db NOP, 0, SIZE_32, 0
instruction_set0x6a: db PUSH, I, SIZE_8, 0
instruction_set0x6b: db NOP, 0, SIZE_32, 0
instruction_set0x6c: db NOP, 0, SIZE_32, 0
instruction_set0x6d: db NOP, 0, SIZE_32, 0
instruction_set0x6e: db NOP, 0, SIZE_32, 0
instruction_set0x6f: db NOP, 0, SIZE_32, 0
instruction_set0x70: db JCC, D, SIZE_8, 0
instruction_set0x71: db JCC, D, SIZE_8, 0
instruction_set0x72: db JCC, D, SIZE_8, 0
instruction_set0x73: db JCC, D, SIZE_8, 0
instruction_set0x74: db JCC, D, SIZE_8, 0
instruction_set0x75: db JCC, D, SIZE_8, 0
instruction_set0x76: db JCC, D, SIZE_8, 0
instruction_set0x77: db JCC, D, SIZE_8, 0
instruction_set0x78: db JCC, D, SIZE_8, 0
instruction_set0x79: db JCC, D, SIZE_8, 0
instruction_set0x7a: db JCC, D, SIZE_8, 0
instruction_set0x7b: db JCC, D, SIZE_8, 0
instruction_set0x7c: db JCC, D, SIZE_8, 0
instruction_set0x7d: db JCC, D, SIZE_8, 0
instruction_set0x7e: db JCC, D, SIZE_8, 0
instruction_set0x7f: db JCC, D, SIZE_8, 0
instruction_set0x80: db ADD, MI, SIZE_8, 1
instruction_set0x81: db ADD, MI, SIZE_32, 1
instruction_set0x82: db NOP, 0, SIZE_32, 0
instruction_set0x83: db ADD, MI8, SIZE_32, 1
instruction_set0x84: db TEST, MR, SIZE_8, 0
instruction_set0x85: db TEST, MR, SIZE_32, 0
instruction_set0x86: db NOP, 0, SIZE_32, 0
instruction_set0x87: db NOP, 0, SIZE_32, 0
instruction_set0x88: db MOV, MR, SIZE_8, 0
instruction_set0x89: db MOV, MR, SIZE_32, 0
instruction_set0x8a: db MOV, RM, SIZE_8, 0
instruction_set0x8b: db MOV, RM, SIZE_32, 0
instruction_set0x8c: db NOP, 0, SIZE_32, 0
instruction_set0x8d: db LEA, RM, SIZE_32, 0
instruction_set0x8e: db NOP, 0, SIZE_32, 0
instruction_set0x8f: db POP, M, SIZE_64, 0
instruction_set0x90: db NOP, 0, SIZE_32, 0
instruction_set0x91: db NOP, 0, SIZE_32, 0
instruction_set0x92: db NOP, 0, SIZE_32, 0
instruction_set0x93: db NOP, 0, SIZE_32, 0
instruction_set0x94: db NOP, 0, SIZE_32, 0
instruction_set0x95: db NOP, 0, SIZE_32, 0
instruction_set0x96: db NOP, 0, SIZE_32, 0
instruction_set0x97: db NOP, 0, SIZE_32, 0
instruction_set0x98: db NOP, 0, SIZE_32, 0
instruction_set0x99: db NOP, 0, SIZE_32, 0
instruction_set0x9a: db NOP, 0, SIZE_32, 0
instruction_set0x9b: db NOP, 0, SIZE_32, 0
instruction_set0x9c: db NOP, 0, SIZE_32, 0
instruction_set0x9d: db NOP, 0, SIZE_32, 0
instruction_set0x9e: db NOP, 0, SIZE_32, 0
instruction_set0x9f: db NOP, 0, SIZE_32, 0
instruction_set0xa0: db NOP, 0, SIZE_32, 0
instruction_set0xa1: db NOP, 0, SIZE_32, 0
instruction_set0xa2: db NOP, 0, SIZE_32, 0
instruction_set0xa3: db NOP, 0, SIZE_32, 0
instruction_set0xa4: db NOP, 0, SIZE_32, 0
instruction_set0xa5: db NOP, 0, SIZE_32, 0
instruction_set0xa6: db NOP, 0, SIZE_32, 0
instruction_set0xa7: db NOP, 0, SIZE_32, 0
instruction_set0xa8: db TEST, AI, SIZE_8, 0
instruction_set0xa9: db TEST, AI, SIZE_32, 0
instruction_set0xaa: db NOP, 0, SIZE_32, 0
instruction_set0xab: db NOP, 0, SIZE_32, 0
instruction_set0xac: db NOP, 0, SIZE_32, 0
instruction_set0xad: db NOP, 0, SIZE_32, 0
instruction_set0xae: db NOP, 0, SIZE_32, 0
instruction_set0xaf: db NOP, 0, SIZE_32, 0
instruction_set0xb0: db MOV, RI, SIZE_8, 0
instruction_set0xb1: db MOV, RI, SIZE_8, 0
instruction_set0xb2: db MOV, RI, SIZE_8, 0
instruction_set0xb3: db MOV, RI, SIZE_8, 0
instruction_set0xb4: db MOV, RI, SIZE_8, 0
instruction_set0xb5: db MOV, RI, SIZE_8, 0
instruction_set0xb6: db MOV, RI, SIZE_8, 0
instruction_set0xb7: db MOV, RI, SIZE_8, 0
instruction_set0xb8: db MOV, RI, SIZE_32, 0
instruction_set0xb9: db MOV, RI, SIZE_32, 0
instruction_set0xba: db MOV, RI, SIZE_32, 0
instruction_set0xbb: db MOV, RI, SIZE_32, 0
instruction_set0xbc: db MOV, RI, SIZE_32, 0
instruction_set0xbd: db MOV, RI, SIZE_32, 0
instruction_set0xbe: db MOV, RI, SIZE_32, 0
instruction_set0xbf: db MOV, RI, SIZE_32, 0
instruction_set0xc0: db SHL, MI, SIZE_8, 1
instruction_set0xc1: db SHL, MI8, SIZE_32, 1
instruction_set0xc2: db NOP, 0, SIZE_32, 0
instruction_set0xc3: db RET, NO, SIZE_32, 0
instruction_set0xc4: db NOP, 0, SIZE_32, 0
instruction_set0xc5: db NOP, 0, SIZE_32, 0
instruction_set0xc6: db MOV, MI, SIZE_8, 0
instruction_set0xc7: db MOV, MI, SIZE_32, 0
instruction_set0xc8: db NOP, 0, SIZE_32, 0
instruction_set0xc9: db LEAVE, NO, SIZE_32, 0
instruction_set0xca: db NOP, 0, SIZE_32, 0
instruction_set0xcb: db NOP, 0, SIZE_32, 0
instruction_set0xcc: db NOP, 0, SIZE_32, 0
instruction_set0xcd: db NOP, 0, SIZE_32, 0
instruction_set0xce: db NOP, 0, SIZE_32, 0
instruction_set0xcf: db NOP, 0, SIZE_32, 0
instruction_set0xd0: db SHL, M1, SIZE_8, 1
instruction_set0xd1: db SHL, M1, SIZE_32, 1
instruction_set0xd2: db NOP, 0, SIZE_32, 0
instruction_set0xd3: db NOP, 0, SIZE_32, 0
instruction_set0xd4: db NOP, 0, SIZE_32, 0
instruction_set0xd5: db NOP, 0, SIZE_32, 0
instruction_set0xd6: db NOP, 0, SIZE_32, 0
instruction_set0xd7: db NOP, 0, SIZE_32, 0
instruction_set0xd8: db NOP, 0, SIZE_32, 0
instruction_set0xd9: db NOP, 0, SIZE_32, 0
instruction_set0xda: db NOP, 0, SIZE_32, 0
instruction_set0xdb: db NOP, 0, SIZE_32, 0
instruction_set0xdc: db NOP, 0, SIZE_32, 0
instruction_set0xdd: db NOP, 0, SIZE_32, 0
instruction_set0xde: db NOP, 0, SIZE_32, 0
instruction_set0xdf: db NOP, 0, SIZE_32, 0
instruction_set0xe0: db NOP, 0, SIZE_32, 0
instruction_set0xe1: db NOP, 0, SIZE_32, 0
instruction_set0xe2: db NOP, 0, SIZE_32, 0
instruction_set0xe3: db JCC, D, SIZE_8, 0
instruction_set0xe4: db NOP, 0, SIZE_32, 0
instruction_set0xe5: db NOP, 0, SIZE_32, 0
instruction_set0xe6: db NOP, 0, SIZE_32, 0
instruction_set0xe7: db NOP, 0, SIZE_32, 0
instruction_set0xe8: db CALL, D, SIZE_32, 0
instruction_set0xe9: db JMP, D, SIZE_32, 0
instruction_set0xea: db NOP, 0, SIZE_32, 0
instruction_set0xeb: db JMP, D, SIZE_8, 0
instruction_set0xec: db NOP, 0, SIZE_32, 0
instruction_set0xed: db NOP, 0, SIZE_32, 0
instruction_set0xee: db NOP, 0, SIZE_32, 0
instruction_set0xef: db NOP, 0, SIZE_32, 0
instruction_set0xf0: db NOP, 0, SIZE_32, 0
instruction_set0xf1: db NOP, 0, SIZE_32, 0
instruction_set0xf2: db NOP, 0, SIZE_32, 0
instruction_set0xf3: db NOP, 0, SIZE_32, 0
instruction_set0xf4: db NOP, 0, SIZE_32, 0
instruction_set0xf5: db NOP, 0, SIZE_32, 0
instruction_set0xf6: db TEST, MI, SIZE_8, 0
instruction_set0xf7: db TEST, MI, SIZE_32, 0
instruction_set0xf8: db NOP, 0, SIZE_32, 0
instruction_set0xf9: db NOP, 0, SIZE_32, 0
instruction_set0xfa: db NOP, 0, SIZE_32, 0
instruction_set0xfb: db NOP, 0, SIZE_32, 0
instruction_set0xfc: db NOP, 0, SIZE_32, 0
instruction_set0xfd: db NOP, 0, SIZE_32, 0
instruction_set0xfe: db INC, M, SIZE_8, 1
instruction_set0xff: db PUSH, M, SIZE_32, 1

;;; Mod/RM Tab

;                   0               1               2               3               4               5               6               7
ModRM_tab: db       MODRM_RM,       MODRM_RM,       MODRM_RM,       MODRM_RM,       MODRM_SIB,      MODRM_REL_32,   MODRM_RM,       MODRM_RM
ModRM_tab_01: db    MODRM_RM_8,     MODRM_RM_8,     MODRM_RM_8,     MODRM_RM_8,     MODRM_SIB_8,    MODRM_RM_8,     MODRM_RM_8,     MODRM_RM_8
ModRM_tab_10: db    MODRM_RM_32,    MODRM_RM_32,    MODRM_RM_32,    MODRM_RM_32,    MODRM_SIB_32,   MODRM_RM_32,    MODRM_RM_32,    MODRM_RM_32
ModRM_tab_11: db    MODRM_REG,      MODRM_REG,      MODRM_REG,      MODRM_REG,      MODRM_REG,      MODRM_REG,      MODRM_REG,      MODRM_REG

memory_offset_tab: db 0, idrm_mem, idmr_mem, idmi_mem, 0, 0, 0, 0, idm_mem, idd_mem ; 0 if none because 0 is opcode