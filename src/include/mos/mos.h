#ifndef MOS_H
#define MOS_H
#include <mos/types.h>
#define MOS_VERSION 0.1.0
#define MOS_MAGIC 20240911
void kernel_init(); // initialize the kernel
void clear_screen(); // clear the screen
void clear_after_cursor(); // clear the screen after the cursor
u16 get_cursor_pos();
void cursor_down(u16 n);
void cursor_up(u16 n);
void cursor_right(u16 n);
void cursor_left(u16 n);
void cursor_home();
void cursor_end();
void cursor_entry();
void cursor_mv_to(u16 pos);
void print(char *str, u16 len);
void println(char *str, u16 len);
// void int_to_string(int num, char *str);
#endif