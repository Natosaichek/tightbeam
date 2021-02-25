local spec = require("spectrum")
local sensor = require("sensor")
local laser = require("laser")
local capacitorbank = require("capacitorbank")
local furnace = require("furnace")
local transreflector = require("transreflector")
local radiator = require("radiator")

Player = {}

function Player:create()
	-- Player has a laser, transreflector, furnace, radiator, capacitorbank, sensor
	p = {}
	setmetatable(p, self)
    self.__index = self
    p.sensor = Sensor:create()
    p.laser = Laser:create()
    p.capacitorbank = CapacitorBank:create()
    p.furnace = Furnace:create()
    p.transreflector = Transreflector:create()
    p.radiator = Radiator:create()
	return p
end

function Player:update(dt, parsedTransreflector)
	-- the radiator emits energy at some rate, that is, there is a power level for it at 
	-- each point in it's spectrum.  how much energy has left in the past dt? Well, we'll just dump it:
	self.radiator:radiateEnergy(dt)
	-- our radiated spectrum is a power spectrum
	local radiatedSpectrum = self.radiator:spectrum()
	local internallyReflectedSpectrum = self.transreflector:reflect(radiatedSpectrum)
	self.radiator:addPowerSpectrum(internallyReflectedSpectrum, dt)
	-- any reflected energy has now been reabsorbed.

	-- our furnace takes time to adjust its power level.
	self.furnace:adjustPower(dt)

	-- are any capacitors set for charging?
		-- if so, distribute power from furnace into capacitors, unless it's full.
		-- if not, put power from furnace into radiator.
	local excessEnergy = self.capacitorbank:consumePower(self.furnace, dt) -- if there is excess energy this dt because the capacitors are full, then we dump it.
	self.radiator:addEnergy(excessEnergy)

	-- are any capacitors set for discharging?
	-- if so, discharge from capacitors through the laser
	self.capacitorbank:discharge(self.laser, dt)

	-- sensor display is afffected by radiator temperature.
	self.sensor:updateDisplay(self.radiator.temperature, parsedTransreflector)

	-- grab and store/send the laser sent energy
	self.laserEnergySpectrum = self.laser:send()
	
end

function Player:reset()
	self.laser:reset()
	self.capacitorbank:reset()
	self.furnace:reset()
	self.transreflector:reset()
	self.radiator:reset()
	self.sensor:reset()
end
