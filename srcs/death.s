BITS 64

%include "defines.s"
%include "instruction_set.s"
%include "disassembler.s"

section .data
    hello: db "Hello World !", 10, 0
        .len: equ $ - hello
    code_len: dd _end - say_hello
    instr_list: dq 0
    label_table: dq 0
    future_label_table: dq 0
    opcode_extension: db 0
    label_instr: db CALL, JMP, JCC, 0

section .text
    global _start
    extern _display_list
    extern _display_labels
    extern _display_future_labels

_start:
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

    lea     rdi, [rel say_hello]
    mov     esi, [rel code_len]
    call    _disass
%ifdef      DEBUG_TIME
    mov     rdi, [instr_list]
    call    _display_list
    mov     rdi, [label_table]
    call    _display_labels
    mov     rdi, [future_label_table]
    call    _display_future_labels
%endif
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
    movzx   eax, BYTE [rdi + 1]
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
    movzx   rax, al
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
    movzx   edx, BYTE [rdi + 1]
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
    mov     rax, rbx ; operands
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
    mov     rdx, rsi
    add     rsi, idmi_mem
    lea     rdx, [rel opcode_extension]
    call    _read_ModRM_byte
    mov     rbx, rax
    pop     rsi
    pop     rcx
    pop     rdi
disass_MI_store_imm:
    test    cl, cl
    jnz     disass_MI_read_imm_32
    movzx   rax, BYTE [rdi + rbx]
    mov     QWORD [rsi + idmi_imm], rax
    mov     al, 1
    jmp     disass_MI_end
disass_MI_read_imm_32:
    cmp     cl, SIZE_32
    jnz     disass_MI_read_imm_64
    mov     eax, DWORD [rdi + rbx]
    mov     QWORD [rsi + idmi_imm], rax
    mov     al, 4
    jmp     disass_MI_end
disass_MI_read_imm_64:
    and     BYTE [rsi + id_opcode], 11111100b | SIZE_64
    mov     rax, QWORD [rdi + rbx]
    mov     QWORD [rsi + idmi_imm], rax
    mov     al, 8
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
    jnz     disass_OI_read_imm_32
    movzx   rax, BYTE [rdi + 1]
    mov     QWORD [rsi + idri_imm], rax
    mov     al, 1
    jmp     disass_OI_end
disass_OI_read_imm_32:
    cmp     cl, SIZE_32
    jnz     disass_OI_read_imm_64
    mov     eax, DWORD [rdi + 1]
    mov     QWORD [rsi + idri_imm], rax
    mov     al, 4
    jmp     disass_OI_end
disass_OI_read_imm_64:
    and     BYTE [rsi + id_opcode], 11111100b | SIZE_64
    mov     rax, QWORD [rdi + 1]
    mov     QWORD [rsi + idri_imm], rax
    mov     al, 8
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
    cmp     dl, SIZE_32
    jne     _disass_I_imm_64
    mov     ebx, DWORD [rdi]
    mov     al, 4
    jmp     _disass_I_store_imm
_disass_I_imm_64:
    mov     rbx, QWORD [rdi]
    mov     al, 8
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
    mov     rcx, rdx
    mov     rdx, rsi
    add     rsi, idm_mem
    lea     rdx, [rel opcode_extension]
    call    _read_ModRM_byte
    sub     rsi, idm_mem
    leave
    ret

; disassemble a D encoded instruction
; rdi: rip
; rsi: current list element
; rdx: size
;
; returns: operands size
_disass_D:
    mov     BYTE [rsi + id_lm_encode], M
    mov     BYTE [rsi + idm_mem + mem_base], RIP
    mov     BYTE [rsi + idm_mem + mem_sindex], NOREG
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
    mov     DWORD [rsi + idm_mem + mem_disp], ebx
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
    jne     disass_instr_extend_opcode_next_opcode
    cmp     cl, 6
    je      disass_instr_extend_opcode_end
    cmp     cl, 2
    jne     disass_instr_extend_opcode_test_push_4
    mov     BYTE [rsi + id_opcode], CALL
    mov     bl, SIZE_64
    or      BYTE [rsi + id_opcode], bl
    jmp     disass_instr_extend_opcode_end
disass_instr_extend_opcode_test_push_4:
    cmp     cl, 4
    jne     disass_instr_extend_opcode_end
    mov     BYTE [rsi + id_opcode], JMP
    mov     bl, SIZE_64
    or      BYTE [rsi + id_opcode], bl
    jmp     disass_instr_extend_opcode_end
    
disass_instr_extend_opcode_next_opcode:
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
    movzx   rax, BYTE [rdi]
    mov     bl, al
    and     bl, 11110000b
    cmp     bl, REX
    jne     continue_disass_next_instr
    mov     [rsp], rax
    inc     rdi
    movzx   rax, BYTE [rdi]
continue_disass_next_instr:
    push    rdi
    mov     rdi, rax
    call    _get_instr
    mov     BYTE [rsi + id_opcode], al
    call    _is_instr_reg_extended
    mov     r8, rax
    call    _get_instr_size
    mov     rbx, [rsp + 0x8]
    and     rbx, REXW
    cmp     rbx, REXW
    jne     disass_next_instr_store_size
    mov     al, SIZE_64
disass_next_instr_store_size:
    or      BYTE [rsi + id_opcode], al
    call    _get_instr_encoding
    or      BYTE [rsi + id_lm_encode], al
    pop     rdi
    test    al, al
    jnz     test_MR
    inc     al
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
    call    _disass_MI
    jmp     end_disass_next_instr
test_OI:
    cmp     al, RI
    jne     test_O
    dec     rdi
    mov     cl, BYTE [rsi + id_opcode]
    and     cl, 11b
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
    jne     end_disass_next_instr
    mov     dl, BYTE [rsi + id_opcode]
    and     dl, 11b
    call    _disass_D
    jmp     end_disass_next_instr
end_disass_next_instr:
    test    r8, r8
    jz      instr_not_extended
    call    _disass_instr_extend_opcode
instr_not_extended:
    mov     rbx, [rsp]
    shr     rbx, 6 ; bit 0x40 is 1 if there is a REX, 0 otherwise
    inc     rax ; opcode
    add     rax, rbx ; REX
    movzx   rax, al
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
    add     rdx, LABEL_ENTRY_SIZE
    jmp     add_new_label_loop
add_new_label_add:
    mov     [rdx + label_rip], rdi
    mov     [rdx + label_elem], rsi
    or      BYTE [rsi + id_lm_encode], LABEL_MARK
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
    add     rdx, 8
    jmp     add_new_future_label_loop
add_new_future_label_add:
    mov     [rdx], rdi
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
    add     dil, [rsi + rax + mem_disp]
    jmp     handle_label_check_if_known
handle_label_rel_32:
    add     edi, [rsi + rax + mem_disp]
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
    

; creates the disassembled instruction list
; rdi: rip
; rsi: len
;
; returns : void
_disass:
    mov     rcx, rsi
    mov     rsi, [rel instr_list]
disass_loop:
    push    rcx
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
    pop     rax
    add     rsi, ID_SIZE
    pop     rcx
    sub     rcx, rax
    cmp     rcx, 0
    jg      disass_loop
    ret


say_hello:
    push    QWORD [rel hello]
    push    QWORD [hello]
    push    QWORD [rsi]
say_hello_test_label:
    call    say_hello
    jmp     _end
    push    QWORD [rdi + rbx * 8 + 0x1234]
    push    QWORD [rsp + 0x1234]
    ret

_end:
    xor     rdi, rdi
    mov     eax, SYS_EXIT
    syscall
