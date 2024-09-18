#ifndef MOS_STRING_H
#define MOS_STRING_H
#include <mos/types.h>

char *strcpy(char *dest, const char *src);
char *strcat(char *dest, const char *src);
usize strlen(const char *s);
int strcmp(const char *s1, const char *s2);
char *strchr(const char *s, int ch);
char *strrchr(const char *s, int ch);
int memcmp(const void *lhs, const void *rhs, usize n);
void *memset(void *dest, int ch, usize n);
void *memsetw(void *dest, int w, usize n);
void *memcpy(void *dest, const void *src, usize n);
void *memchr(const void *s, int ch, usize n);
void *memrchr(const void *s, int ch, usize n);
#endif /* MOS_TYPES_H */