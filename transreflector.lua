local default_spectrum = {}
for i = 1, 100, 1
do
	default_spectrum[i] = .99
end

Transreflector = {spectrum = default_spectrum}

function Transreflector:reset()
	for i = 1, 100, 1
	do
		self.spectrum[i] = .99
	end
end	

function Transreflector:reflect(incomingspectrum)
	reflectedspectrum = {}
	for i, magnitude in ipairs(incomingspectrum) do
		reflectedspectrum[i] = self.spectrum[i]*magnitude
	end
	return reflectedspectrum
end

function Transreflector:transmit(incomingspectrum)
	transmittedspectrum = {}
	for i,magnitude in ipairs(incomingspectrum) do
		transmittedspectrum[i] = (1-self.spectrum[i])*magnitude
	end
	return transmittedspectrum
end

function Transreflector:adjustSpectrum(index, magnitude, spread)
	if spread < 5 then
		if magnitude < 0 then 
			magnitude = 0
		end
		self.spectrum[index] = magnitude
		if index > 1 then
			self:adjustSpectrum(index-1, (self.spectrum[index-1]+magnitude)/2, spread+1)
		end
		if index < 100 then
			self:adjustSpectrum(index+1, (self.spectrum[index+1]+magnitude)/2, spread+1)
		end
	end
end