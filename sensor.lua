-- default values for the sensor

Sensor = {refresh = .5, deltat = .01, last_update = 0}

function Sensor:displayableSpectrum(spectrum)
	-- at best conditions, we update our display of the enemy shield spectrum every "refresh" period
	-- as we warm up, the refresh period increases and our probability of getting a full read on the enemy shield decreases
end


-- depict op_transreflector
function sensorInterface(x,y)
	-- in this function we'll display the existing transreflector spectrum, and also listen for updates to it from mouse events.
	-- first we'll set up the position and size of the box
	local width = 106
	local height = 304
	
	love.graphics.rectangle("line", x, y, width, height)
	local barlengths = {}

	-- now we'll go through and draw the bars for the transreflector spectrum.
	if parsedTransreflector ~= nil then
		barlengths = parsedTransreflector	
	else 
		for i=1,100,1 do
			barlengths[i] = 0
		end
	end
	for i=1,100,1
	do
		bx = x+2
		by = y+3*i
		bwidth = width - 4
		bheight = 2
		love.graphics.setColor(.4,.4,.5)
		love.graphics.rectangle("fill", bx, by, 2, 2)
		love.graphics.rectangle("fill", bx+2, by, barlengths[i]*100, 2)
	end
end