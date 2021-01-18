local default_spectrum = {}
for i = 1, 100, 1
do
	default_spectrum[i] = .5
end

Transreflector = {spectrum = default_spectrum}

function Transreflector:reset()
	for i = 1, 100, 1
	do
		self.spectrum[i] = .5
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

function Transreflector:adjustSpectrum(index, magnitude, direction, depth)
	if magnitude < 0 then 
		magnitude = 0
	end
	self.spectrum[index] = magnitude
	if ((index > 1) and direction[1]==1) then
		local delta = math.abs(self.spectrum[index-1]-magnitude)
		if delta > (depth/100) then
			self:adjustSpectrum(index-1, (self.spectrum[index-1]+magnitude)/2, {1,0}, depth +1)
		end
	end
	if (index < 100 and direction[2]==1) then
		local delta = math.abs(self.spectrum[index+1]-magnitude)
		if delta > (depth/100) then 
			self:adjustSpectrum(index+1, (self.spectrum[index+1]+magnitude)/2, {0,1}, depth +1)
		end
	end
end

function transreflectorInterface(x,y)
	-- in this function we'll display the existing transreflector spectrum, and also listen for updates to it from mouse events.
	-- first we'll set up the position and size of the box
	local width = 106
	local height = 304
	
	-- if the mouse goes over the box, highlight it.
	if mouseinBox(x,y,width,height) then
		love.graphics.setColor(.8, .8, .9)
	else
		love.graphics.setColor(.4, .4, .45)
	end
	love.graphics.rectangle("line", x, y, width, height)
	
	-- now we'll go through and draw the bars for the transreflector spectrum.
	barlengths = Transreflector.spectrum
	local displayLaser = {}

	if parsedLaser == nil then 
		for i=1,100,1 do		
			displayLaser[i] = 0
		end
	else
		displayLaser = parsedLaser
	end

	for i=1,100,1
	do
		bx = x+2
		by = y+3*i
		bwidth = width - 4
		bheight = 2
		-- if the mouse is over one of the bars, then we highlight that bar and also enable changing the spectrum value.
		if mouseinBox(bx, by-1, bwidth, bheight+2) then
			love.graphics.setColor(.9, .9, .95)
			if love.mouse.isDown(1) then
				mx = love.mouse.getX()
				magnitude = (mx-bx) / 100
				Transreflector:adjustSpectrum(i, magnitude, {1,1}, 0)
			end
		else
			love.graphics.setColor(.7,.7,.75)
		end

		if displayLaser[i] > 10 then
			love.graphics.setColor(.7,.5,.45)
		end

		love.graphics.rectangle("fill", bx, by, 2, 2)
		love.graphics.rectangle("fill", bx+2, by, barlengths[i]*100, 2)
	end
end