local socket = require("socket")
local ip = "localhost"
local port = 343434
local client


function serverWaitForConnection()
  server = assert(socket.bind(ip, port))
  client = server:accept()
  client:settimeout(4)
  return server
end

function connectToServer()
  client = socket.connect(ip,port)
  client:settimeout(4)
end

function transmit(str)
  client:send(str)
end

function receive(str)
  local line, err = client:receive()
end

function closeConnection()
  client:close()
end

function serializeSpectrum(descriptor,spectrum)
  if spectrum == nil then 
    spectrum = {}
    for i=1,100,1
    do
      spectrum[i] = 0
    end
  end

  outstring = descriptor..":"..spectrum[1]
  for i=2,100,1
  do
    outstring = outstring..","..tostring(spectrum[i])
  end
  return outstring
end

function deserializeSpectrum(str)
  local spectrum = {}
  local split = string.find(str,":")
  local descriptor = string.sub(str, 1, split)
  str = string.sub(str, split+1) -- strip off the leading descriptor and colon.
  local sep = ","
  for str in string.gmatch(str, "([^"..sep.."]+)") 
  do
    table.insert(spectrum, tonumber(str))
  end
  return {descriptor, spectrum}
end

function parse(str, err)
  if str == nil then 
    -- do something with the error?
    return {nil, nil, nil}
  else
    local sep = ";"
    local fields = {}
    for s in string.gmatch(str, "([^"..sep.."]+)") 
      do
      fields.insert(s)
    end
    local op_laser = deserializeSpectrum(s[1])
    local op_transreflector = deserializeSpectrum(s[2])
    time = tonumber(s[3])
    return {op_laser[2],op_transreflector[2],time}
  end
end
