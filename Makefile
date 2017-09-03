
all:start.o led.o sdram.o clock.o nand.o uart.o main.o
	arm-linux-ld -Tgboot.lds -o gboot.elf $^
	arm-linux-objcopy -O binary gboot.elf gboot.bin
	arm-linux-objdump -Dz -S gboot.elf > gboot.dump
%.o : %.S
	arm-linux-gcc -g -c  $^

%.o : %.c
	arm-linux-gcc -g -c  $^ -fno-builtin

clean:
	rm *.o *.elf *.bin *.dump

