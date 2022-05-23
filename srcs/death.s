BITS 64

%include "defines.s"
%include "instruction_set.s"
%include "disassembler.s"

section .data
    hello: db "Hello World !", 10, 0
        .len: equ $ - hello
    instr_list: dq 0
    label_table: dq 0
    future_label_table: dq 0
    opcode_extension: db 0
    prng_data: db 0
    label_instr: db CALL, JMP, JCC, 0
    ;           rax,  rcx,  rdx,  rbx,  rsp,  rbp,  rsi,  rdi,  r8,   r9,   r10,  r11,  r12,  r13,  r14,  r15
    assembly_pages: dq 0
    regs: db    0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f

section .text
    global _start
    extern _display_list
    extern _display_labels
    extern _display_future_labels

_start:
    xor     rdi, rdi
    mov     rsi, 4096 * 8
    mov     rdx, PROT_READ | PROT_WRITE
    mov     r10, MAP_ANONYMOUS | MAP_PRIVATE
    mov     r8, -1
    xor     r9, r9
    mov     rax, SYS_MMAP
    syscall
    test    al, al
    jnz     _end
    mov     [rel instr_list], rax

    xor     rdi, rdi
    mov     rsi, 4096
    mov     rdx, PROT_READ | PROT_WRITE
    mov     r10, MAP_ANONYMOUS | MAP_PRIVATE
    mov     r8, -1
    xor     r9, r9
    mov     rax, SYS_MMAP
    syscall
    test    al, al
    jnz     _end
    mov     [rel label_table], rax

    xor     rdi, rdi
    mov     rsi, 4096
    mov     rdx, PROT_READ | PROT_WRITE
    mov     r10, MAP_ANONYMOUS | MAP_PRIVATE
    mov     r8, -1
    xor     r9, r9
    mov     rax, SYS_MMAP
    syscall
    test    al, al
    jnz     _end
    mov     [rel future_label_table], rax

    xor     rdi, rdi
    mov     rsi, 4096
    mov     rdx, PROT_READ | PROT_WRITE
    mov     r10, MAP_ANONYMOUS | MAP_PRIVATE
    mov     r8, -1
    xor     r9, r9
    mov     rax, SYS_MMAP
    syscall
    test    al, al
    jnz     _end
    mov     [rel assembly_pages], rax

    call    _prng_init

    lea     rdi, [rel _disass]
    call    _disass
%ifdef      DEBUG_TIME
    mov     rdi, [instr_list]
    call    _display_list
    mov     rdi, [label_table]
    call    _display_labels
    mov     rdi, [future_label_table]
    call    _display_future_labels
%endif
    mov     rdi, [rel instr_list]
    mov     rsi, [rel assembly_pages]
    call    _test_func
    call    _assemble_code
    jmp     _end

; translates assembly opcode to pseudo assembly opcode
; rdi: opcode in dil
; 
; returns: encoding of instruction
_get_instr_encoding:
    mov     al, BYTE [rel instruction_set0x00 + edi * ISE_SIZE + ise_encoding]
    ret

; translates assembly opcode to pseudo assembly opcode
; rdi: opcode in dil
; 
; returns: pseudo assembly opcode value 
_get_instr:
    mov     al, BYTE [rel instruction_set0x00 + edi * ISE_SIZE + ise_opcode]
    ret

; gets the operand size for a given opcode
; rdi: opcode in dil
; 
; returns: the size of the operands
_get_instr_size:
    mov     al, BYTE [rel instruction_set0x00 + edi * ISE_SIZE + ise_size]
    ret

; gets a bool that indicates if the opcode is extended in ModRM's reg
; rdi: opcode in dil
;
; returns: 1 if opcode is extended, 0 otherwise
_is_instr_reg_extended:
    mov     al, BYTE [rel instruction_set0x00 + edi * ISE_SIZE + ise_extended]
    ret

; reads the register held in the ModRM byte
; dil: ModRM byte pointer
; rsi: rex byte
;
; returns: reg byte
_read_ModRM_reg:
    mov     al, [rdi]
    shr     al, 3
    and     al, 111b ; isolate the register part
    mov     cl, sil
    and     cl, REXR
    shl     cl, 1
    or      al, cl ; merge it with REX.R in case it's 64 bit extended reg
    ret

; reads the r/m part of the ModRM byte
; dil: ModRM byte pointer
; rsi: rex byte
;
; returns: r/m's reg
_read_ModRM_rm:
    mov     al, [rdi]
    and     al, 00000111b ; isolate the r/m part
    mov     cl, sil
    and     cl, REXB
    shl     cl, 3
    or      al, cl ; merge it with REX.B in case it's 64 bit extended reg
    ret

; reads the mod part of the ModRM byte
; dil: ModRM byte pointer
;
; returns: mod value
_read_ModRM_mod:
    mov     al, [rdi]
    shr     al, 6
    ret

; stores the base register in mem_base
; This is a read_SIB_byte subfunction so the calling convention is a bit weird.
; It is not designed to be used elsewhere and it is only meant to be used in read_SIB_byte to avoid duplicating code
; rdi: rip
; rsi: Memory_operand struct
; cl: REX byte
;
; returns: void
_read_SIB_byte_store_base:
    mov     al, BYTE [rdi]
    and     al, 111b
    mov     bl, cl
    and     bl, 1b
    shl     bl, 3
    or      al, bl
    mov     [rsi + mem_base], al
    ret

; stores the index register and its scale in mem_sindex
; This is a read_SIB_byte subfunction so the calling convention is a bit weird.
; It is not designed to be used elsewhere and it is only meant to be used in read_SIB_byte to avoid duplicating code
; rdi: rip
; rsi: Memory_operand struct
; cl: REX byte
;
; returns: void
_read_SIB_byte_store_sindex:
    mov     al, BYTE [rdi]
    shr     al, 3
    and     al, 111b
    mov     bl, cl
    and     bl, REXX
    shl     bl, 2
    or      al, bl
    mov     bl, BYTE [rdi]
    and     bl, 11000000b
    or      al, bl
    mov     [rsi + mem_sindex], al
    ret

; stores the displacement and its scale in mem_disp
; This is a read_SIB_byte subfunction so the calling convention is a bit weird.
; It is not designed to be used elsewhere and it is only meant to be used in read_SIB_byte to avoid duplicating code
; rdi: rip
; rsi: Memory_operand struct
;
; returns: void
_read_SIB_byte_store_disp_8:
    xor     eax, eax
    mov     al, BYTE [rdi + 1]
    mov     [rsi + mem_disp], eax
    ret

; stores the displacement and its scale in mem_disp
; This is a read_SIB_byte subfunction so the calling convention is a bit weird.
; It is not designed to be used elsewhere and it is only meant to be used in read_SIB_byte to avoid duplicating code
; rdi: rip
; rsi: Memory_operand struct
;
; returns: void
_read_SIB_byte_store_disp_32:
    mov     eax, DWORD [rdi + 1]
    mov     [rsi + mem_disp], eax
    ret

; reads the byte and place the content in a Memory_operand struct
; rdi: rip
; rsi: Memory_operand struct
; dl:  ModRM byte
; cl:  REX byte
;
; returns: number of bytes read
_read_SIB_byte:
    and     dl, 11000000b
    test    dl, dl
    jnz     read_SIB_byte_modnz
    mov     al, BYTE [rdi]
    and     al, 111000b
    shr     al, 3
    mov     bl, cl
    and     bl, REXX
    shl     bl, 2
    or      al, bl
    cmp     al, 100b ; rsp
    je      read_SIB_byte_modz_sp
    mov     al, BYTE [rdi]
    and     al, 111b
    cmp     al, 101b
    je      read_SIB_byte_modz_nsp_bp
    call    _read_SIB_byte_store_base
    call    _read_SIB_byte_store_sindex
    mov     al, 1
    jmp     read_SIB_byte_ret
read_SIB_byte_modz_nsp_bp:
    mov     BYTE [rsi + mem_base], NOREG
    call    _read_SIB_byte_store_sindex
    call    _read_SIB_byte_store_disp_32
    mov     al, 5
    jmp     read_SIB_byte_ret
read_SIB_byte_modz_sp:
    mov     al, BYTE [rdi]
    and     al, 111b
    cmp     al, 101b
    je      read_SIB_byte_modz_sp_bp
    call    _read_SIB_byte_store_base
    mov     al, 1
    jmp     read_SIB_byte_ret
read_SIB_byte_modz_sp_bp:
    mov     BYTE [rsi + mem_base], NOREG
    call    _read_SIB_byte_store_disp_32
    mov     al, 5
    jmp     read_SIB_byte_ret
read_SIB_byte_modnz:
    call    _read_SIB_byte_store_base
    mov     al, BYTE [rdi]
    and     al, 111000b
    shr     al, 3
    mov     bl, cl
    and     bl, REXX
    shl     bl, 2
    or      al, bl
    cmp     al, 100b ; rsp
    je      read_SIB_byte_modnz_sp
    call    _read_SIB_byte_store_sindex
read_SIB_byte_modnz_sp:
    shr     dl, 6
    cmp     dl, 1
    je      read_SIB_byte_modnz_disp8
    call    _read_SIB_byte_store_disp_32
    mov     al, 5
    jmp     read_SIB_byte_ret
read_SIB_byte_modnz_disp8:
    call    _read_SIB_byte_store_disp_8
    mov     al, 2
read_SIB_byte_ret:
    ret

; disassemble the ModRM byte and sets the corresponding ID fields
; rdi: rip
; rsi: mem_op pointer
; rdx: reg pointer
; rcx: rex
;
; returns: operands size
_read_ModRM_byte:
    push    rbp
    mov     rbp, rsp
    push    rcx
    push    rsi
    mov     rsi, rcx
    call    _read_ModRM_reg
    pop     rsi
    mov     BYTE [rdx], al
    push    rsi
    mov     rsi, [rsp + 0x8]
    call    _read_ModRM_rm
    pop     rsi
    mov     BYTE [rsi + mem_base], al
    mov     BYTE [rsi + mem_sindex], NOREG
    mov     rbx, rax
    and     rbx, 111b
    call    _read_ModRM_mod
    cmp     al, MOD_REG
    je      read_ModRM_byte_handle_RR
    mov     al, BYTE [rel ModRM_tab + rax * MODRM_ENTSIZE + rbx]
    cmp     rax, MODRM_REL_32
    jne     read_ModRM_byte_handle_SIB
    mov     BYTE [rsi + mem_base], RIP
    mov     BYTE [rsi + mem_sindex], NOREG
    mov     edx, DWORD [rdi + 1]
    mov     DWORD [rsi + mem_disp], edx
    mov     rbx, 5
    jmp     read_ModRM_byte_return_bytes_nb
read_ModRM_byte_handle_SIB:
    mov     dl, al
    and     dl, 11110000b
    cmp     dl, MODRM_SIB
    jne     read_ModRM_byte_handle_RM
    mov     dl, BYTE [rdi]
    inc     rdi
    mov     rcx, QWORD [rsp]
    call    _read_SIB_byte
    inc     al ; _read_SIB_byte doesn't count the Mod/RM byte
    mov     bl, al
    jmp     read_ModRM_byte_return_bytes_nb
read_ModRM_byte_handle_RM:
    mov     bl, 1
    and     al, 1111b
    test    al, al
    jz      read_ModRM_byte_return_bytes_nb
    cmp     al, DISP8
    jne     read_ModRM_byte_handle_RM_handle_disp_32
    xor     edx, edx
    mov     dl, BYTE [rdi + 1]
    inc     bl
    jmp     read_ModRM_byte_handle_RM_store_disp
read_ModRM_byte_handle_RM_handle_disp_32:
    mov     edx, DWORD [rdi + 1]
    add     bl, 4
read_ModRM_byte_handle_RM_store_disp:
    mov     DWORD [rsi + mem_disp], edx
    jmp     read_ModRM_byte_return_bytes_nb
read_ModRM_byte_handle_RR:
    mov     bl, 0
read_ModRM_byte_return_bytes_nb:
    mov     rax, rbx ; operands
    leave
    ret

; disassemble operands of instruction using when op1 = modRM/mem and op2 = modRM/reg
; rdi: rip
; rsi: curr list elem
; rdx: rex
;
; returns : operands size
_disass_MR:
    push    rbp
    mov     rbp, rsp
    push    rsi
    mov     rcx, rdx
    mov     rdx, rsi
    add     rsi, idmr_mem
    add     rdx, idmr_reg
    call    _read_ModRM_byte
    pop     rsi
    test    al, al
    jz      disass_MR_handle_RR
    jmp     disass_MR_return_bytes_nb
disass_MR_handle_RR:
    mov     al, BYTE [rsi + id_lm_encode]
    and     al, 11110000b
    or      al, RR
    mov     BYTE [rsi + id_lm_encode], al
    mov     al, [rsi + idmr_mem + mem_base]
    mov     bl, [rsi + idmr_reg]
    mov     [rsi + idrr_reg1], al
    mov     [rsi + idrr_reg2], bl
    mov     al, 1
disass_MR_return_bytes_nb:
    leave
    ret

; disassemble operands of instruction using when op1 = modRM/reg and op2 = modRM/mem
; rdi: rip
; rsi: curr list elem
; rdx: rex
;
; returns : operands size
_disass_RM:
    push    rbp
    mov     rbp, rsp
    push    rsi
    mov     rcx, rdx
    mov     rdx, rsi
    add     rsi, idrm_mem
    add     rdx, idrm_reg
    call    _read_ModRM_byte
    pop     rsi
    test    al, al
    jz      disass_RM_handle_RR
    jmp     disass_RM_return_bytes_nb
disass_RM_handle_RR:
    mov     al, BYTE [rsi + id_lm_encode]
    and     al, 11110000b
    or      al, RR
    mov     BYTE [rsi + id_lm_encode], al
    mov     al, 1
disass_RM_return_bytes_nb:
    ; mov     rax, rbx ; operands
    leave
    ret

; disassemble operands of instruction using when op1 = opcode and op2 = imm
; rdi: rip
; rsi: curr list elem
; rdx: rex
; cl: size
;
; returns : operands size
_disass_MI:
    push    rbp
    mov     rbp, rsp
    push    rdi
    push    rcx
    push    rsi
    mov     rcx, rdx
    add     rsi, idmi_mem
    push    rdx
    lea     rdx, [rel opcode_extension]
    call    _read_ModRM_byte
    pop     rdx
    mov     rbx, rax
    pop     rsi
    pop     rcx
    pop     rdi
    test    al, al
    jnz     disass_MI_store_imm
    mov     al, BYTE [rdi]
    and     al, 111b
    mov     bl, dl
    and     bl, REXB
    shl     bl, 3
    or      al, bl
    mov     BYTE [rsi + idri_reg], al
    mov     al, BYTE [rsi + id_lm_encode]
    and     al, 11110000b
    or      al, RI
    mov     BYTE [rsi + id_lm_encode], al
    mov     bl, 1
disass_MI_store_imm:
    test    cl, cl
    jnz     disass_MI_read_imm_16
    mov     al, BYTE [rdi + rbx]
    mov     QWORD [rsi + idmi_imm], rax
    mov     al, 1
    jmp     disass_MI_end
disass_MI_read_imm_16:
    cmp     cl, SIZE_16
    jnz     disass_MI_read_imm_32
    mov     ax, WORD [rdi + rbx]
    mov     QWORD [rsi + idmi_imm], rax
    mov     al, 2
    jmp     disass_MI_end
disass_MI_read_imm_32:
    mov     eax, DWORD [rdi + rbx]
    mov     QWORD [rsi + idmi_imm], rax
    mov     al, 4
    jmp     disass_MI_end
disass_MI_end:
    add     rax, rbx ; operands
    leave
    ret

; disassemble operands of instruction using when op1 = opcode and op2 = imm
; rdi: rip
; rsi: curr list elem
; rdx: rex
; cl: size
;
; returns : operands size
_disass_OI:
    mov     al, BYTE [rdi]
    and     al, 111b
    mov     bl, dl
    and     bl, 1b
    shl     bl, 3
    or      al, bl
    mov     BYTE [rsi + idri_reg], al
    test    cl, cl
    jnz     disass_OI_read_imm_16
    mov     al, BYTE [rdi + 1]
    mov     QWORD [rsi + idri_imm], rax
    mov     rax, 1
    jmp     disass_OI_end
disass_OI_read_imm_16:
    cmp     cl, SIZE_16
    jnz     disass_OI_read_imm_32_test
    mov     ax, WORD [rdi + 1]
    mov     QWORD [rsi + idri_imm], rax
    mov     rax, 2
    jmp     disass_OI_end
disass_OI_read_imm_32_test:
    cmp     cl, SIZE_32
    jnz     disass_OI_read_imm_64
disass_OI_read_imm_32:
    mov     eax, DWORD [rdi + 1]
    mov     QWORD [rsi + idri_imm], rax
    mov     rax, 4
    jmp     disass_OI_end
disass_OI_read_imm_64:
    cmp     BYTE [rsi + id_opcode], MOV | SIZE_64
    jne     disass_OI_read_imm_32
    and     BYTE [rsi + id_opcode], 11111100b | SIZE_64
    mov     rax, QWORD [rdi + 1]
    mov     QWORD [rsi + idri_imm], rax
    mov     rax, 8
    jmp     disass_OI_end
disass_OI_end:
    ret

; disassemble the O encoded operand
; rdi: rip
; rsi: current list elem
; rdx: REX byte
;
; returns: operands size (1)
_disass_O:
    push    rbp
    mov     rbp, rsp
    mov     al, [rdi]
    and     al, 111b
    mov     bl, dl
    and     bl, 1b
    shl     bl, 3
    or      al, bl
    mov     BYTE [rsi + ido_reg], al
    xor     al, al
    leave
    ret

; disassemble the I encoded operand
; rdi: rip
; rsi: current list elem
; rdx: imm size
;
; returns: operands size
_disass_I:
    push    rbp
    mov     rbp, rsp
    xor     rbx, rbx
    test    dl, dl
    jnz     _disass_I_imm_32
    mov     bl, BYTE [rdi]
    mov     al, 1
    jmp     _disass_I_store_imm
_disass_I_imm_32:
    mov     ebx, DWORD [rdi]
    mov     al, 4
    jmp     _disass_I_store_imm
_disass_I_store_imm:
    mov     [rsi + idi_imm], rbx
    leave
    ret

; disassemble M encoded instruction
; rdi: current rip
; rsi: current list element
; rdx: REX byte
;
; returns: operands size
_disass_M:
    push    rbp
    mov     rbp, rsp
    push    rdx
    mov     rcx, rdx
    mov     rdx, rsi
    add     rsi, idm_mem
    lea     rdx, [rel opcode_extension]
    call    _read_ModRM_byte
    sub     rsi, idm_mem
    pop     rdx
    test    al, al
    jnz     disass_M_leave
    mov     al, BYTE [rdi]
    and     al, 111b
    mov     bl, dl
    and     bl, REXB
    shl     bl, 3
    or      al, bl
    mov     BYTE [rsi + ido_reg], al
    mov     al, BYTE [rsi + id_lm_encode]
    and     al, 11110000b
    or      al, O
    mov     BYTE [rsi + id_lm_encode], al
    mov     al, 1
disass_M_leave:
    leave
    ret

; disassemble a D encoded instruction
; rdi: rip
; rsi: current list element
; rdx: size
;
; returns: operands size
_disass_D:
    mov     BYTE [rsi + idd_mem + mem_base], RIP
    mov     BYTE [rsi + idd_mem + mem_sindex], NOREG
    xor     rbx, rbx
    test    dl, dl
    jnz     disass_D_store_offset_32
    mov     al, 1
    mov     bl, BYTE [rdi]
    jmp     disass_D_store_offset
disass_D_store_offset_32:
    mov     al, 4
    mov     ebx, DWORD [rdi]
disass_D_store_offset:
    mov     DWORD [rsi + idd_mem + mem_disp], ebx
    ret

; disassemble an AI-encoded instruction
; rdi: rip
; rsi: current element
; rdx: operand size
;
; returns: instruction length
_disass_AI:
    mov     al, BYTE [rsi + id_lm_encode] 
    and     al, 11110000b
    or      al, RI
    mov     BYTE [rsi + id_lm_encode], al
    mov     BYTE [rsi + idri_reg], 0
    test    dl, dl
    jnz     disass_AI_read_imm_16
    mov     al, BYTE [rdi]
    mov     QWORD [rsi + idri_imm], rax
    mov     rax, 1
    jmp     disass_AI_end
disass_AI_read_imm_16:
    cmp     dl, SIZE_16
    jnz     disass_AI_read_imm_32
    mov     ax, WORD [rdi]
    mov     QWORD [rsi + idri_imm], rax
    mov     rax, 2
    jmp     disass_AI_end
disass_AI_read_imm_32:
    mov     eax, DWORD [rdi]
    mov     QWORD [rsi + idri_imm], rax
    mov     rax, 4
disass_AI_end:
    ret

; disass an MI8 encoded instruction
; rdi: rip
; rsi: current list elem
; rdx: REX
; cl: size
;
; returns: the size of the operands
_disass_MI8:
    push    rbp
    mov     rbp, rsp
    mov     al, BYTE [rsi + id_lm_encode]
    and     al, 11110000b
    or      al, MI
    mov     BYTE [rsi + id_lm_encode], al
    push    rdi
    push    rcx
    push    rsi
    mov     rcx, rdx
    add     rsi, idmi_mem
    push    rdx
    lea     rdx, [rel opcode_extension]
    call    _read_ModRM_byte
    pop     rdx
    mov     rbx, rax
    pop     rsi
    pop     rcx
    pop     rdi
    test    al, al
    jnz     disass_MI8_store_imm
    mov     al, BYTE [rdi]
    and     al, 111b
    mov     bl, dl
    and     bl, REXB
    shl     bl, 3
    or      al, bl
    mov     BYTE [rsi + idri_reg], al
    mov     al, BYTE [rsi + id_lm_encode]
    and     al, 11110000b
    or      al, RI
    mov     BYTE [rsi + id_lm_encode], al
    mov     bl, 1
disass_MI8_store_imm:
    mov     al, BYTE [rdi + rbx]
    mov     QWORD [rsi + idmi_imm], rax
    inc     rbx ; imm8
    mov     rax, rbx
    leave
    ret

; disass an MI8 encoded instruction
; rdi: rip
; rsi: current list elem
; rdx: REX
; cl: size
;
; returns: the size of the operands
_disass_M1:
    push    rbp
    mov     rbp, rsp
    mov     al, BYTE [rsi + id_lm_encode]
    and     al, 11110000b
    or      al, MI
    mov     BYTE [rsi + id_lm_encode], al
    push    rdi
    push    rcx
    push    rsi
    mov     rcx, rdx
    add     rsi, idmi_mem
    push    rdx
    lea     rdx, [rel opcode_extension]
    call    _read_ModRM_byte
    pop     rdx
    mov     rbx, rax
    pop     rsi
    pop     rcx
    pop     rdi
    test    al, al
    jnz     disass_M1_store_1
    mov     al, BYTE [rdi]
    and     al, 111b
    mov     bl, dl
    and     bl, REXB
    shl     bl, 3
    or      al, bl
    mov     BYTE [rsi + idri_reg], al
    mov     al, BYTE [rsi + id_lm_encode]
    and     al, 11110000b
    or      al, RI
    mov     BYTE [rsi + id_lm_encode], al
    mov     bl, 1
disass_M1_store_1:
    mov     al, 1
    mov     QWORD [rsi + idmi_imm], rax
    mov     rax, rbx
    leave
    ret

; extends the opcode with the extension stored in ModRM's reg if needed
; rsi: current list elem
; 
; returns: void
_disass_instr_extend_opcode:
    mov     bl, [rsi + id_opcode]
    and     bl, 0xfc
    mov     cl, BYTE [rel opcode_extension]
    cmp     bl, PUSH
    jne     disass_instr_extend_opcode_test_add
    test    cl, cl
    jne     disass_instr_extend_opcode_test_push_1
    mov     bl, BYTE [rsi + id_opcode]
    and     bl, 11b
    or      bl, INC
    mov     BYTE [rsi + id_opcode], bl
    jmp     disass_instr_extend_opcode_end
disass_instr_extend_opcode_test_push_1:
    cmp     cl, 1
    jne     disass_instr_extend_opcode_test_push_2
    mov     bl, BYTE [rsi + id_opcode]
    and     bl, 11b
    or      bl, DEC
    mov     BYTE [rsi + id_opcode], bl
    jmp     disass_instr_extend_opcode_end
disass_instr_extend_opcode_test_push_2:
    cmp     cl, 2
    jne     disass_instr_extend_opcode_test_push_4
    mov     BYTE [rsi + id_opcode], CALL
    mov     bl, SIZE_64
    or      BYTE [rsi + id_opcode], bl
    jmp     disass_instr_extend_opcode_end
disass_instr_extend_opcode_test_push_4:
    cmp     cl, 4
    jne     disass_instr_extend_opcode_test_push_6
    mov     BYTE [rsi + id_opcode], JMP
    mov     bl, SIZE_64
    or      BYTE [rsi + id_opcode], bl
    jmp     disass_instr_extend_opcode_end
disass_instr_extend_opcode_test_push_6:
    cmp     cl, 6
    jne     disass_instr_extend_opcode_end
    inc     BYTE [rsi + id_opcode] ; SIZE_32 => SIZE_64
    jmp     disass_instr_extend_opcode_end
disass_instr_extend_opcode_test_add:
    cmp     bl, ADD
    jne     disass_instr_extend_opcode_test_inc
    mov     dl, [rsi + id_opcode]
    and     dl, 11b
    cmp     cl, 1
    jne     disass_instr_extend_opcode_add_test_4
    or      dl, OR
    jmp     disass_instr_extend_opcode_add_change_opcode
disass_instr_extend_opcode_add_test_4:
    cmp     cl, 4
    jne     disass_instr_extend_opcode_add_test_5
    or      dl, AND
    jmp     disass_instr_extend_opcode_add_change_opcode
disass_instr_extend_opcode_add_test_5:
    cmp     cl, 5
    jne     disass_instr_extend_opcode_add_test_6
    or      dl, SUB
    jmp     disass_instr_extend_opcode_add_change_opcode
disass_instr_extend_opcode_add_test_6:
    cmp     cl, 6
    jne     disass_instr_extend_opcode_add_test_7
    or      dl, XOR
    jmp     disass_instr_extend_opcode_add_change_opcode

disass_instr_extend_opcode_add_test_7:
    cmp     cl, 7
    jne     disass_instr_extend_opcode_end
    or      dl, CMP
disass_instr_extend_opcode_add_change_opcode:
    mov     BYTE [rsi + id_opcode], dl
    jmp     disass_instr_extend_opcode_end
disass_instr_extend_opcode_test_inc:
    cmp     bl, INC
    jne     disass_instr_extend_opcode_test_shl
    cmp     cl, 1
    jne     disass_instr_extend_opcode_end
    mov     BYTE [rsi + id_opcode], DEC | SIZE_8
    jmp     disass_instr_extend_opcode_end
disass_instr_extend_opcode_test_shl:
    cmp     bl, SHL
    jne     disass_instr_extend_opcode_next_opcode
    cmp     cl, 5
    jne     disass_instr_extend_opcode_end
    or      BYTE [rsi + id_opcode], SHR ; d0 => d8
    jmp     disass_instr_extend_opcode_end
disass_instr_extend_opcode_next_opcode: ;; REMOVE AFTER DISASS
disass_instr_extend_opcode_end:
    ret

; disassemble the next instruction
; rdi: current rip
; rsi: current list elem
;
; returns : instruction length
_disass_next_instr:
    push    rbp
    mov     rbp, rsp
    mov     [rsi + id_rip], rdi
    push    QWORD 0
    push    QWORD 0
    xor     rax, rax
    mov     al, BYTE [rdi]
    mov     bl, al
disass_next_instr_test_size_override:
    cmp     bl, 0x66
    jne     disass_next_instr_REX
    mov     QWORD [rsp + 0x8], 1
    inc     rdi
    mov     al, BYTE [rdi]
    mov     bl, al
disass_next_instr_REX:
    and     bl, 11110000b
    cmp     bl, REX
    jne     continue_disass_next_instr
    mov     [rsp], rax
    inc     rdi
    mov     al, BYTE [rdi]
continue_disass_next_instr:
    xor     r9, r9
    push    rdi
    mov     rdi, rax
    call    _get_instr
    cmp     al, DOUBLE
    je      disass_next_instr_double_opcode
    mov     BYTE [rsi + id_opcode], al
    call    _is_instr_reg_extended
    mov     r8, rax
    call    _get_instr_size
    mov     rbx, [rsp + 0x8] ; => [rsp + 0x8] because of push rdi
    and     rbx, REXW
    cmp     rbx, REXW
    jne     disass_next_instr_store_size
    mov     al, SIZE_64
disass_next_instr_store_size:
    or      BYTE [rsi + id_opcode], al
    call    _get_instr_encoding
    or      BYTE [rsi + id_lm_encode], al
    pop     rdi
    jmp     disass_next_instr_test
disass_next_instr_double_opcode:
    pop     rdi
    inc     rdi
    inc     r9
    mov     al, BYTE [rdi]
    cmp     al, 0x05
    jne     disass_next_instr_test_movsx
    mov     BYTE [rsi + id_opcode], SYSCALL | SIZE_32
    or      BYTE [rsi + id_lm_encode], NO
    mov     al, NO
    jmp     disass_next_instr_test
disass_next_instr_test_movsx:
    cmp     al, 0xbe
    jne     disass_next_instr_jcc
    mov     BYTE [rsi + id_opcode], MOVSX
    mov     al, SIZE_32
    mov     rbx, [rsp]
    and     bl, 00001000b
    shr     bl, 3
    add     al, bl
    or      BYTE [rsi + id_opcode], al
    or      BYTE [rsi + id_lm_encode], RM
    mov     al, RM
    jmp     disass_next_instr_test
disass_next_instr_jcc:
    mov     BYTE [rsi + id_opcode], JCC | SIZE_32
    or      BYTE [rsi + id_lm_encode], D
    mov     al, D
disass_next_instr_test:
    test    al, al
    jnz     test_MR
    mov     al, 0
    jmp     end_disass_next_instr
test_MR:
    mov     rdx, [rsp]
    inc     rdi
    cmp     al, MR
    jne     test_RM
    call    _disass_MR
    jmp     end_disass_next_instr
test_RM:
    cmp     al, RM
    jne     test_MI
    call    _disass_RM
    jmp     end_disass_next_instr
test_MI:
    cmp     al, MI
    jne     test_OI
    mov     cl, BYTE [rsi + id_opcode]
    and     cl, 11b
    mov     rax, [rsp + 0x8]
    test    al, al
    jz      test_MI_disass
    mov     cl, SIZE_16
test_MI_disass:
    call    _disass_MI
    jmp     end_disass_next_instr
test_OI:
    cmp     al, RI
    jne     test_O
    dec     rdi
    mov     cl, BYTE [rsi + id_opcode]
    and     cl, 11b
    mov     rax, [rsp + 0x8]
    test    al, al
    jz      test_OI_disass
    mov     cl, SIZE_16
test_OI_disass:
    call    _disass_OI
    jmp     end_disass_next_instr
test_O:
    cmp     al, O
    jne     test_I
    dec     rdi
    call    _disass_O
    jmp     end_disass_next_instr
test_I:
    cmp     al, I
    jne     test_M
    mov     dl, BYTE [rsi + id_opcode]
    and     dl, 11b
    call    _disass_I
    jmp     end_disass_next_instr
test_M:
    cmp     al, M
    jne     test_D
    call    _disass_M
    jmp     end_disass_next_instr
test_D:
    cmp     al, D
    jne     test_AI
    mov     dl, BYTE [rsi + id_opcode]
    and     dl, 11b
    call    _disass_D
    jmp     end_disass_next_instr
test_AI:
    cmp     al, AI
    jne     test_MI8
    mov     dl, BYTE [rsi + id_opcode]
    and     dl, 11b
    mov     rax, [rsp + 0x8]
    test    al, al
    jz      test_AI_disass
    mov     dl, SIZE_16
test_AI_disass:
    call    _disass_AI
    jmp     end_disass_next_instr
test_MI8:
    cmp     al, MI8
    jne     test_M1
    mov     cl, BYTE [rsi + id_opcode]
    and     cl, 11b
    mov     rax, [rsp + 0x8]
    test    al, al
    jz      test_MI8_disass
    mov     cl, SIZE_16
test_MI8_disass:
    call    _disass_MI8
    jmp     end_disass_next_instr
test_M1:
    cmp     al, M1
    jne     end_disass_next_instr
    mov     cl, BYTE [rsi + id_opcode]
    and     cl, 11b
    mov     rax, [rsp + 0x8]
    test    al, al
    jz      test_M1_disass
    mov     cl, SIZE_16
test_M1_disass:
    call    _disass_M1
    jmp     end_disass_next_instr
end_disass_next_instr:
    test    r8, r8
    jz      instr_not_extended
    call    _disass_instr_extend_opcode
instr_not_extended:
    mov     rbx, [rsp + 0x8]
    test    bl, bl
    jz      disass_next_instr_return_handle_REX
    mov     dl, BYTE [rsi + id_opcode]
    and     dl, 11111100b
    or      dl, SIZE_16
    mov     BYTE [rsi + id_opcode], dl
    inc     rax
disass_next_instr_return_handle_REX:
    mov     rbx, [rsp]
    shr     rbx, 6 ; bit 0x40 is 1 if there is a REX, 0 otherwise
    inc     rax ; opcode
    add     rax, r9 ; double opcode
    add     rax, rbx ; REX
    mov     bl, al
    xor     rax, rax
    mov     al, bl
    leave
    ret

; returns a bool indicating if instr needs label handling
; rsi: disassembled instr
;
; returns: 0 if no, 1 if yes
_instr_with_label:
    lea     rbx, [rel label_instr]
instr_with_label_loop:
    mov     al, BYTE [rbx]
    mov     dl, BYTE [rsi + id_opcode]
    and     dl, 11111100b
    cmp     dl, al
    je      instr_with_label_ret
    test    al, al
    jz      instr_with_label_ret
    inc     rbx
    jmp     instr_with_label_loop
instr_with_label_ret:
    ret

; gets the offset of the memory operand structure
; rsi: disassembled instruction
;
; returns: the offset
_get_disassembled_instr_memory_offset:
    xor     rbx, rbx
    mov     bl, [rsi + id_lm_encode]
    and     bl, 1111b
    mov     al, [rel memory_offset_tab + rbx]
    ret

; returns a bool indicating if the label has already been disassembled
; rdi: label's rip
;
; returns: 1 if label is already disassembled, 0 otherwise
_is_known_label:
    mov     rdx, [rel label_table]
    xor     al, al
is_known_label_loop:
    mov     rbx, [rdx + label_rip]
    test    rbx, rbx
    jz      is_known_label_not_found
    cmp     rbx, rdi
    je      is_known_label_found
    add     rdx, LABEL_ENTRY_SIZE
    jmp     is_known_label_loop
is_known_label_found:
    inc     al
is_known_label_not_found:
    ret

; checks if label is not known but points on an already disassembled instruction
; rdi: label's rip
;
; returns: instruction list element pointer, NULL otherwise
_is_disassembled_label:
    mov     rax, [rel instr_list]
is_disassembled_label_loop:
    mov     rdx, [rax + id_rip]
    cmp     rdx, rdi
    je      is_disassembled_label_ret
    test    rdx, rdx
    jz      is_disassembled_label_ret_not_found
    add     rax, ID_SIZE
    jmp     is_disassembled_label_loop
is_disassembled_label_ret_not_found:
    xor     rax, rax
is_disassembled_label_ret:
    ret

; add a new label to label_table
; rdi: label's rip
; rsi: label's disassembled instruction
;
; returns: void
_add_new_label:
    mov     rdx, [rel label_table]
add_new_label_loop:
    mov     rax, [rdx + label_rip]
    test    rax, rax
    jz      add_new_label_add
    cmp     rax, rdi
    je      add_new_label_ret
    add     rdx, LABEL_ENTRY_SIZE
    jmp     add_new_label_loop
add_new_label_add:
    mov     [rdx + label_rip], rdi
    mov     [rdx + label_elem], rsi
    or      BYTE [rsi + id_lm_encode], LABEL_MARK
add_new_label_ret:
    ret

; add a new label to future_label_table
; rdi: the label's rip
;
; returns: void
_add_new_future_label:
    mov     rdx, [rel future_label_table]
add_new_future_label_loop:
    mov     rax, [rdx]
    test    rax, rax
    jz      add_new_future_label_add
    cmp     rax, rdi
    je      add_new_future_label_ret
    add     rdx, 8
    jmp     add_new_future_label_loop
add_new_future_label_add:
    mov     [rdx], rdi
add_new_future_label_ret:
    ret

; procedure to handle labels
; rdi: rip
; rsi: current list element
;
; returns: void
_handle_label:
    call    _get_disassembled_instr_memory_offset
    cmp     BYTE [rsi + rax + mem_base], RIP
    jne     handle_label_ret
    mov     bl, [rsi + id_opcode]
    and     bl, 11b
    test    bl, bl
    jnz     handle_label_rel_32
    movsx   rbx, BYTE [rsi + rax + mem_disp]
    add     rdi, rbx 
    jmp     handle_label_check_if_known
handle_label_rel_32:
    add     edi, DWORD [rsi + rax + mem_disp]
handle_label_check_if_known:
    call    _is_known_label
    test    al, al
    jnz     handle_label_ret
    call    _is_disassembled_label
    test    rax, rax
    jz      handle_label_new_label
    mov     rsi, rax
    call    _add_new_label
    jmp     handle_label_ret
handle_label_new_label:
    call    _add_new_future_label
handle_label_ret:
    ret

; checks if the current node is a terminating one
; rsi: node
;
; returns: 0 if no, 1 if yes
_is_terminating_node:
    xor     al, al
    mov     cl, [rsi + id_opcode]
    and     cl, 11111100b
    mov     bl, [rsi + id_lm_encode]
    and     bl, 1111b
    cmp     cl, RET
    je      is_terminating_node_yes
    cmp     cl, JMP
    jne     is_terminating_node_no
    cmp     bl, D
    je      is_terminating_node_no
is_terminating_node_yes:
    inc     al
is_terminating_node_no:
    ret

; pops a future label from future label table
;
; returns: the address of the last future label, NULL if future label table is empty
_pop_future_label:
    mov     rbx, [rel future_label_table]
pop_future_label_loop:
    mov     rax, [rbx]
    mov     rdx, [rbx + 8]
    test    rdx, rdx
    jz      pop_future_label_table_end
    add     rbx, 8
    jmp     pop_future_label_loop
pop_future_label_table_end:
    mov     QWORD [rbx], 0
    ret

; creates the disassembled instruction list
; rdi: rip
;
; returns : void
_disass:
    push    rbp
    mov     rbp, rsp
    mov     rsi, [rel instr_list]
disass_loop:
;     push    rax
;     push    rcx
;     push    rdx
;     push    rdi
;     push    rsi
;     push    r8
;     push    r9
;     push    r10
;     push    r11
; %ifdef      DEBUG_TIME
;     mov     rdi, [instr_list]
;     call    _display_list
;     mov     rdi, [label_table]
;     call    _display_labels
;     mov     rdi, [future_label_table]
;     call    _display_future_labels
; %endif
;     pop     r11
;     pop     r10
;     pop     r9
;     pop     r8
;     pop     rsi
;     pop     rdi
;     pop     rdx
;     pop     rcx
;     pop     rax
    push    rdi
    call    _disass_next_instr
    pop     rdi
    add     rdi, rax
    push    rax
    call    _instr_with_label
    test    al, al
    jz      disass_loop_no_label
    push    rdi
    push    rsi
    call    _handle_label
    pop     rsi
    pop     rdi
disass_loop_no_label:
    call    _is_terminating_node
    test    al, al
    jz      disass_loop_next_instr
    push    rsi
disass_loop_future_label:
    call    _pop_future_label
    test    al, al
    jz      disass_loop_end
    mov     rdi, rax
    call    _is_disassembled_label
    test    al, al
    jz      disass_loop_new_label
    mov     rsi, rax
    call    _add_new_label
    jmp     disass_loop_future_label
disass_loop_new_label:
    pop     rsi
    add     rsi, ID_SIZE
    mov     BYTE [rsi + id_lm_encode], LABEL_MARK
    call    _add_new_label
    jmp     disass_loop
disass_loop_next_instr:
    pop     rax
    add     rsi, ID_SIZE
    jmp     disass_loop
disass_loop_end:
    leave
    ret

; assembles pseudo-code elements into real x86-64 bytecode
; rdi: list of pseudo-code elements
; rsi: where to put the code
;
; returns: void
_assemble_code:
    push    rbp
    mov     rbp, rsp
    leave
    ret

; initialize the internal prng state with a random seed
; 
; returns: void
_prng_init:
    call    prng_init_next_line
prng_init_next_line:
    pop     rdx
    mov     [rel prng_data], dl
    ret

; performs the lfsr on the prng_data byte (taps are 2, 3 and 5) 1 is put is the sum is odd
; rdi: number of output bytes (max 8)
;
; returns: the output bits
_lfsr_iter:
    xor     rax, rax
lfsr_iter_loop:
    shl     al, 1
    mov     dl, [rel prng_data]
    mov     cl, dl
    and     cl, 1
    or      al, cl  ; output byte
    shr     dl, 1
                    ; add taps
    xor     bl, bl
    mov     cl, dl
    shr     cl, 2
    and     cl, 1
    add     bl, cl
    mov     cl, dl
    shr     cl, 3
    and     cl, 1
    add     bl, cl
    mov     cl, dl
    shr     cl, 5
    and     cl, 1
    add     bl, cl
                    ; compute taps
    shl     bl, 7
    or      dl, bl
    mov     BYTE [rel prng_data], dl
    dec     dil
    test    dil, dil
    jnz     lfsr_iter_loop
    ret

; gets a pseudo-random number
; rdi: the range of number to get (from 0 to rdi - 1)
; 
; returns: the number generated
_get_prn:
    mov     dl, 8
get_prn_pow2_for_prn_loop:
    dec     dl
    mov     al, 1
    mov     cl, dl
get_prn_shl_loop:   ; since the only way to have a variable shl is to use cl and we want to avoid unnecessary 
                    ; register dependant instruction, we will loop the shl
    shl     al, 1
    dec     cl
    test    cl, cl
    jnz     get_prn_shl_loop
    test    al, dil
    jz      get_prn_pow2_for_prn_loop
    inc     dl   ; so that we have a greater number of bits than the number
    mov     rsi, rdi
    mov     dil, dl
    call    _lfsr_iter
    cmp     al, sil
    jl      get_prn_ret
    mov     rdi, rsi
    call    _get_prn
get_prn_ret:
    ret

_test_func:
    mov     dil, 2
    call    _get_prn
     mov     dil, 2
    call    _get_prn
     mov     dil, 2
    call    _get_prn
    mov     dil, 5
    call    _get_prn
    mov     dil, 5
    call    _get_prn
    mov     dil, 5
    call    _get_prn
    mov     dil, 8
    call    _get_prn
    mov     dil, 8
    call    _get_prn
    mov     dil, 8
    call    _get_prn
    mov     dil, 7
    call    _get_prn
    mov     dil, 7
    call    _get_prn
    mov     dil, 7
    call    _get_prn
    mov     dil, 4
    call    _get_prn
    mov     dil, 4
    call    _get_prn
    mov     dil, 4
    call    _get_prn
    mov     dil, 9
    call    _get_prn
    mov     dil, 9
    call    _get_prn
    mov     dil, 9
    call    _get_prn
    ret

_end:
    xor     rdi, rdi
    mov     eax, SYS_EXIT
    syscall
