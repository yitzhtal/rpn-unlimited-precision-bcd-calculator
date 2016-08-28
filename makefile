CC		:=	gcc 
CC_FLAGS	:=	-m32
ASM		:=	nasm
ASM_FLAGS	:=	-f elf 



all: calc

calc:	
	$(ASM) $(ASM_FLAGS)  calc.s -o calc.o
	$(CC) $(CC_FLAGS) -Wall -g calc.o -o calc.bin

clean: 
	rm -f *.o calc