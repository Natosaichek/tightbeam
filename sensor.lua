-- default values for the sensor
spec = require("spectrum")

Sensor = {refresh = .5, quality = .9, deltat = .01, last_update = 0, lastSpectrum = Spectrum.zeroSpectrum(), currentRefresh = .5}
sensor_t = 0

function Sensor:updateDisplay(temperature, transreflector)
	-- at best conditions, we update our display of the enemy shield spectrum fully every "refresh" period
	-- as we warm up, the refresh period increases and our probability of getting a full read on the enemy shield decreases
	if transreflector then 
		self.currentRefresh = self.refresh + temperature*self.deltat
		outspectrum = Spectrum.zeroSpectrum()
		if sensor_t > self.currentRefresh then
			sensor_t = 0
			for i=1,100,1 do
				if (love.math.random() < (self.quality-(self.deltat*temperature))) then
					outspectrum[i] = transreflector[i]
				else
					outspectrum[i] = -1
				end
			end
			self.lastSpectrum = outspectrum
		end
	end
end


-- depict op_transreflector
function sensorInterface(x,y)
	-- in this function we'll display the existing transreflector spectrum, and also listen for updates to it from mouse events.
	-- first we'll set up the position and size of the box
	local width = 106
	local height = 304
	love.graphics.setColor(.5,.5,.5)
	love.graphics.rectangle("line", x, y, width, height)
	local barlengths = {}

	-- now we'll go through and draw the bars for the transreflector spectrum.

	brightness = ((Sensor.currentRefresh-sensor_t)/Sensor.currentRefresh)*.6 + .4
	-- love.graphics.setColor(brightness, brightness, brightness)

	if Sensor.lastSpectrum ~= nil then
		barlengths = Sensor.lastSpectrum
	else
		barlengths = Spectrum.zeroSpectrum()
	end

	for i=1,100,1
	do
		bx = x+2
		by = y+3*i
		bwidth = width - 4
		bheight = 2
		love.graphics.setColor(.4,.4,.5)
		love.graphics.rectangle("fill", bx, by, 2, 2)
		if barlengths[i] > 0 then
			love.graphics.setColor(brightness,brightness,brightness)
			love.graphics.rectangle("fill", bx+2, by, barlengths[i]*100, 2)
		end
	end
end