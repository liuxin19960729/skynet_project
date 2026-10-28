# lua
## 嵌入lua虚拟机
```
1.下载lua 源码
2.编译
    make linux
```
## 理解静态库
```
引入 lua.h 头文件 
    声明了虚拟机所需的数据结构和方法

编译器 预处理 编译 优化 汇编 链接
链接这一个步编译器会找到 liblua.a 链接 生成最终的可执行文件

```

## 最重要的结构
```c

note:
    cpp 环境 使用
    extern "C"{
        #include "lua.h"
        #include "lauxlib.h"
        #include "lualib.h"
    }



lua_State *luaL_newstate (void);
创建一个新的 Lua 状态机。 它以一个基于标准 C 的 realloc 函数实现的内存分配器 调用 lua_newstate 。 并把可打印一些出错信息到标准错误输出的 panic 函数（参见 §4.6） 设置好，用于处理致命错误
返回新的状态机。 如果内存分配失败，则返回 NULL



void luaL_openlibs (lua_State *L);
打开指定状态机中的所有 Lua 标准库。


int luaL_dofile (lua_State *L, const char *filename);
  加载并运行指定的文件。 它是用下列宏定义出来：

     (luaL_loadfile(L, filename) || lua_pcall(L, 0, LUA_MULTRET, 0))
如果没有错误，函数返回假； 有错则返回真。



void lua_close (lua_State *L);
  销毁Lua 虚拟机

```

## 调用Lua方法
```c



int lua_getglobal (lua_State *L, const char *name);
把全局变量 name 里的值压栈，返回该值的类型。



void lua_pushinteger (lua_State *L, lua_Integer n);
把值为 n 的整数压栈。


void lua_call (lua_State *L, int nargs, int nresults);
遵循协议
1.执行函数压入栈
2.第一个参数压入栈

nargs:压入栈的参数个数
    
note:函数调用完所有都出栈 这个时候返回值压入栈

nresults:返回值个数，函数返回值将按正序压栈（第一个返回值首先压栈）， 因此在调用结束后，最后一个返回值将被放在栈顶。


int lua_pcall (lua_State *L, int nargs, int nresults, int msgh);
以保护模式调用一个函数。

如果有错误发生的话， lua_pcall 会捕获它， 然后把唯一的值（错误消息）压栈，然后返回错误码。

msgh:
   如果 msgh 是 0 ， 返回在栈顶的错误消息就和原始错误消息完全一致。 否则， msgh 就被当成是 错误处理函数 在栈上的索引位置。 （在当前的实现里，这个索引不能是伪索引。） 在发生运行时错误时， 这个函数会被调用而参数就是错误消息。 错误处理函数的返回值将被 lua_pcall 作为错误消息返回在堆栈上。



const char *lua_tostring (lua_State *L, int index);
等价于调用 lua_tolstring ， 其参数 len 为 NULL 。
const char *lua_tolstring (lua_State *L, int index, size_t *len);
   字符串的长度会存在len中
 

 note:
    lua_pcall msgh 为 0 执行错误将 错误原因放入栈中


    lua_tostring(l,-1) 取出错误原因


```

## 直观理解Lua栈
```c

1.获取全局函数将函数压入栈
lua_getglobal(state,"onInit")

[onInit]


2.将正如压入栈
lua_pushinteger(state,0)
[0,onInit]


3.压入函数的参数
[0,onInit]


3.lua_pcall(state,1,0,0)
 函数调用功能完
 []

 如果函数出现错误
 ["error msgs..."]

```

## lua 调用c 函数
```c
int lua_gettop (lua_State *L);

返回栈顶元素的索引。 因为索引是从 1 开始编号的， 所以这个结果等于栈上的元素个数； 特别指出，0 表示栈为空。


int lua_isstring (lua_State *L, int index);
当给定索引的值是一个字符串或是一个数字 （数字总能转换成字符串）时，返回 1 ，否则返回 0 。



lua call c/c++ function
   被调用的方法会得到一个新的栈
   c/c++ 方法需要把返回的结果放入栈中


note:
  lua栈中存入的字符串是引用地址
  
  

lua_gettop 参数个数


note:
  栈顶->栈底  -1 ,-2  .....
  栈底 ->栈顶 1,2,3
```

## 还需要注册函数
```lua
void lua_setglobal (lua_State *L, const char *name);
从堆栈上弹出一个值，并将其设为全局变量 name 的新值。

void luaL_newlib (lua_State *L, const luaL_Reg l[]);
创建一张新的表，并把列表 l 中的函数注册进去。
```