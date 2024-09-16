#include <mos/types.h>
char* strcpy(char* dest,const char* src){
    char *p = dest;
    while (1){
        *p++ = *src;
        if (*src++ == '\0')
            return dest;
    }
}

char *strcat(char *dest, const char *src){
    char *p = dest;
    while (*p)
        p++;
    while (1){
        *p++ = *src;
        if (*src++ == '\0')
            return dest;
    }
}

usize strlen(const char *s){
    char *p = (char*)s;
    while (*p)
        p++;
    return p - s;
}

int strcmp(const char *s1, const char *s2){
    while (*s1 && *s2 && *s1 == *s2) {
        s1++;
        s2++;
    }
    return *s1 < *s2 ? -1 : *s1 > *s2;
}

char *strchr(const char *s, int ch){
    char* p = (char*)s;
    while (1){
        if (*p == ch)
            return p;
        if (*p++ == '\0')
            return (void*)0;
    }
}

char *strrchr(const char *s, int ch){
    char* p = (char*)s;
    char* last = (void*)0;
    while (1){
        if (*p == ch)
            last = p;
        if (*p++ == '\0')
            return last;
    }
}

int memcmp(const void *lhs, const void *rhs, usize n){
    char* p1 = (char*)lhs;
    char* p2 = (char*)rhs;
    while (n-- > 0 && *p1 == *p2){
        p1++;
        p2++;
    }
    return *p1 < *p2 ? -1 : *p1 > *p2;
}

void* memset(void *dest, int ch, usize n){
    char* p = dest;
    while (n--)
        *p++ = ch;
    return dest;
}

void* memcpy(void *dest, const void *src, usize n){
    char* p1 = dest;
    while (n--)
        *p1++ = *(char *)(src++);
    return dest;
}

void* memchr(const void *s, int ch, usize n){
    char* p = (char*)s;
    while (n--){
        if (*p == ch)
            return (void*)p;
        p++;
    }
}


