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
    inc dword [ards_count]; ards计数器+1
    cmp ebx, 0 ; 是否检测完毕
    jnz .next ; 继续检测

    mov si, detecting_ok ; 显示检测结束
    call print ; 调用显示函数

    jmp prepare_protect_mode ; 准备进入保护模式


prepare_protect_mode:
    ; 准备进入保护模式
    ; 1. 关闭中断

    cli ; 关闭中断

    ; 打开A20
    in al, 0x92
    or al, 0b10
    out 0x92, al ; 打开A20

    ; 加载gdt
    lgdt [gdt_ptr]

    ; 进入保护模式
    mov eax, cr0 ; 保存cr0
    or eax, 1 ; 打开保护模式    
    mov cr0, eax ; 加载cr0

    jmp dword code_selector:protect_mode ; 跳转来刷新缓存, 进入保护模式

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

[bits 32]
protect_mode:
    mov ax, data_selector ; 选择数据段
    mov ds, ax 
    mov es, ax 
    mov fs, ax 
    mov gs, ax 
    mov ss, ax ; 初始化段寄存器
    mov esp, 0x10000 ; 栈指针
    ; 读硬盘
    mov edi, 0x10000
    mov ecx, 10 ; 起始扇区
    mov bl, 200 ; 扇区数
    call read_disk ; 读硬盘
    jmp dword code_selector:0x10000 ; 跳转到内核入口
    ud2 ; 未知错误


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


code_selector equ (1<<3)
data_selector equ (2<<3)

memory_base equ 0; 基地址

; 内存界限 (4g / 4k) - 1
memory_limit equ ((1024 * 1024 * 1024 * 4) / (1024 * 4)) - 1
gdt_ptr:
    dw gdt_end - gdt_base - 1 ; 界限
    dd gdt_base ; 基地址
gdt_base:
    dd 0, 0 ; 空段
gdt_code:
    dw memory_limit & 0xffff ; 代码段界限
    dw memory_base & 0xffff
    db (memory_base >> 16) & 0xff ; 代码段基址
    db 0b1_00_1_1_0_1_0 ; 存在 - dlp0 - S_代码 - 非依存 - 可读 - 未被访问过
    db 0b1_1_0_0_0000 | (memory_limit >> 16) & 0xf 
    db (memory_base >> 24) & 0xff ; 代码段基址
gdt_data:
    dw memory_limit & 0xffff ; 代码段界限
    dw memory_base & 0xffff
    db (memory_base >> 16) & 0xff ; 代码段基址
    db 0b1_00_1_0_0_1_0 ; 存在 - dlp0 - S_数据 - 向上 - 可写 - 未被访问过
    db 0b1_1_0_0_0000 | (memory_limit >> 16) & 0xf 
    db (memory_base >> 24) & 0xff ; 代码段基址
gdt_end:

ards_count:
    dd 0 ; ards计数器
ards_buffer: