spec = require("spectrum")
-- default values for the laser

Laser = {cfreq = 50, deviation = 1, power = 8000, charging = 1500, wasted = 0, sentEnergySpectrum = Spectrum.zeroSpectrum()}

function Laser:create(c)
	c = c or {}
	setmetatable(c, self)
    self.__index = self
	return c
end

function Laser:reset()
	self.cfreq = 50
	self.deviation = 1
	self.wasted = 0
end


function Laser:changeFreq(newFreq)
	self.cfreq = newFreq
end

function Laser:changeDeviation(newDev)
	self.deviation = newDev
end

function Laser:spectrum(energy)
	-- gaussian power distribution
	if energy == 0 
	then
		return Spectrum.zeroSpectrum()
	end
	-- A * e^ ( (-1*(x-B)^2) / (2*C^2) )
	-- A is height
	-- B is center value
	-- C is standard deviation
	-- area under curve is 1 if A = 1/C*sqrt(2*pi)
	-- this yields the normal distribution 
	sig = self.deviation
	mu = self.cfreq
	s = {}
	for f=1,100,1
	do
		s[f] = (1/(sig*math.sqrt(math.pi*2))) * math.exp((-1*(f-mu)^2)/(2*sig*sig))
		s[f] = s[f]*energy
	end
	return s
end


function Laser:consume(storedEnergy, dt)
	-- have to utilize power 
	consumedEnergy = math.min(storedEnergy, self.power*dt)
	
	-- the laser takes the first chunk of power it receives and "wastes" it in charging up the crystals.
	if self.wasted < self.charging then
		delta = self.charging - self.wasted
		if consumedEnergy < delta then
			self.wasted = self.wasted + consumedEnergy
			availableEnergy = 0
		else
			self.wasted = self.charging
			availableEnergy = consumedEnergy - delta
		end
	else
		availableEnergy = consumedEnergy
	end
	s = self:spectrum(availableEnergy)
	for i=1,100,1
	do
		self.sentEnergySpectrum[i] = self.sentEnergySpectrum[i] + s[i]
	end
	return consumedEnergy
end

function Laser:send()
	local out = Spectrum.copy(self.sentEnergySpectrum)
	self.sentEnergySpectrum = Spectrum.zeroSpectrum()
	return out
end

function Laser:off()
	self.wasted = 0
end


function laserInterface(l,x,y)
	local width = 40
	local height = 304
	laserFiring = {.98,.2,.6}
	laserOff = {.7,.1,.5}
	lasercolor = laserOff
	if l.wasted == l.charging then
		lasercolor = laserFiring
	end
	-- if the mouse goes over the box, highlight it.
	if mouseinBox(x,y,width,height) then
		love.graphics.setColor(.9, .3, .5)
	else
		love.graphics.setColor(lasercolor)
	end
	love.graphics.rectangle("line", x, y, width, height)
	s = l:spectrum(1)
	maxwidth = 32
	deviationCalibration = math.sqrt(2*math.pi)
	for i=1,100,1
	do
		bx = x+4
		by = y + i*3
		bwidth = maxwidth
		bheight = 2
		if mouseinBox(bx, by-1, bwidth, bheight+2) then
			love.graphics.setColor(.9, .3, .5)
			if love.mouse.isDown(1) then
				mx = love.mouse.getX()
				magnitude = (mx-bx)/maxwidth
				dev = 1/(magnitude*deviationCalibration)
				l:changeDeviation(dev)
				l:changeFreq(i)
			end
		else
			love.graphics.setColor(lasercolor)
		end
		barwidth = s[i]*maxwidth
		love.graphics.rectangle("fill", bx, by, 1, 2)
		love.graphics.rectangle("fill", bx+1, by, barwidth-1, 2)
	end
end