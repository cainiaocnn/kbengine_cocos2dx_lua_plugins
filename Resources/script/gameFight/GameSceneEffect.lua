--战斗场景特效
GameSceneEffect = {};
local p = GameSceneEffect;

--
local m_MapID = nil;
local m_TimerHandleList = {};
-- 特效允许加的下标为
-- 990~999, 1001~1009

-- 层次Tag说明:
--[[
滚动层
10000~10001 后层 Zorder(0~1)
10002~10003 中层 Zorder(5)
10009~10010 中上层 Zorder(10)
10004~10005 前层 Zorder(1000)

固定层
10006			Zorder(999)
10007			Zorder(1001)
10008			Zorder(2)
10011			Zorder(6)
--]]

--账号注销回调函数
function p.gameLoginOut()
	m_MapID = nil;
	m_TimerHandleList = {};
end


-- 启动特效显示
function p.StartGameEffect(nMapId)
	
	m_MapID = nMapId;
	p.RemoveAllTimer();
	if nMapId == 1 then
		p.SceneEffect_1();
	elseif nMapId == 2 then
		p.SceneEffect_2();
	elseif nMapId == 3 then
		p.SceneEffect_3();
	elseif nMapId == 4 then
		p.SceneEffect_4();
	elseif nMapId == 5 then
		p.SceneEffect_5();		
	elseif nMapId == 6 then
		p.SceneEffect_6();
	elseif nMapId == 7 then
		p.SceneEffect_7();
	elseif nMapId == 8 then	
		p.SceneEffect_8();
	end
end

-- 删除所有定时器
function p.RemoveAllTimer()
	for i,v in ipairs(m_TimerHandleList) do
		if CheckP(v) then
			-- v:removeAllChildrenWithCleanup(true);
			v:setVisible(false);
			v:removeFromParentAndCleanup(true);
		elseif CheckN(v) then
			Scheduler.unscheduleGlobal(v);
		else
			cclog("***战斗场景特效异常,严重错误***");
		end
	end
	m_TimerHandleList = nil;
	m_TimerHandleList = {};
	
	local pLayer = GameFightCenter:GetActiveLayer();
	if pLayer ~= nil then
		for index = 10000, 10011 do
			local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
			if pSprite ~= nil then
				pSprite:removeAllChildrenWithCleanup(true);
			end
		end
	end
end

-- 场景1特效
function p.SceneEffect_1()
	local pLayer = GameFightCenter:GetActiveLayer();
	----1
	local function func()
		for index = 10000, 10001 do
			local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
			if pSprite ~= nil then
				local emitter = CCParticleSystemQuad:create("sceneffect/Effectghpyflagplist001.plist");
				if emitter ~= nil then
					emitter:setPositionType(kCCPositionTypeGrouped);
					local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
					batch:addChild(emitter);
					local fScale = math.random(10,100)/100;
					batch:setScaleX(fScale);
					batch:setScaleY(fScale);
					local x = math.random(0, 1024);
					batch:setPosition(ccp(x,512));
					pSprite:addChild(batch, 0);
					batch:runAction(p.RemoveAndFadeAction(5));
				end
			end
		end
	end
	local nRand = math.random(2,4);
	local handle = Scheduler.scheduleGlobal(func, nRand);
	table.insert(m_TimerHandleList, handle);
	
	
	----2_1
	local function func()
		local pSprite = tolua.cast(pLayer:getChildByTag(10007), "CCSprite");
		if pSprite ~= nil then
			local tArmatureEffect = CreateArmatureEffect();
			local pEffect = tArmatureEffect:CreateEffectSprite("Effectghpysunshine", 1, true);
			if pEffect ~= nil then
				local x = math.random(0, 640);
				pEffect:setPosition(ccp(x,512));
				pSprite:addChild(pEffect, 1);
			else
				cclog("***显示一个骨骼(添加到精灵中)---");
			end
		end
	end
	local nRand = math.random(8,20);
	local handle = Scheduler.scheduleGlobal(func, nRand);
	table.insert(m_TimerHandleList, handle);
	
	----2_2
	local function func()
		for index=10002, 10003 do
			local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
			if pSprite ~= nil then
				local emitter = CCParticleSystemQuad:create("sceneffect/Effectghpybugplist.plist");
				if emitter ~= nil then
					emitter:setPositionType(kCCPositionTypeGrouped);
					local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
					batch:addChild(emitter);
					local x = math.random(0, 1024);
					batch:setPosition(ccp(x,340));
					pSprite:addChild(batch, 0);
					batch:runAction(p.RemoveAndFadeAction(10));
				end
			end
		end
	end
	local nRand = math.random(5,10);
	local handle = Scheduler.scheduleGlobal(func, nRand);
	table.insert(m_TimerHandleList, handle);
	
	--- 2_3
	local function func()
		local pSprite = tolua.cast(pLayer:getChildByTag(10007), "CCSprite");
		if pSprite ~= nil then
			local emitter = CCParticleSystemQuad:create("sceneffect/Effectghpyflagplist002.plist");
			if emitter ~= nil then
				emitter:setPositionType(kCCPositionTypeGrouped);
				-- local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
				local batch = CCNode:create();
				batch:addChild(emitter,0,0);
				local x = math.random(0, 640);
				batch:setPosition(ccp(x,512));
				pSprite:addChild(batch);
				batch:runAction(p.RemoveAndFadeAction(5));
			end
		end
	end
	local nRand = math.random(5,10);
	local handle = Scheduler.scheduleGlobal(func, nRand);
	table.insert(m_TimerHandleList, handle);
	
	----2_4
	local function func()
		for index=10004, 10005 do
			local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
			if pSprite ~= nil then
				local emitter = CCParticleSystemQuad:create("sceneffect/Effectghpybugplist.plist");
				if emitter ~= nil then
					emitter:setPositionType(kCCPositionTypeGrouped);
					local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
					batch:addChild(emitter);
					local x = math.random(0, 1024);
					batch:setPosition(ccp(x,0));
					pSprite:addChild(batch, 0);
					batch:runAction(p.RemoveAndFadeAction(10));
				end
			end
		end
	end
	local nRand = math.random(5,10);
	local handle = Scheduler.scheduleGlobal(func, nRand);
	table.insert(m_TimerHandleList, handle);
	
end

-- 场景2特效
function p.SceneEffect_2()
	local pLayer = GameFightCenter:GetActiveLayer();
	----1
	for index = 10000, 10001 do
		local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
		if pSprite ~= nil then
			local emitter = CCParticleSystemQuad:create("sceneffect/Effectghzcfogplist002.plist");
			if emitter ~= nil then
				local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
				batch:setScaleX(-1);
				batch:addChild(emitter);
				batch:setPosition(ccp(512,384));
				pSprite:addChild(batch, 0);
				table.insert(m_TimerHandleList, batch);
			end
		end
	end

	--
	----2_1
	local function func()
		local pSprite = tolua.cast(pLayer:getChildByTag(10006), "CCSprite");
		if pSprite ~= nil then
			local emitter = CCParticleSystemQuad:create("sceneffect/Effectghzcflagplist.plist");
			if emitter ~= nil then
				emitter:setPositionType(kCCPositionTypeGrouped);
				-- local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
				local batch = CCNode:create();
				batch:addChild(emitter,0,0);
				local y = math.random(128, 384);
				batch:setPosition(ccp(640,y));
				pSprite:addChild(batch);
				batch:runAction(p.RemoveAction(8));
			end
		end
	end
	local nRand = math.random(3,8);
	local handle = Scheduler.scheduleGlobal(func, nRand);
	table.insert(m_TimerHandleList, handle);
	----2_2
	local function func()
		local pSprite = tolua.cast(pLayer:getChildByTag(10006), "CCSprite");
		if pSprite ~= nil then
			local emitter = CCParticleSystemQuad:create("sceneffect/Effectghzcfogplist001.plist");
			if emitter ~= nil then
				emitter:setPositionType(kCCPositionTypeGrouped);
				-- local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
				local batch = CCNode:create();
				batch:addChild(emitter,0,0);
				local y = math.random(128, 384);
				batch:setPosition(ccp(640,y));
				pSprite:addChild(batch);
				batch:runAction(p.RemoveAction(2));
			end
		end
	end
	local nRand = math.random(4,10);
	local handle = Scheduler.scheduleGlobal(func, nRand);
	table.insert(m_TimerHandleList, handle);
end

-- 场景3特效
function p.SceneEffect_3()
	local pLayer = GameFightCenter:GetActiveLayer();
	local function func()
		local pSprite = tolua.cast(pLayer:getChildByTag(10007), "CCSprite");
		if pSprite ~= nil then
			
			local layer = CCLayerColor:create(ccc4(200,200,200,255), 640, 512);
			layer:setAnchorPoint(ccp(0,0))
			layer:setPosition(ccp(0,0));
			pSprite:addChild(layer);
			
			local array = CCArray:create();
			array:addObject(CCDelayTime:create(0.05));
			array:addObject(p.ColorFunc(layer,50,50,50));
			array:addObject(CCDelayTime:create(0.05));
			array:addObject(CCHide:create());
			array:addObject(CCDelayTime:create(0.05));
			array:addObject(CCShow:create());
			array:addObject(p.ColorFunc(layer,200,200,200));
			array:addObject(CCDelayTime:create(0.05));
			array:addObject(CCFadeOut:create(0.4));
			array:addObject(CCRemoveSelf:create(true));
			local pAction = CCSequence:create(array);
			layer:runAction(pAction);
		end
	end
	local nRand = math.random(8,30);
	local handle = Scheduler.scheduleGlobal(func, nRand);
	table.insert(m_TimerHandleList, handle);
	
	----2_1
	local pSprite = tolua.cast(pLayer:getChildByTag(10006), "CCSprite");
	if pSprite ~= nil then
		local emitter = CCParticleSystemQuad:create("sceneffect/Effectyaslrainplist001.plist");
		if emitter ~= nil then
			emitter:setPositionType(kCCPositionTypeGrouped);
			-- local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
			local batch = CCNode:create();
			batch:addChild(emitter,0,0);
			batch:setPosition(ccp(480,512));
			pSprite:addChild(batch);
		end
	end

	----2_3
	local pSprite = tolua.cast(pLayer:getChildByTag(10007), "CCSprite");
	if pSprite ~= nil then
		local emitter = CCParticleSystemQuad:create("sceneffect/Effectyaslrainplist004.plist");
		if emitter ~= nil then
			emitter:setPositionType(kCCPositionTypeGrouped);
			-- local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
			local batch = CCNode:create();
			batch:addChild(emitter,0,0);
			batch:setPosition(ccp(320,256));
			pSprite:addChild(batch);
		end
	end
	
	----2_3
	for index=10002, 10003 do
		local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
		if pSprite ~= nil then
			for i=1,2 do
				local emitter = CCParticleSystemQuad:create("sceneffect/Effectyaslrainplist002.plist");
				if emitter ~= nil then
					emitter:setPositionType(kCCPositionTypeGrouped);
					local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
					batch:addChild(emitter);
					batch:setPosition(ccp((i-1)*512,128));
					pSprite:addChild(batch, 0);
				end
			end
			for i=1,2 do
				local emitter = CCParticleSystemQuad:create("sceneffect/Effectyaslrainplist003.plist");
				if emitter ~= nil then
					emitter:setPositionType(kCCPositionTypeGrouped);
					local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
					batch:addChild(emitter);
					batch:setPosition(ccp((i-1)*512,128));
					pSprite:addChild(batch, 0);
				end
			end
		end
	end
	
	----2_4
	local function func1()
		for index=10002, 10003 do
			local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
			if pSprite ~= nil then
				local emitter = CCParticleSystemQuad:create("sceneffect/Effectyasllight001.plist");
				if emitter ~= nil then
					emitter:setPositionType(kCCPositionTypeGrouped);
					local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
					batch:addChild(emitter);
					local x = math.random(0, 1024);
					batch:setPosition(ccp(x,340));
					pSprite:addChild(batch, 0);
					batch:runAction(p.RemoveAndFadeAction(10));
				end
			end
		end
	end
	local nRand = math.random(2,5);
	local handle = Scheduler.scheduleGlobal(func1, nRand);
	table.insert(m_TimerHandleList, handle);
	
	----2_4
	local function func2()
		for index=10004, 10005 do
			local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
			if pSprite ~= nil then
				local emitter = CCParticleSystemQuad:create("sceneffect/Effectyasllight002.plist");
				if emitter ~= nil then
					emitter:setPositionType(kCCPositionTypeGrouped);
					local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
					batch:addChild(emitter);
					
					local fScale = math.random(100,150)/100;
					batch:setScaleX(fScale);
					batch:setScaleY(fScale);
					
					local x = math.random(0, 1024);
					batch:setPosition(ccp(x,30));
					pSprite:addChild(batch, 0);
					batch:runAction(p.RemoveAndFadeAction(10));
				end
			end
		end
	end
	local nRand = math.random(5,10);
	local handle = Scheduler.scheduleGlobal(func2, nRand);
	table.insert(m_TimerHandleList, handle);
end

-- 场景4特效
function p.SceneEffect_4()
	local pLayer = GameFightCenter:GetActiveLayer();
	
	for index = 10000, 10001 do
		local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
		if pSprite ~= nil then
			local emitter = CCParticleSystemQuad:create("sceneffect/EffectHotPlateauplist005.plist");
			if emitter ~= nil then
				emitter:setPositionType(kCCPositionTypeGrouped);
				local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
				batch:addChild(emitter);
				batch:setPosition(ccp(512,512));
				pSprite:addChild(batch, 0);
				table.insert(m_TimerHandleList, batch);
			end
		end
	end
	
	--最后层岩浆
	----2_1
	local function func()
		for index = 10000, 10001 do
			local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
			if pSprite ~= nil then
				local emitter = CCParticleSystemQuad:create("sceneffect/EffectHotPlateauplist004.plist");
				if emitter ~= nil then
					emitter:setPositionType(kCCPositionTypeGrouped);
					local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
					batch:addChild(emitter);

					local x = math.random(256, 768);
					batch:setPosition(ccp(x,256));
					pSprite:addChild(batch, 0);
					batch:runAction(p.RemoveAndFadeAction(5));
				end
			end
		end
	end
	local nRand = math.random(2,4);
	local handle = Scheduler.scheduleGlobal(func, nRand);
	table.insert(m_TimerHandleList, handle);
	
	--中层烟雾1
	----2_2
	local function func()
		for index=10002, 10003 do
			local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
			if pSprite ~= nil then
				local emitter = CCParticleSystemQuad:create("sceneffect/EffectHotPlateauplist001.plist");
				if emitter ~= nil then
					emitter:setPositionType(kCCPositionTypeGrouped);
					local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
					batch:addChild(emitter);
					batch:setPosition(ccp(86,420));
					pSprite:addChild(batch, 0);
					local fTime = math.random(4, 5);
					batch:runAction(p.RemoveAndFadeAction(fTime));
				end
			end
		end
	end
	local nRand = math.random(5,7);
	local handle = Scheduler.scheduleGlobal(func, nRand);
	table.insert(m_TimerHandleList, handle);

	--中层烟雾2
	----2_2
	local function func()
		for index=10002, 10003 do
			local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
			if pSprite ~= nil then
				local emitter = CCParticleSystemQuad:create("sceneffect/EffectHotPlateauplist002.plist");
				if emitter ~= nil then
					emitter:setPositionType(kCCPositionTypeGrouped);
					local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
					batch:addChild(emitter);
					batch:setPosition(ccp(200,410));
					pSprite:addChild(batch, 0);
					local fTime = math.random(4, 5);
					batch:runAction(p.RemoveAndFadeAction(fTime));
				end
			end
		end
	end
	local nRand = math.random(5,7);
	local handle = Scheduler.scheduleGlobal(func, nRand);
	table.insert(m_TimerHandleList, handle);
	
	--最前层的烟雾
	----2_4
	local function func()
		for index=10004, 10005 do
			local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
			if pSprite ~= nil then
				local emitter = CCParticleSystemQuad:create("sceneffect/EffectHotPlateauplist002.plist");
				if emitter ~= nil then
					emitter:setPositionType(kCCPositionTypeGrouped);
					local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
					batch:addChild(emitter);
					batch:setPosition(ccp(400,95));
					pSprite:addChild(batch, 0);
					local fTime = math.random(4, 5);
					batch:runAction(p.RemoveAndFadeAction(fTime));
				end
			end
		end
	end
	local nRand = math.random(5,7);
	local handle = Scheduler.scheduleGlobal(func, nRand);
	table.insert(m_TimerHandleList, handle);
	--]]
end

-- 场景5特效
function p.SceneEffect_5()
	local pLayer = GameFightCenter:GetActiveLayer();
	--
	--最后层薄雾层
	for index = 10000, 10001 do
		local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
		if pSprite ~= nil then
			local emitter = CCParticleSystemQuad:create("sceneffect/EffectCorruptionswampplist001.plist");
			if emitter ~= nil then
				local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
				batch:setScaleX(-1);
				batch:addChild(emitter);
				batch:setPosition(ccp(512,354));
				pSprite:addChild(batch, 1);
			end
		end
	end
	local function func()
		for index=10000, 10001 do
			local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
			if pSprite ~= nil then
				local emitter = CCParticleSystemQuad:create("sceneffect/EffectCorruptionswampplist004.plist");
				if emitter ~= nil then
					emitter:setPositionType(kCCPositionTypeGrouped);
					local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
					batch:addChild(emitter);
					local x = math.random(128, 896);
					batch:setPosition(ccp(x,366));
					pSprite:addChild(batch, 0);
					batch:runAction(p.RemoveAndFadeAction(2));
				end
			end
		end
	end
	local nRand = math.random(2,3);
	local handle = Scheduler.scheduleGlobal(func, nRand);
	table.insert(m_TimerHandleList, handle);

	
	--中层眼睛
	for index=10002, 10003 do
		local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
		if pSprite ~= nil then
			local tArmatureEffect = CreateArmatureEffect();
			local pEffect = tArmatureEffect:CreateEffectSprite("EffectCorruptionswamp002", 1, false);
			if pEffect ~= nil then
				pEffect:setPosition(ccp(650,370));
				pSprite:addChild(pEffect, 1);
			else
				cclog("***显示一个骨骼(添加到精灵中)---");
			end
		end
	end
	
	--最前层泡泡
	local function func()
		for index=10004, 10005 do
			local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
			if pSprite ~= nil then
				local emitter = CCParticleSystemQuad:create("sceneffect/EffectCorruptionswampplist002.plist");
				if emitter ~= nil then
					emitter:setPositionType(kCCPositionTypeGrouped);
					local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
					batch:addChild(emitter);
					local x = math.random(256, 768);
					batch:setPosition(ccp(x,0));
					pSprite:addChild(batch, 0);
					batch:runAction(p.RemoveAndFadeAction(2));
				end
			end
		end
	end
	local nRand = math.random(3,6);
	local handle = Scheduler.scheduleGlobal(func, nRand);
	table.insert(m_TimerHandleList, handle);
	local function func()
		for index=10004, 10005 do
			local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
			if pSprite ~= nil then
				local emitter = CCParticleSystemQuad:create("sceneffect/EffectCorruptionswampplist003.plist");
				if emitter ~= nil then
					emitter:setPositionType(kCCPositionTypeGrouped);
					local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
					batch:addChild(emitter);
					local x = math.random(256, 768);
					batch:setPosition(ccp(x, -50));
					pSprite:addChild(batch, 0);
					batch:runAction(p.RemoveAndFadeAction(2));
				end
			end
		end
	end
	local nRand = math.random(3,6);
	local handle = Scheduler.scheduleGlobal(func, nRand);
	table.insert(m_TimerHandleList, handle);


	-----------------------------
	for index=10004, 10005 do
		local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
		if pSprite ~= nil then
			local tArmatureEffect = CreateArmatureEffect();
			local pEffect = tArmatureEffect:CreateEffectSprite("EffectCorruptionswamp001", 1, false);
			if pEffect ~= nil then
				pEffect:setPosition(ccp(512,256));
				pSprite:addChild(pEffect, 1);
			else
				cclog("***显示一个骨骼(添加到精灵中)---");
			end
		end
	end
	
end

-- 场景6特效
function p.SceneEffect_6()
	local pLayer = GameFightCenter:GetActiveLayer();
	--
	--最后层薄雾层
	for index = 10000, 10001 do
		local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
		if pSprite ~= nil then
			local emitter = CCParticleSystemQuad:create("sceneffect/EffectThedarkPalaceplist001.plist");
			if emitter ~= nil then
				local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
				batch:setScaleX(-1);
				batch:addChild(emitter);
				batch:setPosition(ccp(512,384));
				pSprite:addChild(batch);
			end
		end
	end
	
	--中层蓝色火焰
	----2_2	
	for index=10002, 10003 do
		local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
		if pSprite ~= nil then
			local emitter = CCParticleSystemQuad:create("sceneffect/EffectThedarkPalaceplist002.plist");
			if emitter ~= nil then
				emitter:setPositionType(kCCPositionTypeGrouped);
				local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
				batch:addChild(emitter);
				batch:setPosition(ccp(509,468));
				pSprite:addChild(batch, 0);
			end
			--
			local emitter = CCParticleSystemQuad:create("sceneffect/EffectThedarkPalaceplist002.plist");
			if emitter ~= nil then
				emitter:setPositionType(kCCPositionTypeGrouped);
				local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
				batch:addChild(emitter);
				batch:setPosition(ccp(919,468));
				pSprite:addChild(batch, 0);	
			end
		end
	end
		
	local function func()
		for index=10002, 10003 do
			local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
			if pSprite ~= nil then
				local emitter = CCParticleSystemQuad:create("sceneffect/EffectThedarkPalaceplist003.plist");
				if emitter ~= nil then
					emitter:setPositionType(kCCPositionTypeGrouped);
					local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
					batch:addChild(emitter,0,0);
					local x = math.random(256, 768);
					batch:setPosition(ccp(x, 580));
					pSprite:addChild(batch);
					batch:runAction(p.RemoveAction(1.5));
				end
			end
		end
	end
	local nRand = math.random(3,7);
	local handle = Scheduler.scheduleGlobal(func, nRand);
	table.insert(m_TimerHandleList, handle);
	
	local function func()
		for index=10002, 10003 do
			local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
			if pSprite ~= nil then
				local emitter = CCParticleSystemQuad:create("sceneffect/EffectThedarkPalaceplist004.plist");
				if emitter ~= nil then
					emitter:setPositionType(kCCPositionTypeGrouped);
					local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
					batch:addChild(emitter,0,0);
					local x = math.random(256, 768);
					batch:setPosition(ccp(x, 550));
					pSprite:addChild(batch);
					batch:runAction(p.RemoveAction(1.5));
				end
			end
		end
	end
	local nRand = math.random(2,4);
	local handle = Scheduler.scheduleGlobal(func, nRand);
	table.insert(m_TimerHandleList, handle);
	
	--
	local pSprite = tolua.cast(pLayer:getChildByTag(10008), "CCSprite");
	if pSprite ~= nil then
		local tArmatureEffect = CreateArmatureEffect();
		local pEffect = tArmatureEffect:CreateEffectSprite("EffectEyesofthewatcher", 1, false);
		if pEffect ~= nil then
			pEffect:setPosition(ccp(320,422));
			pSprite:addChild(pEffect, 1);
		else
			cclog("***显示一个骨骼(添加到精灵中)---");
		end
	end
	
end

-- 场景7特效
function p.SceneEffect_7()
	
	local pLayer = GameFightCenter:GetActiveLayer();
	----1
	for index = 10000, 10001 do
		local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
		if pSprite ~= nil then
			local emitter = CCParticleSystemQuad:create("sceneffect/Effectghzcfogplist002.plist");
			if emitter ~= nil then
				local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
				batch:setScaleX(-1);
				batch:addChild(emitter);
				batch:setPosition(ccp(512,384));
				pSprite:addChild(batch, 0);
				table.insert(m_TimerHandleList, batch);
			end
		end
	end

	--
	----2_1
	local function func()
		local pSprite = tolua.cast(pLayer:getChildByTag(10006), "CCSprite");
		if pSprite ~= nil then
			local emitter = CCParticleSystemQuad:create("sceneffect/Effectghzcflagplist.plist");
			if emitter ~= nil then
				emitter:setPositionType(kCCPositionTypeGrouped);
				local batch = CCNode:create();
				batch:addChild(emitter,0,0);
				local y = math.random(128, 384);
				batch:setPosition(ccp(640,y));
				pSprite:addChild(batch);
				batch:runAction(p.RemoveAction(8));
			end
		end
	end
	local nRand = math.random(3,8);
	local handle = Scheduler.scheduleGlobal(func, nRand);
	table.insert(m_TimerHandleList, handle);
	
	----2_2
	local function func()
		local pSprite = tolua.cast(pLayer:getChildByTag(10006), "CCSprite");
		if pSprite ~= nil then
			local emitter = CCParticleSystemQuad:create("sceneffect/Effectghzcfogplist001.plist");
			if emitter~= nil then
				emitter:setPositionType(kCCPositionTypeGrouped);
				local batch = CCNode:create();
				batch:addChild(emitter,0,0);
				local y = math.random(128, 384);
				batch:setPosition(ccp(640,y));
				pSprite:addChild(batch);
				batch:runAction(p.RemoveAction(2));
			end
		end
	end
	local nRand = math.random(4,10);
	local handle = Scheduler.scheduleGlobal(func, nRand);
	table.insert(m_TimerHandleList, handle);
	
	

end

-- 场景8特效
function p.SceneEffect_8()
	
	local pLayer = GameFightCenter:GetActiveLayer();
		
	----2_1
	local pSprite = tolua.cast(pLayer:getChildByTag(10006), "CCSprite");
	if pSprite ~= nil then
		local emitter = CCParticleSystemQuad:create("sceneffect/EffectThefrozencoastplist003.plist");
		if emitter ~= nil then
			emitter:setPositionType(kCCPositionTypeGrouped);
			local batch = CCNode:create();
			batch:addChild(emitter,0,0);
			batch:setPosition(ccp(480,562));
			pSprite:addChild(batch);
		end
		emitter = CCParticleSystemQuad:create("sceneffect/EffectThefrozencoastplist002.plist");
		if emitter ~= nil then
			emitter:setPositionType(kCCPositionTypeGrouped);
			local batch = CCNode:create();
			batch:addChild(emitter,0,0);
			batch:setPosition(ccp(480,512));
			pSprite:addChild(batch);
		end
	end

	--
	local pSprite = tolua.cast(pLayer:getChildByTag(10008), "CCSprite");
	if pSprite ~= nil then
		local emitter = CCParticleSystemQuad:create("sceneffect/EffectThefrozencoastplist001.plist");
		if emitter ~= nil then
			emitter:setPositionType(kCCPositionTypeGrouped);
			local batch = CCNode:create();
			batch:addChild(emitter,0,0);
			batch:setPosition(ccp(480,512));
			pSprite:addChild(batch);
		end
	end
	
	local pSprite = tolua.cast(pLayer:getChildByTag(10011), "CCSprite");
	if pSprite ~= nil then
		local tArmatureEffect = CreateArmatureEffect();
		local pEffect = tArmatureEffect:CreateEffectSprite("Thefrozencoastseamonster", 1, false);
		if pEffect ~= nil then
			pEffect:setPosition(ccp(320,337));
			pSprite:addChild(pEffect, 1);
		else
			cclog("***显示一个骨骼(添加到精灵中)---");
		end
	end
	
	local function func()
		for index=10009, 10010 do
			local pSprite = tolua.cast(pLayer:getChildByTag(index), "CCSprite");
			if pSprite ~= nil then

				local emitter = CCParticleSystemQuad:create("sceneffect/EffectThefrozencoastplist004.plist");
				if emitter ~= nil then
					emitter:setPositionType(kCCPositionTypeGrouped);
					local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
					batch:addChild(emitter,0,0);
					local x = math.random(256, 768);
					batch:setPosition(ccp(x, 64));
					pSprite:addChild(batch, -1);
					batch:runAction(p.RemoveAction(1.5));
				end
				
				local emitter = CCParticleSystemQuad:create("sceneffect/EffectThefrozencoastplist005.plist");
				if emitter ~= nil then
					emitter:setPositionType(kCCPositionTypeGrouped);
					local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
					batch:addChild(emitter,0,0);
					local x = math.random(256, 768);
					batch:setPosition(ccp(x, 0));
					pSprite:addChild(batch, -1);
					batch:runAction(p.RemoveAction(1.5));
				end
			end
		end
	end
	local nRand = math.random(2,4);
	local handle = Scheduler.scheduleGlobal(func, nRand);
	table.insert(m_TimerHandleList, handle);
		
end

---------------------------------------------
function p.RemoveAction(fTime)
	local array = CCArray:create();
	array:addObject(CCDelayTime:create(fTime));
	array:addObject(CCRemoveSelf:create(true));
	local pAction = CCSequence:create(array);
	return pAction;
end

function p.RemoveAndFadeAction(fTime)
	local array = CCArray:create();
	array:addObject(CCDelayTime:create(fTime));
	array:addObject(CCFadeOut:create(0.8));
	array:addObject(CCRemoveSelf:create(true));
	local pAction = CCSequence:create(array);
	return pAction;
end

function p.ColorFunc(pNode,r,g,b)
	local function func()
		pNode:setColor(ccc3(r,g,b));
	end
	return CCCallFunc:create(func);
end

return p;