if Skinner then
	hooksecurefunc(Skinner, "TradeSkillUI", function(self)
		if self.initialized.TradeSkillUI then
			self:skinEditBox{obj=TradeSkillFrameMinReqText, regs={9}}
			self:skinEditBox{obj=TradeSkillFrameMaxReqText, regs={9}}
			self:moveObject(TradeSkillFrameMinReqText, "-", 6)
			self:moveObject(TradeSkillFrameMaxReqText, "-", 4)
			self:skinDropDown{obj=TradeSkillSortDropDown}
			self:glazeStatusBar(InvenCraftInfoUI.tradeSkillNumBar, 0)
			self:moveObject(InvenCraftInfoUI.tradeSkillNumBar, nil, nil, "-", 4)
			InvenCraftInfoUI.tradeSkillNumBar:SetHeight(18)
			InvenCraftInfoUI.tradeSkillNumBar.bg:SetAlpha(0)
			self:skinScrollBar{obj=InvenCraftInfoUIListScrollFrame}
			self:skinScrollBar{obj=InvenCraftInfoUIDetailScrollFrame}
			for _, tab in ipairs(InvenCraftInfoUI.bottomTab) do
				self:keepRegions(tab, {7, 8})
				self:addSkinFrame{obj=tab, ft="c", x1=6, x2=-6, y2=2}
			end
			for i, tab in ipairs(InvenCraftInfoUI.sideTab) do
				self:removeRegions(tab, {1})
			end
			self:addSkinFrame{obj=InvenCraftInfoUI, ft="c", kfs=true, y1=-11, y2=-3}
		end
	end)
end