local socket = require("socket")

local sensor = require("sensor")
local laser = require("laser")
local capacitorbank = require("capacitorbank")
local furnace = require("furnace")
local transreflector = require("transreflector")
local radiator = require("radiator")

-- the address and port of the server
local address, port = "localhost", 343434
local updaterate = 0.02 -- how long to wait, in seconds, before requesting an update.  We want a fast-twitch game, so 20 ms should be plenty fast.
local t
local score
local gameMode = "boot"

-- onetime setup
function love.load()
	love.window.setTitle("Tightbeam - Commsat Combat")
	gameMode = "boot"
	reset()
end

function reset()
	t=120
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

function titlescreen()
	love.graphics.setColor(1,1,1)
	love.graphics.print("startgame?",300,50)
	if love.keyboard.isDown('y') then 
		gameMode = "play"
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
		love.graphics.setColor(1,1,1)
		love.graphics.print(tostring(score), 500, 250)
		love.graphics.print(tostring(t), 500, 220)
	elseif gameMode == "gameover" then
		gameoverscreen()
	end
end

function love.update(dt)
	if gameMode == "play" then
		--update can be called a lot.  dt is the time since it was last called.
		-- Power is energy / time.
		-- energy is power*time

		-- the radiator emits energy at some rate, that is, there is a power level for it at 
		-- each point in it's spectrum.  how much energy has left in the past dt? lets see:
		Radiator:radiateEnergy(dt)
		-- our radiated spectrum is a power spectrum
		radiatedSpectrum = Radiator:spectrum()
		internallyReflectedSpectrum = Transreflector:reflect(radiatedSpectrum)
		Radiator:addPowerSpectrum(internallyReflectedSpectrum, dt)
		-- any reflected energy has now been reabsorbed.

		-- our furnace takes time to adjust its power level.
		Furnace:adjustPower(dt)

		-- are any capacitors set for charging?
			-- if so, distribute power from furnace into capacitors, unless it's full.
			-- if not, put power from furnace into radiator.
		excessEnergy = CapacitorBank.consumePower(Furnace, dt) -- if there is excess energy this dt because the capacitors are full, then we dump it.
		Radiator:addEnergy(excessEnergy)

		-- are any capacitors set for discharging?
		-- if so, discharge from capacitors through the laser
		CapacitorBank.discharge(Laser, dt)

		-- sensor display is afffected by radiator temperature.
		-- Sensor.display(Radiator.temperature)

		-- grab and store/send the laser sent energy
		s = Laser:send()

		for i=1,100,1 do
			score = score + s[i]
		end
		
		if Radiator.temperature > 100 then
			gameMode = "gameover"
		end

		t = t-dt
		if t<0 then
			gameMode = "gameover"
		end
	end
end
