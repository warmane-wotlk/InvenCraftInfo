local _G = _G
local pairs = _G.pairs
local ipairs = _G.ipairs
local unpack = _G.unpack
local select = _G.select
local tinsert = _G.tinsert
local GetSpellLink = _G.GetSpellLink
local EnumerateFrames = _G.EnumerateFrames
local IsModifiedClick = _G.IsModifiedClick
local GetTradeSkillSelectionIndex = _G.GetTradeSkillSelectionIndex
local dummyFunction = function() end
local simpleLink, nameLink = "\124H(.+)\124h%[", "\124h%[(.+)%]\124h"
local tabIndex
local editBoxIndex
local editBoxTabOrder = {}
local L = InvenCraftInfo.tradeSkillLocale

local function registerEditBoxTab(editBox)
	for _, box in ipairs(editBoxTabOrder) do
		if box == editBox then
			return
		end
	end
	tinsert(editBoxTabOrder, editBox)
end

local function editBoxSetNextTab(editBox)
	editBoxIndex = nil
	for i, box in ipairs(editBoxTabOrder) do
		if box == editBox then
			editBoxIndex = i
			break
		end
	end
	if editBoxIndex then
		if IsShiftKeyDown() then
			if editBoxIndex == 1 then
				editBoxTabOrder[#editBoxTabOrder]:SetFocus()
			else
				editBoxTabOrder[editBoxIndex - 1]:SetFocus()
			end
		elseif editBoxIndex == #editBoxTabOrder then
			editBoxTabOrder[1]:SetFocus()
		else
			editBoxTabOrder[editBoxIndex + 1]:SetFocus()
		end
	end
end

function InvenCraftInfoUI:CreateFrame()
	self:HideOldFrame()
	-- 기본 프레임 정의
	if type(InvenCraftInfoCharDB.pos) == "table" then
		self:SetPoint(unpack(InvenCraftInfoCharDB.pos))
	else
		self:SetPoint("CENTER")
	end
	self:SetWidth(680)
	self:SetHeight(440)
	self:EnableMouse(true)
	self:SetToplevel(true)
	self:SetMovable(true)
	self:RegisterForDrag("LeftButton")
	self:SetClampedToScreen(InvenCraftInfoDB.clamp)
	self:SetScale(InvenCraftInfoDB.scale)
	self:SetAlpha(InvenCraftInfoDB.alpha)
	tinsert(UISpecialFrames, "InvenCraftInfoUI")
	local function frameDragStart()
		InvenCraftInfoUI:StartMoving()
	end
	local function frameDragStop()
		InvenCraftInfoUI:StopMovingOrSizing()
		InvenCraftInfoCharDB.pos = InvenCraftInfoCharDB.pos or {}
		InvenCraftInfoCharDB.pos[1], _, _, InvenCraftInfoCharDB.pos[2], InvenCraftInfoCharDB.pos[3] = InvenCraftInfoUI:GetPoint()
	end
	self:SetScript("OnDragStart", frameDragStart)
	self:SetScript("OnDragStop", frameDragStop)
	self:SetScript("OnHide", function(self)
		if TradeSkillFrame:IsShown() then
			CloseTradeSkill()
		end
		self:ClearSortData()
		self:ClearSkillCache()
		self:StopDescUpdater()
		collectgarbage()
	end)
	-- 전문기술 아이콘
	self.skillIcon = self:CreateTexture(nil, "BACKGROUND")
	self.skillIcon:SetWidth(62)
	self.skillIcon:SetHeight(62)
	self.skillIcon:SetPoint("TOPLEFT", 6, -5)
	-- 옵션 토글 버튼
	self.mainbutton = CreateFrame("BUTTON", nil, self)
	self.mainbutton:SetAllPoints(self.skillIcon)
	self.mainbutton:RegisterForDrag("LeftButton")
	self.mainbutton:SetScript("OnClick", function() InterfaceOptionsFrame_OpenToCategory(InvenCraftInfoOptionFrame) end)
	self.mainbutton:SetScript("OnDragStart", frameDragStart)
	self.mainbutton:SetScript("OnDragStop", frameDragStop)
	-- 닫기 버튼
	self.closeButton = CreateFrame("Button", nil, self, "UIPanelCloseButton")
	self.closeButton:SetPoint("TOPRIGHT", 3, -8)
	-- 기본 프레임 틀
	self.topLeftBorder = self:CreateTexture(nil, "BORDER")
	self.topLeftBorder:SetPoint("TOPLEFT")
	self.topLeftBorder:SetWidth(256)
	self.topLeftBorder:SetHeight(256)
	self.topLeftBorder:SetTexture("Interface\\Addons\\InvenCraftInfoUI\\Texture\\UI-ClassTrainer-TopLeft")
	self.topRightBorder = self:CreateTexture(nil, "BORDER")
	self.topRightBorder:SetPoint("TOPRIGHT", 88, 0)
	self.topRightBorder:SetWidth(256)
	self.topRightBorder:SetHeight(256)
	self.topRightBorder:SetTexture("Interface\\Addons\\InvenCraftInfoUI\\Texture\\UI-ClassTrainer-TopRight")
	self.topBorder = self:CreateTexture(nil, "BACKGROUND")
	self.topBorder:SetPoint("TOPLEFT", 256, 0)
	self.topBorder:SetWidth(256)
	self.topBorder:SetHeight(256)
	self.topBorder:SetTexture("Interface\\Addons\\InvenCraftInfoUI\\Texture\\UI-ClassTrainer-Top")
	self.bottomBorder = self:CreateTexture(nil, "BACKGROUND")
	self.bottomBorder:SetPoint("TOPLEFT", 256, -256)
	self.bottomBorder:SetWidth(256)
	self.bottomBorder:SetHeight(256)
	self.bottomBorder:SetTexture("Interface\\Addons\\InvenCraftInfoUI\\Texture\\UI-ClassTrainer-Bottom")
	self.bottomLeftBorder = self:CreateTexture(nil, "BORDER")
	self.bottomLeftBorder:SetPoint("TOPLEFT", 0, -256)
	self.bottomLeftBorder:SetWidth(256)
	self.bottomLeftBorder:SetHeight(256)
	self.bottomLeftBorder:SetTexture("Interface\\Addons\\InvenCraftInfoUI\\Texture\\UI-ClassTrainer-BottomLeft")
	self.bottomRightBorder = self:CreateTexture(nil, "BORDER")
	self.bottomRightBorder:SetPoint("TOPRIGHT", 88, -256)
	self.bottomRightBorder:SetWidth(256)
	self.bottomRightBorder:SetHeight(256)
	self.bottomRightBorder:SetTexture("Interface\\Addons\\InvenCraftInfoUI\\Texture\\UI-ClassTrainer-BottomRight")
	self.rightLineBorder = self:CreateTexture(nil, "ARTWORK")
	self.rightLineBorder:SetPoint("TOPRIGHT", -2.5, -42)
	self.rightLineBorder:SetWidth(2)
	self.rightLineBorder:SetHeight(390)
	self.rightLineBorder:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopRight")
	self.rightLineBorder:SetTexCoord(0.71, 0.72, 0.2, 1)
	-- 타이틀
	self.titleText = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	self.titleText:SetWidth(265)
	self.titleText:SetHeight(14)
	self.titleText:SetPoint("TOP", 0, -17)
	self.titleText:SetText("Inven Craft Info v"..InvenCraftInfo.version)
	-- 전문기술 이름
	self.tradeSkillTitle = self:CreateFontString(nil, "OVERLAY", "QuestFont_Shadow_Huge")
	self.tradeSkillTitle:SetPoint("TOP", self, "TOPLEFT", 136, -50)
	self.tradeSkillTitle:SetShadowColor(0, 0, 0)
	self.tradeSkillTitle:SetShadowOffset(2, -2)
	self.tradeSkillTitle:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	-- 링크 버튼
	TradeSkillLinkButton:ClearAllPoints()
	TradeSkillLinkButton:SetPoint("TOP", self.tradeSkillTitle, "BOTTOM", 4, -2)
	TradeSkillLinkButton:GetNormalTexture():SetTexCoord(0, 1, 0, 0.49)
	TradeSkillLinkButton:GetHighlightTexture():SetTexCoord(0, 1, 0.5, 0.99)
	TradeSkillLinkButton:SetScript("OnShow", function()
		InvenCraftInfoUI.tradeSkillTitle:ClearAllPoints()
		InvenCraftInfoUI.tradeSkillTitle:SetPoint("TOP", InvenCraftInfoUI, "TOPLEFT", 136, -50)
	end)
	TradeSkillLinkButton:SetScript("OnHide", function()
		InvenCraftInfoUI.tradeSkillTitle:ClearAllPoints()
		InvenCraftInfoUI.tradeSkillTitle:SetPoint("TOP", InvenCraftInfoUI, "TOPLEFT", 136, -56)
	end)
	-- 제작 버튼
	local function lockElement(frame)
		frame.SetWidth = dummyFunction
		frame.SetHeight = dummyFunction
		frame.ClearAllPoints = dummyFunction
		frame.SetPoint = dummyFunction
		frame.Hide = frame.Show
	end
	TradeSkillCancelButton:ClearAllPoints()
	TradeSkillCancelButton:SetPoint("BOTTOMRIGHT", -7, 8)
	TradeSkillCreateButton:ClearAllPoints()
	TradeSkillCreateButton:SetPoint("RIGHT", TradeSkillCancelButton, "LEFT", 0, 0)
	lockElement(TradeSkillCancelButton)
	lockElement(TradeSkillCreateButton)
	lockElement(TradeSkillCreateAllButton)
	lockElement(TradeSkillIncrementButton)
	lockElement(TradeSkillDecrementButton)
	lockElement(TradeSkillInputBox)
	-- 전체 닫기 버튼
	TradeSkillExpandButtonFrame:ClearAllPoints()
	TradeSkillExpandButtonFrame:SetPoint("TOPLEFT", 15, -71)
	TradeSkillExpandTabMiddle:SetWidth(46)
	lockElement(TradeSkillExpandButtonFrame)
	lockElement(TradeSkillExpandTabLeft)
	lockElement(TradeSkillExpandTabMiddle)
	lockElement(TradeSkillExpandTabRight)
	lockElement(TradeSkillCollapseAllButton)
	-- 필터링 드롭다운
	TradeSkillSubClassDropDown:ClearAllPoints()
	TradeSkillSubClassDropDown:SetPoint("BOTTOM", TradeSkillInvSlotDropDown, "TOP", 0, -5)
	TradeSkillInvSlotDropDown:ClearAllPoints()
	TradeSkillInvSlotDropDown:SetPoint("TOPLEFT", TradeSkillExpandButtonFrame, "TOPRIGHT", 120, 5)
	TradeSkillInvSlotDropDown:SetFrameLevel(TradeSkillSubClassDropDown:GetFrameLevel() + 1)
	lockElement(TradeSkillSubClassDropDown)
	lockElement(TradeSkillInvSlotDropDown)
	-- 전문기술 숙련도
	TradeSkillRankFrame:UnregisterAllEvents()
	TradeSkillRankFrame:SetScript("OnEvent", nil)
	TradeSkillRankFrame:ClearAllPoints()
	TradeSkillRankFrame:SetPoint("TOPLEFT", TradeSkillInvSlotDropDown, "TOPRIGHT", -12, -4)
	TradeSkillRankFrame:SetWidth(177)
	TradeSkillRankFrame:SetHeight(21)
	TradeSkillRankFrame:SetStatusBarColor(0.0, 0.0, 1.0, 0.5)
	TradeSkillRankFrame.SetMinMaxValues = dummyFunction
	TradeSkillRankFrame.SetValue = dummyFunction
	TradeSkillRankFrame.SetStatusBarColor = dummyFunction
	TradeSkillRankFrameBackground:SetVertexColor(0.0, 0.0, 0.75, 0.5)
	TradeSkillRankFrameBorder:ClearAllPoints()
	TradeSkillRankFrameBorder:SetPoint("TOPLEFT", TradeSkillRankFrame, "TOPLEFT", -4, 12)
	TradeSkillRankFrameBorder:SetPoint("BOTTOMRIGHT", TradeSkillRankFrame, "BOTTOMRIGHT", 4, -12)
	TradeSkillRankFrameSkillRank:ClearAllPoints()
	TradeSkillRankFrameSkillRank:SetPoint("CENTER", TradeSkillRankFrame, "CENTER", 1, 1)
	TradeSkillRankFrameSkillRank.SetText = dummyFunction
	TradeSkillRankFrameSkillRank.SetFormattedText = dummyFunction
	lockElement(TradeSkillRankFrame)
	lockElement(TradeSkillRankFrameBorder)
	lockElement(TradeSkillRankFrameSkillRank)
	-- 재료 있음 버튼
	TradeSkillFrameAvailableFilterCheckButton:ClearAllPoints()
	TradeSkillFrameAvailableFilterCheckButton:SetPoint("BOTTOMLEFT", TradeSkillRankFrame, "TOPLEFT", -4, 5)
	lockElement(TradeSkillFrameAvailableFilterCheckButton)
	-- 검색 버튼
	TradeSkillFrameEditBox:ClearAllPoints()
	TradeSkillFrameEditBox:SetPoint("LEFT", TradeSkillFrameAvailableFilterCheckButton, "RIGHT", 50, 0)
	TradeSkillFrameEditBox:SetWidth(136)
	TradeSkillFrameEditBox:SetFrameLevel(TradeSkillFrameAvailableFilterCheckButton:GetFrameLevel() + 1)
	TradeSkillFrameEditBox:SetScript("OnTabPressed", editBoxSetNextTab)
	registerEditBoxTab(TradeSkillFrameEditBox)
	lockElement(TradeSkillFrameEditBox)
	-- 배운 전문기술 상태바
	self.tradeSkillNumBar = CreateFrame("StatusBar", nil, self)
	self.tradeSkillNumBar:SetStatusBarTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar")
	self.tradeSkillNumBar:SetStatusBarColor(0, 0, 1, 0.75)
	self.tradeSkillNumBar:SetWidth(315)
	self.tradeSkillNumBar:SetHeight(13)
	self.tradeSkillNumBar:SetPoint("BOTTOMLEFT", 25, 13)
	self.tradeSkillNumBar.text = self.tradeSkillNumBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.tradeSkillNumBar.text:SetPoint("CENTER", 0, 1)
	self.tradeSkillNumBar.bg = self.tradeSkillNumBar:CreateTexture(nil, "BACKGROUND")
	self.tradeSkillNumBar.bg:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar")
	self.tradeSkillNumBar.bg:SetVertexColor(0, 0, 0.75, 0.5)
	self.tradeSkillNumBar.bg:SetAllPoints()
	-- 추가 필터 만들기
	self.sortDropdown = CreateFrame("Frame", "TradeSkillSortDropDown", self, "UIDropDownMenuTemplate")
	UIDropDownMenu_SetWidth(self.sortDropdown, 100)
	self.sortDropdown:SetID(3)
	self.sortDropdown.isEnable = true
	self.sortDropdown:SetPoint("LEFT", TradeSkillFrameEditBox, "RIGHT", -14, -2)
	self.sortDropdown.orders = { "숙련 색상 우선", "필요 숙련 우선", "이름 우선" }
	self.sortDropdown.SetValue = function(self)
		if type(InvenCraftInfoUI.orderDB) == "table" then
			InvenCraftInfoUI.orderDB.order = self.value
			UIDropDownMenu_SetText(TradeSkillSortDropDown, self.value)
			InvenCraftInfoUI:UpdateList()
		end
	end
	UIDropDownMenu_Initialize(TradeSkillSortDropDown, function(self)
		local info = UIDropDownMenu_CreateInfo()
		for _, v in ipairs(self.orders) do
			info.text = v
			info.value = v
			info.func = TradeSkillSortDropDown.SetValue
			info.checked = InvenCraftInfoUI.orderDB and InvenCraftInfoUI.orderDB.order == v
			UIDropDownMenu_AddButton(info)
		end
	end)
	local function reqEditBoxOnTextChanged(self)
		if TradeSkillSortDropDown.isEnable and type(InvenCraftInfoUI.orderDB) == "table" then
			self.value = self:GetText() or ""
			if self.value:sub(1, 1) == "0" and self.value:len() > 1 then
				self:SetText(self.value:sub(2) or 0)
			end
			self.value = self:GetNumber()
			if self:GetID() == 1 then
				if self.value < 2 then
					self.value = nil
				end
				if InvenCraftInfoUI.orderDB.min ~= self.value then
					InvenCraftInfoUI.orderDB.min = self.value
					InvenCraftInfoUI:UpdateList()
				end
			else
				if self.value >= InvenCraftInfo.maxSkillLevel or self.value == 0 then
					self.value = nil
				end
				if InvenCraftInfoUI.orderDB.max ~= self.value then
					InvenCraftInfoUI.orderDB.max = self.value
					InvenCraftInfoUI:UpdateList()
				end
			end
		end
	end
	local function createEditBox(name)
		local f = CreateFrame("EditBox", name, self)
		f:SetWidth(29)
		f:SetHeight(20)
		f:SetAutoFocus(nil)
		f:SetNumeric(true)
		f:SetMaxLetters(3)
		f:SetScript("OnEnterPressed", EditBox_ClearFocus)
		f:SetScript("OnEscapePressed", EditBox_ClearFocus)
		f:SetScript("OnEditFocusLost", EditBox_ClearHighlight)
		f:SetScript("OnEditFocusGained", EditBox_HighlightText)
		f:SetScript("OnTextChanged", reqEditBoxOnTextChanged)
		f:SetScript("OnTabPressed", editBoxSetNextTab)
		f:SetFontObject("GameFontHighlightSmall")
		f.left = f:CreateTexture(nil, "BACKGROUND")
		f.left:SetTexture("Interface\\Common\\Common-Input-Border")
		f.left:SetWidth(8)
		f.left:SetHeight(20)
		f.left:SetTexCoord(0, 0.0625, 0, 0.625)
		f.left:SetPoint("TOPLEFT", -5, 0)
		f.right = f:CreateTexture(nil, "BACKGROUND")
		f.right:SetTexture("Interface\\Common\\Common-Input-Border")
		f.right:SetWidth(8)
		f.right:SetHeight(20)
		f.right:SetTexCoord(0.9375, 1, 0, 0.625)
		f.right:SetPoint("RIGHT", 0, 0)
		f.middle = f:CreateTexture(nil, "BACKGROUND")
		f.middle:SetTexture("Interface\\Common\\Common-Input-Border")
		f.middle:SetWidth(0)
		f.middle:SetHeight(20)
		f.middle:SetTexCoord(0.0625, 0.9375, 0, 0.625)
		f.middle:SetPoint("LEFT", f.left, "RIGHT")
		f.middle:SetPoint("RIGHT", f.right, "LEFT")
		registerEditBoxTab(f)
		return f
	end
	self.reqFilter = self:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	self.reqFilter:SetPoint("LEFT", TradeSkillRankFrame, "RIGHT", 6, 0)
	self.reqFilter:SetText("숙련필터")
	self.minReqText = createEditBox("TradeSkillFrameMinReqText")
	self.minReqText:SetID(1)
	self.minReqText:SetPoint("LEFT", self.reqFilter, "RIGHT", 7, 0)
	self.maxReqText = createEditBox("TradeSkillFrameMaxReqText")
	self.maxReqText:SetID(2)
	self.maxReqText:SetPoint("LEFT", self.minReqText, "RIGHT", 17, 0)
	self.reqFilterDash = self:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	self.reqFilterDash:SetPoint("LEFT", self.minReqText, "RIGHT", 0, 2)
	self.reqFilterDash:SetText("ㅡ")
	self.reqClear = CreateFrame("Button", "TradeSkillFrameClearReqButton", self)
	self.reqClear:SetPoint("LEFT", TradeSkillFrameMaxReqText, "RIGHT", -8, -2)
	self.reqClear:SetWidth(36)
	self.reqClear:SetHeight(42)
	self.reqClear:SetNormalTexture("Interface\\Buttons\\CancelButton-Up")
	self.reqClear:SetPushedTexture("Interface\\Buttons\\CancelButton-Down")
	self.reqClear:SetHighlightTexture("Interface\\Buttons\\CancelButton-Highlight", "ADD")
	self.reqClear:SetDisabledTexture("Interface\\Buttons\\CancelButton-Up")
	self.reqClear:GetDisabledTexture():SetDesaturated(true)
	self.reqClear:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("숙련 필터 초기화")
	end)
	self.reqClear:SetScript("OnLeave", GameTooltip_Hide)
	self.reqClear:SetScript("OnClick", function()
		if InvenCraftInfoUI.orderDB.max or InvenCraftInfoUI.orderDB.min then
			InvenCraftInfoUI.orderDB.max = nil
			InvenCraftInfoUI.orderDB.min = nil
			TradeSkillFrameMinReqText:SetText("")
			TradeSkillFrameMaxReqText:SetText("")
			InvenCraftInfoUI:UpdateList()
		end
		TradeSkillFrameEditBox:ClearFocus()
		TradeSkillFrameMinReqText:ClearFocus()
		TradeSkillFrameMaxReqText:ClearFocus()
	end)
	-- 목록 스크롤 만들기
	self.listScroll = CreateFrame("ScrollFrame", "InvenCraftInfoUIListScrollFrame", self, "ClassTrainerListScrollFrameTemplate")
	self.listScroll:SetPoint("TOPLEFT", 21, -96)
	self.listScroll:SetWidth(296)
	self.listScroll:SetHeight(311)
	self.listScroll:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, 16, InvenCraftInfoUI.ListUpdate)
	end)
	local texture = InvenCraftInfoUIListScrollFrame:GetRegions()
	texture:SetWidth(30)
	texture:SetHeight(253)
	texture:ClearAllPoints()
	texture:SetPoint("TOPLEFT", InvenCraftInfoUIListScrollFrame, "TOPRIGHT", -2, 2)
	texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
	texture:SetTexCoord(0, 0.46875, 0.01171875, 1)
	texture:Show()
	texture = select(2, InvenCraftInfoUIListScrollFrame:GetRegions())
	texture:SetWidth(30)
	texture:SetHeight(108)
	texture:ClearAllPoints()
	texture:SetPoint("BOTTOMLEFT", InvenCraftInfoUIListScrollFrame, "BOTTOMRIGHT", -2, -4)
	texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
	texture:SetTexCoord(0.515625, 0.984375, 0, 0.421875)
	texture:Show()
	self.skillButtons = {}
	local function skillButtonOnClick(self, button)
		if InvenCraftInfoUI.isSort and self.fakeHeader then
			InvenCraftInfoUI.headerExpand[GetTradeSkillLine()][self.fakeHeader] = not InvenCraftInfoUI.headerExpand[GetTradeSkillLine()][self.fakeHeader]
			InvenCraftInfoUI:UpdateList()
		elseif IsModifiedClick("CHATLINK") then
			if TinyPad and TinyPadEditBox and TinyPadEditBox:IsShown() and TinyPad.has_focus then
				TinyPadEditBox:Insert(GetTradeSkillRecipeLink(self:GetID()))
			else
				ChatFrame1EditBox:Show()
				ChatFrame1EditBox:Insert(GetTradeSkillRecipeLink(self:GetID()))
			end
		elseif IsModifiedClick("DRESSUP") then
			DressUpItemLink(GetTradeSkillItemLink(self:GetID()))
		elseif IsModifiedClick() then
			HandleModifiedItemClick(GetTradeSkillRecipeLink(self:GetID()))
		else
			if GetTradeSkillSelectionIndex() ~= self:GetID() then
				InvenCraftInfoUI:UpdateQuee(self:GetID(), true)
			end
			TradeSkillFrame_SetSelection(self:GetID())
		end
		TradeSkillFrameEditBox:ClearFocus()
	end
	local function skillButtonOnEnter(self)
		if InvenCraftInfoDB.listTootip and GetTradeSkillRecipeLink(self:GetID()) then
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
			GameTooltip:SetHyperlink(GetTradeSkillRecipeLink(self:GetID()))
			GameTooltip:Show()
		end
	end
	local function checkButtonOnClick(self, button)
		skillButtonOnClick(self:GetParent(), button)
	end
	local function checkButtonOnEnter(self)
		if self.tooltipText then
			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
			GameTooltip:AddLine(self.tooltipText, 1, 1, 1)
			GameTooltip:Show()
		end
	end
	for i = 1, 20 do
		self.skillButtons[i] = CreateFrame("Button", "InvenCraftInfoUISkillButton"..i, self, "TradeSkillSkillButtonTemplate")
		self.skillButtons[i]:SetPoint("TOPLEFT", self.skillButtons[i - 1], "BOTTOMLEFT", 0, 0.5)
		self.skillButtons[i]:SetScript("OnClick", skillButtonOnClick)
		self.skillButtons[i]:SetScript("OnEnter", skillButtonOnEnter)
		self.skillButtons[i]:SetScript("OnLeave", GameTooltip_Hide)
		self.skillButtons[i].text = _G["InvenCraftInfoUISkillButton"..i.."Text"]
		self.skillButtons[i].count = _G["InvenCraftInfoUISkillButton"..i.."Count"]
		self.skillButtons[i].highlight = _G["InvenCraftInfoUISkillButton"..i.."Highlight"]
		self.skillButtons[i].checkButton = CreateFrame("Button", nil, self.skillButtons[i])
		self.skillButtons[i].checkButton:SetWidth(16)
		self.skillButtons[i].checkButton:SetHeight(16)
		self.skillButtons[i].checkButton:SetPoint("LEFT", self.skillButtons[i], "LEFT", 10, 0)
		self.skillButtons[i].checkButton:SetScript("OnClick", checkButtonOnClick)
		self.skillButtons[i].checkButton:SetScript("OnEnter", checkButtonOnEnter)
		self.skillButtons[i].checkButton:SetScript("OnLeave", GameTooltip_Hide)
		self.skillButtons[i].checkTexture = self.skillButtons[i].checkButton:CreateTexture(nil, "OVERLAY")
		self.skillButtons[i].checkTexture:SetAllPoints(self.skillButtons[i].checkButton)
		self.skillButtons[i].source1 = CreateFrame("Button", nil, self.skillButtons[i])
		self.skillButtons[i].source1:SetWidth(12)
		self.skillButtons[i].source1:SetHeight(12)
		self.skillButtons[i].source1:SetPoint("LEFT", self.skillButtons[i].count, "RIGHT", 2, -1)
		self.skillButtons[i].source1:SetScript("OnClick", checkButtonOnClick)
		self.skillButtons[i].source1:SetScript("OnEnter", checkButtonOnEnter)
		self.skillButtons[i].source1:SetScript("OnLeave", GameTooltip_Hide)
		self.skillButtons[i].source1:Hide()
		self.skillButtons[i].source1:SetNormalTexture("Interface\\Icons\\Temp")
		self.skillButtons[i].source1.texture = self.skillButtons[i].source1:GetNormalTexture()
		self.skillButtons[i].source2 = CreateFrame("Button", nil, self.skillButtons[i])
		self.skillButtons[i].source2:SetWidth(12)
		self.skillButtons[i].source2:SetHeight(12)
		self.skillButtons[i].source2:SetPoint("LEFT", self.skillButtons[i].source1, "RIGHT", -1, 0)
		self.skillButtons[i].source2:SetScript("OnClick", checkButtonOnClick)
		self.skillButtons[i].source2:SetScript("OnEnter", checkButtonOnEnter)
		self.skillButtons[i].source2:SetScript("OnLeave", GameTooltip_Hide)
		self.skillButtons[i].source2:Hide()
	end
	self.skillButtons[1]:ClearAllPoints()
	self.skillButtons[1]:SetPoint("TOPLEFT", 22, -96)
	self.listHighlightBar = CreateFrame("Frame", nil, self)
	self.listHighlightBar:SetWidth(293)
	self.listHighlightBar:SetHeight(16)
	self.listHighlightBar.textrue = self.listHighlightBar:CreateTexture(nil, "ARTWORK")
	self.listHighlightBar.textrue:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight2")
	self.listHighlightBar.textrue:SetAllPoints()
	self.listHighlightBar2 = CreateFrame("Frame", nil, self)
	self.listHighlightBar2:SetWidth(293)
	self.listHighlightBar2:SetHeight(16)
	self.listHighlightBar2.textrue = self.listHighlightBar2:CreateTexture(nil, "ARTWORK")
	self.listHighlightBar2.textrue:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight2")
	self.listHighlightBar2.textrue:SetAllPoints()
	-- 상세 목록 만들기
	self.detailScroll = CreateFrame("ScrollFrame", "InvenCraftInfoUIDetailScrollFrame", self, "ClassTrainerDetailScrollFrameTemplate")
	self.detailScroll:SetPoint("TOPLEFT", self.listScroll, "TOPRIGHT", 30, -2)
	self.detailScroll:SetWidth(298)
	self.detailScroll:SetHeight(310)
	texture = InvenCraftInfoUIDetailScrollFrame:GetRegions()
	texture:SetWidth(30)
	texture:SetHeight(253)
	texture:ClearAllPoints()
	texture:SetPoint("TOPLEFT", InvenCraftInfoUIDetailScrollFrame, "TOPRIGHT", -2, 2)
	texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
	texture:SetTexCoord(0, 0.46875, 0.01171875, 1)
	texture:Show()
	texture = select(2, InvenCraftInfoUIDetailScrollFrame:GetRegions())
	texture:SetWidth(30)
	texture:SetHeight(108)
	texture:ClearAllPoints()
	texture:SetPoint("BOTTOMLEFT", InvenCraftInfoUIDetailScrollFrame, "BOTTOMRIGHT", -2, -4)
	texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
	texture:SetTexCoord(0.515625, 0.984375, 0, 0.421875)
	texture:Show()
	self.detailScrollChild = CreateFrame("Frame", nil, self.detailScroll)
	self.detailScroll:SetScrollChild(self.detailScrollChild)
	self.detailScrollChild:SetWidth(297)
	self.detailScrollChild:SetHeight(150)
	self.detailScrollChild.headerLeft = self.detailScrollChild:CreateTexture(nil, "BACKGROUND")
	self.detailScrollChild.headerLeft:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-DetailHeaderLeft")
	self.detailScrollChild.headerLeft:SetWidth(302)
	self.detailScrollChild.headerLeft:SetHeight(77)
	self.detailScrollChild.headerLeft:SetPoint("TOPLEFT", -2, 3)
	self.detailScrollChild.skillName = self.detailScrollChild:CreateFontString(nil, "BACKGROUND", "GameFontNormal")	-- TradeSkillSkillName
	self.detailScrollChild.skillName:SetJustifyH("LEFT")
	self.detailScrollChild.skillName:SetWidth(0)
	self.detailScrollChild.skillName:SetHeight(0)
	self.detailScrollChild.skillName:SetPoint("TOPLEFT", 56, -5)
	self.detailScrollChild.favorite = CreateFrame("Button", nil, self.detailScrollChild)
	self.detailScrollChild.favorite:SetPoint("LEFT", self.detailScrollChild.skillName, "RIGHT", 5, 1)
	self.detailScrollChild.favorite:SetWidth(16)
	self.detailScrollChild.favorite:SetHeight(16)
	self.detailScrollChild.favorite:RegisterForClicks("LeftButtonUp")
	self.detailScrollChild.favorite:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(InvenCraftInfoUICharDB.favorite[self.link] and "즐겨찾기에서 제거하기" or "즐겨찾기에 추가하기")
		GameTooltip:Show()
	end)
	self.detailScrollChild.favorite:SetScript("OnLeave", GameTooltip_Hide)
	self.detailScrollChild.favorite:SetScript("OnClick", function(self)
		if InvenCraftInfoUICharDB.favorite[self.link] then
			InvenCraftInfoUICharDB.favorite[self.link] = nil
			self:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
		else
			InvenCraftInfoUICharDB.favorite[self.link] = true
			self:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Disabled")
		end
		self:GetScript("OnEnter")(self)
		InvenCraftInfoUI.forceUpdateList = true
		InvenCraftInfoUI:ListUpdate()
	end)
	self.detailScrollChild.reqTool = self.detailScrollChild:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall") -- TradeSkillRequirementLabel
	self.detailScrollChild.reqTool:SetJustifyH("LEFT")
	self.detailScrollChild.reqTool:SetWidth(244)
	self.detailScrollChild.reqTool:SetHeight(0)
	self.detailScrollChild.reqTool:SetPoint("TOPLEFT", self.detailScrollChild.skillName, "BOTTOMLEFT")
	self.detailScrollChild.reqRank = self.detailScrollChild:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
	self.detailScrollChild.reqRank:SetJustifyH("LEFT")
	self.detailScrollChild.reqRank:SetWidth(244)
	self.detailScrollChild.reqRank:SetHeight(0)
	self.detailScrollChild.reqRank:SetPoint("TOPLEFT", self.detailScrollChild.reqTool, "BOTTOMLEFT")
	self.detailScrollChild.cooldown = self.detailScrollChild:CreateFontString(nil, "BACKGROUND", "GameFontRedSmall") -- TradeSkillSkillCooldown
	self.detailScrollChild.cooldown:SetPoint("TOPLEFT", self.detailScrollChild.reqRank, "BOTTOMLEFT")
	self.detailScrollChild.desc = self.detailScrollChild:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall") -- TradeSkillDescription
	self.detailScrollChild.desc:SetJustifyH("LEFT")
	self.detailScrollChild.desc:SetWidth(290)
	self.detailScrollChild.desc:SetHeight(0)
	self.detailScrollChild.desc:SetPoint("TOPLEFT", 5, -60)
	self.detailScrollChild.reagentLabel = self.detailScrollChild:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall") -- TradeSkillReagentLabel
	self.detailScrollChild.reagentLabel:SetText(SPELL_REAGENTS)
	self.detailScrollChild.reagentLabel:SetPoint("TOPLEFT", self.detailScrollChild.desc, "BOTTOMLEFT", 0, -10)
	local function itemButtonOnClick(link, button)
		if link then
			if link:find("item:") then
				local itemName = GetItemInfo(link) or link:match(nameLink)
				local itemID = tonumber(link:match("item:(%d+)") or "")
				if itemID then
					if BlueItemInfo2 and IsShiftKeyDown() and IsControlKeyDown() then
						BlueItemInfo2:AddMemo(itemID)
					elseif BlueItemInfo2 and IsAltKeyDown() then
						BlueItemInfo2:AddFavoriteItem(itemID)
					elseif IsModifiedClick("CHATLINK") then
						if AuctionFrame and AuctionFrame:IsVisible() and BrowseName:IsVisible() then
							BrowseName:SetText(itemName)
						elseif TinyPad and TinyPadEditBox and TinyPadEditBox:IsShown() and TinyPad.has_focus then
							TinyPadEditBox:Insert(link)
						else
							ChatFrame1EditBox:Show()
							ChatFrame1EditBox:Insert(link)
						end
					elseif IsModifiedClick("DRESSUP") then
						DressUpItemLink(link)
					else
						SetItemRef(link:match(simpleLink) or link, itemName, button)
					end
				end
			elseif link:find("enchant:") then
				local enchantName = GetSpellInfo(link) or link:match(nameLink)
				local enchantID = tonumber(link:match("enchant:(%d+)") or "")
				if enchantID then
					if BlueItemInfo2 and IsAltKeyDown() then
						BlueItemInfo2:AddFavoriteItem(-enchantID)
					elseif IsModifiedClick("CHATLINK") then
						if TinyPad and TinyPadEditBox and TinyPadEditBox:IsShown() and TinyPad.has_focus then
							TinyPadEditBox:Insert(link)
						else
							ChatFrame1EditBox:Show()
							ChatFrame1EditBox:Insert(link)
						end
					else
						SetItemRef(link:match(simpleLink) or link, enchantName, button)
					end
				end
			end
		end
	end
	self.detailScrollChild.skillIcon = CreateFrame("Button", nil, self.detailScrollChild)
	self.detailScrollChild.skillIcon:SetWidth(44)
	self.detailScrollChild.skillIcon:SetHeight(44)
	self.detailScrollChild.skillIcon:SetPoint("TOPLEFT", 8, -5)
	self.detailScrollChild.skillIcon.count = self.detailScrollChild.skillIcon:CreateFontString(nil, "ARTWORK", "NumberFontNormal")
	self.detailScrollChild.skillIcon.count:SetJustifyH("RIGHT")
	self.detailScrollChild.skillIcon.count:SetPoint("BOTTOMRIGHT", -5, 2)
	self.detailScrollChild.skillIcon:SetScript("OnClick", function(self, button)
		itemButtonOnClick(GetTradeSkillItemLink(TradeSkillFrame.selectedSkill), button)
	end)
	self.detailScrollChild.skillIcon:SetScript("OnUpdate", function(self)
		if GameTooltip:IsOwned(self) then
			TradeSkillItem_OnEnter(self)
		end
	end)
	self.detailScrollChild.skillIcon:SetScript("OnEnter", TradeSkillItem_OnEnter)
	self.detailScrollChild.skillIcon:SetScript("OnLeave", GameTooltip_HideResetCursor)
	self.detailScrollChild.skillIcon.rarityBorder = self.detailScrollChild.skillIcon:CreateTexture(nil, "OVERLAY")
	self.detailScrollChild.skillIcon.rarityBorder:SetPoint("CENTER", self.detailScrollChild.skillIcon, "CENTER", 0, 1)
	self.detailScrollChild.skillIcon.rarityBorder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
	self.detailScrollChild.skillIcon.rarityBorder:SetBlendMode("ADD")
	self.detailScrollChild.skillIcon.rarityBorder:SetAlpha(0.75)
	self.detailScrollChild.skillIcon.rarityBorder:SetHeight(90)
	self.detailScrollChild.skillIcon.rarityBorder:SetWidth(90)
	self.detailScrollChild.skillIcon.rarityBorder:Hide()
	self.detailScrollChild.skillIcon.rarityBorder:SetWidth(90)
	self.detailScrollChild.skillIcon.rarityBorder:SetHeight(90)
	self.reagentButtons = {}
	local function goToButtonOnEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(self.tooltipText)
		GameTooltip:Show()
	end
	local function goToButtonOnClick(self)
		InvenCraftInfoUI:UpdateQuee(self.index)
		TradeSkillFrame_SetSelection(self.index)
		TradeSkillFrame_Update()
	end
	local function rbButtonOnClick(self, button)
		itemButtonOnClick(GetTradeSkillReagentItemLink(TradeSkillFrame.selectedSkill, self:GetID()) or nil, button)
	end
	for i = 1, 8 do
		self.reagentButtons[i] = CreateFrame("Button", "InvenCraftInfoUIReagent"..i, self.detailScrollChild, "TradeSkillItemTemplate")
		self.reagentButtons[i]:SetID(i)
		self.reagentButtons[i]:SetPoint("LEFT", self.reagentButtons[i - 1], "RIGHT", 0, 0)
		self.reagentButtons[i]:SetScript("OnClick", rbButtonOnClick)
		self.reagentButtons[i].icon = _G["InvenCraftInfoUIReagent"..i.."IconTexture"]
		self.reagentButtons[i].count = _G["InvenCraftInfoUIReagent"..i.."Count"]
		self.reagentButtons[i].count:SetFont(STANDARD_TEXT_FONT, InvenCraftInfoDB.reagentCountSize, "OUTLINE")
		self.reagentButtons[i].text = _G["InvenCraftInfoUIReagent"..i.."Name"]
		self.reagentButtons[i].goto = CreateFrame("Button", nil, self.reagentButtons[i])
		self.reagentButtons[i].goto:SetID(i)
		self.reagentButtons[i].goto:SetWidth(15)
		self.reagentButtons[i].goto:SetHeight(15)
		self.reagentButtons[i].goto:SetScript("OnClick", goToButtonOnClick)
		self.reagentButtons[i].goto:SetScript("OnEnter", goToButtonOnEnter)
		self.reagentButtons[i].goto:SetScript("OnLeave", GameTooltip_Hide)
		self.reagentButtons[i].goto:SetScript("OnLeave", GameTooltip_Hide)
		self.reagentButtons[i].goto:SetNormalTexture("Interface\\AchievementFrame\\UI-Achievement-PlusMinus")
		self.reagentButtons[i].goto:GetNormalTexture():SetTexCoord(0, 0.5, 0, 0.5)
		self.reagentButtons[i].goto:SetHighlightTexture("Interface\\AchievementFrame\\UI-Achievement-PlusMinus", "ADD")
		self.reagentButtons[i].goto:GetHighlightTexture():SetTexCoord(0, 0.5, 0, 0.5)
		self.reagentButtons[i].goto:SetPoint("TOPLEFT", 0, -1)
		self.reagentButtons[i].goto:SetScale(0.9)
		self.reagentButtons[i].goto:Hide()
		self.reagentButtons[i].rarityBorder = self.reagentButtons[i]:CreateTexture(nil, "OVERLAY")
		self.reagentButtons[i].rarityBorder:SetPoint("CENTER", self.reagentButtons[i].icon, "CENTER", 0, 1)
		self.reagentButtons[i].rarityBorder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
		self.reagentButtons[i].rarityBorder:SetBlendMode("ADD")
		self.reagentButtons[i].rarityBorder:SetAlpha(0.75)
		self.reagentButtons[i].rarityBorder:SetHeight(68)
		self.reagentButtons[i].rarityBorder:SetWidth(68)
		self.reagentButtons[i].rarityBorder:Hide()
	end
	self.reagentButtons[1]:ClearAllPoints()
	self.reagentButtons[1]:SetPoint("TOPLEFT", self.detailScrollChild.reagentLabel, "BOTTOMLEFT", 1, -3)
	self.reagentButtons[3]:ClearAllPoints()
	self.reagentButtons[3]:SetPoint("TOP", self.reagentButtons[1], "BOTTOM", 0, -2)
	self.reagentButtons[5]:ClearAllPoints()
	self.reagentButtons[5]:SetPoint("TOP", self.reagentButtons[3], "BOTTOM", 0, -2)
	self.reagentButtons[7]:ClearAllPoints()
	self.reagentButtons[7]:SetPoint("TOP", self.reagentButtons[5], "BOTTOM", 0, -2)
	self.gotoBack = CreateFrame("Button", "TradeSkillFrameGoToBack", self.detailScrollChild)
	self.gotoBack:SetWidth(32)
	self.gotoBack:SetHeight(32)
	self.gotoBack:SetPoint("TOPRIGHT", self.detailScrollChild.headerLeft, "TOPRIGHT", 0, 0)
	self.gotoBack:SetNormalTexture("Interface\\Minimap\\Rotating-MinimapArrow")
	self.gotoBack:SetScript("OnShow", function(self) self:SetNormalTexture("Interface\\Minimap\\Rotating-MinimapArrow") end)
	self.gotoBack:SetScript("OnEnter", function(self)
		self.enter = true
		self:SetNormalTexture("Interface\\Minimap\\Rotating-MinimapGuideArrow")
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:AddLine(("%s|1으로;로; 돌아가기"):format(self.text))
		GameTooltip:Show()
	end)
	self.gotoBack:SetScript("OnLeave", function(self)
		self.enter = nil
		self:SetNormalTexture("Interface\\Minimap\\Rotating-MinimapArrow")
		GameTooltip:Hide()
	end)
	self.gotoBack:SetScript("OnClick", function(self)
		tremove(InvenCraftInfoUI.selectQuee, 1)
		InvenCraftInfoUI:GoToSpell(self.spell)
	end)
	self.gotoBack:Hide()
	-- 드랍 버튼 만들기
	self.dropTitle = self.detailScrollChild:CreateFontString("InvenCraftInfoDropInfoTitle", "BACKGROUND", "GameFontNormalSmall")
	self.dropText = {}
	local function dropTextOnEnter(self)
		if self.npcid and (type(self.npcid) == "string" or (type(self.npcid) == "number" and self.npcid > 0)) and GetAddOnInfo("InvenCraftInfoMap") then
			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
			GameTooltip:AddLine("위치 보기")
			GameTooltip:Show()
			SetCursor("INSPECT_CURSOR")
		end
	end
	local function dropTextOnLeave(self)
		GameTooltip:Hide()
		SetCursor(nil)
	end
	local function dropTextOnClick(self)
		if self.npcid and (type(self.npcid) == "string" or (type(self.npcid) == "number" and self.npcid > 0)) and GetAddOnInfo("InvenCraftInfoMap") then
			LoadAddOn("InvenCraftInfoMap")
			InvenCraftInfoMap:ShowMap(self.npcid)
		end
	end
	for i = 1, 10 do
		self.dropText[i] = CreateFrame("Button", nil, self.detailScrollChild)
		self.dropText[i]:EnableMouse(nil)
		self.dropText[i]:SetWidth(290)
		self.dropText[i]:SetHeight(12)
		self.dropText[i].text = self.dropText[i]:CreateFontString("InvenCraftInfoDropInfoText"..i, "OVERLAY", "GameFontHighlightSmall")
		self.dropText[i].text:SetAllPoints(self.dropText[i])
		self.dropText[i].text:SetJustifyH("LEFT")
		self.dropText[i]:SetScript("OnEnter", dropTextOnEnter)
		self.dropText[i]:SetScript("OnLeave", dropTextOnLeave)
		self.dropText[i]:SetScript("OnClick", dropTextOnClick)
		self.dropText[i]:SetPoint("TOPLEFT", i == 1 and self.dropTitle or self.dropText[i - 1], "BOTTOMLEFT")
	end
	-- 우측 전문기술 탭 만들기(애드온)
	local tradeSkillList = { "요리", "연금술", "재봉술", "가죽세공", "대장기술", "기계공학", "마법부여", "보석세공", "주문각인" }
	local function sideTabOnClick(self)
		if not InvenCraftInfo.tradeSkillLinks[self.tooltip] then
			InvenCraftInfo:CreateLinks()
		end
		if InvenCraftInfo.tradeSkillLinks[self.tooltip] then
			SetItemRef(InvenCraftInfo.tradeSkillLinks[self.tooltip], InvenCraftInfo.tradeSkillFullLinks[self.tooltip], "LeftButton")
			InvenCraftInfoUI:SetSkillChecked(self:GetID())
		else
			InvenCraftInfoUI:SetSkillChecked(nil)
		end
	end
	self.sideTab = {}
	for i, skill in ipairs(InvenCraftInfo.tradeSkillNameList) do
		self.sideTab[i] = CreateFrame("CheckButton", nil, self, "SpellBookSkillLineTabTemplate")
		self.sideTab[i]:SetFrameLevel(2)
		self.sideTab[i]:SetScale(0.9)
		self.sideTab[i]:SetID(i)
		self.sideTab[i].tooltip = skill
		self.sideTab[i]:SetScript("OnClick", sideTabOnClick)
		self.sideTab[i]:SetNormalTexture(InvenCraftInfo.myTradeSkills[skill].iconTexture)
		self.sideTab[i]:GetNormalTexture():SetTexCoord(0.07, 0.93, 0.07, 0.93)
		self.sideTab[i]:Show()
		self.sideTab[i]:SetPoint("TOP", self.sideTab[i - 1], "BOTTOM", 0, -17)
	end
	self.sideTab[1]:ClearAllPoints()
	self.sideTab[1]:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, -45)
	self.sideTabBackground = CreateFrame("Frame", nil, self)
	self.sideTabBackground:EnableMouse(true)
	self.sideTabBackground:SetFrameLevel(1)
	self.sideTabBackground:SetPoint("TOPLEFT", self.sideTab[1], "TOPLEFT")
	self.sideTabBackground:SetPoint("BOTTOMRIGHT", self.sideTab[#tradeSkillList], "BOTTOMRIGHT")
	-- 하단 전문기술 탭 만들기(내 전문기술)
	self.numTabs = 5
	self.bottomTab = {}
	local function bottomTabOnClick(self)
		InvenCraftInfo.myTradeSkills[self.skill]:Click()
		PanelTemplates_Tab_OnClick(self, InvenCraftInfoUI)
	end
	for i = 1, self.numTabs do
		self.bottomTab[i] = CreateFrame("Button", "InvenCraftInfoUITab"..i, self, "CharacterFrameTabButtonTemplate")
		self.bottomTab[i]:Hide()
		self.bottomTab[i]:SetID(i)
		self.bottomTab[i]:SetScript("OnShow", nil)
		self.bottomTab[i]:SetScript("OnClick", bottomTabOnClick)
		self.bottomTab[i]:SetPoint("LEFT", self.bottomTab[i - 1], "RIGHT", -15, 0)
		PanelTemplates_DeselectTab(self.bottomTab[i])
	end
	self.bottomTab[1]:ClearAllPoints()
	self.bottomTab[1]:SetPoint("BOTTOMLEFT", 11, -28)
	self:ScanTradeSkillTab()
	self:InitSaveStatus()
end

function InvenCraftInfoUI:SetSkillChecked(index)
	for i, tab in ipairs(self.sideTab) do
		if tab:GetID() == index or tab.tooltip == index then
			tab:SetChecked(true)
			tab:EnableMouse(nil)
		else
			tab:SetChecked(nil)
			tab:EnableMouse(true)
		end
	end
end

function InvenCraftInfoUI:ScanTradeSkillTab()
	tabIndex = 1
	for i, skill in ipairs(InvenCraftInfo.tradeSkillList) do
		if tabIndex > self.numTabs then
			break
		elseif GetSpellLink(skill) then
			self.bottomTab[tabIndex]:SetText(skill)
			self.bottomTab[tabIndex].skill = skill
			self.bottomTab[tabIndex]:Show()
			PanelTemplates_TabResize(self.bottomTab[tabIndex], 0)
			tabIndex = tabIndex + 1
		elseif InvenCraftInfoData then
			InvenCraftInfoData:ClearKnownRecipe(skill)
		end
	end
	self.value.tab = tabIndex - 1
	for i = tabIndex, self.numTabs do
		self.bottomTab[i].skill = nil
		self.bottomTab[i]:Hide()
	end
end

function InvenCraftInfoUI:SetTradeSkillTab(skill)
	if not IsTradeSkillLinked() and skill then
		skill = skill == L["채광"] and L["제련술"] or skill
		for _, tab in ipairs(self.bottomTab) do
			if tab.skill == skill then
				PanelTemplates_SelectTab(tab)
			else
				PanelTemplates_DeselectTab(tab)
			end
		end
	else
		for _, tab in ipairs(self.bottomTab) do
			PanelTemplates_DeselectTab(tab)
		end
	end
end


function InvenCraftInfoUI:EnableFilter(enable)
	if self.makeSkillWindowDelay then
		enable = nil
	else
		enable = enable and true or nil
	end
	if self.sortDropdown.isEnable ~= enable then
		self.sortDropdown.isEnable = enable
		TradeSkillFrameMinReqText:EnableMouse(enable)
		TradeSkillFrameMaxReqText:EnableMouse(enable)
		if enable then
			UIDropDownMenu_EnableDropDown(TradeSkillSortDropDown)
			TradeSkillFrameMinReqText:SetText(self.orderDB.min or "")
			TradeSkillFrameMaxReqText:SetText(self.orderDB.max or "")
			self.reqFilter:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
			self.reqFilterDash:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
			TradeSkillFrameClearReqButton:Enable()
		else
			UIDropDownMenu_DisableDropDown(TradeSkillSortDropDown)
			TradeSkillFrameMinReqText:SetText("")
			TradeSkillFrameMinReqText:ClearFocus()
			TradeSkillFrameMaxReqText:SetText("")
			TradeSkillFrameMaxReqText:ClearFocus()
			self.reqFilter:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
			self.reqFilterDash:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
			TradeSkillFrameClearReqButton:Disable()
		end
	end
	if self.makeSkillWindowDelay or enable then
		UIDropDownMenu_SetText(TradeSkillSortDropDown, self.orderDB.order)
	else
		UIDropDownMenu_SetText(TradeSkillSortDropDown, "정렬 안함")
	end
end

function InvenCraftInfoUI:HideOldFrame()
	local skipFrames = {
		[TradeSkillFrameAvailableFilterCheckButton] = true,
		[TradeSkillLinkButton] = true,
		[TradeSkillSubClassDropDown] = true,
		[TradeSkillInvSlotDropDown] = true,
		[TradeSkillFrameEditBox] = true,
		[TradeSkillCreateAllButton] = true,
		[TradeSkillDecrementButton] = true,
		[TradeSkillInputBox] = true,
		[TradeSkillIncrementButton] = true,
		[TradeSkillCreateButton] = true,
		[TradeSkillCancelButton] = true,
		[TradeSkillRankFrame] = true,
		[TradeSkillExpandButtonFrame] = true,
		[TradeSkillCollapseAllButton] = true,
	}
	local function disableElement(frame)
		frame:EnableMouse(nil)
		frame:EnableMouseWheel(nil)
		frame.EnableMouse = dummyFunction
		frame.EnableMouseWheel = dummyFunction
		if frame == TradeSkillFrame then
			frame:SetAlpha(0)
			frame.SetAlpha = dummyFunction
		else
			frame.ClearAllPoints = dummyFunction
			frame.SetPoint = dummyFunction
			frame.SetParent = dummyFunction
		end
	end
	local function isTradeSkillFrameChild(frame)
		while frame do
			if frame:GetParent() == TradeSkillFrame then
				return true
			end
			frame = frame:GetParent()
		end
		return nil
	end
	UIPanelWindows["TradeSkillFrame"] =  nil
	tinsert(UISpecialFrames, "TradeSkillFrame")
	disableElement(TradeSkillFrame)
	TradeSkillFrame:HookScript("OnShow", function(self)
		if not InvenCraftInfoUI.value.secondShow then
			InvenCraftInfoUI.value.secondShow = true
			InvenCraftInfoUI:TRADE_SKILL_SHOW()
		end
	end)
	local f = EnumerateFrames(TradeSkillFrame)
	while f do
		if isTradeSkillFrameChild(f) then
			if skipFrames[f] then
				f:SetParent(self)
			elseif not (f:GetName() or ""):find("^DropDownList") then
				disableElement(f)
			end
		end
		f = EnumerateFrames(f)
	end
end