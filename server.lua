local socket = require("socket")
local ip, port = ...
local clientChannel = love.thread.getChannel ( 'client' );

local server = assert(socket.bind(ip, port))
local client = server:accept()
-- client:setoption("keepalive", true)
--client:settimeout(2)
local ping,err = client:receive()
print("got ping:"..ping)
client:send("pong\n")
clientChannel:supply(true)

while(true) do
	local msg = clientChannel:demand()
	if msg then
		-- print(msg.cmd)
		if msg.cmd == "rx" then
			local line,err = client:receive()
			if err then 
				print("error:")
				print(err)
			end
			-- print("linerx:")
			-- print(line)
			clientChannel:supply({cmd = "rx", data=line, error=err})
		end
		if msg.cmd == "tx" then
			-- print(msg.data)
			client:send(msg.data)
			clientChannel:supply({cmd = "tx"})
		end
		if msg.cmd == "noop" then
			clientChannel:supply({cmd="noop"})
		end
		if msg.cmd == "die" then
			clientChannel:supply(true)
			return true
		end
	end
end
