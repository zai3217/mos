#include <mos/mos.h>
#include <mos/types.h>
#include <mos/io.h>
#include <mos/string.h>

char buf[1024];
char msg[] = "Hello, world!";
void kernel_init()
{
    cursor_mv_to(0);
    clear_after_cursor();
    int res;
    res = strcmp(buf, msg);
    strcpy(buf, msg);
    res = strcmp(buf, msg);
    strcat(buf, msg);
    res = strcmp(buf, msg);
}

void clear_after_cursor(){
    u16 pos = get_cursor_pos();
    char *video = (char *)0xb8000; // video memory address
    for (int i = pos; i < 80 * 25; i++)
    {
        video[i * 2] = 0; // clear screen
    }
}