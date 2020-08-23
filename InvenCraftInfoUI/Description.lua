local _G = _G
local select = _G.select
local GetItemInfo = _G.GetItemInfo
local GetTradeSkillItemLink = _G.GetTradeSkillItemLink
local GetTradeSkillDescription = _G.GetTradeSkillDescription
local item, itemID, desc, itemType, itemSubType, text
local itemTypes = {
	["소비용품"] = { ["음식과 음료"] = 1, ["물약"] = 1, ["비약"] = 1, ["영약"] = 1, ["붕대"] = 1, ["두루마리"] = 1, ["아이템 강화"] = 1, ["기타"] = 1 },
	["Consumable"] = { ["Food & Drink"] = 1, ["Potion"] = 1, ["Elixir"] = 1, ["Flask"] = 1, ["Bandage"] = 1, ["Scroll"] = 1, ["Item Enhancement"] = 1, ["Other"] = 1 },
	["보석"] = 2, ["Gem"] = 2,
	["문양"] = 3, ["Glyph"] = 3,
}
local USE = GetLocale() == "koKR" and "^사용 효과: " or "^Use: "
local tooltip = CreateFrame("GameTooltip", "InvenCraftInfoDescriptionTooltip", UIParent, "GameTooltipTemplate")
tooltip.left = {}
local descCache = {}
local descUpdater = CreateFrame("Frame", nil, InvenCraftInfoUI)
descUpdater:Hide()
descUpdater:SetScript("OnUpdate", function(self, timer)
	self.timer = (self.timer or 0) + timer
	if self.timer > 0.25 then
		self.count = self.count + 1
		self.timer = 0
		if self.index and self.index <= GetNumTradeSkills() and GetTradeSkillItemLink(self.index) then
			tooltip:SetOwner(self, "ANCHOR_NONE")
			tooltip:ClearLines()
			tooltip:SetTradeSkillItem(self.index)
			tooltip:Show()
			if self.itemType == 1 then
				-- 소비용품
				for i = 2, tooltip:NumLines() do
					tooltip.left[i] = tooltip.left[i] or _G[tooltip:GetName().."TextLeft"..i]
					text = tooltip.left[i] and tooltip.left[i]:IsShown() and tooltip.left[i]:GetText() or ""
					if text:find(USE) then
						descCache[self.itemID] = (text:gsub(USE, "")):gsub("%((.+)%)$", "")
						for j = 1, 2 do
							tooltip.left[i + j] = tooltip.left[i + j] or _G[tooltip:GetName().."TextLeft"..(i + j)]
							text = tooltip.left[i + j] and tooltip.left[i + j]:IsShown() and tooltip.left[i + j]:GetText() or ""
							if text:find("\"") then
								descCache[self.itemID] = descCache[self.itemID].."\n"..text:gsub("\"", "")
								break
							end
						end
						if self.desc then
							InvenCraftInfoUI.detailScrollChild.desc:SetFormattedText("%s\n\n%s", descCache[self.itemID], self.desc)
						else
							InvenCraftInfoUI.detailScrollChild.desc:SetText(descCache[self.itemID])
						end
						self:Hide()
						break
					end
				end
			elseif self.itemType == 2 then
				-- 보석
				for i = 2, tooltip:NumLines() do
					tooltip.left[i] = tooltip.left[i] or _G[tooltip:GetName().."TextLeft"..i]
					text = tooltip.left[i] and tooltip.left[i]:IsShown() and tooltip.left[i]:GetText() or ""
					if text:find("++") or text:find("일정 확률") then
						descCache[self.itemID] = text
						for j = 1, 2 do
							tooltip.left[i + j] = tooltip.left[i + j] or _G[tooltip:GetName().."TextLeft"..(i + j)]
							text = tooltip.left[i + j] and tooltip.left[i + j]:IsShown() and tooltip.left[i + j]:GetText() or ""
							if text:find("\"") then
								descCache[self.itemID] = descCache[self.itemID].."\n"..text:gsub("\"", "")
								break
							end
						end
						if self.desc then
							InvenCraftInfoUI.detailScrollChild.desc:SetFormattedText("%s\n\n%s", descCache[self.itemID], self.desc)
						else
							InvenCraftInfoUI.detailScrollChild.desc:SetText(descCache[self.itemID])
						end
						self:Hide()
						break
					end
				end
			else
				-- 문양
				for i = 2, tooltip:NumLines() do
					tooltip.left[i] = tooltip.left[i] or _G[tooltip:GetName().."TextLeft"..i]
					text = tooltip.left[i] and tooltip.left[i]:IsShown() and tooltip.left[i]:GetText() or ""
					if text:find(USE) then
						descCache[self.itemID] = (text:gsub(USE, "")):gsub("%((.+)%)$", "")
						if self.desc then
							InvenCraftInfoUI.detailScrollChild.desc:SetFormattedText("%s\n\n%s", descCache[self.itemID], self.desc)
						else
							InvenCraftInfoUI.detailScrollChild.desc:SetText(descCache[self.itemID])
						end
						self:Hide()
						break
					end
				end
			end
			tooltip:Hide()
			if self.count > 3 then
				InvenCraftInfoUI.detailScrollChild.desc:SetText(self.desc)
				self:Hide()
			end
		else
			self:Hide()
		end
	end
end)

function InvenCraftInfoUI:StopDescUpdater()
	descUpdater:Hide()
end

function InvenCraftInfoUI:GetNewDescription(index)
	descUpdater:Hide()
	desc = GetTradeSkillDescription(index)
	desc = desc ~= "" and desc or nil
	item = GetTradeSkillItemLink(index)
	if item and item:find("item:(%d+)") then
		itemType, itemSubType = select(6, GetItemInfo(item))
		if itemType and itemTypes[itemType] then
			if type(itemTypes[itemType]) == "table" then
				if itemSubType and itemTypes[itemType][itemSubType] then
					itemType = itemTypes[itemType][itemSubType]
				else
					itemType = nil
				end
			else
				itemType = itemTypes[itemType]
			end
		else
			itemType = nil
		end
		if itemType then
			if itemType == 3 and desc then
				return self.detailScrollChild.desc:SetText(desc)
			else
				itemID = InvenCraftInfo:GetLinkID(item, "item")
				if descCache[itemID] and descCache[itemID] ~= "" then
					if desc then
						self.detailScrollChild.desc:SetFormattedText("%s\n\n%s", descCache[itemID], desc)

					else
						self.detailScrollChild.desc:SetText(descCache[itemID])
					end
					return
				end
				descUpdater.timer, descUpdater.count, descUpdater.index, descUpdater.itemType, descUpdater.itemID, descUpdater.desc = 1, 0, index, itemType, itemID, desc
				descUpdater:Show()
				return self.detailScrollChild.desc:SetText(desc)
			end
		end
	end
	self.detailScrollChild.desc:SetText(desc)
end