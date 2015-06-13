--技能释放

SpriteSkill = {};
local p = SpriteSkill;

--******************************************************************
--------------------------------------------------------------------
-- 单体近战攻击	(1V多)
-- nAttackSpriteTag, 	攻击骨骼精灵
-- tBeAttackSpriteTag, 	被击的所有骨骼精灵(第一个是攻击主体)
-- nSkillID				施法技能ID
-- bSkillType			攻击状态
-- 1:被击中, 2:格挡, 3:回避, 4:被击反击 5:格挡反击 6:回避反击
-- tAttackHurt			攻击的所有伤害
-- nCounterHurt			反击伤害(ni:不执行)
-- tBuffer				产生buffer(nil:不执行)
-- 以上是行动部分****************************************
-- tStateArray			状态部分
function p:ReleaseAllMeleeAttack(nAttackSpriteTag, tBeAttackSpriteTag,  nSkillID, bSkillType, tAttackHurt, nCounterHurt, tBuffer, tStateArray, nAttackType)
	
	local pAttackSprite   = SpriteArmaturePool:GetArmature(nAttackSpriteTag);
	local pBeAttackSprite = SpriteArmaturePool:GetArmature(tBeAttackSpriteTag[1]);
	if pAttackSprite ~= nil and pBeAttackSprite ~= nil then

		--显示技能
		GameFightCenter:ShowSkillName(nSkillID, pAttackSprite.IsEnemy);
		
		-- 数据准备
		local pos = p:CalculatePostion(pAttackSprite.Sprite, pBeAttackSprite.Sprite);
		local attackZorder = pAttackSprite.Sprite:getZOrder();
		local beattackZorder = pBeAttackSprite.Sprite:getZOrder();
		
		local armatrueActionName = nil;		
		if bSkillType == 1 then
			armatrueActionName = "beattack";
		elseif bSkillType == 2 then
			armatrueActionName = "parry";
		elseif bSkillType == 3 then
			armatrueActionName = "dodge";
		elseif bSkillType == 4 then
			
		elseif bSkillType == 5 then
			
		elseif bSkillType == 6 then
			
		end
		---------------------------------------------------------------------------------------------------------
		local actionArray = {};
		--表示执行动作的精灵
		table.insert(actionArray, nAttackSpriteTag);
		--技能攻击前的蓄力特效
		local tbSkillBefore = SkillDoReleaseBefore:GetStorageSkillBefore(nSkillID, nAttackSpriteTag, tBeAttackSpriteTag);
		if tbSkillBefore ~= nil then
			table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.SKILLBEFORE_ACTION, tbSkillBefore});
		end
		
		--攻击骨骼精灵立马改变状态机
		table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.ARMATURE_ACTION, {{"dash",0,0}, nil}});		
		--播放冲刺音效
		GameFightMusic.InsertPlayEffect(actionArray, MusicEnum.MUSIC_RUSH);
		--移动到目标位置
		table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag[1], ActionEnum.MOVE_ACTION, { pos , 0.2}});
		--****改变显示层次
		table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag[1], ActionEnum.ZORDER_ACTION, { beattackZorder , nil}});
		
		--攻击目标执行攻击动作状态机
		table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.ARMATURE_ACTION, {{"attack",0,0}, nil}});
		--等待攻击动作播放完毕
		table.insert(actionArray,{nAttackSpriteTag, nil, ActionEnum.DELAY_ACTION, 0.25});
		--播放攻击特效
		local bHit = true;
		if bSkillType == 3 then
			bHit = false;--躲避的时候不播放被击特效
		end

		--释放技能ID
		table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.SKILL_ACTION, {nSkillID, bHit}});

		if nAttackType == 1 then
			--CRITICAL = 1, 暴击
			table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.SPECIAL_ACTION, {nSkillID, tBeAttackSpriteTag[1], nAttackType}});
		elseif nAttackType == 2 then
			-- DODGE = 2,   闪避
			table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.SPECIAL_ACTION, {nSkillID, tBeAttackSpriteTag[1], nAttackType}});
		elseif nAttackType == 3 then	
			-- PARRY = 3,   格挡
			table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.SPECIAL_ACTION, {nSkillID, tBeAttackSpriteTag[1], nAttackType}});
		end
		
		--播放攻击音效
		GameFightMusic.InsertPlayEffectByRoleType(actionArray, pAttackSprite.RoleType, true, bSkillType);
		
		--站在位置停留
		table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag[1], ActionEnum.DELAY_ACTION, 0.2});
		
		--产生buffer(正常这条数据应该放在--伤害播放执行之后)
		if tBuffer ~= nil and #tBuffer > 0 then
			table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag[1], ActionEnum.BUFFER_ACTION, tBuffer});
		end
		
		--被打的骨骼动画动作设置
		if bSkillType ~= 5 then
			--播放被击延迟
			local fDelayTime = SpriteDoBeHitDelay:GetDoBeDelay(nSkillID, bSkillType);
			if fDelayTime > 0 then
				table.insert(actionArray,{nAttackSpriteTag, nil, ActionEnum.DELAY_ACTION, fDelayTime});
			end
			--播放被击音效
			GameFightMusic.InsertPlayEffectByRoleType(actionArray, pAttackSprite.RoleType, false, bSkillType)
			table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.ARMATURE_ACTION, {nil, {armatrueActionName,0,0}}});
		else
			-- local tSpriteHurt = {{tBeAttackSpriteTag[1], "MISS", HurtEnum.NORMAL_TIPS}};	
			-- table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag[1], ActionEnum.HURT_ACTION, tSpriteHurt});
		end
		
		-- 执行伤害播放
		table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag[1], ActionEnum.HURT_ACTION, tAttackHurt});
		
		--产生反击
		if bSkillType == 4 or bSkillType == 5 or bSkillType == 6 then
			
		end
		
		--打完停留下
		table.insert(actionArray,{nAttackSpriteTag, nil, ActionEnum.DELAY_ACTION, 0.6});
		
		--被击骨骼精灵恢复状态
		table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.ARMATURE_ACTION, {nil, {"normal",0,0}}});
		--返回原来位置
		table.insert(actionArray,{nAttackSpriteTag, nil, ActionEnum.JUMP_ACTION, {0.2,ccp(-pos.x, -pos.y), 50, 1}});
		--****改变显示层次
		table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag[1], ActionEnum.ZORDER_ACTION, { attackZorder , nil}});
		--攻击状态恢复
		table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.ARMATURE_ACTION, {{"normal",0,0}, nil}});
		
		--战斗状态部分显示
		if tStateArray ~= nil then
			for i,v in ipairs(tStateArray) do
				for j,d in ipairs(v) do
					table.insert(actionArray, d);
				end
			end
		end
		
		--推入技能池
		SpriteActionPool:PushInActionFromQueue(actionArray);
		
	else
		cclog("*********** 单体近战攻击	(1V多) 找不到施法对象***********");
	end
	
end

-- 释放远程攻击 (1V多)
-- nAttackSpriteTag, 	攻击骨骼精灵
-- tBeAttackSpriteTag, 	被击骨骼精灵
-- nSkillID				施法技能ID
-- bSkillType			攻击状态
-- 1:被击中, 2:格挡, 3:回避, 4:被击反击 5:格挡反击 6:回避反击 7:什么都没发生
-- tAttackHurt			攻击伤害
-- nCounterHurt			反击伤害(ni:不执行)
-- tBuffer				产生buffer(nil:不执行)
-- 以上是行动部分****************************************
-- tStateArray			状态部分
function p:ReleaseAllRemoteAttack(nAttackSpriteTag, tBeAttackSpriteTag,  nSkillID, bSkillType, tAttackHurt, nCounterHurt, tBuffer, tStateArray, nAttackType)
	local pAttackSprite   = SpriteArmaturePool:GetArmature(nAttackSpriteTag);
	local pBeAttackSprite = SpriteArmaturePool:GetArmature(tBeAttackSpriteTag[1]);
	if pAttackSprite ~= nil and pBeAttackSprite ~= nil then
		
		--显示技能
		GameFightCenter:ShowSkillName(nSkillID, pAttackSprite.IsEnemy);
		
		local actionArray = {};
		-- 表示执行动作的精灵
		table.insert(actionArray, nAttackSpriteTag);
		--技能攻击前的蓄力特效
		local tbSkillBefore = SkillDoReleaseBefore:GetStorageSkillBefore(nSkillID, nAttackSpriteTag, tBeAttackSpriteTag);
		if tbSkillBefore ~= nil then
			table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.SKILLBEFORE_ACTION, tbSkillBefore});
		end
		-- 攻击目标(或者是施法)
		local eActType = CfgData["cfg_skill"][nSkillID]["act_type"];
		if eActType == 1 then --释放魔法
			table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.ARMATURE_ACTION, {{"mgattack",0,0}, nil}});
		elseif eActType == 2 then --攻击
			-- 播放攻击音效
			-- GameFightMusic.InsertPlayEffectByRoleType(actionArray, pAttackSprite.RoleType, true, bSkillType);
			table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.ARMATURE_ACTION, {{"attack",0,0}, nil}});
		else
			cclog("***数据库配置错误(释放远程攻击)技能ID=%d,act_type 异常---",nSkillID);
		end
		
		-- 延时
		table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag[1], ActionEnum.DELAY_ACTION, 0.25});
		
		-- 被打的骨骼动画动作设置
		local bHit = false;
		local armatrueActionName = nil;
		if bSkillType == 1 then
			armatrueActionName = "beattack";
			bHit = true;
		elseif bSkillType == 2 then
			armatrueActionName = "parry";
		elseif bSkillType == 3 then
			armatrueActionName = "dodge";
		elseif bSkillType == 4 then
		elseif bSkillType == 5 then
		elseif bSkillType == 6 then
		end

		--释放技能ID
		local eSkillExtType = SceneSkillEffectPool:SkillExternEnum(nSkillID, nAttackType);
		table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.SKILL_ACTION, {nSkillID, bHit, eSkillExtType}});
		
		if nAttackType == 1 then
			--CRITICAL = 1, 暴击
			table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.SPECIAL_ACTION, {nSkillID, tBeAttackSpriteTag[1], nAttackType}});
		elseif nAttackType == 2 then
			-- DODGE = 2,   闪避
			table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.SPECIAL_ACTION, {nSkillID, tBeAttackSpriteTag[1], nAttackType}});
		elseif nAttackType == 3 then	
			-- PARRY = 3,   格挡
			table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.SPECIAL_ACTION, {nSkillID, tBeAttackSpriteTag[1], nAttackType}});
		end
		
		if eActType == 2 then --攻击
			--播放攻击音效
			GameFightMusic.InsertPlayEffectByRoleType(actionArray, pAttackSprite.RoleType, true, bSkillType);
		end
		
		--等待攻击动作播放完毕
		table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag[1], ActionEnum.DELAY_ACTION, 0.25});
		
		--播放被击动作
		if SceneSkillEffectPool:IsPlayStrikeAction(nSkillID) then
			--播放被击延迟
			local fDelayTime = SpriteDoBeHitDelay:GetDoBeDelay(nSkillID, bSkillType);
			if fDelayTime > 0 then
				table.insert(actionArray,{nAttackSpriteTag, nil, ActionEnum.DELAY_ACTION, fDelayTime});
			end
			--播放被击音效
			if eActType ~= 1 then --普通的攻击
				GameFightMusic.InsertPlayEffectByRoleType(actionArray, pAttackSprite.RoleType, false, bSkillType)
			else				  --魔法攻击
			
			end
			table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.ARMATURE_ACTION, {nil, {armatrueActionName,0,0}}});
		end
		
		if bSkillType == 1 then
			-- 播放伤害表现
			table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag[1], ActionEnum.HURT_ACTION, tAttackHurt});
		end
		--产生buffer
		if tBuffer ~= nil and #tBuffer > 0 then
			table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag[1], ActionEnum.BUFFER_ACTION, tBuffer});
		end
		-- 攻击状态恢复
		table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.ARMATURE_ACTION, {{"normal",0,0}, nil}});
		-- 延时
		table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag[1], ActionEnum.DELAY_ACTION, 0.6});		
		-- 恢复
		if SceneSkillEffectPool:IsPlayStrikeAction(nSkillID) then
			table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.ARMATURE_ACTION, {nil, {"normal",0,0}}});
		end
		
		--战斗状态部分显示
		if tStateArray ~= nil then
			for i,v in ipairs(tStateArray) do
				for j,d in ipairs(v) do
					table.insert(actionArray, d);
				end
			end
		end
		
		-- 推入技能池
		SpriteActionPool:PushInActionFromQueue(actionArray);
	else
		cclog("***********释放远程攻击 (1V多) 找不到施法对象***********");
	end
end


-- 释放Buff攻击 (1V多)
-- nAttackSpriteTag, 	攻击骨骼精灵
-- tBeAttackSpriteTag, 	被击骨骼精灵
-- nSkillID				施法技能ID
-- bSkillType			攻击状态
-- 1:被击中, 2:格挡, 3:回避, 4:被击反击 5:格挡反击 6:回避反击
-- tAttackHurt			攻击伤害
-- nCounterHurt			反击伤害(ni:不执行)
-- tBuffer				产生buffer(nil:不执行)
-- 以上是行动部分****************************************
-- tStateArray			状态部分
function p:ReleaseAllBufferAttack(nAttackSpriteTag, tBeAttackSpriteTag,  nSkillID, bSkillType, tAttackHurt, nCounterHurt, tBuffer, tStateArray, nAttackType)
	local pAttackSprite   = SpriteArmaturePool:GetArmature(nAttackSpriteTag);
	local pBeAttackSprite = SpriteArmaturePool:GetArmature(tBeAttackSpriteTag[1]);
	if pAttackSprite ~= nil and pBeAttackSprite ~= nil then
		
		--显示技能
		-- GameFightCenter:ShowSkillName(nSkillID, pAttackSprite.IsEnemy);
		
		local actionArray = {};
		-- 表示执行动作的精灵
		table.insert(actionArray, nAttackSpriteTag);
		
		--执行状态 Buff
		local strEven = SpriteSkillBufferPool:GetBufferDoState(nSkillID);
		if strEven ~= nil then
			table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.ARMATURE_ACTION, {{strEven,0,0}, nil}});
			if strEven == "badstate" then
				--眩晕表现
				table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.SPECIAL_ACTION, {nSkillID, tBeAttackSpriteTag[1], 4}});
			end
		end

		-- 播放伤害表现
		table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag[1], ActionEnum.HURT_ACTION, tAttackHurt});
		
		--产生buffer
		if tBuffer ~= nil and #tBuffer > 0 then
			table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag[1], ActionEnum.BUFFER_ACTION, tBuffer});
		end

		-- 延时
		table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag[1], ActionEnum.DELAY_ACTION, 1.0});
		
		-- 攻击状态恢复
		if strEven ~= nil then
			table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.ARMATURE_ACTION, {{"normal",0,0}, nil}});
		end
		
		-- 恢复
		if SceneSkillEffectPool:IsPlayStrikeAction(nSkillID) then
			table.insert(actionArray,{nAttackSpriteTag, tBeAttackSpriteTag, ActionEnum.ARMATURE_ACTION, {nil, {"normal",0,0}}});
		end
		
		--战斗状态部分显示
		if tStateArray ~= nil then
			for i,v in ipairs(tStateArray) do
				for j,d in ipairs(v) do
					table.insert(actionArray, d);
				end
			end
		end
		
		-- 推入技能池
		SpriteActionPool:PushInActionFromQueue(actionArray);
	else
		cclog("***********释放Buff攻击 (1V多) 找不到施法对象***********");
	end
end


-- 战斗对话
-- nAttackSpriteTag, 	攻击骨骼精灵
-- tBeAttackSpriteTag, 	被击骨骼精灵
function p:ReleaseAllHeroSayAttack(nAttackSpriteTag, tBeAttackSpriteTag, nWorldIndex)
	-- local pAttackSprite   = SpriteArmaturePool:GetArmature(nAttackSpriteTag);
	-- local pBeAttackSprite = SpriteArmaturePool:GetArmature(tBeAttackSpriteTag[1]);
	-- if pAttackSprite ~= nil and pBeAttackSprite ~= nil then
		
		-- local actionArray = {};
		-- 表示执行动作的精灵
		-- table.insert(actionArray, nAttackSpriteTag);
		-- cclog(tostring(nWorldIndex));
		local strWorld = GameFightInfoBase:ShowHeroTalkInfoById(nWorldIndex);
		if strWorld ~= nil then
			local tAttackSprite   = SpriteArmaturePool:GetArmature(nAttackSpriteTag);
			if tAttackSprite ~= nil then
				local bLeft 	= not tAttackSprite.IsEnemy;
				local strName	= GameFightCenter:GetHeroNameByTagId(nAttackSpriteTag)
				GameFightHeroTalk:ShowHeroWorld(bLeft , strName, strWorld);
			else
				cclog("***对话的英雄不存在---");
			end
		end
		-- 推入技能池
		-- SpriteActionPool:PushInActionFromQueue(actionArray);
	-- else
		-- cclog("***********释放 战斗对话 找不到说话对象***********");
	-- end
end



--------------------------------------------------------------------
function p:CalculatePostion(pAttackSprite, pBeAttackSprite)
	local attackSpritePosX,attackSpritePosY = pAttackSprite:getPosition();
	local beattackSpritePosX,beattackSpritePosY = pBeAttackSprite:getPosition();
	local x = beattackSpritePosX - attackSpritePosX
	if x < 0 then
		x = x + 100;
	else
		x = x - 100;
	end
	local y = beattackSpritePosY - attackSpritePosY;
	return ccp(x,y);
end

