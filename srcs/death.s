BITS 64

%include "defines.s"
%include "instruction_set.s"
%include "disassembler.s"

section .data
    hello: db "Hello World !", 10, 0
        .len: equ $ - hello
    code_len: dd _end - say_hello
    instr_list: dq 0

section .text
    global _start

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
    mov     [instr_list], rax

    lea     rdi, [rel say_hello]
    mov     esi, [rel code_len]
    call    _disass
    jmp     _end

; translates assembly opcode to pseudo assembly opcode
; rdi: opcode in dil
; 
; returns: encoding of instruction
_get_instr_encoding:
    mov     al, BYTE [instruction_set0x00 + edi * ISE_SIZE + ise_encoding]
    ret

; translates assembly opcode to pseudo assembly opcode
; rdi: opcode in dil
; 
; returns: pseudo assembly opcode value 
_get_instr:
    mov     al, BYTE [instruction_set0x00 + edi * ISE_SIZE + ise_opcode]
    ret

; gets the operand size for a given opcode
; rdi: opcode in dil
; 
; returns: the size of the operands
_get_instr_size:
    mov     al, BYTE [instruction_set0x00 + edi * ISE_SIZE + ise_size]
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
    shl     cl, 2
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
    shl     cl, 4
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
    test    al, 100b
    jnz     read_SIB_byte_modz_sp
    mov     al, BYTE [rdi]
    and     al, 111b
    cmp     al, 101b
    je      read_SIB_byte_modz_nsp_bp
    call    _read_SIB_byte_store_base
    call    _read_SIB_byte_store_sindex
    mov     al, 1
    jmp     read_SIB_byte_ret
read_SIB_byte_modz_nsp_bp:
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
    call    _read_SIB_byte_store_disp_32
    mov     al, 5
    jmp     read_SIB_byte_ret
read_SIB_byte_modnz:
    call    _read_SIB_byte_store_base
    mov     al, BYTE [rdi]
    and     al, 111000b
    shr     al, 3
    test    al, 100b
    jnz     read_SIB_byte_modz_sp
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

; disassemble operands of instruction using when op1 = modRM/mem and op2 = modRM/reg
; rdi: rip
; rsi: curr list elem
; rdx: rex
;
; returns : whole instruction size
_disass_MR:
    push    rsi
    mov     rsi, rdx
    call    _read_ModRM_reg
    pop     rsi
    mov     BYTE [rsi + idmr_reg], al
    push    rsi
    mov     rsi, rdx
    call    _read_ModRM_rm
    pop     rsi
    mov     BYTE [rsi + idmr_mem + mem_base], al
    movzx   rax, al
    mov     rbx, rax
    call    _read_ModRM_mod
    mov     al, BYTE [rel ModRM_tab + rax * MODRM_ENTSIZE + rbx]
    push    rax
    cmp     rax, MODRM_REL_32
    jne     disass_MR_handle_SIB
    mov     BYTE [rsi + idmr_mem + mem_base], RIP
    mov     BYTE [rsi + idmr_mem + mem_sindex], 0
    mov     edx, DWORD [rdi + 1]
    mov     DWORD [rsi + idmr_mem + mem_disp], edx
    mov     rbx, 5
    jmp     disass_MR_return_bytes_nb
disass_MR_handle_SIB:
    mov     dl, al
    and     dl, 11110000b
    cmp     dl, SIB
    jne     disass_MR_handle_RM
    inc     rdi
    add     rsi, 2
    mov     dl, al
    mov     rcx, QWORD [rsp]
    call    _read_SIB_byte
    mov     bl, al
    sub     rsi, 2
    jmp     disass_MR_return_bytes_nb
disass_MR_handle_RM:
    xor     dl, dl
    mov     BYTE [rsi + idmr_mem + mem_sindex], dl
    and     al, 1111b
    cmp     al, DISP8
    jne     disass_MR_handle_RM_handle_disp_32
    movzx   edx, BYTE [rdi + 1]
    jmp     disass_MR_handle_RM_store_disp
disass_MR_handle_RM_handle_disp_32:
    mov     edx, DWORD [rdi + 1]
    mov     bl, 5
disass_MR_handle_RM_store_disp:
    mov     DWORD [rsi + idmr_mem + mem_disp], edx
    mov     bl, 2
disass_MR_return_bytes_nb:
    mov     rax, rbx ; operands
    ret

; disassemble operands of instruction using when op1 = modRM/reg and op2 = modRM/mem
; rdi: rip
; rsi: curr list elem
; rdx: rex
;
; returns : whole instruction size
_disass_RM:
    push    rsi
    mov     rsi, rdx
    call    _read_ModRM_reg
    pop     rsi
    mov     BYTE [rsi + idrm_reg], al
    push    rsi
    mov     rsi, rdx
    call    _read_ModRM_rm
    pop     rsi
    mov     BYTE [rsi + idrm_mem + mem_base], al
    movzx   rax, al
    mov     rbx, rax
    call    _read_ModRM_mod
    mov     al, BYTE [rel ModRM_tab + rax * MODRM_ENTSIZE + rbx]
    push    rax
    cmp     rax, MODRM_REL_32
    jne     disass_RM_handle_SIB
    mov     BYTE [rsi + idrm_mem + mem_base], RIP
    mov     BYTE [rsi + idrm_mem + mem_sindex], 0
    mov     edx, DWORD [rdi + 1]
    mov     DWORD [rsi + idrm_mem + mem_disp], edx
    mov     rbx, 5
    jmp     disass_RM_return_bytes_nb
disass_RM_handle_SIB:
    mov     dl, al
    and     dl, 11110000b
    cmp     dl, SIB
    jne     disass_RM_handle_RM
    inc     rdi
    add     rsi, 2
    mov     dl, al
    mov     rcx, QWORD [rsp]
    call    _read_SIB_byte
    mov     bl, al
    sub     rsi, 2
    jmp     disass_RM_return_bytes_nb
disass_RM_handle_RM:
    xor     dl, dl
    mov     BYTE [rsi + idrm_mem + mem_sindex], dl
    and     al, 1111b
    cmp     al, DISP8
    jne     disass_RM_handle_RM_handle_disp_32
    movzx   edx, BYTE [rdi + 1]
    jmp     disass_RM_handle_RM_store_disp
disass_RM_handle_RM_handle_disp_32:
    mov     edx, DWORD [rdi + 1]
    mov     bl, 5
disass_RM_handle_RM_store_disp:
    mov     DWORD [rsi + idrm_mem + mem_disp], edx
    mov     bl, 2
disass_RM_return_bytes_nb:
    mov     rax, rbx ; operands
    ret

; disassemble operands of instruction using when op1 = opcode and op2 = imm
; rdi: rip
; rsi: curr list elem
; rdx: rex
;
; returns : whole instruction size
_disass_MI:
    ret

; disassemble operands of instruction using when op1 = opcode and op2 = imm
; rdi: rip
; rsi: curr list elem
; rdx: rex
; cl: size
;
; returns : whole instruction size
_disass_OI:
    mov     al, BYTE [rdi]
    and     al, 111b
    mov     bl, dl
    and     bl, 1000b
    or      al, bl
    mov     BYTE [rsi + idri_reg], al
    test    cl, cl
    jnz     disass_OI_read_imm_32
    movzx   rax, BYTE [rdi + 1]
    mov     QWORD [rsi + idri_imm], rax
    mov     al, 1
    jmp     disass_OI_end
disass_OI_read_imm_32:
    mov     al, dl
    and     al, REXW
    test    al, al
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

; disassemble the next instruction
; rdi: current rip
; rsi: current list elem
;
; returns : instruction length
_disass_next_instr:
    push    rbp
    mov     rbp, rsp
    mov     [rsi + id_rip], rsi
    push    QWORD 0
    movzx   rax, BYTE [rdi]
    test    al, REX
    jz      continue_disass_next_instr
    mov     [rsp], rax
    inc     rdi
    movzx   rax, BYTE [rdi]
continue_disass_next_instr:
    mov     rdi, rax
    call    _get_instr
    mov     BYTE [rsi + id_opcode], al
    call    _get_instr_size
    and     BYTE [rsi + id_opcode], al
    call    _get_instr_encoding
    or      BYTE [rsi + id_lm_encode], al
    test    al, al
    jnz     test_MR
    inc     al
    jmp     end_disass_next_instr
test_MR:
    pop     rdx
    inc     rdi
    cmp     al, MR
    jne     test_RM
    call    _disass_MR
test_RM:
    cmp     al, RM
    jne     test_MI
    call    _disass_RM
test_MI:
    cmp     al, MI
    jne     test_OI
    call    _get_instr_size
    mov     cl, al
    call    _disass_MI
test_OI:
    cmp     al, OI
    jne     end_disass_next_instr
    dec     rdi
    call    _get_instr_size
    mov     cl, al
    call    _disass_OI
end_disass_next_instr:
    mov     rbx, [rsp]
    shr     rbx, 6 ; bit 0x40 is 1 if there is a REX, 0 otherwise
    inc     rax ; opcode
    add     rax, rbx ; REX
    leave
    ret

; creates the disassembled instruction list
; rdi: rip
; rsi: len
;
; returns : void
_disass:
    mov     rcx, rsi
    lea     rsi, [rel instr_list]
disass_loop:
    push    rcx
    push    rdi
    call    _disass_next_instr
    pop     rdi
    add     rdi, rax
    pop     rcx
    sub     rcx, rax
    test    rcx, rcx
    jle     disass_loop
    ret

say_hello:
    mov     rdi, 0
    lea     rsi, [rel hello]
    mov     rdx, hello.len
    mov     eax, 0x12345678
    mov     rax, 0x123456781234
    mov     al, SYS_WRITE
    ret

_end:
    xor     rdi, rdi
    mov     eax, SYS_EXIT
    syscall
