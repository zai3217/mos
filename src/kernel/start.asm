[bits 32]

global _start
_start:
    ; 加载内核
    call clear
    mov byte [0xb8000], 'K'; 表示进入内核
    mov byte [0xb8002], 'e'; 显示颜色为白色
    mov byte [0xb8004], 'r';
    mov byte [0xb8006], 'n';
    mov byte [0xb8008], 'e';
    mov byte [0xb800a], 'l';
    jmp $ ; 阻塞

clear:
    ; 清屏
    mov eax, 0x00000000 ; 黑色背景
    mov edi, 0xb8000 ; 显示缓冲区
    mov ecx, 200 ; 屏幕大小
    rep stosb ; 填充0
    ret ; 结束

    