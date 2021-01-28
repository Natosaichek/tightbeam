local socket = require("socket")
local ip, port = ...
local clientChannel = love.thread.getChannel ( 'client' );

local client = socket.connect(ip, port)
-- client:setoption("keepalive", true)
-- client:settimeout(10)
client:send("ping\n")
local pong,err = client:receive()
print("rcvd:"..pong)
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
