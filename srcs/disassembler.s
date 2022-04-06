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

struc       Instruction_disass_RI
    idri_opcode:    resb    1 ; OPCODE + size
    idri_lm_encode: resb    1
    idri_reg:       resb    1 ; encoding | value of right register 
    idri_pad:       resw    5 ; padding to align the structure
    idri_imm:       resq    1 ; value of immediate
    idri_rip:       resq    1 ; value of rip on this instruction
endstruc

struc       Instruction_disass_MI
    idmi_opcode:    resb    1
    idmi_lm_encode: resb    1
    idmi_mem:       resb    6
    idmi_imm:       resq    1
    idmi_rip:       resq    1
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

struc       Memory_operand
    mem_base:       resb    1 ; base register
    mem_sindex:     resb    1 ; scale | index_register
    mem_disp:       resd    1 ; displacement
endstruc

struc       Instruction_set_entry ; Structure used in instruction_set.s
    ise_opcode:     resb    1 ; pseudo-assembly opcode value
    ise_encoding:   resb    1 ; encoding disposition
    ise_size:       resb    1 ; operand size
endstruc

%define ISE_SIZE        3

%define REX             0x40
%define REXW            REX | (1 << 3)
%define REXR            REX | (1 << 2)
%define REXX            REX | (1 << 1)
%define REXB            REX | (1 << 0)

%define MOV             0xb0
%define NOP             0x90
%define SYSCALL         0xf0
%define RET             0xc0
%define LEA             0x80

%define NO              0x0
%define RM              0x1
%define MR              0x2
%define MI              0x3
%define OI              0x4

%define ENC_MR          (MR << 6)
%define ENC_RM          (RM << 6)
%define ENC_RI          (OI << 6)
%define ENC_MI          (MI << 6)

%define REG             0x1
%define SIB             0x2
%define REL             0x4

%define DISP0           0x0
%define DISP8           0x1
%define DISP32          0x2

%define MODRM_RM        (REG << 4)
%define MODRM_RM_8      (REG << 4) | DISP8
%define MODRM_RM_32     (REG << 4) | DISP32
%define MODRM_SIB       (SIB << 4)
%define MODRM_SIB_8     (SIB << 4) | DISP8
%define MODRM_SIB_32    (SIB << 4) | DISP32
%define MODRM_REL_32    (REL << 4) | DISP32

%define BASE            (1 << 5)       
%define SINDEX          (1 << 4)

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

%define MODRM_ENTSIZE   8
%define RIP             10000b

%endif