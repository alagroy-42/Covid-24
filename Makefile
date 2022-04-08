# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: alagroy- <alagroy-@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2022/02/09 14:49:38 by alagroy-          #+#    #+#              #
#    Updated: 2022/04/07 15:24:45 by alagroy-         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = Death

SRCS = death.s
OBJDIR = ./.objs/
SRCDIR = ./srcs/
OBJ_FILES = $(SRCS:.s=.o)
OBJS = $(addprefix $(OBJDIR), $(OBJ_FILES))
INCLUDES = ./srcs/defines.s ./srcs/instruction_set.s ./srcs/disassembler.s

all : $(OBJDIR) $(NAME)

$(NAME): $(OBJS)
	ld --omagic  -lc -o $@ $< # -e _start_first_time
	printf "\n\033[0;32m[$(NAME)] Linking [OK]\n\033[0;0m"

$(OBJDIR)%.o: $(SRCDIR)%.s $(INCLUDES) Makefile 
	nasm -i $(SRCDIR) -f elf64 -o $@ $<
	printf "\033[0;32m[$(NAME)] Compilation [$<]                 \r\033[0m"

$(OBJDIR):
	mkdir -p $@

test: $(OBJDIR)
	nasm -i $(SRCDIR) -D DEBUG_TIME -f elf64 -o ./.objs/death.o ./srcs/death.s
	gcc -c ./srcs/test_debug.c -o ./.objs/test_debug.o
	ld -dynamic-linker /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 -o Death -lc ./.objs/death.o ./.objs/test_debug.o # -e _start_first_time

clean:
	$(RM) -Rf $(OBJDIR)
	printf "\033[0;31m[$(NAME)] Clean [OK]\n"

fclean: clean
	$(RM) $(NAME)
	printf "\033[0;31m[$(NAME)] Fclean [OK]\n"

re: fclean all

.PHONY: clean re fclean all test
.SILENT: