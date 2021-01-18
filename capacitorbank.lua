-- default values for Capacitor and bank
Capacitor = {capacity = 10000, stored = 0, charging = false, discharging = false}

function Capacitor:create(c) -- we need a bunch of caps so this will be a, like, class for capacitors? or a prototype?
	c = c or {}
	setmetatable(c, self)
    self.__index = self
	return c
end

function Capacitor:charge(qty)
	remaining = self.capacity - self.stored
	if remaining >= qty then
		self.stored = self.stored + qty
		return true
	else
		self.stored = self.capacity
		return false
	end
end

function Capacitor:discharge(qty)
	if self.stored >= qty then
		self.stored = self.stored - qty
		return true
	else
		self.stored = 0
		return false
	end
end

function Capacitor:setCharging()
	self.discharging = false
	self.charging = true
end
function Capacitor:setDischarging()
	self.discharging = true
	self.charging = false
end
function Capacitor:setDisconnected()
	self.discharging = false
	self.charging = false
end

CapacitorBank = {qty = 5, capacitors = {}}
for i = 1, CapacitorBank.qty, 1
do
	CapacitorBank.capacitors[i] = Capacitor:create{}
end

function CapacitorBank.reset()
	for i = 1, CapacitorBank.qty, 1
	do
		CapacitorBank.capacitors[i] = Capacitor:create{}
	end
end
function CapacitorBank.consumePower(furnace, dt)
	local chargingcaps = {}
	for i = 1, CapacitorBank.qty,  1
	do
		c = CapacitorBank.capacitors[i]
		if c.charging then
			if c.capacity > c.stored then 
				table.insert(chargingcaps, c)
			end
		end
	end
	nreceivers = table.maxn(chargingcaps) 
	energyAvailable = furnace.powerlevel*dt
	-- even though a cap technically might not have enough capacity to accommodate all the power, 
	-- we'll pretend they can overcharge a little bit and not worry about the remainder for now.
	if nreceivers > 0 then
		percapEnergy = energyAvailable / table.maxn(chargingcaps) 
		for i,c in ipairs(chargingcaps) do
			c:charge(percapEnergy)
		end
	else
		-- return the leftover energy
		return energyAvailable
	end
	-- if we consumed it all, there's no leftover energy.
	return 0
end

function CapacitorBank.discharge(laser, dt)
	-- dump discharging capacitors through the laser.
	local dumpingcaps = {}
	for i = 1, CapacitorBank.qty,  1
	do
		c = CapacitorBank.capacitors[i]
		if c.discharging then
			if c.stored > 0 then 
				table.insert(dumpingcaps, c)
			end
		end
	end
	ndumpers = table.maxn(dumpingcaps)
	if ndumpers == 0 then
		laser:off()
	else
		storedEnergy = 0
		for i,c in ipairs(dumpingcaps)
		do
			storedEnergy = storedEnergy + c.stored
		end
		usedEnergy = laser:consume(storedEnergy, dt)
		for i,c in ipairs(dumpingcaps)
		do
			if c.stored < usedEnergy then
				usedEnergy = usedEnergy-c.stored
				c.stored = 0
			else
				c.stored = c.stored - usedEnergy
				usedEnergy = 0
			end
		end
	end
end


function capacitorInterface(x,y)
	-- depict each capacitor and enable keyboard and mouse control of them.
	local capradius = 20
	local controlRadius = capradius/2
	local margin = 10
	local width = (capradius*2+margin)*CapacitorBank.qty+margin
	local height = (capradius+margin)*2

	capChargeColor = {.7,.5,.1}
	capChargeSelectedColor = {.8,.7,.3}
	capDischargeColor = {.1,.5,.7}
	capDischargeSelectedColor = {.3,.7,.8}
	capDisabledColor = {.4,.4,.4}
	capDisabledSelectedColor = {.6,.6,.6}
	-- if the mouse goes over the box, highlight it.
	if mouseinBox(x,y,width,height) then
		love.graphics.setColor(.4, .4, .9)
	else
		love.graphics.setColor(.2, .2, .6)
	end
	love.graphics.rectangle("line", x, y, width, height)
	for i,c in ipairs(CapacitorBank.capacitors)
	do
		cx = x + i*(capradius*2+margin) - capradius
		cy = y + (capradius+margin)
		fillratio = c.stored/c.capacity
		fillradius = capradius*fillratio
		if c.charging then
			love.graphics.setColor({.5,.3,.05})
		elseif c.discharging then
			love.graphics.setColor({.05,.3,.5})
		else
			love.graphics.setColor(capDisabledColor)			
		end
		love.graphics.circle("fill",cx,cy,fillradius,36)

		-- for each capacitor, highlight the perimeter appropriately to how the cap is.
		if mouseinCircle(cx,cy,capradius) then
			if c.charging then
				love.graphics.setColor(capChargeSelectedColor)
			elseif c.discharging then
				love.graphics.setColor(capDischargeSelectedColor)
			else
				love.graphics.setColor(capDisabledSelectedColor)
			end
		else
			if c.charging then
				love.graphics.setColor(capChargeColor)
			elseif c.discharging then
				love.graphics.setColor(capDischargeColor)
			else
				love.graphics.setColor(capDisabledColor)			
			end
		end
		love.graphics.circle("line",cx,cy,capradius,36)
		-- now draw the 'charge' and 'discharge' selection buttons
		dc_cx = cx-(capradius/2)
		dc_cy = cy
		if mouseinCircle(dc_cx,dc_cy,controlRadius) then
			love.graphics.setColor(capDischargeSelectedColor)
			if love.mouse.isDown(1) then
				c:setDischarging()
			end
		else
			love.graphics.setColor(capDischargeColor)
		end
		love.graphics.circle("fill",dc_cx,dc_cy,controlRadius,24)

		c_cx = cx+(capradius/2)
		c_cy = cy
		if mouseinCircle(c_cx,c_cy,controlRadius) then
			changestate = false
			love.graphics.setColor(capChargeSelectedColor)
			if love.mouse.isDown(1) then
				c:setCharging()
			end
		else
			love.graphics.setColor(capChargeColor)
		end
		love.graphics.circle("fill",c_cx,c_cy,controlRadius,24)
	end
end