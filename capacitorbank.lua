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
