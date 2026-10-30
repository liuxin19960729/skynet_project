# Coroutine
```lua
skynet 框架消息处理使用coroutine
不要在skynet 里面使用 coroutine API



请使用
skynet.fork
skynet.wait
skynet.wakeup

如果有其他原因使用coroutine 请使用 skynet.coroutine 模块的API
   

新增的API
col,bol= coroutine.thread(co)
col:
    返回根协程


bol:true 是由skynet.coroutine 创建管理的协程
bol:false 普通未被skynet 管理的协程



```