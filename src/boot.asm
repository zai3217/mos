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

mov si, booting
call print

mov edi, 0x1000; 读目标地址
mov ecx, 2; 起始扇区号
mov bl, 4; 读入扇区数
call read_disk

cmp word [0x1000], 0x55aa ; 检查是否是有效的引导扇区
jnz error ; 若不是, 则报错并死机

jmp 0:0x1002

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

    inc dx; 0x1f4
    shr ecx, 8
    mov al, cl; 起始扇区中八位
    out dx, al

    inc dx; 0x1f5
    shr ecx, 8
    mov al, cl; 起始扇区高八位
    out dx, al

    inc dx; 0x1f6
    shr ecx, 8
    and cl, 0b1111
    mov al, 0b1110_0000; 主盘LBA模式
    or al, cl
    out dx, al

    inc dx; 0x1f7
    mov al,0x20; 读硬盘
    out dx, al

    xor ecx, ecx; 清空ecx
    mov cl, bl; 扇区数

    .read
        push cx ; 保存扇区数
        call .waits; 等待磁盘准备好
        call .reads; 读入一个扇区
        pop cx ; 恢复扇区数
        loop .read
    ret

    .waits:
        mov dx, 0x1f7
        .check:
            in al, dx
            jmp $+2
            jmp $+2
            jmp $+2
            and al, 0b1000_1000
            cmp al, 0b0000_1000
            jnz .check ; 等待磁盘准备好
        ret
    
    .reads:
        mov dx, 0x1f0; 读取
        mov cx, 256; 读256个word
        .readw:
            in ax, dx
            jmp $+2
            jmp $+2
            jmp $+2
            mov [edi], ax ; 保存到目标地址
            add edi, 2 ; 
            loop .readw
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

error:
    mov si, .msg
    call print
    hlt ; 死机
    jmp $ ; 死循环
    .msg db "Err: Booting failed.",10,13, 0

; 填充为512字节 
times 510-($-$$) db 0
; 照顾bios
db 0x55, 0xaa