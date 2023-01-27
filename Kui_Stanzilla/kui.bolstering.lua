local name = ...
local addon = KuiNameplates
local core = KuiNameplatesCore
local mod = addon:NewPlugin("Bolstering", 101)
if not mod then
	return
end

function mod.Bolster(f)
	if f.id == 99 then
		local c = 0
		for i = 1, 40 do
			local name, _, count, _, duration, expiration, _, can_purge, _, spellid = UnitAura(f.parent.unit, i)
			if name and name == "Bolster" then
				c = c + 1
			end
		end
		-- print(UnitName(f.parent.unit), c)
		if c > 1 then
			for _, button in ipairs(f.buttons) do
				if button.spellid == 209859 then
					button.count:SetText(c)
					button.count:Show()
					break
				end
			end
		end
	end
end

function mod:Create(f)
	local auras = f.handler:CreateAuraFrame({
		id = 99,
		max = 1,
		size = 42,
		squareness = 1,
		point = { "CENTER", "LEFT", "RIGHT" },
		rows = 1,
		filter = "HELPFUL",
		centred = true,
		whitelist = {
			[209859] = true, -- Mythic Plus Affix: Bolstering
		},
	})
	auras:SetFrameLevel(0)
	auras:SetWidth(42)
	auras:SetHeight(42)
	auras:SetPoint("BOTTOM", f.bg, "TOP", 0, 42)
	f.EnemyAuras = auras
end

function mod:Initialise()
	self:RegisterMessage("Create")
	self:AddCallback("Auras", "PostUpdateAuraFrame", self.Bolster)
end
