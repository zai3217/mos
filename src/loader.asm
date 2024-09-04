[org 0x1000]

dw 0x55aa ; magic number to wrong judgment

; 显示字符串
mov si, loading ; 字符串地址
call print ; 调用显示函数

; 检测内存
mov si, detecting ; 显示检测字符串
call print ; 调用显示函数
detect_mem:
    xor ebx, ebx ; ebx清零
    
    mov ax, 0 ; es:di指向ARDS返回区
    mov es, ax
    mov edi, ards_buffer

    mov edx, 0x534d4150 ; "SMAP"固定签名

.next:
    mov eax, 0xe820; ARDS 中断
    mov ecx, 20; "ARDS"结构体大小 固定长度

    int 0x15 ; 调用中断
    jc detecting_err ; 调用失败，显示错误信息

    add di, cx ; 指向下一个ARDS结构体
    inc word [ards_count]; ards计数器+1
    cmp ebx, 0 ; 是否检测完毕
    jnz .next ; 继续检测

    mov si, detecting_ok ; 显示检测结束
    call print ; 调用显示函数

    mov cx, [ards_count] ; ards计数器
    mov si, 0; ards指针
.show:
    mov eax, [si + ards_buffer]
    mov ebx, [si + ards_buffer + 8]
    mov edx, [si + ards_buffer + 16]
    add si, 20
    xchg bx, bx
    loop .show

; 阻塞
jmp $ ; 死循环



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

loading:
db "Loading Mos...", 10, 13, 0;\n \r
detecting:
db "Detecting A.R.D.S....", 10, 13, 0;\n \r

detecting_ok:
db "Detecting A.R.D.S. Success.", 10, 13, 0;\n \r

loading_err:
mov si, .msg
call print
jmp hlts
.msg db "Err: Loading failed.",10,13, 0
detecting_err:
mov si, .msg
call print
jmp hlts
.msg db "Err: Detecting failed.",10,13, 0

hlts:
    hlt ; 死机
    jmp $ ; 死循环


ards_count:
    db 0 ; ards计数器
ards_buffer: