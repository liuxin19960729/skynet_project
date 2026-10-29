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

## c调用lua方法
```c


1.需要将执行的Lua 函数压入栈
    
    int lua_getglobal (lua_State *L, const char *name);
    返回 全局变量 名为name的类型
    键全局变量名为name的全局函数压入栈

    [func]


    note:如果要使用 lua_pcall 执行并且需要一个c函数捕获错误
    例如
        static int
            traceback (lua_State *L) {
                const char *msg = lua_tostring(L, 1);
                if (msg)
                    luaL_traceback(L, L, msg, 1);
                else {
                    lua_pushliteral(L, "(no error message)");
                }
                return 1;
            }
        
        可以将 lua_pushcfunction(state,traceback) 推入到栈在执行将全局函数推入到栈  lua_getglobal(state,name)


        [func,traceback]
2.  
  lua 函数需要几个参数将参数以此推入栈
    [....arg2,arg1,func,traceback]
    

3.

void lua_call (lua_State *L, int nargs, int nresults);

int lua_pcall (lua_State *L, int nargs, int nresults, int msgh);


通过下面两个函数中的一个执行Lua函数


nargs:压入参数个数
nresults:返回值个数

note:
   1.lua_call or lua_pcall 执行完所有值都出栈,在压入返回值
返回的值从栈底到栈顶依次 1,2,3...
   2.lua_pcall 是保护模式执行
   msgh 为 0 返回的错误信息回在所有值弹出栈的时候将信息压入栈
    通过 lua_tostring 或 lua_tolstring 拿取信息
   
   msgh 可以设置栈上的处理函数的索引
        [....arg2,arg1,func,traceback]

        该处理的函数索引为 -1 或 1都可以



int lua_pcall (lua_State *L, int nargs, int nresults, int msgh);

返回时

lua.h
LUA_OK (0): 成功。
LUA_ERRRUN: 运行时错误。
LUA_ERRMEM: 内存分配错误。对于这种错，Lua 不会调用错误处理函数。
LUA_ERRERR: 在运行错误处理函数时发生的错误。
LUA_ERRGCMM: 在运行 __gc 元方法时发生的错误。 （这个错误和被调用的函数无关。

```

## lua调用c
```c
1.需要将c语言的函数注册到虚拟机
typedef struct luaL_Reg {
  const char *name;
  lua_CFunction func;
} luaL_Reg;

typedef int (*lua_CFunction) (lua_State *L);

2.执行进入c语言函数通过某些方法获取参数和设置对应的返回值就可以了
   ntoe: 进入到c语言函数式新的栈 如果我们要给返回对应函数将参数压入对应的栈就可以了


int lua_gettop (lua_State *L);
返回收到 lua 调用传入参数的个数


void lua_settop (lua_State *L, int index);
  设置参数个数 
  note:设置为0 会将栈上所有参数移除
  如果设置的栈顶比原来的大 则使用nil填新元素


int lua_isstring (lua_State *L, int index);
    当给定索引的值是一个字符串或是一个数字 （数字总能转换成字符串）时，返回 1 ，否则返回 0 。
```


## API

### 注册c函数到lua
```c

static const luaL_Reg l[] = {
    {函数名称,函数指针}
    ....
    { NULL, NULL }, //note:{NULL,NULL} 表示结束符号
};




void lua_setglobal (lua_State *L, const char *name);
从栈顶弹出一个值将其设置为全局变量为name 的新值

void luaL_newlib (lua_State *L, const luaL_Reg l[]);
创建一个张新表压入栈顶把表l中的函数注册进去



void lua_createtable (lua_State *L, int narr, int nrec);
    1.通过c代理创建一个lua table
    2.narr ,nrec 数组索引部分 和map key 部分预留多少个位置存储内容
    3.将table 压入栈顶
void luaL_setfuncs (lua_State *L, const luaL_Reg *l, int nup);

    将一组c函数注册到栈顶上的表中
    nup:为每个绑定的c函数绑定upvalue 值
      upvalue 设置 
      1.将对应的值压入栈顶
      2.luaL_setfuncs(L,arr,1) 
         设置了upvalue 之后 upvalue 弹出 note:此时table仍然在栈中


      使用的时候
          lua_upvalueindex(1) 获取到对应的upvalue的值






    lua_createtable(L,0,数组中函数数量) 
    luaL_setfuncs(L,arr,0)



void lua_newtable (lua_State *L);
    创建一张空表，并将其压栈。 它等价于 lua_createtable(L, 0, 0) 。

```

### 判断栈上某个元素的类型
```c
int lua_isboolean (lua_State *L, int index);
当给定索引的值是一个布尔量时，返回 1 ，否则返回 0 。

int lua_iscfunction (lua_State *L, int index);
当给定索引的值是一个 C 函数时，返回 1 ，否则返回 0 。


int lua_isfunction (lua_State *L, int index);
当给定索引的值是一个函数（ C 或 Lua 函数均可）时，返回 1 ，否则返回 0 

int lua_isinteger (lua_State *L, int index);
当给定索引的值是一个整数 （其值是一个数字，且内部以整数储存）， 时，返回 1 ，否则返回 0 。


int lua_islightuserdata (lua_State *L, int index);
当给定索引的值是一个轻量用户数据时，返回 1 ，否则返回 0 。

int lua_isuserdata (lua_State *L, int index);
当给定索引的值是一个用户数据（无论是完全的还是轻量的）时， 返回 1 ，否则返回 0 

int lua_isnil (lua_State *L, int index);
当给定索引的值是 nil 时，返回 1 ，否则返回 0 。

int lua_isnone (lua_State *L, int index);
当给定索引无效时，返回 1 ，否则返回 0 。

int lua_isstring (lua_State *L, int index);
当给定索引的值是一个字符串或是一个数字 （数字总能转换成字符串）时，返回 1 ，否则返回 0 。

int lua_istable (lua_State *L, int index);
当给定索引的值是一张表时，返回 1 ，否则返回 0 。


int lua_isthread (lua_State *L, int index);
当给定索引的值是一条线程时，返回 1 ，否则返回 0 。


```

### 判断函数参数类型
```c
lua_Integer luaL_checkinteger (lua_State *L, int arg);
检查函数的第 arg 个参数是否是一个 整数（或是可以被转换为一个整数） 并以 lua_Integer 类型返回这个整数值。


const char *luaL_checklstring (lua_State *L, int arg, size_t *l);

检查函数的第 arg 个参数是否是一个 字符串，并返回该字符串； 如果 l 不为 NULL ， 将字符串的长度填入 *l。
note: l 传入 指针 可以获取字符串长度 

lua_Number luaL_checknumber (lua_State *L, int arg);
检查函数的第 arg 个参数是否是一个 数字，并返回这个数字。



int luaL_checkoption (lua_State *L,
                      int arg,
                      const char *def,
                      const char *const lst[]);

arg 第几个参数
def  默认选项；如果传入 NULL，表示不使用默认选项

lst 自发货串选项列表 一 NULL 结尾


返回值
   如果参数不在 lst 里面 将抛出错误
   def 设置 了 如果参数设置为nil 则使用 def 值

    返回值是lst 里面的索引号


void luaL_checkstack (lua_State *L, int sz, const char *msg);

用于检测栈空间是否足够 并在必要的时候尝试扩展栈空间


sz:需要额外预留栈空间数量
   例如 设置为 10 表示确保至少有10个栈曹

栈空间不足时用于错误提示的描述文字；可以是 NULL


    int lua_checkstack (lua_State *L, int n);
    返回栈还有几个空位 返回 0表示没有空位


const char *luaL_checkstring (lua_State *L, int arg);
  检查函数的第 arg 个参数是否是一个 字符串并返回这个字符串。

const char *lua_tolstring (lua_State *L, int index, size_t *len);

    lua 值必须是一个string 或 数字 否则返回 NULL


void luaL_checktype (lua_State *L, int arg, int t);

检查第arg 参数什么类型 t 传入对应的类型


 LUA_TNIL， LUA_TNUMBER， LUA_TBOOLEAN， LUA_TSTRING， LUA_TTABLE， LUA_TFUNCTION， LUA_TUSERDATA， LUA_TTHREAD， LUA_TLIGHTUSERDATA。



void luaL_checkversion (lua_State *L);
检查调用它的内核是否是创建这个 Lua 状态机的内核。 以及调用它的代码是否使用了相同的 Lua 版本。 同时也检查调用它的内核与创建该 Lua 状态机的内核 是否使用了同一片地址空间。
```

