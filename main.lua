local network = require("network")
local tb = require("textboxes")

local player = require("player")
local spec = require("spectrum")
local sensor = require("sensor")
local laser = require("laser")
local capacitorbank = require("capacitorbank")
local furnace = require("furnace")
local transreflector = require("transreflector")
local radiator = require("radiator")

local updaterate = 0.02 -- how long to wait, in seconds, before requesting an update.  Fifty ms should be plenty fast... 50 updates/sec is pretty reasonable.
local game_t
local energyout = 0
local energyin = 0
local win = false
turn_t = 0
gameMode = "boot"  -- game mode state gets manipulated in other interfaces (eg. networkInterface)
title = "splash"   -- title mode state also gets manipulated 
netMode = "boot"
connected = false
connecting = false
player = Player:create()

-- onetime setup
function love.load()
	love.window.setTitle("Tightbeam - Commsat Combat")
	reset()
	title = "splash"
	MenuFont = love.graphics.newFont("ArizoneUnicaseRegular-5dRZ.ttf", 14)
	love.graphics.setFont(MenuFont)
end

function reset()
	gameMode = "boot"
	title = "playercount"
	netMode = "boot"
	win = false
	game_t = 240
	sensor_t = 0
	turn_t = 0
	score = 0
	player:reset()
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
		furnaceInterface(player.furnace,2,150)
		radiatorInterface(player.radiator,16,150)
		transreflectorInterface(player.transreflector,125, 150)
		laserInterface(player.laser,233,150)
		capacitorInterface(player.capacitorbank,2,460)
		sensorInterface(player.sensor,350,150)
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
	turn_t = turn_t + dt
	while (turn_t > updaterate) do
		if gameMode == "play" then

			player:update(updaterate,parsedTransreflector)

			if parsedLaser ~= nil then
				for i=1,100,1 do
					energyin = energyin + parsedLaser[i]
				end
				laserIncident = player.transreflector:transmit(parsedLaser)
				player.radiator:addEnergySpectrum(laserIncident)
				parsedLaser = nil
			end

			for i=1,100,1 do
				energyout = energyout + player.laserEnergySpectrum[i]
			end
			
			if player.radiator.temperature > 100 then
				gameMode = "gameover"
				win = false
			end

			game_t = game_t-updaterate
			sensor_t = sensor_t+updaterate
			if game_t < 0 then
				gameMode = "gameover"
			end
		end
		if netMode == "server" and  (gameMode == "play" or gameMode == "gameover") then
			if (connected == true) then
				-- parse received data
				opponent,err = receive()
				parsedState = parse(opponent,err)
				parsedLaser = parsedState[1]
				parsedTransreflector = parsedState[2]
				parsedGameMode = parsedState[3]
				if parsedGameMode == "gameover" then
					if gameMode == "play" then
						gameMode = "gameover"
						win = true
					end
				end
				-- send data
				laserSend = serializeSpectrum("laser",player.laserEnergySpectrum)
				transreflectorSend = serializeSpectrum("transreflector",player.transreflector.spectrum)
				sendstring = laserSend..";"..transreflectorSend..";"..gameMode.."\n"
				transmit(sendstring)
			end
		end
		if netMode == "client" and(gameMode == "play" or gameMode == "gameover") then
			-- send and request data
			if (connected == true) then
				-- send data
				laserSend = serializeSpectrum("laser",player.laserEnergySpectrum)
				transreflectorSend = serializeSpectrum("transreflector",player.transreflector.spectrum)
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
					if gameMode == "play" then
						gameMode = "gameover"
						win = true
					end
				end
				
			end
			if netMode == "none" then
				parsedLaser = Spectrum.zeroSpectrum()
				parsedTransreflector = Spectrum.zeroSpectrum()
			end
		end
		turn_t = turn_t-updaterate
	end
end
