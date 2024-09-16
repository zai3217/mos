#include <mos/types.h>
#include <mos/mos.h>
#include <mos/io.h>
void cursor_down(u16 n)
{
    u16 pos = get_cursor_pos();
    cursor_mv_to(pos + n * 80);
}
void cursor_up(u16 n)
{
    u16 pos = get_cursor_pos();
    cursor_mv_to(pos - n * 80);
}
void cursor_left(u16 n)
{
    u16 pos = get_cursor_pos();
    cursor_mv_to(pos - n);
}
void cursor_right(u16 n)
{
    u16 pos = get_cursor_pos();
    cursor_mv_to(pos + n);
}
void cursor_home()
{
    u16 pos = get_cursor_pos();
    cursor_mv_to(pos - (pos % 80));
}
void cursor_end()
{
    u16 pos = get_cursor_pos();
    cursor_mv_to(pos - (pos % 80) + 79);
}
void cursor_entry()
{
    u16 pos = get_cursor_pos();
    cursor_mv_to(pos - (pos % 80) + 80);
}

u16 get_cursor_pos()
{
    outb(0x3d4, 0x0e);
    u16 pos = inb(0x3d5) << 8;
    outb(0x3d4, 0x0f);
    pos |= inb(0x3d5); // 获取光标位置
    return pos;
};
void cursor_mv_to(u16 pos)
{
    outb(0x3d4, 0x0e);
    outb(0x3d5, pos >> 8);
    outb(0x3d4, 0x0f);
    outb(0x3d5, pos); // 移动光标到左上角
}