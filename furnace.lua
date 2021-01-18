-- Nuclear Furnace
Furnace = {powerlevel = 0, targetPowerlevel = 0, maxRate = 4, maxPowerlevel = 5000}

function Furnace:reset()
	self.powerlevel = 0
	self.targetPowerlevel = 0
end

function Furnace:setTargetPower(newPowerlevel)
	if newPowerlevel > self.maxPowerlevel then
		newPowerlevel = self.maxPowerlevel
	end
	if newPowerlevel < 0 then
		newPowerlevel = 0
	end
	self.targetPowerlevel = newPowerlevel
end

function Furnace:adjustPower(dt)
	deltapower = self.targetPowerlevel-self.powerlevel
	if math.abs(deltapower/dt) < self.maxRate then
		self.powerlevel = self.targetPowerlevel
	else
		if deltapower > 0 then
			self.powerlevel = self.powerlevel+self.maxRate
		else
			self.powerlevel = self.powerlevel-self.maxRate
		end
	end
end

function Furnace:providePower(requested, dt)
	-- provide the requested power. 
	-- for now, all power is excess.
	excessPowerlevel = self.powerlevel
	return excessPowerlevel
end

function furnaceInterface(ox,oy)
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