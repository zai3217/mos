[org 0x7c00]
; 设置屏幕为文本模式,并清屏
mov ax, 3
int 0x10
; 初始化段寄存器(不然可能出现问题)
mov ax, 0
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00

xchg bx, bx ; 空操作

mov si, booting
call print

mov edi, 0x0100; 读目标地址
mov ecx, 0; 起始扇区号
mov bl, 1; 读入扇区数

call read_disk

;阻塞
jmp $

read_disk:
    ; 设置读写扇区号
    mov dx, 0x1f2
    mov al, bl
    out dx, al

    inc dx; 0x1f3
    mov al, cl; 起始扇区低八位
    out dx, al
    ret

    inc dx; 0x1f4
    mov al, cl; 起始扇区中八位
    out dx, al
    ret

    inc dx; 0x1f5
    mov al, cl; 起始扇区高八位
    out dx, al
    ret
print:
    mov ah, 0x0e ; 选择显示字符
.next:
    mov al, [si] ; 读出字符
    cmp al, 0 ; 遇到结束符
    jz .done
    int 0x10 ; 显示字符
    inc si ; 指向下一个字符
    jmp .next
.done:
    ret

booting:
db "Booting Mos...", 10, 13, 0;\n \r

; 填充为512字节 
times 510-($-$$) db 0
; 照顾bios
db 0x55, 0xaa