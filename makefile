PWD=$$(pwd)
OBJECTS= build/boot/boot.bin build/boot/loader.bin build/kernel/kernel.bin \
build/system.bin build/system.map
CFLAGS=-m32
IFDEBUG=-g
INCLUDE=-Isrc/include

$(shell mkdir -p build/boot)
$(shell mkdir -p build/kernel)

.PHONY: all
all: $(OBJECTS) build/master.img

.PHONY: build
build: clean all

.PHONY: clean
clean:
	rm -rf ./build 

build/%.bin: src/%.asm
	nasm -f bin $< -o $@

build/kernel/%.o: src/kernel/%.asm
	nasm -f elf32 $(IFDEBUG) $< -o $@

build/kernel/%.o: src/kernel/%.c
	gcc $(CFLAGS) $(IFDEBUG) $(INCLUDE) -c $< -o $@

build/kernel/kernel.bin: build/kernel/start.o build/kernel/main.o
	ld -m elf_i386 -static $^ -o $@ -Ttext 0x10000

build/system.bin: build/kernel/kernel.bin
	objcopy -O binary $< $@

build/system.map: build/kernel/kernel.bin
	nm $< |	sort > $@

build/master.img: $(OBJECTS)
	yes | bximage -q -hd=16 -func=create -sectsize=512 -imgmode=flat build/master.img
	dd if=build/boot/boot.bin of=build/master.img bs=512 count=1 conv=notrunc
	dd if=build/boot/loader.bin of=build/master.img bs=512 count=4 seek=2 conv=notrunc
	dd if=build/system.bin of=build/master.img bs=512 count=200 seek=10 conv=notrunc

.PHONY: run
run: all
	cd src && bochs -q

.PHONY: usb
usb: all /dev/sda
	sudo dd if=/dev/sda of=tmp.bin bs=512 count=1 conv=notrunc
	cp tmp.bin usb.bin
	sudo rm tmp.bin
	dd if=build/boot/boot.bin of=usb.bin bs=446 count=1 conv=notrunc
	sudo dd if=usb.bin of=/dev/sda bs=512 count=1 conv=notrunc
	rm usb.bin