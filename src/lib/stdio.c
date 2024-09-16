#include <mos/types.h>
#include <mos/mos.h>
void print(char *s, u16 len)
{
    u16 pos = get_cursor_pos();              // 获取光标位置
    char *video = (char *)0xb8000 + pos * 2; // video memory address
    for (int i = 0; i < len; i++)
    {
        video[i * 2] = s[i];
    }
    pos += len; // 计算光标位置
    cursor_mv_to(pos);
    return;
}

void println(char *s, u16 len)
{
    print(s, len);
    u16 pos = get_cursor_pos();
    if (pos % 80)
    {
        cursor_entry(); // 光标移到下一行
    }
}