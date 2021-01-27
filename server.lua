local socket = require("socket")
local ip, port = ...

server = assert(socket.bind(ip, port))
client = server:accept()
-- client:settimeout(4)

love.thread.getChannel('server'):push(client)
