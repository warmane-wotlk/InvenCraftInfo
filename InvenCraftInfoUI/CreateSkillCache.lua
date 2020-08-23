local _G = _G
local max = _G.max
local min = _G.min
local type = _G.type
local pairs = _G.pairs
local ipairs = _G.ipairs
local select = _G.select
local GetItemInfo = _G.GetItemInfo
local GetTradeSkillLine = _G.GetTradeSkillLine
local GetNumTradeSkills = _G.GetNumTradeSkills
local GetTradeSkillInfo = _G.GetTradeSkillInfo
local GetTradeSkillRecipeLink = _G.GetTradeSkillRecipeLink
local GetTradeSkillSelectionIndex = _G.GetTradeSkillSelectionIndex

local skillMatch, numSkills, spellID, itemID, checkCount, checkCountMax = {}

local function clearMatchTable()
	skillMatchName = nil
	for p in pairs(skillMatch) do
		skillMatch[p] = nil
	end
end

local function makeMatchTable(skillName)
	skillName = skillName ==InvenCraftInfo.tradeSkillLocale["채광"] and InvenCraftInfo.tradeSkillLocale["제련술"] or skillName
	if skillMatchName ~= skillName then
		checkCountMax = 0
		skillMatchName = skillName
		for p in pairs(skillMatch) do
			skillMatch[p] = nil
		end
		if skillName then
			dataTable = InvenCraftInfo:GetSkillTable(skillName)
			if type(dataTable) == "table" then
				for p, v in pairs(dataTable) do
					skillMatch[v] = true
				end
			else
				skillMatchName = nil
			end
		end
	end
end

local function checkList()
	if TradeSkillFrame:IsShown() then
		makeMatchTable(GetTradeSkillLine())
		checkCount, headerCount = 0
		numSkills = GetNumTradeSkills()
		for i = 1, numSkills do
			if select(2, GetTradeSkillInfo(i)) ~= "header" then
				if GetTradeSkillRecipeLink(i) then
					spellID = InvenCraftInfo:GetLinkID(GetTradeSkillRecipeLink(i), "enchant")
					if not spellID then
						checkCount = checkCount + 1
					elseif skillMatch[spellID] then
						itemID = InvenCraftInfo:GetLinkID(GetTradeSkillItemLink(i), "item")
						if not (itemID and GetItemInfo(itemID)) then
							checkCount = checkCount + 1
						end
					end
				else
					checkCount = checkCount + 1
				end
			end
		end
		checkCountMax = max(checkCountMax, checkCount)
		return checkCount
	else
		clearMatchTable()
		return 0
	end
end

local function setStatusBar(value, minValue, maxValue)
	if InvenCraftInfoUI.blackBack then
		value = max(value, minValue)
		value = min(value, maxValue)
		InvenCraftInfoUI.blackBack.statusBar:SetMinMaxValues(minValue, maxValue)
		InvenCraftInfoUI.blackBack.statusBar:SetValue(value)
		InvenCraftInfoUI.blackBack.statusBar.text:SetFormattedText("%d / %d (%d%%)", value, maxValue, value / maxValue * 100)
	end
end

local function createBlackBack()
	if InvenCraftInfoUI.blackBack then return end
	local bb = CreateFrame("Frame", nil, InvenCraftInfoUI)
	bb:Hide()
	bb:SetPoint("TOPLEFT", InvenCraftInfoUI.skillButtons[1])
	bb:SetPoint("BOTTOMRIGHT", InvenCraftInfoUIDetailScrollFrameScrollBarScrollDownButton)
	bb:EnableMouse(true)
	bb:EnableMouseWheel(true)
	bb:SetToplevel(true)
	bb.tex = bb:CreateTexture(nil, "BACKGROUND")
	bb.tex:SetTexture(0, 0, 0)
	bb.tex:SetAlpha(0.8)
	bb.tex:SetAllPoints()
	bb.title = bb:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
	bb.title:SetPoint("CENTER", 0, 40)
	bb.title:SetText("전문기술 창을 열기 위한 정보를 수집중입니다.\n잠시만 기다려주세요.")
	bb.statusBar = CreateFrame("StatusBar", nil, bb)
	bb.statusBar:SetPoint("TOP", bb.title, "BOTTOM", 0, -20)
	bb.statusBar:SetWidth(bb.title:GetWidth())
	bb.statusBar:SetHeight(30)
	bb.statusBar:SetStatusBarTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar")
	bb.statusBar:SetStatusBarColor(0.25, 0.25, 0.75)
	bb.statusBar:SetMinMaxValues(0, 1)
	bb.statusBar:SetValue(0.5)
	bb.statusBar.border = bb.statusBar:CreateTexture(nil, "OVERLAY")
	bb.statusBar.border:SetPoint("TOPLEFT", bb.statusBar, -8, 15)
	bb.statusBar.border:SetPoint("BOTTOMRIGHT", bb.statusBar, 8, -15)
	bb.statusBar.border:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-BarBorder")
	bb.statusBar.text = bb.statusBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	bb.statusBar.text:SetPoint("CENTER", 0, 2)
	bb:SetScript("OnUpdate", function(self, timer)
		self.timer = self.timer + timer
		if self.timer >= 1 then
			self.timer = 0
			if checkList() == 0 then
				InvenCraftInfoUI:CheckSkillCache()
			elseif checkCountMax == 0 then
				checkCountMax = 1
				setStatusBar(checkCountMax - checkCount, 0, checkCountMax)
			else
				setStatusBar(checkCountMax - checkCount, 0, checkCountMax)
			end
		end
	end)
	bb.reload = CreateFrame("Frame", nil, InvenCraftInfoUI)
	bb.reload:Hide()
	bb.reload:SetScript("OnUpdate", function(self, timer)
		self.timer = self.timer + timer
		if self.timer > 3 then
			self.timer = 0
			if TradeSkillFrame:IsShown() then
				InvenCraftInfoUI.forceUpdateList = true
				InvenCraftInfoUI:ListUpdate()
				collectgarbage()
			end
			self:Hide()
		end
	end)

	InvenCraftInfoUI.blackBack = bb
end

function InvenCraftInfoUI:ClearSkillCache()
	clearMatchTable()
end

function InvenCraftInfoUI:CheckSkillCache()
	if checkList() > 0 then
		self.skipUpdate = true
		if self.makeSkillWindowDelay == nil then
			self.makeSkillWindowDelay = true
			self.listScroll:EnableMouseWheel(nil)
			self.detailScroll:EnableMouseWheel(nil)
			TradeSkillCollapseAllButton:Disable()
			TradeSkillFrameAvailableFilterCheckButton:Disable()
			TradeSkillFrameEditBox:ClearFocus()
			TradeSkillFrameEditBox:EnableMouse(nil)
			UIDropDownMenu_DisableDropDown(TradeSkillSubClassDropDown)
			UIDropDownMenu_DisableDropDown(TradeSkillInvSlotDropDown)
			TradeSkillCreateButton:Disable()
			TradeSkillCreateAllButton:Disable()
			TradeSkillDecrementButton:Disable()
			TradeSkillIncrementButton:Disable()
			TradeSkillInputBox:ClearFocus()
			TradeSkillInputBox:EnableMouse(nil)
			self:EnableFilter(nil)
			TradeSkillFrame_SetSelection(GetTradeSkillSelectionIndex())
			createBlackBack()
		end
		self.blackBack.reload:Hide()
		self.blackBack.timer = 0
		self.blackBack:Show()
		setStatusBar(0, 0, checkCountMax)
	else
		self.skipUpdate = nil
		clearMatchTable()
		if self.makeSkillWindowDelay then
			self.makeSkillWindowDelay = nil
			self.listScroll:EnableMouseWheel(true)
			self.detailScroll:EnableMouseWheel(true)
			TradeSkillCollapseAllButton:Enable()
			TradeSkillFrameAvailableFilterCheckButton:Enable()
			TradeSkillFrameEditBox:EnableMouse(1)
			UIDropDownMenu_EnableDropDown(TradeSkillSubClassDropDown)
			UIDropDownMenu_EnableDropDown(TradeSkillInvSlotDropDown)
			TradeSkillCreateButton:Enable()
			TradeSkillCreateAllButton:Enable()
			TradeSkillDecrementButton:Enable()
			TradeSkillIncrementButton:Enable()
			TradeSkillInputBox:EnableMouse(1)
			self:EnableFilter(self.isSort)
			InvenCraftInfoUI:TRADE_SKILL_SHOW()
			TradeSkillFrame_SetSelection(GetTradeSkillSelectionIndex())
		end
		if self.blackBack then
			self.blackBack:Hide()
			self.blackBack.reload.timer = 0
			self.blackBack.reload:Show()
		end
	end
end