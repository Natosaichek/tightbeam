local socket = require("socket")
local ip, port = ...

client = socket.connect(ip, port)
-- client:settimeout(4)
love.thread.getChannel('client'):push(client)