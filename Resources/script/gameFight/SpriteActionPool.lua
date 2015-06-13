-- 精灵动作生成器
-- 包括精灵动作， 以及2dx的各种动作

SpriteActionPool = {};
local t = SpriteActionPool;

local m_tActionList = {};

--账号注销回调函数
function t.gameLoginOut()
	m_tActionList = {};
end

-- 动作定义枚举
--------------------------------
ActionEnum = {
	MOVE_ACTION 		= 1,		--移动
	JUMP_ACTION 		= 2,		--跳跃
	DELAY_ACTION 		= 3,		--延时
	ARMATURE_ACTION 	= 4,		--骨骼动作
	SKILL_ACTION 		= 5,		--技能表现(普通攻击)
	HURT_ACTION 		= 6,		--伤害表现
	-- SCENESKILL_ACTION	= 7,		--场景技能
	ZORDER_ACTION		= 8,		--改变显示层次
	BUFFER_ACTION		= 9,		--Buffer状态
	SKILLBEFORE_ACTION	= 10,		--技能释放前蓄力特效
	MUSIC_ACTION		= 11,		--执行播放音效
	SPECIAL_ACTION		= 12,		--战斗特别特效

};

--骨骼动作类型枚举
ArmatureActionEnum = {
	NONE = 0, 	--什么都没有
	ORGE = 1,	--动作还原
}

--***************************************
--推入一个动作数据
function t:PushInActionFromQueue(tAction)
	table.insert(m_tActionList, tAction);
end

-- 推出一个动作数据
function t:PushOutActionFromQueue()
	if #m_tActionList > 0 then
		local tAction = m_tActionList[1];
		table.remove(m_tActionList, 1);
		return tAction;
	end
	return nil;
end

-- 解析并且执行一个动作队列
function t:RunActionParsing(tAction)
	
	local nPerformSpriteTag = -1;
	local array = CCArray:create();
	for i,v in ipairs(tAction) do
		if i > 1 then
			local action  = t:ActionParsing(v);
			if action ~= nil then
				array:addObject(action);
			end
		else
			nPerformSpriteTag = v;
		end
	end
	local pAction = CCSequence:create(array);
	if nPerformSpriteTag ~= -1 then
		local pAttackSprite = SpriteArmaturePool:GetArmature(nPerformSpriteTag);		
		if pAttackSprite ~= nil and pAction ~= nil then
			pAttackSprite.Sprite:runAction(pAction);	
		end
	else
		cclog("******技能Action必须第一数组是施法Tag------");
	end
end

-- 动作解析
function t:ActionParsing(tAction)
	if tAction ~= nil then
		local nAttackSpriteTag		= tAction[1];
		local nBeAttackSpriteTag	= tAction[2];
		local nActionType			= tAction[3];
		local tParam				= tAction[4];
		if nActionType == ActionEnum.MOVE_ACTION then
			
			local cPos = tParam[1]
			local nDelayTime = tParam[2];
			return t:MoveTo(cPos, nDelayTime);
			
		elseif nActionType == ActionEnum.JUMP_ACTION then
			
			local fTime = tParam[1];
			local cPos  = tParam[2];
			local nHeight = tParam[3];
			local nCount = tParam[4];
			return t:JumpTo(nAttackSpriteTag, nBeAttackSpriteTag, fTime, cPos, nHeight, nCount)
			
		elseif nActionType == ActionEnum.DELAY_ACTION then
			
			return t:Delay(tParam);
			
		elseif nActionType == ActionEnum.ARMATURE_ACTION then
			
			return t:ArmatrueAction(nAttackSpriteTag, nBeAttackSpriteTag, tParam[1], tParam[2]);
		
		elseif nActionType == ActionEnum.SKILL_ACTION then
			
			return t:SkillAction(nAttackSpriteTag, nBeAttackSpriteTag, tParam);
		
		elseif nActionType == ActionEnum.HURT_ACTION then
		
			return t:HurtAndDamage(nAttackSpriteTag, nBeAttackSpriteTag, tParam);
		
		elseif nActionType == ActionEnum.SCENESKILL_ACTION then
		
			return t:SceneSkillEffect(nAttackSpriteTag, nBeAttackSpriteTag, tParam);
			
		elseif nActionType == ActionEnum.ZORDER_ACTION then
			
			local pAttackSprite   = SpriteArmaturePool:GetArmature(nAttackSpriteTag);
			local pBeAttackSprite = SpriteArmaturePool:GetArmature(nBeAttackSpriteTag);
			return t:ChangeZOrder(pAttackSprite, pBeAttackSprite, tParam);
		
		elseif nActionType == ActionEnum.BUFFER_ACTION then
			
			return t:BufferShow(nil, nil, tParam);
		
		elseif nActionType == ActionEnum.SKILLBEFORE_ACTION then
			return t:SkillBeforeShow(nil, nil, tParam);
		
		elseif nActionType == ActionEnum.MUSIC_ACTION then
			return t:PlayMusicEffect(tParam);
		elseif nActionType == ActionEnum.SPECIAL_ACTION then
			return t:PlaySpecialEffect(tParam);
		end
	end
	return nil;
end

--------------------------------
-- 移动
function t:MoveTo(cPos, fTime)
	return CCMoveBy:create(fTime, cPos);
end

-- 跳跃
function t:JumpTo(nAttackSpriteTag, nBeAttackSpriteTag, fTime, cPos, nHeight, nCount)
	local function jumpFunc()
		-- local pAttackSprite = SpriteArmaturePool:GetArmature(nAttackSpriteTag);
		--(保证客死他乡能够回来)
		local pAttackSprite = SpriteArmaturePool:GetArmatureIgnoreDeath(nAttackSpriteTag);
		if  pAttackSprite ~= nil then
			pAttackSprite.Sprite:runAction(CCJumpBy:create(fTime, cPos, nHeight, nCount));
		end
	end
	return CCCallFunc:create(jumpFunc);
end

-- 延时
function t:Delay(fTime)
	return CCDelayTime:create(fTime);
end

-- 骨骼动作
function t:ArmatrueAction(nAttackSpriteTag, tBeAttackSpriteTag, tAction1, tAction2)
	local function armatureFunc()
		if nAttackSpriteTag ~= nil and tAction1 ~= nil then
			local actionName1 = tAction1[1]; --执行时间名称
			local fDelayTime  = tAction1[2]; --延时执行动作
			local eArmature   = tAction1[3]; --执行枚举(用于状态)
			if eArmature == ArmatureActionEnum.NONE then --无任何
				local pAttackSprite = SpriteArmaturePool:GetArmature(nAttackSpriteTag);
				-- local pAttackSprite = SpriteArmaturePool:GetArmatureIgnoreDeath(nAttackSpriteTag);
				if pAttackSprite ~= nil then
					pAttackSprite.fsm:doEvent(actionName1);
				end
			elseif eArmature == ArmatureActionEnum.ORGE then --动作还原
			
			else
				cclog("***角色骨骼动作状态机执行失败,ArmatureActionEnum枚举失败1---");
			end
		end
		if tBeAttackSpriteTag ~= nil and tAction2 ~= nil then
			local actionName2 = tAction2[1]; --执行时间名称
			local fDelayTime  = tAction2[2]; --延时执行动作
			local eArmature   = tAction2[3]; --执行枚举(用于状态)
			if eArmature == ArmatureActionEnum.NONE then --无任何
				for k,v in pairs(tBeAttackSpriteTag) do
					local pBeAttackSprite = SpriteArmaturePool:GetArmature(v);
					-- local pBeAttackSprite = SpriteArmaturePool:GetArmatureIgnoreDeath(v);
					if pBeAttackSprite ~= nil then
						pBeAttackSprite.fsm:doEvent(actionName2);
					end				
				end
			elseif eArmature == ArmatureActionEnum.ORGE then --动作还原
			
			else
				cclog("***角色骨骼动作状态机执行失败,ArmatureActionEnum枚举失败2---");			
			end
		end
	end
	return CCCallFunc:create(armatureFunc);
end

-- 技能表现(单体骨骼技能)
function t:SkillAction(nAttackId, tBeAttackId, tParam)
	local function skillFunc()
		--[[
		if pAttackSprite ~= nil and tParam ~= nil then
			local skillName1 	= tParam[1][1];
			local bLoop 	 	= tParam[1][2];
			local isAutoRelease = tParam[1][3];
			if skillName1 ~= nil then
				local tArmatureEffect = CreateArmatureEffect();
				local pEffect = tArmatureEffect:CreateEffectSprite(skillName1, bLoop, isAutoRelease)
				local nTag = pAttackSprite:AddArmatureEffect(tArmatureEffect);
				if isAutoRelease then
					tArmatureEffect:SetAutoInfo(pAttackSprite.RemoveArmatureEffect, nTag);
				end
			end
		end
		if pBeAttackSprite ~= nil and tParam ~= nil then
			local function func()
				local skillName2 	= tParam[3][1];
				local bLoop 	 	= tParam[3][2];
				local isAutoRelease = tParam[3][3];
				if skillName2 ~= nil then
					local tArmatureEffect = CreateArmatureEffect();
					local pEffect = tArmatureEffect:CreateEffectSprite(skillName2, bLoop, isAutoRelease);
					local nTag = pBeAttackSprite:AddArmatureEffect(tArmatureEffect);
					if isAutoRelease then
						tArmatureEffect:SetAutoInfo(pBeAttackSprite.RemoveArmatureEffect, nTag);
					end
				end
			end
			local fTime = tParam[2];
			if fTime > 0 then
				Scheduler.performWithDelayGlobal(func, fTime);
			else
				func();
			end
		end
		--]]
		SceneSkillEffectPool:PushInEffectToQueue({nAttackId, tBeAttackId, tParam});
	end
	return CCCallFunc:create(skillFunc);
end

-- 技能伤害
function t:HurtAndDamage(nAttackSpriteTag, nBeAttackSpriteTag, tParam)
	local function hurtFunc()
		SpriteDamagePool:PushInActionFromQueue(tParam);
	end
	return CCCallFunc:create(hurtFunc);
end

-- 场景技能()
function t:SceneSkillEffect(nAttackSpriteTag, nBeAttackSpriteTag, tParam)
	local function sceneSkillFunc()
		local tEffect = {nAttackSpriteTag, nBeAttackSpriteTag, tParam}
		SceneSkillEffectPool:PushInEffectToQueue(tEffect);
	end
	return CCCallFunc:create(sceneSkillFunc);
end

-- 改变显示层次
function t:ChangeZOrder(pAttackSprite, pBeAttackSprite, tParam)
	local function zOrderFunc()
		if pAttackSprite ~= nil and tParam[1] ~= nil then
			pAttackSprite.Sprite:setZOrder(tParam[1]);
		end
		if pBeAttackSprite ~= nil and tParam[2] ~= nil then
			pBeAttackSprite.Sprite:setZOrder(tParam[2]);
		end
	end
	return CCCallFunc:create(zOrderFunc);
end

-- 添加buffer表现
function t:BufferShow(pAttackSprite, pBeAttackSprite, tParam)
	local function bufferFunc()
		--{}
		SpriteSkillBufferPool:PushInBufferToQueue(tParam);
	end
	return CCCallFunc:create(bufferFunc);
end

-- 技能释放前蓄力特效
function t:SkillBeforeShow(pAttackSprite, pBeAttackSprite, tParam)
	local function bufferBeforeFunc()
		SkillDoReleaseBefore:PushInStorageToQueue(tParam);
	end
	return CCCallFunc:create(bufferBeforeFunc);
end

-- 播放音效
function t:PlayMusicEffect(tMusicInfo)
	local function doPlayEffectFunc()
		GameFightMusic.PlayEffect(tMusicInfo, false);
	end
	return CCCallFunc:create(doPlayEffectFunc);
end

-- 播放也别特效
function t:PlaySpecialEffect(tInfo)
	local function doPlaySpecialEffect()
		local nTagID 		= tInfo[2];
		local nAttackType 	= tInfo[3];
		
		local tShowArmature = SpriteArmaturePool:GetArmature(nTagID);
		if tShowArmature ~= nil then
			local armtureName = nil;
			if nAttackType == 1 then
				armtureName = "Effectcritstrike";
			elseif nAttackType == 2 then
				armtureName = "Effectdodge";
			elseif nAttackType == 3 then
				armtureName = "Effectparry";
			elseif nAttackType == 4 then
				armtureName = "EffectVertigo";
			else
				return;
			end
			-- local function func()
					local tArmatureEffect = CreateArmatureEffect();
					local pEffect = tArmatureEffect:CreateEffectSprite(armtureName, 0, true);
					if tShowArmature.IsEnemy then
						tArmatureEffect:SetFlip(true,false);
					end
					if pEffect ~= nil then
						tArmatureEffect:SetPostion(ccp(0, 170));
						local nTag = tShowArmature:AddArmatureEffect(tArmatureEffect);
						tArmatureEffect:SetAutoInfo(tShowArmature.RemoveArmatureEffect, nTag);
					else
						cclog("***显示一个骨骼(添加到精灵中)失败,骨骼:%s---",armtureName);
					end
				-- end
			-- end
			--[[
			if fDelTime > 0 then
				Scheduler.performWithDelayGlobal(func, fDelTime);
			else
				func();
			end
			--]]
		else
			cclog("***显示一个骨骼(添加到精灵中)失败,ShowArmatureSprite---");
		end
		
		
	end
	return CCCallFunc:create(doPlaySpecialEffect);
end

--------------------------------------------------------------------
function t:CalculatePostion(pAttackSprite, pBeAttackSprite)
	local attackSpritePosX,attackSpritePosY = pAttackSprite:getPosition();
	local beattackSpritePosX,beattackSpritePosY = pBeAttackSprite:getPosition();
	local x = beattackSpritePosX - attackSpritePosX;
	if x < 0 then
		x = x + 100;
	else
		x = x - 100;
	end
	local y = beattackSpritePosY - attackSpritePosY;
	return ccp(x,y);
end

return t;