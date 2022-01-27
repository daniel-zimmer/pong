build: bin pong.bin

clean:
	rm -rf bin pong

run: build
	qemu-system-x86_64 -drive format=raw,file="pong.bin",index=0,if=floppy, -m 128M

.PHONY: build clean run

##################################################

# creates bin directory if it does not exist
bin:
	mkdir -p bin

bin/boot.bin: src/boot.asm
	nasm $< -f bin -o $@

bin/kernel_entry.o: src/kernel_entry.asm
	nasm $< -f elf -o $@

bin/program.o: src/program.c
	i386-elf-gcc -ffreestanding -m32 -g -c $< -o $@

bin/program_with_entry: bin/kernel_entry.o bin/program.o
	i386-elf-ld -Ttext 0x1000 $^ --oformat binary -o $@

pong.bin: bin/boot.bin bin/program_with_entry src/zeroes.bin
	cat $^ > $@

