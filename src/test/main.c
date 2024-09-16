#include <stdio.h>
void int_to_str(int num, char *str){
    int isNegative = 0;
    if (num < 0){
        isNegative = 1; // 标记为负数
        num = -num;     // 取绝对值
    }
    int i = 0;
    do{
        str[i++] = (num % 10) + '0'; // 提取最后一位并转换为字符
        num /= 10;                   // 去掉最后一位
    } while (num > 0);

    if (isNegative){
        str[i++] = '-'; // 如果是负数，添加负号
    };

    // 反转字符串
    for (int j = 0; j < i / 2; j++){
        char temp = str[j];
        str[j] = str[i - j - 1];
        str[i - j - 1] = temp;
    }
}
int main(){
    int n = -2123221231;
    char str[11];
    int_to_str(n, str);
    printf("%s\n", str);
}