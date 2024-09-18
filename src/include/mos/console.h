#ifndef MOS_CONSOLE_H
#define MOS_CONSOLE_H
#include <mos/types.h>
#define scr_base ((u32)scr_pos * 2 + 0xb8000) // 屏幕内存位置
#define scr_end (scr_base + 80 * 25 * 2)      // 屏幕内存结束位置
#define cur_base ((u32)cur_pos * 2 + 0xb8000)   // 屏幕内存位置
#define cur_pos_x (cur_pos % 80)
#define cur_pos_y (cur_pos / 80)

extern u16 scr_pos; // 屏幕位置
extern u16 cur_pos;    // 光标位置

void console_init();       // initialize the console
void cur_mv(i32 pos);
void scr_mv(i32 pos);
void cur_up(i32 n);
void scr_up(i32 n);
void cur_down(i32 n);
void scr_down(i32 n);
void cur_left(i32 n);
void scr_left(i32 n);
void cur_right(i32 n);
void scr_right(i32 n);
void cur_home();
void scr_home();
void cur_enter();
void scr_enter();
void write_pos(char *str, u16 pos, char style);
void write_pos_ch(char ch, u16 pos, char style);
void write(char *str, char style);
void write_ch(char ch, char style);
void writeln(char *s, char style);
void print(char *str);
void println(char *str);
#endif