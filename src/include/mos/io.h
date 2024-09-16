#ifndef MOS_IO_H
#define MOS_IO_H
#include <mos/types.h>

extern u8 inb(u16 port);
extern u16 inw(u16 port);

extern void outb(u16 port, u8 value);
extern void outw(u16 port, u16 value);

#endif