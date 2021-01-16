local default_spectrum = {}
for i = 1, 100, 1
do
	default_spectrum[i] = .99
end

Transreflector = {spectrum = default_spectrum}

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

function Transreflector:adjustSpectrum(index, magnitude)
	if magnitude < 0 then 
		magnitude = 0
	end
	self.spectrum[index] = magnitude
end