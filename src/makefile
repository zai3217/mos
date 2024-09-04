ASPARMAS= -f bin
OBJECTS= boot.bin loader.bin

all: $(OBJECTS) master.img

.PHONY: clean
clean:
	rm -f $(OBJECTS)

%.bin: %.asm
	nasm $(ASPARMAS) $< -o $@

master.img: $(OBJECTS)
	yes | bximage -q -hd=16 -func=create -sectsize=512 -imgmode=flat master.img
	dd if=boot.bin of=master.img bs=512 count=1 conv=notrunc
	dd if=loader.bin of=master.img bs=512 count=4 seek=2 conv=notrunc

.PHONY: run
run: all
	bochs -q

.PHONY: usb
usb: all /dev/sda
	sudo dd if=/dev/sda of=tmp.bin bs=512 count=1 conv=notrunc
	cp tmp.bin usb.bin
	sudo rm tmp.bin
	dd if=boot.bin of=usb.bin bs=446 count=1 conv=notrunc
	sudo dd if=usb.bin of=/dev/sda bs=512 count=1 conv=notrunc
	rm usb.bin