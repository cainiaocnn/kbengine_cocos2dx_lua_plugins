-- 骨骼精灵的贴图样式
ArmatureSpriteShap = {}
local t = ArmatureSpriteShap;

-- 怪物骨骼对应武器
-- hweaponattack  对应 cfg_equip中的type字段值 4,7
-- mweaponattack  对应 cfg_equip中的type字段值 2,3,6,9
-- lhweaponattack 对应 cfg_equip中的type字段值 8
-- lweaponattack  对应 cfg_equip中的type字段值 1,5
-- bowattack	  对应 cfg_equip中的type字段值 12,13,14
-- staffattack	  对应 cfg_equip中的type字段值 10,11

--****************************************************
-- 人类种族类型骨骼贴图(男)
function t:HumanChangeToClienWT(nEquipId)
	if nEquipId == 0 or nEquipId == nil then
		return 0,0;
	end
	--武器类型
	local eWeapons = CfgData["cfg_equip"][nEquipId]["type"];
	if eWeapons == 0 then
		-- 没有武器(暂时)
		return 0 , 0;
	elseif eWeapons == 4 or eWeapons == 7 then
		-- 双手剑 1
		-- 双手斧 1
		local nIndex   = CfgData["cfg_equip"][nEquipId]["weapon"];
		return 1, nIndex;
	elseif eWeapons == 2 or eWeapons == 3 or eWeapons == 6 or eWeapons == 9 then
		-- 弯刀	2
		-- 长剑	2
		-- 斧	2
		-- 锤	2	
		local nIndex   = CfgData["cfg_equip"][nEquipId]["weapon"];
		return 2, nIndex;
	elseif eWeapons == 1 or eWeapons == 5 then
		-- 短剑	3
		-- 匕首	3
		local nIndex   = CfgData["cfg_equip"][nEquipId]["weapon"];
		return 4, nIndex;
	elseif eWeapons == 10 or eWeapons == 11 then
		-- 法杖	4
		-- 手杖	4	
		local nIndex   = CfgData["cfg_equip"][nEquipId]["weapon"];
		return 6, nIndex;
	elseif eWeapons == 12 or eWeapons == 13 or eWeapons == 14 then
		-- 短弓	5
		-- 长弓	5
		local nIndex   = CfgData["cfg_equip"][nEquipId]["weapon"];
		return 5, nIndex;
	elseif eWeapons == 8 then
		-- 矛	1
		local nIndex   = CfgData["cfg_equip"][nEquipId]["weapon"];
		return 3, nIndex;
	else
		cclog("***人类种族类型骨骼贴图错误".."nEquipId="..nEquipId.." Type="..eWeapons);
	end
	return 0, 0;
end
function t:SetShowIsHumanRace(tArmatureSprite)
	local tBoneKeys = {					--骨骼对应
		Layer54 = {"human001","png"},
		Layer56 = {"human002","png"},
		Layer121 = {"human003","png"},
		Layer47 = {"human004","png"},
		Layer92 = {"human005","png"},
		Layer90 = {"human006","png"},
		Layer89 = {"human007","png"},
		Layer87 = {"human008","png"},
		Layer88 = {"human009","png"},
		Layer94 = {"human010","png"},
		Layer59 = {"human011","png"},
		Layer128 = {"human012","png"},
		Layer164 = {"human013","png"},
		Layer46 = {"human014","png"},
		Layer58 = {"human015","png"},
		Layer45 = {"human016","png"},
		Layer127 = {"human017","png"},
		Layer119 = {"human018","png"},
		Layer60 = {"human019","png"},
		Layer64 = {"human020","png"},
		Layer62 = {"human021","png"},
		Layer120 = {"human022","png"},
		Layer42 = {"human023","png"},
		Layer61 = {"human024","png"},
		Layer65 = {"human020","png"},
		Layer63 = {"human025","png"},
		Layer53 = {"human026","png"},
		Layer49 = {"human027","png"},
		Layer125 = {"human028","png"},
		Layer48 = {"human029","png"},
		Layer66 = {"human030","png"},
		Layer165 = {"human031","png"},
	};
	
	local tWeapons = {
		{"Layer160", "Hweapon0001"},
		{"Layer158", "Mweapon0001"},
		{"Layer162", "LHweapon0001"},
		{"Layer155", "Lweapon0001"},
		{"Layer152", "Bow0001"},
		{"Layer151", "Staff0001"},
	}
	--赋予人类贴图
	tArmatureSprite.tBoneKeys = tBoneKeys;
	tArmatureSprite.tWeapons = tWeapons;
end

--****************************************************
-- 人类种族(提福林)类型骨骼贴图(女)
function t:SetShowIsTiefling(tArmatureSprite)
	local tBoneKeys = {					--骨骼对应
		Layer65 = {"Tiefling001","png"},
		Layer73 = {"Tiefling002","png"},
		Layer82 = {"Tiefling003","png"},
		Layer80 = {"Tiefling004","png"},
		Layer81 = {"Tiefling005","png"},		
		Layer79 = {"Tiefling006","png"},
		Layer64 = {"Tiefling007","png"},
		Layer62 = {"Tiefling008","png"},
		Layer63 = {"Tiefling009","png"},
		Layer38 = {"Tiefling010","png"},
		Layer41 = {"Tiefling011","png"},
		Layer53 = {"Tiefling012","png"},
		Layer42 = {"Tiefling013","png"},
		Layer43 = {"Tiefling014","png"},
		Layer46 = {"Tiefling015","png"},
		Layer45 = {"Tiefling016","png"},
		Layer47 = {"Tiefling014","png"},
		Layer52 = {"Tiefling015","png"},
		Layer48 = {"Tiefling016","png"},
		Layer55 = {"Tiefling017","png"},
		Layer57 = {"Tiefling017","png"},
		Layer78 = {"Tiefling018","png"},
		Layer74 = {"Tiefling019","png"},
		Layer76 = {"Tiefling020","png"},
		Layer83 = {"Tiefling021","png"},
		Layer84 = {"Tiefling022","png"},
		Layer85 = {"Tiefling022","png"},
		Layer88 = {"Tiefling023","png"},
		Layer89 = {"Tiefling024","png"},
	};
	
	local tWeapons = {
		{"Layer93", "WHweapon0001"},
		{"Layer94","WMweapon0001"},
		{"Layer91","WLHweapon0001"},
		{"Layer129","WLweapon0001"},
		{"Layer90","WBow0001"},
		{"Layer92","WStaff0001"}
	}
	--赋予人类贴图
	tArmatureSprite.tBoneKeys = tBoneKeys;
	tArmatureSprite.tWeapons = tWeapons;
end

-- 
--****************************************************
-- 亡灵战士种族类型骨骼贴图
function t:UnDeadChangeToClienWT(nEquipId)
	-- 亡灵默认是重型武器
	-- return 1,0;
	return t:HumanChangeToClienWT(nEquipId);
end
function t:SetShowIsUnDeadRace(tArmatureSprite)
	local tBoneKeys = {					--骨骼对应
		Layer32 = {"monster001001","png"},
		Layer31 = {"monster001003","png"},
		Layer30 = {"monster001004","png"},
		Layer29 = {"monster001005","png"},
		Layer26 = {"monster001006","png"},
		Layer25 = {"monster001007","png"},
		Layer24 = {"monster001008","png"},
		Layer37 = {"monster001009","png"},
		Layer39 = {"monster001010","png"},
		Layer38 = {"monster001011","png"},
		Layer36 = {"monster001012","png"},
		Layer33 = {"monster001013","png"},
		Layer34 = {"monster001014","png"},
		Layer42 = {"monster001009","png"},
		Layer45 = {"monster001010","png"},
		Layer44 = {"monster001011","png"},
		Layer48 = {"monster001015","png"},
		Layer66 = {"monster001002","png"},
	};
	local tWeapons = {
		{"Layer66", "monster001002"},
		{nil, nil},
		{nil, nil},
		{nil, nil},
		{nil, nil},
		{"Layer66", "monster001002"},
	}
	--赋予贴图
	tArmatureSprite.tBoneKeys = tBoneKeys;
	tArmatureSprite.tWeapons = tWeapons;
end

-- 
--****************************************************
-- 哥布林种族类型骨骼贴图
function t:GoblinsChangeToClienWT(nEquipId)
	-- 哥布林默认是中型武器
	-- return 2,0;
	return t:HumanChangeToClienWT(nEquipId);
end
function t:SetShowIsGoblins(tArmatureSprite)
	local tBoneKeys = {					--骨骼对应
		Layer31 = {"monster003017","png"},
		Layer32 = {"monster003016","png"},
		Layer30 = {"monster003015","png"},
		Layer36 = {"monster003014","png"},
		Layer35 = {"monster003013","png"},
		Layer34 = {"monster003012","png"},
		Layer23 = {"monster003011","png"},
		Layer73 = {"monster003010","png"},
		Layer27 = {"monster003009","png"},
		Layer29 = {"monster003008","png"},
		Layer37 = {"monster003007","png"},
		Layer47 = {"monster003005","png"},
		Layer44 = {"monster003004","png"},
		Layer38 = {"monster003006","png"},
		Layer51 = {"monster003005","png"},
		Layer49 = {"monster003004","png"},
		Layer69 = {"monster003003","png"},
		Layer70 = {"monster003002","png"},
		Layer52 = {"monster003001","png"},
		Layer75 = {"monster003018","png"},
	};
	local tWeapons = {
		{nil, nil},
		{"Layer32", "monster003016"},
		{nil, nil},
		{nil, nil},
		{nil, nil},
		{"Layer32", "monster003016"},
	}
	--赋予贴图
	tArmatureSprite.tBoneKeys = tBoneKeys;
	tArmatureSprite.tWeapons = tWeapons;
end

-- 
--****************************************************
-- 老鼠种族类型骨骼贴图
function t:MouseChangeToClienWT(nEquipId)
	-- 老鼠默没有武器
	-- return 0,0;
	return t:HumanChangeToClienWT(nEquipId);
end
function t:SetShowIsMouse(tArmatureSprite)
	local tBoneKeys = {					--骨骼对应
		Layer41 = {"monster002001","png"},
		Layer40 = {"monster002002","png"},
		Layer25 = {"monster002003","png"},
		Layer29 = {"monster002004","png"},
		Layer23 = {"monster002005","png"},
		Layer24 = {"monster002006","png"},
		Layer32 = {"monster002007","png"},
		Layer33 = {"monster002008","png"},
		Layer34 = {"monster002009","png"},
		Layer30 = {"monster0020016","png"},
		Layer45 = {"monster0020010","png"},
		Layer44 = {"monster0020011","png"},
		Layer27 = {"monster0020012","png"},
		Layer35 = {"monster002007","png"},
		Layer36 = {"monster002008","png"},
		Layer38 = {"monster002009","png"},
		Layer42 = {"monster0020013","png"},
		Layer43 = {"monster0020014","png"},
		Layer2  = {"monster0020015","png"},
	};
	local tWeapons = {
	}
	--赋予贴图
	tArmatureSprite.tBoneKeys = tBoneKeys;
	tArmatureSprite.tWeapons = tWeapons;
end

-- 
--****************************************************
-- 蜘蛛种族类型骨骼贴图
function t:SpiderChangeToClienWT(nEquipId)
	-- 蜘蛛默没有武器
	-- return 0,0;
	return t:HumanChangeToClienWT(nEquipId);
end
function t:SetShowIsSpider(tArmatureSprite)
	local tBoneKeys = {					--骨骼对应
		Layer44 = {"monster004001","png"},
		Layer43 = {"monster004002","png"},
		Layer42 = {"monster004003","png"},
		Layer47 = {"monster004001","png"},
		Layer46 = {"monster004002","png"},
		Layer45 = {"monster004003","png"},
		Layer50 = {"monster004001","png"},
		Layer49 = {"monster004002","png"},
		Layer48 = {"monster004003","png"},
		Layer41 = {"monster004004","png"},
		Layer40 = {"monster004005","png"},
		Layer39 = {"monster004006","png"},
		Layer64 = {"monster004007","png"},
		Layer53 = {"monster004008","png"},
		Layer56 = {"monster004009","png"},
		Layer55 = {"monster004010","png"},
		Layer52 = {"monster004011","png"},
		Layer51 = {"monster004012","png"},
		Layer57  = {"monster004014","png"},
		Layer54  = {"monster004013","png"},
		Layer65  = {"monster004007","png"},
		Layer37  = {"monster004015","png"},
		Layer38  = {"monster004015","png"},
		Layer35  = {"monster004016","png"},
		Layer61  = {"monster004004","png"},
		Layer100 = {"monster004006","png"},
		Layer60  = {"monster004005","png"},
		Layer36  = {"monster004017","png"},
		Layer66  = {"monster004018","png"},
		Layer96  = {"monster004019","png"},
		
	};
	local tWeapons = {
	}
	--赋予贴图
	tArmatureSprite.tBoneKeys = tBoneKeys;
	tArmatureSprite.tWeapons = tWeapons;
end

-- 
--****************************************************
-- 元素族类型骨骼贴图
function t:ElementChangeToClienWT(nEquipId)
	-- 元素默没有武器
	-- return 0,0;
	return t:HumanChangeToClienWT(nEquipId);
end
function t:SetShowIsElement(tArmatureSprite)
	local tBoneKeys = {					--骨骼对应
		Layer26 = {"monster005002","png"},
		Layer49 = {"monster005plist001","plist"},
		Layer25 = {"monster005001","png"},
		Layer24 = {"monster005003","png"},
		Layer18 = {"monster005004","png"},
		Layer19 = {"monster005005","png"},
		Layer14 = {"monster005006","png"},
		Layer51 = {"monster005plist002","plist"},
		Layer17 = {"monster005007","png"},
		Layer50 = {"monster005plist001","plist"},
		Layer28 = {"monster005003","png"},
		Layer29 = {"monster005008","png"},
		Layer30 = {"monster005009","png"},
		Layer47 = {"monster005010","png"},		
	};
	local tWeapons = {
	}
	--赋予贴图
	tArmatureSprite.tBoneKeys = tBoneKeys;
	tArmatureSprite.tWeapons = tWeapons;
end

-- 
--****************************************************
-- 烂泥怪族类型骨骼贴图
function t:MudChangeToClienWT(nEquipId)
	-- 烂泥怪默没有武器
	-- return 0,0;
	return t:HumanChangeToClienWT(nEquipId);
end
function t:SetShowIsMud(tArmatureSprite)
	local tBoneKeys = {					--骨骼对应
		Layer17 = {"monster007001","png"},
		Layer20 = {"monster007002","png"},
		Layer22 = {"monster007003","png"},
		Layer15 = {"monster007004","png"},
		Layer14 = {"monster007005","png"},
		Layer21 = {"monster007006","png"},
		Layer12 = {"monster007007","png"},
		Layer10 = {"monster007008","png"},
	};
	local tWeapons = {
	}
	--赋予贴图
	tArmatureSprite.tBoneKeys = tBoneKeys;
	tArmatureSprite.tWeapons = tWeapons;
end

-- 
--****************************************************
--牛头人种族类型骨骼贴图
function t:TaurenChangeToClienWT(nEquipId)
	-- 蜘蛛默没有武器
	-- return 0,0;
	return t:HumanChangeToClienWT(nEquipId);
end
function t:SetShowIsTauren(tArmatureSprite)
	local tBoneKeys = {					--骨骼对应
		Layer_1 = {"monsterbone009001","png"},
		Layer_2 = {"monsterbone009002","png"},
		Layer_3 = {"monsterbone009003","png"},
		Layer_4 = {"monsterbone009004","png"},
		Layer_5 = {"monsterbone009005","png"},
		-- Layer_6 = {"monsterbone009020","png"},
		Layer_7 = {"monsterbone009006","png"},
		Layer_8 = {"monsterbone009007","png"},
		Layer_9 = {"monsterbone009008","png"},
		Layer_10 = {"monsterbone009009","png"},
		Layer_11 = {"monsterbone009010","png"},
		Layer_12 = {"monsterbone009011","png"},
		Layer_13 = {"monsterbone009012","png"},
		Layer_14 = {"monsterbone009013","png"},
		Layer_15 = {"monsterbone009014","png"},
		Layer_16 = {"monsterbone009015","png"},
		Layer_17 = {"monsterbone009016","png"},
		Layer_18 = {"monsterbone009017","png"},
		Layer_19 = {"monsterbone009018","png"},
		Layer_20 = {"monsterbone009019","png"},
	};
	local tWeapons = {
	}
	--赋予贴图
	tArmatureSprite.tBoneKeys = tBoneKeys;
	tArmatureSprite.tWeapons = tWeapons;
end

-- 
--****************************************************
--蛇怪种族类型骨骼贴图
function t:SnakeChangeToClienWT(nEquipId)
	-- return 0,0;
	return t:HumanChangeToClienWT(nEquipId);
end
function t:SetShowIsSnake(tArmatureSprite)
	local tBoneKeys = {					--骨骼对应
		Layer_1 = {"monsterbone008001","png"},
		Layer_2 = {"monsterbone008012","png"},
		Layer_3 = {"monsterbone008017","png"},
		Layer_4 = {"monsterbone008018","png"},
		Layer_5 = {"monsterbone008019","png"},
		Layer_6 = {"monsterbone008020","png"},
		Layer_7 = {"monsterbone008021","png"},
		Layer_8 = {"monsterbone008022","png"},
		Layer_9 = {"monsterbone008023","png"},
		Layer_10 = {"monsterbone008002","png"},
		Layer_11 = {"monsterbone008003","png"},
		Layer_12 = {"monsterbone008004","png"},
		Layer_13 = {"monsterbone008005","png"},
		Layer_14 = {"monsterbone008006","png"},
		Layer_15 = {"monsterbone008007","png"},
		Layer_16 = {"monsterbone008008","png"},
		Layer_17 = {"monsterbone008009","png"},
		Layer_18 = {"monsterbone008010","png"},
		Layer_19 = {"monsterbone008011","png"},
		Layer_20 = {"monsterbone008013","png"},
		Layer_21 = {"monsterbone008014","png"},
		Layer_22 = {"monsterbone008015","png"},
		Layer_23 = {"monsterbone008016","png"},
		Layer_24 = {"monsterbone008024","png"},
	};
	local tWeapons = {
	}
	--赋予贴图
	tArmatureSprite.tBoneKeys = tBoneKeys;
	tArmatureSprite.tWeapons = tWeapons;
end

-- 
--****************************************************
--巨魔种族类型骨骼贴图
function t:TrollChangeToClienWT(nEquipId)
	-- return 0,0;
	return t:HumanChangeToClienWT(nEquipId);
end
function t:SetShowIsTroll(tArmatureSprite)
	local tBoneKeys = {					--骨骼对应
		Layer_9 = {"monsterbone011015","png"},
		Layer_32 = {"monsterbone011011","png"},
		Layer_11 = {"monsterbone011016","png"},
		Layer_12 = {"monsterbone011012","png"},
		Layer_13 = {"monsterbone011013","png"},
		Layer_14 = {"monsterbone011001","png"},
		Layer_15 = {"monsterbone011014","png"},
		Layer_31 = {"monsterbone011015","png"},
		Layer_33 = {"monsterbone011016","png"},
		Layer_16 = {"monsterbone011017","png"},
		Layer_17 = {"monsterbone011018","png"},
		Layer_18 = {"monsterbone011019","png"},
		Layer_19 = {"monsterbone011020","png"},
		Layer_20 = {"monsterbone011002","png"},
		Layer_21 = {"monsterbone011003","png"},
		Layer_22 = {"monsterbone011004","png"},
		Layer_23 = {"monsterbone011005","png"},
		Layer_24 = {"monsterbone011006","png"},
		Layer_25 = {"monsterbone011007","png"},
		Layer_26 = {"monsterbone011008","png"},
		Layer_27 = {"monsterbone011009","png"},
		Layer_28 = {"monsterbone011010","png"},
	};
	
	local tWeapons = {
	}
	--赋予贴图
	tArmatureSprite.tBoneKeys = tBoneKeys;
	tArmatureSprite.tWeapons = tWeapons;
end

-- 
--****************************************************
--龙种族类型骨骼贴图
function t:DragonChangeToClienWT(nEquipId)
	-- return 0,0;
	return t:HumanChangeToClienWT(nEquipId);
end
function t:SetShowIsDragon(tArmatureSprite)
	local tBoneKeys = {					--骨骼对应
		Layer_29 = {"monsterbone015030","png"},
		Layer_30 = {"monsterbone015041","png"},
		Layer_31 = {"monsterbone015051","png"},
		Layer_32 = {"monsterbone015052","png"},
		Layer_33 = {"monsterbone015053","png"},
		Layer_34 = {"monsterbone015054","png"},
		Layer_35 = {"monsterbone015055","png"},
		Layer_36 = {"monsterbone015056","png"},
		Layer_37 = {"monsterbone015057","png"},
		Layer_38 = {"monsterbone015031","png"},
		Layer_39 = {"monsterbone015032","png"},
		Layer_40 = {"monsterbone015033","png"},
		Layer_41 = {"monsterbone015034","png"},
		Layer_42 = {"monsterbone015035","png"},
		Layer_43 = {"monsterbone015036","png"},
		Layer_44 = {"monsterbone015037","png"},
		Layer_45 = {"monsterbone015038","png"},
		Layer_46 = {"monsterbone015039","png"},
		Layer_47 = {"monsterbone015040","png"},
		Layer_48 = {"monsterbone015042","png"},
		Layer_49 = {"monsterbone015043","png"},
		Layer_50 = {"monsterbone015044","png"},
		Layer_51 = {"monsterbone015045","png"},
		Layer_52 = {"monsterbone015046","png"},
		Layer_53 = {"monsterbone015047","png"},
		Layer_54 = {"monsterbone015048","png"},
		Layer_55 = {"monsterbone015049","png"},
		Layer_56 = {"monsterbone015050","png"},
	};
	
	local tWeapons = {
	}
	--赋予贴图
	tArmatureSprite.tBoneKeys = tBoneKeys;
	tArmatureSprite.tWeapons = tWeapons;
end

-- 
--****************************************************
--女妖族类型骨骼贴图
function t:BansheeChangeToClienWT(nEquipId)
	-- return 0,0;
	return t:HumanChangeToClienWT(nEquipId);
end
function t:SetShowIsBanshee(tArmatureSprite)
	local tBoneKeys = {					--骨骼对应
		Layer_30 = {"monsterbone010001","png"},
		Layer_31 = {"monsterbone010008","png"},
		Layer_32 = {"monsterbone010022","png"},
		Layer_33 = {"monsterbone010029","png"},
		Layer_34 = {"monsterbone010006","png"},
		Layer_35 = {"monsterbone010027","png"},
		Layer_36 = {"monsterbone010028","png"},
		Layer_37 = {"monsterbone010007","png"},
		Layer_38 = {"monsterbone010005","png"},
		Layer_39 = {"monsterbone010025","png"},
		Layer_40 = {"monsterbone010010","png"},
		Layer_41 = {"monsterbone010021","png"},
		Layer_42 = {"monsterbone010024","png"},
		Layer_44 = {"monsterbone010014","png"},
		Layer_45 = {"monsterbone010012","png"},
		Layer_46 = {"monsterbone010015","png"},
		Layer_49 = {"monsterbone010020","png"},
		Layer_47 = {"monsterbone010013","png"},
		Layer_48 = {"monsterbone010016","png"},
		Layer_43 = {"monsterbone010011","png"},
		Layer_50 = {"monsterbone010019","png"},
		Layer_51 = {"monsterbone010018","png"},
		Layer_52 = {"monsterbone010017","png"},
		Layer_53 = {"monsterbone010009","png"},
		Layer_54 = {"monsterbone010023","png"},
		Layer_55 = {"monsterbone010004","png"},
		Layer_56 = {"monsterbone010030","png"},
		Layer_57 = {"monsterbone010002","png"},
		Layer_58 = {"monsterbone010003","png"},
	};
	
	local tWeapons = {
	}
	--赋予贴图
	tArmatureSprite.tBoneKeys = tBoneKeys;
	tArmatureSprite.tWeapons = tWeapons;
end

-- 
--****************************************************
--恶魔族类型骨骼贴图
function t:DevilChangeToClienWT(nEquipId)
	-- return 0,0;
	return t:HumanChangeToClienWT(nEquipId);
end
function t:SetShowIsDevil(tArmatureSprite)
	local tBoneKeys = {					--骨骼对应
		namibe_1 = {"monsterbone013050","png"},
		namibe_2 = {"monsterbone013051","png"},
		namibe_3 = {"monsterbone013045","png"},
		namibe_4 = {"monsterbone013027","png"},
		namibe_5 = {"monsterbone013038","png"},
		namibe_6 = {"monsterbone013046","png"},
		namibe_7 = {"monsterbone013047","png"},
		namibe_8 = {"monsterbone013048","png"},
		namibe_9 = {"monsterbone013049","png"},
		namibe_10 = {"monsterbone013050","png"},
		namibe_11 = {"monsterbone013051","png"},
		namibe_12 = {"monsterbone013052","png"},
		namibe_13 = {"monsterbone013028","png"},
		namibe_14 = {"monsterbone013029","png"},
		namibe_15 = {"monsterbone013030","png"},
		namibe_16 = {"monsterbone013031","png"},
		namibe_17 = {"monsterbone013032","png"},
		namibe_18 = {"monsterbone013033","png"},
		namibe_19 = {"monsterbone013034","png"},
		namibe_20 = {"monsterbone013035","png"},
		namibe_21 = {"monsterbone013036","png"},
		namibe_22 = {"monsterbone013037","png"},
		namibe_23 = {"monsterbone013039","png"},
		namibe_24 = {"monsterbone013040","png"},
		namibe_25 = {"monsterbone013041","png"},
		namibe_26 = {"monsterbone013042","png"},
		namibe_27 = {"monsterbone013043","png"},
		namibe_28 = {"monsterbone013044","png"},
		
	};
	
	local tWeapons = {
	}
	--赋予贴图
	tArmatureSprite.tBoneKeys = tBoneKeys;
	tArmatureSprite.tWeapons = tWeapons;
end


-- 
--****************************************************
--邪神骨骼贴图
function t:DaalChangeToClienWT(nEquipId)
	return 6, 0;
end
function t:SetShowIsDaal(tArmatureSprite)
	local tBoneKeys = {					--骨骼对应
		Layer141 = {"monster016plist001","plist"},
		Layer56 = {"monster016001","png"},
		Layer59 = {"monster016002","png"},
		Layer55 = {"monster016003","png"},
		Layer44 = {"monster016004","png"},
		Layer45 = {"monster016005","png"},
		Layer43 = {"monster016006","png"},
		Layer42 = {"monster016007","png"},
		Layer51 = {"monster016008","png"},
		Layer54 = {"monster016009","png"},
		Layer41 = {"monster016010","png"},
		Layer79 = {"monster016011","png"},
		Layer80 = {"monster016012","png"},
		Layer82 = {"monster016013","png"},
		Layer86 = {"monster016014","png"},
		Layer87 = {"monster016015","png"},
		Layer88 = {"monster016016","png"},
		Layer64 = {"monster016017","png"},
		Layer66 = {"monster016018","png"},
		Layer71 = {"monster016019","png"},
		Layer40 = {"monster016020","png"},
		Layer137 = {"monster016021","png"},
		Layer136 = {"monster016021","png"},
		Layer135 = {"monster016021","png"},
		Layer96 = {"monster016022","png"},
		Layer79 = {"monster016023","png"},
		Layer72 = {"monster016017","png"},
		Layer76 = {"monster016018","png"},
		Layer77 = {"monster016019","png"},
		Layer95 = {"monster016024","png"},
		Layer46 = {"monster016025","png"},
		Layer48 = {"monster016026","png"},
		Layer49 = {"monster016027","png"},
		Layer50 = {"monster016028","png"},
		Layer98 = {"monster016029","png"},
		Layer64 = {"monster016002","png"},
		Layer60 = {"monster016003","png"},
		Layer61 = {"monster016001","png"},
		Layer133 = {"monster016030","png"},
	};
	
	local tWeapons = {
	}
	--赋予贴图
	tArmatureSprite.tBoneKeys = tBoneKeys;
	tArmatureSprite.tWeapons = tWeapons;
end


--一魔女
function t:WingSirenChangeToClienWT(nEquipId)
	return 3, 0;
end
function t:SetShowIsWingSiren(tArmatureSprite)
	local tBoneKeys = {					--骨骼对应
		Layer48 = {"monster012001","png"},
		Layer37 = {"monster012002","png"},
		Layer36 = {"monster012003","png"},
		Layer69 = {"monster012004","png"},
		Layer71 = {"monster012005","png"},
		Layer70 = {"monster012006","png"},
		Layer74 = {"monster012007","png"},
		Layer77 = {"monster012008","png"},
		Layer73 = {"monster012009","png"},
		Layer33 = {"monster012010","png"},
		Layer35 = {"monster012011","png"},
		Layer34 = {"monster012012","png"},
		Layer80 = {"monster012013","png"},
		Layer81 = {"monster012014","png"},
		Layer82 = {"monster012015","png"},
		Layer75 = {"monster012016","png"},
		Layer85 = {"monster012017","png"},
		Layer84 = {"monster012018","png"},
		Layer83 = {"monster012019","png"},
		Layer68 = {"monster012005","png"},
		Layer66 = {"monster012004","png"},
		Layer67 = {"monster012006","png"},
		Layer50 = {"monster012003","png"},
		Layer55 = {"monster012020","png"},
		Layer51 = {"monster012002","png"},
		Layer79 = {"monster012021","png"},
		Layer63 = {"monster012022","png"},
		Layer78 = {"monster012023","png"},
		Layer86 = {"monster012024","png"},
	};
	
	local tWeapons = {
	}
	--赋予贴图
	tArmatureSprite.tBoneKeys = tBoneKeys;
	tArmatureSprite.tWeapons = tWeapons;
end


--铠甲战士
function t:ArmorWarriorChangeToClienWT(nEquipId)
	return 3, 0;
end
function t:SetShowIsArmorWarrior(tArmatureSprite)
	local tBoneKeys = {					--骨骼对应
		Layer28 = {"monster006001","png"},
		Layer26 = {"monster006002","png"},
		Layer21 = {"monster006003","png"},
		Layer20 = {"monster006004","png"},
		Layer22 = {"monster006005","png"},
		Layer18 = {"monster006006","png"},
		Layer16 = {"monster006007","png"},
		Layer24 = {"monster006003","png"},
		Layer23 = {"monster006004","png"},
		Layer25 = {"monster006005","png"},
		Layer29 = {"monster006008","png"},
		Layer30 = {"monster006009","png"},
		Layer31 = {"monster006010","png"},
		Layer33 = {"monster006011","png"},
	};
	
	local tWeapons = {
	}
	--赋予贴图
	tArmatureSprite.tBoneKeys = tBoneKeys;
	tArmatureSprite.tWeapons = tWeapons;
end

