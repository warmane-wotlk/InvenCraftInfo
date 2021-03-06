local _G = getfenv(0)
local mod = _G.mod
local strlen = _G.string.len
local v, n, s, item
local useSkillID = {}
local useSkills = {
	[1] = GetSpellInfo(2259),
	[2] = GetSpellInfo(3908),
	[3] = GetSpellInfo(2108),
	[4] = GetSpellInfo(2018),
	[5] = GetSpellInfo(4036),
	[6] = GetSpellInfo(7411),
	[7] = GetSpellInfo(25229),
	[8] = GetSpellInfo(45363),
	[9] = GetSpellInfo(2656),
	[10] = GetSpellInfo(3273),
	[11] = GetSpellInfo(2550),
}

for id, skill in ipairs(useSkills) do
	useSkillID[skill] = id
end

local reagentData = {
	[38425] = 22,
	[5082] = 4,
	[33470] = 530,
	[8167] = 4,
	[23448] = 88,
	[22457] = 127,
	[6149] = 64,
	[27668] = 1024,
	[36923] = 65,
	[9262] = 1,
	[15408] = 4,
	[30817] = 1024,
	[12363] = 97,
	[27860] = 64,
	[23784] = 16,
	[44500] = 16,
	[22793] = 1,
	[38426] = 2,
	[13466] = 1,
	[21882] = 2,
	[33567] = 4,
	[6261] = 2,
	[4231] = 4,
	[36860] = 127,
	[33823] = 1024,
	[36924] = 81,
	[43126] = 128,
	[4255] = 8,
	[6317] = 1024,
	[3164] = 1,
	[4291] = 6,
	[3172] = 1024,
	[3174] = 1024,
	[27429] = 1024,
	[6361] = 1024,
	[1081] = 1024,
	[13754] = 1024,
	[33568] = 20,
	[44853] = 1024,
	[12803] = 127,
	[12811] = 42,
	[33824] = 1024,
	[36925] = 74,
	[4375] = 16,
	[43127] = 128,
	[4387] = 16,
	[25719] = 4,
	[22682] = 14,
	[4407] = 16,
	[8831] = 35,
	[8839] = 1,
	[22794] = 35,
	[5466] = 1024,
	[5470] = 1024,
	[44854] = 1024,
	[5498] = 78,
	[8951] = 4,
	[2251] = 1024,
	[41146] = 16,
	[17056] = 4,
	[34113] = 16,
	[22203] = 8,
	[40411] = 1,
	[28437] = 8,
	[41594] = 2,
	[38557] = 4,
	[20381] = 4,
	[44855] = 1024,
	[4603] = 1024,
	[4611] = 16,
	[36927] = 81,
	[10286] = 83,
	[2321] = 14,
	[15417] = 12,
	[2325] = 6,
	[12364] = 90,
	[4655] = 1024,
	[3356] = 37,
	[3358] = 1,
	[23786] = 16,
	[19726] = 30,
	[13467] = 49,
	[3372] = 33,
	[41595] = 2,
	[38558] = 4,
	[1179] = 1024,
	[37663] = 56,
	[3390] = 4,
	[10502] = 16,
	[36928] = 64,
	[3404] = 1024,
	[10558] = 16,
	[12644] = 8,
	[28438] = 8,
	[1206] = 92,
	[18240] = 6,
	[18256] = 33,
	[13755] = 1024,
	[6889] = 1024,
	[39774] = 128,
	[12804] = 95,
	[23563] = 8,
	[27671] = 1024,
	[3466] = 8,
	[2447] = 1,
	[2449] = 1,
	[2453] = 1,
	[34052] = 114,
	[2457] = 4,
	[2459] = 12,
	[3486] = 8,
	[23787] = 16,
	[5966] = 8,
	[7005] = 16,
	[21885] = 127,
	[10998] = 32,
	[32227] = 64,
	[12037] = 1024,
	[37921] = 1,
	[36930] = 83,
	[7069] = 27,
	[17010] = 30,
	[7077] = 127,
	[7081] = 108,
	[5051] = 1024,
	[11134] = 32,
	[14227] = 22,
	[17202] = 16,
	[11174] = 32,
	[12205] = 1024,
	[38561] = 4,
	[159] = 1040,
	[8172] = 4,
	[22445] = 62,
	[22461] = 32,
	[4096] = 4,
	[9224] = 32,
	[23564] = 8,
	[22573] = 57,
	[1288] = 513,
	[15410] = 4,
	[23676] = 1024,
	[12365] = 88,
	[2589] = 538,
	[11382] = 72,
	[13444] = 32,
	[6218] = 32,
	[13468] = 3,
	[2605] = 30,
	[33447] = 1,
	[21886] = 255,
	[39681] = 16,
	[32228] = 64,
	[4232] = 4,
	[4236] = 4,
	[36932] = 65,
	[43102] = 222,
	[23117] = 65,
	[17011] = 30,
	[34055] = 36,
	[6338] = 32,
	[4304] = 30,
	[17203] = 8,
	[6358] = 1,
	[6362] = 1024,
	[2673] = 1024,
	[6370] = 33,
	[2677] = 1024,
	[39682] = 16,
	[35622] = 127,
	[4340] = 6,
	[22462] = 32,
	[3712] = 1024,
	[19441] = 512,
	[43007] = 1024,
	[39970] = 1,
	[36933] = 81,
	[43103] = 128,
	[25707] = 4,
	[34056] = 32,
	[4400] = 16,
	[4404] = 16,
	[15994] = 16,
	[6470] = 4,
	[25867] = 65,
	[5467] = 1024,
	[5471] = 1024,
	[21887] = 30,
	[39683] = 16,
	[35623] = 125,
	[37701] = 91,
	[34664] = 78,
	[6522] = 1025,
	[44958] = 1,
	[30183] = 15,
	[21024] = 1024,
	[36934] = 66,
	[43104] = 128,
	[17012] = 14,
	[34057] = 36,
	[34249] = 16,
	[28425] = 8,
	[28441] = 8,
	[3818] = 1,
	[3820] = 1,
	[12206] = 1024,
	[3824] = 79,
	[39684] = 16,
	[24477] = 1024,
	[37702] = 27,
	[31670] = 1024,
	[5635] = 9,
	[43009] = 1024,
	[36903] = 1,
	[44128] = 20,
	[3858] = 1,
	[3860] = 89,
	[2841] = 88,
	[25868] = 65,
	[22831] = 8,
	[21840] = 18,
	[31079] = 64,
	[35625] = 255,
	[37703] = 15,
	[32230] = 64,
	[43010] = 1024,
	[36904] = 1,
	[723] = 1024,
	[43106] = 128,
	[10560] = 16,
	[2901] = 16,
	[10576] = 16,
	[21153] = 1024,
	[10592] = 16,
	[12662] = 74,
	[729] = 1024,
	[730] = 1024,
	[10648] = 144,
	[731] = 1024,
	[13757] = 1024,
	[27515] = 1024,
	[1468] = 1024,
	[24478] = 64,
	[22448] = 52,
	[31671] = 1024,
	[1475] = 512,
	[43011] = 1024,
	[36905] = 1,
	[43107] = 128,
	[13893] = 1024,
	[22832] = 16,
	[34412] = 1024,
	[46784] = 1024,
	[2997] = 6,
	[44834] = 1024,
	[37705] = 61,
	[32231] = 64,
	[43012] = 1024,
	[36906] = 1,
	[11040] = 2,
	[43108] = 128,
	[7070] = 79,
	[7078] = 127,
	[40199] = 1,
	[32423] = 16,
	[24271] = 18,
	[11128] = 32,
	[11144] = 32,
	[41510] = 2,
	[11176] = 35,
	[8153] = 63,
	[1529] = 94,
	[12223] = 1024,
	[27516] = 1024,
	[8169] = 4,
	[44835] = 1024,
	[22449] = 56,
	[9210] = 2,
	[769] = 1024,
	[14341] = 6,
	[43013] = 1024,
	[27676] = 1024,
	[22577] = 1024,
	[35948] = 1024,
	[15412] = 4,
	[12359] = 121,
	[774] = 88,
	[13422] = 1,
	[22785] = 1,
	[41511] = 2,
	[21842] = 2,
	[13510] = 8,
	[783] = 4,
	[7286] = 4,
	[20963] = 64,
	[785] = 1153,
	[4233] = 4,
	[36908] = 3,
	[6291] = 1024,
	[35949] = 1024,
	[6303] = 1024,
	[12607] = 4,
	[10577] = 16,
	[24272] = 18,
	[4289] = 4,
	[6339] = 32,
	[3173] = 1024,
	[28428] = 8,
	[4305] = 6,
	[27437] = 1024,
	[6359] = 1,
	[6371] = 35,
	[39690] = 16,
	[4337] = 22,
	[41800] = 1024,
	[12799] = 88,
	[4361] = 16,
	[20500] = 4,
	[27677] = 1024,
	[22578] = 97,
	[4377] = 16,
	[39151] = 128,
	[4385] = 16,
	[4389] = 16,
	[37101] = 128,
	[39334] = 128,
	[39338] = 128,
	[39340] = 128,
	[13926] = 34,
	[43105] = 128,
	[39339] = 128,
	[23793] = 28,
	[6471] = 4,
	[6217] = 32,
	[39342] = 128,
	[10507] = 16,
	[43109] = 128,
	[5468] = 1024,
	[22572] = 32,
	[1080] = 1024,
	[43117] = 128,
	[4461] = 4,
	[28435] = 8,
	[41801] = 1024,
	[36919] = 66,
	[5500] = 46,
	[5504] = 1024,
	[22789] = 1,
	[32249] = 64,
	[818] = 88,
	[43125] = 128,
	[27503] = 8,
	[10026] = 16,
	[43122] = 128,
	[39501] = 128,
	[43124] = 128,
	[12207] = 1024,
	[16204] = 32,
	[39354] = 128,
	[39469] = 128,
	[39502] = 128,
	[24243] = 64,
	[32473] = 16,
	[47556] = 14,
	[11145] = 32,
	[28429] = 8,
	[27422] = 1024,
	[27438] = 1024,
	[11177] = 32,
	[12208] = 1024,
	[20817] = 64,
	[29548] = 4,
	[18335] = 64,
	[4589] = 2,
	[21752] = 64,
	[41802] = 1024,
	[36931] = 64,
	[41266] = 64,
	[36783] = 66,
	[18512] = 4,
	[14342] = 6,
	[20501] = 4,
	[27678] = 1024,
	[24479] = 64,
	[2318] = 30,
	[2320] = 6,
	[32229] = 64,
	[2324] = 6,
	[12360] = 90,
	[42225] = 64,
	[36926] = 64,
	[3355] = 1,
	[3357] = 1,
	[13423] = 1,
	[39341] = 128,
	[20725] = 40,
	[22787] = 1,
	[23826] = 16,
	[13463] = 1,
	[3371] = 33,
	[11130] = 32,
	[21844] = 6,
	[21884] = 127,
	[13503] = 1,
	[21881] = 2,
	[3383] = 6,
	[36929] = 65,
	[41803] = 1024,
	[3389] = 4,
	[3391] = 72,
	[36784] = 66,
	[8846] = 1,
	[25845] = 32,
	[22463] = 32,
	[3859] = 24,
	[17034] = 32,
	[23107] = 65,
	[10546] = 16,
	[1705] = 88,
	[28484] = 8,
	[5956] = 16,
	[35562] = 1024,
	[10586] = 16,
	[10978] = 32,
	[3827] = 66,
	[2772] = 32,
	[32474] = 16,
	[11084] = 32,
	[11082] = 32,
	[11083] = 96,
	[20498] = 4,
	[27439] = 1024,
	[41805] = 1024,
	[11135] = 32,
	[11175] = 32,
	[13759] = 1024,
	[7910] = 90,
	[11178] = 96,
	[23436] = 80,
	[22452] = 127,
	[16202] = 32,
	[13446] = 32,
	[22447] = 32,
	[12800] = 90,
	[12808] = 1147,
	[23571] = 127,
	[36913] = 25,
	[25649] = 4,
	[43115] = 128,
	[23427] = 32,
	[2450] = 1,
	[2452] = 1025,
	[7974] = 1024,
	[11291] = 48,
	[44501] = 16,
	[44499] = 16,
	[1210] = 88,
	[10647] = 16,
	[39343] = 128,
	[8836] = 1,
	[3470] = 8,
	[20816] = 80,
	[6530] = 16,
	[19767] = 4,
	[4363] = 16,
	[21845] = 2,
	[10938] = 32,
	[21877] = 538,
	[40769] = 16,
	[18232] = 16,
	[4357] = 16,
	[14047] = 542,
	[4364] = 16,
	[23449] = 88,
	[19943] = 1,
	[32472] = 16,
	[4368] = 16,
	[10543] = 16,
	[27674] = 1024,
	[23438] = 80,
	[43116] = 128,
	[7067] = 127,
	[6048] = 34,
	[7075] = 124,
	[7079] = 118,
	[42253] = 2,
	[41814] = 1,
	[9060] = 16,
	[814] = 16,
	[22202] = 8,
	[32475] = 16,
	[11138] = 32,
	[7191] = 16,
	[28431] = 8,
	[17194] = 1024,
	[10505] = 16,
	[8150] = 1044,
	[8154] = 4,
	[18631] = 16,
	[46793] = 1024,
	[42546] = 16,
	[8170] = 62,
	[3577] = 90,
	[41806] = 1024,
	[7387] = 16,
	[23441] = 80,
	[23437] = 80,
	[23440] = 80,
	[14343] = 32,
	[23572] = 94,
	[32478] = 16,
	[33448] = 1,
	[9260] = 1,
	[32480] = 16,
	[15414] = 4,
	[4399] = 16,
	[12361] = 88,
	[4359] = 16,
	[4371] = 16,
	[10561] = 16,
	[10559] = 16,
	[2592] = 538,
	[2594] = 1024,
	[2596] = 1024,
	[43501] = 1024,
	[16000] = 16,
	[13464] = 1,
	[2604] = 22,
	[8365] = 1024,
	[16006] = 16,
	[23439] = 80,
	[23785] = 16,
	[13512] = 8,
	[40533] = 16,
	[22829] = 16,
	[6260] = 18,
	[7287] = 4,
	[15992] = 16,
	[45087] = 14,
	[4470] = 48,
	[4234] = 30,
	[21071] = 1024,
	[23077] = 81,
	[4246] = 4,
	[43118] = 128,
	[3369] = 1,
	[28483] = 8,
	[6308] = 1024,
	[17035] = 32,
	[8171] = 4,
	[41245] = 8,
	[32428] = 14,
	[41355] = 8,
	[19774] = 8,
	[32476] = 16,
	[7909] = 120,
	[3685] = 1024,
	[28432] = 8,
	[4306] = 538,
	[3823] = 8,
	[28426] = 8,
	[2672] = 1024,
	[2674] = 1024,
	[13760] = 1024,
	[2678] = 1024,
	[12753] = 12,
	[4338] = 542,
	[4342] = 23,
	[20424] = 1024,
	[5373] = 4,
	[28440] = 8,
	[929] = 2,
	[12809] = 14,
	[23573] = 88,
	[36917] = 65,
	[12204] = 1024,
	[43119] = 128,
	[4382] = 16,
	[25699] = 4,
	[13888] = 1024,
	[4394] = 16,
	[2319] = 30,
	[4402] = 1041,
	[3731] = 1024,
	[36901] = 1,
	[7071] = 6,
	[23781] = 16,
	[25843] = 32,
	[8845] = 1,
	[12655] = 8,
	[2593] = 1024,
	[16203] = 34,
	[5465] = 1024,
	[5469] = 1024,
	[10939] = 32,
	[46796] = 1024,
	[3478] = 8,
	[41745] = 32,
	[8925] = 33,
	[41809] = 1024,
	[11137] = 98,
	[8949] = 4,
	[2835] = 88,
	[22786] = 1,
	[765] = 1,
	[27425] = 1024,
	[36918] = 113,
	[12203] = 1024,
	[43120] = 128,
	[41163] = 120,
	[23445] = 88,
	[17020] = 16,
	[118] = 1,
	[16206] = 32,
	[35128] = 88,
	[9061] = 1040,
	[15409] = 4,
	[32461] = 16,
	[22451] = 127,
	[11139] = 32,
	[7966] = 8,
	[10285] = 22,
	[17196] = 1024,
	[3819] = 33,
	[3821] = 1025,
	[14256] = 6,
	[9149] = 1,
	[46797] = 1024,
	[3829] = 58,
	[23446] = 88,
	[41520] = 2,
	[41810] = 1024,
	[10290] = 2,
	[36916] = 24,
	[5633] = 4,
	[5637] = 109,
	[14344] = 34,
	[3730] = 1024,
	[27682] = 1024,
	[27681] = 1024,
	[43121] = 128,
	[15407] = 20,
	[15415] = 4,
	[2836] = 88,
	[2838] = 88,
	[2840] = 92,
	[2842] = 88,
	[8151] = 84,
	[11371] = 88,
	[20520] = 10,
	[23782] = 17,
	[25844] = 32,
	[22791] = 33,
	[12938] = 65,
	[13465] = 1,
	[36920] = 82,
	[14044] = 4,
	[12202] = 1024,
	[37700] = 28,
	[8165] = 4,
	[35627] = 255,
	[41807] = 1024,
	[4235] = 4,
	[8152] = 68,
	[22790] = 1,
	[2880] = 24,
	[6289] = 1024,
	[10500] = 16,
	[2886] = 1024,
	[29539] = 4,
	[23079] = 81,
	[12184] = 1024,
	[5785] = 4,
	[15416] = 4,
	[2675] = 1024,
	[22644] = 1024,
	[40195] = 1,
	[4243] = 4,
	[5784] = 4,
	[37704] = 3,
	[41808] = 1024,
	[27435] = 1024,
	[10620] = 1,
	[32494] = 16,
	[3182] = 6,
	[28434] = 8,
	[7912] = 88,
	[2924] = 1024,
	[4341] = 2,
	[14048] = 6,
	[7392] = 36,
	[36907] = 1,
	[2934] = 4,
	[23447] = 72,
	[7972] = 59,
	[22456] = 127,
	[13889] = 1024,
	[15419] = 4,
	[19768] = 4,
	[4625] = 35,
	[12810] = 30,
	[34736] = 1024,
	[36921] = 81,
	[25700] = 4,
	[43123] = 128,
	[29547] = 4,
	[30816] = 1024,
	[7971] = 110,
	[3667] = 1024,
	[25708] = 4,
	[22574] = 49,
	[34054] = 106,
	[22446] = 34,
	[5503] = 1024,
	[23783] = 16,
	[8838] = 33,
	[22792] = 33,
	[27669] = 1024,
	[22824] = 40,
	[8343] = 6,
	[7082] = 119,
	[3864] = 94,
	[10940] = 32,
	[2996] = 2,
	[3575] = 89,
	[41812] = 1024,
	[21929] = 81,
	[41813] = 1024,
	[36782] = 1024,
	[18255] = 1024,
	[13758] = 1024,
	[49908] = 14,
	[22450] = 46,
	[11754] = 76,
	[36922] = 82,
	[6037] = 122,
	[23112] = 81,
	[7068] = 59,
	[7072] = 2,
	[7076] = 127,
	[7080] = 63,
	[16207] = 32,
	[4339] = 18,
	[1015] = 1024,
	[41334] = 64,
	[35624] = 127,
	[32479] = 16,
	[32495] = 16,
	[41593] = 2,
	[13756] = 1024,
}

function InvenCraftInfo:GetUseSkill(item)
	item = self:GetLinkID(item, "item")
	if item and reagentData[item] then
		s, v, n = "", "", reagentData[item] + 0
		while n > 0 do
			v = v..mod(n, 2)
			n = (n - mod(n, 2)) / 2
		end
		n = strlen(v)
		for i = 1, n do
			if strsub(v, i, i) == "1" then
				if s == "" then
					s = useSkills[i]
				else
					s = s..", "..useSkills[i]
				end
			end
		end
		return s
	end
	return nil
end

function InvenCraftInfo:GetUseSkillID(skill)
	return useSkillID[skill]
end

function InvenCraftInfo:ReturnUseTable()
	return reagentData
end