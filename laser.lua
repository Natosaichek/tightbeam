-- default values for the laser
local zeroSpectrum = {}
for i = 1, 100, 1
do
	zeroSpectrum[i] = 0
end
Laser = {cfreq = 50, deviation = 1, power = 8000, charging = 1500, wasted = 0, sentEnergySpectrum = zeroSpectrum}

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
		return zeroSpectrum
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
	tmpspectrum = {}
	for i=1,100,1
	do
		tmpspectrum[i] = self.sentEnergySpectrum[i]
		self.sentEnergySpectrum[i] = 0
	end
	return tmpspectrum
end

function Laser:off()
	self.wasted = 0
end
