#ifndef MOS_TYPES_H
#define MOS_TYPES_H

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;
typedef char i8;
typedef short i16;
typedef int i32;
typedef long long i64;
typedef float f32;
typedef double f64;

#define EOF -1 // end of file
#define NULL 0 // null pointer
#define bool _Bool // boolean type
#define true 1 // true value
#define false 0 // false value

#define _packed __attribute__((packed)) // packed attribute

#endif