Spectrum = {}

function Spectrum.zeroSpectrum()
	out = {}
	for i=1,100,1
	do
		out[i] = 0
	end
	return out
end

function Spectrum.copy(spectrum)
	if spectrum ~= nil then
		out = {}
		for i=1,100,1
		do
			out[i] = spectrum[i]
		end
		return out
	else
		return nil
	end
end
