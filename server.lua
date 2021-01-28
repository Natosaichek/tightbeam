local socket = require("socket")
local ip, port = ...
local clientChannel = love.thread.getChannel ( 'client' );

local server = assert(socket.bind(ip, port))
-- server:settimeout(.5)
local client = nil
while not client do
	client = server:accept()
end
-- client:setoption("keepalive", true)
client:settimeout(10)
local ping,err = client:receive()
print("got ping:"..ping)
client:send("pong\n")
print("starting to wait for directives")
clientChannel:supply(true)

while(true) do
	local msg = clientChannel:demand()
	if msg then
		print(msg.cmd)
		if msg.cmd == "rx" then
			local line,err = client:receive()
			if err then 
				print("error:")
				print(err)
			end
			clientChannel:push({cmd = "rx", data=line, error=err})
		end
		if msg.cmd == "tx" then
			client:send(cmd.data)
			clientChannel:push({cmd = "tx"})
		end
		if msg.cmd == "noop" then
			clientChannel:push({cmd="noop"})
		end
		if msg.cmd == "die" then
			clientChannel:push(true)
			return true
		end
	end
end
