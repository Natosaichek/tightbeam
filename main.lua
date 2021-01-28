local network = require("network")
local tb = require("textboxes")

local spec = require("spectrum")
local sensor = require("sensor")
local laser = require("laser")
local capacitorbank = require("capacitorbank")
local furnace = require("furnace")
local transreflector = require("transreflector")
local radiator = require("radiator")

local updaterate = 0.05 -- how long to wait, in seconds, before requesting an update.  Fifty ms should be plenty fast... 20 updates/sec of the oponent's actions is pretty reasonable.
local game_t
local energyout = 0
local energyin = 0
local win = false
net_t = 0
gameMode = "boot"  -- game mode state gets manipulated in other interfaces (eg. networkInterface)
title = "splash"   -- title mode state also gets manipulated 
netMode = "boot"
connected = false
connecting = false

-- onetime setup
function love.load()
	love.window.setTitle("Tightbeam - Commsat Combat")
	gameMode = "boot"
	reset()
	MenuFont = love.graphics.newFont("ArizoneUnicaseRegular-5dRZ.ttf", 14)
	love.graphics.setFont(MenuFont)
end

function reset()
	win = false
	game_t = 240
	sensor_t = 0
	net_t = 0
	score = 0
	Laser:reset()
	CapacitorBank:reset()
	Furnace:reset()
	Transreflector:reset()
	Radiator:reset()
end

function love.keypressed(key, scancode, isrepeat)
   if key == "escape" then
      love.event.quit()
   end
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
	if title == "splash" then
		w_width, w_height, flags = love.window.getMode()
		splashscreen = love.graphics.newImage("TightBeamSplashScreenClean.png")
		scale_x = w_width/splashscreen:getWidth()
		scale_y = w_height/splashscreen:getHeight()
		-- if we're scaling x more, then the window width is really wide, and we should use the _height_ scaling of the image.  
		-- if we're scaling y more, then the window height is really tall, and we should use the _width_ scaling of the image.  
		if scale_x > scale_y then
			scale = scale_y
			x_margin = (w_width - scale*splashscreen:getWidth())/2
			y_margin = 0
		else
			scale = scale_x
			y_margin = (w_height - scale*splashscreen:getHeight())/2
			x_margin = 0
		end
		rotation = 0
		-- now that we've got it scaled so it will fit, we should center it.
		love.graphics.draw(splashscreen, x_margin, y_margin, rotation, scale, scale)

		if love.keyboard.isDown('space') or love.keyboard.isDown('return') then 
			title = "playercount"
		end
	end
	if title == "playercount" then
		love.graphics.print("(m)ultiplayer or ",300,50)
		love.graphics.print("(s)ingleplayer?",300,70)
		if love.keyboard.isDown('s') then
			netMode = "none"
			gameMode = "play"
		end
		if love.keyboard.isDown('m') then
			title = "multiplayer"
		end
	end
	if title == "multiplayer" then
		networkingInterface()
	end
end

function gameoverscreen()
	love.graphics.setColor(1,1,1)
	if win then 
		love.graphics.print("You Won!", 280, 210)
	else
		love.graphics.print("You Lost!", 280, 210)
	end
	love.graphics.print("Your expended energy:", 280, 230)
	love.graphics.print(tostring(energyout), 300, 250)
	love.graphics.print("Your absorbed energy:", 280, 270)
	love.graphics.print(tostring(energyin), 300, 290)
	love.graphics.print("Try again?(y/n)", 280, 310)
	if love.keyboard.isDown('y') then
		reset()
		gameMode = "boot"
		title = "playercount"
	end
	if love.keyboard.isDown('n') then
		love.event.quit()
	end

end

-- what to draw on the screen every frame
function love.draw()
	if gameMode == "boot" then
		titlescreen()
	elseif gameMode == "menu" then
		menu()
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
	-- make sure our textbox ui elements get drawn
	Textboxes.draw()
end

function love.update(dt)
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
		Sensor:updateDisplay(Radiator.temperature, parsedTransreflector)

		-- grab and store/send the laser sent energy
		laserEnergySpectrum = Laser:send()



		if parsedLaser ~= nil then
			for i=1,100,1 do
				energyin = energyin + parsedLaser[i]
			end
			laserIncident = Transreflector:transmit(parsedLaser)
			Radiator:addEnergySpectrum(laserIncident)
			parsedLaser = nil
		end

		for i=1,100,1 do
			energyout = energyout + laserEnergySpectrum[i]
		end
		
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
	if netMode == "none" then
		parsedLaser = Spectrum.zeroSpectrum()
		parsedTransreflector = Spectrum.zeroSpectrum()
	end

	if netMode == "server" and  (gameMode == "play" or gameMode == "gameover") then
		if (net_t > updaterate and connected == true) then
			-- parse received data
			opponent,err = receive()
			parsedState = parse(opponent,err)
			parsedLaser = parsedState[1]
			parsedTransreflector = parsedState[2]
			parsedGameMode = parsedState[3]
			if parsedGameMode == "gameover" then
				gameMode = "gameover"
				win = true
			end
			-- send data
			laserSend = serializeSpectrum("laser",laserEnergySpectrum)
			transreflectorSend = serializeSpectrum("transreflector",Transreflector.spectrum)
			sendstring = laserSend..";"..transreflectorSend..";"..gameMode.."\n"
			transmit(sendstring)
			net_t = 0
		end
	end
	
	if netMode == "client" and(gameMode == "play" or gameMode == "gameover") then
		-- send and request data
		if (net_t > updaterate and connected == true) then
			-- send data
			laserSend = serializeSpectrum("laser",laserEnergySpectrum)
			transreflectorSend = serializeSpectrum("transreflector",Transreflector.spectrum)
			sendstring = laserSend..";"..transreflectorSend..";"..gameMode.."\n"
			transmit(sendstring)
			-- 
			-- parse received data
			opponent,err = receive()
			parsedState = parse(opponent,err)
			parsedLaser = parsedState[1]
			parsedTransreflector = parsedState[2]
			parsedGameMode = parsedState[3]
			if parsedGameMode == "gameover" then
				gameMode = "gameover"
				win = true
			end
			net_t = 0
		end
	end
end
