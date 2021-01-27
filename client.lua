local socket = require("socket")
local ip, port = ...
local clientChannel = love.thread.getChannel ( 'client' );

client = socket.connect(ip, port)
-- client:settimeout(4)
clientChannel:push({cmd="noop"})


while(true) do
	socket.sleep(0.01)
	msg = clientChannel:pop()
	-- print(":::")
	-- print(msg)
	if msg then 
		if msg.cmd == "rx" then
			line,err = client:receive()
			clientChannel:push({cmd = "rx", data=line, error=error})
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
