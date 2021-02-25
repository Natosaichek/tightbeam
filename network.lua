local socket = require("socket")
local tb = require("textboxes")

local spinner = 0
local netthread
local clientChannel = love.thread.getChannel ( 'client' );

function startServer(ip, port)
  print("starting server")
  netthread = love.thread.newThread("server.lua")
  netthread:start(ip,port)
  connecting = true
end
function connectToServer(ip, port)
  print("starting client")
  netthread = love.thread.newThread("client.lua")
  netthread:start(ip,port)
  connecting = true
end

function receive()
  clientChannel:supply({cmd="rx"})
  msg = clientChannel:demand()
  if msg.data then
    -- print("rx msg.data:"..msg.data)
  elseif msg.error then 
    print("rx msg.error:"..msg.error)
  end
  return msg.data, msg.error
end

function transmit(tdata)
  -- print("data:"..tdata)
  clientChannel:supply({cmd="tx",data=tdata})
  clientChannel:demand() -- just a way to wait until the thread indicates it's done sending
end

function closeConnection()
  print("sending die command")
  clientChannel:supply({cmd="die"}, 0.2)
  print("waiting for response")
  clientChannel:demand(0.2)
  print("checking if thread is alive")
  if netthread.isRunning then 
    print("it is.  killing it.")
    netthread:release()
  end
  print("done aborting")
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
    print("got an empty string")
    -- do something with the error?
    return {nil, nil, nil}
  else
    -- print(str)
    local sep = ";"
    local fields = {}
    for s in string.gmatch(str, "([^"..sep.."]+)") 
      do
      table.insert(fields,s)
    end
    local op_laser = deserializeSpectrum(fields[1])
    local op_transreflector = deserializeSpectrum(fields[2])
    local op_state = fields[3]
    return {op_laser[2],op_transreflector[2],op_state}
  end
end

--************************************
-- Interface for the networking stuff
--************************************
local hdown = false
local cdown = false
local bdown = false
function networkingInterface()
  love.graphics.setColor(1,1,1)
  -- love.graphics.print(netMode,100,50)
  if netMode == "boot" then
    ipTextbox:hide()
    portTextbox:hide()
    love.graphics.print("(h)ost or ",300,50)
    love.graphics.print("(c)onnect?",300,70)
    love.graphics.print("(b)ack",300,110)
    if hdown then
      if not love.keyboard.isDown('h') then  -- trigger on release of the key
        netMode = "server"
      end
    end
    if cdown then
      if not love.keyboard.isDown('c') then
        netMode = "client"
      end
    end
    if bdown then
      if not love.keyboard.isDown('b') then
        title="playercount"
      end
    end
    hdown = love.keyboard.isDown('h')
    cdown = love.keyboard.isDown('c')
    bdown = love.keyboard.isDown('b')
  end
  if not connected then
    if netMode == "client" then
      if not connecting then 
        clientConnectInterface()
      else 
        waitingInterface("connecting")
      end
    end
    if netMode == "server" then 
      if not connecting then 
        serverHostInterface()
      else 
        waitingInterface("waiting...")
      end
    end
  else
    gameMode = "play"
  end
end


function clientConnectInterface()
  ipTextbox:show()
  portTextbox:show()
  connectButton()
  backButton()
  if love.keyboard.isDown("c") then 
    connectToServer(ipTextbox.text,portTextbox.text)
  end
  if bdown then
    if not love.keyboard.isDown('b') then
      netMode = "boot"
    end
  end
end

function serverHostInterface()
  ipTextbox:hide()
  ipTextbox.text="*"
  portTextbox:show()
  hostButton()
  backButton()
  if love.keyboard.isDown("h") then 
    startServer(ipTextbox.text,portTextbox.text)
  end
  if bdown then
    if not love.keyboard.isDown('b') then
      netMode = "boot"
    end
  end
end


ipTextbox = Textboxes.create{}
ipTextbox.text="localhost"
ipTextbox.textcolor={.5,1,.5}
ipTextbox.bgcolor={.05,.15,.05}
ipTextbox.focuscolor={.1,.2,.1}
ipTextbox.x=200
ipTextbox.y=100
ipTextbox.width=15*20
ipTextbox.height=20
ipTextbox.focussed=false
ipTextbox.visible=false

portTextbox = Textboxes.create{}
portTextbox.text="6111"
portTextbox.textcolor={.5,1,.5}
portTextbox.bgcolor={.05,.15,.05}
portTextbox.focuscolor={.1,.2,.1}
portTextbox.x=200
portTextbox.y=130
portTextbox.width=5*20
portTextbox.height=20
portTextbox.focussed=false
portTextbox.visible=false

function connectButton()
  local bx = 200
  local by = 200
  local bwidth = 200
  local bheight = 40
  local framecolor = {.3,.5,.3}
  local bgcolor = {.3,.5,.3}
  local textcolor = {.5,1,.5}
  local mx, my = love.mouse.getPosition()
  
  if mouseinBox(bx,by,bwidth,bheight) then
    framecolor = {.4,.6,.4}
    if love.mouse.isDown(1) and not connecting then
      connectToServer(ipTextbox.text,portTextbox.text)
    end
  end
  love.graphics.setColor(framecolor)
  love.graphics.rectangle("line", bx, by, bwidth, bheight)
  love.graphics.setColor(bgcolor)
  love.graphics.rectangle("fill", bx, by, bwidth, bheight)
  love.graphics.setColor(textcolor)
  love.graphics.print("(C)onnect",bx+5,by+5)
end

function backButton()
  local bx = 200
  local by = 260
  local bwidth = 200
  local bheight = 40
  local framecolor = {.3,.5,.3}
  local bgcolor = {.3,.5,.3}
  local textcolor = {.5,1,.5}
  local mx, my = love.mouse.getPosition()
  
  if mouseinBox(bx,by,bwidth,bheight) then
    framecolor = {.4,.6,.4}
    if love.mouse.isDown(1) then
      netMode = "boot"
    end
  end
  love.graphics.setColor(framecolor)
  love.graphics.rectangle("line", bx, by, bwidth, bheight)
  love.graphics.setColor(bgcolor)
  love.graphics.rectangle("fill", bx, by, bwidth, bheight)
  love.graphics.setColor(textcolor)
  love.graphics.print("(B)ack",bx+5,by+5)
end


function hostButton()
  local bx = 200
  local by = 200
  local bwidth = 200
  local bheight = 40
  local framecolor = {.3,.5,.3}
  local bgcolor = {.3,.5,.3}
  local textcolor = {.5,1,.5}
  local mx, my = love.mouse.getPosition()
  
  if mouseinBox(bx,by,bwidth,bheight) then
    framecolor = {.4,.6,.4}
    if love.mouse.isDown(1) and not connecting then
      startServer(ipTextbox.text,portTextbox.text)
    end
  end
  love.graphics.setColor(framecolor)
  love.graphics.rectangle("line", bx, by, bwidth, bheight)
  love.graphics.setColor(bgcolor)
  love.graphics.rectangle("fill", bx, by, bwidth, bheight)
  love.graphics.setColor(textcolor)
  love.graphics.print("(H)ost",bx+30,by+5)
end

function averageColors(c1,c2,percent)
  out = {0,0,0}
  for i=1,3,1 do
    out[i] = c1[i] + (c2[i] - c1[i])*percent/100
  end
  return out
end

function waitingInterface(message)
  -- have some nice "waiting for connection" animation
  ipTextbox:hide()
  portTextbox:hide()
  local error = netthread:getError()
  assert( not error, error )
  local clientActive = clientChannel:pop()
  -- print("client:"..tostring(client))
  if clientActive then
    connected = true
    net_t = 0
  end
  if abortButton() then
    print("aborting connection")
    closeConnection()
    connecting = false
  end
  -- have some nice "attempting to connect" animation run until the 'connect to server' call completes successfully
  local bx = 200
  local by = 200
  local bwidth = 200
  local bheight = 40
  local framecolor = {.3,.5,.3}
  local bgcolor = {.05,.2,.05}
  local topbgcolor = {.1,.6,.1}
  local tmpbgcolor = averageColors(topbgcolor,bgcolor,spinner)
  spinner = (spinner + 3)%100
  local textcolor = {.5,1,.5}
  love.graphics.setColor(framecolor)
  love.graphics.rectangle("line", bx, by, bwidth, bheight)
  love.graphics.setColor(tmpbgcolor)
  love.graphics.rectangle("fill", bx, by, bwidth, bheight)
  love.graphics.setColor(textcolor)
  love.graphics.print(message,bx+5,by+5)
end

local adown = false
function abortButton()
  local bx = 200
  local by = 240
  local bwidth = 200
  local bheight = 40
  local framecolor = {.3,.5,.3}
  local bgcolor = {.3,.5,.3}
  local textcolor = {.5,1,.5}
  local mx, my = love.mouse.getPosition()
  if adown then
    if not love.keyboard.isDown("a") then
      return true
    end
  end
  adown = love.keyboard.isDown("a")
  if mouseinBox(bx,by,bwidth,bheight) then
    framecolor = {.4,.6,.4}
    if love.mouse.isDown(1) then
      return true
    end
  end
  love.graphics.setColor(framecolor)
  love.graphics.rectangle("line", bx, by, bwidth, bheight)
  love.graphics.setColor(bgcolor)
  love.graphics.rectangle("fill", bx, by, bwidth, bheight)
  love.graphics.setColor(textcolor)
  love.graphics.print("(A)bort",bx+30,by+5)
  return false
end