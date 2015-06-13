
GameFightCenter = {};
local p = GameFightCenter;

p.Layer = nil;
p.ui = nil;
p.uiLayer = nil;

--战斗的英雄数据存储
local m_BattleSprite = {};
local m_BattleDate = {};
local m_RoundDate = {};
local m_Sprite_2_UI = {};

local m_bInitMap = false;
local m_bStop = false;
local handTime = nil;
local x_speed_1 = 10;
local x_speed_2 = 20;	
local m_yOffest = 382;

--(true  表示读取文件回复战斗)
--(false 表示读取测试技能)
local m_BeginRound = nil;
local m_IsReadFile = true;
local m_MapId = 6;

local m_battleStr  = "res/fight_bak/2015_05_20_13_45_56.txt";
-- local m_battleStr  = "fight_bak/2014_12_15_16_21_40.txt";

--是否显示战斗相关日志
function p:IsShowLog()
	return true;
end

--创建战斗Layer
function p:FightSceneLayer()
	if p.Layer == nil then
		p.Layer = CCLayer:create()
		if nil == p.Layer then
			cclog("****************create fight layer faild!");
			return nil;
		end
		local function onNodeEvent(event)
			if event == "enter" then
				
				CfgData.LoadCfgData();
				
				if not m_IsReadFile then
					p:InitTestPostion();
				end
				p:RuningMapInit(m_yOffest);
				-- p:InitTouchGroup({});
				m_bStop = true;
				
				--读取战斗保存数据
				if m_IsReadFile then
					local battleStr = FileOperate:ReadFromFile(m_battleStr, "r", "*a");
					p:ParsingBattle(battleStr);
					-- p:ParsingBattle(GameFightInfoBase.FirstBattleLog());
					m_bStop = false;
				else
					p:StartGameFight();
					handTime = Scheduler.scheduleGlobal(p.schedulerFight, 1.8);
				end
				
			elseif event == "exit" then

			end
		end
		p.Layer:registerScriptHandler(onNodeEvent)
    end
	--]]
	return p:create();
end

function p.FightBattleIsShow()
	if p.uiLayer ~= nil then
		return p.uiLayer:isVisible();
	else
		cclog("***FightBattleIsShow Error ***");
	end	
	return false;
end

--UI
function p:create()
	if p.uiLayer == nil then
		p.uiLayer = TouchGroup:create()
		p.ui = ui_delegate(GUIReader:shareReader():widgetFromJsonFile("UserUI/action_1.json"))
		p.uiLayer:addWidget(p.ui.nativeUI);
		p.uiLayer:addChild(p.Layer,0);
		
		--注册按钮事件
		ui_add_click_listener(p.ui.Button_40_0,p.changeMap); --切换地图
		ui_add_click_listener(p.ui.Button_40_1,p.SpeedFight); --快速战斗
		ui_add_click_listener(p.ui.Button_40,p.battleSet); --战斗设置
	end
    return p.uiLayer;
end

--切换地图
function p.changeMap()
	OpenLayer(UI_TAG.UI_STAGEINFO);
end

--初始化UI
function p:InitTouchGroup(tHeroList)
	
	m_Sprite_2_UI = nil;
	m_Sprite_2_UI = {};
	for i=1, 4 do
		-- 头像
		local headKey = "Image_head_"..i;
		local pHeadImg = tolua.cast(p.ui[headKey], "ImageView");
		-- 等级
		local levlKey = "Label_LV_"..i;
		local pLvlLable = tolua.cast(p.ui[levlKey], "Label");
		-- 名字
		local nameKey = "Label_name_"..i;
		local pNameLable = tolua.cast(p.ui[nameKey], "Label");
		-- 血量文本
		local hpLabKey = "Label_hp_"..i;
		local pHpLable = tolua.cast(p.ui[hpLabKey], "Label");
		-- 血量进度条
		local hpBarKey = "ProgressBar_hp_"..i;
		local pHpBar = tolua.cast(p.ui[hpBarKey], "LoadingBar");
		-- 血量进度条(背景红色)
		local hpRedBarKey = "ProgressBar_hp_red_"..i;
		local pHpBkBar = tolua.cast(p.ui[hpRedBarKey], "LoadingBar");
		-- 背景
		local bkImgKey = "Image_hero_bg_"..i;
		local pBkImg = tolua.cast(p.ui[bkImgKey], "ImageView");
		-- 选框背景
		-- local bkHeroImgKey = "Image_hero_"..i;
		-- local pHeroBkImg = tolua.cast(p.ui[bkHeroImgKey], "ImageView");		
		
		local bShow = false;
		if tHeroList[i]~=nil then
			bShow = true;
			pNameLable:setText(tHeroList[i].sName);
			local str = tHeroList[i].nMaxHp.."/"..tHeroList[i].nMaxHp;
			pHpLable:setText(str);
			pHpBar:setPercent(100);
			pHpBkBar:setPercent(100);
			
			pLvlLable:setText(tostring(UserData.TeamLevel));
		
			m_Sprite_2_UI[tostring(tHeroList[i].nId)] = {};
			m_Sprite_2_UI[tostring(tHeroList[i].nId)].nUiId = i;
			m_Sprite_2_UI[tostring(tHeroList[i].nId)].nMaxHp = tHeroList[i].nMaxHp;
			
		end
		pHeadImg:setVisible(bShow);
		pLvlLable:setVisible(bShow);
		pNameLable:setVisible(bShow);
		pHpLable:setVisible(bShow);
		pHpBar:setVisible(bShow);
		pHpBkBar:setVisible(bShow);
		-- pHeroBkImg:setVisible(bShow);
		pBkImg:setVisible(not bShow);
	end
end

function p:InitTestPostion()


-- {31995,"轻武器",1,1,1,0,0,0,0,0,0,0,0,0,0}
-- ,{31996,"中武器",1,2,1,0,0,0,0,0,0,0,0,0,0}
-- ,{31997,"重武器",1,4,1,0,0,0,0,0,0,0,0,0,0}
-- ,{31998,"远程武器",1,12,1,0,0,0,0,0,0,0,0,0,0}
-- ,{31999,"法杖武器",1,10,1,0,0,0,0,0,0,0,0,0,0}
	-- 80015
	local xOffset = 0;
	local yOffset = m_yOffest;
	local tSpite = {
		-- 31998(短弓) 31995(短剑)
		{nId=1, nRace=1201, nRole=1114, nWeap=31997,IsEnemy=false,nMaxHp=1000},
		{nId=2, nRace=1206, nRole=1114, nWeap=31997,IsEnemy=false,nMaxHp=1000},
		{nId=3, nRace=1201, nRole=1101, nWeap=31997,IsEnemy=false,nMaxHp=1000},
		{nId=4, nRace=1201, nRole=1101, nWeap=31997,IsEnemy=false,nMaxHp=1000},
	}
	--我方
	local nSprite = #tSpite;
	for nIndex=1,nSprite do
		local spriteName = nil;
		local spriteWearing = nil;
		local weapIng = nil;
		if tSpite[nIndex].nRace < 35000 then
			--角色
			spriteName = CfgData["cfg_race"][tSpite[nIndex].nRace]["armture"];
			spriteWearing = CfgData["cfg_profession"][tSpite[nIndex].nRole]["wear"];
			weapIng = tSpite[nIndex].nWeap;
		else
			--怪物
			spriteName = CfgData["cgf_monster"][tSpite[nIndex].nRace]["armture"];
			spriteWearing = CfgData["cgf_monster"][tSpite[nIndex].nRace]["wear"];
			weapIng = CfgData["cgf_monster"][tSpite[nIndex].nRace]["weap"];
		end
		local pos = p:GetAttackPostion(nIndex , nSprite, bIsEnemy, xOffset, yOffset);
		
		-- if nIndex == 1 then
		SpriteArmaturePool:CreateArmature(tSpite[nIndex].nId, spriteName, weapIng, spriteWearing, tSpite[nIndex].IsEnemy, "normal", pos, tSpite[nIndex].nMaxHp);
		-- else
			-- SpriteArmaturePool:CreateArmature(tSpite[nIndex].nId, "Tieflingaction", weapIng, 17, tSpite[nIndex].IsEnemy, "normal", pos, tSpite[nIndex].nMaxHp);
		-- end
		-- SpriteArmaturePool:CreateArmature(tSpite[nIndex].nId, "humanaction", tSpite[nIndex].nWeap, 4, tSpite[nIndex].IsEnemy, "normal", pos, tSpite[nIndex].nMaxHp);
		
	end
	--]]
	
	local tSpite2 = {
		{nId=5, nRace=35045, nRole=1121, nWeap=31997,IsEnemy=true,nMaxHp=10000},
		{nId=6, nRace=35046, nRole=1121, nWeap=31997,IsEnemy=true,nMaxHp=10000},
		-- {nId=7, nRace=35047, nRole=1121, nWeap=31995,IsEnemy=true,nMaxHp=1000},
		-- {nId=8, nRace=35048, nRole=1121, nWeap=31995,IsEnemy=true,nMaxHp=1000},
		-- {nId=5, nRace=1201, nRole=1114, nWeap=80001,IsEnemy=true,nMaxHp=1000},
		-- {nId=6, nRace=1206, nRole=1114, nWeap=80001,IsEnemy=true,nMaxHp=1000},
		-- {nId=7, nRace=1201, nRole=1101, nWeap=80001,IsEnemy=true,nMaxHp=1000},
		-- {nId=8, nRace=1201, nRole=1101, nWeap=80001,IsEnemy=true,nMaxHp=1000},
	}
	--敌方
	local nSprite = #tSpite2;
	for nIndex=1,nSprite do
		local pos = p:GetBeAttackPostion(nIndex , nSprite, bIsEnemy, xOffset, yOffset);

		local spriteName = nil;
		local spriteWearing = nil;
		local weapIng = nil;
		if tSpite2[nIndex].nRace < 35000 then
			--角色
			spriteName = CfgData["cfg_race"][tSpite2[nIndex].nRace]["armture"];
			spriteWearing = CfgData["cfg_profession"][tSpite2[nIndex].nRole]["wear"];
			weapIng = tSpite2[nIndex].nWeap;
		else
			--怪物
			spriteName = CfgData["cgf_monster"][tSpite2[nIndex].nRace]["armture"];
			spriteWearing = CfgData["cgf_monster"][tSpite2[nIndex].nRace]["wear"];
			weapIng = CfgData["cgf_monster"][tSpite2[nIndex].nRace]["weap"];
			-- spriteName = "monsterbone007"
			-- spriteWearing = 6;
		end
		SpriteArmaturePool:CreateArmature(tSpite2[nIndex].nId, "monsterbone008", weapIng, 3, tSpite2[nIndex].IsEnemy, "normal", pos, tSpite2[nIndex].nMaxHp);
		-- SpriteArmaturePool:CreateArmature(tSpite2[nIndex].nId, "humanaction", tSpite2[nIndex].nWeap, 4, tSpite2[nIndex].IsEnemy, "normal", pos, tSpite2[nIndex].nMaxHp);
	end
	--]]
end


--显示技能的名称
function p:ShowSkillName(nSkillId, isEnemy)
	if nSkillId == 10010 then
		return;
	end
	local pSprite = CCSprite:create("image/skill_message.png");
	if pSprite ~= nil then
		pSprite:setCascadeOpacityEnabled(true);
		local winSize = CCDirector:sharedDirector():getWinSize();
		local size = pSprite:getContentSize();
		if isEnemy then
			pSprite:setPosition(ccp(winSize.width, winSize.height*9/10));
		else
			pSprite:setPosition(ccp(0, winSize.height*9/10));
		end
		
		local skillName = CfgData["cfg_skill"][nSkillId]["name"];
		local skillType = CfgData["cfg_skill"][nSkillId]["type"];
		local skillFonts = nil;
		if skillType == 1 then --攻击技能
			skillFonts = "fonts/yellow.fnt";
		elseif skillType == 2 then --增益技能
			skillFonts = "fonts/greenSkill.fnt";
		else
			cclog("***************技能字体配置错误---------------"..skillName);
		end
			
		-- local pLable = CCLabelBMFont:create(skillName, skillFonts);
		local pLable = CCLabelTTF:create(skillName, "Arial", 22)
		if skillType == 1 then --攻击技能
			pLable:setColor(ccc3(255,215,0))
		elseif skillType == 2 then --增益技能
			pLable:setColor(ccc3(124,252,0))			
		end
		
		pLable:setAnchorPoint(ccp(0,0));
		local lableSize = pLable:getContentSize();
		local x = (size.width - lableSize.width)/2;
		local y = (size.height - lableSize.height)/2;
		pLable:setPosition(ccp(x,y));
		pSprite:addChild(pLable, 1);
		p.Layer:addChild(pSprite,1000);
		
		local array2 = CCArray:create();
		local xOffset    = winSize.width/4;
		local xOffset_to = winSize.width*3/4;
		if isEnemy then
			xOffset    = -winSize.width/4;
			xOffset_to = -winSize.width*3/4;
		end
		
		
		array2:addObject(CCMoveBy:create(0.05, ccp(xOffset, 0)));
		array2:addObject(CCFadeIn:create(0.1));
		array2:addObject(CCDelayTime:create(0.8));
		array2:addObject(CCFadeOut:create(0.5));
		-- array2:addObject(CCMoveBy:create(0.1, ccp(xOffset_to, 0)));
		array2:addObject(CCRemoveSelf:create(true));
		local pAction = CCSequence:create(array2);	
		pSprite:runAction(pAction);
	end
end

--nTag实体ID;
--nHp 剩余HP;
function p:UpdateHp(nTag, nHp)
	if m_Sprite_2_UI[tostring(nTag)] ~= nil then
		local i = m_Sprite_2_UI[tostring(nTag)].nUiId;
		local nMaxHp = m_Sprite_2_UI[tostring(nTag)].nMaxHp;
		
		-- 血量文本
		local hpLabKey = "Label_hp_"..i;
		local pHpLable = tolua.cast(p.ui[hpLabKey], "Label");
		-- 血量进度条
		local hpBarKey = "ProgressBar_hp_"..i;
		local pHpBar = tolua.cast(p.ui[hpBarKey], "LoadingBar");
		
		-- 血量进度条(背景红色)
		local hpRedBarKey = "ProgressBar_hp_red_"..i;
		local pHpBkBar = tolua.cast(p.ui[hpRedBarKey], "LoadingBar");

			
		local objHpKey = "BitmapLabel_hp_"..nTag;
		local sHp = nHp.."/"..nMaxHp;
		pHpLable:setText(sHp);
		
		local objProKey = "ProgressBar_hp_"..nTag;
		local nPrecent = math.floor(nHp/nMaxHp*100);
		local nNowPer = pHpBkBar:getPercent();
		local fMiner = (nNowPer-nPrecent)/50;
		if fMiner > 0 then
			pHpBar:setPercent(nPrecent);
			local function update(delta)
				nNowPer = nNowPer - fMiner;
				if nNowPer<=nPrecent then
					pHpBkBar:unscheduleUpdate();
				end
				pHpBkBar:setPercent(nNowPer);
			end
			pHpBkBar:scheduleUpdateWithPriorityLua(update, 0)
		else
			
			local function update(delta)
				nNowPer = nNowPer - fMiner;
				if nNowPer>=nPrecent then
					pHpBar:setPercent(nPrecent);
					pHpBkBar:unscheduleUpdate();
				end
				pHpBkBar:setPercent(nNowPer);
			end
			pHpBkBar:scheduleUpdateWithPriorityLua(update, 0)			
		end
	end
	p:ShowHpAction(nTag, nHp);
end

--获取战斗英雄名字
function p:GetHeroNameByTagId(nTag)
	local strName = "";
	local tInfo = nil;
	local nMaxHp = nil;
	for i,v in ipairs(m_BattleSprite) do
		for j,d in ipairs(v) do
			if d.nId == nTag then
				strName=d.sName;
				break;
			end
		end
	end
	return strName;
end

--显示血条动作
function p:ShowHpAction(nTag, nNowHp)

	--显示血条动作
	-- local tArmatureSprite = SpriteArmaturePool:GetArmature(nTag);
	local tArmatureSprite = SpriteArmaturePool:GetArmatureIgnoreDeath(nTag);
	if tArmatureSprite ~= nil then
		
		local nMaxHp = nil;
		for i,v in ipairs(m_BattleSprite) do
			for j,d in ipairs(v) do
				if d.nId == nTag then
					nMaxHp = d.nMaxHp;
				end
			end
			if nMaxHp ~= nil then
				break;
			end
		end
		
		if nMaxHp == nil then
			cclog("******************** 显示血条动作 ShowHpAction 错误");
			return;
		end
		
		if tArmatureSprite.ProgressTimer == nil then
			tArmatureSprite:CreateProgressTimer("image/hp_green.png", "image/hp_red.png","image/heroxp-progress-bg.png");
		end
		local nPrecent = math.floor(nNowHp/nMaxHp*100);
		local nNowPre  = tArmatureSprite.ProgressTimer:getPercentage();
		tArmatureSprite.ProgressTimer:setPercentage(nPrecent);
		tArmatureSprite.ProgressTimerRed:setPercentage(nPrecent);
		
		tArmatureSprite.ProgressTimerRed:runAction(CCProgressFromTo:create(1.0, nNowPre, nPrecent));
		--
		local array = CCArray:create();
		array:addObject(CCShow:create());
		array:addObject(CCDelayTime:create(1.0));
		array:addObject(CCHide:create());
		local pAction = CCSequence:create(array);
		tArmatureSprite.ProgressTimer:runAction(pAction);
		--]]
	end
end


-- 战斗字符串解析
function p:ParsingBattle(battleStr)
	
	--伤处所有精灵
	SpriteArmaturePool:RemoveAllArmature();
		
	m_BattleSprite = nil;
	m_BattleSprite = {};
	--
	local xOffset = 0;
	local yOffset = m_yOffest;
	
	--战斗数据分割(英雄数据/战斗数据)
	local battleTb = Split(battleStr, "#", false);
	
	--英雄数据
	local heroTb = Split(battleTb[1], "|", false);
	--攻击方英雄数据
	m_BattleSprite[1] = {};
	local tAttackTb = Split(heroTb[1], "&", false);
	for i,v in ipairs(tAttackTb) do
		if v~="" then
			local heroInfo = Split(v, "_", false);
			local tHero = {};
			tHero.IsEnemy = false;
			tHero.nId 	= tonumber(heroInfo[1]);	--实体ID
			tHero.sName = heroInfo[2];				--昵称
			tHero.nLevel = tonumber(heroInfo[3]);	--等级
			tHero.nRace = tonumber(heroInfo[4]);	--种族
			tHero.nRole	= tonumber(heroInfo[5]);	--职业
			tHero.nWeap = tonumber(heroInfo[6]);	--武器
			tHero.nArmor= tonumber(heroInfo[7]);	--防具
			tHero.nMaxHp= tonumber(heroInfo[8]);	--血量上限
			table.insert(m_BattleSprite[1], tHero);
		end
	end
	-- p:InitTouchGroup(m_BattleSprite[1]);
	p:InitBattleSpite(m_BattleSprite[1], false, xOffset, yOffset);
	
	--被攻击方英雄数据
	m_BattleSprite[2] = {};
	local tBeAttackTb = Split(heroTb[2], "&", false);
	for i,v in ipairs(tBeAttackTb) do
		if v~="" then
			local heroInfo = Split(v, "_", false);
			local tHero = {};
			tHero.IsEnemy = true;
			tHero.nId 	= tonumber(heroInfo[1]);	--实体ID
			tHero.sName = heroInfo[2];				--昵称
			tHero.nLevel = tonumber(heroInfo[3]);	--等级
			tHero.nRace = tonumber(heroInfo[4]);	--种族
			tHero.nRole	= tonumber(heroInfo[5]);	--职业
			tHero.nWeap = tonumber(heroInfo[6]);	--武器
			tHero.nArmor= tonumber(heroInfo[7]);	--防具
			tHero.nMaxHp= tonumber(heroInfo[8]);	--血量上限
			table.insert(m_BattleSprite[2], tHero);
			
			--骨骼资源异步加载
			-- SpriteArmaturePool:AsyncFucLoadArmatureData(tHero.nRace, tHero.nRole);
		end
	end
	
	--战斗回合数据
	m_BattleDate = nil;
	m_BattleDate = {};
	for i=2 ,#battleTb do
		local tbRound = {};
		local tRoundTb = Split(battleTb[i], "/", false);
		for i,v in ipairs(tRoundTb) do
			if v~="" then
				--单次行动数据
				local tb = p:SingleMessage(v);
				table.insert(tbRound, tb);
			end
		end
		if m_BeginRound ~= nil then
			if i == (m_BeginRound+1) then
				table.insert(m_BattleDate, tbRound);
			end
		else
			table.insert(m_BattleDate, tbRound);
		end
	end
	
	--地图跑动
	m_bStop = false;
	if not m_bInitMap then
		p:RuningMapInit(yOffset);
		m_bInitMap = true;
	end
	p:DoFightBegin();
	p:StartGameFight();
	
end

-- 当个战斗回合
function p:SingleMessage(strMessage)
	local tb = {}
	local battleTb = Split(strMessage, "|", false);
	
	--行动部分
	if battleTb[1] ~= "" then
		tb[1] = {};
		local tMoveData = Split(battleTb[1], "&", false);
		for i, v in ipairs(tMoveData) do
			if v ~= "" then
				tb[1][i] = {};
				local tMoveData1 = Split(v, "_", false);
				-- 攻击者实体ID
				tb[1][i].nAttackId = tonumber(tMoveData1[1]);
				-- 技能ID
				tb[1][i].nSkillId = tonumber(tMoveData1[2]);
				-- 技能资源异步加载
				-- SkillResourcesLoad:SyncLoadArmature(tb[1][i].nSkillId);
				-- 被击者实体ID
				tb[1][i].nBeAttackId = {tonumber(tMoveData1[3])};
				-- 攻击结果
				tb[1][i].nAttackType = tonumber(tMoveData1[4]);
				-- 伤害数值
				tb[1][i].nDamageHurt = tonumber(tMoveData1[5]);
				-- 附加状态串
				tb[1][i].sAdditional = tMoveData1[6];
			end
		end
	end
	
	--状态部分
	if battleTb[2] ~= "" then
		tb[2] = {};
		local tMoveData = Split(battleTb[2], "&", false);
		for i, v in ipairs(tMoveData) do
			if v ~= "" then
				tb[2][i] = {};
				local tMoveData1 = Split(v, "_", false);
				-- 攻击者实体ID
				tb[2][i].nAttackId = tonumber(tMoveData1[1]);
				-- 技能ID
				tb[2][i].nSkillId = tonumber(tMoveData1[2]);
				-- 被击者实体ID
				tb[2][i].nBeAttackId = {tonumber(tMoveData1[3])};
				-- 攻击结果
				tb[2][i].nAttackType = tonumber(tMoveData1[4]);
				-- 伤害数值
				tb[2][i].nDamageHurt = tonumber(tMoveData1[5]);
				-- 附加状态串
				tb[2][i].sAdditional = tMoveData1[6];
			end
		end
	end
	return tb;
end

--开始战斗
function p:DoFightBegin()
	if handTime ~= nil then
		Scheduler.unscheduleGlobal(handTime);
		handTime = nil;
		m_bStop = false;
	end
	
	local function listenerRun()
		local function listenerMove()
			
			local winSize = CCDirector:sharedDirector():getWinSize();
			local function callBack()
				SpriteArmaturePool:SetAllSpriteStateMachibe("normal");
				handTime = Scheduler.scheduleGlobal(p.schedulerFight, 1.8);
				m_bStop = true;
			end
			p:ShowEnemy(winSize, m_yOffest, callBack);
		end
		Scheduler.performWithDelayGlobal(listenerMove, math.random(0,1));
		SpriteArmaturePool:SetAllSpriteStateMachibe("move");
		x_speed_1 = 10;
		x_speed_2 = 20;	
	end
	x_speed_1 = 10*2;
	x_speed_2 = 20*2;
	
	Scheduler.performWithDelayGlobal(listenerRun, math.random(0,1));
	SpriteArmaturePool:SetAllSpriteStateMachibe("run");
end


function p:assemblyFight(tMessage)
	--状态部分
	local stateArray = nil;
	if tMessage[2] ~= nil then
		stateArray = {};
		for i,v in ipairs(tMessage[2]) do
			local tb = SpriteStateCenter:StateAssembly(v);
			if tb ~= nil then
				table.insert(stateArray, tb);
			end
		end
		if #stateArray == 0 then
			stateArray = nil;
		end
	end
	--行动部分
	SkillReleaseCenter:SkillRoundComb(tMessage[1], stateArray);
end

-- 敌人出现
function p:ShowEnemy(winSize, yOffset, callBack)
	
	local xOffset = 300;
	p:InitBattleSpite(m_BattleSprite[2], true, xOffset, yOffset);

	--添加到动作池
	local actionArray = {};
	--表示执行动作的精灵
	for i,v in ipairs(m_BattleSprite[2]) do
		if i==1 then
			table.insert(actionArray, v.nId);
		else
			table.insert(actionArray,{nil, nil, ActionEnum.DELAY_ACTION, 0.1});
		end
		table.insert(actionArray,{v.nId, nil, ActionEnum.JUMP_ACTION, {0.2,ccp(-xOffset, 0), 50, 1}});
	end
	SpriteActionPool:PushInActionFromQueue(actionArray);
	-----------------------------------------------
	Scheduler.performWithDelayGlobal(callBack, 0.4);
end

-- 地图初始化
function p:RuningMapInit(yOffset)

	--速度	
	local xOffset_1 = x_speed_1*0.1;
	local xOffset_2 = x_speed_2*0.1;
	
    local sprite = CCSprite:create("map/"..tostring(m_MapId).."_1.png");
	sprite:setAnchorPoint(ccp(0,0))
	sprite:setPosition(ccp(0,yOffset))
    p.Layer:addChild(sprite);
	
	local x_w_1 = sprite:getContentSize().width;
    local sprite_ex = CCSprite:create("map/"..tostring(m_MapId).."_1.png");
	sprite_ex:setAnchorPoint(ccp(0,0))
	sprite_ex:setPosition(ccp(x_w_1-xOffset_1,yOffset));
    p.Layer:addChild(sprite_ex);
	

    local sprit2 = CCSprite:create("map/"..tostring(m_MapId).."_2.png");
	sprit2:setAnchorPoint(ccp(0,0))
	sprit2:setPosition(ccp(0,yOffset))
    p.Layer:addChild(sprit2);
	
	local x_w_1 = sprit2:getContentSize().width;
    local sprite2_ex = CCSprite:create("map/"..tostring(m_MapId).."_2.png");
	sprite2_ex:setAnchorPoint(ccp(0,0))
	sprite2_ex:setPosition(ccp(x_w_1-xOffset_2,yOffset));
    p.Layer:addChild(sprite2_ex);

	local function runMapTime()
		
		if m_bStop then
			return;
		end
		local x1,y1 = sprite:getPosition();
		local x2,y2 = sprite_ex:getPosition();
		------------------------------------
		if x1 < -x_w_1 then
			x1 = x2+x_w_1-2*x_speed_1*0.1;
		else
			x1 = x1 - x_speed_1*0.1;
		end
		sprite:setPosition(ccp(x1,yOffset));
		------------------------------------
		if x2 < -x_w_1 then
			x2 = x1+x_w_1-2*x_speed_1*0.1;
		else
			x2 = x2 - x_speed_1*0.1;
		end
		sprite_ex:setPosition(ccp(x2,yOffset));		
		--------------------------
		--*******************************************************
		local x1,y1 = sprit2:getPosition();
		local x2,y2 = sprite2_ex:getPosition();
		------------------------------------
		if x1 < -x_w_1 then
			x1 = x2+x_w_1-2*x_speed_2*0.1;
		else
			x1 = x1 - x_speed_2*0.1;
		end
		sprit2:setPosition(ccp(x1,yOffset));
		------------------------------------
		if x2 < -x_w_1 then
			x2 = x1+x_w_1-2*x_speed_2*0.1;
		else
			x2 = x2 - x_speed_2*0.1;
		end
		sprite2_ex:setPosition(ccp(x2,yOffset));		
		--------------------------
	end
	Scheduler.scheduleGlobal(runMapTime, 0);
end

local nRoundTime = 0;
--战斗数据池
function p:schedulerFight()
	
	if not m_IsReadFile then
		-- 1:被击中, 2:格挡, 3:回避, 4:被击反击 5:格挡反击 6:回避反击 
		local nAttackType 	= 3;
		local nSpecileType	= 2;
		local nSkillId = 10010;
		--左边->右边
		--近战攻击
		-- SpriteSkill:ReleaseAllMeleeAttack(1, {5,6}, 10010, nAttackType, {{5, 50, HurtEnum.NORMAL_HURT,eHurtEnum},{6, 50, HurtEnum.NORMAL_HURT,eHurtEnum}}, nil, nil, nil);
		SpriteSkill:ReleaseAllMeleeAttack(3, {6}, nSkillId, nAttackType, {{5, 50, HurtEnum.NORMAL_HURT,eHurtEnum}}, nil, nil, nil, nSpecileType);
		
		--施法攻击
		-- SpriteSkill:ReleaseAllRemoteAttack(1, {5,6}, 10155, nAttackType, {{5, 50, HurtEnum.NORMAL_HURT,eHurtEnum},{5, 50, HurtEnum.NORMAL_HURT,eHurtEnum}}, nil, nil, nil);
		-- SpriteSkill:ReleaseAllRemoteAttack(4, {5}, nSkillId , nAttackType, {{5, 50, HurtEnum.NORMAL_HURT,eHurtEnum}}, nil, nil, nil, 1);
		--]]
		
		--右边->左边
		--近战攻击
		-- SpriteSkill:ReleaseAllMeleeAttack(5, {1,2}, 10880, nAttackType, {{1, 50, HurtEnum.NORMAL_HURT,eHurtEnum},{2, 50, HurtEnum.NORMAL_HURT,eHurtEnum}}, nil, nil, nil);
		-- SpriteSkill:ReleaseAllMeleeAttack(5, {1}, 10460, nAttackType, {{5, 50, HurtEnum.NORMAL_HURT,eHurtEnum}}, nil, nil, nil);
		
		--施法攻击
		-- SpriteSkill:ReleaseAllRemoteAttack(5, {1,2}, 10710, nAttackType, {{1, 50, HurtEnum.NORMAL_HURT,eHurtEnum},{2, 50, HurtEnum.NORMAL_HURT,eHurtEnum}}, nil, nil, nil);
		-- SpriteSkill:ReleaseAllRemoteAttack(5, {1}, 10700, nAttackType, {{1, 50, HurtEnum.NORMAL_HURT,eHurtEnum}}, nil, nil, nil);
		--]]
		-- if nRoundTime == 1 then
			-- local tSprite = SpriteArmaturePool:GetArmatureIgnoreDeath(5);
			-- tSprite:PlayAnimationByName("dodge",nil,nil,1);
		-- end
		-- nRoundTime = nRoundTime + 1;
		
		-- local tSprite = SpriteArmaturePool:GetArmatureIgnoreDeath(6);
		-- tSprite:PlayAnimationByName("badstate",nil,nil,1);
		-- tSprite.fsm:doEvent("badstate");
	else
		if #m_RoundDate==0 then
			-- 回合结束后buff计算
			-- SpriteSkillBufferPool:DoNextRound();
			if #m_BattleDate > 0 then
				m_RoundDate = m_BattleDate[1];
				table.remove(m_BattleDate,1);
				nRoundTime = nRoundTime + 1;
				cclog("----****战斗第_"..nRoundTime.."_回合");
			else
				--
				Scheduler.unscheduleGlobal(handTime);
				handTime = nil;
				--执行战斗结束
				SpriteDamagePool:RemoveNumActionList();
				SpriteSkillBufferPool:RemoveAllBuffer();
				SpriteArmaturePool:RemoveAllArmature();
				-- 清除没用的缓存
				CCTextureCache:sharedTextureCache():removeUnusedTextures();
				
				if m_IsReadFile then
					local battleStr = FileOperate:ReadFromFile(m_battleStr, "r", "*a");
					p:ParsingBattle(battleStr);
				end
				cclog("战斗结束----");
				--]]
			end
		end
		
		if #m_RoundDate > 0 then
			local tMessage = m_RoundDate[1];
			p:assemblyFight(tMessage);
			table.remove(m_RoundDate,1);
		end
		-- SpriteArmaturePool.ReleaseArmature();
	end
end


-- 开始战斗
function p:StartGameFight()
	Scheduler.scheduleGlobal(p.schedulerFunc, 0);
end

-- 队列轮询定时器
function p:schedulerFunc()	
	
	-- 1:动作池
	local tAction = SpriteActionPool:PushOutActionFromQueue();
	if tAction ~= nil then
		SpriteActionPool:RunActionParsing(tAction)
	end
	
	-- 2:场景粒子特效池(技能显示)
	local tEffect = SceneSkillEffectPool:PushOutEffectFromQueue();
	if tEffect ~= nil then
		SceneSkillEffectPool:ShowEffect(tEffect)
	end
	
	-- 3:英雄伤害显示
	local tDamage = SpriteDamagePool:PushOutActionFromQueue()
	if tDamage ~= nil then
		SpriteDamagePool:ShowDamageHurt(tDamage);
	end
	
	-- 4:英雄buff状态显示
	local tBuffer = SpriteSkillBufferPool:PushOutBufferFromQueue();
	if tBuffer ~= nil then
		SpriteSkillBufferPool:BufferParsing(tBuffer);
	end
	
	-- 5:由于英雄的技能产生的位移
	local tPerform = SkillActionPerform:PushOutActionFromQueue()
	if tPerform ~= nil then
		SkillActionPerform:RunPerformAction(tPerform);
	end
	
	-- 6:技能释放前的蓄力表现
	local tStorageEffect = SkillDoReleaseBefore:PushOutStorageFromQueue()
	if tStorageEffect ~= nil then
		SkillDoReleaseBefore:ShowStorageEffect(tStorageEffect);
	end
	
end

--获取战斗的场景
function p:GetActiveLayer()
	return p.Layer;
end

-- 场景抖动
function p:LayerMoveAction()
	local array = CCArray:create();
	local pMove = CCMoveBy:create(0.02, ccp(0,-20));
	array:addObject(pMove);
	array:addObject(pMove:reverse());
	local pMove = CCMoveBy:create(0.03, ccp(10,10));
	array:addObject(pMove);
	array:addObject(pMove:reverse());
	local pMove = CCMoveBy:create(0.05, ccp(-8, 8));
	array:addObject(pMove);
	array:addObject(pMove:reverse());
	
	local pAction = CCSequence:create(array);	
	p.Layer:runAction(pAction);
end

-- 场景变灰度
function p:ShowGrayLayer()
	if p.GrayLayer == nil then
		p.GrayLayer = CCLayerColor:create(ccc4(0, 0, 0, 125), 640, 960);
		p.Layer:addChild(p.GrayLayer,0);
	end
	local array = CCArray:create();
	array:addObject(CCShow:create());
	
	array:addObject(CCFadeTo:create(0.4, 150));
	array:addObject(CCDelayTime:create(0.6));
	array:addObject(CCFadeTo:create(0.4, 0));
	array:addObject(CCHide:create());
	local pAction = CCSequence:create(array);	
	p.GrayLayer:runAction(pAction);
end

--初始化精灵
function p:InitBattleSpite(tSpite, bIsEnemy, xOffset, yOffset)
	local nSprite = #tSpite;
	for nIndex=1,nSprite do
		local pos = nil;
		if not bIsEnemy then
			pos = p:GetAttackPostion(nIndex , nSprite, bIsEnemy, xOffset, yOffset);
		else
			pos = p:GetBeAttackPostion(nIndex , nSprite, bIsEnemy, xOffset, yOffset);
		end
		
		local spriteName = nil;
		local spriteWearing = nil;
		local weapIng = nil;
		
		if tSpite[nIndex].nRace < 35000 then
			--角色
			spriteName = CfgData["cfg_race"][tSpite[nIndex].nRace]["armture"];
			spriteWearing = CfgData["cfg_profession"][tSpite[nIndex].nRole]["wear"];
			weapIng = tSpite[nIndex].nWeap;
		else
			--怪物
			spriteName = CfgData["cgf_monster"][tSpite[nIndex].nRace]["armture"];
			spriteWearing = CfgData["cgf_monster"][tSpite[nIndex].nRace]["wear"];
			weapIng = CfgData["cgf_monster"][tSpite[nIndex].nRace]["weap"];
		end
		SpriteArmaturePool:CreateArmature(tSpite[nIndex].nId, spriteName, weapIng, spriteWearing, tSpite[nIndex].IsEnemy, "move", pos, tSpite[nIndex].nMaxHp);
	end
end

--站位初始化函数
--***********************************************************************
--攻击方
function p:GetAttackPostion(nIndex , nMaxCount, bIsEnemy, xOffset, yOffset)
	local winSize = CCDirector:sharedDirector():getWinSize();
	if nMaxCount == 1 then
		return ccp(winSize.width*4/18+xOffset, winSize.height*2/16+yOffset)
	elseif nMaxCount == 2 then
		if nIndex==1 then
			return ccp(winSize.width*4/18+xOffset, winSize.height*3/16+yOffset)
		elseif nIndex==2 then
			return ccp(winSize.width*3/18+xOffset, winSize.height*1/16+yOffset)
		end
	elseif nMaxCount == 3 then
		if nIndex==1 then
			return ccp(winSize.width*5/36+xOffset, winSize.height*7/32+yOffset)
		elseif nIndex==2 then
			return ccp(winSize.width*10/36+xOffset, winSize.height*4/32+yOffset)
		elseif nIndex==3 then
			return ccp(winSize.width*6/36+xOffset, winSize.height*1/32+yOffset)
		end
	elseif nMaxCount == 4 then
		if nIndex==1 then
			return ccp(winSize.width*6/36+xOffset, winSize.height*8/32+yOffset)
		elseif nIndex==2 then
			return ccp(winSize.width*11/36+xOffset, winSize.height*6/32+yOffset)
		elseif nIndex==3 then
			return ccp(winSize.width*5/36+xOffset, winSize.height*3/32+yOffset)
		elseif nIndex==4 then
			return ccp(winSize.width*9/36+xOffset, winSize.height*1/64+yOffset)
		end
	end
	return ccp(winSize.width*4/18+xOffset, winSize.height*3/16+yOffset)
end

--被击方
function p:GetBeAttackPostion(nIndex , nMaxCount, bIsEnemy, xOffset, yOffset)
	local winSize = CCDirector:sharedDirector():getWinSize();
	if nMaxCount == 1 then
		return ccp(winSize.width*14/18+xOffset, winSize.height*2/16+yOffset)
	elseif nMaxCount == 2 then
		if nIndex==1 then
			return ccp(winSize.width*14/18+xOffset, winSize.height*3/16+yOffset)
		elseif nIndex==2 then
			return ccp(winSize.width*15/18+xOffset, winSize.height*1/16+yOffset)
		end
	elseif nMaxCount == 3 then
		if nIndex==1 then
			return ccp(winSize.width*31/36+xOffset, winSize.height*7/32+yOffset)
		elseif nIndex==2 then
			return ccp(winSize.width*26/36+xOffset, winSize.height*4/32+yOffset)
		elseif nIndex==3 then
			return ccp(winSize.width*30/36+xOffset, winSize.height*1/32+yOffset)
		end
	elseif nMaxCount == 4 then
		if nIndex==1 then
			return ccp(winSize.width*31/36+xOffset, winSize.height*8/32+yOffset)
		elseif nIndex==2 then
			return ccp(winSize.width*26/36+xOffset, winSize.height*6/32+yOffset)
		elseif nIndex==3 then
			return ccp(winSize.width*31/36+xOffset, winSize.height*3/32+yOffset)
		elseif nIndex==4 then
			return ccp(winSize.width*25/36+xOffset, winSize.height*1/32+yOffset)
		end
	end
	return ccp(winSize.width*14/18+xOffset, winSize.height*2/16+yOffset);
end







