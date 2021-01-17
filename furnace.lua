-- Nuclear Furnace
Furnace = {powerlevel = 0, targetPowerlevel = 0, maxRate = 2, maxPowerlevel = 5000}

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

