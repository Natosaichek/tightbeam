local network = require("network")

local sensor = require("sensor")
local laser = require("laser")
local capacitorbank = require("capacitorbank")
local furnace = require("furnace")
local transreflector = require("transreflector")
local radiator = require("radiator")

-- the address and port of the server
local address, port = "localhost", 343434
local updaterate = 0.02 -- how long to wait, in seconds, before requesting an update.  We want a fast-twitch game, so 20 ms should be plenty fast.
local game_t
local net_t
local sensor_t
local score
local gameMode = "boot"
local netMode = "boot"
local title = "playercount"
local connected = false

-- onetime setup
function love.load()
	love.window.setTitle("Tightbeam - Commsat Combat")
	gameMode = "boot"
	reset()
	-- server.start()
end

function reset()
	game_t = 820
	sensor_t = 0
	net_t = 0
	score = 0
	Laser:reset()
	CapacitorBank:reset()
	Furnace:reset()
	Transreflector:reset()
	Radiator:reset()
end

-- Interface Functions
function mouseinBox(x,y,width,height)
	mx, my = love.mouse.getPosition( )
	if mx > x and mx < x+width and my > y and my < y+height then
		return true
	else return false
	end
end

function mouseinCircle(x,y,radius)
	mx, my = love.mouse.getPosition( )
	return (mx-x)*(mx-x) + (my-y)*(my-y) < radius*radius
end

function displaySpectrum(spectrum, x,y)
	if spectrum ~= nil then
		for i=1,100,1 do
			px = x
			py = y+9*i
			love.graphics.print(tostring(spectrum[i]),px,py)
		end
	end
end

function titlescreen()
	love.graphics.setColor(1,1,1)
	if title == "playercount" then
		love.graphics.print("(m)ultiplayer or ",300,50)
		love.graphics.print("(s)ingleplayer?",300,70)
		if love.keyboard.isDown('s') then
			netMode = "none"
			-- aiPlayer.start()
		end
		if love.keyboard.isDown('m') then
			title = "multiplayer"
		end
	end
	if title == "multiplayer" then
		love.graphics.print("(h)ost or ",300,50)
		love.graphics.print("(c)onnect?",300,70)
		if love.keyboard.isDown('h') then
			netMode = "server"
		end
		if love.keyboard.isDown('c') then
			netMode = "client"
		end
		-- title = netMode
	end
end

function gameoverscreen()
	love.graphics.setColor(1,1,1)
	love.graphics.print("Your score:", 280, 230)
	love.graphics.print(tostring(score), 300, 250)
	love.graphics.print("Try again?", 280, 270)
	if love.keyboard.isDown('y') then
		reset()
		gameMode = "play"
	end
end

-- what to draw on the screen every frame
function love.draw()
	if gameMode == "boot" then
		titlescreen()
	elseif gameMode == "play" then
		furnaceInterface(2,150)
		radiatorInterface(16,150)
		transreflectorInterface(125, 150)
		laserInterface(233,150)
		capacitorInterface(2,460)
		sensorInterface(350,150)
		love.graphics.setColor(1,1,1)
		love.graphics.print(tostring(game_t), 500, 50)
		love.graphics.print(tostring(score), 500, 70)
		-- displaySpectrum(laserEnergySpectrum, 500,90)
		-- love.graphics.print(tostring(transreflectorSend), 500, 30)
	elseif gameMode == "gameover" then
		gameoverscreen()
	end
end

function love.update(dt)
	if netMode == "none" then
		gameMode = "play"
	end
	if gameMode == "play" then
		--update can be called a lot.  dt is the time since it was last called.
		-- Power is energy / time.
		-- energy is power*time

		-- the radiator emits energy at some rate, that is, there is a power level for it at 
		-- each point in it's spectrum.  how much energy has left in the past dt? Well, we'll just dump it:
		Radiator:radiateEnergy(dt)
		-- our radiated spectrum is a power spectrum
		local radiatedSpectrum = Radiator:spectrum()
		local internallyReflectedSpectrum = Transreflector:reflect(radiatedSpectrum)
		Radiator:addPowerSpectrum(internallyReflectedSpectrum, dt)
		-- any reflected energy has now been reabsorbed.

		-- our furnace takes time to adjust its power level.
		Furnace:adjustPower(dt)

		-- are any capacitors set for charging?
			-- if so, distribute power from furnace into capacitors, unless it's full.
			-- if not, put power from furnace into radiator.
		local excessEnergy = CapacitorBank.consumePower(Furnace, dt) -- if there is excess energy this dt because the capacitors are full, then we dump it.
		Radiator:addEnergy(excessEnergy)

		-- are any capacitors set for discharging?
		-- if so, discharge from capacitors through the laser
		CapacitorBank.discharge(Laser, dt)

		-- sensor display is afffected by radiator temperature.
		-- Sensor.display(Radiator.temperature)

		-- grab and store/send the laser sent energy
		laserEnergySpectrum = Laser:send()



		if parsedLaser ~= nil then
			for i=1,100,1 do
				score = score + parsedLaser[i]
			end
			laserIncident = Transreflector:transmit(parsedLaser)
			Radiator:addEnergySpectrum(laserIncident)
			parsedLaser = nil
		end

		-- for i=1,100,1 do
		-- 	score = score + laserEnergySpectrum[i]
		-- end
		
		if Radiator.temperature > 100 then
			gameMode = "gameover"
		end

		game_t = game_t-dt
		sensor_t = sensor_t+dt
		if game_t < 0 then
			gameMode = "gameover"
		end
	end
	net_t = net_t + dt
	if netMode == "server" then
		-- wait for the client to connect
		if not connected then
			serverWaitForConnection()
			-- once client is connected, switch game to play mode and start the timer.
			gameMode = "play"
			connected = true
		end
		
		if (net_t > updaterate and connected == true) then
			-- parse received data
			opponent,err = receive()
			parsedState = parse(opponent,err)
			parsedLaser = parsedState[1]
			parsedTransreflector = parsedState[2]
			-- send data
			laserSend = serializeSpectrum("laser",laserEnergySpectrum)
			transreflectorSend = serializeSpectrum("transreflector",Transreflector.spectrum)
			transmit(laserSend..";"..transreflectorSend..";"..tostring(t).."\n")
			net_t = 0
		end
	end
	
	if netMode == "client" then 
		-- connect to the server
		if not connected then
			connectToServer()
			-- once connection confirmed, switch game to play mode
			gameMode = "play"
			connected = true
		end
		-- send and request data
		if (net_t > updaterate and connected == true) then
			-- send data
			laserSend = serializeSpectrum("laser",laserEnergySpectrum)
			transreflectorSend = serializeSpectrum("transreflector",Transreflector.spectrum)
			deserialized = deserializeSpectrum(transreflectorSend)
			sendstring = laserSend..";"..transreflectorSend..";"..tostring(t).."\n"
			transmit(sendstring)
			-- 
			-- parse received data
			opponent,err = receive()
			parsedState = parse(opponent,err)
			parsedLaser = parsedState[1]
			parsedTransreflector = parsedState[2]
			net_t = 0
			-- t = op_time
		end
	end
end
