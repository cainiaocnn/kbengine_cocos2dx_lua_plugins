-- 战斗精灵管理器
SpriteArmaturePool = {};
local t = SpriteArmaturePool;

--精灵放置容器
local m_tSpriteArmature = {};
local m_ReleasArmatureList = {};
-- (战斗中显示的骨骼精灵添加到层中的启始)
-- (0~100是添加的范围)
local m_nSpriteArmature = 11;

local _batchNode = nil;--CCBatchNode:create()

--账号注销回调函数
function t.gameLoginOut()
	m_tSpriteArmature = {};
	m_ReleasArmatureList = {};
	m_nSpriteArmature = 11;
	_batchNode = nil;
end

-- 创建一个精灵并且加入到管理器中
function t:CreateArmature(nArmatureTag, spriteName, nEquipId, spriteWearing, bFlipX, event, pos, nHp, bIsBoss, nSkillStoneId, nSkillStoneLv)

	local tSprite = CreateArmatureSprite();	
	if spriteName == "humanaction" then
		--人族(男)
		ArmatureSpriteShap:SetShowIsHumanRace(tSprite);
	elseif spriteName == "Tieflingaction" then
		--人族(女)
		ArmatureSpriteShap:SetShowIsTiefling(tSprite);
	elseif spriteName == "monsterbone001" then
		--亡灵
		ArmatureSpriteShap:SetShowIsUnDeadRace(tSprite);
	elseif spriteName == "monsterbone002" then
		--老鼠类
		ArmatureSpriteShap:SetShowIsMouse(tSprite);
	elseif spriteName == "monsterbone003" then
		--哥布林
		ArmatureSpriteShap:SetShowIsGoblins(tSprite);
	elseif spriteName == "monsterbone004" then
		--蜘蛛或者蜘蛛女
		ArmatureSpriteShap:SetShowIsSpider(tSprite);
	elseif spriteName == "monsterbone005" then
		--元素
		ArmatureSpriteShap:SetShowIsElement(tSprite);
	elseif spriteName == "monsterbone006" then
		--铠甲战士
		ArmatureSpriteShap:SetShowIsArmorWarrior(tSprite);	
	elseif spriteName == "monsterbone007" then
		--烂泥怪
		ArmatureSpriteShap:SetShowIsMud(tSprite);
	elseif spriteName == "monsterbone008" then
		--蛇怪
		ArmatureSpriteShap:SetShowIsSnake(tSprite)
	elseif spriteName == "monsterbone009" then
		--牛头人
		ArmatureSpriteShap:SetShowIsTauren(tSprite);
	elseif spriteName == "monsterbone010" then
		--女妖
		ArmatureSpriteShap:SetShowIsBanshee(tSprite);
	elseif spriteName == "monsterbone011" then
		--巨魔
		ArmatureSpriteShap:SetShowIsTroll(tSprite);
	elseif spriteName == "monsterbone012" then
		--翼魔女
		ArmatureSpriteShap:SetShowIsWingSiren(tSprite);		
	elseif spriteName == "monsterbone013" then
		--恶魔
		ArmatureSpriteShap:SetShowIsDevil(tSprite);	
	elseif spriteName == "monsterbone015" then
		--龙
		ArmatureSpriteShap:SetShowIsDragon(tSprite);
	elseif spriteName == "monsterbone016" then
		--邪神
		ArmatureSpriteShap:SetShowIsDaal(tSprite);		
	end
	
	tSprite.ArmatrureHP = nHp;
	tSprite.IsEnemy = bFlipX;
	tSprite.SpriteTag = nArmatureTag;
	
	--创建骨骼精灵
	local armature = tSprite:CreateSprite(spriteName, spriteWearing);
	tSprite:SetPostion(pos);
	if bFlipX then
		tSprite:SetFlip(true, false);
	end
	--角色的武器类型
	local nWeapons = nil;
	local nWeapInx = nil;
	if spriteName == "humanaction" or spriteName == "Tieflingaction"  then
		--人族
		nWeapons, nWeapInx = ArmatureSpriteShap:HumanChangeToClienWT(nEquipId);
		--是否有宝石镶嵌
		if nWeapons > 0 and nSkillStoneId~= nil and nSkillStoneLv ~=nil then
			if nSkillStoneId ~=0 and nSkillStoneLv ~=0 then
				local effHead = CfgData["cfg_SkillStone"][nSkillStoneId]["effect"];
				if effHead ~= "a" and effHead ~= nil then
					local last = nSkillStoneLv%5;
					if last > 0 then
						last = math.floor(nSkillStoneLv/5)+1;
					else
						last = math.floor(nSkillStoneLv/5);
					end
					if last > 4 then
						last = 4;
						cclog("*********skillStone LV Error***********");
					end
					local strEffect   = effHead..tostring(last)
					tSprite:RemoveParticle("weaponsBaoShi", true);
					tSprite:AddWeaponEffect(nWeapons, strEffect, "weaponsBaoShi");
				end
			end
		end
		
	elseif spriteName == "monsterbone001" then
		--亡灵
		nWeapons, nWeapInx = ArmatureSpriteShap:UnDeadChangeToClienWT(nEquipId);
		if nWeapInx > 0 then
			cclog("***怪物%s不能用武器ID=%d换装:", tostring(spriteName), nEquipId)
		end
		nWeapInx = 0;
	elseif spriteName == "monsterbone002" then
		--老鼠类
		nWeapons, nWeapInx = ArmatureSpriteShap:MouseChangeToClienWT(nEquipId);	
		if nWeapInx > 0 then
			cclog("***怪物%s不能用武器ID=%d换装:", tostring(spriteName), nEquipId)
		end
		nWeapInx = 0;
	elseif spriteName == "monsterbone003" then
		--哥布林
		nWeapons, nWeapInx = ArmatureSpriteShap:GoblinsChangeToClienWT(nEquipId);
		if nWeapInx > 0 then
			cclog("***怪物%s不能用武器ID=%d换装:", tostring(spriteName), nEquipId)
		end
		nWeapInx = 0;
	elseif spriteName == "monsterbone004" then
		--蜘蛛或者蜘蛛女
		nWeapons, nWeapInx = ArmatureSpriteShap:SpiderChangeToClienWT(nEquipId);
		if nWeapInx > 0 then
			cclog("***怪物%s不能用武器ID=%d换装:", tostring(spriteName), nEquipId)
		end
		nWeapInx = 0;
	elseif spriteName == "monsterbone005" then
		--元素
		nWeapons, nWeapInx = ArmatureSpriteShap:ElementChangeToClienWT(nEquipId);
		if nWeapInx > 0 then
			cclog("***怪物%s不能用武器ID=%d换装:", tostring(spriteName), nEquipId)
		end
		nWeapInx = 0;
	elseif spriteName == "monsterbone006" then
		--铠甲战士
		nWeapons, nWeapInx = ArmatureSpriteShap:ArmorWarriorChangeToClienWT(nEquipId);
		if nWeapInx > 0 then
			cclog("***怪物%s不能用武器ID=%d换装:", tostring(spriteName), nEquipId)
		end
		nWeapInx = 0;
	elseif spriteName == "monsterbone007" then
		--烂泥怪
		nWeapons, nWeapInx = ArmatureSpriteShap:MudChangeToClienWT(nEquipId);
		if nWeapInx > 0 then
			cclog("***怪物%s不能用武器ID=%d换装:", tostring(spriteName), nEquipId)
		end
		nWeapInx = 0;
	elseif spriteName == "monsterbone008" then
		--蛇怪
		nWeapons, nWeapInx = ArmatureSpriteShap:SnakeChangeToClienWT(nEquipId);
		if nWeapInx > 0 then
			cclog("***怪物%s不能用武器ID=%d换装:", tostring(spriteName), nEquipId)
		end
		nWeapInx = 0;
	elseif spriteName == "monsterbone009" then
		--牛头人
		nWeapons, nWeapInx = ArmatureSpriteShap:TaurenChangeToClienWT(nEquipId);
		if nWeapInx > 0 then
			cclog("***怪物%s不能用武器ID=%d换装:", tostring(spriteName), nEquipId)
		end
		nWeapInx = 0;
	elseif spriteName == "monsterbone010" then
		--女妖
		nWeapons, nWeapInx = ArmatureSpriteShap:BansheeChangeToClienWT(nEquipId);
		if nWeapInx > 0 then
			cclog("***怪物%s不能用武器ID=%d换装:", tostring(spriteName), nEquipId)
		end
		nWeapInx = 0;
	elseif spriteName == "monsterbone011" then
		--巨魔
		nWeapons, nWeapInx = ArmatureSpriteShap:TrollChangeToClienWT(nEquipId);
		if nWeapInx > 0 then
			cclog("***怪物%s不能用武器ID=%d换装:", tostring(spriteName), nEquipId)
		end
		nWeapInx = 0;
	elseif spriteName == "monsterbone012" then
		--翼魔女
		nWeapons, nWeapInx = ArmatureSpriteShap:WingSirenChangeToClienWT(nEquipId);
		if nWeapInx > 0 then
			cclog("***怪物%s不能用武器ID=%d换装:", tostring(spriteName), nEquipId)
		end
		nWeapInx = 0;
	elseif spriteName == "monsterbone013" then
		--恶魔
		nWeapons, nWeapInx = ArmatureSpriteShap:DevilChangeToClienWT(nEquipId);	
		if nWeapInx > 0 then
			cclog("***怪物%s不能用武器ID=%d换装:", tostring(spriteName), nEquipId)
		end
		nWeapInx = 0;
	elseif spriteName == "monsterbone015" then
		--龙
		nWeapons, nWeapInx = ArmatureSpriteShap:DragonChangeToClienWT(nEquipId);
		if nWeapInx > 0 then
			cclog("***怪物%s不能用武器ID=%d换装:", tostring(spriteName), nEquipId)
		end
		nWeapInx = 0;
	elseif spriteName == "monsterbone016" then
		--邪神
		nWeapons, nWeapInx = ArmatureSpriteShap:DaalChangeToClienWT(nEquipId);
		if nWeapInx > 0 then
			cclog("***怪物%s不能用武器ID=%d换装:", tostring(spriteName), nEquipId)
		end
		nWeapInx = 0;
	end
	tSprite:WeaponModule(nWeapons, nWeapInx);
	

	
	--如果是Boss那么就放大
	if bIsBoss then
		tSprite:SetScale(1.3, 1.3);
	end
	--角色的状态机类型
	if spriteName == "humanaction" or spriteName == "Tieflingaction" then
		--人族状态机
		addHumanStateMachine(tSprite);
	elseif spriteName == "monsterbone001" then
		--亡灵状态机
		addUnDeadStateMachine(tSprite);
	elseif spriteName == "monsterbone002" then	
		--老鼠状态机
		addMouseStateMachine(tSprite)
	elseif spriteName == "monsterbone003" then
		--(哥布林)暂时用亡灵状态机
		addUnDeadStateMachine(tSprite);
	elseif spriteName == "monsterbone004" then
		--蜘蛛或者蜘蛛女状态机
		addSpiderStateMachine(tSprite);
	elseif spriteName == "monsterbone005" then
		--元素(暂时用亡灵状态机)
		addUnDeadStateMachine(tSprite);
	elseif spriteName == "monsterbone006" then
		--铠甲战士(暂时用亡灵状态机)
		addUnDeadStateMachine(tSprite);
	elseif spriteName == "monsterbone007" then
		--烂泥怪(暂时使用蜘蛛)
		addTaurenStateMachine(tSprite);
	elseif spriteName == "monsterbone008" then
		--蛇怪(暂时使用牛头人的)
		addTaurenStateMachine(tSprite);
	elseif spriteName == "monsterbone009" then
		--牛头人
		addTaurenStateMachine(tSprite);
	elseif spriteName == "monsterbone010" then
		--女妖(暂时使用牛头人的)
		addTaurenStateMachine(tSprite);		
	elseif spriteName == "monsterbone011" then
		--巨魔(暂时使用牛头人的)
		addTaurenStateMachine(tSprite);
	elseif spriteName == "monsterbone012" then
		--魔女
		addWingSirenStateMachine(tSprite);
	elseif spriteName == "monsterbone013" then
		--恶魔(暂时使用牛头人的)
		addTaurenStateMachine(tSprite);
	elseif spriteName == "monsterbone015" then
		--龙(暂时使用牛头人的)
		addTaurenStateMachine(tSprite);
	elseif spriteName == "monsterbone016" then
		--邪神
		addDaalStateMachine(tSprite);
	end
	tSprite.fsm:doEvent(event);
	--
	local pLayer = GameFightCenter:GetActiveLayer();
	if pLayer ~= nil then
		m_nSpriteArmature = m_nSpriteArmature + 1;
		pLayer:addChild(armature, m_nSpriteArmature);
		--
		tSprite.IsDeath = false;
		m_tSpriteArmature[tostring(nArmatureTag)] = {};
		m_tSpriteArmature[tostring(nArmatureTag)] = tSprite;
	else
		cclog("***严重错误,获取不到精灵要添加的层---");
	end
	
	armature:setZOrder(m_nSpriteArmature);
	--]]
	--[[
	if _batchNode == nil then
		 _batchNode = CCBatchNode:create();
		local pLayer = GameFightCenter:GetActiveLayer();
		if pLayer ~= nil then
			pLayer:addChild(_batchNode);
		end
	end
	_batchNode:addChild(armature);
	m_tSpriteArmature[tostring(nArmatureTag)] = {};
	m_tSpriteArmature[tostring(nArmatureTag)] = tSprite;
	--]]
end

-- 从管理器中删除一个精灵(死亡)
function t:RemoveArmature(nArmatureTag)
	if m_tSpriteArmature[tostring(nArmatureTag)] ~= nil then
		-- 从父节点删除该物体
		-- m_tSpriteArmature[tostring(nArmatureTag)].Sprite:removeFromParentAndCleanup(true);
		-- m_tSpriteArmature[tostring(nArmatureTag)].Sprite:setVisible(false);
		
		-- tSprite.IsDeath = false;
		m_tSpriteArmature[tostring(nArmatureTag)].IsDeath = true;
		
		-- table.insert(m_ReleasArmatureList, m_tSpriteArmature[tostring(nArmatureTag)].Sprite);
		-- m_tSpriteArmature[tostring(nArmatureTag)] = nil;
		-- m_nSpriteArmature = m_nSpriteArmature - 1;
	end
end

--用于播放胜利失败动作判断
function t:IsHumaction(spriteName)
	if spriteName == "humanaction" then
		return true;
	elseif spriteName == "Tieflingaction" then
		return true;
	end
	return false;
end

-- 从管理器中添加一个精灵(复活)
function t:AddArmature(nArmatureTag)
	if m_tSpriteArmature[tostring(nArmatureTag)] ~= nil then
		m_tSpriteArmature[tostring(nArmatureTag)].IsDeath = false;
	end
end

-- 获取一个精灵
function t:GetArmature(nArmatureTag)
	if m_tSpriteArmature[tostring(nArmatureTag)] ~= nil then
		if not (m_tSpriteArmature[tostring(nArmatureTag)].IsDeath) then
			return m_tSpriteArmature[tostring(nArmatureTag)];
		else
			if GameFightCenter:IsShowLog() then
				cclog("---精灵已经死亡了,获取失败了---");
			end
			return nil;
		end
	end
	cclog("***获取的精灵不在存储队列中---");
	return nil;
end

-- 获取一个精灵即使死亡也可以获取
function t:GetArmatureIgnoreDeath(nArmatureTag)
	if m_tSpriteArmature[tostring(nArmatureTag)] ~= nil then
		return m_tSpriteArmature[tostring(nArmatureTag)];
	end
	cclog("***获取忽略死亡精灵不在存储队列中---");
	return nil;
end

--战斗结束删除所有英雄
function t:RemoveAllArmature()
	
	for i,v in pairs(m_tSpriteArmature) do
		--下面这个接口导致安卓内存泄露请谨慎使用(IOS不会有问题)
		-- v.Sprite:removeAllChildrenWithCleanup(true);
		v.Sprite:removeFromParentAndCleanup(true);
	end
	m_tSpriteArmature = nil;
	m_nSpriteArmature = 10;
	m_tSpriteArmature = {};
end

-- 给所有精灵发送一个状态
function t:SetAllSpriteStateMachibe(sEvent)
	for i,v in pairs(m_tSpriteArmature) do
		v.fsm:doEvent(sEvent);
	end
end

-- 释放精灵
function t:ReleaseArmature()
	for i,v in pairs(m_ReleasArmatureList) do
		v:removeFromParentAndCleanup(true);
	end
	m_ReleasArmatureList = {};
	if GameFightCenter:IsShowLog() then
		cclog("---Release All Armature Success---");
	end
end

-- 获取队友精灵；列表
function t:GetFriendTeam()
	local tb = {};
	for k,v in pairs(m_tSpriteArmature) do
		if v.IsEnemy == false then
			table.insert(tb, tonumber(k));
		end
	end
	return tb;
end

-- 获取队友精灵；列表
function t:GetEnemyTeam()
	local tb = {};
	for k,v in pairs(m_tSpriteArmature) do
		if v.IsEnemy then
			table.insert(tb, tonumber(k));
		end
	end
	return tb;
end

-- 获取敌对精灵；列表
function t:GetRivalTeam(nArmatureTag)
	local tb = {};
	local tAttackArmture = m_tSpriteArmature[tostring(nArmatureTag)]
	if tAttackArmture ~= nil then
		for k,v in pairs(m_tSpriteArmature) do
			if v.IsEnemy ~= tAttackArmture.IsEnemy then
				table.insert(tb, tonumber(k));
			end
		end
	end
	return tb;
end

function t:GetSpriteArmature()
	return m_tSpriteArmature;
end

-- ***********************************************
--[[ Demo：

		创建一个骨骼角色
		
		local nRace = 1201 --人类(参见 cfg_race 配置表)
		local nRole = 1114 --游侠(参见 cfg_profession 配置表)
		local spriteName = CfgData["cfg_race"][nRace]["armture"];
		local spriteWearing = CfgData["cfg_profession"][.nRole]["wear"];
		local nEquipId = 31995;
		
		local tArmatureSprite = SpriteArmaturePool:CreateArmatureSpriteForGame(spriteName, nEquipId, spriteWearing, false, "normal", 1.0)
		-- 具体骨骼精灵指针是 tArmatureSprite.Sprite
		-- 可以直接使用 tArmatureSprite.Sprite 加入某个节点中间去

		--那么如果已经创建的了 tArmatureSprite 那么换装就如下即可
		tArmatureSprite:ChangeWearing(spriteName, spriteWearing);
		
--]]
-- 非战斗中角色创建
-- spriteName,  骨骼名称,如:humanaction、Tieflingaction
-- nEquipId, 	手上拿什么装备 如:
								--[[
								31995,"轻武器"
								31996,"中武器"
								31997,"重武器"
								31998,"远程武器"
								31999,"法杖武器"
								-]]
-- spriteWearing,  	穿什么套装
-- bFlipX, 		  	是否绕X翻转
-- strEvent 		默认执行状态机
-- fScale			缩放大小
--------------------------------------------------------
function t:CreateArmatureSpriteForGame(spriteName, nEquipId, spriteWearing, bFlipX, strEvent, fScale)

	local tSprite = CreateArmatureSprite();
	if spriteName == "humanaction" then
		--人族(男)
		ArmatureSpriteShap:SetShowIsHumanRace(tSprite);
	elseif spriteName == "Tieflingaction" then
		--人族(女)
		ArmatureSpriteShap:SetShowIsTiefling(tSprite);
	elseif spriteName == "monsterbone001" then
		--亡灵
		ArmatureSpriteShap:SetShowIsUnDeadRace(tSprite);
	elseif spriteName == "monsterbone002" then
		--老鼠类
		ArmatureSpriteShap:SetShowIsMouse(tSprite);
	elseif spriteName == "monsterbone003" then
		--哥布林
		ArmatureSpriteShap:SetShowIsGoblins(tSprite);
	elseif spriteName == "monsterbone004" then
		--蜘蛛或者蜘蛛女
		ArmatureSpriteShap:SetShowIsSpider(tSprite);
	elseif spriteName == "monsterbone005" then
		--元素
		ArmatureSpriteShap:SetShowIsElement(tSprite);
	elseif spriteName == "monsterbone007" then
		--烂泥怪
		ArmatureSpriteShap:SetShowIsMud(tSprite);
	elseif spriteName == "monsterbone008" then
		--蛇怪
		ArmatureSpriteShap:SetShowIsSnake(tSprite)
	elseif spriteName == "monsterbone009" then
		--牛头人
		ArmatureSpriteShap:SetShowIsTauren(tSprite);
	elseif spriteName == "monsterbone010" then
		--女妖
		ArmatureSpriteShap:SetShowIsBanshee(tSprite);
	elseif spriteName == "monsterbone011" then
		--巨魔
		ArmatureSpriteShap:SetShowIsTroll(tSprite);
	elseif spriteName == "monsterbone013" then
		--恶魔
		ArmatureSpriteShap:SetShowIsDevil(tSprite);	
	elseif spriteName == "monsterbone015" then
		--龙
		ArmatureSpriteShap:SetShowIsDragon(tSprite);
	elseif spriteName == "monsterbone016" then
		--邪神
		ArmatureSpriteShap:SetShowIsDaal(tSprite);		
	end
	
	tSprite.ArmatrureHP = nHp;
	tSprite.IsEnemy = bFlipX;
	tSprite.SpriteTag = nArmatureTag;
	
	--创建骨骼精灵
	local armature = tSprite:CreateSprite(spriteName, spriteWearing);
	if bFlipX then
		tSprite:SetFlip(true, false);
	end
	--角色的武器类型
	local nWeapons = nil;
	local nWeapInx = nil;
	if nEquipId ~= nil then

		if spriteName == "humanaction" or spriteName == "Tieflingaction"  then
			--人族
			nWeapons, nWeapInx = ArmatureSpriteShap:HumanChangeToClienWT(nEquipId);
		elseif spriteName == "monsterbone001" then
			--亡灵
			nWeapons, nWeapInx = ArmatureSpriteShap:UnDeadChangeToClienWT(nEquipId);
		elseif spriteName == "monsterbone002" then
			--老鼠类
			nWeapons, nWeapInx = ArmatureSpriteShap:MouseChangeToClienWT(nEquipId);	
		elseif spriteName == "monsterbone003" then
			--哥布林
			nWeapons, nWeapInx = ArmatureSpriteShap:GoblinsChangeToClienWT(nEquipId);
		elseif spriteName == "monsterbone004" then
			--蜘蛛或者蜘蛛女
			nWeapons, nWeapInx = ArmatureSpriteShap:SpiderChangeToClienWT(nEquipId);
		elseif spriteName == "monsterbone005" then
			--元素
			nWeapons, nWeapInx = ArmatureSpriteShap:ElementChangeToClienWT(nEquipId);
		elseif spriteName == "monsterbone007" then
			--烂泥怪
			nWeapons, nWeapInx = ArmatureSpriteShap:MudChangeToClienWT(nEquipId);
		elseif spriteName == "monsterbone008" then
			--蛇怪
			nWeapons, nWeapInx = ArmatureSpriteShap:SnakeChangeToClienWT(nEquipId);
		elseif spriteName == "monsterbone009" then
			--牛头人
			nWeapons, nWeapInx = ArmatureSpriteShap:TaurenChangeToClienWT(nEquipId);
		elseif spriteName == "monsterbone010" then
			--女妖
			nWeapons, nWeapInx = ArmatureSpriteShap:BansheeChangeToClienWT(nEquipId);
		elseif spriteName == "monsterbone011" then
			--巨魔
			nWeapons, nWeapInx = ArmatureSpriteShap:TrollChangeToClienWT(nEquipId);
		elseif spriteName == "monsterbone013" then
			--恶魔
			nWeapons, nWeapInx = ArmatureSpriteShap:DevilChangeToClienWT(nEquipId);	
		elseif spriteName == "monsterbone015" then
			--龙
			nWeapons, nWeapInx = ArmatureSpriteShap:DragonChangeToClienWT(nEquipId);
		elseif spriteName == "monsterbone016" then
			--邪神
			nWeapons, nWeapInx = ArmatureSpriteShap:DaalChangeToClienWT(nEquipId);
		end
	end
	tSprite:WeaponModule(nWeapons, nWeapInx);
	
	--如果是Boss那么就放大
	tSprite:SetScale(fScale, fScale);

	--角色的状态机类型
	if spriteName == "humanaction" or spriteName == "Tieflingaction" then
		--人族状态机
		addHumanStateMachine(tSprite);
	elseif spriteName == "monsterbone001" then
		--亡灵状态机
		addUnDeadStateMachine(tSprite);
	elseif spriteName == "monsterbone002" then	
		--老鼠状态机
		addMouseStateMachine(tSprite)
	elseif spriteName == "monsterbone003" then
		--(哥布林)暂时用亡灵状态机
		addUnDeadStateMachine(tSprite);
	elseif spriteName == "monsterbone004" then
		--蜘蛛或者蜘蛛女状态机
		addSpiderStateMachine(tSprite);
	elseif spriteName == "monsterbone005" then
		--元素(暂时用亡灵状态机)
		addUnDeadStateMachine(tSprite);
	elseif spriteName == "monsterbone007" then
		--烂泥怪(暂时使用蜘蛛)
		addTaurenStateMachine(tSprite);
	elseif spriteName == "monsterbone008" then
		--蛇怪(暂时使用牛头人的)
		addTaurenStateMachine(tSprite);
	elseif spriteName == "monsterbone009" then
		--牛头人
		addTaurenStateMachine(tSprite);
	elseif spriteName == "monsterbone010" then
		--女妖(暂时使用牛头人的)
		addTaurenStateMachine(tSprite);		
	elseif spriteName == "monsterbone011" then
		--巨魔(暂时使用牛头人的)
		addTaurenStateMachine(tSprite);
	elseif spriteName == "monsterbone013" then
		--恶魔(暂时使用牛头人的)
		addTaurenStateMachine(tSprite);
	elseif spriteName == "monsterbone015" then
		--龙(暂时使用牛头人的)
		addTaurenStateMachine(tSprite);
	elseif spriteName == "monsterbone016" then
		--邪神
		addDaalStateMachine(tSprite);
	end
	
	tSprite.fsm:doEvent(strEvent);
	--[[
	local pLayer = GameFightCenter:GetActiveLayer();
	if pLayer ~= nil then
		m_nSpriteArmature = m_nSpriteArmature + 1;
		pLayer:addChild(armature, m_nSpriteArmature);
		--
		tSprite.IsDeath = false;
		m_tSpriteArmature[tostring(nArmatureTag)] = {};
		m_tSpriteArmature[tostring(nArmatureTag)] = tSprite;
	else
		cclog("***严重错误,获取不到精灵要添加的层---");
	end
	--]]
	
	return tSprite;
end

return t;