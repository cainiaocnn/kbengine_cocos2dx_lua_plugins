
-- 给战斗精灵添加buffer表现效果
SpriteSkillBufferPool = {};
local t = SpriteSkillBufferPool;

-- 数据队列
local tBufferQueue = {};

-- 显示队列
local m_tBufferObject = {};

-- Hero Buffer Tag  = 10000
local m_tHeroBufferTag = 10000;

--账号注销回调函数
function t.gameLoginOut()
	tBufferQueue = {};
	m_tBufferObject = {};
	m_tHeroBufferTag = 10000;
end

--
BufferEnum = {
	PARTICLE_BUFFER 	= 1,		--显示粒子特效
	HP_BUFFER			= 2,		--显示血量
	REBIRTH_BUFFER		= 3,		--复活
	ARMATURE_BUFFER		= 4,		--显示骨骼Buff
	ACTION_BUFFER		= 5,		--Buff导致的Actoin(变大/变小)
	STATE_BUFFER		= 6,		--执行Debuff动作
};


function t:PushInBufferToQueue(tBuffer)
	table.insert(tBufferQueue, tBuffer);
end

-- 推出一个Buffer数据
function t:PushOutBufferFromQueue()
	if #tBufferQueue > 0 then
		local tBuffer = tBufferQueue[1];
		table.remove(tBufferQueue, 1);
		return tBuffer;
	end
	return nil;
end

-- 解析一个buffer
function t:BufferParsing(tBufferList)
	if tBufferList ~= nil  then
		for i,tBuffer in ipairs(tBufferList) do
			local eBuffer = tBuffer[1];
			if eBuffer == BufferEnum.PARTICLE_BUFFER then
				t:ShowParticleBuffer(tBuffer);		-- 粒子特效Buffer
			elseif eBuffer == BufferEnum.ARMATURE_BUFFER then 
				t:ShowArmatureBuffer(tBuffer);		-- 骨骼特效Buffer
			elseif eBuffer == BufferEnum.ACTION_BUFFER then 
				t:ShowActionBuffer(tBuffer);		-- 骨骼特效Buffer
			elseif eBuffer == BufferEnum.HP_BUFFER then
				t:ShowHpBuffer(tBuffer[2]);			-- 显示血量
			elseif eBuffer == BufferEnum.REBIRTH_BUFFER then
				t:HeroRebirth(tBuffer[2], tBuffer[3]);			-- 复活
			elseif eBuffer == BufferEnum.STATE_BUFFER then
				t:DoStateMachine(tBuffer);
			else
				cclog("***客户端SpriteBuffer数据组装错误---");
			end
		end
	else
		cclog("***解析一个Buffer出现错误,传入数据是空---");
	end
end

--判断是否存在Buff
function t:IsHaveBuff(nSpriteTag, nEffectID)
	local bufferKey = tostring(nEffectID).."_"..tostring(nSpriteTag);
	local tBufferInfo = m_tBufferObject[bufferKey];
	if tBufferInfo ~= nil then
		return true;
	end
	return false;
end

-- 移除英雄特效Buf
function t:RemoveBuffer(nSpriteTag, nEffectID)
	--英雄Tag 和bufferId 组合成
	local bufferKey = tostring(nEffectID).."_"..tostring(nSpriteTag);
	local tBufferInfo = m_tBufferObject[bufferKey];
	if tBufferInfo ~= nil then
		local nSpriteTag = tBufferInfo["TagParent"];
		--只有没有死亡的的英雄才能被允许删除
		local tSprite = SpriteArmaturePool:GetArmature(nSpriteTag);
		if  tSprite~= nil and tBufferInfo["Node"]~=nil then
			
			local nTag = tBufferInfo["BufferTag"];
			local nType= tBufferInfo["BufferType"];
			if nType == 0 then
				local pNode = tSprite.Sprite:getChildByTag(nTag);
				if pNode ~= nil then
					local pParticleBatchNode = tolua.cast(pNode, "CCParticleBatchNode");
					if pParticleBatchNode ~= nil then
						pParticleBatchNode:removeFromParentAndCleanup(true);
					end
				else
					cclog("**********RemoveBuffer Dure To No Have******");
				end
			elseif nType == 1 then
				local pNode = tSprite.Sprite:getChildByTag(nTag);
				if pNode ~= nil then
					local pArmature = tolua.cast(pNode, "CCArmature");
					if pArmature ~= nil then
						pArmature:removeFromParentAndCleanup(true);
					end
				else
					cclog("**********RemoveBuffer Dure To No Have******");
				end
			end
			-- tBufferInfo["Node"]:removeFromParentAndCleanup(true);
		end
		--清除数据
		m_tBufferObject[bufferKey] = nil;
		
		if GameFightCenter:IsShowLog() then
			cclog("~~~~~~移除BuffId=%d~~~~~~~",nEffectID);
		end
		
		--移除Buffer导致的Action
		SkillActionPerform:BufferLeadToAction(nSpriteTag, nEffectID, false);
	else
		cclog("---要移除的Buff,本身不存在英雄身上---");
	end
end

--移除英雄身上的所有buff
function t:RemoveSpriteAllBuffer(nSpriteTag)
	--英雄Tag 和bufferId 组合成
	for k, v in pairs(m_tBufferObject) do		
		local nValueSpriteTag = v["TagParent"];
		if nValueSpriteTag ~= nil then
			if tonumber(nValueSpriteTag) == nSpriteTag then
				--只有没有死亡的的英雄才能被允许删除
				local tSprite = SpriteArmaturePool:GetArmature(nSpriteTag)
				if tSprite ~= nil and v["Node"]~=nil then
					-- v["Node"]:removeFromParentAndCleanup(true);
					
					local nTag = v["BufferTag"];
					local nType= v["BufferType"];
					if nType == 0 then
						local pNode = tSprite.Sprite:getChildByTag(nTag);
						if pNode ~= nil then
							local pParticleBatchNode = tolua.cast(pNode, "CCParticleBatchNode");
							if pParticleBatchNode ~= nil then
								pParticleBatchNode:removeFromParentAndCleanup(true);
							end
						else
							cclog("**********RemoveBuffer Dure To No Have******");
						end
					elseif nType == 1 then
						local pNode = tSprite.Sprite:getChildByTag(nTag);
						if pNode ~= nil then
							local pArmature = tolua.cast(pNode, "CCArmature");
							if pArmature ~= nil then
								pArmature:removeFromParentAndCleanup(true);
							end
						else
							cclog("**********RemoveBuffer Dure To No Have******");
						end
					end
					
				end
				m_tBufferObject[k] = nil;
			end
		end
	end
end

-- 移除所有数据
function t:RemoveAllBuffer()
	for k,v in pairs(m_tBufferObject) do
		local tBufferInfo = v;
		if tBufferInfo["Node"] ~= nil then
			-- tBufferInfo["Node"]:removeFromParentAndCleanup(true);
			local nValueSpriteTag = v["TagParent"];
			local tSprite = SpriteArmaturePool:GetArmatureIgnoreDeath(nValueSpriteTag)
			if tSprite ~= nil and v["Node"]~=nil then
				-- v["Node"]:removeFromParentAndCleanup(true);
				
				local nTag = v["BufferTag"];
				local nType= v["BufferType"];
				if nType == 0 then
					local pNode = tSprite.Sprite:getChildByTag(nTag);
					if pNode ~= nil then
						local pParticleBatchNode = tolua.cast(pNode, "CCParticleBatchNode");
						if pParticleBatchNode ~= nil then
							pParticleBatchNode:removeFromParentAndCleanup(true);
						end
					else
						cclog("**********RemoveBuffer Dure To No Have******");
					end
				elseif nType == 1 then
					local pNode = tSprite.Sprite:getChildByTag(nTag);
					if pNode ~= nil then
						local pArmature = tolua.cast(pNode, "CCArmature");
						if pArmature ~= nil then
							pArmature:removeFromParentAndCleanup(true);
						end
					else
						cclog("**********RemoveBuffer Dure To No Have******");
					end
				end
			end
		end
	end
	m_tHeroBufferTag = 10000;
	m_tBufferObject = nil;
	m_tBufferObject = {};
end

--各种buffer处理
--------------------------------
-- 1:在角色身上显示或者移除粒子Buff
function t:ShowParticleBuffer(tBuffer)
	local nSpriteTag = tBuffer[2]; 	--显示buffer的英雄tag
	local effectID   = tBuffer[3]; 	--显示bufferID
	local roundTime	 = tBuffer[4];	--显示buffer添加数
	--------------
	local tArmatureSprite = SpriteArmaturePool:GetArmature(nSpriteTag);
	if tArmatureSprite ~= nil then
		--英雄Tag 和bufferId 组合成
		local bufferKey = tostring(effectID).."_"..tostring(nSpriteTag);
		--查找粒子显示对象并给予
		local tBufferInfo = m_tBufferObject[bufferKey];
		if tBufferInfo == nil then
			local effectName, nTime , nZorder = t:GetBufferNameAndTime(effectID);
			if effectName ~= nil and nTime ~= nil then
				if roundTime > 0 then
					local emitter = CCParticleSystemQuad:create(effectName);
					local batch = CCParticleBatchNode:createWithTexture(emitter:getTexture());
					batch:addChild(emitter);
					if tArmatureSprite.bFlipX then
						batch:setScaleX(-1);				
					end
					m_tHeroBufferTag = m_tHeroBufferTag + 1;
					tArmatureSprite.Sprite:addChild(batch, nZorder, m_tHeroBufferTag);
					-------------------------------------------
					tBufferInfo = {};
					tBufferInfo["Node"]  = batch;
					if roundTime ~= nil then
						tBufferInfo["Round"] = roundTime;
					else
						tBufferInfo["Round"] = nTime;
					end
					tBufferInfo["TagParent"] = nSpriteTag;
					tBufferInfo["BufferTag"]  = m_tHeroBufferTag;
					tBufferInfo["BufferType"] = 0;
					--Buffer导致的Action
					SkillActionPerform:BufferLeadToAction(nSpriteTag, effectID, true);
					
					if t:IsShowBuffer(effectID) then
						m_tBufferObject[bufferKey] = {};
						m_tBufferObject[bufferKey] = tBufferInfo;
					end
					
				else
					cclog("***服务器下发移除Buff不存在错误,严重错误 1 %d-----", effectID)
				end
			end
		else
			if roundTime ~= nil then
				if roundTime == -1 then
					t:RemoveBuffer(nSpriteTag, effectID);
				else
					-- cclog("*********Buffer显示增加错误***");
				end
				--[[
				tBufferInfo["Round"] = tBufferInfo["Round"] + roundTime;
				--判断是否次数?<0
				if tBufferInfo["Round"] <= 0 then
					--移除英雄特效Buf
					t:RemoveBuffer(nSpriteTag, effectID);
				end
				--]]
			else
				cclog("***客户端传入Buff添加次数的roundTime出现异常, 请检查数据---");
			end
		end
	end
end

-- 2:加血
function t:ShowHpBuffer(tDamage)
	if tDamage ~= nil then
		--加血数据显示
		SpriteDamagePool:PushInActionFromQueue(tDamage);
	end
end

-- 3:角色复活
function t:HeroRebirth(tRebith, nSkillId)
	if tRebith ~= nil then
		
		local nMainSpriteTag = tRebith[1][1];
		local nSpriteTag = tRebith[1][2];
		local nAddHp	 = tRebith[2];
		
		local tAttackSprite = SpriteArmaturePool:GetArmatureIgnoreDeath(nSpriteTag);
		if tAttackSprite ~= nil then
			--[[
			SpriteArmaturePool:AddArmature(nSpriteTag);
			--清除掉英雄死亡的Action
			tAttackSprite.Sprite:stopActionByTag(1000);
			local array = CCArray:create();			
			array:addObject(CCShow:create());
			array:addObject(CCFadeIn:create(0.8));--1.5
			local pAction = CCSequence:create(array);	
			tAttackSprite.Sprite:runAction(pAction);	
			--]]
			SpriteDamagePool:PushInActionFromQueue({{tRebith[1], nAddHp, HurtEnum.ADDHP_HURT, nSkillId}});
		else
			cclog("***角色复活失败---");
		end
	end
end

-- 4:在角色身上显示或者移除骨骼Buff
function t:ShowArmatureBuffer(tBuffer)

	local nSpriteTag = tBuffer[2]; 	--显示buffer的英雄tag
	local effectID   = tBuffer[3]; 	--显示bufferID
	local roundTime	 = tBuffer[4];	--显示buffer添加数
	--------------------------------------------------------
	local tShowArmature = nil;
	if t:IsIgnoreDeathBuff(effectID) then
		tShowArmature = SpriteArmaturePool:GetArmatureIgnoreDeath(nSpriteTag);
	else
		tShowArmature = SpriteArmaturePool:GetArmature(nSpriteTag);
	end
	if tShowArmature ~= nil then
		--英雄Tag 和bufferId 组合成
		local bufferKey = tostring(effectID).."_"..tostring(nSpriteTag);
		--查找粒子显示对象并给予
		local tBufferInfo = m_tBufferObject[bufferKey];
		if tBufferInfo == nil then
			local effectName, nTime , nTag = t:GetBufferNameAndTime(effectID);
			if effectName ~= nil and nTime ~= nil then
				if roundTime > 0 then
					local tArmatureEffect = CreateArmatureEffect();
					
					local bLoop = 1;
					if not t:IsShowBuffer(effectID) then
						bLoop =  0;
					end
					
					local pEffect = tArmatureEffect:CreateEffectSprite(effectName, bLoop, false);
					if pEffect ~= nil then
						tShowArmature:AddArmatureEffect(tArmatureEffect);
						-- local nTag = tShowArmature:AddArmatureEffect(tArmatureEffect);
						-- tArmatureEffect:SetAutoInfo(tShowArmature.RemoveArmatureEffect, nTag);
						-------------------------------------------
						if tShowArmature.bFlipX then
							-- tArmatureEffect:SetFlip(true, false);
						end
						m_tHeroBufferTag = m_tHeroBufferTag + 1;
						pEffect:setTag(m_tHeroBufferTag);
						
						
						tBufferInfo = {};
						tBufferInfo["Node"]  = pEffect;
						if roundTime ~= nil then
							tBufferInfo["Round"] = roundTime;
						else
							tBufferInfo["Round"] = nTime;
						end
						tBufferInfo["TagParent"] = nSpriteTag;
						
						tBufferInfo["BufferTag"]  = m_tHeroBufferTag;
						tBufferInfo["BufferType"] = 1;
						
						--Buffer导致的Action
						SkillActionPerform:BufferLeadToAction(nSpriteTag, effectID, true);
						if t:IsShowBuffer(effectID) then
							m_tBufferObject[bufferKey] = {};
							m_tBufferObject[bufferKey] = tBufferInfo;
						end
					end
				else
					cclog("***服务端删除了一个不存在的骨骼Buffer---");
				end
			else
				cclog("***显示一个骨骼Buffer错误,由于客户端(GetBufferNameAndTime)找不到配置---");
			end
		else
			if roundTime ~= nil then
				if roundTime == -1 then
					t:RemoveBuffer(nSpriteTag, effectID);
				else
					-- cclog("*********Buffer显示增加错误***");
				end
				--[[
				tBufferInfo["Round"] = tBufferInfo["Round"] + roundTime;
				if tBufferInfo["Round"] <= 0 then
					--移除英雄特效Buf
					t:RemoveBuffer(nSpriteTag, effectID);
				end
				--]]
			else
				cclog("***客户端传入Buff添加次数的roundTime出现异常, 请检查数据---");
			end
		end
	else
		cclog("***显示一个骨骼Buffer错误:%s---", tostring(nSpriteTag));
		cclog("***显示一个骨骼Buffer错误:%s---", tostring(effectID));
	end
end

-- 5:带有Action的Buff
function t:ShowActionBuffer(tBuffer)
	local nSpriteTag = tBuffer[2]; 	--显示buffer的英雄tag
	local effectID   = tBuffer[3]; 	--显示bufferID
	local roundTime	 = tBuffer[4];	--显示buffer添加数
	--------------
	local tArmatureSprite = nil;
	if t:IsIgnoreDeathBuff(effectID) then
		tArmatureSprite = SpriteArmaturePool:GetArmatureIgnoreDeath(nSpriteTag);
	else
		tArmatureSprite = SpriteArmaturePool:GetArmature(nSpriteTag);
	end
	if tArmatureSprite ~= nil then
		--英雄Tag 和bufferId 组合成
		local bufferKey = tostring(effectID).."_"..tostring(nSpriteTag);
		--查找粒子显示对象并给予
		local tBufferInfo = m_tBufferObject[bufferKey];
		if tBufferInfo == nil then
			local effectName, nTime , nTag = t:GetBufferNameAndTime(effectID);
			if effectName ~= nil and nTime ~= nil then
				if roundTime > 0 then
					tBufferInfo = {};
					tBufferInfo["Node"]  = nil;
					if roundTime ~= nil then
						tBufferInfo["Round"] = roundTime;
					else
						tBufferInfo["Round"] = nTime;
					end
					tBufferInfo["TagParent"] = nSpriteTag;
					
					--Buffer导致的Action
					SkillActionPerform:BufferLeadToAction(nSpriteTag, effectID, true);
					
					if t:IsShowBuffer(effectID) then
						m_tBufferObject[bufferKey] = {};
						m_tBufferObject[bufferKey] = tBufferInfo;
					end				
				else
					cclog("***服务器下发移除Buff不存在错误,严重错误 2-----")
				end
			end
		else
			if roundTime ~= nil then
				if roundTime == -1 then
					t:RemoveBuffer(nSpriteTag, effectID);
				end
				--[[
				tBufferInfo["Round"] = tBufferInfo["Round"] + roundTime;
				--判断是否次数?<0
				if tBufferInfo["Round"] <= 0 then
					--移除英雄特效Buf
					t:RemoveBuffer(nSpriteTag, effectID);
				end
				--]]
			else
				cclog("***客户端传入Buff添加次数的roundTime出现异常, 请检查数据---");
			end
		end
	end
end

-- 6:角色执行状态机
function t:DoStateMachine(tBuffer)
	local nSpriteTag = tBuffer[2]; 	--显示buffer的英雄tag
	local effectID   = tBuffer[3]; 	--显示bufferID
	local roundTime	 = tBuffer[4];	--显示buffer添加数
	
	local tArmatureSprite = nil;
	if t:IsIgnoreDeathBuff(effectID) then
		tArmatureSprite = SpriteArmaturePool:GetArmatureIgnoreDeath(nSpriteTag);
	else
		tArmatureSprite = SpriteArmaturePool:GetArmature(nSpriteTag);
	end
	---------------------------------------
	if tArmatureSprite ~= nil then
		--英雄Tag 和bufferId 组合成
		local bufferKey = tostring(effectID).."_"..tostring(nSpriteTag);
		--查找粒子显示对象并给予
		local tBufferInfo = m_tBufferObject[bufferKey];
		if tBufferInfo == nil then
			local effectName, nTime , nTag = t:GetBufferNameAndTime(effectID);
			if effectName ~= nil and nTime ~= nil then
				if roundTime > 0 then
					tBufferInfo = {};
					tBufferInfo["Node"]  = nil;
					if roundTime ~= nil then
						tBufferInfo["Round"] = roundTime;
					else
						tBufferInfo["Round"] = nTime;
					end
					tBufferInfo["TagParent"] = nSpriteTag;
					--Buffer导致的Action
					SkillActionPerform:BufferLeadToAction(nSpriteTag, effectID, true);
					if t:IsShowBuffer(effectID) then
						m_tBufferObject[bufferKey] = {};
						m_tBufferObject[bufferKey] = tBufferInfo;
					end
				else
					cclog("***服务器下发移除Buff不存在错误,严重错误 3-----")
				end
			end
		else
			if roundTime ~= nil then
				if roundTime == -1 then
					t:RemoveBuffer(nSpriteTag, effectID);
				else
					-- cclog("*********Buffer显示增加错误***");
				end
				--[[
				tBufferInfo["Round"] = tBufferInfo["Round"] + roundTime;
				--判断是否次数?<0
				if tBufferInfo["Round"] <= 0 then
					--移除英雄特效Buf
					t:RemoveBuffer(nSpriteTag, effectID);
					--移除后要还原的动作,执行状态机事件
					-- tArmatureSprite.fsm:doEvent("normal");
				end
				--]]
			else
				cclog("***客户端传入Buff添加次数的roundTime出现异常, 请检查数据---");
			end
		end
	end
end

--*****************************************************************************
-- 获取Buffer名称和回合数
-- nBufferId
-- 返回3个参数
-- 1技能特效
-- 2回合数
-- 3添加层次
-- nil 表示没有配置(后面会配置上去)
function t:GetBufferNameAndTime(nBufferId)
	if nBufferId == 20161 then --力场护盾
		return "EffectForceshield002", 1, 0;
	elseif nBufferId == 20036 then --毒牙
		return "effects/Effectpoisoning.plist", 1, 100;
	elseif nBufferId == 20057 then --心灵狂暴，免疫所有Debuff效果
		return "effects/Effectstatusfury.plist", 1, 0;
	elseif nBufferId == 20059 then --
		return "effects/Effectpoisoning.plist", 1, 100;
	elseif nBufferId == 20065 then --防御光环
		return "Effectpaladinaura001", 1, 0;--虔诚光环导致的Buff
	elseif nBufferId == 20067 then --伤害增加25%
		return "Effectpaladinaura002", 1, 0;--专注光环导致的buff
	--还有一个20068 专注光环导致的buff
	elseif nBufferId == 20069 then --反弹敌人直攻伤害的25%
		return "Effectpaladinaura003", 1, 0;--荆棘光环导致的Buff
	elseif nBufferId == 20073 then --反弹敌人
		return "EffectThornsarmorblow", 1, 0;
	elseif nBufferId == 20079 then --咒缚复活
		return "EffectResurrection", 1, 0;
	elseif nBufferId == 20081 then --主教复活
		return "EffectResurrection", 1, 0;
	elseif nBufferId == 20087 then --反弹敌人导致反弹角色表现
		return "EffectThornsarmor", 1, 0;
	elseif nBufferId == 20100 then --
		return "EffectBlazingstardebuff", 1, 0;
	elseif nBufferId == 20101 then --
		return "EffectPactrometerattackbuff", 1, 0;
	elseif nBufferId == 20103 then --
		return "EffectFireshieldbuff", 1, 0;
	elseif nBufferId == 20114 then --圣言(光环)
		return "Effectoracleaura", 1, 0;
	elseif nBufferId == 20115 then --圣言(De光环)
		return "Effectoracleaura", 1, 0;
	elseif nBufferId == 20122 then --异域毒刃产生的中毒
		return "effects/Effectpoisoning.plist", 1, 100;
	elseif nBufferId == 20126 then --中毒
		return "effects/Effectpoisoning.plist", 1, 100;
	elseif nBufferId == 20130 then --内视导致的DeBuff
		return "Effectinwardvisiondebuff", 1, 0;
	elseif nBufferId == 20131 then --眩晕动作
		return "", 1, 0;
	elseif nBufferId == 20132 then --集结号角
		return "EffectDownthehorndebuff", 1, 0;
	elseif nBufferId == 20133 then --
		return "", 1, 0;
	elseif nBufferId == 20141 then --真实视觉DeBuff
		return "", 1, 0;
	elseif nBufferId == 20143 then --直攻伤害提升10%
		return "effects/Effectstatusfury.plist", 1, 0;
	elseif nBufferId == 20144 then --集火号角产生的集火Buff
		return "EffectDownthehorndebuff", 1, 0;
	elseif nBufferId == 20145 then --
		cclog("******特效BufferID:%d,配置显示",nBufferId);
		return nil, 1, 0;
	elseif nBufferId == 20147 then --
		return "effects/Effectfixeddamage001.plist", 1, 0;
	elseif nBufferId == 20148 then --
		return "Effectsuckbloodheal", 1, 0;	
	else
		if GameFightCenter:IsShowLog() then
			cclog("---特效BufferID:%d,不需要配置显示",nBufferId);
		end
		return nil, 1;
	end
end

-- 根据状态要显示的事件
function t:GetBufferDoState(nBufferId)
	if nBufferId == 20131 or nBufferId == 20133 then
		return "badstate";	--眩晕
	end
	return nil;
end

-- 判断是否是Buffer(有些表现是Buff)
function t:IsShowBuffer(nBufferId)
	if nBufferId == 20073 then
		return false;
	elseif nBufferId == 20081 then
		return false;
	elseif nBufferId == 20087 then
		return false;
	elseif nBufferId == 20148 then
		return false;
	end
	return true;
end

-- 某些BuffId导致角色需要表现新的BufferID
function t:GetBuffLeadToBuff(nBufferId)
	if 20073 == nBufferId then --反伤类
		return 20087;
	end
	return nil
end

-- 某些表现即使是死亡后也要表现的BuffID
function t:IsIgnoreDeathBuff(nBufferId)
	if nBufferId == 20087 then
		return true;
	end
	return false;
end

return t;