-- 精灵由于技能或者Buffer产生的动作

SkillActionPerform = {};
local t = SkillActionPerform;

local m_tActionList = {};

--账号注销回调函数
function t.gameLoginOut()
	m_tActionList = {};
end

-- 动作定义枚举
--------------------------------
ActionPerformEnum = {
	FLY_ACTION 		= 1,		-- 飞行
	BIG_ACTION 		= 2,		-- 变大
	SMALL_ACTION 	= 3,		-- 变小
	ORG_ACTION		= 4,		-- 缩放还原
};

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
function t:RunPerformAction(tAction)
	if tAction ~= nil then
		for i, v in ipairs(tAction) do
			local nSpriteTag 	= v[1];	--精灵Tag
			local ePerfrpAction = v[2];	--执行动作
			local fDelayTime    = v[3];	--延时执行动作
			local extInfo		= v[4]; --扩展数据
			if ePerfrpAction == ActionPerformEnum.FLY_ACTION then
				t:PerformActionFly(nSpriteTag, fDelayTime, extInfo)
			elseif ePerfrpAction == ActionPerformEnum.BIG_ACTION then
				t:PerformActionBig(nSpriteTag, fDelayTime, extInfo)
			elseif ePerfrpAction == ActionPerformEnum.SMALL_ACTION then
				t:PerformActionSmall(nSpriteTag, fDelayTime, extInfo)
			elseif ePerfrpAction == ActionPerformEnum.ORG_ACTION then
				t:PerformActionOrg(nSpriteTag, fDelayTime, extInfo)
			end
		end
	end
end

-- 什么技能可以产生Action
function t:SkillLeadToAction(nSkillId, bSkillHit, nAttackId, tBeAttackId)
	if nSkillId == 10360 then	--狂暴旋风,引起被溅射的目标飞起动作
		local tAction = {};
		for i,v in ipairs(tBeAttackId) do
			if i>1 then
				table.insert(tAction,{v, ActionPerformEnum.FLY_ACTION, 0.2, nSkillId});
			end
		end	
		t:PushInActionFromQueue(tAction);
	else
		
	end
end

-- 任何Buff都可以产生Action
-- nBufferId 
-- bAdd 添加或者移除
function t:BufferLeadToAction(nSpriteTag, nBufferId, bAdd)
	if nBufferId == 20141 then --真实视觉DeBuff
		local tAction = {};
		if bAdd then
			table.insert(tAction,{nSpriteTag, ActionPerformEnum.SMALL_ACTION, 0.2, nBufferId});--缩小
			if not SpriteSkillBufferPool:IsHaveBuff(nSpriteTag, nBufferId) then
				t:PushInActionFromQueue(tAction);
			end
		else
			table.insert(tAction,{nSpriteTag, ActionPerformEnum.ORG_ACTION, 0.2, nBufferId});--还原
			t:PushInActionFromQueue(tAction);
		end
	end
end

--执行飞行动作
-------------------------------------------------
function t:PerformActionFly(nSpriteTag, fDelayTime, extInfo)

	local function func()
		local tShowSprite = SpriteArmaturePool:GetArmature(nSpriteTag);
		if tShowSprite ~= nil then
			local array = CCArray:create();
			local pMove = CCMoveBy:create(0.1, ccp(0, 120));
			array:addObject(pMove);
			array:addObject(pMove:reverse());
			local pAction = CCSequence:create(array);	
			tShowSprite.Sprite:runAction(pAction);
		end
	end
	
	if fDelayTime > 0 then
		Scheduler.performWithDelayGlobal(func, fDelayTime);
	else
		func();
	end
end

--执行变大动作
-------------------------------------------------
function t:PerformActionBig(nSpriteTag, fDelayTime, extInfo)
	local function func()
		local tShowSprite = SpriteArmaturePool:GetArmature(nSpriteTag);
		if tShowSprite ~= nil then
			local nBufferId = extInfo;
			local fScaleValue = t:GetScalseValueByBufferId(nBufferId, 1);
			local orgSx = tShowSprite.Sprite:getScaleX();
			local orgSy = tShowSprite.Sprite:getScaleY();
			local sx = fScaleValue * orgSx;
			local sy = fScaleValue * orgSy;
			tShowSprite.Sprite:runAction(CCScaleTo:create(1.0,sx,sy));
		end
	end
	
	if fDelayTime > 0 then
		Scheduler.performWithDelayGlobal(func, fDelayTime);
	else
		func();
	end
end

--执行变小动作
-------------------------------------------------
function t:PerformActionSmall(nSpriteTag, fDelayTime, extInfo)

	local function func()
		local tShowSprite = SpriteArmaturePool:GetArmature(nSpriteTag);
		if tShowSprite ~= nil then
			local nBufferId = extInfo;
			local fScaleValue = t:GetScalseValueByBufferId(nBufferId, 2);
			local orgSx = tShowSprite.Sprite:getScaleX();
			local orgSy = tShowSprite.Sprite:getScaleY();
			local sx = fScaleValue * orgSx;
			local sy = fScaleValue * orgSy;
			tShowSprite.Sprite:runAction(CCScaleTo:create(1.0,sx,sy));
		end
	end
	if fDelayTime > 0 then
		Scheduler.performWithDelayGlobal(func, fDelayTime);
	else
		func();
	end
end

--执行还原动作
-------------------------------------------------
function t:PerformActionOrg(nSpriteTag, fDelayTime, extInfo)
	local function func()
		local tShowSprite = SpriteArmaturePool:GetArmature(nSpriteTag);
		if tShowSprite ~= nil then
			local nBufferId = extInfo;
			local fScaleValue = t:GetScalseValueByBufferId(nBufferId, 3);
			local orgSx = tShowSprite.Sprite:getScaleX();
			local orgSy = tShowSprite.Sprite:getScaleY();
			local sx = fScaleValue * orgSx;
			local sy = fScaleValue * orgSy;
			tShowSprite.Sprite:runAction(CCScaleTo:create(1.0,sx,sy));
		end
	end
	
	if fDelayTime > 0 then
		Scheduler.performWithDelayGlobal(func, fDelayTime);
	else
		func();
	end
end

--获取缩放系数
--nBufferId,
-- nType(1:变大2:变小3:还原)
function t:GetScalseValueByBufferId(nBufferId, nType)
	if nType == 1 then
		return 1.25;
	elseif nType == 2 then
		return 0.8;
	elseif nType == 3 then
		if nBufferId == 20141 then --真实视觉DeBuff
			return 1.25;
		end
		return 1.0;
	end
end

return t;