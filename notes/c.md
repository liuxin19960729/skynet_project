# c
## stdlib.h
```c
long strtol(const char *restrict str, char **restrict endptr, int base);


str:\0结尾的字符串
endptr:
    1.不需要此信息传入NULL
    2.传入 *char 地址 将第一个不等你转换字符地址传入此信息

base:
    进制基数 一般使用 10 

例如:
#include <stdlib.h>
#include <stdio.h>

int main()
{
    char *str = "99";
    long num = strtol(str, NULL, 10);// 字符串转化为long
    printf("num:%ld\n",num);// 99
}

```
## pthread.h
```c
#include <pthread.h>

int pthread_key_create(pthread_key_t *key, void (*destructor)(void *));

它解决的问题是：在多线程程序中，让同一个全局变量或静态变量在不同线程里拥有各自独立的值。


创建一个全局唯一标识符，所有线程共享这个键




destructor:可选析构函数
    NULL 线程退出时不会自动清理数据
    函数指针 线程退出 系统调用这个析构函数  并将该值作为参数传入，用于释放内存等清理工作

初始值：键创建后，当前所有活动线程以及未来新创建的线程，与该键关联的初始值都是 NULL


return
  成功返回0

    EAGAIN：键的数量超过了系统限制（PTHREAD_KEYS_MAX）。

    ENOMEM：内存不足。



配套使用的函数

pthread_setspecific(key, value)

pthread_getspecific(key)



#include <pthread.h>

// 控制变量，必须静态初始化
pthread_once_t once_control = PTHREAD_ONCE_INIT;

// 首次调用执行 init_routine，后续调用直接返回
int pthread_once(pthread_once_t *once_control, void (*init_routine)(void));


pthread_once 返回时 确保 init_routine 一定执行完


```
