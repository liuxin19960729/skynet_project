local skynet = require "skynet"
local socket = require "skynet.socket"



local function connect(cfd, addr)
    print("addr:" .. addr)

    -- cfd 只有在socket.start 之后才能接受数据
    -- skynet 是通过 socket.start(cfd) 该函数知道 接收的socket 函数那个服务接收
    socket.start(cfd)

    while true do
        local data = socket.read(cfd)

        if data ~= nil then
            print("rcv:" .. data)
            socket.write(cfd, "rev:"..data)
        else
            print(cfd .. "close")
            socket.close(cfd)
        end
    end
end

skynet.start(function()
    print("app/main.lua skynet.start")
    local listenFd = socket.listen("0.0.0.0", 8888, 2)

    -- 新accept 计入进来都会调用 connect
    socket.start(listenFd, connect)
end)
