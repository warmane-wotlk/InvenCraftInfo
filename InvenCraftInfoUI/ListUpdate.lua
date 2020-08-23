local _G = _G
local min = _G.min
local pairs = _G.pairs
local ipairs = _G.ipairs
local unpack = _G.unpack
local select = _G.select
local abs = _G.math.abs
local tinsert = _G.table.insert
local GetItemInfo = _G.GetItemInfo
local GetTradeSkillRecipeLink = _G.GetTradeSkillRecipeLink
local GetTradeSkillItemLink = _G.GetTradeSkillItemLink
local GetNumTradeSkills = _G.GetNumTradeSkills
local GetTradeSkillInfo = _G.GetTradeSkillInfo
local GetTradeSkillLine = _G.GetTradeSkillLine
local GetTradeSkillSelectionIndex = _G.GetTradeSkillSelectionIndex
local IsTradeSkillLinked = _G.IsTradeSkillLinked
local IsModifiedClick = _G.IsModifiedClick
local GetMouseFocus = _G.GetMouseFocus

local numTradeSkills, realNumTradeSkills, skillOffset, name, rank, maxRank, skillName, skillType, numAvailable, isExpanded, altVerb
local skillIndex, realIndex, skillButton, nameWidth, countWidth, numHeaders, notExpanded, isLinked, selectID, firstID, orderName, orderMin, orderMax
local knownPlayer, splayer, spellID, fontName, stype, sid, iconWidth, prevHeader, spellCount, maxCount, desc, itemID
local tradeSkillList, headerData, spellIDTable, savedSpellIDTable, skillNameTable = {}, {}, {}, {}, {}
local skillTypeTable, skillReqTable, subList, itemLevelTable, shownIndex = {}, {}, {}, {}, {}
local horde = UnitFactionGroup("player") ~= "Horde"
local locale = GetLocale()

InvenCraftInfoUI.headerExpand = {}

local categoryNames, newCategoryHeader, newCategoryGoEtc, newCategoryList, newCategoryNameTable

if locale == "koKR" then
	categoryNames = {
		["요리"] = { "요리", "즐겨찾기", "음식과 음료", "이벤트" },
		["연금술"] = { "연금술", "즐겨찾기", "연금술 연구", "영약", "비약", "물약", "장신구", "얼개 보석", "변환", "가마솥", "기름", "기타" },
		["재봉술"] = { "재봉술", "즐겨찾기", "자수", "아이템 강화", "두루마리", "옷감", "천", "망토", "가방", "마법부여 가방", "보석 가방", "약초 가방", "영혼의 가방", "셔츠", "탈것", "기타" },
		["가죽세공"] = { "가죽세공", "즐겨찾기", "새김무늬", "아이템 강화", "직업용품", "가죽", "사슬", "망토", "가방", "가죽세공 가방", "주문각인 가방", "채광 가방", "탄환 주머니", "화살통", "기타" },
		["대장기술"] = { "대장기술", "즐겨찾기", "개조", "아이템 강화", "판금", "사슬", "양손 도검류", "양손 도끼류", "양손 둔기류", "장창류", "단검류", "한손 도검류", "한손 도끼류", "한손 둔기류", "투척 무기류", "방패", "마법막대", "연마석", "기타" },
		["기계공학"] = { "기계공학", "즐겨찾기", "수선", "판금", "사슬", "가죽", "천", "총기류", "조준경", "탄환", "기계 장치", "폭발물", "부품", "물약", "기계공학 가방", "애완동물", "잡동사니", "축제용품", "대장기술", "연금술", "탈것", "기타" },
		["마법부여"] = { "마법부여", "즐겨찾기", "무기 마법부여", "양손 무기 마법부여", "지팡이 마법부여", "방패 마법부여", "가슴보호구 마법부여", "장화 마법부여", "장갑 마법부여", "손목보호구 마법부여", "망토 마법부여", "반지 마법부여", "다색 보석", "마법막대", "마법봉", "오일", "기타" },
		["보석세공"] = { "보석세공", "즐겨찾기", "붉은색", "노란색", "푸른색", "주황색 (노란+붉은)", "보라색 (붉은+푸른)", "녹색 (노란+푸른)", "다색", "얼개 보석", "소비용품", "목걸이", "반지", "장신구", "천", "직업용품", "기타" },
		["주문각인"] = { "주문각인", "즐겨찾기", "문양 연구", "각인", "다크문 카드", "잉크", "전사", "도적", "사제", "마법사", "흑마법사", "사냥꾼", "드루이드", "주술사", "성기사", "죽음의 기사", "두루마리", "피지", "기타" },
		["응급치료"] = { "응급치료", "즐겨찾기", "붕대", "기타" },
		["채광"] = { "채광", "즐겨찾기", "광물", "원소" },
		["제련술"] = { "제련술", "즐겨찾기", "광물", "원소" },
	}
	newCategoryHeader = {
		["요리"] = { ["(.+)"] = "음식과 음료" },
		["연금술"] = { ["연금술 연구$"] = "연금술 연구", ["물약$"] = "물약", ["비약$"] = "비약", ["^아서스의 선물$"] = "비약", ["영약$"] = "영약", ["기름$"] = "기름", ["^변환식: (.+) 다이아몬드$"] = "얼개 보석", ["^변환식:"] = "변환", ["연금술사의 돌$"] = "장신구", ["연금술사 돌$"] = "장신구", ["^현자의 돌$"] = "장신구", ["^수은석$"] = "장신구", ["보호의 가마솥$"] = "가마솥" },
		["재봉술"] = { [" 두루마리$"] = "두루마리", [" 옷감$"] = "옷감", [" 셔츠$"] = "셔츠", ["드레스$"] = "천", [" 의상$"] = "천", ["무도복$"] = "천", ["망토$"] = "망토", ["^고르독 오우거 위장복$"] = "기타" },
		["가죽세공"] = { [" 망토$"] = "망토", [" 가죽$"] = "직업용품", ["^겨울 장화$"] = "기타", ["^야생의 장막"] = "망토", ["^고르독 오우거 위장복$"] = "기타" },
		["대장기술"] = { [" 연마석$"] = "연마석", ["마법막대"] = "마법막대", ["^세공된 미스릴 실린더$"] = "기타", ["철제 죔쇠"] = "기타" },
		["기계공학"] = { [" 조준경$"] = "조준경", ["^마력장 원반$"] = "기타", ["^사로나이트 서슬촉$"] = "탄환", ["^얼음날 화살$"] = "탄환" },
		["마법부여"] = { ["^무기"] = "무기 마법부여", ["^양손 무기"] = "양손 무기 마법부여", ["^지팡이"] = "지팡이 마법부여", ["^방패"] = "방패 마법부여", ["^가슴보호구"] = "가슴보호구 마법부여", ["^장화"] = "장화 마법부여", ["^장갑"] = "장갑 마법부여", ["^손목보호구"] = "손목보호구 마법부여", ["^망토"] = "망토 마법부여", ["^반지"] = "반지 마법부여", [" 구슬$"] = "다색 보석", ["마법막대$"] = "마법막대", ["마술봉$"] = "마법봉", [" 오일$"] = "오일" },
		["보석세공"] = { ["목걸이$"] = "목걸이", ["아뮬렛$"] = "목걸이", ["펜던트$"] = "목걸이", ["^여명의 선물$"] = "목걸이", ["^밤의 눈$"] = "목걸이", [" 목줄$"] = "목걸이", ["얼어붙은 눈"] = "반지", ["자연의 수호"] = "반지", ["반지$"] = "반지", ["고리$"] = "반지", ["인장$"] = "반지", ["^비취의 눈$"] = "반지", ["^루비 토끼"] = "장신구", ["^사파이어 올빼미"] = "장신구", ["^에메랄드 멧돼지"] = "장신구", ["^제왕 게"] = "장신구", ["^황혼뱀"] = "장신구", ["^조각상 "] = "장신구",  ["^수은 아다만타이트$"] = "직업용품", [" 장식$"] = "직업용품", [" 철사$"] = "직업용품", [" 다이아몬드$"] ="얼개 보석",  ["^묵직한 철제 너클$"] = "기타", ["변화무쌍한 검은 다이아몬드"] = "소비용품" },
		["주문각인"] = { [" 문양 연구$"] = "문양 연구", [" 카드$"] = "다크문 카드", ["^무기 피지"] = "피지", ["^방어구 피지"] = "피지", [" 잉크$"] = "잉크" },
		["응급치료"] = { [" 붕대$"] = "붕대" },
	}
	newCategoryGoEtc = {
		["연금술"] = true, ["마법부여"] = true, ["응급치료"] = true,
	}
	newCategoryList, newCategoryNameTable = {}, {}
	for p, t in pairs(newCategoryHeader) do
		newCategoryList[p] = {}
		for parser, header in pairs(t) do
			tinsert(newCategoryList[p], parser)
		end
		sort(newCategoryList[p], function(a, b)
			if a:len() == b:len() then
				return a < b
			else
				return a:len() > b:len()
			end
		end)
	end
	for p, t in pairs(categoryNames) do
		InvenCraftInfoUI.headerExpand[p] = {}
		newCategoryNameTable[p] = {}
		for i, v in pairs(t) do
			newCategoryNameTable[p][v] = i
			InvenCraftInfoUI.headerExpand[p][v] = true
		end
	end
else
	categoryNames = {
		[InvenCraftInfo.tradeSkillLocale["요리"]] = {},
		[InvenCraftInfo.tradeSkillLocale["연금술"]] = {},
		[InvenCraftInfo.tradeSkillLocale["재봉술"]] = {},
		[InvenCraftInfo.tradeSkillLocale["가죽세공"]] = {},
		[InvenCraftInfo.tradeSkillLocale["대장기술"]] = {},
		[InvenCraftInfo.tradeSkillLocale["기계공학"]] = {},
		[InvenCraftInfo.tradeSkillLocale["마법부여"]] = {},
		[InvenCraftInfo.tradeSkillLocale["보석세공"]] = {},
		[InvenCraftInfo.tradeSkillLocale["주문각인"]] = {},
		[InvenCraftInfo.tradeSkillLocale["응급치료"]] = {},
		[InvenCraftInfo.tradeSkillLocale["채광"]] = {},
		[InvenCraftInfo.tradeSkillLocale["제련술"]] = {},
	}
	newCategoryHeader = {}
	for p in pairs(categoryNames) do
		InvenCraftInfoUI.headerExpand[p] = {}
		newCategoryHeader[p] = {}
	end
end

local fontColor = {
	["InvenCraftInfoFont0"] = { 0.616, 0.616, 0.616 },
	["InvenCraftInfoFont1"] = { 1, 1, 1 },
	["InvenCraftInfoFont2"] = { 0.118, 1, 0 },
	["InvenCraftInfoFont3"] = { 0, 0.44, 0.867 },
	["InvenCraftInfoFont4"] = { 0.64, 0.208, 0.933 },
	["InvenCraftInfoFont5"] = { 1, 0.520, 0 },
	["InvenCraftInfoFont6"] = { 0.902, 0.8, 0.502 },
	["InvenCraftInfoFont7"] = { 0.902, 0.8, 0.502 },
}
local sourceText = { ["Q"] = "퀘스트", ["D"] = "드랍", ["E"] = "이벤트", ["F"] = "평판", ["A"] = "발견", ["V"] = "상인", ["W"] = "월드 드랍", ["H"] = "명예/투기장", ["X"] = "미확인/미구현" }
local sourceTexture = {
	["Q"] = "Interface\\GossipFrame\\AvailableQuestIcon",
	["D"] = "Interface\\GossipFrame\\BattleMasterGossipIcon",
	["E"] = "Interface\\GossipFrame\\BinderGossipIcon",
	["F"] = "Interface\\GossipFrame\\TaxiGossipIcon",
	["A"] = "Interface\\GossipFrame\\GossipGossipIcon",
	["V"] = "Interface\\GossipFrame\\VendorGossipIcon",
	["W"] = "Interface\\TargetingFrame\\UI-TargetingFrame-Skull",
	["H"] = "Interface\\PvPFrame\\PVP-ArenaPoints-Icon",
	["X"] = "Interface\\Common\\VoiceChat-Muted",
}
local tokenTexture = {
	["두꺼운 북풍 가죽"] = GetItemIcon(38425),
	["극지 가죽"] = GetItemIcon(44128),
	["꿈의 결정"] = GetItemIcon(34052),
	["심연의 수정"] = GetItemIcon(34057),
	["달라란 요리상"] = GetItemIcon(43016),
	["바위 문지기의 조각"] = GetItemIcon(43228),
	["달라란 보석세공사의 징표"] = GetItemIcon(41596),
	["초롱 버섯"] = GetItemIcon(24245),
	["할라아 연구 주화"] = GetItemIcon(26044),
	["문양 숙련의 서적"] = GetItemIcon(45912),
	["태고의 사로나이트"] = GetItemIcon(49908),
}
local difficultOrder = { ["header"] = 0, ["trivial"] = 1, ["easy"] = 2, ["medium"] = 3, ["optimal"] = 4, ["difficult"] = 5 }
local ignoreSpellID = {
	[2336] = true,				-- 언어의 비약
	[2671] = true,				-- 청동 팔보호구
	[7636] = true,				-- 녹색 양모 로브
	[8366] = true,				-- 아이언포지 사슬 갑옷
	[8368] = true,				-- 아이언포지 건틀릿
	[8778] = true,				-- 암흑의 장화
	[9942] = true,				-- 미스릴 미늘 장갑
	[10550] = true,				-- 밤하늘 망토
	[12062] = true,				-- 폭풍매듭 바지
	[12063] = true,				-- 폭풍매듭 장갑
	[12068] = true,				-- 폭풍매듭 조끼
	[12083] = true,				-- 폭풍매듭 머리띠
	[12087] = true,				-- 폭풍매듭 어깨보호구
	[12090] = true,				-- 폭풍매듭 장화
	[12720] = true,				-- 고블린 "콰앙" 상자
	[12722] = true,				-- 고블린 라디오
	[12900] = true,				-- 휴대용 경보기
	[12904] = true,				-- 고블린 무전기
	[16960] = true,				-- 토륨 대검
	[16965] = true,				-- 귀신나무 도끼
	[16967] = true,				-- 세공된 토륨 망치
	[16980] = true,				-- 룬문자 칼날도끼
	[16986] = true,				-- 피의 갈퀴발톱
	[16987] = true,				-- 검은 창
	[17579] = true,				-- 상급 신성 보호 물약
	[19106] = true,				-- 오닉시아 비늘 흉갑
	[22813] = true,				-- 고르독 오우거 위장복
	[22815] = true,				-- 고르독 오우거 위장복
	[24266] = true,				-- 광기의 구루바시 모조
	[25614] = true,				-- 은장미 펜던트
	[26918] = true,				-- 아케이나이트 검 펜던트
	[26920] = true,				-- 피의 왕관
	[28021] = true,				-- 신비한 수정 가루
	[28327] = true,				-- 통통 전차 조정기
	[30342] = true,				-- 적색 조명탄
	[30343] = true,				-- 청색 조명탄
	[30549] = true,				-- 동물 확대기
	[31461] = true,				-- 무거운 황천매듭 그물
	[32810] = true,				-- 고대 돌 조각상
	[36665] = true,				-- 황천의 불길 로브
	[36667] = true,				-- 황천의 불길 허리띠
	[36668] = true,				-- 황천의 불길 장화
	[36669] = true,				-- 생명의 피 다리보호구
	[36670] = true,				-- 생명의 피 팔보호구
	[36672] = true,				-- 생명의 피 허리띠
	[44612] = true,				-- 장갑 마법부여 - 상급 폭파
	[54020] = true,				-- 영원의 힘
	[55243] = true,				-- 굴곡의 팔보호구
	[56048] = true,				-- 그늘매듭 장화
	[57231] = true,				-- 죽음의 기사 문양
	[60244] = true,				-- 맛있는 딸기
	[62257] = true,				-- 무기 마법부여 - 티탄의 수호
	[65454] = true,				-- 망자의 빵
	[65730] = true,				-- 모피 안감 - 전투력
	[67790] = true,				-- 차원 분절기: K3
	[62051] = not horde,			-- 고구마 맛탕
	[62049] = not horde,			-- 새콤달콤 덩굴윌귤 소스
	[62050] = not horde,			-- 매콤한 빵 범벅
	[62044] = not horde,			-- 호박 파이
	[62045] = not horde,			-- 서서히 구운 칠면조
	[66034] = horde,			-- 고구마 맛탕
	[66035] = horde,			-- 새콤달콤 덩굴윌귤 소스
	[66036] = horde,			-- 호박 파이
	[66037] = horde,			-- 서서히 구운 칠면조
	[66038] = horde,			-- 매콤한 빵 범벅
	[60866] = horde,			-- 호토바이
	[60867] = not horde,			-- 맥기니어의 붕붕이
	[67064] = not horde,
	[67065] = not horde,
	[67066] = not horde,
	[67079] = not horde,
	[67080] = not horde,
	[67081] = not horde,
	[67082] = not horde,
	[67083] = not horde,
	[67084] = not horde,
	[67085] = not horde,
	[67086] = not horde,
	[67087] = not horde,
	[67091] = not horde,
	[67092] = not horde,
	[67093] = not horde,
	[67094] = not horde,
	[67095] = not horde,
	[67096] = not horde,
	[67130] = horde,
	[67131] = horde,
	[67132] = horde,
	[67133] = horde,
	[67134] = horde,
	[67135] = horde,
	[67136] = horde,
	[67137] = horde,
	[67138] = horde,
	[67139] = horde,
	[67140] = horde,
	[67141] = horde,
	[67142] = horde,
	[67143] = horde,
	[67144] = horde,
	[67145] = horde,
	[67146] = horde,
	[67147] = horde,
}

local dropTable = InvenCraftInfo.GetDropTable and InvenCraftInfo:GetDropTable()

InvenCraftInfoUI.selectQuee = {}

local function setButtonColor(button, font, r, g, b)
	button:SetNormalFontObject(font)
	button.count:SetVertexColor(r, g, b)
	button.r, button.g, button.b = r, g, b
end

local function setSkillSource(button, link)
	if link and InvenCraftInfo.GetSpellSource then
		if InvenCraftInfo.GetSpellSourceString then
			stype = InvenCraftInfo:GetSpellSourceString(link)
			if stype and not stype:find("F(%d+)_(%d+)") then
				for p, v in pairs(tokenTexture) do
					if stype:find(p) then
						button.source1:SetWidth(9)
						button.source1:SetHeight(9)
						button.source1.texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
						button.source1.tooltipText = InvenCraftInfo:GetDrop(link) or stype
						button.source1:SetNormalTexture(v)
						button.source1:Show()
						button.source2:Hide()
						return
					end
				end
			end
			stype = InvenCraftInfo:GetSpellSource(link)
			if stype == "T" and InvenCraftInfo.GetSpellReq and InvenCraftInfo:GetSpellReq(link) == 0 then
				stype = "X"
			end
			if stype and stype ~= "T" then
				stype = { (","):split(stype) }
				sid = 1
				for i = 1, 2 do
					if sourceTexture[stype[i] or "*"] then
						if sid == 1 then
							button.source1:SetWidth(12)
							button.source1:SetHeight(12)
							button.source1.texture:SetTexCoord(0, 1, 0, 1)
						end
						button["source"..sid].tooltipText = InvenCraftInfo:GetDrop(link) or sourceText[stype[i]]
						button["source"..sid]:SetNormalTexture(sourceTexture[stype[i]])
						button["source"..sid]:Show()
						sid = sid + 1
					end
				end
				for i = sid, 2 do
					button["source"..i]:Hide()
				end
				return
			end
		end
	end
	button.source1:Hide()
	button.source2:Hide()
end

local function setButtonText(button, sname, count)
	button.text:SetText(sname)
	TradeSkillFrameDummyString:SetText(sname)
	nameWidth = TradeSkillFrameDummyString:GetWidth()
	if button.source1:IsShown() then
		iconWidth = button.source1:GetWidth() + 2 + (button.source2:IsShown() and button.source2:GetWidth() or 0)
	else
		iconWidth = 0
	end
	if count > 0 then
		button.count:SetFormattedText("[%d]", count)
		countWidth = button.count:GetWidth()
	else
		button.count:SetText("")
		countWidth = 0
	end
	if (nameWidth + countWidth + iconWidth + 2) > 275 then
		button.text:SetWidth(275 - countWidth - iconWidth - 2)
	else
		button.text:SetWidth(0)
	end
end

local function clearTable(table)
	for p in pairs(table) do
		table[p] = nil
	end
end

local function isTrueSpell(id)
	if isLinked and InvenCraftInfoUI.isAddOnLink then
		return not ignoreSpellID[id]
	else
		return true
	end
end

local function sortFunc1(a, b)
	-- 필요 숙련 우선 정렬
	if skillReqTable[a] == skillReqTable[b] then
		if itemLevelTable[a] == itemLevelTable[b] then
			if skillNameTable[a] == skillNameTable[b] then
				return a > b
			else
				return skillNameTable[a] < skillNameTable[b]
			end
		else
			return itemLevelTable[a] > itemLevelTable[b]
		end
	else
		return skillReqTable[a] > skillReqTable[b]
	end
end

local function sortFunc2(a, b)
	-- 숙련 색상 우선
	if skillTypeTable[a] == skillTypeTable[b] then
		return sortFunc1(a, b)
	else
		return skillTypeTable[a] > skillTypeTable[b]
	end
end

local function sortFunc3(a, b)
	-- 이름 우선 정렬
	if skillNameTable[a] == skillNameTable[b] then
		if skillReqTable[a] == skillReqTable[b] then
			if itemLevelTable[a] == itemLevelTable[b] then
				return a > b
			else
				return itemLevelTable[a] > itemLevelTable[b]
			end
		else
			return skillReqTable[a] > skillReqTable[b]
		end
	else
		return skillNameTable[a] < skillNameTable[b]
	end
end

local function sortSubList(sortTable)
	if #sortTable > 0 then
		if orderName == "필요 숙련 우선" then
			sort(sortTable, sortFunc1)
		elseif orderName == "숙련 색상 우선" then
			sort(sortTable, sortFunc2)
		else
			sort(sortTable, sortFunc3)
		end
		for _, v in ipairs(sortTable) do
			tinsert(tradeSkillList, v)
		end
	end
end

local function addData(cate, value)
	if orderMin <= orderMax then
		if skillReqTable[value] == 9999 or (skillReqTable[value] >= orderMin and skillReqTable[value] <= orderMax) then
			headerData[cate] = headerData[cate] or {}
			tinsert(headerData[cate], value)
			if categoryNames[name] and spellIDTable[value] and InvenCraftInfoUICharDB.favorite[spellIDTable[value]] then
				headerData["즐겨찾기"] = headerData["즐겨찾기"] or {}
				tinsert(headerData["즐겨찾기"], value)
			end
		end
	end
end

local function sortTradeSkillList()
	InvenCraftInfoUI:ClearSortData()
	prevHeader = nil
	spellCount = 0
	if categoryNames[name] then
		if locale == "koKR" then
			for i = 1, realNumTradeSkills do
				skillName, skillType = GetTradeSkillInfo(i)
				if skillName then
					if skillType == "header" then
						prevHeader = skillName
					else
						spellID = InvenCraftInfo:GetLinkID(GetTradeSkillRecipeLink(i), "enchant")
						shownIndex[i] = spellID
						if not savedSpellIDTable[spellID] and isTrueSpell(spellID) then
							if not ignoreSpellID[id] then
								spellCount = spellCount + 1
							end
							savedSpellIDTable[spellID] = i
							skillTypeTable[i] = difficultOrder[skillType] or 0
							spellIDTable[i] = spellID
							skillReqTable[i] = InvenCraftInfo:GetSpellReq(spellID)
							skillReqTable[i] = skillReqTable[i] == 0 and 9999 or skillReqTable[i]
							itemID = InvenCraftInfo:GetLinkID(GetTradeSkillItemLink(i), "item")
							itemLevelTable[i] = itemID and select(4, GetItemInfo(itemID)) or 0
							if newCategoryHeader[name] then
								if newCategoryList[name][spellID] then
									skillNameTable[i] = skillName
									addData(newCategoryList[name][spellID], i)
								elseif name == "요리" and categoryNames[name][4] == "이벤트" and dropTable and type(dropTable[spellID]) == "string" and dropTable[spellID]:find("이벤트") then
									skillNameTable[i] = skillName
									addData("이벤트", i)
								else
									for _, parser in ipairs(newCategoryList[name]) do
										if type(parser) == "string" and skillName:find(parser) then
											skillNameTable[i] = skillName
											addData(newCategoryHeader[name][parser], i)
											break
										end
									end
								end
							end
							if not skillNameTable[i] then
								skillNameTable[i] = skillName
								if newCategoryGoEtc[name] then
									addData("기타", i)
								else
									if not prevHeader then
										if #categoryNames[name] == 1 then
											prevHeader = categoryNames[name][1]
										else
											prevHeader = skillName
										end
									end
									if newCategoryNameTable[name][prevHeader] then
										addData(prevHeader, i)
									else
										addData(name, i)
									end
								end
							end
						end
					end
				end
			end
		else
			for p in pairs(categoryNames[name]) do
				categoryNames[name][p] = nil
			end
			for p in pairs(newCategoryHeader[name]) do
				newCategoryHeader[name][p] = nil
			end
			categoryNames[name][1] = "즐겨찾기"
			if InvenCraftInfoUI.headerExpand[name]["즐겨찾기"] == nil then
				InvenCraftInfoUI.headerExpand[name]["즐겨찾기"] = true
			end
			for i = 1, realNumTradeSkills do
				skillName, skillType = GetTradeSkillInfo(i)
				if skillName then
					if skillType == "header" then
						prevHeader = skillName
						if not newCategoryHeader[name][skillName] then
							newCategoryHeader[name][skillName] = true
							tinsert(categoryNames[name], skillName)
							if InvenCraftInfoUI.headerExpand[name][skillName] == nil then
								InvenCraftInfoUI.headerExpand[name][skillName] = true
							end
						end
					else
						spellID = InvenCraftInfo:GetLinkID(GetTradeSkillRecipeLink(i), "enchant")
						shownIndex[i] = spellID
						if not savedSpellIDTable[spellID] and isTrueSpell(spellID) then
							if not ignoreSpellID[id] then
								spellCount = spellCount + 1
							end
							savedSpellIDTable[spellID] = i
							skillTypeTable[i] = difficultOrder[skillType] or 0
							spellIDTable[i] = spellID
							skillReqTable[i] = InvenCraftInfo:GetSpellReq(spellID)
							skillReqTable[i] = skillReqTable[i] == 0 and 9999 or skillReqTable[i]
							itemID = InvenCraftInfo:GetLinkID(GetTradeSkillItemLink(i), "item")
							itemLevelTable[i] = itemID and select(4, GetItemInfo(itemID)) or 0
							skillNameTable[i] = skillName
							addData(prevHeader, i)
						end
					end
				end
			end

		end
		for i, p in ipairs(categoryNames[name]) do
			if headerData[p] and #headerData[p] > 0 then
				if InvenCraftInfoUI.subClassIndex == 0 or InvenCraftInfoUI.subClassIndex == i then
					tinsert(tradeSkillList, p)
					if InvenCraftInfoUI.headerExpand[name][p] then
						sortSubList(headerData[p])
					end
				end
				clearTable(headerData[p])
			end
		end
		for p in pairs(skillNameTable) do
			skillNameTable[p] = nil
			skillTypeTable[p] = nil
			spellIDTable[p] = nil
			skillReqTable[p] = nil
			itemLevelTable[p] = nil
		end
		InvenCraftInfoUI.isSort = true
		InvenCraftInfoUI:EnableFilter(true)
	else
		for i = 1, realNumTradeSkills do
			skillName, skillType = GetTradeSkillInfo(i)
			if skillName and skillType ~= "header" then
				spellID = InvenCraftInfo:GetLinkID(GetTradeSkillRecipeLink(i), "enchant")
				shownIndex[i] = spellID
				if not savedSpellIDTable[spellID] and isTrueSpell(spellID) then
					if not ignoreSpellID[id] then
						spellCount = spellCount + 1
					end
					savedSpellIDTable[spellID] = true
				end
			end
		end
		InvenCraftInfoUI:EnableFilter(nil)
	end
end

local function setFirstTradeSkill()
	if InvenCraftInfoUI.isSort then
		for _, v in ipairs(tradeSkillList) do
			if type(v) == "number" and select(2, GetTradeSkillInfo(v)) ~= "header" then
				return TradeSkillFrame_SetSelection(v)
			end
		end
		TradeSkillFrame_SetSelection(0)
	else
		TradeSkillFrame_SetSelection(GetFirstTradeSkill())
	end
end

local function findCurrentTradeSkill()
	if InvenCraftInfoUI.isSort then
		if tradeSkillList[selectID] ~= selectID then
			firstID = nil
			for _, v in ipairs(tradeSkillList) do
				if v == selectID then
					return TradeSkillFrame_SetSelection(selectID)
				elseif not firstID and type(v) == "number" and select(2, GetTradeSkillInfo(v)) ~= "header" then
					firstID = v
				end
			end
			TradeSkillFrame_SetSelection(firstID or 0)
		end
	end
end

local function countHeader(startIndex, endIndex, selectionIndex)
	if InvenCraftInfoUI.isSort then
		for i = startIndex, endIndex do
			if type(tradeSkillList[i]) == "string" then
				numHeaders = numHeaders + 1
				if not InvenCraftInfoUI.headerExpand[name][tradeSkillList[i]] then
					notExpanded = notExpanded + 1
				end
			elseif selectionIndex == tradeSkillList[i] then
				TradeSkillFrame.numAvailable = abs(select(3, GetTradeSkillInfo(tradeSkillList[i])) or 0)
			end
			if type(tradeSkillList[i]) == "number" and not InvenCraftInfoUI.forceUpdateList then
				spellID = InvenCraftInfo:GetLinkID(GetTradeSkillRecipeLink(tradeSkillList[i]), "enchant")
				if isLinked and InvenCraftInfoUI.isAddOnLink and spellID and ignoreSpellID[spellID] then
					InvenCraftInfoUI.forceUpdateList = true
				end
			end

		end
	else
		for i = startIndex, endIndex do
			skillName, skillType, numAvailable, isExpanded = GetTradeSkillInfo(i)
			if skillName and skillType == "header" then
				numHeaders = numHeaders + 1
				if not isExpanded then
					notExpanded = notExpanded + 1
				end
			end
			if selectionIndex == i then
				TradeSkillFrame.numAvailable = abs(numAvailable)
			end
		end
	end
end

local function checkUpdate()
	if InvenCraftInfoUI.p_tradeSkillName ~= InvenCraftInfoUI.tradeSkillName or InvenCraftInfoUI.p_numTradeSkills ~= InvenCraftInfoUI.numTradeSkills or InvenCraftInfoUI.p_skillInfo1 ~= InvenCraftInfoUI.skillInfo1 or InvenCraftInfoUI.p_skillInfo2 ~= InvenCraftInfoUI.skillInfo2 or InvenCraftInfoUI.p_skillInfo3 ~= InvenCraftInfoUI.skillInfo3 then
		InvenCraftInfoUI.p_tradeSkillName = InvenCraftInfoUI.tradeSkillName
		InvenCraftInfoUI.p_numTradeSkills = InvenCraftInfoUI.numTradeSkills
		InvenCraftInfoUI.p_skillInfo1 = InvenCraftInfoUI.skillInfo1
		InvenCraftInfoUI.p_skillInfo2 = InvenCraftInfoUI.skillInfo2
		InvenCraftInfoUI.p_skillInfo3 = InvenCraftInfoUI.skillInfo3
		InvenCraftInfoUI.forceUpdateList = nil
		return true
	elseif InvenCraftInfoUI.forceUpdateList then
		InvenCraftInfoUI.forceUpdateList = nil
		return true
	end
	return nil
end

function InvenCraftInfoUI:IsIgnoreSkill(spellID)
	if isLinked and self.isAddOnLink then
		return ignoreSpellID[InvenCraftInfo:GetLinkID(spellID, "enchant") or "*"]
	else
		return nil
	end
end

function InvenCraftInfoUI:ListUpdate()
	self = InvenCraftInfoUI
	if not self:IsShown() or self.skipUpdate or self.makeSkillWindowDelay then return end
	realNumTradeSkills = GetNumTradeSkills()
	name, rank, maxRank = GetTradeSkillLine()
	isLinked = IsTradeSkillLinked()
	self.tradeSkillName = name
	self.numTradeSkills = realNumTradeSkills
	self.skillInfo1 = GetTradeSkillInfo(2)
	self.skillInfo2 = GetTradeSkillInfo(floor(self.numTradeSkills / 2) + 1)
	self.skillInfo3 = GetTradeSkillInfo(self.numTradeSkills)
	orderName, orderMin, orderMax = self.orderDB.order, max(self.orderDB.min or 1, 1), min(self.orderDB.max or InvenCraftInfo.maxSkillLevel, InvenCraftInfo.maxSkillLevel)
	selectID = GetTradeSkillSelectionIndex()
	if checkUpdate() then
		self.sortedName = name
		sortTradeSkillList()
		if self.changeSpell then
			setFirstTradeSkill()
			selectID = nil
		elseif selectID and selectID > 0 then
			findCurrentTradeSkill()
		else
			setFirstTradeSkill()
		end
		self.changeSpell = nil
		if selectID ~= GetTradeSkillSelectionIndex() then
			selectID = GetTradeSkillSelectionIndex()
			InvenCraftInfoUI:UpdateQuee(selectID, true)
		end
	end
	if self.isSort then
		numTradeSkills = #tradeSkillList
	else
		numTradeSkills = realNumTradeSkills
	end
	skillOffset = FauxScrollFrame_GetOffset(InvenCraftInfoUIListScrollFrame)
	FauxScrollFrame_Update(InvenCraftInfoUIListScrollFrame, numTradeSkills, 20, 16, nil, nil, nil, self.listHighlightBar, 293, 316)
	self.listHighlightBar:Hide()
	self.listHighlightBar2:Hide()
	selectID = GetTradeSkillSelectionIndex()
	numHeaders, notExpanded = 0, 0
	TradeSkillFrame.numAvailable = 0
	for i = 1, 20 do
		skillIndex = i + skillOffset
		skillButton = self.skillButtons[i]
		if InvenCraftInfoUIListScrollFrame:IsShown() then
			skillButton:SetWidth(293)
		else
			skillButton:SetWidth(323)
		end
		if self.isSort then
			realIndex = tradeSkillList[skillIndex]
		else
			realIndex = skillIndex
		end
		if type(realIndex) == "string" then
			skillButton.fakeHeader = realIndex
			skillButton:SetID(1)
			skillButton:Show()
			numHeaders = numHeaders + 1
			setButtonColor(skillButton, TradeSkillTypeColor.header.font, TradeSkillTypeColor.header.r, TradeSkillTypeColor.header.g, TradeSkillTypeColor.header.b)
			if realIndex == "즐겨찾기" and locale ~= "koKR" then
				skillButton:SetText("Favorites")
			else
				skillButton:SetText(realIndex)
			end
			skillButton.text:SetWidth(275)
			skillButton.count:SetText("")
			if self.headerExpand[name][realIndex] then
				skillButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
				skillButton:SetDisabledTexture("Interface\\Buttons\\UI-MinusButton-Disabled")
			else
				notExpanded = notExpanded + 1
				skillButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
				skillButton:SetDisabledTexture("Interface\\Buttons\\UI-PlusButton-Disabled")
			end
			skillButton:UnlockHighlight()
			skillButton.highlight:SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
			skillButton.checkTexture:SetTexture("")
			skillButton.checkButton.tooltipText = nil
			setSkillSource(skillButton)
		elseif realIndex and realIndex <= realNumTradeSkills then
			skillName, skillType, numAvailable, isExpanded, altVerb = GetTradeSkillInfo(realIndex)
			skillButton.fakeHeader = nil
			skillButton:SetID(realIndex)
			skillButton:Show()
			skillName = self:CorrectSkillName(skillName)
			if skillType == "header" then
				numHeaders = numHeaders + 1
				setButtonColor(skillButton, TradeSkillTypeColor[skillType].font, TradeSkillTypeColor[skillType].r, TradeSkillTypeColor[skillType].g, TradeSkillTypeColor[skillType].b)
				skillButton:SetText(skillName)
				skillButton.text:SetWidth(275)
				skillButton.count:SetText("")
				if isExpanded then
					skillButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
					skillButton:SetDisabledTexture("Interface\\Buttons\\UI-MinusButton-Disabled")
				else
					notExpanded = notExpanded + 1
					skillButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
					skillButton:SetDisabledTexture("Interface\\Buttons\\UI-PlusButton-Disabled")
				end
				skillButton:UnlockHighlight()
				skillButton.highlight:SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
				if selectID == realIndex then
					TradeSkillFrame.numAvailable = abs(numAvailable)
				end
				skillButton.checkTexture:SetTexture("")
				skillButton.checkButton.tooltipText = nil
				setSkillSource(skillButton)
			else
				spellID = InvenCraftInfo:GetLinkID(GetTradeSkillRecipeLink(realIndex), "enchant")
				if isLinked and self.isAddOnLink then
					if self.isSort and spellID and ignoreSpellID[spellID] then
						self.forceUpdateList = true
					end
					fontName = GetTradeSkillItemLink(realIndex)
					fontName = "InvenCraftInfoFont"..(fontName and select(3, GetItemInfo(fontName)) or 2)
					setButtonColor(skillButton, fontName, unpack(fontColor[fontName]))
					setSkillSource(skillButton, spellID)
					setButtonText(skillButton, " "..skillName, numAvailable)
				else
					InvenCraftInfoUI.isAddOnLink = nil
					setButtonColor(skillButton, TradeSkillTypeColor[skillType].font, TradeSkillTypeColor[skillType].r, TradeSkillTypeColor[skillType].g, TradeSkillTypeColor[skillType].b)
					setSkillSource(skillButton)
					setButtonText(skillButton, " "..skillName, numAvailable)
				end
				if isLinked then
					knownPlayer, splayer = InvenCraftInfoData:IsKnownRecipe(spellID)
					if knownPlayer then
						skillButton.checkButton.tooltipText = knownPlayer:gsub(", ", "\n")
						if splayer then
							skillButton.checkTexture:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
						else
							skillButton.checkTexture:SetTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
						end
						skillButton.checkButton:Show()
					else
						skillButton.checkButton:Hide()
						skillButton.checkButton.tooltipText = nil
					end
				else
					skillButton.checkButton:Hide()
					skillButton.checkButton.tooltipText = nil
				end
				skillButton:SetNormalTexture("")
				skillButton:SetDisabledTexture("")
				skillButton.highlight:SetTexture("")
				if selectID == realIndex then
					TradeSkillFrame.numAvailable = abs(numAvailable)
					if self.listHighlightBar:IsShown() then
						self.listHighlightBar2:ClearAllPoints()
						self.listHighlightBar2:SetPoint("TOPLEFT", skillButton, "TOPLEFT", 0, 0)
						self.listHighlightBar2:Show()
					else
						self.listHighlightBar:SetPoint("TOPLEFT", skillButton, "TOPLEFT", 0, 0)
						self.listHighlightBar:Show()
					end
					skillButton.count:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
					skillButton:LockHighlight()
					skillButton.isHighlighted = true
				else
					skillButton:UnlockHighlight()
					skillButton.isHighlighted = false
				end
				if InvenCraftInfoDB.listTootip and GetMouseFocus() == skillButton then
					GameTooltip:Hide()
					skillButton:GetScript("OnEnter")(skillButton)
				end
			end
		else
			skillButton:Hide()
		end
	end
	countHeader(1, skillOffset + TRADE_SKILLS_DISPLAYED - 1, selectID)
	countHeader(skillOffset + TRADE_SKILLS_DISPLAYED + 1, numTradeSkills, selectID)
	if notExpanded ~= numHeaders then
		TradeSkillCollapseAllButton.collapsed = nil
		TradeSkillCollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
		TradeSkillCollapseAllButton:SetDisabledTexture("Interface\\Buttons\\UI-MinusButton-Disabled")
	else
		TradeSkillCollapseAllButton.collapsed = 1
		TradeSkillCollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
		TradeSkillCollapseAllButton:SetDisabledTexture("Interface\\Buttons\\UI-PlusButton-Disabled")
	end
	if self.changeSpell or self.currentSpellCount == nil or self.currentSpellCount < spellCount then
		self.changeSpell = nil
		self.currentSpellCount = spellCount
		maxCount = InvenCraftInfo:GetNumTotalTradeSkills(name)
		if maxCount then
			if spellCount > maxCount then
				InvenCraftInfo:UpdateNumTotalTradeSkills(name, spellCount)
				maxCount = spellCount
			end
			self.tradeSkillNumBar:SetMinMaxValues(0, maxCount)
			self.tradeSkillNumBar:SetValue(spellCount)
			self.tradeSkillNumBar.text:SetFormattedText("%d / %d (%d%%)", spellCount, maxCount, (spellCount / maxCount) * 100)
			self.tradeSkillNumBar.bg:Show()
		else
			self.tradeSkillNumBar.bg:Hide()
		end
	end
	self:UpdateRankFrame(name, rank, maxRank)
end

function InvenCraftInfoUI:GoToSpell(spell)
	if spell and savedSpellIDTable[spell] then
		TradeSkillFrame_SetSelection(savedSpellIDTable[spell])
		self:ListUpdate()
		return true
	end
	return nil
end

function InvenCraftInfoUI:UpdateQuee(index, clear)
	if clear or not index then
		clearTable(self.selectQuee)
	end
	if index then
		index = InvenCraftInfo:GetLinkID(GetTradeSkillRecipeLink(index), "enchant")
		if index then
			tinsert(self.selectQuee, 1, index)
		elseif #self.selectQuee > 0 then
			clearTable(self.selectQuee)
		end
	end
end

function InvenCraftInfoUI:FindSkillIndex(spell)
	spell = InvenCraftInfo:GetLinkID(spell, "enchant")
	if spell and savedSpellIDTable[spell] and shownIndex[savedSpellIDTable[spell]] then
		return savedSpellIDTable[spell]
	else
		return nil
	end
end

function InvenCraftInfoUI:UpdateList()
	self.p_tradeSkillName = nil
	self:ListUpdate()
end

function InvenCraftInfoUI:GetSubClassText(skill, index)
	if categoryNames[skill] then
		if index == 1 then
			return ALL_SUBCLASSES
		else
			return categoryNames[skill][index] or ""
		end
	end
	return ""
end

function InvenCraftInfoUI:HasFavorite(skill)
	return categoryNames[skill or name] and true or nil
end

function InvenCraftInfoUI:ResetExpand(skill)
	self.subClassIndex = 0
	if self.headerExpand[skill] then
		for _, p in ipairs(categoryNames[skill]) do
			self.headerExpand[skill][p] = true
		end
	end
end

function InvenCraftInfoUI:ClearSortData()
	self.isSort = nil
	clearTable(tradeSkillList)
	clearTable(savedSpellIDTable)
	clearTable(shownIndex)
end

local hook_ExpandTradeSkillSubClass = ExpandTradeSkillSubClass
local hook_CollapseTradeSkillSubClass = CollapseTradeSkillSubClass

function CollapseTradeSkillSubClass(index)
	if not InvenCraftInfoUI.isSort then
		hook_CollapseTradeSkillSubClass(index)
	end
end

function ExpandTradeSkillSubClass(index)
	if InvenCraftInfoUI.isSort then
		hook_ExpandTradeSkillSubClass(0)
	else
		hook_ExpandTradeSkillSubClass(index)
	end
end

TradeSkillCollapseAllButton:SetScript("OnClick", function(self)
	if InvenCraftInfoUI.isSort then
		if self.collapsed then
			self.collapsed = nil
			if categoryNames[name] then
				for _, p in ipairs(categoryNames[name]) do
					InvenCraftInfoUI.headerExpand[name][p] = true
				end
			end
		elseif categoryNames[name] then
			for _, p in ipairs(categoryNames[name]) do
				InvenCraftInfoUI.headerExpand[name][p] = false
			end
		end
		InvenCraftInfoUI:UpdateList()
	elseif self.collapsed then
		self.collapsed = nil
		ExpandTradeSkillSubClass(0)
	else
		self.collapsed = 1
		TradeSkillListScrollFrameScrollBar:SetValue(0)
		CollapseTradeSkillSubClass(0)
	end
end)

local function setSubClassDropDown(info, text, value, func)
	if text == "즐겨찾기" and locale ~= "koKR" then
		text = "Favorites"
	end
	info.text = text
	info.arg1 = text
	info.arg2 = value == 0 and 1 or (info.arg2 + 1)
	info.value = value
	info.func = func
	info.checked = InvenCraftInfoUI.subClassIndex == value
	UIDropDownMenu_AddButton(info)
	if info.checked then
		UIDropDownMenu_SetText(TradeSkillSubClassDropDown, text)
	end
end

local function subClassDropDownOnClick(self, text, index)
	if InvenCraftInfoUI.subClassIndex ~= self.value then
		InvenCraftInfoUI.subClassIndex = self.value
		UIDropDownMenu_SetSelectedID(TradeSkillSubClassDropDown, index)
		UIDropDownMenu_SetText(TradeSkillSubClassDropDown, text)
		InvenCraftInfoUI:SetScrollTop()
		InvenCraftInfoUI:UpdateList()
	end
end

function TradeSkillSubClassDropDown_Initialize()
	if InvenCraftInfoUI.isSort then
		name = GetTradeSkillLine()
		if name and categoryNames[name] then
			local info = UIDropDownMenu_CreateInfo()
			setSubClassDropDown(info, ALL_SUBCLASSES, 0, subClassDropDownOnClick)
			if categoryNames[name][1] == name then
				for i = 2, #categoryNames[name] do
					setSubClassDropDown(info, categoryNames[name][i], i, subClassDropDownOnClick)
				end
			else
				for i = 1, #categoryNames[name] do
					setSubClassDropDown(info, categoryNames[name][i], i, subClassDropDownOnClick)
				end
			end
		else
			TradeSkillFilterFrame_LoadSubClasses(GetTradeSkillSubClasses())
		end
	else
		TradeSkillFilterFrame_LoadSubClasses(GetTradeSkillSubClasses())
	end
end