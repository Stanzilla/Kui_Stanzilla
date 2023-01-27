-- luacheck: globals KuiNameplates KuiNameplatesCore

-- add the unit's target's name at the bottom right of the nameplate
local folder, ns = ...
local addon = KuiNameplates
local core = KuiNameplatesCore
local LSM = LibStub("LibSharedMedia-3.0")

local mod = addon:NewPlugin("TargetName", 101, 5)
if not mod then
	return
end

local FONT_STYLE_ASSOC = {
	"",
	"THINOUTLINE",
	"",
	"THINOUTLINE",
	"THINOUTLINE MONOCHROME",
}

local UPDATE_INTERVAL = 0.1
local interval = 0

local function ClassColorName(unit)
	local _, class = UnitClass(unit)
	if not class then
		return
	end
	unitName = UnitName(unit)
	unitName = unitName:gsub("(.[\128-\191]*)%S+%s", "%1.")
	return RAID_CLASS_COLORS[class]:WrapTextInColorCode(unitName)
end

local player = UnitGUID("player")

local update = CreateFrame("Frame")
update:SetScript("OnUpdate", function(self, elap)
	-- units changing target doesn't fire an event, so we have to check constantly
	interval = interval + elap

	if interval >= UPDATE_INTERVAL then
		interval = 0

		for _, f in addon:Frames() do
			if f:IsShown() and f.unit then
				local name = f.unit .. "target"
				if name and UnitGUID(f.unit .. "target") ~= player then
					f.TargetName:SetText(ClassColorName(name))
				else
					f.TargetName:SetText("")
				end
			end
		end
	end
end)

function mod:Create(frame)
	local tn = frame:CreateFontString(nil, "OVERLAY")
	local path = LSM:Fetch(LSM.MediaType.FONT, core.profile.font_face)
	local size = 12
	local flags = FONT_STYLE_ASSOC[core.profile.font_style]

	tn:SetFont(path, size, flags)
	tn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, -8)
	tn:SetJustifyH("RIGHT")
	frame.TargetName = tn
end

function mod:Initialise()
	self:RegisterMessage("Create")
end
