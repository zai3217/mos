
OBJECTS= build/boot/boot.bin build/boot/loader.bin build/kernel.bin \
build/system.bin build/system.map
CFLAGS= -m32 -Qn
CFLAGS+= -fno-builtin # disable gcc built-in functions
CFLAGS+= -nostdlib # disable standard library
CFLAGS+= -nostdinc # disable standard include files
CFLAGS+= -fno-pic # disable position-independent code
CFLAGS+= -fno-pie # disable position-independent executable
CFLAGS+= -fno-stack-protector # disable stack protector
CFLAGS:= $(strip $(CFLAGS)) # remove empty spaces

IFDEBUG=-g
INCLUDE=-Isrc/include

.PHONY: all
all: clean $(OBJECTS) build/master.img

.PHONY: clean
clean:
	rm -rf ./build 
	mkdir -p build/boot
	mkdir -p build/kernel
	mkdir -p build/lib

build/%.bin: src/%.asm
	nasm -f bin $< -o $@

build/%.o: src/%.asm
	nasm -f elf32 $(IFDEBUG) $< -o $@

build/%.o: src/%.c
	gcc $(CFLAGS) $(IFDEBUG) $(INCLUDE) -c $< -o $@

build/kernel.bin: build/kernel/start.o \
	build/kernel/main.o \
	build/kernel/io.o \
	build/lib/string.o \
	build/lib/console.o \

	ld -m elf_i386 -static $^ -o $@ -Ttext 0x10000

build/system.bin: build/kernel.bin
	objcopy -O binary $< $@

build/system.map: build/kernel.bin
	nm $< |	sort > $@

build/master.img: $(OBJECTS)
	yes | bximage -q -hd=16 -func=create -sectsize=512 -imgmode=flat build/master.img
	dd if=build/boot/boot.bin of=build/master.img bs=512 count=1 conv=notrunc
	dd if=build/boot/loader.bin of=build/master.img bs=512 count=4 seek=2 conv=notrunc
	dd if=build/system.bin of=build/master.img bs=512 count=200 seek=10 conv=notrunc

.PHONY: bochs
run: all
	cd src && bochs -q

.PHONY: bochsd
dbg: all
	cd src && bochs-gdb -q -f bochsrc.gdb

.PHONY: qemu
qemu: all
	qemu-system-i386 \
		-m 32M\
		-boot c\
		-hda build/master.img\

.PHONY: qemud
qemud: all
	qemu-system-i386 \
		-s -S\
		-m 32M\
		-boot c\
		-hda build/master.img\

build/master.vmdk: build/master.img
	qemu-img convert -O vmdk $< $@
.PHONY: vmdk
vmdk: build/master.vmdk
    

# .PHONY: usb
# usb: all /dev/sda
# 	sudo dd if=/dev/sda of=tmp.bin bs=512 count=1 conv=notrunc
# 	cp tmp.bin usb.bin
# 	sudo rm tmp.bin
# 	dd if=build/boot/boot.bin of=usb.bin bs=446 count=1 conv=notrunc
# 	sudo dd if=usb.bin of=/dev/sda bs=512 count=1 conv=notrunc
# 	rm usb.bin