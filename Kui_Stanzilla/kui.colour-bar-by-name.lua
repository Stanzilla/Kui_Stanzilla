-- luacheck: globals KuiNameplates KuiNameplatesCore plugin_fading

-- colours nameplate healthbars depending on their name
local folder, ns = ...
local addon = KuiNameplates
local core = KuiNameplatesCore

local mod = addon:NewPlugin("ColourBarByName", 101, 5)
if not mod then
	return
end

-- table of names -> bar colours (r,g,b)
local names = {
	["Arcane Sentinel"] = { 1, 0, 0 },
	["Duskwatch Battlemaster"] = { 1, 0, 1 },
	["Volatile Scorpid"] = { 1, 0, 1 },
	["Leystalker Dro"] = { 1, 0, 1 },
	["Hand from Beyond"] = { 1, 0, 1 },
	["Explosives"] = { 1, 0, 1 },
	["Spawn of G'huun"] = { 1, 1, 0 },
	["Scrimshaw Racketeer"] = { 1, 0, 0 },
	["Enchanted Emissary"] = { 1, 1, 0 },
	["Void-Touched Emissary"] = { 1, 1, 0 },
	["Emissary of the Tides"] = { 1, 1, 0 },
	["Invigorating Fish Stick"] = { 1, 1, 0 },
}

-- table of names -> frame alpha
local names_fade = {
	["Explosives"] = 1,
	["Spawn of G'huun"] = 1,
	["Invigorating Fish Stick"] = 1,
}

-- comment out the next line (by adding two dashes at the start, like this) to
-- disable target colouring:
local COLOUR_TARGET = { 0.4, 0.8, 0.4 }

-- To overwrite tank mode, set this to 6
-- To overwrite execute, set this to 5
local PRIORITY = 2

-- local functions #############################################################
-- reimplemented locally in execute & tankmode
local function CanOverwriteHealthColor(f)
	return not f.state.health_colour_priority or f.state.health_colour_priority <= PRIORITY
end

-- messages ####################################################################
function mod.Fading_FadeRulesReset()
	plugin_fading:AddFadeRule(function(f)
		return f.state.name and names_fade[f.state.name]
	end, 1)
end

function mod:NameUpdate(frame)
	if COLOUR_TARGET and frame.handler:IsTarget() then
		return
	end

	local col = frame.state.name and names[frame.state.name]

	if frame.state.name and names_fade[frame.state.name] then
		plugin_fading:UpdateFrame(frame)
	end

	if not col and frame.state.bar_is_name_coloured then
		frame.state.bar_is_name_coloured = nil

		if CanOverwriteHealthColor(frame) then
			frame.state.health_colour_priority = nil
			frame.HealthBar:SetStatusBarColor(unpack(frame.state.healthColour))
		end
	elseif col then
		if CanOverwriteHealthColor(frame) then
			frame.state.bar_is_name_coloured = true
			frame.state.health_colour_priority = PRIORITY

			frame.HealthBar:SetStatusBarColor(unpack(col))
		end
	end
end

function mod:UNIT_NAME_UPDATE(event, frame)
	self:NameUpdate(frame)
end

function mod:GainedTarget(frame)
	if not COLOUR_TARGET then
		return
	end
	if CanOverwriteHealthColor(frame) then
		frame.state.bar_is_name_coloured = true
		frame.state.health_colour_priority = PRIORITY
		frame.HealthBar:SetStatusBarColor(unpack(COLOUR_TARGET))
	end
end

-- initialise ##################################################################
function mod:Initialise()
	self:RegisterMessage("Show", "NameUpdate")
	self:RegisterMessage("HealthColourChange", "NameUpdate")
	self:RegisterMessage("LostTarget", "NameUpdate")
	self:RegisterUnitEvent("UNIT_NAME_UPDATE")

	self:RegisterMessage("GainedTarget", "TargetUpdate")

	plugin_fading = addon:GetPlugin("Fading")

	self:AddCallback("Fading", "FadeRulesReset", self.Fading_FadeRulesReset)
	self.Fading_FadeRulesReset()
end
