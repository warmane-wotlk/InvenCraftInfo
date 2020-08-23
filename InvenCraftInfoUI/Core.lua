if not InvenCraftInfo then LoadAddOn("InvenCraftInfo") end

local debugMode = true
InvenCraftInfo:LoadData()

InvenCraftInfoUI = CreateFrame("Frame", "InvenCraftInfoUI", UIParent)
InvenCraftInfoUI:Hide()
InvenCraftInfoUI:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
InvenCraftInfoUI:RegisterEvent("ADDON_LOADED")
InvenCraftInfoUI.value = { tab = 0, secondShow = false }
InvenCraftInfoUI.prevStatus = {}

local _G = _G
local format = _G.format
local select = _G.select
local strsplit = _G.string.split
local unpack = _G.unpack
local min = _G.math.min
local GetTime = _G.GetTime
local GetItemIcon = _G.GetItemIcon
local GetSpellInfo = _G.GetSpellInfo
local GetSpellLink = _G.GetSpellLink
local IsTradeSkillLinked = _G.IsTradeSkillLinked
local GetTradeSkillListLink = _G.GetTradeSkillListLink
local GetNumTradeSkills = _G.GetNumTradeSkills
local GetTradeSkillLine = _G.GetTradeSkillLine
local InCombatLockdown = _G.InCombatLockdown
local GetTradeSkillReagentInfo = _G.GetTradeSkillReagentInfo
local GetTradeSkillReagentItemLink = _G.GetTradeSkillReagentItemLink
local GetItemCount = _G.GetItemCount
local PlaySound = _G.PlaySound

local v1, v2, v3, v4, v5, drop, link, isLink, knownPlayer, splayer, kp, sp, font, tname, tnum, treq, currentSkill, idx, skillColor, gnts, gntsn
local currentSkillNum, currentSkillTotalNum, droptable, npctable, dropnum, dropnpcid, dropins, reagentLink, numSkills, isHeader, isExpand
local L = InvenCraftInfo.tradeSkillLocale

local skills = { 2259, 3908, 2108, 2018, 4036, 7411, 25229, 45363, 2656, 45542, 2550, 53428 }
local skillTexture = {}
local tradeSkillID = {
	["요리"] = 2550,	[L["요리"]] = 2550,
	["연금술"] = 2259,	[L["연금술"]] = 2259,
	["재봉술"] = 3908,	[L["재봉술"]] = 3908,
	["가죽세공"] = 2108,	[L["가죽세공"]] = 2108,
	["대장기술"] = 2018,	[L["대장기술"]] = 2018,
	["기계공학"] = 4036,	[L["기계공학"]] = 4036,
	["마법부여"] = 7411,	[L["마법부여"]] = 7411,
	["보석세공"] = 25229,	[L["보석세공"]] = 25229,
	["주문각인"] = 45363,	[L["주문각인"]] = 45363,
}
local tradeSkillName = {}

function InvenCraftInfoUI:ADDON_LOADED()
	self:UnregisterEvent("ADDON_LOADED")
	self.enable = true
	InvenCraftInfo:CreateLinks()
	InvenCraftInfoUICharDB = InvenCraftInfoUICharDB or { mySkill = {}, addOnLink = {}, otherLink = {}, favorite = {} }
	InvenCraftInfoUICharDB.favorite = InvenCraftInfoUICharDB.favorite or {}
	if InvenCraftInfoUICharDB.prevIndexName then
		InvenCraftInfoUICharDB.prevIndexName = nil
	end
	self.defaultSkillOrder = { mySkill = "숙련 색상 우선", addOnLink = "필요 숙련 우선", otherLink = "숙련 색상 우선" }
	self.chardb = InvenCraftInfoUICharDB
	self:CreateFrame()
	hooksecurefunc("TradeSkillFrame_SetSelection", function(id) InvenCraftInfoUI:SetSelection(id) end)
	if InvenCraftInfo.initFirstSetTradeSkillLink then
		self:SetTradeSkillLink(InvenCraftInfo.initFirstSetTradeSkillLink[1], InvenCraftInfo.initFirstSetTradeSkillLink[2])
		InvenCraftInfo.initFirstSetTradeSkillLink = nil
	end
	self.PLAYER_ENTERING_WORLD = self.ScanTradeSkillTab
	self:RegisterEvent("TRADE_SKILL_SHOW")
	self:RegisterEvent("TRADE_SKILL_CLOSE")
	self:RegisterEvent("TRADE_SKILL_UPDATE")
	self:RegisterEvent("SKILL_LINES_CHANGED")
	self:RegisterEvent("CHAT_MSG_SYSTEM")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	if TradeSkillFrame:IsShown() then
		self:Show()
	end
end

function InvenCraftInfoUI:TRADE_SKILL_SHOW()
	self:Show()
	self:ScanTradeSkillTab()
	self.skipUpdate = nil
	self.isSort = nil
	TradeSkillCreateButton:Disable()
	TradeSkillCreateAllButton:Disable()
	currentSkill = GetTradeSkillLine()
	if IsTradeSkillLinked() then
		self:SetTradeSkillTab(nil)
		if self.isAddOnLink then
			if not self.chardb.addOnLink[currentSkill] then
				self.chardb.addOnLink[currentSkill] = { order = self.defaultSkillOrder.addOnLink }
			end
			self.orderName = "addOnLink"
			self.orderDB = self.chardb.addOnLink[currentSkill]
			InvenCraftInfoCharDB.openSkill, InvenCraftInfoCharDB.isMySkill = currentSkill, nil
			self.saveStatusName = currentSkill.."!"
		else
			if not self.chardb.otherLink[currentSkill] then
				self.chardb.otherLink[currentSkill] = { order = self.defaultSkillOrder.otherLink }
			end
			self.orderName = "otherLink"
			self.orderDB = self.chardb.otherLink[currentSkill]
			self.saveStatusName = nil
		end
	else
		self:SetSkillChecked(nil)
		self:SetTradeSkillTab(currentSkill)
		self.value.link = nil
		self.value.skill = nil
		self.isAddOnLink = nil
		if not self.chardb.mySkill[currentSkill] then
			self.chardb.mySkill[currentSkill] = { order = self.defaultSkillOrder.mySkill }
		end
		self.orderName = "mySkill"
		self.orderDB = self.chardb.mySkill[currentSkill]
		if currentSkill and GetSpellTexture(currentSkill) then
			InvenCraftInfoCharDB.openSkill, InvenCraftInfoCharDB.isMySkill = currentSkill, true
		end
		self.saveStatusName = currentSkill
	end
	self.tradeSkillTitle:SetText(currentSkill)
	SetPortraitToTexture(self.skillIcon, InvenCraftInfo.myTradeSkills[currentSkill == L["채광"] and L["제련술"] or currentSkill].iconTexture or "")
	self:SetScrollTop()
	TradeSkillCollapseAllButton.collapsed = nil
	ExpandTradeSkillSubClass(0)
	TradeSkillSubClassDropDown_OnLoad(TradeSkillSubClassDropDown)
	TradeSkillInvSlotDropDown_OnLoad(TradeSkillInvSlotDropDown)
	TradeSkillFrameAvailableFilterCheckButton:SetChecked(nil)
	TradeSkillOnlyShowMakeable(nil)
	TradeSkillFrameEditBox:Show()
	TradeSkillFrameEditBox:SetText(SEARCH)
	TradeSkillFrameEditBox:ClearFocus()
	TradeSkillFrameMinReqText:SetText(self.orderDB.min or "")
	TradeSkillFrameMinReqText:ClearFocus()
	TradeSkillFrameMaxReqText:SetText(self.orderDB.max or "")
	TradeSkillFrameMaxReqText:ClearFocus()
	UIDropDownMenu_SetText(TradeSkillSortDropDown, self.orderDB.order)
	SetTradeSkillItemNameFilter("")
	if self.orderName == "mySkill" then
		InvenCraftInfoData:SaveKnownRecipe()
	end
	self.skipUpdate = nil
	self.changeSpell = true
	self.p_tradeSkillName = nil
	self.tradeSkillName = currentSkill
	self.currentSpellCount = nil
	self:ResetExpand(currentSkill)
	self:ListUpdate()
	CloseDropDownMenus()
	if self.isSort then
		TradeSkillSubClassDropDown_Initialize()
	end
	PlaySound("igCharacterInfoTab")
	if InvenCraftInfoUI.CheckSkillCache then
		InvenCraftInfoUI:CheckSkillCache()
	end
	if self.saveStatusName then
		if self.prevStatus[self.saveStatusName] then
			self:RestorePrevStatus(self.prevStatus[self.saveStatusName])
		else
			self:RestorePrevStatus(nil)
			self.prevStatus[self.saveStatusName] = { search = SEARCH, showMakeable = nil, listScroll = 0, invSlotID = 1, subClassID = 1, selectionIndex = GetTradeSkillSelectionIndex(), headerExpand = {} }
		end
	end
end

function InvenCraftInfoUI:TRADE_SKILL_CLOSE()
	self:Hide()
end

function InvenCraftInfoUI:TRADE_SKILL_UPDATE()
	self:ListUpdate()
end

function InvenCraftInfoUI:SKILL_LINES_CHANGED()
	if self:IsShown() then
		self.forceUpdateList = true
		self:ListUpdate()
	end
end

function InvenCraftInfoUI:GetSkillChecked()
	for i = 1, #InvenCraftInfoUI.tab do
		if InvenCraftInfoUI.tab[i]:GetChecked() then
			return self.tab[i].skill, InvenCraftInfo.tradeSkillLinks[self.tab[i].skill]
		end
	end
	return nil, nil
end

function InvenCraftInfoUI:SetScrollTop()
	FauxScrollFrame_SetOffset(InvenCraftInfoUIListScrollFrame, 0)
	InvenCraftInfoUIListScrollFrameScrollBar:SetMinMaxValues(0, 0)
	InvenCraftInfoUIListScrollFrameScrollBar:SetValue(0)
end

function InvenCraftInfoUI:TradeSkillFrameTitleTextPos()
	TradeSkillFrameTitleText:ClearAllPoints()
	if TradeSkillLinkButton:IsShown() then
		TradeSkillFrameTitleText:SetPoint("TOP", TradeSkillFrame, "TOPLEFT", 136, -50)
	else
		TradeSkillFrameTitleText:SetPoint("TOP", TradeSkillFrame, "TOPLEFT", 136, -56)
	end
end

function InvenCraftInfoUI:ClearAllDropText()
	self.dropTitle:SetText(" ")
	for i = 1, 10 do
		self.dropText[i].text:SetText(" ")
		self.dropText[i]:EnableMouse(nil)
	end
end

local function setIconColorBorder(icon, rarity)
	if InvenCraftInfoDB.hideRarityBorder then
		icon.rarityBorder:Hide()
	else
		if type(rarity) == "string" and rarity:find("item:") then
			rarity = select(3, GetItemInfo(rarity))
		end
		if type(rarity) == "number" then
			if rarity > 1 or icon == InvenCraftInfoUI.detailScrollChild.skillIcon then
				icon.rarityBorder:Show()
				icon.rarityBorder:SetVertexColor(GetItemQualityColor(rarity))
			else
				icon.rarityBorder:Hide()
			end
		elseif icon == InvenCraftInfoUI.detailScrollChild.skillIcon then
			icon.rarityBorder:Show()
			icon.rarityBorder:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		else
			icon.rarityBorder:Hide()
		end
	end
end

local selectName, selectType, selectNumAvailable, selectIsExpanded, selectAltVerb, selectCreatable, selectCooldown, selectIcon
local selectMinMade, selectMaxMade, selectNumReagents, reagentName, reagentTexture, reagentCount, playerReagentCount, selectReqTool, bankReagentCount

function InvenCraftInfoUI:SetSelection(id)
	self:StopDescUpdater()
	id = GetTradeSkillSelectionIndex()
	selectName, selectType, selectNumAvailable, selectIsExpanded, selectAltVerb = GetTradeSkillInfo(id)
	numSkills = GetNumTradeSkills()
	if not selectName or selectType == "header" or id == 0 or id > numSkills then
		self.detailScrollChild.skillName:SetText("")
		self.detailScrollChild.cooldown:SetText("")
		self.detailScrollChild.reqTool:SetText("")
		self.detailScrollChild.reqRank:SetText("")
		self.detailScrollChild.cooldown:SetText("")
		self.detailScrollChild.desc:SetText("")
		self.detailScrollChild.skillIcon:Hide()
		self.detailScrollChild.reagentLabel:Hide()
		for i = 1, 8 do
			self.reagentButtons[i]:Hide()
		end
		self.detailScrollChild.favorite:Hide()
		self:ClearAllDropText()
		self.listHighlightBar:Hide()
		self.listHighlightBar2:Hide()
		self:UpdateRankFrame()
		self.Hide(TradeSkillCreateButton)
		self.Hide(TradeSkillCreateAllButton)
		self.Hide(TradeSkillDecrementButton)
		self.Hide(TradeSkillInputBox)
		self.Hide(TradeSkillIncrementButton)
		self.bottomRightBorder:SetTexture("Interface\\Addons\\InvenCraftInfoUI\\Texture\\UI-ClassTrainer-Link-BottomRight")
		self.bottomBorder:SetTexture("Interface\\Addons\\InvenCraftInfoUI\\Texture\\UI-ClassTrainer-Link-Bottom")
		return self:ListUpdate()
	end
	currentSkill = GetTradeSkillLine()
	if TradeSkillTypeColor[selectType] then
		self.listHighlightBar.textrue:SetVertexColor(TradeSkillTypeColor[selectType].r, TradeSkillTypeColor[selectType].g, TradeSkillTypeColor[selectType].b)
		self.listHighlightBar2.textrue:SetVertexColor(TradeSkillTypeColor[selectType].r, TradeSkillTypeColor[selectType].g, TradeSkillTypeColor[selectType].b)
	end
	self.detailScrollChild.skillName:SetText(selectName)
	selectReqTool = BuildColoredListString(GetTradeSkillTools(id))
	if selectReqTool and selectReqTool ~= "" then
		self.detailScrollChild.reqTool:SetFormattedText("%s %s", REQUIRES_LABEL, selectReqTool)
	else
		self.detailScrollChild.reqTool:SetText("")
	end
	link = InvenCraftInfo:GetLinkID(GetTradeSkillRecipeLink(id), "enchant")
	if currentSkill == "룬벼리기" then
		self.detailScrollChild.reqRank:SetText("")
	else
		treq = (InvenCraftInfo.GetSpellReq and InvenCraftInfo:GetSpellReq(link)) or 0
		treq = treq > 0 and (treq.."") or "|cffff2222"..COMBATLOG_FILTER_STRING_UNKNOWN_UNITS.."|r"

		skillColor = InvenCraftInfo:GetSpellColor(link)
		if skillColor == "" then
			self.detailScrollChild.reqRank:SetFormattedText("필요 숙련: %s", treq)
		else
			self.detailScrollChild.reqRank:SetFormattedText("필요 숙련: %s (%s)", treq, skillColor)
		end
	end
	if link and self:HasFavorite(currentSkill) then
		if InvenCraftInfoUICharDB.favorite[link] then
			self.detailScrollChild.favorite:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Disabled")
		else
			self.detailScrollChild.favorite:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
		end
		self.detailScrollChild.favorite.link = link
		self.detailScrollChild.favorite:Show()
	else
		self.detailScrollChild.favorite:Hide()
	end
	selectCooldown = GetTradeSkillCooldown(id)
	if selectCooldown then
		self.detailScrollChild.cooldown:SetFormattedText("%s %s", COOLDOWN_REMAINING, SecondsToTime(selectCooldown))
	else
		self.detailScrollChild.cooldown:SetText("")
	end
	selectIcon = GetTradeSkillIcon(id)
	if selectIcon and selectIcon ~= "" then
		self.detailScrollChild.skillIcon:SetNormalTexture(selectIcon)
		self.detailScrollChild.skillIcon:GetNormalTexture():SetTexCoord(0.07, 0.93, 0.07, 0.93)
		self.detailScrollChild.skillIcon:Show()
		setIconColorBorder(self.detailScrollChild.skillIcon, GetTradeSkillItemLink(id) or 2)
	else
		self.detailScrollChild.skillIcon:Hide()
	end
	selectMinMade, selectMaxMade = GetTradeSkillNumMade(id)
	if selectMaxMade > 1 then
		if selectMinMade == selectMaxMade then
			self.detailScrollChild.skillIcon.count:SetText(selectMinMade)
		else
			self.detailScrollChild.skillIcon.count:SetFormattedText("%d-%d", selectMinMade, selectMaxMade)
		end
		if self.detailScrollChild.skillIcon.count:GetWidth() > 44 then
			self.detailScrollChild.skillIcon.count:SetFormattedText("~%d", (selectMinMade + selectMaxMade) / 2)
		end
	else
		self.detailScrollChild.skillIcon.count:SetText("")
	end
	selectNumReagents = GetTradeSkillNumReagents(id)
	if selectNumReagents > 0 then
		self.detailScrollChild.reagentLabel:Show()
	else
		self.detailScrollChild.reagentLabel:Hide()
	end
	for i = 1, selectNumReagents do
		self.reagentButtons[i]:Show()
		reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(id, i)
		reagentItemLink = GetTradeSkillReagentItemLink(id, i)
		if reagentItemLink then
			reagentName = regentName or GetItemInfo(reagentItemLink) or "미확인 아이템"
			reagentTexture = reagentTexture or GetItemIcon(reagentItemLink) or "Interface\\Icons\\INV_Misc_QuestionMark"
			if reagentName == "미확인 아이템" then
				self.reagentButtons[i].goto:Hide()
				setIconColorBorder(self.reagentButtons[i], 0)
			else
				self.reagentButtons[i].goto.index = self:FindSkillIndex(InvenCraftInfo:IsMakeableItem(currentSkill, reagentItemLink))
				if self.reagentButtons[i].goto.index then
					self.reagentButtons[i].goto.tooltipText = ("%s|1으로;로; 바로가기"):format(reagentName)
					self.reagentButtons[i].goto:Show()
				else
					self.reagentButtons[i].goto.tooltipText = nil
					self.reagentButtons[i].goto:Hide()
				end
				setIconColorBorder(self.reagentButtons[i], reagentItemLink)
				if InvenCraftInfoDB.bankCount then
					bankReagentCount = (GetItemCount(reagentItemLink, true) or 0) - playerReagentCount
					if bankReagentCount > 0 then
						reagentName = ("%s\n(은행: %d)"):format(reagentName, bankReagentCount)
					end
				end
			end
		else
			reagentName = regentName or "미확인 아이템"
			reagentTexture = reagentTexture or "Interface\\Icons\\INV_Misc_QuestionMark"
			self.reagentButtons[i].goto:Hide()
			setIconColorBorder(self.reagentButtons[i], 0)
		end
		self.reagentButtons[i].text:SetText(reagentName)
		SetItemButtonTexture(self.reagentButtons[i], reagentTexture)
		if reagentCount and playerReagentCount then
			self.reagentButtons[i].count:SetFormattedText("%d/%d", playerReagentCount, reagentCount)
			self.reagentButtons[i].count:ClearAllPoints()
			if playerReagentCount < 100 then
				self.reagentButtons[i].count:SetPoint("BOTTOMRIGHT", self.reagentButtons[i].icon, -1, 3)
			elseif playerReagentCount > 999 then
				self.reagentButtons[i].count:SetPoint("BOTTOMRIGHT", self.reagentButtons[i].icon, 4, 3)
			else
				self.reagentButtons[i].count:SetPoint("BOTTOMRIGHT", self.reagentButtons[i].icon, 0, 3)
			end
			if playerReagentCount < reagentCount then
				SetItemButtonTextureVertexColor(self.reagentButtons[i], 0.5, 0.5, 0.5)
				self.reagentButtons[i].text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
				selectCreatable = nil
			else
				SetItemButtonTextureVertexColor(self.reagentButtons[i], 1.0, 1.0, 1.0)
				self.reagentButtons[i].text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
			end
		else
			self.reagentButtons[i].count:SetText("")
			SetItemButtonTextureVertexColor(self.reagentButtons[i], 0.5, 0.5, 0.5)
			self.reagentButtons[i].text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
		end
	end
	for i = selectNumReagents + 1, MAX_TRADE_SKILL_REAGENTS do
		self.reagentButtons[i]:Hide()
	end
	if self.makeSkillWindowDelay then
		TradeSkillCreateButton:Disable()
		TradeSkillCreateAllButton:Disable()
		TradeSkillDecrementButton:Disable()
		TradeSkillIncrementButton:Disable()
		TradeSkillInputBox:ClearFocus()
		TradeSkillInputBox:EnableMouse(nil)
	end
	if IsTradeSkillLinked() then
		self.Hide(TradeSkillCreateButton)
		self.Hide(TradeSkillCreateAllButton)
		self.Hide(TradeSkillDecrementButton)
		self.Hide(TradeSkillInputBox)
		self.Hide(TradeSkillIncrementButton)
		TradeSkillLinkButton:Hide()
		self.bottomRightBorder:SetTexture("Interface\\Addons\\InvenCraftInfoUI\\Texture\\UI-ClassTrainer-Link-BottomRight")
		self.bottomBorder:SetTexture("Interface\\Addons\\InvenCraftInfoUI\\Texture\\UI-ClassTrainer-Link-Bottom")
	else
		if selectAltVerb then
			TradeSkillCreateButton:SetText(selectAltVerb)
			self.Hide(TradeSkillCreateAllButton)
			self.Hide(TradeSkillDecrementButton)
			self.Hide(TradeSkillInputBox)
			self.Hide(TradeSkillIncrementButton)
			self.bottomBorder:SetTexture("Interface\\Addons\\InvenCraftInfoUI\\Texture\\UI-ClassTrainer-TwoButton-Bottom")
		else
			TradeSkillCreateButton:SetText(CREATE)
			self.Show(TradeSkillCreateAllButton)
			self.Show(TradeSkillDecrementButton)
			self.Show(TradeSkillInputBox)
			self.Show(TradeSkillIncrementButton)
			self.bottomBorder:SetTexture("Interface\\Addons\\InvenCraftInfoUI\\Texture\\UI-ClassTrainer-Bottom")
		end
		self.bottomRightBorder:SetTexture("Interface\\Addons\\InvenCraftInfoUI\\Texture\\UI-ClassTrainer-BottomRight")
		if GetTradeSkillListLink() then
			TradeSkillLinkButton:Show()
		else
			TradeSkillLinkButton:Hide()
		end
		self.Show(TradeSkillCreateButton)
	end
	self.bottomLeftBorder:SetTexture("Interface\\Addons\\InvenCraftInfoUI\\Texture\\UI-ClassTrainer-BottomLeft")
	if self.selectQuee[1] == link then
		if self.selectQuee[2] then
			self.gotoBack.text = GetSpellInfo(self.selectQuee[2])
			self.gotoBack.spell = self.selectQuee[2]
			self.gotoBack:Show()
			if self.gotoBack.enter then
				self.gotoBack:GetScript("OnEnter")(self.gotoBack)
			end
		else
			self.gotoBack:Hide()
		end
	else
		self:UpdateQuee(id, true)
		self.gotoBack:Hide()
	end
	drop = nil
	if InvenCraftInfo.GetDropText then
		drop = InvenCraftInfo:GetDropText(link)
		if drop then
			self.dropTitle:ClearAllPoints()
			self.dropTitle:SetText("도안 획득처:")
			self.dropTitle.textvalue = drop
			droptable = { strsplit("\n", drop) }
			dropnpcid, dropnum = InvenCraftInfo:GetDropNPCID(link)
			if dropnpcid and dropnum > 0 then
				npctable = { strsplit(",", dropnpcid) }
				for i = 1, 10 do
					if droptable[i] then
						self.dropText[i].text:SetText(droptable[i])
						self.dropText[i].npcid = tonumber(npctable[i])
						if self.dropText[i].npcid and self.dropText[i].npcid > 0 then
							self.dropText[i]:EnableMouse(true)
						elseif droptable[i]:find("(.+) 모든") then
							dropins = droptable[i]:match("(.+) 모든 몬스터") or droptable[i]:match("(.+) 모든 보스 몬스터")
							if dropins then
								self.dropText[i].npcid = dropins
								self.dropText[i]:EnableMouse(true)
							else
								self.dropText[i]:EnableMouse(false)
							end
						else
							self.dropText[i]:EnableMouse(false)
						end
					else
						self.dropText[i].text:SetText(" ")
						self.dropText[i]:EnableMouse(false)
					end
				end
			else
				for i = 1, 10 do
					if droptable[i] then
						self.dropText[i].text:SetText(droptable[i])
						if droptable[i]:find("(.+) 모든") then
							dropins = droptable[i]:match("(.+) 모든 몬스터") or droptable[i]:match("(.+) 모든 보스 몬스터")
							if dropins then
								self.dropText[i].npcid = dropins
								self.dropText[i]:EnableMouse(true)
							else
								self.dropText[i]:EnableMouse(false)
							end
						else
							self.dropText[i]:EnableMouse(false)
						end
					else
						self.dropText[i].text:SetText(" ")
						self.dropText[i]:EnableMouse(false)
					end
				end
			end
			if self.detailScrollChild.desc:GetText() == "" then
				self.dropTitle:SetPoint("TOPLEFT", 5, -60)
			else
				self.dropTitle:SetPoint("TOPLEFT", self.detailScrollChild.desc, "BOTTOMLEFT", 0, -10)
			end
			self.detailScrollChild.reagentLabel:ClearAllPoints()
			self.detailScrollChild.reagentLabel:SetPoint("TOPLEFT", self.dropText[min(10, #droptable)], "BOTTOMLEFT", 0, -10)
		else
			self:ClearAllDropText()
		end
	end
	if not drop then
		self.detailScrollChild.reagentLabel:ClearAllPoints()
		if self.detailScrollChild.desc:GetText() == "" then
			self.detailScrollChild.reagentLabel:SetPoint("TOPLEFT", 5, -60)
		else
			self.detailScrollChild.reagentLabel:SetPoint("TOPLEFT", self.detailScrollChild.desc, "BOTTOMLEFT", 0, -10)
		end
	end
	self:GetNewDescription(id)
	self:UpdateRankFrame()
	self:ListUpdate()
end

function InvenCraftInfoUI:UpdateRankFrame(skillName, skillLineRank, skillLineMaxRank)
	if type(skillName) == "string" and skillName ~= "UNKNOWN" and type(skillLineRank) == "number" and type(skillLineMaxRank) == "number" then
		if self.isAddOnLink then
			skillLineRank, skillLineMaxRank = InvenCraftInfo.maxSkillLevel, InvenCraftInfo.maxSkillLevel
		end
		self.tradeSkillTitle:SetText(skillName)
		self.tradeSkillNumBar.SetMinMaxValues(TradeSkillRankFrame, 0, skillLineMaxRank)
		self.tradeSkillNumBar.SetValue(TradeSkillRankFrame, skillLineRank)
		self.tradeSkillNumBar.text.SetFormattedText(TradeSkillRankFrameSkillRank, "%d/%d", skillLineRank, skillLineMaxRank)
	end
end

function InvenCraftInfoUI:SetTradeSkillLink(skill, link)
	if skill and tradeSkillID[skill] and link == InvenCraftInfo.tradeSkillLinks[skill] then
		InvenCraftInfoCharDB.openSkill, InvenCraftInfoCharDB.mySkill = skill, nil
		self:SetSkillChecked(skill)
		InvenCraftInfoDB.selecter = skill
		self.isAddOnLink = true
		self.value.skill = skill
		self.value.link = link
	else
		self:SetSkillChecked(nil)
		self.value.link = nil
		self.value.skill = nil
		self.isAddOnLink = nil
	end
end

function InvenCraftInfoUI:GetNumTradeSkills()
	gnts, gntsn = 0, GetNumTradeSkills()
	for i = 1, gntsn do
		if select(2, GetTradeSkillInfo(i)) ~= "header" then
			gnts = gnts + 1
		end
	end
	return gnts
end

local updateDelay = CreateFrame("Frame")
updateDelay:Hide()
updateDelay:SetScript("OnUpdate", function(self, timer)
	self.timer = (self.timer or 0) + timer
	if self.timer >= 1 then
		self.timer = 0
		InvenCraftInfoUI:ScanTradeSkillTab()
		InvenCraftInfoUI:SetTradeSkillTab(GetTradeSkillLine())
		self:Hide()
	end
end)

local learn1 = ERR_LEARN_ABILITY_S:gsub("%%s", "(.+)")
local learn2 = ERR_LEARN_ABILITY_S:gsub("%%s", "(.+) %((.+)%)")
local unlearn1 = ERR_SPELL_UNLEARNED_S:gsub("%%s", "(.+)")
local unlearn2 = ERR_SPELL_UNLEARNED_S:gsub("%%s", "(.+) %((.+)%)")

function InvenCraftInfoUI:CHAT_MSG_SYSTEM(msg)
	local skill = msg:match(learn1) or msg:match(learn2)
	if not skill then
		skill = msg:match(unlearn1) or msg:match(unlearn2)
		if skill and InvenCraftInfoData then
			InvenCraftInfoData:CHAT_MSG_SYSTEM(skill)
		end
	end
	if skill and InvenCraftInfo.myTradeSkills[skill == L["채광"] and L["제련술"] or skill] then
		updateDelay.timer = 0
		updateDelay:Show()
	end
end

if not debugMode then return end

function InvenCraftInfoUI:ConfimAllReagents()
	if TradeSkillFrame and TradeSkillFrame:IsShown() then
		local skillName = GetTradeSkillLine()
		if skillName and skillName ~= "" and skillName ~= "UNKNOWN" then
			if not self.confimUpdater then
				self.confimUpdater = CreateFrame("Frame")
				self.confimUpdater.Check = function(self)
					if select(2, GetTradeSkillInfo(self.index)) == "header" then
						return true
					else
						local rn = GetTradeSkillNumReagents(self.index)
						if rn and rn > 0 then
							local r
							for i = 1, rn do
								r = GetTradeSkillReagentItemLink(self.index, i)
								if not(r and GetItemInfo(r)) then
									return false
								end
							end
						end
					end
					return true
				end
				self.confimUpdater:SetScript("OnUpdate", function(self, timer)
					self.timer = self.timer + timer
					if self.timer > 0.05 then
						self.timer = 0
						if self.skill ~= GetTradeSkillLine() then
							BluePrint(self.skill.." 재료 캐쉬 생성 중지")
							self:Hide()
						elseif self.index > self.num then
							BluePrint(self.skill.." 재료 캐쉬 생성 완료")
							self:Hide()
						else
							if self:Check() == false then
								TradeSkillFrame_SetSelection(self.index)
							else
								if self.index <= self.num and select(2, GetTradeSkillInfo(self.index)) ~= "header" then
									TradeSkillFrame_SetSelection(self.index)
								end
								self.index = self.index + 1
							end
							for i = self.index, self.num do
								if self:Check() == false then
									self.index = i
									return
								end
							end
						end
					end
				end)
			end
			self.confimUpdater:Hide()
			self.confimUpdater.num = GetNumTradeSkills()
			self.confimUpdater.index = 1
			self.confimUpdater.timer = 1
			self.confimUpdater.skill = skillName
			BluePrint(skillName.." 재료 캐쉬 생성 시작")
			self.confimUpdater:Show()
		end
	end

end

function InvenCraftInfoUI:SaveReagents()
	BlueOutputDB = BlueOutputDB or {}
	BlueOutputDB.reagent = BlueOutputDB.reagent or {}
	BlueOutputDB.reagent2 = BlueOutputDB.reagent2 or {}
	local sk = { 2259, 3908, 2108, 2018, 4036, 7411, 25229, 45363, 2656, 3273, 2550 }
	local skill, ss
	local def = ""
	local st = {}
	local sd = {}
	for p, v in ipairs(sk) do
		def = def.."0"
		st[GetSpellInfo(v)] = p
		sd[GetSpellInfo(v)] = 2 ^ (p - 1)
	end

	local function marking(id)
		skill = GetTradeSkillLine() or "*"
		if st[skill] then
			ss = BlueOutputDB.reagent2[id] or def
			if ss:sub(st[skill], st[skill]) == "0" then
				ss = ss:sub(1, st[skill] - 1).."1"..ss:sub(st[skill] + 1)
				BlueOutputDB.reagent2[id] = ss
				BlueOutputDB.reagent[id] = (BlueOutputDB.reagent[id] or 0) + sd[skill]
			end
		end
	end

	local n = GetNumTradeSkills()
	local m, link
	local skillName, skillType

	for i = 1, n do
		skillName, skillType = GetTradeSkillInfo(i)
		if skillType ~= "header" then
			m = GetTradeSkillNumReagents(i)
			for j = 1, m do
				link = GetTradeSkillReagentItemLink(i, j)
				if link and link:find("item:(%d+)") then
					link = tonumber(link:match("item:(%d+)"))
					marking(link)
				end
			end
		end
	end
end