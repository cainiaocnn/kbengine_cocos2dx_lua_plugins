-- 为了游戏能够顺畅的进行表现
-- 异步加载技能骨骼动画

--需要加载的骨骼技能分布在(SceneSkillEffectPool,SkillDoReleaseBefore,SpriteSkillBufferPool)文件

SkillResourcesLoad = {};
local t = SkillResourcesLoad;


-- 配置

-- 已经加载完成的骨骼数据队列
local tHaveFinishLoadArmature = {};
local tHaveFinishLoadArmatureHero = {};
-- 资源存储时间戳
local tHaveFinishLoadKeyStr   = {}

--账号注销回调函数
function t.gameLoginOut()
	tHaveFinishLoadArmature = {};
	tHaveFinishLoadArmatureHero = {};
	-- 资源存储时间戳
	tHaveFinishLoadKeyStr   = {}
end

-- 异步需要加载的技能
-- "RES_"+"SkillId"
local tSkillArmatureResource = {

	-- 普通技能特效
	----------------------------------------------------------------
	--闪避	Effectdodge
	
	--格挡	Effectparry
	
	--暴击	Effectcritstrike
		
	--眩晕
	
	----------------------------------------------------------------
	
	--狂战士(狂暴旋风)
	RES_10360 = {
		{"EffectViolentcyclone","EffectViolentcyclone", ".ExportJson"},
	},	
	
	--狂战士(狂暴之心)
	RES_10380 = {
		{"Effectheartoffury","Effectheartoffury", ".ExportJson"},
		{"Effectheartoffury","Effectheartoffuryplist001", ".plist"},
		{"Effectheartoffury","Effectheartoffuryplist002", ".plist"},
		{"Effectheartoffury","Effectheartoffuryplist003", ".plist"},
		{"Effectheartoffury","Effectheartoffuryplist004", ".plist"},
		{"Effectfuryattack","Effectfuryattack", ".ExportJson"},
		{"Effectfuryattack","Effectfuryattackplist", ".plist"},
	},
	
	--狂暴之心(清)
	RES_11160 = {
		{"Effectheartoffury","Effectheartoffury", ".ExportJson"},
		{"Effectheartoffury","Effectheartoffuryplist001", ".plist"},
		{"Effectheartoffury","Effectheartoffuryplist002", ".plist"},
		{"Effectheartoffury","Effectheartoffuryplist003", ".plist"},
		{"Effectheartoffury","Effectheartoffuryplist004", ".plist"},
		{"Effectfuryattack","Effectfuryattack", ".ExportJson"},
		{"Effectfuryattack","Effectfuryattackplist", ".plist"},
	},
	
	--狂战士(孤注一掷)
	RES_10390 = {
		{"Effectgzyz","Effectgzyz", ".ExportJson"},
		{"Effectgzyz","Effectgzyzplist001", ".plist"},
		{"Effectgzyz","Effectgzyzplist002", ".plist"}
	},	

	--狂战士(逆差攻击)(增强)
	RES_10410 = {
		{"EffectDeficitattack","EffectDeficitattack", ".ExportJson"},
		{"EffectDeficitattack","EffectDeficitattack001", ".plist"},
		{"EffectDeficitattack","EffectDeficitattack002", ".plist"},
		{"EffectDeficitattack","EffectDeficitattack003", ".plist"},
	},
	
	--刺客(暗影斗篷)
	RES_10840 = {
		{"EffectCloakofShadows","EffectCloakofShadows", ".ExportJson"},
		{"EffectCloakofShadows","Effectassassinplist001", ".plist"}
	},
	
	--刺客(异域毒刃)
	RES_10850 = {
		{"Effectreleaseskill", "Effectreleaseskill", ".ExportJson"},
		{"EffectExoticShiv", "EffectExoticShiv", ".ExportJson"},
		{"EffectExoticShiv", "Effectassassinplist002", ".plist"}
	},
	
	--刺客(背刺)
	RES_10860 = {
		{"Effectreleaseskill", "Effectreleaseskill", ".ExportJson"},
		{"EffectStabintheback", "EffectStabintheback", ".ExportJson"},
		{"EffectStabinthebackblow","EffectStabinthebackblow", ".ExportJson"},
		{"EffectStabinthebackblow","Effectassassinplist004", ".plist"}
	},
	
	--刺客(毒雾喷射)	
	RES_10880 = {
		{"EffectPoisoninjection","EffectPoisoninjection",".ExportJson"},
		{"EffectPoisoninjection","Effectassassinplist003",".plist"},
		{"EffectPoisoninjection","Effectassassinplist005",".plist"},
		{"EffectPoisoninjection","Effectassassinplist006",".plist"}
	},
	
	--刺客(暗影之刺)	
	RES_10890 = {
		{"EffectShadowthorn","EffectShadowthorn", ".ExportJson"},
		{"EffectShadowthorn","Effectassassinplist007", ".plist"},
		{"EffectShadowthorn","Effectassassinplist008", ".plist"}
	},
	
	--领主(眩晕攻击)
	RES_11020 = {
		{"EffectVertigoattack","EffectVertigoattack", ".ExportJson"},
		{"EffectVertigoattack","Effectlordplist001", ".plist"},
		{"EffectVertigoattack","Effectlordplist002", ".plist"}
	},
	
	--领主(集火号角)	
	RES_11050 = {
		{"Effectreleaseskill","Effectreleaseskill",".ExportJson"},
		{"EffectDownthehorn","EffectDownthehorn",".ExportJson"},
		{"EffectDownthehorn","Effectlordplist004",".plist"}
	},
	
	--领主(灵魂震慑)	
	RES_11060 = {
		{"Effectreleaseskill","Effectreleaseskill",".ExportJson"},
		{"EffectSoulshock","EffectSoulshock",".ExportJson"},
		{"EffectSoulshock","Effectlordplist005",".plist"},
		{"EffectSoulshock","Effectlordplist006",".plist"}
	},	
	
	--魔战士(内视)
	RES_10960 = {
		{"Effectreleaseskill","Effectreleaseskill",".ExportJson"},
		{"Effectinwardvision","Effectinwardvision",".ExportJson"},
		{"Effectinwardvision","Effectclownplist001",".plist"}
	},
	
	--魔战士(算术)
	RES_10970 = {
		{"Effectreleaseskill","Effectreleaseskill",".ExportJson"},
		{"EffectArithmetic","EffectArithmetic",".ExportJson"},
		{"EffectArithmetic","Effectclownplist002",".plist"},
		{"EffectArithmetic","Effectclownplist003",".plist"},
		{"EffectArithmetic","Effectclownplist004",".plist"},
		{"EffectArithmetic","Effectclownplist005",".plist"},
	},
	
	--魔战士(乱数)
	RES_11000 = {
		{"EffectRandomnumber001","EffectRandomnumber001",".ExportJson"},
		{"EffectRandomnumber001","Effectclownplist001",".plist"},
		{"EffectRandomnumber002","EffectRandomnumber002",".ExportJson"},
		{"EffectRandomnumber002","Effectclownplist001",".plist"},
		{"EffectRandomnumber003","EffectRandomnumber003",".ExportJson"},
		{"EffectRandomnumber003","Effectclownplist001",".plist"},
		{"EffectRandomnumberblow","EffectRandomnumberblow",".ExportJson"},
		{"EffectRandomnumberblow","Effectclownplist001",".plist"},
		{"EffectRandomnumberblow","Effectclownplist006",".plist"},
	},
	
	--魔战士(真实视觉)
	RES_11010 = {
		{"Effectreleaseskill","Effectreleaseskill",".ExportJson"},
		{"EffectTruesight","EffectTruesight",".ExportJson"},
		{"EffectTruesight","Effectclownplist007",".plist"},
		{"EffectTruesight","Effectclownplist008",".plist"},
	},
	
	--审判(审判之怒)
	RES_10790 = {
		{"EffectTrialByFury","EffectTrialByFury",".ExportJson"},
		{"EffectTrialByFury","EffectInquisitorplist001",".plist"},
	},
	
	--审判(破甲攻击)
	RES_10780 = {
		{"EffectSunderArmor","EffectSunderArmor",".ExportJson"},
		{"EffectSunderArmor","EffectInquisitorplist002",".plist"}
	},
	
	--审判(力之审判)
	RES_10800 = {
		{"Effectreleaseskill","Effectreleaseskill",".ExportJson"},
		{"EffectPowerofthetrial","EffectPowerofthetrial",".ExportJson"},
		{"EffectPowerofthetrial","EffectInquisitorplist002",".plist"},
		{"EffectPowerofthetrial","EffectInquisitorplist003",".plist"},
		{"EffectPowerofthetrial","EffectInquisitorplist004",".plist"},
		{"EffectPowerofthetrial","EffectInquisitorplist005",".plist"},
		
	},
	
	--审判(裁决之光)
	RES_10820 = {
		{"Effectreleaseskill","Effectreleaseskill",".ExportJson"},
		{"EffectThedecisionofthelight","EffectThedecisionofthelight",".ExportJson"},
		{"EffectThedecisionofthelight","EffectInquisitorplist003",".plist"},
		{"EffectThedecisionofthelight","EffectInquisitorplist005",".plist"},
		{"EffectThedecisionofthelight","EffectInquisitorplist006",".plist"},
	},
	
	--守望者(螺旋冲击)
	RES_10480 = {
		{"Effectreleaseskill","Effectreleaseskill",".ExportJson"}, 
		{"Effectspiralshock", "Effectspiralshock", ".ExportJson"},
		{"Effectspiralshock", "EffectGuardianplist001", ".plist"},
		{"Effectspiralshock", "EffectGuardianplist002", ".plist"},
		{"EffectGuardianblow", "EffectGuardianblow", ".ExportJson"},
		{"EffectGuardianblow", "EffectGuardianplist006", ".plist"},
	},
		
	--守望者(削弱攻击)
	RES_10490 = {
		{"Effectweakenattack", "Effectweakenattack", ".ExportJson"},
		{"Effectweakenattack", "EffectGuardianplist003", ".plist"},
		{"Effectweakenattack02", "Effectweakenattack02", ".ExportJson"},
		{"Effectweakenattack02", "EffectGuardianplist005", ".plist"},
		{"EffectGuardianblow", "EffectGuardianblow" , ".ExportJson"},
		{"EffectGuardianblow", "EffectGuardianplist006" , ".plist"},
	},
	
	--守望者(防御姿态)
	RES_10520 = {
		{"EffectDefensivestance", "EffectDefensivestance", ".ExportJson"},
		{"EffectDefensivestance", "EffectGuardianplist003", ".plist"},
	},
	
	--守望者(寓攻于守)
	RES_10530 = {
		{"Effectyugongyushou", "Effectyugongyushou", ".ExportJson"},
		{"Effectyugongyushou", "EffectGuardianplist004", ".plist"},
	},
	
	--死亡骑士(瘟疫之触)
	RES_10420 = {
		{"Effectreleaseskill","Effectreleaseskill",".ExportJson"}, 
		{"EffectPlaguetouch", "EffectPlaguetouch", ".ExportJson"},
		{"EffectPlaguetouchblow", "EffectPlaguetouchblow", ".ExportJson"},
		{"EffectPlaguetouchblow", "EffectPlaguetouchblowplist", ".plist"},
	},
	
	--死亡骑士(吸血)
	RES_10430 = {
		{"Effectsuckblood", "Effectsuckblood", ".ExportJson"},
		{"Effectsuckblood", "Effectsuckbloodplist001", ".plist"},
		{"Effectsuckbloodblow", "Effectsuckbloodblow", ".ExportJson"},
		{"Effectsuckbloodblow", "Effectsuckbloodplist002", ".plist"},
		{"Effectsuckbloodblow", "Effectsuckbloodplist003", ".plist"},		
	},
	
	--死亡骑士(死亡霜寒)
	RES_10460 = {
		{"EffectThedeathofthefrost", "EffectThedeathofthefrost", ".ExportJson"},
		{"EffectThedeathofthefrost", "EffectThedeathofthefrost001", ".plist"},
		{"EffectThedeathofthefrost", "EffectThedeathofthefrost002", ".plist"},
		{"EffectThedeathofthefrostblow", "EffectThedeathofthefrostblow", ".ExportJson"},
		{"EffectThedeathofthefrostblow", "EffectThedeathofthefrost003", ".plist"},
		{"EffectThedeathofthefrostblow", "EffectThedeathofthefrost004", ".plist"},
	},
	
	--死亡骑士(吸血鬼之触)
	RES_10470 = {
		{"Effectreleaseskill","Effectreleaseskill",".ExportJson"},
		{"EffectVampiricTouch", "EffectVampiricTouch", ".ExportJson"},
		{"EffectVampiricTouch", "EffectVampiricTouchplist001", ".plist"},
		{"EffectVampiricTouch", "EffectVampiricTouchplist002", ".plist"},
		{"Effectsuckbloodblow", "Effectsuckbloodblow", ".ExportJson"},
		{"Effectsuckbloodblow", "Effectsuckbloodplist002", ".plist"},
		{"Effectsuckbloodblow", "Effectsuckbloodplist003", ".plist"},
	},
	
	--游侠(暗影闪击)
	RES_10900 = {
		{"EffectShadowstrike", "EffectShadowstrike", ".ExportJson"},
		{"EffectShadowstrike", "Effectrangerplist001", ".plist"},
		{"EffectShadowstrike", "Effectrangerplist002", ".plist"},
		{"Effectrangerblow", "Effectrangerblow", ".ExportJson"},
		{"Effectrangerblow", "Effectrangerplist003", ".plist"},
	},
	
	--游侠(灵巧连击)
	RES_10910 = {
		{"EffectSmartbatter001", "EffectSmartbatter001", ".ExportJson"},
		{"EffectSmartbatter001", "Effectrangerplist003", ".plist"},
		{"EffectSmartbatter001", "Effectrangerplist004", ".plist"},
		{"EffectSmartbatter002", "EffectSmartbatter002", ".ExportJson"},
		{"EffectSmartbatter002", "Effectrangerplist004", ".plist"},
	},
	
	--游侠(死亡之舞)
	RES_10950 = {
		{"EffectDanceOfTheDead001", "EffectDanceOfTheDead001", ".ExportJson"},
		{"EffectDanceOfTheDead001", "Effectrangerplist003", ".plist"},
		{"EffectDanceOfTheDead001", "Effectrangerplist005", ".plist"},
		{"EffectDanceOfTheDead002", "EffectDanceOfTheDead002", ".ExportJson"},
		{"EffectDanceOfTheDead002", "Effectrangerplist005", ".plist"},
	},
	
	--占星术士(炽焰之星)
	RES_10600 = {
		{"Effectreleaseskill","Effectreleaseskill",".ExportJson"}, 
		{"EffectBlazingstar","EffectBlazingstar",".ExportJson"}, 
		{"EffectBlazingstar","Effectastrologerplist001",".plist"}, 
		{"EffectBlazingstar","Effectastrologerplist002",".plist"}, 
	},
	
	--占星术士(蓄力攻击)
	RES_10610 = {
		{"EffectPactrometerattack001", "EffectPactrometerattack001", ".ExportJson"},
		{"EffectPactrometerattack002", "EffectPactrometerattack002", ".ExportJson"},
		{"EffectPactrometerattack002", "Effectastrologerplist005", ".plist"},
		{"EffectPactrometerattackblow", "EffectPactrometerattackblow", ".ExportJson"},
		{"EffectPactrometerattackblow", "Effectastrologerplist006", ".plist"},
	},
	
	--占星术士(火焰护盾)
	RES_10620 = {
		{"EffectFireshield", "EffectFireshield", ".ExportJson"},
		{"EffectFireshield", "Effectastrologerplist007", ".plist"},
	},
	
	--占星术士(不息之炎)
	RES_10630 = {
		{"EffectEndlessinflammation", "EffectEndlessinflammation", ".ExportJson"},
		{"EffectEndlessinflammation", "Effectastrologerplist008", ".plist"},
		{"EffectEndlessinflammation", "Effectastrologerplist009", ".plist"},
	},
	
	--占星术士(烈焰风暴)
	RES_10640 = {
		{"Effectreleaseskill","Effectreleaseskill",".ExportJson"}, 
		{"EffectFlamestrike001", "EffectFlamestrike001", ".ExportJson"},
		{"EffectFlamestrike001", "Effectastrologerplist010", ".plist"},
		{"EffectFlamestrike001", "Effectastrologerplist011", ".plist"},
		{"EffectFlamestrike001", "Effectastrologerplist012", ".plist"},
		{"EffectFlamestrike002", "EffectFlamestrike002", ".ExportJson"},
		{"EffectFlamestrike002", "Effectastrologerplist013", ".plist"},
		{"EffectFlamestrike002", "Effectastrologerplist014", ".plist"},
		{"EffectFlamestrike002", "Effectastrologerplist015", ".plist"},
	},
	
	--主教(洗礼)
	RES_10720 = {
		{"Effectreleaseskill","Effectreleaseskill",".ExportJson"}, 
	},
	
	--主教(消退)
	RES_10730 = {
		{"Effectreleaseskill","Effectreleaseskill",".ExportJson"}, 
		{"Effectdispel", "Effectdispel", ".ExportJson"},
		{"Effectdispel", "Effectbishopplist005", ".plist"},
	},
	
	--主教(无罪之手)
	RES_10740 = {
		{"Effectreleaseskill","Effectreleaseskill",".ExportJson"}, 
		{"EffectTheinnocenthands", "EffectTheinnocenthands", ".ExportJson"},
		{"EffectTheinnocenthands", "Effectbishopplist003", ".plist"},
		{"EffectTheinnocenthands", "Effectbishopplist004", ".plist"},
		{"Effectbishopblow", "Effectbishopblow", ".ExportJson"},
		{"Effectbishopblow", "Effectbishopplist006", ".plist"},
	},
	
	--主教(圣言)
	RES_10770 = {
		{"Effectreleaseskill","Effectreleaseskill",".ExportJson"}, 
		{"Effectoracle", "Effectoracle", ".ExportJson"},
		{"Effectoracle", "Effectbishopplist009", ".plist"},
		{"Effectoracle", "Effectbishopplist010", ".plist"},
	},
	
	--圣骑士(虔诚光环)
	RES_10540 = {
		{"Effectpaladinreleaseskill", "Effectpaladinreleaseskill", ".ExportJson"},
		{"Effectpaladinreleaseskill", "Effectpaladinplist001", ".plist"},
		{"Effectpaladinreleaseskill", "Effectpaladinplist002", ".plist"},
		
		{"Effectpaladinblow001", "Effectpaladinblow001", ".ExportJson"},
		{"Effectpaladinblow001", "Effectpaladinplist005", ".plist"},
	},
	
	--圣骑士(专注光环)
	RES_10550 = {
		{"Effectpaladinreleaseskill", "Effectpaladinreleaseskill", ".ExportJson"},
		{"Effectpaladinreleaseskill", "Effectpaladinplist001", ".plist"},
		{"Effectpaladinreleaseskill", "Effectpaladinplist002", ".plist"},
		{"Effectpaladinblow002", "Effectpaladinblow002", ".ExportJson"},
		{"Effectpaladinblow002", "Effectpaladinplist006", ".plist"},
	},
	
	--圣骑士(荆棘光环)
	RES_10570 = {
		{"Effectpaladinreleaseskill", "Effectpaladinreleaseskill", ".ExportJson"},
		{"Effectpaladinreleaseskill", "Effectpaladinplist001", ".plist"},
		{"Effectpaladinreleaseskill", "Effectpaladinplist002", ".plist"},
		{"Effectpaladinblow003", "Effectpaladinblow003", ".ExportJson"},
		{"Effectpaladinblow003", "Effectpaladinplist004", ".plist"},
	},
	
	--圣骑士(帜热光辉)
	RES_10580 = {
		{"Effectpaladinreleaseheal","Effectpaladinreleaseheal",".ExportJson"},
		{"Effectpaladinreleaseheal","Effectpaladinplist001",".plist"},
		{"Effectpaladinreleaseheal","Effectpaladinplist002",".plist"},
		{"Effectpaladinglowingradiance001","Effectpaladinglowingradiance001",".ExportJson"},
		{"Effectpaladinglowingradiance001","Effectpaladinplist001",".plist"},
		{"Effectpaladinglowingradiance001","Effectpaladinplist003",".plist"},
		{"Effectpaladinglowingradiance001","Effectpaladinplist005",".plist"},
		{"Effectpaladinglowingradiance002","Effectpaladinglowingradiance002",".ExportJson"},
		{"Effectpaladinglowingradiance002","Effectpaladinplist001",".plist"},
		{"Effectpaladinglowingradiance002","Effectpaladinplist003",".plist"},
		{"Effectpaladinglowingradiance002","Effectpaladinplist006",".plist"},
		{"Effectpaladinglowingradiance003","Effectpaladinglowingradiance003",".ExportJson"},
		{"Effectpaladinglowingradiance003","Effectpaladinplist001",".plist"},
		{"Effectpaladinglowingradiance003","Effectpaladinplist003",".plist"},
		{"Effectpaladinglowingradiance003","Effectpaladinplist004",".plist"},
	},
}


--判断资源是否加载完毕
function t:IsSkillArmatureLoadFinish(strMaskKey)
	local sTimeKey = tHaveFinishLoadKeyStr[strMaskKey];
	if sTimeKey ~= nil then
		return tHaveFinishLoadArmature[sTimeKey];		
	end
	return false;
end

-- 异步加载技能需要的骨骼动画
-- 参数1:技能ID
-- 加载时候的时间戳
function t:SyncLoadSkillArmature(nSkillID, strMaskKey, nextFuc)
	
	if nSkillID == nil then
		if nextFuc ~= nil then
			nextFuc();
			nextFuc = nil;
		end
		return true;
	end
	
	local strKey = "RES_"..tostring(nSkillID);
	if tHaveFinishLoadArmature[strKey] ~= nil then
		--这个资源已经加载过了
		if tHaveFinishLoadArmature[strKey] then
			if nextFuc ~= nil then
				nextFuc();
				nextFuc = nil;
			end
			return true;
		end
	end

	--判断是否需要异步加载资源
	if tSkillArmatureResource[strKey] ~= nil then
		--资源是不是在加载了?
		if tHaveFinishLoadArmature[strKey] ~= nil then			
			if tHaveFinishLoadArmature[strKey]==false then
				-- 表示在加载资源中
				return false;
			end
		end
		
		if GameFightCenter:IsShowLog() then
			cclog("---将要异步加载技能ID:%d。---",nSkillID);		
		end
		
		tHaveFinishLoadArmature[strKey] 	= false;
		if strMaskKey ~= nil then
			tHaveFinishLoadKeyStr[strMaskKey] 	= strKey;
		end
		
		local nIndex = 1;
		for i,v in ipairs(tSkillArmatureResource[strKey]) do
			--v[1] 代表技能目录
			--v[2] 代表技能名字
			--v[3] 代表技能后缀
			local function func()
			
				local spriteExportJson = "skill/"..v[1].."/"..v[2]..v[3];
				local function dataLoaded(percent)
					if percent >= 1 then
						nIndex = nIndex + 1;
						if GameFightCenter:IsShowLog() then						
							cclog("---加载技能骨骼(%d)OK:%s---", i, v);
						end
						
						if (#tSkillArmatureResource[strKey]+1) == nIndex then
							--表示只有一个骨骼异步加载
							tHaveFinishLoadArmature[strKey] = true;
							if nextFuc ~= nil then
								nextFuc();
								nextFuc = nil;
							end
						end
					end
				end
				if ".ExportJson" == v[3] then
					CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfoAsync(spriteExportJson, dataLoaded)
				elseif ".plist" == v[3] then
					CCPlistCache:sharedPlistCache():addPlistAsync( spriteExportJson, dataLoaded);
				else
					cclog("**************************************");
				end
			end
			if i~=1 then
				local handle = nil;
				local function funcCallBack()
					if i==nIndex then
						Scheduler.unscheduleGlobal(handle);
						func();
					end
				end
				handle = Scheduler.scheduleGlobal(funcCallBack, 0);
			else
				func();
			end
		end
		return false;		
	else
		if nextFuc ~= nil then
			nextFuc();
			nextFuc = nil;
		end
	end
	return true;
end

-- 异步加载技能表需要的骨骼动画
-- 参数1:技能ID数据表
-- 加载完毕回调函数
function t:SyncLoadSkillTableArmature(tSkillTb, nextFuc)
	
	-- 整理去除相同的模型
	local tSameIndex = {};
	for i,v in ipairs(tSkillTb) do
		if i < #tSkillTb then
			for j=i+1, #tSkillTb  do
				local d = tSkillTb[j]
				if v==d then
					table.insert(tSameIndex,j);
				end
			end
		end
	end
	if #tSameIndex > 0 then
		table.sort(tSameIndex, function(a,b)
			if a>b then 
				return true;
			else
				return false;
			end
		end
		);
		for i,v in ipairs(tSameIndex) do
			table.remove(tSkillTb,v);
		end
	end
	
	if #tSkillTb == 0 then
		if nextFuc ~= nil then
			nextFuc();
			nextFuc = nil;
		end
		return;
	end
	
	--
	local nIndex = 1;
	for i,v in ipairs(tSkillTb) do
		--加载一个技能中所有骨骼技能
		local function func()
			local function dataLoaded()
				nIndex = nIndex + 1;						
				if GameFightCenter:IsShowLog() then
					cclog("---加载技能骨骼(%d)OK:%s---", i, v);
				end
				if (#tSkillTb+1) == nIndex then
					if nextFuc ~= nil then
						nextFuc();
						nextFuc = nil;
					end
				end
			end
			t:SyncLoadSkillArmature(v, nil, dataLoaded)
		end
		if i~=1 then
			local handle = nil;
			local function funcCallBack()
				if i==nIndex then
					Scheduler.unscheduleGlobal(handle);
					func();
				end
			end
			handle = Scheduler.scheduleGlobal(funcCallBack, 0);
		else
			func();
		end
	end
end


--异步加载角色资源列表
--tbArmatureList(加载骨骼数据)
--nextFuc(加载完毕回调函数)
function t:AsyncLoadModuleArmature(tbArmatureList, nextFuc)
	-- 整理去除相同的模型
	local tSameIndex = {};
	for i,v in ipairs(tbArmatureList) do
		if i < #tbArmatureList then
			for j=i+1, #tbArmatureList  do
				local d = tbArmatureList[j]
				if d[1]==v[1] and d[2]==v[2] then
					table.insert(tSameIndex,j);
				end
			end
		end
	end
	if #tSameIndex > 0 then
		table.sort(tSameIndex, function(a,b)
			if a>b then 
				return true;
			else
				return false;
			end
		end
		);
		for i,v in ipairs(tSameIndex) do
			table.remove(tbArmatureList,v);
		end
	end
	
	if #tbArmatureList == 0 then
		if nextFuc ~= nil then
			nextFuc();
			nextFuc = nil;
		end
		return;
	end
	
	local nIndex = 1;
	for i,v in ipairs(tbArmatureList) do
		local function func()
			local nRace = v[1];
			local nRole = v[2];
			-------------------------------------------------------
			--用Race 和 Role标记骨骼
			local strKey = "RES_"..tostring(nRace)..tostring(nRole);
			--说明资源没加载
			if tHaveFinishLoadArmature[strKey] == nil then
				--标记在加载
				tHaveFinishLoadArmature[strKey] = false;
				local spriteName = nil;
				local spriteWearing = nil;
				if nRace < 35000 then
					--角色
					spriteName = CfgData["cfg_race"][nRace]["armture"];
					spriteWearing = CfgData["cfg_profession"][nRole]["wear"];
				else
					--怪物
					spriteName = CfgData["cgf_monster"][nRace]["armture"];
					spriteWearing = CfgData["cgf_monster"][nRace]["wear"];
				end
				local spriteExportJson = "hero/"..spriteName.."/"..spriteName..".ExportJson";
				
				if GameFightCenter:IsShowLog() then
					cclog("---将要异步加载:"..spriteExportJson);
				end
				
				--异步加载回调
				local function dataLoaded(percent)
					if percent >= 1 then
						if spriteWearing ~= 0 then
							local pSpriteFrameCache = CCSpriteFrameCache:sharedSpriteFrameCache();
							if pSpriteFrameCache ~= nil then
								local spritePlist = "hero/"..spriteName.."/"..spriteName..spriteWearing..".plist";
								local spritePng   = "hero/"..spriteName.."/"..spriteName..spriteWearing..".png";
								pSpriteFrameCache:addSpriteFramesWithFile(spritePlist, spritePng);
							end
						end
						tHaveFinishLoadArmature[strKey] = true;
						nIndex = nIndex + 1;
						if (#tbArmatureList+1) == nIndex then
							--表示只有一个骨骼异步加载
							if nextFuc ~= nil then
								nextFuc();
								nextFuc = nil;
							end
						end
						if GameFightCenter:IsShowLog() then
							cclog("---异步加载OK:"..spriteExportJson);
						end
					end
				end
				CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfoAsync(spriteExportJson, dataLoaded);
			else
				nIndex = nIndex + 1;
				if (#tbArmatureList+1) == nIndex then
					--表示只有一个骨骼异步加载
					if nextFuc ~= nil then
						nextFuc();
						nextFuc = nil;
					end
				end
			end
	
		end
		if i~=1 then
			local handle = nil;
			local function funcCallBack()
				if i==nIndex then
					Scheduler.unscheduleGlobal(handle);
					func();
				end
			end
			handle = Scheduler.scheduleGlobal(funcCallBack, 0);
		else
			func();
		end
	end
end

--异步加载角色资源列表
--tbArmatureList(加载骨骼数据)
--nextFuc(加载完毕回调函数)
function t:AsyncLoadModuleArmatureForHero(tbArmatureList, nextFuc)
	
	tHaveFinishLoadArmatureHero = {};
	-- 整理去除相同的模型
	local tSameIndex = {};
	for i,v in ipairs(tbArmatureList) do
		if i < #tbArmatureList then
			for j=i+1, #tbArmatureList  do
				local d = tbArmatureList[j]
				if d[1]==v[1] and d[2]==v[2] then
					table.insert(tSameIndex,j);
				end
			end
		end
	end
	if #tSameIndex > 0 then
		table.sort(tSameIndex, function(a,b)
			if a>b then 
				return true;
			else
				return false;
			end
		end
		);
		for i,v in ipairs(tSameIndex) do
			table.remove(tbArmatureList,v);
		end
	end
	
	if #tbArmatureList == 0 then
		if nextFuc ~= nil then
			nextFuc();
			nextFuc = nil;
		end
		return;
	end
	
	local nIndex = 1;
	for i,v in ipairs(tbArmatureList) do
		local function func()
			local nRace = v[1];
			local nRole = v[2];
			-------------------------------------------------------
			--用Race 和 Role标记骨骼
			local strKey = "RES_"..tostring(nRace)..tostring(nRole);
			--说明资源没加载
			if tHaveFinishLoadArmatureHero[strKey] == nil then
				--标记在加载
				tHaveFinishLoadArmatureHero[strKey] = false;
				local spriteName = nil;
				local spriteWearing = nil;
				if nRace < 35000 then
					--角色
					spriteName = CfgData["cfg_race"][nRace]["armture"];
					spriteWearing = CfgData["cfg_profession"][nRole]["wear"];
				else
					--怪物
					spriteName = CfgData["cgf_monster"][nRace]["armture"];
					spriteWearing = CfgData["cgf_monster"][nRace]["wear"];
				end
				local spriteExportJson = "hero/"..spriteName.."/"..spriteName..".ExportJson";
				
				if GameFightCenter:IsShowLog() then
					cclog("---将要异步加载:"..spriteExportJson);
				end
				
				--异步加载回调
				local function dataLoaded(percent)
					if percent >= 1 then
						if spriteWearing ~= 0 then
							local pSpriteFrameCache = CCSpriteFrameCache:sharedSpriteFrameCache();
							if pSpriteFrameCache ~= nil then
								local spritePlist = "hero/"..spriteName.."/"..spriteName..spriteWearing..".plist";
								local spritePng   = "hero/"..spriteName.."/"..spriteName..spriteWearing..".png";
								pSpriteFrameCache:addSpriteFramesWithFile(spritePlist, spritePng);
							end
						end
						tHaveFinishLoadArmatureHero[strKey] = true;
						nIndex = nIndex + 1;
						if (#tbArmatureList+1) == nIndex then
							--表示只有一个骨骼异步加载
							if nextFuc ~= nil then
								nextFuc();
								nextFuc = nil;
							end
						end
						if GameFightCenter:IsShowLog() then
							cclog("---异步加载OK:"..spriteExportJson);
						end
					end
				end
				CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfoAsync(spriteExportJson, dataLoaded);
			else
				nIndex = nIndex + 1;
				if (#tbArmatureList+1) == nIndex then
					--表示只有一个骨骼异步加载
					if nextFuc ~= nil then
						nextFuc();
						nextFuc = nil;
					end
				end
			end
	
		end
		if i~=1 then
			local handle = nil;
			local function funcCallBack()
				if i==nIndex then
					Scheduler.unscheduleGlobal(handle);
					func();
				end
			end
			handle = Scheduler.scheduleGlobal(funcCallBack, 0);
		else
			func();
		end
	end
end


--清除数据
function t:ClearLoadArmature()
	tHaveFinishLoadArmature = {};
end

return t;