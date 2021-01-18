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


function printSpectrum(spectrum)
	x = 400
	y = 20
	for i=1,100,1
	do
		love.graphics.print(tostring(spectrum[i]), x, y+i*9)
	end
end


function radiatorInterface()
	local x = 16
	local y = 150
	local width = 104
	local height = 304

	local lengths = Radiator:spectrum()
	local color = Radiator.color()
	love.graphics.setColor(color[1],color[2],color[3])
	love.graphics.rectangle("line", x, y, width, height)
	for i=1,100,1
	do
		love.graphics.rectangle("fill", x+2, y+3*i, 2, 2)
		love.graphics.rectangle("fill", x+4, y+3*i, lengths[i], 2)
	end
end

function furnaceInterface()
	local ox = 2
	local oy = 150
	local owidth = 12
	local oheight = 304
	local margin = 2
	local x = 2+margin
	local y = 150+margin
	local width = 12-2*margin
	local height = 304-2*margin
	local color = {.4,.6,.4}
	if mouseinBox(x,y,width,height) then
		color[1] = 1+color[1]/2
		color[2] = 1+color[2]/2
		color[3] = 1+color[3]/2
		if love.mouse.isDown(1) then
			my = love.mouse.getY()
			magnitude = ((y+height-my)/height)*Furnace.maxPowerlevel
			Furnace:setTargetPower(magnitude)
		end
	end
	love.graphics.setColor(color[1],color[2],color[3])
	love.graphics.rectangle("line", x, y, width, height)
	-- draw the background of the power gauge
	love.graphics.setColor(.1,.1,.1)
	love.graphics.rectangle("fill", x, y, width, height)
	-- draw a rectangle indicating the current power level
	powerheight = (Furnace.powerlevel*height/Furnace.maxPowerlevel)
	love.graphics.setColor(.1,.6,.1)
	love.graphics.rectangle("fill", x, y+height-powerheight, width, powerheight)
	-- draw a line across indicating the target power level
	targetpos = y + height * (1-(Furnace.targetPowerlevel/Furnace.maxPowerlevel))
	love.graphics.setColor(.2,.8,.2)
	love.graphics.rectangle("fill", x-1, targetpos, width+1, 2)
end


function capacitorInterface()
	-- depict each capacitor and enable keyboard and mouse control of them.
	local x = 2
	local y = 460
	local capradius = 20
	local controlRadius = capradius/2
	local margin = 10
	local width = (capradius*2+margin)*CapacitorBank.qty+margin
	local height = (capradius+margin)*2

	capChargeColor = {.7,.5,.1}
	capChargeSelectedColor = {.8,.7,.3}
	capDischargeColor = {.1,.5,.7}
	capDischargeSelectedColor = {.3,.7,.8}
	capDisabledColor = {.4,.4,.4}
	capDisabledSelectedColor = {.6,.6,.6}
	-- if the mouse goes over the box, highlight it.
	if mouseinBox(x,y,width,height) then
		love.graphics.setColor(.4, .4, .9)
	else
		love.graphics.setColor(.2, .2, .6)
	end
	love.graphics.rectangle("line", x, y, width, height)
	for i,c in ipairs(CapacitorBank.capacitors)
	do
		cx = x + i*(capradius*2+margin) - capradius
		cy = y + (capradius+margin)
		fillratio = c.stored/c.capacity
		fillradius = capradius*fillratio
		if c.charging then
			love.graphics.setColor({.5,.3,.05})
		elseif c.discharging then
			love.graphics.setColor({.05,.3,.5})
		else
			love.graphics.setColor(capDisabledColor)			
		end
		love.graphics.circle("fill",cx,cy,fillradius,36)

		-- for each capacitor, highlight the perimeter appropriately to how the cap is.
		if mouseinCircle(cx,cy,capradius) then
			if c.charging then
				love.graphics.setColor(capChargeSelectedColor)
			elseif c.discharging then
				love.graphics.setColor(capDischargeSelectedColor)
			else
				love.graphics.setColor(capDisabledSelectedColor)
			end
		else
			if c.charging then
				love.graphics.setColor(capChargeColor)
			elseif c.discharging then
				love.graphics.setColor(capDischargeColor)
			else
				love.graphics.setColor(capDisabledColor)			
			end
		end
		love.graphics.circle("line",cx,cy,capradius,36)
		-- now draw the 'charge' and 'discharge' selection buttons
		dc_cx = cx-(capradius/2)
		dc_cy = cy
		if mouseinCircle(dc_cx,dc_cy,controlRadius) then
			love.graphics.setColor(capDischargeSelectedColor)
			if love.mouse.isDown(1) then
				c:setDischarging()
			end
		else
			love.graphics.setColor(capDischargeColor)
		end
		love.graphics.circle("fill",dc_cx,dc_cy,controlRadius,24)

		c_cx = cx+(capradius/2)
		c_cy = cy
		if mouseinCircle(c_cx,c_cy,controlRadius) then
			changestate = false
			love.graphics.setColor(capChargeSelectedColor)
			if love.mouse.isDown(1) then
				c:setCharging()
			end
		else
			love.graphics.setColor(capChargeColor)
		end
		love.graphics.circle("fill",c_cx,c_cy,controlRadius,24)
	end
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
		radiatorInterface()
		transreflectorInterface()
		furnaceInterface()
		capacitorInterface()
		laserInterface()
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

		t = t-dt
		if Radiator.temperature > 100 then
			gameMode = "gameover"
		end

		if t<0 then
			gameMode = "gameover"
		end
	end
end
