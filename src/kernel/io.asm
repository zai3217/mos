[bits 32]

section .text; 代码段

global inb
inb: ; 从端口读取一个字节
    push ebp ; 保存ebp
    mov ebp, esp
    xor eax, eax ; 置eax为0
    mov edx, [ebp+8] ; port
    in al, dx          ; 读取状态
    jmp $+2
    jmp $+2
    jmp $+2
    leave              ; 弹出 ebp
    ret

global inw
inw: ; 从端口读取一个字
    push ebp ; 保存ebp
    mov ebp, esp
    xor eax, eax ; 置eax为0
    mov edx, [ebp+8] ; port
    in ax, dx          ; 读取状态
    jmp $+2
    jmp $+2
    jmp $+2
    leave              ; 弹出 ebp
    ret

global outb
outb: ; 向端口输出一个字节
    push ebp ; 保存ebp
    mov ebp, esp
    mov edx, [ebp+8] ; port
    mov al, [ebp+12] ; value
    out dx, al        ; 输出状态
    jmp $+2
    jmp $+2
    jmp $+2
    leave              ; 弹出 ebp
    ret

global outw
outw: ; 向端口输出一个字
    push ebp ; 保存ebp
    mov ebp, esp
    mov edx, [ebp+8] ; port
    mov ax, [ebp+12] ; value
    out dx, ax        ; 输出状态
    jmp $+2
    jmp $+2
    jmp $+2
    leave              ; 弹出 ebp
    ret
