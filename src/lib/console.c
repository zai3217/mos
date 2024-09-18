#include <mos/types.h>
#include <mos/io.h>
#include <mos/console.h>
#include <mos/string.h>

// #define CRT_ADDR_REG 0x3D4 // CRT(6845)索引寄存器
// #define CRT_DATA_REG 0x3D5 // CRT(6845)数据寄存器

// #define CRT_START_ADDR_H 0xC // 显示内存起始位置 - 高位
// #define CRT_START_ADDR_L 0xD // 显示内存起始位置 - 低位
// #define CRT_CURSOR_H 0xE     // 光标位置 - 高位
// #define CRT_CURSOR_L 0xF     // 光标位置 - 低位

// #define MEM_BASE 0xB8000              // 显卡内存起始位置
#define MEM_SIZE 0x4000               // 显卡内存大小
// #define MEM_END (MEM_BASE + MEM_SIZE) // 显卡内存结束位置
// #define WIDTH 80                      // 屏幕文本列数
// #define HEIGHT 25                     // 屏幕文本行数
// #define ROW_SIZE (WIDTH * 2)          // 每行字节数
// #define SCR_SIZE (ROW_SIZE * HEIGHT)  // 屏幕字节数

// #define NUL 0x00
// #define ENQ 0x05
// #define ESC 0x1B // ESC
// #define BEL 0x07 // \a
// #define BS 0x08  // \b
// #define HT 0x09  // \t
// #define LF 0x0A  // \n
// #define VT 0x0B  // \v
// #define FF 0x0C  // \f
// #define CR 0x0D  // \r
// #define DEL 0x7F


u16 scr_pos; // 屏幕位置
u16 cur_pos; // 光标位置

static void get_scr_pos(){
    outb(0x3d4, 0xc); // 开始地址高位
    scr_pos = inb(0x3d5) << 8; // 开始地址高位
    outb(0x3d4, 0xd); // 开始地址低位
    scr_pos |= inb(0x3d5);    // 开始地址低位
}

static void set_scr_pos(){
    outb(0x3d4, 0xc);  // 开始地址高位
    outb(0x3d5, scr_pos >> 8);
    outb(0x3d4, 0xd);  // 开始地址低位
    outb(0x3d5, scr_pos);
}

static void get_cur_pos(){
    outb(0x3d4, 0xe);
    u16 cur_pos = inb(0x3d5) << 8;
    outb(0x3d4, 0xf);
    cur_pos |= inb(0x3d5); // 获取光标位置
};

static void set_cur_pos(){
    outb(0x3d4, 0xe); // 开始地址高位
    outb(0x3d5, cur_pos >> 8);
    outb(0x3d4, 0xf); // 开始地址低位
    outb(0x3d5, cur_pos);
}

static void cp_end_start(){
    for (u16 i = 0 ; i < 160 * 25; i+=2){
        *(char *)(0xb8000 + i) = *(char *)(0xb8000 + MEM_SIZE - 4000 + i);
        }
}

void console_init(){
    scr_pos = 0; // 屏幕位置
    set_scr_pos(); // 设置屏幕位置
    cur_pos = 0; // 光标位置
    set_cur_pos(); // 设置光标位置
    // 清屏
    cp_end_start(); // 复制显示内存到开始位置

}

void cur_mv(i32 pos)
{
    if (pos >= MEM_SIZE / 2){
        cur_pos = 24*80 + (pos % MEM_SIZE / 2); // 超过总大小，移动到最后一行
    }
    set_cur_pos();
}

void scr_mv(i32 pos){
    if (pos >= 8192 - 25*80)
    {
        scr_pos = pos % 8192; // 超过总大小减去一屏幕，移动到开始位置
    }
    set_scr_pos();
}

void cur_up(u16 n){
    cur_mv(cur_pos + n * 80);
}

void scr_up(u16 n){
    scr_mv(scr_pos - n * 80);
}

void cur_down(u16 n){
    cur_mv(cur_pos + n * 80);
}

void scr_down(u16 n){
    scr_mv(scr_pos + n * 80);
}

void cur_left(u16 n){
    cur_mv(cur_pos - n);
}

void scr_left(u16 n){
    scr_mv(scr_pos + n);
}

void cur_right(u16 n){
    cur_mv(cur_pos + n);
}

void scr_right(u16 n){
    scr_mv(scr_pos - n);
}

void cur_home(){
    cur_mv(cur_pos - cur_pos % 80);
}

void scr_home(){
    scr_mv(scr_pos - scr_pos % 80);
}

void cur_enter(){
    cur_mv(cur_pos + 80 - cur_pos % 80);
    if (cur_pos - scr_pos >= 24*80)
    {
        scr_down(1);
    } 
}

void scr_enter(){
    scr_mv(scr_pos - scr_pos % 80 + 79);
}

// 在指定位置打印字符串
void write_pos(char *s, u16 pos, char style){
    char *p = (char *)(pos * 2 + 0xb8000); // video memory address
    while (1)
    {
        if (*s == '\0')
            break;
        *p = (u16)*s++ | style<<8; // 写入字符串和样式
        p+=2; // 指向下一个位置
    }
}

// 在指定位置打印字符
void write_pos_ch(char ch, u16 pos, char style)
{
    char *p = (char *)(pos * 2 + 0xb8000); // video memory address
    *p = (u16)ch | style << 8; // 写入字符串和样   
}

// 在当前位置打印字符串
void write(char *s, char style){
    write_pos(s, cur_pos, style);
}

// 在当前位置打印字符
void write_ch(char ch, char style)
{
    write_pos_ch(ch, cur_pos, style);
}

void writeln(char *s, char style){
    write(s, style);
    if (cur_pos % 80 || !strlen(s))
    {
        cur_enter(); // 光标移到下一行
    }
}

// 在当前位置格式化打印字符串
void print(char *s){
    char ch;
    while (1){
        ch = *s++;
        if (ch == '\0')
            break;
        switch (ch){
            case 0x00: // NUL
                goto end;
            case 0x05: // ENQ
                break;
            case 0x1B: // ESC
                break;
            case 0x07: // BEL \a
                // 响铃
                // todo
                break;
            case 0x08: // BS \b
                // 光标左移并清除字符(如果不为开头)
                if (cur_pos_x){
                    cur_pos--;
                    write_pos(" ", cur_pos, 7);
                }
                break;
            case 0x09: // HT \t
                break;
            case 0x0A: // LF \n
                if (cur_pos_x || *s == '\n')
                {
                    cur_enter(); // 光标移到下一行
                }
                break;
            case 0x0B: // VT \v
                break;
            case 0x0C: // FF \f
                scr_down(1); // 屏幕下移
                break;
            case 0x0D: // CR \r
                // 光标移到开头并清除字符
                cur_home();  // 光标移到开头
                break;
            case 0x7f: // DEL
                // 清除光标所在位置字符
                write_pos_ch(' ', cur_pos, 7);
                break;
            default:
                write_ch(ch, 7); // 写入字符和样式
                cur_pos++; // 光标右移
                break;
        }
    }
    end:
    set_cur_pos(); // 设置光标位置
}

void println(char *s)
{
    print(s);
    if (cur_pos_x || !*s)
    {
        cur_enter(); // 光标移到下一行
    }
}




