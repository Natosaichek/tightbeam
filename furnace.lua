-- Nuclear Furnace
Furnace = {powerlevel = 0, targetPowerlevel = 0, maxRate = 2, maxPowerlevel = 5000}

function Furnace.setTargetPower(newPowerlevel)
	if newPowerlevel > Furnace.maxPowerlevel then
		newPowerlevel = Furnace.maxPowerlevel
	end
	if newPowerlevel < 0 then
		newPowerlevel = 0
	end
	Furnace.targetPowerlevel = newPowerlevel
end

function Furnace.adjustPower(dt)
	deltapower = Furnace.targetPowerlevel-Furnace.powerlevel
	if math.abs(deltapower/dt) < Furnace.maxRate then
		Furnace.powerlevel = Furnace.targetPowerlevel
	else
		if deltapower > 0 then
			Furnace.powerlevel = Furnace.powerlevel+Furnace.maxRate
		else
			Furnace.powerlevel = Furnace.powerlevel-Furnace.maxRate
		end
	end
end

function Furnace.providePower(requested, dt)
	-- provide the requested power. 
	-- for now, all power is excess.
	excessPowerlevel = Furnace.powerlevel
	return excessPowerlevel
end

