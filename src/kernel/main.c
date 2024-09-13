#include <mos/mos.h>

int magic = MOS_MAGIC;
char message[] = "hello mos!!!"; // .data
char buf[1024];

void kernel_init(){
    clear_screen();
    char* video = (char*)0xb8000; // video memory address
    for (int i = 0; i < sizeof(message); i++)
    {
        video[i * 2] = message[i]; // write message to video memory   
    }
}

void clear_screen()
{
    char *video = (char *)0xb8000; // video memory address
    for (int i = 0; i < 80 * 25; i++)
    {
        video[i * 2] = 0; // clear screen
    }
}