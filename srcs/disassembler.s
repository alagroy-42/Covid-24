%ifndef DISASSEMBLER_S
%define DISASSEMBLER_S

struc       Instruction_disass_RM
    idrm_opcode:    resb    1 ; OPCODE + size
    idrm_lm_encode: resb    1
    idrm_reg:       resb    1 ; encoding | value of left register 
    idrm_mem:       resb    6 ; value of right memory value as reg1, scale|reg2, disp
    idrm_pad:       resb    7 ; padding to align the structure
    idrm_rip:       resq    1 ; value of rip on this instruction
endstruc

struc       Instruction_disass_MR
    idmr_opcode:    resb    1 ; OPCODE + size
    idmr_lm_encode: resb    1
    idmr_mem:       resb    6 ; encoding | value of left memory value as reg1, scale|reg2, disp
    idmr_reg:       resb    1 ; value of right register 
    idmr_pad:       resb    7 ; padding to align the structure
    idmr_rip:       resq    1 ; value of rip on this instruction
endstruc

struc       Instruction_disass_RR
    idrr_opcode:    resb    1 ; OPCODE + size
    idrr_lm_encode: resb    1
    idrr_reg1:      resb    1 ; value of right register 
    idrr_reg2:      resb    1 ; encoding | value of left memory value as reg1, scale|reg2, disp
    idrr_pad:       resb    12 ; padding to align the structure
    idrr_rip:       resq    1 ; value of rip on this instruction
endstruc

struc       Instruction_disass_RI
    idri_opcode:    resb    1 ; OPCODE + size
    idri_lm_encode: resb    1
    idri_reg:       resb    1 ; encoding | value of right register 
    idri_pad:       resb    5 ; padding to align the structure
    idri_imm:       resq    1 ; value of immediate
    idri_rip:       resq    1 ; value of rip on this instruction
endstruc

struc       Instruction_disass_O
    ido_opcode:    resb    1 ; OPCODE + size
    ido_lm_encode: resb    1
    ido_reg:       resb    1 ; register value 
    ido_pad:       resb    13 ; padding to align the structure
    ido_rip:       resq    1 ; value of rip on this instruction
endstruc

struc       Instruction_disass_MI
    idmi_opcode:    resb    1
    idmi_lm_encode: resb    1
    idmi_mem:       resb    6
    idmi_imm:       resq    1
    idmi_rip:       resq    1
endstruc

struc       Instruction_disass_M
    idm_opcode:    resb    1
    idm_lm_encode: resb    1
    idm_mem:       resb    6
    idm_pad:       resq    1
    idm_rip:       resq    1
endstruc

struc       Instruction_disass_D
    idd_opcode:    resb    1
    idd_lm_encode: resb    1
    idd_mem:       resb    6
    idd_pad:       resq    1
    idd_rip:       resq    1
endstruc

struc       Instruction_disass_I
    idi_opcode:    resb    1
    idi_lm_encode: resb    1
    idi_pad:       resb    6
    idi_imm:       resq    1
    idi_rip:       resq    1
endstruc

struc       Instruction_disass  ; Generic structure before encoding identification
    id_opcode:      resb    1  ; OPCODE | OP_SIZE
                               ; OP_SIZE working as SIB's scale 
    id_lm_encode:   resb    1  ; label mark | encoding
                               ; whether it's a register or a memory value, since memory values start with a register,
                               ; this field is gonna hold a register value.
                               ; Register values use only 5 bytes (4 bytes to encode the 16 normal registers + the fifth for RIP => 0x10) 
                               ; The three higher bytes are gonna hold the encoding type value
    id_pad:         resb    14 ; leet's keep the structure aligned
    id_rip:         resq    1  ; value of rip on this instruction
endstruc

%define ID_SIZE 24

struc       Memory_operand
    mem_base:       resb    1 ; base register
    mem_sindex:     resb    1 ; scale | index_register
    mem_disp:       resd    1 ; displacement
endstruc

struc       Instruction_set_entry ; Structure used in instruction_set.s
    ise_opcode:     resb    1 ; pseudo-assembly opcode value
    ise_encoding:   resb    1 ; encoding disposition
    ise_size:       resb    1 ; operand size
    ise_extended:   resb    1
endstruc

%define ISE_SIZE        4

struc       Label_entry
    label_rip:      resq    1 ; the code rip that points on label
    label_elem:     resq    1 ; a pointer on the instruction pointed on by label
endstruc

%define LABEL_ENTRY_SIZE    16

%define RIP             10000b
%define NOREG           11111b

%define REX             0x40
%define REXW            REX | (1 << 3)
%define REXR            (1 << 2)
%define REXX            (1 << 1)
%define REXB            (1 << 0)

%define DOUBLE          0x0f
%define PUSH            0x50
%define POP             0x58
%define JCC             0x70
%define ADD             0x80
%define OR              0x84
%define AND             0x88
%define SUB             0x8c
%define NOP             0x90
%define XOR             0x94
%define CMP             0x98
%define LEA             0x9c
%define TEST            0xa8
%define MOV             0xb0
%define MOVSX           0xbc
%define RET             0xc4
%define LEAVE           0xc8
%define SHL             0xd0
%define SHR             0xd8
%define CALL            0xe8
%define JMP             0xec
%define SYSCALL         0xf0
%define INC             0xf4
%define DEC             0xf8

%define LABEL_MARK      0x10

%define NO              0x0
%define RM              0x1
%define MR              0x2
%define MI              0x3
%define RI              0x4
%define RR              0x5
%define O               0x6
%define I               0x7
%define M               0x8
%define D               0x9
%define AI              0xa
%define MI8             0xb
%define M1              0xc

%define RM              0x1
%define SIB             0x2
%define REL             0x4
%define REG             0x8

%define DISP0           0x0
%define DISP8           0x1
%define DISP32          0x2

%define MOD_REG         0x3

%define MODRM_RM        (RM << 4)
%define MODRM_RM_8      (RM << 4) | DISP8
%define MODRM_RM_32     (RM << 4) | DISP32
%define MODRM_SIB       (SIB << 4)
%define MODRM_SIB_8     (SIB << 4) | DISP8
%define MODRM_SIB_32    (SIB << 4) | DISP32
%define MODRM_REL_32    (REL << 4) | DISP32
%define MODRM_REG       (REG << 4)

%define MODRM_ENTSIZE   8

%define BASE            (1 << 5)
%define SINDEX          (1 << 4)
%define NO_SINDEX       RIP

%define SIB_BASE            BASE
%define SIB_SI              SINDEX
%define SIB_BASE_SI         BASE | SINDEX
%define SIB_SI_DISP_32      SI | DISP32
%define SIB_BASE_SI_DISP_8  BASE | SINDEX | DISP8
%define SIB_BASE_SI_DISP_32 BASE | SINDEX | DISP32
%define SIB_BASE_DISP_8     BASE | DISP8
%define SIB_BASE_DISP_8     BASE | DISP32
%define SIB_DISP_32         DISP32

%define SIZE_8          0x0
%define SIZE_16         0x1
%define SIZE_32         0x2
%define SIZE_64         0x3

%endif