SOURCES = $(shell find cpu drivers include kernel libc -name '*.c')
HEADERS = $(shell find cpu drivers include kernel libc -name '*.h')
OBJ = ${SOURCES:.c=.o cpu/interrupt.o}

ASM = nasm
CC = gcc
LD = ld
CFLAGS = -ffreestanding -Wall -Wextra -fno-exceptions -march=i386 -m32 -std=c11 -fno-pic

ifeq ($(shell uname -s),Darwin)
	CC = i386-elf-gcc
	LD = i386-elf-ld
endif

all: os-image.bin

run: all
	qemu-system-i386 -fda os-image.bin

clean:
	rm -rf *.bin *.dis *.o os-image.bin *.elf
	rm -rf kernel/*.o boot/*.bin drivers/*.o boot/*.o cpu/*.o libc/*.o

os-image.bin: boot/boot.bin kernel/kernel.bin
	cat $^ > os-image.bin

boot/boot.bin: boot/boot.asm
	${ASM} $< -f bin -o $@

kernel/kernel.bin: boot/kernel_entry.o ${OBJ}
	${LD} -o $@ -Ttext 0x1000 $^ --oformat binary -m elf_i386

%.o: %.c ${HEADERS}
	${CC} ${CFLAGS} -c $< -o $@

%.o: %.asm
	${ASM} $< -f elf -o $@

%.bin: %.asm
	${ASM} $< -f bin -o $@
