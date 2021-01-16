-- Radiator
-- Energy emitted is propotional to temperature ^4 in real life.
-- peak frequency increases linearly with temperature
-- spectral energy density ~~ 1/(L^5*(e^(1/LT)-1))
-- gotta find a nice equation that makes good power spectrum curves eventually.

Radiator = {temperature = 5, capacity = 200}

function Radiator:color()
	return {1-(Radiator.temperature/100),0,(Radiator.temperature/100)}
end
function Radiator:spectrum()
	-- describe the thermal power spectrum as a function of temperature.
	-- we'll do a simplified thing for now.
	maxtemperature = 100
	maxlevel = 100
	local t = Radiator.temperature
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

function Radiator:addPowerSpectrum(spectrum,dt)
	local totalPower = 0
	for i,v in ipairs(spectrum) do
		totalPower = totalPower + v
	end
	totalEnergy = totalPower*dt
	Radiator.temperature = Radiator.temperature + totalEnergy/Radiator.capacity
end

function Radiator:addEnergy(energy)
	Radiator.temperature = Radiator.temperature + energy/Radiator.capacity
end

function Radiator:addPower(power, dt)
	energy = power*dt
	Radiator.temperature = Radiator.temperature + energy/Radiator.capacity
end

function Radiator:radiateEnergy(dt)
	-- use the power spectrum to figure out energy output in dt time periods.
	local spectrum = Radiator:spectrum()
	radiated = 0
	for i,v in ipairs(spectrum) do
		radiated = radiated + v
	end
	radiatedEnergy = radiated*dt
	Radiator.temperature = Radiator.temperature - radiatedEnergy/Radiator.capacity
end