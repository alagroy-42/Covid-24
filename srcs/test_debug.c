/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   test_debug.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: alagroy- <alagroy-@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2022/04/06 15:18:14 by alagroy-          #+#    #+#             */
/*   Updated: 2022/04/13 02:18:07 by alagroy-         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <stdio.h>
#include <string.h>

typedef unsigned char   byte;

typedef struct              s_instruction_disass
{
    byte    opcode;
    byte    lm_encode;
    byte    padding[14];
    byte    *rip;
} __attribute__((packed))   t_instr;

typedef struct              memory_operand
{
    byte    base_reg;
    byte    sindex;
    int     disp;
} __attribute__((packed))   t_memop;

typedef struct              s_instruction_disass_rm
{
    byte    opcode;
    byte    lm_encode;
    byte    reg;
    t_memop memop;
    byte    padding[7];
    byte    *rip;
} __attribute__((packed))   t_instr_rm;

typedef struct              s_instruction_disass_rr
{
    byte    opcode;
    byte    lm_encode;
    byte    reg;
    byte    reg2;
    byte    padding[12];
    byte    *rip;
} __attribute__((packed))   t_instr_rr;

typedef struct              s_instruction_disass_mr
{
    byte    opcode;
    byte    lm_encode;
    t_memop memop;
    byte    reg;
    byte    padding[7];
    byte    *rip;
} __attribute__((packed))   t_instr_mr;

typedef struct              s_instruction_disass_ri
{
    byte    opcode;
    byte    lm_encode;
    byte    reg;
    byte    padding[5];
    long    imm;
    byte    *rip;
} __attribute__((packed))   t_instr_ri;

typedef struct              s_instruction_disass_mi
{
    byte    opcode;
    byte    lm_encode;
    t_memop memop;
    long    imm;
    byte    *rip;
} __attribute__((packed))   t_instr_mi;

typedef struct              s_instruction_disass_m
{
    byte    opcode;
    byte    lm_encode;
    t_memop memop;
    long    pad;
    byte    *rip;
} __attribute__((packed))   t_instr_m;

typedef struct              s_instruction_disass_i
{
    byte    opcode;
    byte    lm_encode;
    byte    padding[6];
    long    imm;
    byte    *rip;
} __attribute__((packed))   t_instr_i;

typedef struct              s_instruction_disass_o
{
    byte    opcode;
    byte    lm_encode;
    byte    reg;
    byte    padding[13];
    byte    *rip;
} __attribute__((packed))   t_instr_o;

static void     get_opcode(char *opcode, byte op_value)
{
    op_value &= 0b11111100;
    if (op_value == 0xc0)
        strcpy(opcode, "RET");
    else if (op_value == 0x80)
        strcpy(opcode, "LEA");
    else if (op_value == 0xb0)
        strcpy(opcode, "MOV");
    else if (op_value == 0x50)
        strcpy(opcode, "PUSH");
    else if (op_value == 0x58)
        strcpy(opcode, "POP");
    else
        strcpy(opcode, "NOP");
}

static void     get_register(byte reg, int size, char *buf)
{
    switch (reg)
    {
        case 0:
            strcpy(buf, " ax");
            break;
        case 1:
            strcpy(buf, " cx");
            break;
        case 2:
            strcpy(buf, " dx");
            break;
        case 3:
            strcpy(buf, " bx");
            break;
        case 4:
            strcpy(buf, " sp");
            break;
        case 5:
            strcpy(buf, " bp");
            break;
        case 6:
            strcpy(buf, " si");
            break;
        case 7:
            strcpy(buf, " di");
            break;
        case 8:
            strcpy(buf, " 8");
            break;
        case 9:
            strcpy(buf, " 9");
            break;
        case 10:
            strcpy(buf, " 10");
            break;
        case 11:
            strcpy(buf, " 11");
            break;
        case 12:
            strcpy(buf, " 12");
            break;
        case 13:
            strcpy(buf, " 13");
            break;
        case 14:
            strcpy(buf, " 14");
            break;
        case 15:
            strcpy(buf, " 15");
            break;
        case 16:
            strcpy(buf, " ip");
            break;
        case 31:
            strcpy(buf, "NOR");
            break;
        default:
            strcpy(buf, "000");
            break;
    }
    switch (size)
    {
        case 8:
            buf[2] = 'l';
            break;
        case 16:
            break;
        case 32:
            buf[0] = 'e';
            break;
        default:
            buf[0] = 'r';
            break;
    }
}

static void     get_mem(t_memop memop, int size, char *buf)
{
    char    reg_base[10];
    char    reg_index[10];
    int     scale;

    get_register(memop.base_reg, size, reg_base);
    get_register(memop.sindex & 0b11111, size, reg_index);
    scale = memop.sindex >> 6;
    if (!scale)
        scale = 1;
    else if (scale == 1)
        scale = 2;
    else if (scale == 2)
        scale = 4;
    else
        scale = 8;
    sprintf(buf, "[%s + %s * %u + %#0x]", reg_base, reg_index, scale, memop.disp);
}

static void     display_instr(t_instr *instr)
{
    char        opcode[10];
    char        reg[10];
    char        reg2[10];
    char        mem[30];
    int         size;
    int         encoding;
    
    size = instr->opcode & 0b11;
    encoding = instr->lm_encode;
    if (!size)
        size = 8;
    else if (size == 1)
        size = 16;
    else if (size == 2)
        size = 32;
    else
        size = 64;
    get_opcode(opcode, instr->opcode);
    printf("Instruction at %p: opcode: %s, operand_size: %d\n", instr->rip, opcode, size);
    if (encoding == 0)
        return ;
    else if (encoding == 1) // RM
    {
        get_register(((t_instr_rm *)instr)->reg, size, reg);
        get_mem(((t_instr_rm *)instr)->memop, size, mem);
        printf("\toperands: %s, %s\n", reg, mem);
    }
    else if (encoding == 2) // MR
    {
        get_register(((t_instr_mr *)instr)->reg, size, reg);
        get_mem(((t_instr_mr *)instr)->memop, size, mem);
        printf("\toperands: %s, %s\n", mem, reg);
    }
    else if (encoding == 3) // MI
    {
        get_mem(((t_instr_mi *)instr)->memop, size, mem);
        printf("\toperands: %s, %#0lx\n", mem, ((t_instr_mi *)instr)->imm);
    }
    else if (encoding == 4) // OI
    {
        get_register(((t_instr_ri *)instr)->reg, size, reg);
        printf("\toperands: %s, %#0lx\n", reg, ((t_instr_ri *)instr)->imm);
    }
    else if (encoding == 5) // RR
    {
        get_register(((t_instr_rr *)instr)->reg, size, reg);
        get_register(((t_instr_rr *)instr)->reg2, size, reg2);
        printf("\toperands: %s, %s\n", reg, reg2);
    }
    else if (encoding == 6) // O
    {
        get_register(((t_instr_o *)instr)->reg, size, reg);
        printf("\toperands: %s\n", reg);
    }
    else if (encoding == 7) // I
    {
        printf("\toperands: %0#x\n", ((t_instr_i *)instr)->imm);
    }
    else if (encoding == 8) // M
    {
        get_mem(((t_instr_m *)instr)->memop, size, mem);
        printf("\toperands: %s\n", mem);
    }
}

void        _display_list(t_instr *list)
{
    t_instr     *instr;

    instr = *(&list);
    while (instr->opcode)
    {
        display_instr(instr);
        instr++;
    }
}

