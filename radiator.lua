-- Radiator
-- Energy emitted is propotional to temperature ^4 in real life.
-- peak frequency increases linearly with temperature
-- spectral energy density ~~ 1/(L^5*(e^(1/LT)-1))
-- gotta find a nice equation that makes good power spectrum curves eventually.

Radiator = {temperature = 5, capacity = 200}

function Radiator:create(c)
	c = c or {}
	setmetatable(c, self)
    self.__index = self
	return c
end

function Radiator:reset()
	self.temperature = 5
end
function Radiator:color()
	return {1-(self.temperature/100),0,(self.temperature/100)}
end
function Radiator:spectrum()
	-- describe the thermal power spectrum as a function of temperature.
	-- we'll do a simplified thing for now.
	maxtemperature = 100
	maxlevel = 100
	local t = self.temperature
	peak = t
	level = (t*t*t)/10000
	slope_up = level/t
	slope_down = level/(100-t)
	s = {}
	for i=1,100,1
	do
		if i < peak then
			s[i] = slope_up*i
		else
			s[i] = level - slope_down*(i-peak)
		end
	end
	return s
end

function Radiator:addEnergySpectrum(spectrum)
	local totalEnergy = 0
	for i,v in ipairs(spectrum) do
		totalEnergy = totalEnergy + v
	end
	self.temperature = self.temperature + totalEnergy/self.capacity
end

function Radiator:addPowerSpectrum(spectrum,dt)
	local totalPower = 0
	for i,v in ipairs(spectrum) do
		totalPower = totalPower + v
	end
	totalEnergy = totalPower*dt
	self.temperature = self.temperature + totalEnergy/self.capacity
end

function Radiator:addEnergy(energy)
	self.temperature = self.temperature + energy/self.capacity
end

function Radiator:addPower(power, dt)
	energy = power*dt
	self.temperature = self.temperature + energy/self.capacity
end

function Radiator:radiateEnergy(dt)
	-- use the power spectrum to figure out energy output in dt time periods.
	local spectrum = self:spectrum()
	radiated = 0
	for i,v in ipairs(spectrum) do
		radiated = radiated + v
	end
	radiatedEnergy = radiated*dt
	self.temperature = self.temperature - radiatedEnergy/self.capacity
end

function radiatorInterface(r,x,y)
	local width = 104
	local height = 304

	local lengths = r:spectrum()
	local color = r:color()
	love.graphics.setColor(color[1],color[2],color[3])
	love.graphics.rectangle("line", x, y, width, height)
	for i=1,100,1
	do
		love.graphics.rectangle("fill", x+2, y+3*i, 2, 2)
		love.graphics.rectangle("fill", x+4, y+3*i, lengths[i], 2)
	end
end