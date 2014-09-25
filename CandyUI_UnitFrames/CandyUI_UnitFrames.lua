-----------------------------------------------------------------------------------------------
-- Client Lua Script for CandyUI_UnitFrames
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
--DEVELOPER LICENSE
-- CandyUI - Copyright (C) 2014 Neil Smith
-- This work is licensed under the GNU GENERAL PUBLIC LICENSE.
-- A copy of this license is included with this release.
-----------------------------------------------------------------------------------------------

require "Window"
 
-----------------------------------------------------------------------------------------------
-- CandyUI_UnitFrames Module Definition
-----------------------------------------------------------------------------------------------
local CandyUI_UnitFrames = {} 

--%%%%%%%%%%%
--   ROUND
--%%%%%%%%%%%
local function round(num, idp)
    local mult = 10^(idp or 0)
    if num >= 0 then return math.floor(num * mult + 0.5) / mult
    else return math.ceil(num * mult - 0.5) / mult end
end
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999

local karClassToIcon =
{
	[GameLib.CodeEnumClass.Warrior] 		= "Sprites:Class_Warrior",
	[GameLib.CodeEnumClass.Engineer] 		= "Sprites:Class_Engineer",
	[GameLib.CodeEnumClass.Esper] 			= "Sprites:Class_Esper",
	[GameLib.CodeEnumClass.Medic] 			= "Sprites:Class_Medic",
	[GameLib.CodeEnumClass.Stalker] 		= "Sprites:Class_Stalker",
	[GameLib.CodeEnumClass.Spellslinger] 	= "Sprites:Class_Spellslinger",
}
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function CandyUI_UnitFrames:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function CandyUI_UnitFrames:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end

-----------------------------------------------------------------------------------------------
-- CandyUI_UnitFrames OnLoad
-----------------------------------------------------------------------------------------------
function CandyUI_UnitFrames:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("CandyUI_UnitFrames.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
	self.db = Apollo.GetPackage("Gemini:DB-1.0").tPackage:New(self, kcuiUFDefaults)
end

-----------------------------------------------------------------------------------------------
-- CandyUI_UnitFrames OnDocLoaded
-----------------------------------------------------------------------------------------------
function CandyUI_UnitFrames:OnDocLoaded()
		
	Apollo.LoadSprites("Sprites.xml")

	self.wndPlayerUF = Apollo.LoadForm(self.xmlDoc, "PlayerUF", nil, self)
	for i=1, 4 do
		local wndCurr = Apollo.LoadForm(self.xmlDoc, "ClusterTarget", self.wndPlayerUF:FindChild("ClusterFrame"), self)
	end
	self.wndPlayerUF:FindChild("ClusterFrame"):ArrangeChildrenVert()
	self.wndTargetUF = Apollo.LoadForm(self.xmlDoc, "TargetUF", nil, self)
	for i=1, 4 do
		local wndCurr = Apollo.LoadForm(self.xmlDoc, "ClusterTarget", self.wndTargetUF:FindChild("ClusterFrame"), self)
	end
	self.wndTargetUF:FindChild("ClusterFrame"):ArrangeChildrenVert()
	self.wndToTUF = Apollo.LoadForm(self.xmlDoc, "ToTUF", nil, self)
	self.wndToTUF:Show(false, true)
	self.wndFocusUF = Apollo.LoadForm(self.xmlDoc, "TargetUF", nil, self)
	self.wndFocusUF:SetName("FocusUF")
	self.wndFocusUF:Show(false, true)
	self.wndFocusUF:FindChild("Glow"):Show(true, true)
	
	self.OptionsAddon = Apollo.GetAddon("CandyUI_Options")
	self.wndOptionsMain = self.OptionsAddon.wndOptions
	assert(self.wndOptionsMain ~= nil, "\n\n\nOptions Not Loaded\n\n")
	--local wndCurr = Apollo.LoadForm(self.xmlDoc, "OptionsListItem", self.wndOptionsMain:FindChild("ListControls"), self)
	--wndCurr:SetText("Unit Frames")
	
	self.wndControls = Apollo.LoadForm(self.xmlDoc, "OptionsControlsList", self.wndOptionsMain:FindChild("OptionsDialogueControls"), self)
	
	self.wndControls:Show(false, true)
	--[[
	if not candyUI_Cats then
		candyUI_Cats = {}
	end
	table.insert(candyUI_Cats, "UnitFrames")
	]]
		--self.wndControls:Show(false)
		--[[
		for i, v in ipairs(self.wndControls:GetChildren()) do
			if v:GetName() ~= "Help" then
			local strCategory = v:FindChild("Title"):GetText()
			local wndCurr = Apollo.LoadForm(self.xmlDoc, "OptionsListItem", self.wndOptionsNew:FindChild("ListControls"), self)
			wndCurr:SetText(strCategory)
			end
		end
		]]
		--self.wndOptionsMain:FindChild("ListControls"):ArrangeChildrenVert()
	
	--CandyUI_OptionsLoaded
	self.bOptionsSet = CUI_RegisterOptions("UnitFrames", self.wndControls)
	if not self.bOptionsSet then
		Apollo.RegisterEventHandler("CandyUI_OptionsLoaded", "OnCUIOptionsLoaded", self)
	end
		
	--Color Picker
	GeminiColor = Apollo.GetPackage("GeminiColor").tPackage
  	self.colorPicker = GeminiColor:CreateColorPicker(self, "ColorPickerCallback", false, "ffffffff")
	self.colorPicker:Show(false, true)
	
	--Apollo.RegisterEventHandler("CandyUI_UnitFramesClicked", "OnOptionsHome", self)
	Apollo.RegisterEventHandler("VarChange_FrameCount", "OnCharacterLoaded", self)
	Apollo.RegisterEventHandler("CharacterCreated", "OnCharacterLoaded", self)
	Apollo.RegisterEventHandler("TargetUnitChanged", "OnTargetUnitChanged", self)
	Apollo.RegisterEventHandler("AlternateTargetUnitChanged", "OnAlternateTargetUnitChanged", self)
	
	self.wndPlayerUF:SetAnchorOffsets(unpack(self.db.profile.player.tAnchorOffsets))
	self.wndTargetUF:SetAnchorOffsets(unpack(self.db.profile.target.tAnchorOffsets))
	self.wndFocusUF:SetAnchorOffsets(unpack(self.db.profile.focus.tAnchorOffsets))
	self.wndToTUF:SetAnchorOffsets(unpack(self.db.profile.tot.tAnchorOffsets))	
	
	if GameLib.GetPlayerUnit() and GameLib.GetPlayerUnit():GetTarget() then
		self:OnTargetUnitChanged(GameLib.GetPlayerUnit():GetTarget())
	end
	
	self:SetOptions()	
	self:SetLooks()
end

function CandyUI_UnitFrames:OnCUIOptionsLoaded()
	CUI_RegisterOptions("UnitFrames", self.wndControls)
	--Print("Resources saw Options load") --debug
end

function CandyUI_UnitFrames:OnOptionsHome()
	self.wndOptionsMain:FindChild("ListControls"):DestroyChildren()
	for i, v in ipairs(self.wndControls:GetChildren()) do
		if v:GetName() ~= "Help" then
			local strCategory = v:FindChild("Title"):GetText()
			local wndCurr = Apollo.LoadForm(self.xmlDoc, "OptionsListItem", self.wndOptionsMain:FindChild("ListControls"), self)
			wndCurr:SetText(strCategory)
		end
	end
	self.wndOptionsMain:FindChild("ListControls"):ArrangeChildrenVert()
	
	self.wndOptionsMain:FindChild("OptionsDialogueControls"):DestroyChildren()
	self.wndControls = Apollo.LoadForm(self.xmlDoc, "OptionsControlsList", self.wndOptionsMain:FindChild("OptionsDialogueControls"), self)
	self:SetOptions()	
end

function CandyUI_UnitFrames:OnOptionsHeaderCheck(wndHandler, wndControl, eMouseButton)
	for i, v in ipairs(self.wndControls:GetChildren()) do
		if v:FindChild("Title"):GetText() == wndControl:GetText() then
			v:Show(true)
		else
			v:Show(false)
		end
	end
end

function CandyUI_UnitFrames:OnTargetUnitChanged(unitTarget)
	if unitTarget ~= nil and unitTarget:GetMaxHealth() ~= nil then
		self.wndTargetUF:Show(true)
		--self.arTargetClusters = self:GetClusters(unitTarget)
		self:UpdateUnitFrame(self.wndTargetUF, unitTarget)
		if unitTarget:GetTarget() ~= nil and unitTarget:GetTarget():GetMaxHealth() ~= nil and self.db.profile.tot.bShow then
			self.wndToTUF:Show(true)
			self:UpdateToT(unitTarget:GetTarget())
		else
			self.wndToTUF:Show(false)
		end
	else
		self.wndTargetUF:Show(false)
		self.wndToTUF:Show(false)
	end
	
	
end

function CandyUI_UnitFrames:OnAlternateTargetUnitChanged(unitTarget)
	if unitTarget ~= nil and unitTarget:GetMaxHealth() ~= nil then
		self.wndFocusUF:Show(true)
		self:UpdateUnitFrame(self.wndFocusUF, unitTarget)
		
	else
		self.wndFocusUF:Show(false)
	end
end

function CandyUI_UnitFrames:OnUpdate()
	local uPlayer = GameLib.GetPlayerUnit()
	if not uPlayer then
		--self:OnCharacterCreated()
		return
	end
	local x = math.floor(uPlayer:GetHealth())
	local y = math.floor(uPlayer:GetMaxHealth())

	self.wndPlayerUF:FindChild("HealthBar"):SetMax(y)
	self.wndPlayerUF:FindChild("ShieldBar"):SetMax(uPlayer:GetShieldCapacityMax())
	self.wndPlayerUF:FindChild("ManaBar"):SetMax(uPlayer:GetMaxMana())
	self.wndPlayerUF:FindChild("Name"):SetText(uPlayer:GetName())
	self.wndPlayerUF:FindChild("BuffContainerWindow"):SetUnit(uPlayer)
	self.wndPlayerUF:FindChild("HealthBar"):SetProgress(x)
	--Print(x)
	self.wndPlayerUF:FindChild("ShieldBar"):SetProgress(uPlayer:GetShieldCapacity())
	self.wndPlayerUF:FindChild("ManaBar"):SetProgress(uPlayer:GetMana())
	
end

function CandyUI_UnitFrames:OnCharacterLoaded()
	local unitPlayer = GameLib.GetPlayerUnit()
	
	if unitPlayer ~= nil then
		local unitTarget = unitPlayer:GetTarget()
		local unitFocus = unitPlayer:GetAlternateTarget()
	
		self.arPlayerClusters = self:GetClusters(unitPlayer)
		self:UpdateUnitFrame(self.wndPlayerUF, unitPlayer)
		self:UpdateClusters(self.arPlayerClusters, self.wndPlayerUF)
		self.wndPlayerUF:SetData(unitPlayer)
		if unitTarget ~= nil and unitTarget:GetMaxHealth() ~= nil then
			self.arTargetClusters = self:GetClusters(unitTarget)
			self:UpdateClusters(self.arTargetClusters, self.wndTargetUF)
			self:UpdateUnitFrame(self.wndTargetUF, unitTarget)
			self.wndTargetUF:SetData(unitTarget)
			if unitTarget:GetTarget() ~= nil and unitTarget:GetTarget():GetMaxHealth() ~= nil then
				--self.wndToTUF:Show(true)
				self.wndToTUF:SetData(unitTarget:GetTarget())
				self:UpdateToT(unitTarget:GetTarget())
			end
		end
		self:UpdateUnitFrame(self.wndFocusUF, unitFocus)
		self.wndFocusUF:SetData(unitFocus)
	end
end

function CandyUI_UnitFrames:HelperFormatBigNumber(nArg)
	if nArg < 1000 then
		strResult = tostring(nArg)
	elseif nArg < 1000000 then
		if math.floor(nArg%1000/100) == 0 then
			strResult = String_GetWeaselString(Apollo.GetString("TargetFrame_ShortNumberWhole"), math.floor(nArg / 1000))
		else
			strResult = String_GetWeaselString(Apollo.GetString("TargetFrame_ShortNumberFloat"), nArg / 1000)
		end
	elseif nArg < 1000000000 then
		if math.floor(nArg%1000000/100000) == 0 then
			strResult = String_GetWeaselString(Apollo.GetString("TargetFrame_MillionsNumberWhole"), math.floor(nArg / 1000000))
		else
			strResult = String_GetWeaselString(Apollo.GetString("TargetFrame_MillionsNumberFloat"), nArg / 1000000)
		end
	elseif nArg < 1000000000000 then
		if math.floor(nArg%1000000/100000) == 0 then
			strResult = String_GetWeaselString(Apollo.GetString("TargetFrame_BillionsNumberWhole"), math.floor(nArg / 1000000))
		else
			strResult = String_GetWeaselString(Apollo.GetString("TargetFrame_BillionsNumberFloat"), nArg / 1000000)
		end
	else
		strResult = tostring(nArg)
	end
	return strResult
end

function CandyUI_UnitFrames:UpdateUnitFrame(wndFrame, uUnit)

	if uUnit == nil then
		
		return
	end
	
	--wndFrame:Show(true)
--set up frame
	--name
	local strSeperator = " - "
	local strName = uUnit:GetName()
	local nLevel = uUnit:GetLevel() or ""
	local crName = uUnit:GetNameplateColor()
	
	--Name
	wndFrame:FindChild("Name"):SetText(strName..strSeperator..nLevel)
	wndFrame:FindChild("Name"):SetTextColor(crName)
	
	--Buffs/Debuffs
	wndFrame:FindChild("BuffContainerWindow"):SetUnit(uUnit)
	wndFrame:FindChild("DebuffContainerWindow"):SetUnit(uUnit)
	
	--Bars
	local barHealth = wndFrame:FindChild("HealthBar:Bar")
	local barShield = wndFrame:FindChild("ShieldBar:Bar")
	local barMana = wndFrame:FindChild("ManaBar:Bar")
	--wndFrame:FindChild("HealthBarBG"):Show(false, true)
	--wndFrame:FindChild("HealthBarBG"):Show(true, true)
	--wndFrame:FindChild("HealthBarBG"):ToFront(true)
	--barHealth:ToFront(true)
	
	--Absorb
	local nAbsorbCurr = 0
	local nAbsorbMax = uUnit:GetAbsorptionMax()
	if nAbsorbMax > 0 then
		nAbsorbCurr = uUnit:GetAbsorptionValue()
	end
	self:SetBarValue( wndFrame:FindChild("HealthBar:AbsorbBar"), nAbsorbCurr, 0, nAbsorbMax)
	--[[
	local bShowAbsorbText = wndFrame:GetName() == "PlayerUF" and self.db.profile.player.bAbsorbText or wndFrame:GetName() == "TargetUF" and self.db.profile.target.bAbsorbText or wndFrame:GetName() == "FocusUF" and self.db.profile.focus.bAbsorbText
	if bShowAbsorbText and nAbsorbMax > 0 then
		wndFrame:FindChild("HealthBar:AbsorbBar"):SetText(self:HelperFormatBigNumber(nAbsorbCurr).." / "..self:HelperFormatBigNumber(nAbsorbMax))
	else
		wndFrame:FindChild("HealthBar:AbsorbBar"):SetText("")
	end
	]]
	--Health
	local nHealthMax = uUnit:GetMaxHealth()
	local nHealthCurr = uUnit:GetHealth()
	local nHealthPerc = round((nHealthCurr/nHealthMax) * 100)
	self:SetBarValue(barHealth, nHealthCurr, 0, nHealthMax)
	
	--Health Text
	local nShowHealthText = wndFrame:GetName() == "PlayerUF" and self.db.profile.player.nHealthText or wndFrame:GetName() == "TargetUF" and self.db.profile.target.nHealthText or wndFrame:GetName() == "FocusUF" and self.db.profile.focus.nHealthText
	local nHealthFormat = wndFrame:GetName() == "PlayerUF" and self.db.profile.player.nHealthFormat or wndFrame:GetName() == "TargetUF" and self.db.profile.target.nHealthFormat or wndFrame:GetName() == "FocusUF" and self.db.profile.focus.nHealthFormat
	local bShowHealthText = nShowHealthText == 1 or nShowHealthText == 2
	
	barHealth:FindChild("Text"):Show(bShowHealthText, true)
	barHealth:FindChild("Text"):SetStyle("AutoFade", nShowHealthText == 2)
	if nShowHealthText == 1 and barHealth:FindChild("Text"):GetOpacity() < 1 then
		barHealth:FindChild("Text"):SetOpacity(1)
	end
	local strHealthText = ""
	if nHealthFormat == 0 then
		--Min / Max
		strHealthText = nHealthCurr.." / "..nHealthMax
	elseif nHealthFormat == 1 then
		--Min / Max (Short)
		strHealthText = self:HelperFormatBigNumber(nHealthCurr).." / "..self:HelperFormatBigNumber(nHealthMax)
	elseif nHealthFormat == 2 then
		--Percent
		strHealthText = nHealthPerc.."%"
	elseif nHealthFormat == 3 then
		--Min / Max (Percent)
		strHealthText = self:HelperFormatBigNumber(nHealthCurr).." / "..self:HelperFormatBigNumber(nHealthMax).." ("..nHealthPerc.."%)"
	end
	local bShowShieldText = false --wndFrame:GetName() == "PlayerUF" and self.db.profile.player.bShowShieldText or wndFrame:GetName() == "TargetUF" and self.db.profile.target.bShowShieldText or wndFrame:GetName() == "FocusUF" and self.db.profile.focus.bShowShieldText 
	local nShieldPerc = "" --replace with text
	local nShieldText = "["..nShieldPerc.."%]"
	if bShowShieldText then
		barHealth:FindChild("Text"):SetText(strHealthText.." "..nShieldText)
	else
		barHealth:FindChild("Text"):SetText(strHealthText)
	end
	
	--Color by health
	local bColorByHealth = wndFrame:GetName() == "PlayerUF" and self.db.profile.player.bColorByHealth or wndFrame:GetName() == "TargetUF" and self.db.profile.target.bColorByHealth or wndFrame:GetName() == "FocusUF" and self.db.profile.focus.bColorByHealth
	if bColorByHealth then
		local nPercDec = nHealthPerc/100
		local crRed = 1-nPercDec
		local crGreen = nPercDec
		local crBlue = 0
		barHealth:SetBarColor(ApolloColor.new(crRed, crGreen, crBlue))
	end
	
	--Shield
	--wndFrame:FindChild("HealthBarBG"):SetSprite("Sprites:HealthEmpty_Grey")
	local nShieldMax = uUnit:GetShieldCapacityMax()
	local nShieldCurr = uUnit:GetShieldCapacity()
	nShieldPerc = round((nShieldCurr/nShieldMax) * 100)
	if nShieldMax ~= nil and nShieldMax > 0 then
		if barShield:IsShown() then
			self:SetBarValue(barShield, nShieldCurr, 0, nShieldMax)
			barShield:FindChild("Text"):SetText(nShieldPerc.."%")
		else
			--barShield:Show(true, true)
			wndFrame:FindChild("ShieldBar"):Show(true, true)
			wndFrame:FindChild("HealthBar"):SetSprite("Sprites:HealthEmpty_Grey")
			--barHealth:SetEmptySprite("Sprites:HealthEmpty_Grey")
			barHealth:SetFullSprite("Sprites:HealthFull_Grey")
			wndFrame:FindChild("HealthBar:AbsorbBar"):SetFullSprite("Sprites:HealthFull_Grey")
			local nsl, nst, nsr, nsb = wndFrame:FindChild("ShieldBar"):GetAnchorOffsets()
			local nhl, nht, nhr, nhb = wndFrame:FindChild("HealthBar"):GetAnchorOffsets()
			wndFrame:FindChild("HealthBar"):SetAnchorOffsets(nhl, nht, nsl-4, nhb)
			--barHealth:SetAnchorOffsets(nhl, nht, nsl-4, nhb)
			self:SetBarValue(barShield, nShieldCurr, 0, nShieldMax)
			barShield:FindChild("Text"):SetText(nShieldPerc.."%")
		end
	else
		if not barShield:IsShown() then
		--	self:SetBarValue(barShield, nShieldCurr, 0, nShieldMax)
		else
		--barShield:Show(false, true)
		wndFrame:FindChild("ShieldBar"):Show(false, true)
		wndFrame:FindChild("HealthBar"):SetSprite("Sprites:HealthEmpty_RoundedGrey")
		--barHealth:SetEmptySprite("Sprites:HealthEmpty_RoundedGrey")
		barHealth:SetFullSprite("Sprites:HealthFull_RoundedGrey")
		wndFrame:FindChild("HealthBar:AbsorbBar"):SetFullSprite("Sprites:HealthFull_RoundedGrey")
		local nhl, nht, nhr, nhb = wndFrame:FindChild("HealthBar"):GetAnchorOffsets()
		local nsl, nst, nsr, nsb = wndFrame:FindChild("ShieldBar"):GetAnchorOffsets()
		wndFrame:FindChild("HealthBar"):SetAnchorOffsets(nhl, nht, nsr, nhb)
		--barHealth:SetAnchorOffsets(nhl, nht, nsr, nhb)
		end
	end
	
	--Mana
	local nManaMax = uUnit:GetMaxMana() or 0
	local nManaCurr = uUnit:GetMana() or 0
	local nShowManaText = wndFrame:GetName() == "PlayerUF" and self.db.profile.player.nManaText or wndFrame:GetName() == "TargetUF" and self.db.profile.target.nManaText or wndFrame:GetName() == "FocusUF" and self.db.profile.focus.nManaText
	local nManaFormat = wndFrame:GetName() == "PlayerUF" and self.db.profile.player.nManaFormat or wndFrame:GetName() == "TargetUF" and self.db.profile.target.nManaFormat or wndFrame:GetName() == "FocusUF" and self.db.profile.focus.nManaFormat
	local bShowManaText = nShowManaText == 1 or nShowManaText == 2
	local nManaPerc = round((nManaCurr /nManaMax ) * 100)
			
	if nManaMax ~= nil and nManaMax > 5  then
		if barMana:IsShown() then
			self:SetBarValue(barMana, nManaCurr, 0, nManaMax)
			
			--Text
			barMana:FindChild("Text"):Show(bShowManaText, true)
			barMana:FindChild("Text"):SetStyle("AutoFade", nShowManaText == 2)
			if nShowManaText == 1 and barMana:FindChild("Text"):GetOpacity() < 1 then
				barMana:FindChild("Text"):SetOpacity(1)
			end
			local strManaText = ""
			if nManaFormat == 0 then
				--Min / Max
				strManaText = nManaCurr.." / "..nManaMax
			elseif nManaFormat == 1 then
				--Min / Max (Short)
				strManaText = self:HelperFormatBigNumber(nManaCurr).." / "..self:HelperFormatBigNumber(nManaMax)
			elseif nManaFormat == 2 then
				--Percent
				strManaText = nManaPerc.."%"
			elseif nManaFormat == 3 then
				--Min / Max (Percent)
				strManaText = self:HelperFormatBigNumber(nManaCurr).." / "..self:HelperFormatBigNumber(nManaMax).." ("..nManaPerc.."%)"
			end
			barMana:FindChild("Text"):SetText(strManaText)
		else
			--barMana:Show(true, true)
			wndFrame:FindChild("ManaBar"):Show(true)
			local nml, nmt, nmr, nmb = wndFrame:FindChild("ManaBar"):GetAnchorOffsets()
			local nhl, nht, nhr, nhb = wndFrame:FindChild("HealthBar"):GetAnchorOffsets()
			local nsl, nst, nsr, nsb = wndFrame:FindChild("ShieldBar"):GetAnchorOffsets()
			--barHealth:SetAnchorOffsets(nhl, nht, nhr, nht+29)
			wndFrame:FindChild("HealthBar"):SetAnchorOffsets(nhl, nht, nhr, nht+29)
			--barShield:SetAnchorOffsets(nsl, nst, nsr, nst+29)
			wndFrame:FindChild("ShieldBar"):SetAnchorOffsets(nsl, nst, nsr, nst+29)
			
			self:SetBarValue(barMana, nManaCurr, 0, nManaMax)
			
			--Text
			barMana:FindChild("Text"):Show(bShowManaText, true)
			barMana:FindChild("Text"):SetStyle("AutoFade", nShowManaText == 2)
			if nShowManaText == 1 and barMana:FindChild("Text"):GetOpacity() < 1 then
				barMana:FindChild("Text"):SetOpacity(1)
			end
			local strManaText = ""
			if nManaFormat == 0 then
				--Min / Max
				strManaText = nManaCurr.." / "..nManaMax
			elseif nManaFormat == 1 then
				--Min / Max (Short)
				strManaText = self:HelperFormatBigNumber(nManaCurr).." / "..self:HelperFormatBigNumber(nManaMax)
			elseif nManaFormat == 2 then
				--Percent
				strManaText = nManaPerc.."%"
			elseif nManaFormat == 3 then
				--Min / Max (Percent)
				strManaText = self:HelperFormatBigNumber(nManaCurr).." / "..self:HelperFormatBigNumber(nManaMax).." ("..nManaPerc.."%)"
			end
			barMana:FindChild("Text"):SetText(strManaText)
		end
	else
		--barMana:Show(false, true)
		wndFrame:FindChild("ManaBar"):Show(false)
		local nml, nmt, nmr, nmb = wndFrame:FindChild("ManaBar"):GetAnchorOffsets()
		local nhl, nht, nhr, nhb = wndFrame:FindChild("HealthBar"):GetAnchorOffsets()
		local nsl, nst, nsr, nsb = wndFrame:FindChild("ShieldBar"):GetAnchorOffsets()
		--barHealth:SetAnchorOffsets(nhl, nht, nhr, nmb)
		wndFrame:FindChild("HealthBar"):SetAnchorOffsets(nhl, nht, nhr, nmb)
		--barShield:SetAnchorOffsets(nsl, nst, nsr, nmb)
		wndFrame:FindChild("ShieldBar"):SetAnchorOffsets(nsl, nst, nsr, nmb)
	end
	
	--Icon
	local eRank = uUnit:GetRank()
	local strClassIconSprite = ""
	local strPlayerIconSprite = ""
	
	if uUnit:GetType() == "Player" then
		strPlayerIconSprite = karClassToIcon[uUnit:GetClassId()]
	elseif eRank == Unit.CodeEnumRank.Elite then
		strClassIconSprite = "Sprites:TargetIcon_Elite"
		strPlayerIconSprite = strClassIconSprite.."_Large"
	elseif eRank == Unit.CodeEnumRank.Superior then
		strClassIconSprite = "Sprites:TargetIcon_Superior"
		strPlayerIconSprite = strClassIconSprite.."_Large"
	elseif eRank == Unit.CodeEnumRank.Champion then
		strClassIconSprite = "Sprites:TargetIcon_Champion"
		strPlayerIconSprite = strClassIconSprite.."_Large"
	elseif eRank == Unit.CodeEnumRank.Standard then
		strClassIconSprite = "Sprites:TargetIcon_Standard"
		strPlayerIconSprite = strClassIconSprite.."_Large"
	elseif eRank == Unit.CodeEnumRank.Minion then
		strClassIconSprite = "Sprites:TargetIcon_Minion"
		strPlayerIconSprite = strClassIconSprite.."_Large"
	elseif eRank == Unit.CodeEnumRank.Fodder then
		strClassIconSprite = "Sprites:TargetIcon_Fodder"
		strPlayerIconSprite = strClassIconSprite.."_Large"
	end
		
	wndFrame:FindChild("TargetIcons"):FindChild("TargetIcon"):SetSprite(strClassIconSprite)
	wndFrame:FindChild("Icon"):FindChild("IconPic"):SetSprite(strPlayerIconSprite)
	--if wndFrame:FindChild("Icon"):FindChild("IconPic"):GetOpacity() ~= 0.4 then
	--	wndFrame:FindChild("Icon"):FindChild("IconPic"):SetOpacity(0.4)
	--end
--Group Size
	if wndFrame:FindChild("TargetIcons:GroupSize") then
		wndFrame:FindChild("TargetIcons:GroupSize"):Show(uUnit:GetGroupValue() > 0)
		wndFrame:FindChild("TargetIcons:GroupSize"):SetText(uUnit:GetGroupValue())
	end
	
--Quest Icon
	if RewardIcons ~= nil and RewardIcons.GetUnitRewardIconsForm ~= nil and wndFrame:FindChild("TargetGoalPanel") then
		RewardIcons.GetUnitRewardIconsForm(wndFrame:FindChild("TargetIcons:TargetGoal:Img"), uUnit, nil)
	end
	local strRewardImg = wndFrame:FindChild("TargetIcons:TargetGoal:Img"):GetSprite()
	if strRewardImg == "CRB_TargetFrameRewardPanelSprites:sprTargetFrame_ActiveQuest" or strRewardImg == "sprTargetFrame_ActiveQuest" then
		wndFrame:FindChild("TargetIcons:TargetGoal:Img"):SetSprite("Sprites:QuestIcon")
		--TODO: Make other Icons!!!
	end
	
--Icon/Portrait
	local nPortStyle = wndFrame:GetName() == "PlayerUF" and self.db.profile.player.nPortraitStyle or wndFrame:GetName() == "TargetUF" and self.db.profile.target.nPortraitStyle --Replace with option
	
	if nPortStyle == 0 then
		--Hide
		local npl, npt, npr, npb = wndFrame:FindChild("Icon"):GetAnchorOffsets()
		local nnl, nnt, nnr, nnb = wndFrame:FindChild("Name"):GetAnchorOffsets()
		local nml, nmt, nmr, nmb = wndFrame:FindChild("ManaBar"):GetAnchorOffsets() --barMana:GetAnchorOffsets()
		local nhl, nht, nhr, nhb = wndFrame:FindChild("HealthBar"):GetAnchorOffsets()
		local nsl, nst, nsr, nsb = wndFrame:FindChild("ShieldBar"):GetAnchorOffsets() -- barShield:GetAnchorOffsets()
		
		if wndFrame:GetName() == "PlayerUF" then
			--barHealth:SetAnchorOffsets(npl+6, nht, nhr, nhb)
			wndFrame:FindChild("HealthBar"):SetAnchorOffsets(npl+6, nht, nhr, nhb)
			--barMana:SetAnchorOffsets(npl+6, nmt, nmr, nmb)
			wndFrame:FindChild("ManaBar"):SetAnchorOffsets(npl+6, nmt, nmr, nmb)
		elseif wndFrame:GetName() == "TargetUF" then
			barShield:SetAnchorOffsets(nsl, nst, npr-6, nsb)
			wndFrame:FindChild("ShieldBar"):SetAnchorOffsets(nsl, nst, npr-6, nsb)
			--barMana:SetAnchorOffsets(nml, nmt, npr-6, nmb)
			wndFrame:FindChild("ManaBar"):SetAnchorOffsets(nml, nmt, npr-6, nmb)
		end		
		
		wndFrame:FindChild("Icon:IconPic"):Show(false, true)
		wndFrame:FindChild("Icon:Portrait"):Show(false, true)
	elseif nPortStyle == 1 then
		--Model
		local npl, npt, npr, npb = wndFrame:FindChild("Icon"):GetAnchorOffsets()
		local nnl, nnt, nnr, nnb = wndFrame:FindChild("Name"):GetAnchorOffsets()
		local nml, nmt, nmr, nmb = wndFrame:FindChild("ManaBar"):GetAnchorOffsets() --barMana:GetAnchorOffsets()
		local nhl, nht, nhr, nhb = wndFrame:FindChild("HealthBar"):GetAnchorOffsets()
		local nsl, nst, nsr, nsb = wndFrame:FindChild("ShieldBar"):GetAnchorOffsets() -- barShield:GetAnchorOffsets()
		
		if wndFrame:GetName() == "PlayerUF" then
			--barHealth:SetAnchorOffsets(npr, nht, nhr, nhb)
			wndFrame:FindChild("HealthBar"):SetAnchorOffsets(npr, nht, nhr, nhb)
			--barMana:SetAnchorOffsets(npr, nmt, nmr, nmb)
			wndFrame:FindChild("ManaBar"):SetAnchorOffsets(npr, nmt, nmr, nmb)
		elseif wndFrame:GetName() == "TargetUF" then
			--barShield:SetAnchorOffsets(nsl, nst, npl, nsb)
			wndFrame:FindChild("ShieldBar"):SetAnchorOffsets(nsl, nst, npl, nsb)
			--barMana:SetAnchorOffsets(nml, nmt, npl, nmb)
			wndFrame:FindChild("ManaBar"):SetAnchorOffsets(nml, nmt, npl, nmb)
		end	
		
		wndFrame:FindChild("Icon:Portrait"):Show(true)
		wndFrame:FindChild("Icon:Portrait"):SetData(uUnit)
		wndFrame:FindChild("Icon:Portrait"):SetCostume(uUnit)
		wndFrame:FindChild("Icon:IconPic"):Show(false, true)
	else
		--Icon
		local npl, npt, npr, npb = wndFrame:FindChild("Icon"):GetAnchorOffsets()
		local nnl, nnt, nnr, nnb = wndFrame:FindChild("Name"):GetAnchorOffsets()
		local nml, nmt, nmr, nmb = wndFrame:FindChild("ManaBar"):GetAnchorOffsets() --barMana:GetAnchorOffsets()
		local nhl, nht, nhr, nhb = wndFrame:FindChild("HealthBar"):GetAnchorOffsets()
		local nsl, nst, nsr, nsb = wndFrame:FindChild("ShieldBar"):GetAnchorOffsets() -- barShield:GetAnchorOffsets()
		
		if wndFrame:GetName() == "PlayerUF" then
			--barHealth:SetAnchorOffsets(npr, nht, nhr, nhb)
			wndFrame:FindChild("HealthBar"):SetAnchorOffsets(npr, nht, nhr, nhb)
			--barMana:SetAnchorOffsets(npr, nmt, nmr, nmb)
			wndFrame:FindChild("ManaBar"):SetAnchorOffsets(npr, nmt, nmr, nmb)
		elseif wndFrame:GetName() == "TargetUF" then
			--barShield:SetAnchorOffsets(nsl, nst, npl, nsb)
			wndFrame:FindChild("ShieldBar"):SetAnchorOffsets(nsl, nst, npl, nsb)
			--barMana:SetAnchorOffsets(nml, nmt, npl, nmb)
			wndFrame:FindChild("ManaBar"):SetAnchorOffsets(nml, nmt, npl, nmb)
		end	
		
		wndFrame:FindChild("Icon:IconPic"):Show(true, true)
		wndFrame:FindChild("Icon:Portrait"):Show(false, true)
	end
			
	--Interrupt Armor
	local nInterruptMax = uUnit:GetInterruptArmorMax()
	local nInterruptValue = uUnit:GetInterruptArmorValue()
	wndFrame:FindChild("InterruptArmor"):Show(nInterruptValue > 0)
	wndFrame:FindChild("InterruptArmor"):SetText(nInterruptValue)

	--Focus Glow
	if wndFrame:GetName() == "FocusUF" then
		wndFrame:FindChild("Glow"):Show(self.db.profile.focus.bGlow, true)
	end
	
	--[[
	-RewardInfo
	nCompleted
	nNeeded
	strType = Quest, Challenge, (Soldier, Settler, Explorer), Scientist, PublicEvent
	idQuest
	nShowCount
	strTitle
	splObjective -- not always there
	idChallenge --only for challenges
	]]
end

function CandyUI_UnitFrames:UpdateToT(uUnit)
	local wndFrame = self.wndToTUF

	--Name
	local strSeperator = " - "
	local strName = uUnit:GetName()
	local nLevel = uUnit:GetLevel() or ""
	local crName = uUnit:GetNameplateColor()
	
	self.wndToTUF:FindChild("Name"):SetText(strName..strSeperator..nLevel)
	self.wndToTUF:FindChild("Name"):SetTextColor(crName)
	
	--Buffs/Debuffs
	self.wndToTUF:FindChild("BuffContainerWindow"):SetUnit(uUnit) --are debuffs
	--self.wndToTUF:FindChild("DebuffContainerWindow"):SetUnit(uUnit)
	
	--Bars
	local barHealth = wndFrame:FindChild("HealthBar:Bar")
	local barShield = wndFrame:FindChild("ShieldBar:Bar")
	
	--Absorb
	local nAbsorbCurr = 0
	local nAbsorbMax = uUnit:GetAbsorptionMax()
	if nAbsorbMax > 0 then
		nAbsorbCurr = uUnit:GetAbsorptionValue()
	end
	self:SetBarValue( wndFrame:FindChild("HealthBar:AbsorbBar"), nAbsorbCurr, 0, nAbsorbMax)
	--[[
	local bShowAbsorbText = self.db.profile.tot.bAbsorbText
	if bShowAbsorbText and nAbsorbMax > 0 then
		wndFrame:FindChild("HealthBar:AbsorbBar"):SetText(self:HelperFormatBigNumber(nAbsorbCurr).." / "..self:HelperFormatBigNumber(nAbsorbMax))
	else
		wndFrame:FindChild("HealthBar:AbsorbBar"):SetText("")
	end
	]]
	--Health
	local nHealthMax = uUnit:GetMaxHealth()
	local nHealthCurr = uUnit:GetHealth()
	local nHealthPerc = round((nHealthCurr/nHealthMax) * 100)
	self:SetBarValue(barHealth, nHealthCurr, 0, nHealthMax)
	
	--Health Text
	local nShowHealthText = self.db.profile.tot.nHealthText
	local nHealthFormat = self.db.profile.tot.nHealthFormat
	local bShowHealthText = nShowHealthText == 1 or nShowHealthText == 2
	
	barHealth:FindChild("Text"):Show(bShowHealthText, true)
	barHealth:FindChild("Text"):SetStyle("AutoFade", nShowHealthText == 2)
	if nShowHealthText == 1 and barHealth:FindChild("Text"):GetOpacity() < 1 then
		barHealth:FindChild("Text"):SetOpacity(1)
	end
	local strHealthText = ""
	if nHealthFormat == 0 then
		--Min / Max
		strHealthText = nHealthCurr.." / "..nHealthMax
	elseif nHealthFormat == 1 then
		--Min / Max (Short)
		strHealthText = self:HelperFormatBigNumber(nHealthCurr).." / "..self:HelperFormatBigNumber(nHealthMax)
	elseif nHealthFormat == 2 then
		--Percent
		strHealthText = nHealthPerc.."%"
	elseif nHealthFormat == 3 then
		--Min / Max (Percent)
		strHealthText = self:HelperFormatBigNumber(nHealthCurr).." / "..self:HelperFormatBigNumber(nHealthMax).." ("..nHealthPerc.."%)"
	end
	local bShowShieldText = false --self.db.profile.tot.bShowShieldText 
	local nShieldPerc = "" --replace with text
	local nShieldText = "["..nShieldPerc.."%]"
	if bShowShieldText then
		barHealth:FindChild("Text"):SetText(strHealthText.." "..nShieldText)
	else
		barHealth:FindChild("Text"):SetText(strHealthText)
	end
	
	--Color by health
	local bColorByHealth = self.db.profile.tot.bColorByHealth
	if bColorByHealth then
		local nPercDec = nHealthPerc/100
		local crRed = 1-nPercDec
		local crGreen = nPercDec
		local crBlue = 0
		barHealth:SetBarColor(ApolloColor.new(crRed, crGreen, crBlue))
	end
	
	--Shield
	--wndFrame:FindChild("HealthBarBG"):SetSprite("Sprites:HealthEmpty_Grey")
	local nShieldMax = uUnit:GetShieldCapacityMax()
	local nShieldCurr = uUnit:GetShieldCapacity()
	nShieldPerc = round((nShieldCurr /nShieldMax ) * 100)
	if nShieldMax ~= nil and nShieldMax > 0 then
		if barShield:IsShown() then
			self:SetBarValue(barShield, nShieldCurr, 0, nShieldMax)
			barShield:FindChild("Text"):SetText(nShieldPerc.."%")
		else
			--barShield:Show(true, true)
			wndFrame:FindChild("ShieldBar"):Show(true, true)
			wndFrame:FindChild("HealthBar"):SetSprite("Sprites:HealthEmpty_Grey")
			--barHealth:SetEmptySprite("Sprites:HealthEmpty_Grey")
			barHealth:SetFullSprite("Sprites:HealthFull_Grey")
			wndFrame:FindChild("HealthBar:AbsorbBar"):SetFullSprite("Sprites:HealthFull_Grey")
			local nsl, nst, nsr, nsb = wndFrame:FindChild("ShieldBar"):GetAnchorOffsets()
			local nhl, nht, nhr, nhb = wndFrame:FindChild("HealthBar"):GetAnchorOffsets()
			wndFrame:FindChild("HealthBar"):SetAnchorOffsets(nhl, nht, nsl-4, nhb)
			--barHealth:SetAnchorOffsets(nhl, nht, nsl-4, nhb)
			self:SetBarValue(barShield, nShieldCurr, 0, nShieldMax)
			barShield:FindChild("Text"):SetText(nShieldPerc.."%")
		end
	else
		if not barShield:IsShown() then
			--self:SetBarValue(barShield, nShieldCurr, 0, nShieldMax)
		else
		--barShield:Show(false, true)
		wndFrame:FindChild("ShieldBar"):Show(false, true)
		wndFrame:FindChild("HealthBar"):SetSprite("Sprites:HealthEmpty_RoundedGrey")
		--barHealth:SetEmptySprite("Sprites:HealthEmpty_RoundedGrey")
		barHealth:SetFullSprite("Sprites:HealthFull_RoundedGrey")
		wndFrame:FindChild("HealthBar:AbsorbBar"):SetFullSprite("Sprites:HealthFull_RoundedGrey")
		local nhl, nht, nhr, nhb = wndFrame:FindChild("HealthBar"):GetAnchorOffsets()
		local nsl, nst, nsr, nsb = wndFrame:FindChild("ShieldBar"):GetAnchorOffsets()
		wndFrame:FindChild("HealthBar"):SetAnchorOffsets(nhl, nht, nsr, nhb)
		--barHealth:SetAnchorOffsets(nhl, nht, nsr, nhb)
		end
	end
end

function CandyUI_UnitFrames:GetClusters(uUnit)
		local unitTarget = uUnit
		local unitPlayer = GameLib.GetPlayerUnit()
		local tCluster = nil
		-- Cluster info
		tCluster = unitTarget:GetClusterUnits()
		
		if unitTarget == unitPlayer then
			--Treat Mount as a Cluster Target
			if unitPlayer:IsMounted() then
				table.insert(tCluster, unitPlayer:GetUnitMount())
			end
		end
		
		--Make the unit a cluster of a vehicle if they're in one.
		if unitTarget:IsInVehicle() then
			--local uPlayer = unitTarget
			--unitTarget = uPlayer:GetVehicle()
			
			table.insert(tCluster, unitTarget:GetVehicle())
		end
		
		-- Treat Pets as Cluster Targets
		--self.wndPetFrame:FindChild("PetContainerDespawnBtn"):SetData(nil)
		
		local tPlayerPets = GameLib.GetPlayerPets()
		--self.wndPetFrame:Show(false)
		
		for k,v in ipairs(tPlayerPets) do
			if k < 3 and unitTarget == unitPlayer then
				table.insert(tCluster, v)
			end
		end
		
		if tCluster == nil or #tCluster < 1 then
			tCluster = nil
		end
		
		return tCluster
end

function CandyUI_UnitFrames:UpdateClusters(tClusters, wndUnitFrame)
	local arClusterWindows = wndUnitFrame:FindChild("ClusterFrame"):GetChildren()
	wndUnitFrame:FindChild("ClusterFrame"):ArrangeChildrenVert()
	for i, v in ipairs(arClusterWindows) do
		v:Show(false) 
	end
	if wndUnitFrame:FindChild("ClusterFrame") == nil or tClusters == nil then
		return
	end
	for i, v in ipairs(tClusters) do
		arClusterWindows[i]:Show(v:GetName() ~= nil)
		arClusterWindows[i]:FindChild("Name"):SetText(v:GetName())
		self:SetBarValue(arClusterWindows[i]:FindChild("HealthBar"), v:GetHealth(), 0, v:GetMaxHealth())
		--self:SetBarValue(arClusterWindows[i]:FindChild("HealthBar"), v:GetHealth(), 0, v:GetHealthMax())
		--Shield
		local nShieldMax = v:GetShieldCapacityMax()
		local nShieldCurr = v:GetShieldCapacity()
		
		if nShieldMax ~= nil and nShieldMax > 0 then
			if arClusterWindows[i]:FindChild("ShieldBar"):IsShown() then
				self:SetBarValue(arClusterWindows[i]:FindChild("ShieldBar"), nShieldCurr, 0, nShieldMax)
			else
				arClusterWindows[i]:FindChild("ShieldBar"):Show(true, true)
				local nsl, nst, nsr, nsb = arClusterWindows[i]:FindChild("ShieldBar"):GetAnchorOffsets()
				local nhl, nht, nhr, nhb = arClusterWindows[i]:FindChild("HealthBar"):GetAnchorOffsets()
				arClusterWindows[i]:FindChild("HealthBar"):SetAnchorOffsets(nhl, nht, nsl, nhb)
				self:SetBarValue(arClusterWindows[i]:FindChild("ShieldBar"), nShieldCurr, 0, nShieldMax)
			end
		else
			arClusterWindows[i]:FindChild("ShieldBar"):Show(false, true)
			local nhl, nht, nhr, nhb = arClusterWindows[i]:FindChild("HealthBar"):GetAnchorOffsets()
			local nsl, nst, nsr, nsb = arClusterWindows[i]:FindChild("ShieldBar"):GetAnchorOffsets()
			arClusterWindows[i]:FindChild("HealthBar"):SetAnchorOffsets(nhl, nht, nsr, nhb)
		end
	end
end

function CandyUI_UnitFrames:SetBarValue(wndBar, fValue, fMin, fMax)
	fValue = math.floor(fValue)
	fMin = math.floor(fMin)
	fMax = math.floor(fMax)
	
	wndBar:SetMax(fMax)
	wndBar:SetFloor(fMin)
	wndBar:SetProgress(fValue)
	
	if wndBar:FindChild("Text") then
		--Add code for options
		local strSeperator = " / "
		wndBar:FindChild("Text"):SetText(fValue..strSeperator..fMax)
	end
end

---------------------------------------------------------------------------------------------------
-- PlayerUF Functions
---------------------------------------------------------------------------------------------------

function CandyUI_UnitFrames:OnGenerateBuffTooltip(wndHandler, wndControl, tType, splBuff)
	if wndHandler == wndControl or Tooltip == nil then
		return
	end
	Tooltip.GetBuffTooltipForm(self, wndControl, splBuff, {bFutureSpell = false})
end

--#############################################################################################
function CandyUI_UnitFrames:OnUFMoved( wndHandler, wndControl, nOldLeft, nOldTop, nOldRight, nOldBottom )
	local strName = wndControl:GetName()
	local tAnchors = {wndControl:GetAnchorOffsets()}
	if strName == "PlayerUF" then
		self.db.profile.player.tAnchorOffsets = tAnchors
	elseif strName == "TargetUF" then
		self.db.profile.target.tAnchorOffsets = tAnchors
	elseif strName == "FocusUF" then
		self.db.profile.focus.tAnchorOffsets = tAnchors
	elseif strName == "ToTUF" then
		self.db.profile.tot.tAnchorOffsets = tAnchors
	end
end

function CandyUI_UnitFrames:OnMouseUp( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY )
	local unit = wndControl:GetData()
	if eMouseButton == GameLib.CodeEnumInputMouse.Left and unit ~= nil then
		GameLib.SetTargetUnit(unit)
		return false
	end
	if eMouseButton == GameLib.CodeEnumInputMouse.Right and unit ~= nil then
		Event_FireGenericEvent("GenericEvent_NewContextMenuPlayerDetailed", nil, unit:GetName(), unit)
		return true
	end
end

-----------------------------------------------------------------------------------------------
-- 								OPTIONS
-----------------------------------------------------------------------------------------------
--#############################################################################################

kcuiUFDefaults = {
	char = {
		currentProfile = nil,
	},
	profile = {
		general = {
			
		},
		player = {
			nPortraitStyle = 2,
			nWidth = 256,
			nHealthText = 2,
			nHealthFormat = 3,
			crHealthBar = "ffff0000",
			--default for color?
			bColorByHealth = true,
			crShieldBar = "ff00bff3",
			nManaText = 2,
			nManaFormat = 3,
			crManaBar = "fffe7b00",
			bAbsorbText = true,
			crAbsorbBar = "xkcdAmber",
			nOpacity = 1,
			nBGOpacity = 1,
			tAnchorOffsets = {0,-324,256,-268}
		},
		target = {
			nPortraitStyle = 2,
			nWidth = 256,
			nHealthText = 2,
			nHealthFormat = 3,
			crHealthBar = "ffff0000",
			--default for color?
			bColorByHealth = true,
			crShieldBar = "ff00bff3",
			nManaText = 2,
			nManaFormat = 3,
			crManaBar = "fffe7b00",
			bAbsorbText = true,
			crAbsorbBar = "xkcdAmber",
			nOpacity = 1,
			nBGOpacity = 1,
			tAnchorOffsets = {-256,-324,0,-268}
		},
		focus = {
			nPortraitStyle = 1,
			nWidth = 256,
			nHealthText = 2,
			nHealthFormat = 3,
			crHealthBar = "ffff0000",
			--default for color?
			bColorByHealth = true,
			crShieldBar = "ff00bff3",
			nManaText = 2,
			nManaFormat = 3,
			crManaBar = "fffe7b00",
			bAbsorbText = true,
			crAbsorbBar = "xkcdAmber",
			nOpacity = 1,
			nBGOpacity = 1,
			bGlow = true,
			tAnchorOffsets = {-256,-258,0,-202}
		},
		tot = {
			bShow = true,
			nHealthText = 2,
			nHealthFormat = 3,
			crHealthBar = "ffff0000",
			bColorByHealth = true,
			crShieldBar = "ff00bff3",
			bAbsorbText = true,
			crAbsorbBar = "xkcdAmber",
			nOpacity = 1,
			nBGOpacity = 1,
			tAnchorOffsets = {-261,-293,-111,-268}
		},
	},
}



--%%%%%%%%%%%%%
--Key By Value
--%%%%%%%%%%%%%
local function GetKey(tTable, strValue)
	for k, v in pairs(tTable) do
		if tostring(v) == tostring(strValue) then
			return k
		end
	end
	return nil
end

--%%%%%%%%%%%%%%%%%
-- Create Dropdown
--%%%%%%%%%%%%%%%%%
local function CreateDropdownMenu(self, wndDropdown, tOptions, strEventHandler, bDisable)
	--wndDropdown needs to be the whole window object i.e. containing the label, button, and box
	local wndDropdownButton = wndDropdown:FindChild("Dropdown")
	local wndDropdownBox = wndDropdown:FindChild("DropdownBox")
	
	if #wndDropdownBox:FindChild("ScrollList"):GetChildren() > 0 then
		return
	end	
	for name, value in pairs(tOptions) do
		local currButton = Apollo.LoadForm(self.xmlDoc, "DropdownItem", wndDropdownBox:FindChild("ScrollList"), self)
		currButton:SetText(name)
		currButton:SetData(value)
		currButton:AddEventHandler("ButtonUp", strEventHandler)
	end
		
	wndDropdownBox:FindChild("ScrollList"):ArrangeChildrenVert()
	
	if bDisable then
	--[[
		for k, v in pairs(wndDropdown:GetParent():GetChildren()) do
			if v:GetName() ~= wndDropdown:GetName() and v:GetName() ~= "Title" and v:GetName() ~= "Description" then
				v:Enable(false)
				--Print(v:GetName())
			end
		end
		]]
	end
end

---------------------------------
--		Dropdown Options
---------------------------------

local tPortraitOptions = {
	["Hide"] = 0,
	["Model"] = 1,
	["Class Icon"] = 2,
}

local tTargetPortraitOptions = {
	["Hide"] = 0,
	["Model"] = 1,
	--["Class Icon"] = 2,
}

local tBarTextOptions = {
	["Hide"] = 0,
	["Show"] = 1,
	["Hover"] = 2,
}

local tBarTextFormatOptions = {
	["Min / Max"] = 0,
	["Min / Max (Short)"] = 1,
	["Percent"] = 2,
	["Min / Max (Percent)"] = 3,
}

--===============================
--			Set Options
--===============================
function CandyUI_UnitFrames:SetOptions()
	for _, strUnit in ipairs({"Player", "Target", "Focus"}) do
		local strUnitLower = string.lower(strUnit)
		
		local controls = self.wndControls:FindChild(strUnit.."Controls")
		--Portrait
		controls:FindChild("Portrait:Dropdown"):SetText(GetKey(tPortraitOptions, self.db.profile[strUnitLower]["nPortraitStyle"]))
		--Width
		controls:FindChild("Width:Input"):SetText(self.db.profile[strUnitLower]["nWidth"])
		local l, t, r, b = self["wnd"..strUnit.."UF"]:GetAnchorOffsets()
		self["wnd"..strUnit.."UF"]:SetAnchorOffsets(l, t, l+self.db.profile[strUnitLower]["nWidth"], b)
		--Opacity
		controls:FindChild("Opacity:SliderBar"):SetValue(self.db.profile[strUnitLower]["nOpacity"])
		controls:FindChild("Opacity:EditBox"):SetText(self.db.profile[strUnitLower]["nOpacity"])
		--BGOpacity
		controls:FindChild("BGOpacity:SliderBar"):SetValue(self.db.profile[strUnitLower]["nBGOpacity"])
		controls:FindChild("BGOpacity:EditBox"):SetText(self.db.profile[strUnitLower]["nBGOpacity"])
		--==BARS==--
		--Health Text
		controls:FindChild("HealthText:Dropdown"):SetText(GetKey(tBarTextOptions, self.db.profile[strUnitLower]["nHealthText"]))
		--Health Format
		controls:FindChild("HealthFormat:Dropdown"):SetText(GetKey(tBarTextFormatOptions, self.db.profile[strUnitLower]["nHealthFormat"]))
		--Health Bar Color
		controls:FindChild("HealthBarColor:Swatch"):SetBGColor(self.db.profile[strUnitLower]["crHealthBar"])
		--Color By Health
		controls:FindChild("ColorByHealthToggle"):SetCheck(self.db.profile[strUnitLower]["bColorByHealth"])
		--Shield Bar Color
		controls:FindChild("ShieldBarColor:Swatch"):SetBGColor(self.db.profile[strUnitLower]["crShieldBar"])
		--Absorb Bar Color
		controls:FindChild("AbsorbBarColor:Swatch"):SetBGColor(self.db.profile[strUnitLower]["crAbsorbBar"])
		--Absorb Text
		controls:FindChild("ShowAbsorbTextToggle"):SetCheck(self.db.profile[strUnitLower]["bAbsorbText"])
	end
--Player
	--Mana Text
	self.wndControls:FindChild("PlayerControls"):FindChild("ManaText:Dropdown"):SetText(GetKey(tBarTextOptions, self.db.profile.player.nManaText))
	--Mana Format
	self.wndControls:FindChild("PlayerControls"):FindChild("ManaFormat:Dropdown"):SetText(GetKey(tBarTextFormatOptions, self.db.profile.player.nManaFormat))
	--Mana Bar Color
	self.wndControls:FindChild("PlayerControls"):FindChild("ManaBarColor:Swatch"):SetBGColor(self.db.profile.player.crManaBar)
--Focus
	--Focus Glow
	self.wndControls:FindChild("FocusControls"):FindChild("GlowToggle"):SetCheck(self.db.profile.focus.bGlow)
--ToT
	--show
	self.wndControls:FindChild("ToTControls"):FindChild("ShowToggle"):SetCheck(self.db.profile.tot.bShow)
	--Health Text
	self.wndControls:FindChild("ToTControls"):FindChild("HealthText:Dropdown"):SetText(GetKey(tBarTextOptions, self.db.profile.tot.nHealthText))
	--Health Format
	self.wndControls:FindChild("ToTControls"):FindChild("HealthFormat:Dropdown"):SetText(GetKey(tBarTextFormatOptions, self.db.profile.tot.nHealthFormat))
	--Health Bar Color
	self.wndControls:FindChild("ToTControls"):FindChild("HealthBarColor:Swatch"):SetBGColor(self.db.profile.tot.crHealthBar)
	--Color By Health
	self.wndControls:FindChild("ToTControls"):FindChild("ColorByHealthToggle"):SetCheck(self.db.profile.tot.bColorByHealth)
	--Shield Bar Color
	self.wndControls:FindChild("ToTControls"):FindChild("ShieldBarColor:Swatch"):SetBGColor(self.db.profile.tot.crShieldBar)
end

function CandyUI_UnitFrames:SetLooks()
--Player
	--Bar Colors
	self.wndPlayerUF:FindChild("HealthBar"):FindChild("Bar"):SetBarColor(self.db.profile.player.crHealthBar)
	self.wndPlayerUF:FindChild("HealthBar"):SetBGColor(self.db.profile.player.crHealthBar)
	self.wndPlayerUF:FindChild("ShieldBar"):FindChild("Bar"):SetBarColor(self.db.profile.player.crShieldBar)
	self.wndPlayerUF:FindChild("ShieldBar"):SetBGColor(self.db.profile.player.crShieldBar)
	self.wndPlayerUF:FindChild("ManaBar"):FindChild("Bar"):SetBarColor(self.db.profile.player.crManaBar)
	self.wndPlayerUF:FindChild("ManaBar"):SetBGColor(self.db.profile.player.crManaBar)
	
	self.wndPlayerUF:FindChild("HealthBar:AbsorbBar"):SetBarColor(self.db.profile.player.crAbsorbBar)
	--self.wndPlayerUF:FindChild("HealthBar:AbsorbBar"):SetOpacity(0.5)
	--Opacity
	self.wndPlayerUF:SetOpacity(self.db.profile.player.nOpacity)
	self.wndPlayerUF:FindChild("BG"):SetOpacity(self.db.profile.player.nBGOpacity)
--target
	--Bar Colors
	self.wndTargetUF:FindChild("HealthBar"):FindChild("Bar"):SetBarColor(self.db.profile.target.crHealthBar)
	self.wndTargetUF:FindChild("HealthBar"):SetBGColor(self.db.profile.target.crHealthBar)
	self.wndTargetUF:FindChild("ShieldBar"):FindChild("Bar"):SetBarColor(self.db.profile.target.crShieldBar)
	self.wndTargetUF:FindChild("ShieldBar"):SetBGColor(self.db.profile.target.crShieldBar)
	self.wndTargetUF:FindChild("ManaBar"):FindChild("Bar"):SetBarColor(self.db.profile.target.crManaBar)
	self.wndTargetUF:FindChild("ManaBar"):SetBGColor(self.db.profile.target.crManaBar)
	
	self.wndTargetUF:FindChild("HealthBar:AbsorbBar"):SetBarColor(self.db.profile.target.crAbsorbBar)
	--Opacity
	self.wndTargetUF:SetOpacity(self.db.profile.target.nOpacity)
	self.wndTargetUF:FindChild("BG"):SetOpacity(self.db.profile.target.nBGOpacity)
--focus
	--Bar Colors
	self.wndFocusUF:FindChild("HealthBar"):FindChild("Bar"):SetBarColor(self.db.profile.focus.crHealthBar)
	self.wndFocusUF:FindChild("HealthBar"):SetBGColor(self.db.profile.focus.crHealthBar)
	self.wndFocusUF:FindChild("ShieldBar"):FindChild("Bar"):SetBarColor(self.db.profile.focus.crShieldBar)
	self.wndFocusUF:FindChild("ShieldBar"):SetBGColor(self.db.profile.focus.crShieldBar)
	self.wndFocusUF:FindChild("ManaBar"):FindChild("Bar"):SetBarColor(self.db.profile.focus.crManaBar)
	self.wndFocusUF:FindChild("ManaBar"):SetBGColor(self.db.profile.focus.crManaBar)
	
	self.wndFocusUF:FindChild("HealthBar:AbsorbBar"):SetBarColor(self.db.profile.focus.crAbsorbBar)
	--Opacity
	self.wndFocusUF:SetOpacity(self.db.profile.focus.nOpacity)
	self.wndFocusUF:FindChild("BG"):SetOpacity(self.db.profile.focus.nBGOpacity)
--ToT
	--Bar Colors
	self.wndToTUF:FindChild("HealthBar"):FindChild("Bar"):SetBarColor(self.db.profile.tot.crHealthBar)
	self.wndToTUF:FindChild("HealthBar"):SetBGColor(self.db.profile.tot.crHealthBar)
	self.wndToTUF:FindChild("ShieldBar"):FindChild("Bar"):SetBarColor(self.db.profile.tot.crShieldBar)
	self.wndToTUF:FindChild("ShieldBar"):SetBGColor(self.db.profile.tot.crShieldBar)
	self.wndToTUF:FindChild("HealthBar:AbsorbBar"):SetBarColor(self.db.profile.tot.crAbsorbBar)
	--Opacity
	self.wndToTUF:SetOpacity(self.db.profile.tot.nOpacity)
	self.wndToTUF:FindChild("BG"):SetOpacity(self.db.profile.tot.nBGOpacity)
end
-------------------------
-- Player Option Events
-------------------------

function CandyUI_UnitFrames:ColorPickerCallback(strColor)
	local strUnit = self.strColorPickerTargetUnit
	local strUnitLower = string.lower(strUnit)
		if self.strColorPickerTargetControl == "HealthBar" then
			self.db.profile[strUnitLower].crHealthBar = strColor
			self.wndControls:FindChild(strUnit.."Controls"):FindChild("HealthBarColor"):FindChild("Swatch"):SetBGColor(strColor)
			self["wnd"..strUnit.."UF"]:FindChild("HealthBar"):FindChild("Bar"):SetBarColor(self.db.profile[strUnitLower].crHealthBar)
			self["wnd"..strUnit.."UF"]:FindChild("HealthBar"):SetBGColor(self.db.profile[strUnitLower].crHealthBar)
		elseif self.strColorPickerTargetControl == "ShieldBar" then
			self.db.profile[strUnitLower].crShieldBar = strColor
			self.wndControls:FindChild(strUnit.."Controls"):FindChild("ShieldBarColor"):FindChild("Swatch"):SetBGColor(strColor)
			self["wnd"..strUnit.."UF"]:FindChild("ShieldBar"):FindChild("Bar"):SetBarColor(self.db.profile[strUnitLower].crShieldBar)
			self["wnd"..strUnit.."UF"]:FindChild("ShieldBar"):SetBGColor(self.db.profile[strUnitLower].crShieldBar)
		elseif self.strColorPickerTargetControl == "ManaBar" then
			self.db.profile[strUnitLower].crManaBar = strColor
			self.wndControls:FindChild(strUnit.."Controls"):FindChild("ManaBarColor"):FindChild("Swatch"):SetBGColor(strColor)
			self["wnd"..strUnit.."UF"]:FindChild("ManaBar"):FindChild("Bar"):SetBarColor(self.db.profile[strUnitLower].crManaBar)
			self["wnd"..strUnit.."UF"]:FindChild("ManaBar"):SetBGColor(self.db.profile[strUnitLower].crManaBar)
		elseif self.strColorPickerTargetControl == "AbsorbBar" then
			self.db.profile[strUnitLower].crAbsorbBar = strColor
			self.wndControls:FindChild(strUnit.."Controls"):FindChild("AbsorbBarColor"):FindChild("Swatch"):SetBGColor(strColor)
			self["wnd"..strUnit.."UF"]:FindChild("HealthBar"):FindChild("AbsorbBar"):SetBarColor(self.db.profile[strUnitLower].crAbsorbBar)
			--self["wnd"..strUnit.."UF"]:FindChild("HealthBar"):SetBGColor(self.db.profile[strUnitLower].crHealthBar)
		end
	--[[
	if self.strColorPickerTargetUnit == "Player" then
		if self.strColorPickerTargetControl == "HealthBar" then
			self.db.profile.player.crHealthBar = strColor
			self.wndControls:FindChild("PlayerControls"):FindChild("HealthBarColor"):FindChild("Swatch"):SetBGColor(strColor)
			self.wndPlayerUF:FindChild("HealthBar"):FindChild("Bar"):SetBarColor(self.db.profile.player.crHealthBar)
			self.wndPlayerUF:FindChild("HealthBar"):SetBGColor(self.db.profile.player.crHealthBar)
		elseif self.strColorPickerTargetControl == "ShieldBar" then
			self.db.profile.player.crShieldBar = strColor
			self.wndControls:FindChild("PlayerControls"):FindChild("ShieldBarColor"):FindChild("Swatch"):SetBGColor(strColor)
			self.wndPlayerUF:FindChild("ShieldBar"):SetBarColor(self.db.profile.player.crShieldBar)
			self.wndPlayerUF:FindChild("ShieldBarBG"):SetBGColor(self.db.profile.player.crShieldBar)
		elseif self.strColorPickerTargetControl == "ManaBar" then
			self.db.profile.player.crManaBar = strColor
			self.wndControls:FindChild("PlayerControls"):FindChild("ManaBarColor"):FindChild("Swatch"):SetBGColor(strColor)
			self.wndPlayerUF:FindChild("ManaBar"):SetBarColor(self.db.profile.player.crManaBar)
			self.wndPlayerUF:FindChild("ManaBarBG"):SetBGColor(self.db.profile.player.crManaBar)
		end
	elseif self.strColorPickerTargetUnit == "Target" then
	
	elseif self.strColorPickerTargetUnit == "Focus" then
	
	elseif self.strColorPickerTargetUnit == "ToT" then
	
	end
	]]
end

--Portrait Style
function CandyUI_UnitFrames:OnPortraitStyleClick(wndHandler, wndControl, eMouseButton)
	local strUnit = wndControl:GetParent():GetParent():FindChild("Title"):GetText()
	CreateDropdownMenu(self, wndControl:GetParent(), tPortraitOptions, "OnPortraitStyleItemClick", true)
	--self.wndControls:FindChild("PlayerControls")
	self.wndControls:FindChild(strUnit.."Controls"):FindChild("Opacity"):Enable(false)
	wndControl:GetParent():FindChild("DropdownBox"):Show(true)
end

function CandyUI_UnitFrames:OnPortraitStyleItemClick(wndHandler, wndControl, eMouseButton)
	local strUnit = wndControl:GetParent():GetParent():GetParent():GetParent():FindChild("Title"):GetText()
	wndControl:GetParent():GetParent():GetParent():FindChild("Dropdown"):SetText(wndControl:GetText())
	
	self.db.profile[string.lower(strUnit)]["nPortraitStyle"] = wndControl:GetData()
	wndControl:GetParent():GetParent():Show(false)
end

function CandyUI_UnitFrames:OnPortraitStyleHide( wndHandler, wndControl )
	local strUnit = wndControl:GetParent():GetParent():FindChild("Title"):GetText()
	self.wndControls:FindChild(strUnit.."Controls"):FindChild("Opacity"):Enable(true)
end

function CandyUI_UnitFrames:OnWidthReturn( wndHandler, wndControl, strText )
	local strUnit = wndControl:GetParent():GetParent():FindChild("Title"):GetText()
	if strUnit == "Target of Target" then strUnit = "ToT" end
	local value = round(tonumber(strText))
	self.db.profile[string.lower(strUnit)]["nWidth"] = value
	
	local l, t, r, b = self["wnd"..strUnit.."UF"]:GetAnchorOffsets()
	self["wnd"..strUnit.."UF"]:SetAnchorOffsets(l, t, l+value, b)
end

function CandyUI_UnitFrames:OnBGOpacityChanged( wndHandler, wndControl, fNewValue, fOldValue )
	local strUnit = wndControl:GetParent():GetParent():FindChild("Title"):GetText()
	if strUnit == "Target of Target" then strUnit = "ToT" end
	local value = round(fNewValue, 1)
	wndControl:GetParent():FindChild("EditBox"):SetText(value)
	self.db.profile[string.lower(strUnit)]["nBGOpacity"] = value
	if self["wnd"..strUnit.."UF"] then
		self["wnd"..strUnit.."UF"]:FindChild("BG"):SetOpacity(value)
	end
end

function CandyUI_UnitFrames:OnOpacityChanged( wndHandler, wndControl, fNewValue, fOldValue )
	local strUnit = wndControl:GetParent():GetParent():FindChild("Title"):GetText()
	if strUnit == "Target of Target" then strUnit = "ToT" end
	--self["wnd"..strUnit.."UF"]
	local value = round(fNewValue, 1)
	wndControl:GetParent():FindChild("EditBox"):SetText(value)
	self.db.profile[string.lower(strUnit)]["nOpacity"] = value
	if self["wnd"..strUnit.."UF"] then
		self["wnd"..strUnit.."UF"]:SetOpacity(value)
	end
end

function CandyUI_UnitFrames:OnHealthTextClick( wndHandler, wndControl, eMouseButton )
	local strUnit = wndControl:GetParent():GetParent():FindChild("Title"):GetText()
	if strUnit == "Target of Target" then strUnit = "ToT" end
	CreateDropdownMenu(self, wndControl:GetParent(), tBarTextOptions, "OnHealthTextItemClick")
	self.wndControls:FindChild(strUnit.."Controls"):FindChild("HealthBarColor"):Enable(false)
	self.wndControls:FindChild(strUnit.."Controls"):FindChild("ShieldBarColor"):Enable(false)
	if self.wndControls:FindChild(strUnit.."Controls"):FindChild("ManaText") then
		self.wndControls:FindChild(strUnit.."Controls"):FindChild("ManaText"):Enable(false)
	end
	wndControl:GetParent():FindChild("DropdownBox"):Show(true)
end

function CandyUI_UnitFrames:OnHealthTextItemClick(wndHandler, wndControl, eMouseButton)
	local strUnit = wndControl:GetParent():GetParent():GetParent():GetParent():FindChild("Title"):GetText()
	if strUnit == "Target of Target" then strUnit = "ToT" end
	wndControl:GetParent():GetParent():GetParent():FindChild("Dropdown"):SetText(wndControl:GetText())
	
	self.db.profile[string.lower(strUnit)]["nHealthText"] = wndControl:GetData()
	
	wndControl:GetParent():GetParent():Show(false)
end

function CandyUI_UnitFrames:OnHealthTextHide( wndHandler, wndControl )
	local strUnit = wndControl:GetParent():GetParent():FindChild("Title"):GetText()
	if strUnit == "Target of Target" then strUnit = "ToT" end
	self.wndControls:FindChild(strUnit.."Controls"):FindChild("HealthBarColor"):Enable(true)
	self.wndControls:FindChild(strUnit.."Controls"):FindChild("ShieldBarColor"):Enable(true)
	if self.wndControls:FindChild(strUnit.."Controls"):FindChild("ManaText") then
		self.wndControls:FindChild(strUnit.."Controls"):FindChild("ManaText"):Enable(true)
	end
end

function CandyUI_UnitFrames:OnHealthFormatClick( wndHandler, wndControl, eMouseButton )
	local strUnit = wndControl:GetParent():GetParent():FindChild("Title"):GetText()
	if strUnit == "Target of Target" then strUnit = "ToT" end
	CreateDropdownMenu(self, wndControl:GetParent(), tBarTextFormatOptions, "OnHealthFormatItemClick")
	self.wndControls:FindChild(strUnit.."Controls"):FindChild("ColorByHealthToggle"):Enable(false)
	--self.wndControls:FindChild(strUnit.."Controls"):FindChild("ShieldBarColor"):Enable(false)
	if self.wndControls:FindChild(strUnit.."Controls"):FindChild("ManaFormat") then
		self.wndControls:FindChild(strUnit.."Controls"):FindChild("ManaFormat"):Enable(false)
	end
	wndControl:GetParent():FindChild("DropdownBox"):Show(true)
end

function CandyUI_UnitFrames:OnHealthFormatItemClick(wndHandler, wndControl, eMouseButton)
	local strUnit = wndControl:GetParent():GetParent():GetParent():GetParent():FindChild("Title"):GetText()
	if strUnit == "Target of Target" then strUnit = "ToT" end
	wndControl:GetParent():GetParent():GetParent():FindChild("Dropdown"):SetText(wndControl:GetText())
	
	self.db.profile[string.lower(strUnit)]["nHealthFormat"] = wndControl:GetData()
	
	wndControl:GetParent():GetParent():Show(false)
end

function CandyUI_UnitFrames:OnHealthFormatHide( wndHandler, wndControl )
	local strUnit = wndControl:GetParent():GetParent():FindChild("Title"):GetText()
	if strUnit == "Target of Target" then strUnit = "ToT" end
	self.wndControls:FindChild(strUnit.."Controls"):FindChild("ColorByHealthToggle"):Enable(true)
	--self.wndControls:FindChild(strUnit.."Controls"):FindChild("ShieldBarColor"):Enable(false)
	if self.wndControls:FindChild(strUnit.."Controls"):FindChild("ManaFormat") then
		self.wndControls:FindChild(strUnit.."Controls"):FindChild("ManaFormat"):Enable(true)
	end
end

function CandyUI_UnitFrames:OnHealthBarColorClick( wndHandler, wndControl, eMouseButton )
	local strUnit = wndControl:GetParent():GetParent():FindChild("Title"):GetText()
	if strUnit == "Target of Target" then strUnit = "ToT" end
	--Open Color Picker
	self.strColorPickerTargetUnit = strUnit
	self.strColorPickerTargetControl = "HealthBar"
	self.colorPicker:Show(true)
	self.colorPicker:ToFront()
end

function CandyUI_UnitFrames:OnColorByHealthClick( wndHandler, wndControl, eMouseButton )
	local strUnit = wndControl:GetParent():FindChild("Title"):GetText()
	if strUnit == "Target of Target" then strUnit = "ToT" end
	self.db.profile[string.lower(strUnit)]["bColorByHealth"] = wndControl:IsChecked()
	if not wndControl:IsChecked() then
		self:SetLooks()
	end
end

function CandyUI_UnitFrames:OnShieldBarColorClick( wndHandler, wndControl, eMouseButton )
	local strUnit = wndControl:GetParent():GetParent():FindChild("Title"):GetText()
	if strUnit == "Target of Target" then strUnit = "ToT" end
	--Open Color Picker
	self.strColorPickerTargetUnit = strUnit
	self.strColorPickerTargetControl = "ShieldBar"
	self.colorPicker:Show(true)
	self.colorPicker:ToFront()
end

function CandyUI_UnitFrames:OnPlayerManaTextClick( wndHandler, wndControl, eMouseButton )
	CreateDropdownMenu(self, wndControl:GetParent(), tBarTextOptions, "OnPlayerManaTextItemClick")
	self.wndControls:FindChild("PlayerControls"):FindChild("ManaBarColor"):Enable(false)
	wndControl:GetParent():FindChild("DropdownBox"):Show(true)
end

function CandyUI_UnitFrames:OnPlayerManaTextItemClick(wndHandler, wndControl, eMouseButton)
	wndControl:GetParent():GetParent():GetParent():FindChild("Dropdown"):SetText(wndControl:GetText())
	
	self.db.profile.player.nManaText = wndControl:GetData()
	
	wndControl:GetParent():GetParent():Show(false)
end

function CandyUI_UnitFrames:OnPlayerManaTextHide( wndHandler, wndControl )
	self.wndControls:FindChild("PlayerControls"):FindChild("ManaBarColor"):Enable(true)
end

function CandyUI_UnitFrames:OnPlayerManaFormatClick( wndHandler, wndControl, eMouseButton )
	CreateDropdownMenu(self, wndControl:GetParent(), tBarTextFormatOptions, "OnPlayerManaFormatItemClick")
	wndControl:GetParent():FindChild("DropdownBox"):Show(true)
end

function CandyUI_UnitFrames:OnPlayerManaFormatItemClick(wndHandler, wndControl, eMouseButton)
	wndControl:GetParent():GetParent():GetParent():FindChild("Dropdown"):SetText(wndControl:GetText())
	
	self.db.profile.player.nManaFormat = wndControl:GetData()
	
	wndControl:GetParent():GetParent():Show(false)
end

function CandyUI_UnitFrames:OnPlayerManaBarColorClick( wndHandler, wndControl, eMouseButton )
	--Open Color Picker
	self.strColorPickerTargetUnit = "Player"
	self.strColorPickerTargetControl = "ManaBar"
	self.colorPicker:Show(true)
	self.colorPicker:ToFront()
end

function CandyUI_UnitFrames:OnFocusShowGlowClick( wndHandler, wndControl, eMouseButton )
	self.db.profile.focus.bGlow = wndControl:IsChecked()
end

function CandyUI_UnitFrames:OnToTShowClick( wndHandler, wndControl, eMouseButton )
	self.db.profile.tot.bShow = wndControl:IsChecked()
	self:OnTargetUnitChanged(GameLib.GetTargetUnit())
end
---------------------------------------------------------------------------------------------------
-- OptionsControlsList Functions
---------------------------------------------------------------------------------------------------

function CandyUI_UnitFrames:OnAbsorbBarColorClick( wndHandler, wndControl, eMouseButton )
	local strUnit = wndControl:GetParent():GetParent():FindChild("Title"):GetText()
	if strUnit == "Target of Target" then strUnit = "ToT" end
	--Open Color Picker
	self.strColorPickerTargetUnit = strUnit
	self.strColorPickerTargetControl = "AbsorbBar"
	self.colorPicker:Show(true)
	self.colorPicker:ToFront()
end

function CandyUI_UnitFrames:OnShowAbsorbTextClick( wndHandler, wndControl, eMouseButton )
end

-----------------------------------------------------------------------------------------------
-- CandyUI_UnitFrames Instance
-----------------------------------------------------------------------------------------------
local CandyUI_UnitFramesInst = CandyUI_UnitFrames:new()
CandyUI_UnitFramesInst:Init()
