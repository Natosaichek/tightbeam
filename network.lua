local socket = require("socket")
local ip = "localhost"
local port = 71647
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
  return line,err
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
      table.insert(fields,s)
    end
    local op_laser = deserializeSpectrum(fields[1])
    local op_transreflector = deserializeSpectrum(fields[2])
    time = tonumber(fields[3])
    return {op_laser[2],op_transreflector[2],time}
  end
end



-- local utf8 = require("utf8")
 
-- function love.load()
--     text = "Type away! -- "
 
--     -- enable key repeat so backspace can be held down to trigger love.keypressed multiple times.
--     love.keyboard.setKeyRepeat(true)
-- end
 
-- function love.textinput(t)
--     text = text .. t
-- end
 
-- function love.keypressed(key)
--     if key == "backspace" then
--         -- get the byte offset to the last UTF-8 character in the string.
--         local byteoffset = utf8.offset(text, -1)
 
--         if byteoffset then
--             -- remove the last UTF-8 character.
--             -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
--             text = string.sub(text, 1, byteoffset - 1)
--         end
--     end
-- end
 
-- function love.draw()
--     love.graphics.printf(text, 0, 0, love.graphics.getWidth())
-- end
