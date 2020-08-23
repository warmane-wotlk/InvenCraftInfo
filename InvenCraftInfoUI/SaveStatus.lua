local _G = _G
local GetTradeSkillLine = _G.GetTradeSkillLine
local IsTradeSkillLinked = _G.IsTradeSkillLinked

local skill

local function save()
	if not InvenCraftInfoUI.skipUpdate and InvenCraftInfoUI.tradeSkillName == GetTradeSkillLine() then
		if IsTradeSkillLinked() then
			if InvenCraftInfoUI.isAddOnLink then
				skill = InvenCraftInfoUI.tradeSkillName.."!"
			else
				return
			end
		else
			skill = InvenCraftInfoUI.tradeSkillName
		end
		InvenCraftInfoUI.prevStatus[skill] = InvenCraftInfoUI.prevStatus[skill] or {}
		InvenCraftInfoUI.prevStatus[skill].search = TradeSkillFrameEditBox:GetText() or SEARCH
		if InvenCraftInfoUI.prevStatus[skill].search:trim() == "" then
			InvenCraftInfoUI.prevStatus[skill].search = SEARCH
		end
		InvenCraftInfoUI.prevStatus[skill].showMakeable = TradeSkillFrameAvailableFilterCheckButton:GetChecked()
		InvenCraftInfoUI.prevStatus[skill].listScroll = InvenCraftInfoUIListScrollFrameScrollBar:IsShown() and InvenCraftInfoUIListScrollFrameScrollBar:GetValue() or 0
		InvenCraftInfoUI.prevStatus[skill].invSlotID = UIDropDownMenu_GetSelectedID(TradeSkillInvSlotDropDown) or 1
		InvenCraftInfoUI.prevStatus[skill].subClassID = UIDropDownMenu_GetSelectedID(TradeSkillSubClassDropDown) or 1
		InvenCraftInfoUI.prevStatus[skill].selectionIndex = GetTradeSkillSelectionIndex()
		if InvenCraftInfoUI.isSort and InvenCraftInfoUI.headerExpand[InvenCraftInfoUI.tradeSkillName] then
			InvenCraftInfoUI.prevStatus[skill].header = InvenCraftInfoUI.prevStatus[skill].header or {}
			for p in pairs(InvenCraftInfoUI.prevStatus[skill].header) do
				InvenCraftInfoUI.prevStatus[skill].header[p] = nil
			end
			for p, v in pairs(InvenCraftInfoUI.headerExpand[InvenCraftInfoUI.tradeSkillName]) do
				InvenCraftInfoUI.prevStatus[skill].header[p] = v
			end
		end
	end
end

local handler = CreateFrame("Frame")
handler:Hide()
handler:SetScript("OnUpdate", function(self, timer)
	if InvenCraftInfoUI:IsShown() then
		self.timer = self.timer + timer
		if self.timer > 0.15 then
			self:Hide()
			save()
		end
	else
		handler:Hide()
	end
end)

local function update()
	handler.timer = 0
	handler:Show()
end

function InvenCraftInfoUI:InitSaveStatus()
	for _, button in pairs(self.skillButtons) do
		button:HookScript("PostClick", update)
	end
	TradeSkillFrameEditBox:HookScript("OnEditFocusGained", function(self) self.hasFocus = true end)
	TradeSkillFrameEditBox:HookScript("OnEditFocusLost", function(self) self.hasFocus = nil end)
	TradeSkillFrameEditBox:HookScript("OnTextChanged", function(self) if self.hasFocus then update() end end)
	TradeSkillFrameAvailableFilterCheckButton:HookScript("PostClick", update)
	TradeSkillCollapseAllButton:HookScript("PostClick", update)
	InvenCraftInfoUIListScrollFrame:HookScript("OnMouseWheel", update)
	InvenCraftInfoUIListScrollFrameScrollBar:HookScript("OnMouseUp", update)
	InvenCraftInfoUIListScrollFrameScrollBarScrollUpButton:HookScript("OnMouseUp", update)
	InvenCraftInfoUIListScrollFrameScrollBarScrollDownButton:HookScript("OnMouseUp", update)
	DropDownList1:HookScript("OnHide", function()
		if UIDROPDOWNMENU_OPEN_MENU == TradeSkillSubClassDropDown or UIDROPDOWNMENU_OPEN_MENU == TradeSkillInvSlotDropDown then
			update()
		end
	end)
end

function InvenCraftInfoUI:RestorePrevStatus(status)
	handler:Hide()
	if type(status) == "table" and status.search then
		self.skipUpdate = true
		TradeSkillFrameAvailableFilterCheckButton:SetChecked(status.showMakeable)
		TradeSkillOnlyShowMakeable(status.showMakeable)
		TradeSkillFrameEditBox:ClearFocus()
		TradeSkillFrameEditBox:SetText(status.search)
		if self.isSort then
			self.subClassIndex = (status.subClassID == 1 and 0 or status.subClassID)
			if self.subClassIndex then
				UIDropDownMenu_SetSelectedID(TradeSkillSubClassDropDown, status.subClassID)
				UIDropDownMenu_SetText(TradeSkillSubClassDropDown, self:GetSubClassText(self.tradeSkillName, status.subClassID))
			end
			if status.header then
				for p, v in pairs(status.header) do
					self.headerExpand[self.tradeSkillName][p] = v
				end
			end
		elseif status.subClassID then
			UIDropDownMenu_SetSelectedID(TradeSkillSubClassDropDown, status.subClassID)
			SetTradeSkillSubClassFilter(status.subClassID - 1, 1, 1)
		end
		if status.invSlotID then
			UIDropDownMenu_SetSelectedID(TradeSkillInvSlotDropDown, status.invSlotID)
			SetTradeSkillInvSlotFilter(status.invSlotID - 1, 1, 1)
			TradeSkillInvSlotDropDown.selected = TradeSkillFilterFrame_InvSlotName(GetTradeSkillInvSlots())
		end
		status.listScroll = status.listScroll or 0
		FauxScrollFrame_SetOffset(InvenCraftInfoUIListScrollFrame, status.listScroll)
		InvenCraftInfoUIListScrollFrameScrollBar:SetValue(status.listScroll)
		status.detailScroll = status.detailScroll or 0
		FauxScrollFrame_SetOffset(InvenCraftInfoUIDetailScrollFrame, status.detailScroll)
		self.skipUpdate = nil
		self.forceUpdateList = true
		self:ListUpdate()
		TradeSkillFrame_SetSelection(status.selectionIndex or 1)
	end
end