--技能解析中心
SkillReleaseCenter = {};
local t = SkillReleaseCenter;

EnumDamage =
{
	NORMAL 		= 0, --普通命中
	CIRTICAL	= 1, --暴击
	DODGE		= 2, --闪避
	PARRY		= 3, --格挡
	CURE		= 4, --治疗
	SUCK		= 5, --吸血
	REBOUND		= 6, --反弹
	BATBACK		= 7, --反击
	BUFF		= 8, --状态
	REVIVE		= 9, --复活
	SELF		= 10,--自伤
	VERTIGO		= 11,--眩晕
	BUFFERMOVE	= 12,--消除Buff
	NONE		= 13,--什么都没有
	WORLD		= 25,--文字显示
}

--技能回合数据组合
function t:SkillRoundComb(tMessages, stateArray)

	local tRoundMessage =nil;
	--行动回合数据设置
	for i,v in ipairs(tMessages) do
		
		if i==1 then
			-- i=1表示是施法的对象,第一次对象赋予驱动攻击精灵
			local nHurt = v.nDamageHurt;
			v.tBuffer = {};
			v.tStateArray = stateArray;
			---------------------------
			tRoundMessage = v;
			tRoundMessage.nDamageHurt = {};
			tRoundMessage.sHeroSayWorlds = "";
			--如果是移除或者添加Buff
			if v.nAttackType == EnumDamage.WORLD then --战斗对话
				tRoundMessage.sHeroSayWorlds = v.sAdditional;
			elseif v.nAttackType == EnumDamage.BUFF or v.nAttackType == EnumDamage.BUFFERMOVE  then
				
				if v.nAttackType == EnumDamage.BUFFERMOVE then
					--特殊处理,宇子哥说这个就驱散技能有
					local eHurtEnum = t:GetHurtType(v.nAttackType);
					for k, value in pairs(nHurt) do
						table.insert(tRoundMessage.nDamageHurt, {{v.nAttackId, v.nBeAttackId[1]}, value, eHurtEnum, tRoundMessage.nSkillId});
					end
				end
				
				--是buffer
				local bAdd = true;
				if v.nAttackType ~= EnumDamage.BUFF then
					bAdd = false;
				end
				local tBuffers = t:BufferAdditional(v.sAdditional, v.nBeAttackId, bAdd);
				for k,d in ipairs(tBuffers) do
					table.insert(tRoundMessage.tBuffer,d);
				end
			else
				local eHurtEnum = t:GetHurtType(v.nAttackType);
				for k, value in pairs(nHurt) do
					table.insert(tRoundMessage.nDamageHurt, {{v.nAttackId, v.nBeAttackId[1]}, value, eHurtEnum, tRoundMessage.nSkillId});
				end
				--可能存在Buff
				local tBuffers = t:BufferAdditional(v.sAdditional, v.nBeAttackId, true);
				for k,d in ipairs(tBuffers) do
					table.insert(tRoundMessage.tBuffer,d);
				end
				
			end
		else
			--判断是否是添加或者移除Buff
			if v.nAttackType ~= EnumDamage.BUFF and v.nAttackType ~= EnumDamage.BUFFERMOVE  then
				--不是buff
				--判断战斗是否是AOE
				if v.nSkillId == tRoundMessage.nSkillId then
					if v.nAttackType == EnumDamage.NORMAL then
						--AOE
						table.insert(tRoundMessage.nBeAttackId, v.nBeAttackId[1]);
						local eHurtEnum = t:GetHurtType(v.nAttackType);
						for k, value in pairs(v.nDamageHurt) do
							table.insert(tRoundMessage.nDamageHurt,{ {v.nAttackId,v.nBeAttackId[1]},  value, eHurtEnum, tRoundMessage.nSkillId});
						end
					else
						--暂时处理按照AOE处理
						-- table.insert(tRoundMessage.nBeAttackId, v.nBeAttackId[1]);
						local eHurtEnum = t:GetHurtType(v.nAttackType);
						for k, value in pairs(v.nDamageHurt) do
							table.insert(tRoundMessage.nDamageHurt,{ {v.nAttackId,v.nBeAttackId[1]},  value, eHurtEnum, tRoundMessage.nSkillId});
						end
					end
				else
					t:AssemblyMore(tRoundMessage, v);
				end
			else
				--是buffer
				local bAdd = true;
				if v.nAttackType ~= EnumDamage.BUFF then
					bAdd = false;
				end
				local tBuffers = t:BufferAdditional(v.sAdditional, v.nBeAttackId, bAdd);
				for k,d in ipairs(tBuffers) do
					table.insert(tRoundMessage.tBuffer,d);
				end
			end
		end
	end
	if tRoundMessage ~= nil then
		--****************************
		t:SkillAttack(tRoundMessage, tRoundMessage.nSkillId);
	else
		cclog("***严重错误,技能数据组合失败---");
	end
end

--解析行动回合2以上的数据
function t:AssemblyMore(tMainMsg,tMessage)
	if tMessage.nSkillId == 20047 then	--敌死后HP恢复5%
		for k, v in pairs(tMessage.nDamageHurt) do
			local tSpriteHurt = {{{tMessage.nAttackId,tMessage.nBeAttackId[1]}, v, HurtEnum.ADDHP_HURT, tMessage.nSkillId}};-- 执行Buffer伤害播放
			table.insert(tMainMsg.tBuffer,{BufferEnum.HP_BUFFER, tSpriteHurt, tMessage.nSkillId});
		end
	elseif tMessage.nSkillId == 20073 then	--受到直攻伤害时，反弹伤害的15%给对方
		for k, v in pairs(tMessage.nDamageHurt) do
			local tSpriteHurt = {{{tMessage.nAttackId,tMessage.nBeAttackId[1]},v, HurtEnum.NORMAL_HURT, tMessage.nSkillId}};		
			table.insert(tMainMsg.tBuffer,{BufferEnum.HP_BUFFER, tSpriteHurt, tMessage.nSkillId});
		end
	elseif tMessage.nSkillId == 20076 then	--每次受到直攻，都会对攻击者造成Con 5%的伤害
		for k, v in pairs(tMessage.nDamageHurt) do
			local tSpriteHurt = {{{tMessage.nAttackId,tMessage.nBeAttackId[1]}, v, HurtEnum.NORMAL_HURT, tMessage.nSkillId}};		
			table.insert(tMainMsg.tBuffer,{BufferEnum.HP_BUFFER, tSpriteHurt, tMessage.nSkillId});
		end
	elseif tMessage.nSkillId == 20079 then	--死亡时如果自己有召唤物存在，它们每个持续回合数都为你回复3%HP。在回复之后如果你的HP为正数，则复活，并清除你的所有召唤。每场战斗只能使用一次
		for k, v in pairs(tMessage.nDamageHurt) do
			local tSpriteRebith = {{tMessage.nAttackId,tMessage.nBeAttackId[1]}, v};
			table.insert(tMainMsg.tBuffer,{BufferEnum.REBIRTH_BUFFER, tSpriteRebith, tMessage.nSkillId});
		end
	elseif tMessage.nSkillId == 20081 then	--死亡时如果自己有召唤物存在，它们每个持续回合数都为你回复3%HP。在回复之后如果你的HP为正数，则复活，并清除你的所有召唤。每场战斗只能使用一次
		for k, v in pairs(tMessage.nDamageHurt) do
			local tSpriteRebith = {{tMessage.nAttackId,tMessage.nBeAttackId[1]}, v};
			table.insert(tMainMsg.tBuffer,{BufferEnum.REBIRTH_BUFFER, tSpriteRebith, tMessage.nSkillId});
		end
	elseif tMessage.nSkillId == 20113 then
		for k, v in pairs(tMessage.nDamageHurt) do
			local tSpriteHurt = {{{tMessage.nAttackId,tMessage.nBeAttackId[1]}, v, HurtEnum.NORMAL_HURT, tMessage.nSkillId}};		
			table.insert(tMainMsg.tBuffer,{BufferEnum.HP_BUFFER, tSpriteHurt, tMessage.nSkillId});
		end
	else
		cclog("~~~AssemblyMore Not Find BufferId May Create Error~~~");
		local eHurtEnum = t:GetHurtType(tMessage.nAttackType);
		for k, v in pairs(tMessage.nDamageHurt) do
			local tSpriteHurt = {{{tMessage.nAttackId,tMessage.nBeAttackId[1]}, v, eHurtEnum, tMessage.nSkillId}};-- 执行Buffer伤害播放
			local eBuffEnum = t:GetBuffEnumByHurtEnum(tMessage.nAttackType);
			if eBuffEnum ~= nil then
				table.insert(tMainMsg.tBuffer,{eBuffEnum, tSpriteHurt, tMessage.nSkillId});
			end
		end
	end
end


--技能攻击
function t:SkillAttack(tMessage, nSkillId)
	if GameFightCenter:IsShowLog() then
		cclog("---释放技能ID:"..tostring(tMessage.nSkillId).."---");
	end
	-- bSkillType1:被击中, 2:回避 ,3:格挡, 4:被击反击 5:回避反击
	local bSkillType = t:GetSkillType(tMessage.nAttackType);
	if tMessage.nAttackType == 0 then
		bSkillType = 1;		--NORMAL = 0,	普通命中
	elseif tMessage.nAttackType == 1 then
		bSkillType = 1;		--CRITICAL = 1, 暴击
	elseif tMessage.nAttackType == 2 then
		bSkillType = 3;		-- DODGE = 2,   闪避
	elseif tMessage.nAttackType == 3 then	
		bSkillType = 2;		-- PARRY = 3,   格挡
	elseif tMessage.nAttackType == 4 then	
		bSkillType = 1;	-- CURE = 4,	治疗
	elseif tMessage.nAttackType == 10 then	
		bSkillType = 1;	-- 自伤
	elseif tMessage.nAttackType == 11 then	
		bSkillType = 1;	-- 眩晕
	elseif tMessage.nAttackType == 12 then	
		bSkillType = 1;	-- 移除Buff
	elseif tMessage.nAttackType == 13 then	
		bSkillType = 1;	-- 没有攻击
	elseif tMessage.nAttackType == 25 then	
		bSkillType = 1; --战斗对话
	end
	if bSkillType ~= nil then

		local nType = nil;		
		--如果是战斗对话的
		if tMessage.nAttackType == 25 then	
			nType = 25; --战斗对话
		else
			--返回 1:表示施法， 2:表示攻击
			if nSkillId < 20000 then
				--技能
				nType = CfgData["cfg_skill"][nSkillId]["act_type"];
			else
				--Buff
				nType = 3;
			end
			
			if nType ~= 1 and nType ~= 3 then
				--不是施法继续判断武器
				nType = t:JudgeAttackType(tMessage.nAttackId);
			end
		end
		
		--是否是显示黑屏的特别技能呢?
		t:IsShowGrayLayer(nSkillId)
		
		if nType == 2 then
			--近战攻击
			SpriteSkill:ReleaseAllMeleeAttack(tMessage.nAttackId, tMessage.nBeAttackId, nSkillId, bSkillType, tMessage.nDamageHurt, nil, tMessage.tBuffer, tMessage.tStateArray, tMessage.nAttackType);
		elseif nType == 1 then
			--施法攻击
			SpriteSkill:ReleaseAllRemoteAttack(tMessage.nAttackId, tMessage.nBeAttackId,  nSkillId, bSkillType, tMessage.nDamageHurt, nil, tMessage.tBuffer, tMessage.tStateArray, tMessage.nAttackType);
		elseif nType == 3 then
			--直接结算
			SpriteSkill:ReleaseAllBufferAttack(tMessage.nAttackId, tMessage.nBeAttackId,  nSkillId, bSkillType, tMessage.nDamageHurt, nil, tMessage.tBuffer, tMessage.tStateArray, tMessage.nAttackType);
		elseif nType == 25 then
			--战斗对话
			SpriteSkill:ReleaseAllHeroSayAttack(tMessage.nAttackId, tMessage.nBeAttackId, nSkillId);
		else
			cclog("***严重错,技能施法类型判断错误---");
		end
		-------------------------------------
		-- GameFightCenter:LayerMoveAction()
	else
		cclog("***严重错误, 释放技能错误，由于没有相对应的攻击类型=%d---",tMessage.nAttackType);
	end
end


--*****************************************************

--攻击类型判断
--判断是否是移动攻击,还是定位施法
--1:判断施法还是攻击技能(施法-定位，攻击-移位)
--2:攻击-移位的话判断武器是否远程武器
--3:拿远程武器-改变回施法-定位
--返回 1:表示施法， 2:表示攻击
function t:JudgeAttackType(nAttackId)
	local tArmture = SpriteArmaturePool:GetArmature(nAttackId);
	if tArmture ~= nil then
		if tArmture.RoleType == 1 then		--[[右手双面斧头]]
			return 2;
		elseif tArmture.RoleType == 2 then 	--[[右手当面斧头]]
			return 2;
		elseif tArmture.RoleType == 3 or tArmture.RoleType == 0 then --[[右手长戟,没有武器]]
			return 2;
		elseif tArmture.RoleType == 4 then --[[右手短剑]]
			return 2;
		elseif tArmture.RoleType == 5 then --[[左手弓箭]]
			return 1;
		elseif tArmture.RoleType == 6 then --[[左手法杖]]
			return 1;
		else
			cclog("***严重错误,攻击类型判断查找武器类型错误---");
		end
	else
		cclog("***严重错误,攻击类型判断查找战斗英雄查找错误---");
	end
	return nil;
end

-- 添加Buffer解析
-- 附加状态串
-- sAdditional, 附加状态ID以,进行分割
-- tBeAttackId, 被添加英雄的表
-- bAddBuff		添加一次还是删除一次
function t:BufferAdditional(sAdditional, tBeAttackId, bAddBuff)
	local tBuffer = {};
	if sAdditional ~= nil then
		local nRoundTime = 1;
		if not bAddBuff then
			nRoundTime = -1;
		end
		local tAdditional = Split(sAdditional, ",", false);
		for i, v in pairs(tAdditional) do
			local nBufferId = tonumber(v);
			if nBufferId ~= nil then
				t:BufferList(tBuffer, nBufferId, tBeAttackId[1], nRoundTime)
			end
		end
	end
	return tBuffer;
end

--所有BufferI对应的数据
function t:BufferList(tBuffer, nBufferId, nBeAttackId, nRoundTime)
	
	if nBufferId == 20161 then 		--**力场护盾
		table.insert(tBuffer,{BufferEnum.ARMATURE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20036 then 	--**
		table.insert(tBuffer,{BufferEnum.PARTICLE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20057 then  --**
		table.insert(tBuffer,{BufferEnum.PARTICLE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20059 then 	--**
		table.insert(tBuffer,{BufferEnum.PARTICLE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20065 then  --**
		table.insert(tBuffer,{BufferEnum.ARMATURE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20067 then  --**
		table.insert(tBuffer,{BufferEnum.ARMATURE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20069 then  --**
		table.insert(tBuffer,{BufferEnum.ARMATURE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20073 then  --**
		table.insert(tBuffer,{BufferEnum.ARMATURE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20079 then  --**
		table.insert(tBuffer,{BufferEnum.ARMATURE_BUFFER, nBeAttackId, nBufferId, nRoundTime});				
	elseif nBufferId == 20081 then  --**
		table.insert(tBuffer,{BufferEnum.ARMATURE_BUFFER, nBeAttackId, nBufferId, nRoundTime});		
	elseif nBufferId == 20087 then  --**
		table.insert(tBuffer,{BufferEnum.ARMATURE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20100 then 	--**
		table.insert(tBuffer,{BufferEnum.ARMATURE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20101 then 	--**
		table.insert(tBuffer,{BufferEnum.ARMATURE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20103 then 	--**
		table.insert(tBuffer,{BufferEnum.ARMATURE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20114 then 	--**
		table.insert(tBuffer,{BufferEnum.ARMATURE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20115 then 	--**
		table.insert(tBuffer,{BufferEnum.ARMATURE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20122 then 	--**
		table.insert(tBuffer,{BufferEnum.PARTICLE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20126 then  --**
		table.insert(tBuffer,{BufferEnum.PARTICLE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20130 then  --**
		table.insert(tBuffer,{BufferEnum.ARMATURE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20131 then  --**
		table.insert(tBuffer,{BufferEnum.STATE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20132 then  --**
		table.insert(tBuffer,{BufferEnum.ARMATURE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20133 then  --**
		table.insert(tBuffer,{BufferEnum.STATE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20141 then  --**
		table.insert(tBuffer,{BufferEnum.ACTION_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20143 then 	--**
		table.insert(tBuffer,{BufferEnum.PARTICLE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20144 then  --**
		table.insert(tBuffer,{BufferEnum.ARMATURE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20145 then 	--**
		table.insert(tBuffer,{BufferEnum.PARTICLE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20147 then 	--**
		table.insert(tBuffer,{BufferEnum.PARTICLE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	elseif nBufferId == 20148 then 	--**
		table.insert(tBuffer,{BufferEnum.ARMATURE_BUFFER, nBeAttackId, nBufferId, nRoundTime});
	else
		if GameFightCenter:IsShowLog() then
			cclog("---SkillReleaseCenter的BufferID= %d,不需要显示---", nBufferId);
		end
	end
end

-- 伤害技能
function t:GetSkillType(nAttackType)

	-- bSkillType1:被击中, 2:回避 ,3:格挡, 4:被击反击 5:回避反击
	local bSkillType = nil;
	if nAttackType == 0 then
		bSkillType = 1;		--NORMAL = 0,	普通命中
	elseif nAttackType == 1 then
		bSkillType = 1;		--CRITICAL = 1, 暴击
	elseif nAttackType == 2 then
		bSkillType = 3;		-- DODGE = 2,   闪避
	elseif nAttackType == 3 then
		bSkillType = 2;		-- PARRY = 3,   格挡
	elseif nAttackType == 4 then
		bSkillType = 1;		-- CURE = 4,	治疗
	elseif nAttackType == 5 then
		bSkillType = 1;		-- SUCK	= 5,    吸血
	elseif nAttackType == 6 then
		bSkillType = 1;		-- REBOUND = 6, 反弹
	elseif nAttackType == 7 then
		bSkillType = 1;		-- BATBACK = 7,	反击
	elseif nAttackType == 8 then
		bSkillType = 1;		-- BUFF	= 8, 	状态
	end	
	return bSkillType;
end

-- 伤害类型
function t:GetHurtType(nAttackType)
	if nAttackType == EnumDamage.NORMAL then --普通命中
		return HurtEnum.NORMAL_HURT;
	elseif nAttackType ==  EnumDamage.CIRTICAL then --暴击
		return HurtEnum.CIRT_HURT;
	elseif nAttackType ==  EnumDamage.DODGE	then --闪避
		return HurtEnum.NOSHOW_HURT;
	elseif nAttackType ==  EnumDamage.PARRY	then --格挡
		return HurtEnum.NORMAL_HURT;
	elseif nAttackType ==  EnumDamage.CURE	then --治疗
		return HurtEnum.ADDHP_HURT;
	elseif nAttackType ==  EnumDamage.SUCK	then --吸血
		return HurtEnum.ADDHP_HURT;
	elseif nAttackType ==  EnumDamage.REBOUND	then --反弹
		return HurtEnum.NORMAL_HURT;
	elseif nAttackType ==  EnumDamage.BATBACK	then --反击
		return HurtEnum.NORMAL_HURT;
	elseif nAttackType ==  EnumDamage.BUFF	then --状态
		return HurtEnum.NOSHOW_HURT;
	elseif nAttackType ==  EnumDamage.REVIVE	then --复活
		return HurtEnum.ADDHP_HURT;
	elseif nAttackType ==  EnumDamage.SELF	then --自伤
		return HurtEnum.NORMAL_HURT;
	elseif nAttackType ==  EnumDamage.VERTIGO	then --眩晕
		return HurtEnum.NORMAL_HURT;
	elseif nAttackType ==  EnumDamage.BUFFERMOVE	then --移除Buff伤害
		return HurtEnum.NORMAL_HURT;
	elseif nAttackType ==  EnumDamage.NONE	then --无任何
		return HurtEnum.NORMAL_HURT;
	end
	cclog("***严重错误函数t:GetHurtType("..nAttackType..")---(SkillReleaseCenter)");
end

function t:GetBuffEnumByHurtEnum(nAttackType)
	if nAttackType == EnumDamage.NORMAL then --普通命中
		return BufferEnum.HP_BUFFER;
	elseif nAttackType ==  EnumDamage.CIRTICAL then --暴击
		return BufferEnum.HP_BUFFER;
	elseif nAttackType ==  EnumDamage.DODGE	then --闪避
		cclog("***GetBuffEnumByHurtEnum 由于闪避 返回 nil---");
	elseif nAttackType ==  EnumDamage.PARRY	then --格挡
		cclog("***GetBuffEnumByHurtEnum 由于格挡 返回 nil---");
	elseif nAttackType ==  EnumDamage.CURE	then --治疗
		return BufferEnum.HP_BUFFER;
	elseif nAttackType ==  EnumDamage.SUCK	then --吸血
		return BufferEnum.HP_BUFFER;
	elseif nAttackType ==  EnumDamage.REBOUND	then --反弹
		return BufferEnum.HP_BUFFER;
	elseif nAttackType ==  EnumDamage.BATBACK	then --反击
		return BufferEnum.HP_BUFFER;
	elseif nAttackType ==  EnumDamage.BUFF	then --状态
		cclog("***GetBuffEnumByHurtEnum 由于状态 返回 nil---");
	elseif nAttackType ==  EnumDamage.REVIVE	then --复活
		return BufferEnum.REBIRTH_BUFFER;
	elseif nAttackType ==  EnumDamage.SELF	then --自伤
		return BufferEnum.HP_BUFFER;
	elseif nAttackType ==  EnumDamage.VERTIGO	then --眩晕
		cclog("***GetBuffEnumByHurtEnum 由于眩晕 返回 nil---");
	elseif nAttackType ==  EnumDamage.BUFFERMOVE	then --移除Buff伤害
		cclog("***GetBuffEnumByHurtEnum 由于移除Buff伤害 返回 nil---");
	elseif nAttackType ==  EnumDamage.NONE	then --无任何
		cclog("***GetBuffEnumByHurtEnum 由于任何 返回 nil---");
	else
		cclog("***严重错误函数t:GetBuffEnumByHurtEnum("..nAttackType..")---(SkillReleaseCenter)");
	end
	return nil;
end

--是否显示黑屏
function t:IsShowGrayLayer(nSkillId)
	--只有技能才能显示黑屏
	if nSkillId < 20000 then
		if CfgData["cfg_skill"][nSkillId] ~= nil then
			if CfgData["cfg_skill"][nSkillId]["show"] == 1 then
			-- if nSkillId == 10390 or nSkillId == 10410 then
				 GameFightCenter:ShowGrayLayer();
			-- end
			end
		end
	end
end
