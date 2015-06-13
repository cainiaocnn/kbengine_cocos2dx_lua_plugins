-- 技能管理器
-- 场景的特效表现或者技能表现池
-- 只能播放一次或者多次,不能再界面上持续显示的特效

SceneSkillEffectPool = {};
local t = SceneSkillEffectPool;
-- 数据
local tSkillEffectQueue = {};


SceneSkillType = {
	ARMTURE_TYPE = 1, --骨骼动画表现
	PARTICLE_TYPE= 2, --粒子特效表现
}

SceneSkillEnum = {
	LAYER_TYPE = 1,		--显示在层
	SPRITE_TYPE = 2,	--显示在英雄
};

--技能施法
SkillExtEnum = {
	SKILL_RELSEAS_1 = 1,	--技能施法1(攻击)
	SKILL_RELSEAS_2 = 2,	--技能施法2(治疗)
	SKILL_RELSEAS_3 = 3,	--技能施法3(什么都没有)
}

--账号注销回调函数
function t.gameLoginOut()
	tSkillEffectQueue = {};
end

-- 数据部分*******************************************
------------------------------------------------------
-- 压入一个特效数据
function t:PushInEffectToQueue(tEffect)
	table.insert(tSkillEffectQueue, tEffect);
end

-- 推出一个特效数据
function t:PushOutEffectFromQueue()
	if #tSkillEffectQueue > 0 then
		local tEffect = tSkillEffectQueue[1];
		table.remove(tSkillEffectQueue, 1);
		return tEffect;
	end
	return nil;
end


-- 技能特效解析
function t:ShowEffect(tEffect)
	if tEffect ~= nil then
		--这个数据由 SpriteActionPool发送来的
		local nAttackTag		= tEffect[1];--攻击精灵
		local tBeAttackTag		= tEffect[2];--被击精灵表
		local tParam			= tEffect[3];--技能参数
		t:ShowSkill(nAttackTag, tBeAttackTag, tParam);
	end
end

--显示一个技能
--nAttackTag:施法技能的精灵ID
--tBeAttackTag:被击精灵表
--tParam:技能显示参数
function t:ShowSkill(nAttackTag, tBeAttackTag, tParam)

	local tShowArmature = SpriteArmaturePool:GetArmature(nAttackTag);
	if tShowArmature ~= nil then
		
		local nSkillID  = tParam[1];
		local bSkiilHit = tParam[2];
		local eSkillExt = tParam[3];
		local nRoleType = tShowArmature.RoleType;
		--------------------------------------------
		
		local tShowSkillInfo = t:GetSkillInfoByID(nRoleType, nSkillID, bSkiilHit, tBeAttackTag, nAttackTag, eSkillExt);
		if tShowSkillInfo ~= nil then
			
			-- 技能音效
			-- GameFightMusic.PlaySkillEffectMusic(nSkillID, eSkillExt);
			
			--攻击英雄显示的特效
			local tSkillInfo1 = tShowSkillInfo[1];
			if tSkillInfo1 ~= nil then
				for i,v in ipairs(tSkillInfo1) do
					--技能名字不为nil才播放技能
					if v[3] ~= nil then
						-- 表示是播放的是粒子特效
						if v[1] == SceneSkillType.PARTICLE_TYPE then
							if v[2] == SceneSkillEnum.LAYER_TYPE then
								-- 特效是加载战斗层中
								t:ShowParticleLayer(nAttackTag, v[3], v[4], v[5]);
							else
								-- 特效是加在英雄中的
								t:ShowParticleSprite(nAttackTag, v[3], v[4], v[5]);
							end
						else
						-- 表示是播放的是骨骼特效
							if v[2] == SceneSkillEnum.LAYER_TYPE then
								-- 特效是加载战斗层中
								t:ShowArmatureLayer(nAttackTag, v[3], v[4], v[5]);
							else
								-- 特效是加在英雄中的
								t:ShowArmatureSprite(nAttackTag, v[3], v[4], v[5]);
							end
						end
					end
				end
			end
			--被击英雄显示的特效
			local tSkillInfo2 = tShowSkillInfo[2];
			if tSkillInfo2 ~= nil then
				for i,d in ipairs(tSkillInfo2) do
					for j,v in ipairs(d) do
						--技能名字不为nil才播放技能
						if v[3] ~= nil then
							-- 表示是播放的是粒子特效
							if v[1] == SceneSkillType.PARTICLE_TYPE then
								if v[2] == SceneSkillEnum.LAYER_TYPE then
									-- 特效是加载战斗层中
									t:ShowParticleLayer(tBeAttackTag[i], v[3], v[4], v[5]);
								else
									-- 特效是加在英雄中的
									t:ShowParticleSprite(tBeAttackTag[i], v[3], v[4], v[5]);
								end
							else
							-- 表示是播放的是骨骼特效
								if v[2] == SceneSkillEnum.LAYER_TYPE then
									-- 特效是加载战斗层中
									t:ShowArmatureLayer(tBeAttackTag[i], v[3], v[4], v[5]);
								else
									-- 特效是加在英雄中的
									t:ShowArmatureSprite(tBeAttackTag[i], v[3], v[4], v[5]);
								end
							end
						end
					end
				end
			end
			
			--技能导致产生的动作(例如:飞行)
			SkillActionPerform:SkillLeadToAction(nSkillID, bSkiilHit, nAttackTag, tBeAttackTag);
			
		end
	else
		cclog("***显示一个英雄释放的技能,由于没有找到释放的英雄,导出播放失败错误---");
	end
end


--显示一个特效(添加到场景层的)
function t:ShowParticleLayer(nTagID, skillName, fDelTime, tMusicInfo)
	local pActiveLayer = GameFightCenter:GetActiveLayer();
	if pActiveLayer ~= nil then
		local tShowArmature = SpriteArmaturePool:GetArmature(nTagID);
		if tShowArmature ~= nil then
			local function func()
				-- 创建特效位置
				local skillPos = ccp(tShowArmature.Sprite:getPosition());
				--创建粒子
				local pParticle = CCParticleSystemQuad:create(skillName);
				if pParticle == nil then
					cclog("***显示一个特效(添加到场景层的)失败,创建粒子:%s---",skillName);
					return;
				end
				--加入显示纹理
				local pShowBatch = CCParticleBatchNode:createWithTexture(pParticle:getTexture());
				if pShowBatch ~= nil then
					--设置位置
					pParticle:setPosition(skillPos);
					pShowBatch:addChild(pParticle);
				else
					cclog("***加入显示纹理失败,ShowParticleLayer---");
					return;
				end
				--播放完毕删除
				local delay = 1.0;--pParticle:getDuration();
				local function listener()
					if pShowBatch ~= nil then
						pShowBatch:removeFromParentAndCleanup(true);
					else
						cclog("***场景技能特效显示删除失败1---");
					end
				end
				Scheduler.performWithDelayGlobal(listener, delay);
				pActiveLayer:addChild(pShowBatch, 100);
				
				--Music
				GameFightMusic.PlaySkillEffectMusic(tMusicInfo);
				
			end
			
			if fDelTime > 0 then
				Scheduler.performWithDelayGlobal(func, fDelTime);
			else
				func();
			end
		else
			cclog("***显示一个特效(添加到场景层的)错误1---");
		end
	else
		cclog("***显示一个特效(添加到场景层的)错误2---");
	end
end

--显示一个特效(添加到精灵中的)
function t:ShowParticleSprite(nTagID, skillName, fDelTime, tMusicInfo)
	local tShowArmature = SpriteArmaturePool:GetArmature(nTagID);
	if tShowArmature ~= nil then
		local function func()
			-- 创建特效位置
			-- local skillPos = ccp(tShowArmature.Sprite:getPosition());
			--创建粒子
			local pParticle = CCParticleSystemQuad:create(skillName);
			if pParticle == nil then
				cclog("***显示一个特效(添加到精灵中的)失败,创建粒子:%s---",skillName);
				return;
			end
			--加入显示纹理
			local pShowBatch = CCParticleBatchNode:createWithTexture(pParticle:getTexture());
			if pShowBatch ~= nil then
				--设置位置
				-- pParticle:setPosition(skillPos);
				pShowBatch:addChild(pParticle);
			else
				cclog("***加入显示纹理失败,ShowParticleSprite---");
				return;
			end
			--播放完毕删除
			local delay = 1.0;--pParticle:getDuration();
			local function listener()
				if SpriteArmaturePool:GetArmature(nTagID) ~= nil then
					if pShowBatch ~= nil then
						pShowBatch:removeFromParentAndCleanup(true);
					else
						cclog("***场景技能特效显示删除失败2---");
					end
				else
					if GameFightCenter:IsShowLog() then
						cclog("---Sprite is dead so it not be delete---");
					end
				end
			end
			Scheduler.performWithDelayGlobal(listener, delay);
			--暂时处理
			tShowArmature.Sprite:addChild(pShowBatch, 100);
			
			--Music
			GameFightMusic.PlaySkillEffectMusic(tMusicInfo);
		end
		--延时播放
		if fDelTime > 0 then
			Scheduler.performWithDelayGlobal(func, fDelTime);
		else
			func();
		end
	else
		cclog("***显示一个特效(添加到精灵中的)错误1---");
	end	
end


--显示一个骨骼(添加到战斗层中)
function t:ShowArmatureLayer(nTagID, armtureName, fDelTime, tMusicInfo)
	local pActiveLayer = GameFightCenter:GetActiveLayer();
	if pActiveLayer ~= nil then
		local tShowArmature = SpriteArmaturePool:GetArmature(nTagID);
		if tShowArmature ~= nil then
			local function func()
				if armtureName ~= nil then
					local tArmatureEffect = CreateArmatureEffect();
					local pEffect = tArmatureEffect:CreateEffectSprite(armtureName, 0, true);
					if pEffect ~= nil then
						local skillPos = ccp(tShowArmature.Sprite:getPosition());
						tArmatureEffect:SetPostion(skillPos);
						
						--注:修改过的，原先不是这样的
						if tShowArmature.IsEnemy then
							tArmatureEffect:SetFlip(true,false);
						end
						
						pActiveLayer:addChild(pEffect, 100);
						
						--Music
						GameFightMusic.PlaySkillEffectMusic(tMusicInfo);
					else
						cclog("***显示一个骨骼(添加到战斗层中)失败,骨骼:%s---",armtureName);
					end
				end
			end
			if fDelTime > 0 then
				Scheduler.performWithDelayGlobal(func, fDelTime);
			else
				func();
			end
		else
			cclog("***显示一个骨骼(添加到战斗层中)失败,ShowArmatureLayer_1---");
		end
	else
		cclog("***显示一个骨骼(添加到战斗层中)失败,ShowArmatureLayer_2---");
	end
end

--显示一个骨骼(添加到精灵中)
function t:ShowArmatureSprite(nTagID, armtureName, fDelTime, tMusicInfo)
	local tShowArmature = SpriteArmaturePool:GetArmature(nTagID);
	if tShowArmature ~= nil then
		local function func()
			if armtureName ~= nil then
				local tArmatureEffect = CreateArmatureEffect();
				local pEffect = tArmatureEffect:CreateEffectSprite(armtureName, 0, true);
				if pEffect ~= nil then
					local nTag = tShowArmature:AddArmatureEffect(tArmatureEffect);
					tArmatureEffect:SetAutoInfo(tShowArmature.RemoveArmatureEffect, nTag);
					
					--Music
					GameFightMusic.PlaySkillEffectMusic(tMusicInfo);
				else
					cclog("***显示一个骨骼(添加到精灵中)失败,骨骼:%s---",armtureName);
				end
			end
		end
		if fDelTime > 0 then
			Scheduler.performWithDelayGlobal(func, fDelTime);
		else
			func();
		end
	else
		cclog("***显示一个骨骼(添加到精灵中)失败,ShowArmatureSprite---");
	end
end

-- 获取技能表现的数据
--------------------------------------------------------------------
function t:GetSkillInfoByID(nRoleType, nSkillID, bSkiilHit, tBeAttackTag, nAttackTag, eSkillExt)
	
	if nSkillID == 10010 then --普通攻击
	
		return t:NormalAttackSkillInfo(nRoleType, bSkiilHit);
		
	elseif nSkillID == 10020 then --猛击 √
	
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit, nil, {10020, eSkillExt});
		local tListInfo  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectdirectattack003.plist", 0.2};
		table.insert(tSkillInfo[2][1], tListInfo);
		return tSkillInfo;
		
	elseif nSkillID == 10120 then --顺势斩 10040顺势斩ID更改为10120 √
		
		--配置受击目标
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit);
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectdirectattack001.plist", 0.2, {10120,eSkillExt}};
		table.insert(tSkillInfo[2][1], tListInfo1);
		local tListInfo2  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectsputteringdust.plist", 0.2};
		table.insert(tSkillInfo[2][1], tListInfo2);
		local tListInfo3  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectsputteringwave", 0.2};
		table.insert(tSkillInfo[2][1], tListInfo3);
		
		--配置溅射目标
		for i,v in ipairs(tBeAttackTag) do
			if i>1 then--第一个是受击的上面已经处理了
				local tInfo = {}
				table.insert(tInfo, {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectsputteringblow.plist", 0.2});
				table.insert(tSkillInfo[2], tInfo);
			end
		end
		return tSkillInfo;
		
	elseif nSkillID == 10060 then --魔法攻击
						
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000,eSkillExt}}, nil}, nil};
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectmagicmissile", 0.2});
		if bSkiilHit then
			table.insert(tInfo, {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectdirectattack001.plist", 0.4, {10060, eSkillExt}});
		end
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
		
	elseif nSkillID == 10090 then --穿刺攻击
		
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit);
		local tListInfo  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectdirectattack001.plist", 0.2, {10090,eSkillExt}};
		table.insert(tSkillInfo[2][1], tListInfo);
		return tSkillInfo;
		
	--	删除原10120力量牵制 改为 新增技能10040“牵制”
	elseif nSkillID == 10040 then --力量牵制 技能删除
	
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit);
		local tListInfo  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectfixeddamage001.plist", 0.2, {10040, eSkillExt}};
		table.insert(tSkillInfo[2][1], tListInfo);
		return tSkillInfo;

	elseif nSkillID == 10130 then --附魔攻击
		
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit);
		local tListInfo  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectdirectattack002.plist", 0.2, {10130,eSkillExt}};
		table.insert(tSkillInfo[2][1], tListInfo);
		return tSkillInfo;
	elseif nSkillID == 10155 then --群嘲
	
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "EffectMasstaunt", 0, {10155, eSkillExt}}, nil}, nil};		
		return tSkillInfo;	
		
	elseif nSkillID == 10160 then --身体冲撞
	
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit);
		local tListInfo  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectdirectattack001.plist", 0.2, {10160,eSkillExt}};
		table.insert(tSkillInfo[2][1], tListInfo);
		return tSkillInfo;
		
	elseif nSkillID == 10200 then --连发火球
			
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000,eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2, {10200, eSkillExt}};
		table.insert(tSkillInfo[1], tListInfo1);
		
		--连发溅射
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectfireball", 0});
		if bSkiilHit then
			table.insert(tInfo, {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.LAYER_TYPE, "effects/Effectfireballburn.plist", 0.4});
			table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.LAYER_TYPE, "Effectfireballwave", 0.2});
		end
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		
		return tSkillInfo;
	
	elseif nSkillID == 10220 then --魔法暴击
	
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000, eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
	
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectmissilestrom", 0.2,{10220,eSkillExt}});
		if bSkiilHit then
			table.insert(tInfo, {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectdirectattack002.plist", 0.2});
		end
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
	
	elseif nSkillID == 10240 then --惩罚刺击


		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {102401, eSkillExt}}, nil}, nil};
		local tListInfo_1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo_1);
		
		--攻击目标
		local tBeAttackInfo = {};
		local tInfo = {}
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectDisciplinarysting", 0, {102402,eSkillExt}});
		if bSkiilHit then
			table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectDisciplinarystingblow", 0.2, {102403, eSkillExt}});
		end		
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		
		return tSkillInfo;
	
	elseif nSkillID == 10270 or nSkillID == 10560 then --治疗
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000,eSkillExt}}, nil}, nil};
		
		local tListInfo2_1  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effecthealing", 0.4};
		local tListInfo2_2  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.4};
		table.insert(tSkillInfo[1], tListInfo2_1);
		table.insert(tSkillInfo[1], tListInfo2_2);
		
		--治疗目标
		local tBeAttackInfo = {};
		for i,v in ipairs(tBeAttackTag) do
			local tInfo = {}
			table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effecthealing", 0.4,{ nSkillID, eSkillExt}});
			table.insert(tInfo, {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectheal.plist", 0.4});
			table.insert(tBeAttackInfo, tInfo);
		end
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
	
	elseif nSkillID == 10290 then --毒牙
	
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit);
		local tListInfo1  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectpoisonfang", 0.2, {10290, eSkillExt}};
		table.insert(tSkillInfo[2][1], tListInfo1);
		if bSkiilHit then
			local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectpoisonfangfog.plist", 0.4};
			table.insert(tSkillInfo[2][1], tListInfo1);
		end	
		return tSkillInfo;
		
	elseif nSkillID == 10330 then --破邪一击
	
		--配置受击目标
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit);
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectdirectattack002.plist", 0.2,{10330,eSkillExt}};
		table.insert(tSkillInfo[2][1], tListInfo1);
		local tListInfo2  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectsputteringdust.plist", 0.2};
		table.insert(tSkillInfo[2][1], tListInfo2);
		local tListInfo3  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectsputteringwave", 0.2};
		table.insert(tSkillInfo[2][1], tListInfo3);
		
		--配置溅射目标
		for i,v in ipairs(tBeAttackTag) do
			if i>1 then--第一个是受击的上面已经处理了
				local tInfo = {};
				table.insert(tInfo, {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectsputteringblow.plist", 0.2});
				table.insert(tSkillInfo[2], tInfo);
			end
		end
		return tSkillInfo;
	
	elseif nSkillID == 10350 then --二段斩
	
		--配置受击目标
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit);

		local tListInfo1  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effecttwoattack", 0.2, {10350, eSkillExt}};
		table.insert(tSkillInfo[2][1], tListInfo1);
		local tListInfo2  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effecttwoattackpetal.plist", 0.2};
		table.insert(tSkillInfo[2][1], tListInfo2);
		if bSkiilHit then
			local tListInfo1  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effecttwoattackblow", 0.2};
			table.insert(tSkillInfo[2][1], tListInfo1);
			local tListInfo2  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effecttwoattackblowpetal.plist", 0.2};
			table.insert(tSkillInfo[2][1], tListInfo2);
		end
		return tSkillInfo;
		
	elseif nSkillID == 10360 then --狂暴旋风
		
		--配置受击目标
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit);
		local tListInfo1  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectViolentcyclone", 0.2, {10360,eSkillExt}};
		table.insert(tSkillInfo[2][1], tListInfo1);
		local tListInfo2  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/EffectBerserkerplist.plist", 0.2};
		table.insert(tSkillInfo[2][1], tListInfo2);
		if bSkiilHit then
			local tListInfo2  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectsputteringdust.plist", 0.2};
			table.insert(tSkillInfo[2][1], tListInfo2);
			local tListInfo3  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectsputteringwave", 0.2};
			table.insert(tSkillInfo[2][1], tListInfo3);
		end
		--配置溅射目标
		for i,v in ipairs(tBeAttackTag) do
			if i>1 then--第一个是受击的上面已经处理了
				local tInfo = {};
				table.insert(tInfo, {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectsputteringblow.plist", 0.2});
				table.insert(tSkillInfo[2], tInfo);
			end
		end
		return tSkillInfo;
		
	elseif nSkillID == 10380  or nSkillID == 11160 then --狂暴之心(清)
	
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectheartoffury", 0, {103801,eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/EffectBerserkerplist.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
	
		local tBeAttackInfo = {};
		local tInfo = {};
		if bSkiilHit then
			table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectfuryblow", 0.2, {103803,eSkillExt}});
		end
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectfuryattack", 0.2, {103802,eSkillExt}});
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
	
	elseif nSkillID == 10390 then --孤注一掷
		
		--配置受击目标
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit);
		tSkillInfo[2][1] = {};
		if bSkiilHit then
			tSkillInfo[2][1] = {{SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectfuryblow", 0.2}};
		end
		local tListInfo1  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectgzyz", 0.2, {10390,eSkillExt}};
		table.insert(tSkillInfo[2][1], tListInfo1);
		return tSkillInfo;

	elseif nSkillID == 10410 then --逆差攻击(增强)
		
		--配置受击目标
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit);
		-- tSkillInfo[2][1] = {};
		tSkillInfo[2][1] = {{SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.LAYER_TYPE, "EffectDeficitattack", 0.2, {104101,eSkillExt}}};
		if bSkiilHit then
			local tListInfo1  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.LAYER_TYPE, "EffectDeficitattackblow", 0.2, {104102,eSkillExt}};
			table.insert(tSkillInfo[2][1], tListInfo1);
		end
		return tSkillInfo;	
		
	elseif nSkillID == 10023 then --战吼 技能ID变更 11160战吼ID更改为10023
	
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectfury", 0, {100231, eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/EffectBerserkerplist.plist", 0.2, {100232, eSkillExt}};
		table.insert(tSkillInfo[1], tListInfo1);
	
		local tBeAttackInfo = {};
		local tInfo = {};
		if bSkiilHit then
			table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectfuryblow", 0.2, {100233, eSkillExt}});
		end
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectfuryattack", 0.2});
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
	elseif nSkillID == 10026 then --冲撞 技能ID变更 11170冲撞ID更改为10026
	
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit, nil, {10026, eSkillExt});
		local tListInfo  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectdirectattack001.plist", 0.2};
		table.insert(tSkillInfo[2][1], tListInfo);
		return tSkillInfo;
		
	elseif nSkillID == 10055 then --火球术 11180火球术ID更改为10055，且火球术增加aoe效果
		
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
		
		--连发溅射
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectfireball", 0, {10055, eSkillExt}});
		if bSkiilHit then
			table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.LAYER_TYPE, "Effectfireballwave", 0.2});
		end
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		
		return tSkillInfo;
		
	elseif nSkillID == 10085 then --迅捷一击 11190迅捷一击ID更改为10085
		
		--配置受击目标
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit);
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectdirectattack002.plist", 0.2, {10085, eSkillExt}};
		table.insert(tSkillInfo[2][1], tListInfo1);
		-- local tListInfo2  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectsputteringdust.plist", 0.2};
		-- table.insert(tSkillInfo[2][1], tListInfo2);
		-- local tListInfo3  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectsputteringwave", 0.2};
		-- table.insert(tSkillInfo[2][1], tListInfo3);
		return tSkillInfo;
	
	elseif nSkillID == 10840 then --刺客(暗影斗篷)
	
		--配置施法动作(只配置了施法特效,没有攻击)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "EffectCloakofShadows", 0, {nSkillID, eSkillExt}}, nil}, nil};
		table.insert(tSkillInfo[1], tListInfo1);
		return tSkillInfo;

	elseif nSkillID == 10850 then --刺客(异域毒刃)
	
		--配置施法动作(配置施法特效,和攻击目标特效)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000, eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectExoticShiv", 0.2,{nSkillID, eSkillExt}});
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;

	elseif nSkillID == 10860 then --刺客(背刺)
	
		--配置施法动作(配置施法特效,和攻击目标特效)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {108601, eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectStabintheback", 0.2,{108602, eSkillExt}});
		if bSkiilHit then
			table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectStabinthebackblow", 0.2, {108603, eSkillExt}});
		end
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
		
	elseif nSkillID == 10880 then --刺客(毒雾喷射)	
		--近战技能1V1配置普攻特效和被击特效
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit);
		if bSkiilHit then
			local tListInfo1  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectPoisoninjection", 0.2, {nSkillID, eSkillExt}};
			table.insert(tSkillInfo[2][1], tListInfo1);
		end
		return tSkillInfo;
		
	elseif nSkillID == 10890 then --刺客(暗影之刺)	
		--近战技能1V1配置普攻特效和被击特效
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit);
		if bSkiilHit then
			local tListInfo1  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectShadowthorn", 0.2, {nSkillID, eSkillExt}};
			table.insert(tSkillInfo[2][1], tListInfo1);
		end
		return tSkillInfo;
	
	elseif nSkillID == 11020 then --领主(眩晕攻击)
	
		--近战技能1V1配置普攻特效和被击特效
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit);
		if bSkiilHit then
			local tListInfo1  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectVertigoattack", 0.2, {nSkillID, eSkillExt}};
			table.insert(tSkillInfo[2][1], tListInfo1);
		end
		return tSkillInfo;
		
	elseif nSkillID == 11030 then --领主(荆棘护甲)
		cclog("***荆棘护甲--不可能出现在战报释放技能中,服务端严重bug---");
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit);
		return tSkillInfo;
		
	elseif nSkillID == 11050 then --领主(集火号角)	
		
		--配置施法动作(配置施法特效,和攻击目标特效)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000, eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectDownthehorn", 0.2, {nSkillID, eSkillExt}});
		-- if bSkiilHit then
			-- table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectStabinthebackblow", 0.2});
		-- end
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
		
	elseif nSkillID == 11060 then --领主(灵魂震慑)	
		--配置施法动作(配置施法特效,和攻击目标特效)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000,eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectSoulshock", 0.2, {nSkillID, eSkillExt}});
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
	
	elseif nSkillID == 10960 then --魔战士(内视)
	
		--配置施法动作(配置施法特效,和攻击目标特效)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000,eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectinwardvision", 0.2,{nSkillID, eSkillExt}});
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
		
	elseif nSkillID == 10970 then --魔战士(算术)
		--配置施法动作(配置施法特效,和攻击目标特效)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000,eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectArithmetic", 0.2, {nSkillID, eSkillExt}});
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;

	elseif nSkillID == 11000 then --魔战士(乱数)
		
		-- eSkillExt = SkillExtEnum.SKILL_RELSEAS_3
		if eSkillExt == SkillExtEnum.SKILL_RELSEAS_2 then--技能施法2(治疗)
			local eShowType  = SceneSkillType.ARMTURE_TYPE;
			local eAddType   = SceneSkillEnum.SPRITE_TYPE;
			local tSkillInfo = {{{eShowType, eAddType, "EffectRandomnumber001", 0, {110003,eSkillExt}}, nil}, nil};
			return tSkillInfo;
		elseif eSkillExt == SkillExtEnum.SKILL_RELSEAS_1 then--技能施法1(攻击)
			local eShowType  = SceneSkillType.ARMTURE_TYPE;
			local eAddType   = SceneSkillEnum.SPRITE_TYPE;
			local tSkillInfo = {{{eShowType, eAddType, "EffectRandomnumber002", 0, {10000,eSkillExt}}, nil}, nil};
			
			local tBeAttackInfo = {};
			local tInfo = {};
			table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectRandomnumberblow", 0.2, {110001,eSkillExt}});
			table.insert(tBeAttackInfo, tInfo);
			table.insert(tSkillInfo, tBeAttackInfo);
			return tSkillInfo;
			
		elseif eSkillExt == SkillExtEnum.SKILL_RELSEAS_3 then--技能施法3(什么都没有)
			local eShowType  = SceneSkillType.ARMTURE_TYPE;
			local eAddType   = SceneSkillEnum.SPRITE_TYPE;
			local tSkillInfo = {{{eShowType, eAddType, "EffectRandomnumber003", 0, {110002, eSkillExt}}, nil}, nil};
			return tSkillInfo;
		else
			cclog("***乱数--配置具体特效---");
		end
		return nil;
	elseif nSkillID == 11010 then --魔战士(真实视觉)
		--配置施法动作(配置施法特效,和攻击目标特效)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000, eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectTruesight", 0.2, {nSkillID, eSkillExt}});
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;	
		
	elseif nSkillID == 10780 then --审判(破甲攻击)
		
		--近战技能1V1配置普攻特效和被击特效
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit);
		if bSkiilHit then
			local tListInfo1  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectSunderArmor", 0.2, {nSkillID, eSkillExt}};
			table.insert(tSkillInfo[2][1], tListInfo1);
		end
		return tSkillInfo;
	elseif nSkillID == 10790 then --审判(审判之怒)
		--近战技能1V1配置普攻特效和被击特效
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit,nil);
		return tSkillInfo;
	elseif nSkillID == 10800 then --审判(力之审判)
		--配置施法动作(配置施法特效,和攻击目标特效)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000,eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectPowerofthetrial", 0.2, {nSkillID, eSkillExt}});
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
	elseif nSkillID == 10820 then --审判(裁决之光)
		--配置施法动作(配置施法特效,和攻击目标特效)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000,eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectThedecisionofthelight", 0.2,{nSkillID, eSkillExt}});
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
		
	elseif nSkillID == 10480 then --守望者(螺旋冲击)

		--配置施法动作(配置施法特效,和攻击目标特效)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {104801,eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectspiralshock", 0.2, {104802, eSkillExt}});
		if bSkiilHit then
			table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectGuardianblow", 0.2, {104803,eSkillExt}});
		end
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
		
	elseif nSkillID == 10490 then --守望者(削弱攻击)

		--配置施法动作(配置施法特效,和攻击目标特效)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectweakenattack", 0, {104901,eSkillExt}}, nil}, nil};
		
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectweakenattack02", 0.4, {104902, eSkillExt}});
		if bSkiilHit then
			table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectGuardianblow", 0.4});
		end
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
		
	elseif nSkillID == 10520 then --守望者(防御姿态)
		--近战技能1V1配置普攻特效和被击特效
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "EffectDefensivestance", 0, {10520,eSkillExt}}, nil}, nil};
		return tSkillInfo;
		
	elseif nSkillID == 10530 then --守望者(寓攻于守)
		--近战技能1V1配置普攻特效和被击特效		
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectyugongyushou", 0, {10530, eSkillExt}}, nil}, nil};
		return tSkillInfo;
		
	elseif nSkillID == 10420 then --死亡骑士(瘟疫之触)
		--配置施法动作(配置施法特效,和攻击目标特效)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000,eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectPlaguetouch", 0.2, {nSkillID, eSkillExt}});
		if bSkiilHit then
			table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectPlaguetouchblow", 0.2});
		end
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
	elseif nSkillID == 10430 then --死亡骑士(吸血)
		--
		cclog("***服务器下发技能错误,由于吸血技能是个被动技能---");
		--配置施法动作(配置施法特效,和攻击目标特效)
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit);
		local tListInfo1  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectsuckblood", 0.2};
		table.insert(tSkillInfo[2][1], tListInfo1);
		if bSkiilHit then
			local tListInfo1  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectsuckbloodblow", 0.2};
			table.insert(tSkillInfo[2][1], tListInfo1);
		end
		return tSkillInfo;
		
	elseif nSkillID == 10460 then --死亡骑士(死亡霜寒)
	
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit);
		local tListInfo1  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectThedeathofthefrost", 0.2, {nSkillID, eSkillExt}};
		table.insert(tSkillInfo[2][1], tListInfo1);
		if bSkiilHit then
			local tListInfo1  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectThedeathofthefrostblow", 0.2};
			table.insert(tSkillInfo[2][1], tListInfo1);
		end
		return tSkillInfo;
		
	elseif nSkillID == 10470 then --死亡骑士(吸血鬼之触)
		--配置施法动作(配置施法特效,和攻击目标特效)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000,eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectVampiricTouch", 0.2, {nSkillID, eSkillExt}});
		if bSkiilHit then
			table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectsuckbloodblow", 0.2});
		end
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
		
	elseif nSkillID == 10900 then --游侠(暗影闪击)
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit);
		local tListInfo1  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.LAYER_TYPE, "EffectShadowstrike", 0.2, {nSkillID, eSkillExt}};
		table.insert(tSkillInfo[2][1], tListInfo1);
		if bSkiilHit then
			local tListInfo1  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectrangerblow", 0.2};
			table.insert(tSkillInfo[2][1], tListInfo1);
		end
		return tSkillInfo;
	
	elseif nSkillID == 10910 then --游侠(灵巧连击)
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit);
		if bSkiilHit then
			local tListInfo1  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.LAYER_TYPE, "EffectSmartbatter001", 0.2, {nSkillID, eSkillExt}};
			table.insert(tSkillInfo[2][1], tListInfo1);		
		else
			local tListInfo1  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectSmartbatter002", 0.2, {nSkillID, eSkillExt}};
			table.insert(tSkillInfo[2][1], tListInfo1);
		end
		return tSkillInfo;
	elseif nSkillID == 10950 then --游侠(死亡之舞)
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit);
		if bSkiilHit then
			local tListInfo1  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectDanceOfTheDead001", 0.2,{nSkillID, eSkillExt}};
			table.insert(tSkillInfo[2][1], tListInfo1);		
		else
			local tListInfo1  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectDanceOfTheDead002", 0.2,{nSkillID, eSkillExt}};
			table.insert(tSkillInfo[2][1], tListInfo1);
		end
		return tSkillInfo;
	
	elseif nSkillID == 10600 then --占星术士(炽焰之星)
		--配置施法动作(配置施法特效,和攻击目标特效)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000,eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectBlazingstar", 0.2, {nSkillID, eSkillExt}});
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
	
	elseif nSkillID == 10610 then --占星术士(蓄力攻击)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "EffectPactrometerattack001", 0, {106101,eSkillExt}}, nil}, nil};
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectPactrometerattack002", 0.2, {106102,eSkillExt}});
		if bSkiilHit then
			table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectPactrometerattackblow", 0.2});
		end
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
	
	elseif nSkillID == 10620 then --占星术士(火焰护盾)
		
		--配置施法动作(配置施法特效,和攻击目标特效)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "EffectFireshield", 0, {nSkillID, eSkillExt}}, nil}, nil};
		return tSkillInfo;
		
	elseif nSkillID == 10630 then --占星术士(不息之炎)
		local tSkillInfo = t:NormalAttackSkillInfo(nRoleType, bSkiilHit, nil);
		return tSkillInfo;
	elseif nSkillID == 10640 then --占星术士(烈焰风暴)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000,eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.LAYER_TYPE, "EffectFlamestrike001", 0.2, {nSkillID, eSkillExt}});
		if bSkiilHit then
			table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.LAYER_TYPE, "EffectFlamestrike002", 0.2});
		end
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
	
	elseif nSkillID == 10660 then --咒缚者(圣言术)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000,eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
		local tListInfo2  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectThewordMantra001", 0.4, {nSkillID, eSkillExt}};
		table.insert(tSkillInfo[1], tListInfo2);
	
		return tSkillInfo;
	elseif nSkillID == 10670 then --咒缚者(火焰咒)
	
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000,eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.LAYER_TYPE, "EffectFirespell001", 0.2, {nSkillID, eSkillExt}});
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		
		return tSkillInfo;
	
	elseif nSkillID == 10680 then --咒缚者(力场护盾)
	
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {nSkillID, eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
		local tListInfo2  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectForceshield001", 0.4};
		table.insert(tSkillInfo[1], tListInfo2);
	
		return tSkillInfo;
	
	elseif nSkillID == 10690 then --咒缚者(咒术链接)
		--
		cclog("---未配置咒缚者(咒术链接)---");
	elseif nSkillID == 10700 then --咒缚者(咒缚人偶)
	
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000,eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectCursedoll001", 0.2, {nSkillID, eSkillExt}});
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
	
	elseif nSkillID == 10710 then --咒缚者(死神印记)
	
		--配置受击目标
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000,eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.LAYER_TYPE, "EffectMarkofdeath001", 0.2,{nSkillID, eSkillExt}});
		if bSkiilHit then
			table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.LAYER_TYPE, "EffectMarkofdeath002", 0.2});
		end
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		
		return tSkillInfo;	
	
	elseif nSkillID == 10720 then --主教(洗礼)
		--Error
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000,eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2,{nSkillID, eSkillExt}};
		table.insert(tSkillInfo[1], tListInfo1);
		return tSkillInfo;
		
	elseif nSkillID == 10730 then --主教(消退)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000,eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectdispel", 0.2,{nSkillID, eSkillExt}});
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
		
	elseif nSkillID == 10740 then --主教(无罪之手)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000,eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectTheinnocenthands", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "EffectTheinnocenthands", 0.2,{nSkillID, eSkillExt}});
		if bSkiilHit then
			table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectbishopblow", 0.2});
		end
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
		
	elseif nSkillID == 10760 then --主教(复活)
		cclog("***主教(复活)技能未配置---");
	elseif nSkillID == 10770 then --主教(圣言)

		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectreleaseskill", 0, {10000,eSkillExt}}, nil}, nil};
		local tListInfo1  = {SceneSkillType.PARTICLE_TYPE, SceneSkillEnum.SPRITE_TYPE, "effects/Effectreleaseskilllight.plist", 0.2};
		table.insert(tSkillInfo[1], tListInfo1);
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.LAYER_TYPE, "Effectoracle", 0.2,{nSkillID, eSkillExt}});
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		
		return tSkillInfo;
		
	elseif nSkillID == 10540 then --圣骑士(虔诚光环)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectpaladinreleaseskill", 0, {105401, eSkillExt}}, nil}, nil};
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectpaladinblow001", 0.2, {105402,eSkillExt}});
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
		
	elseif nSkillID == 10550 then --圣骑士(专注光环)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectpaladinreleaseskill", 0, {105501,eSkillExt}}, nil}, nil};
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectpaladinblow002", 0.2, {105502,eSkillExt}});
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
		
	elseif nSkillID == 10570 then --圣骑士(荆棘光环)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectpaladinreleaseskill", 0, {105701,eSkillExt}}, nil}, nil};
		
		local tBeAttackInfo = {};
		local tInfo = {};
		table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectpaladinblow003", 0.2, {105702,eSkillExt}});
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
	elseif nSkillID == 10580 then --圣骑士(帜热光辉)
		local eShowType  = SceneSkillType.ARMTURE_TYPE;
		local eAddType   = SceneSkillEnum.SPRITE_TYPE;
		local tSkillInfo = {{{eShowType, eAddType, "Effectpaladinreleaseheal", 0, {105801,eSkillExt}}, nil}, nil};
		
		local noHaveTree = true;
		local tBeAttackInfo = {};
		local tInfo = {};
		local bAddMusic = false;
		if SpriteSkillBufferPool:IsHaveBuff(nAttackTag, 20065) then
			table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectpaladinglowingradiance001", 0.2, {105802,eSkillExt}});
			noHaveTree = false;
			bAddMusic = true;
		end
		if SpriteSkillBufferPool:IsHaveBuff(nAttackTag, 20067) then
			if not bAddMusic then
				table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectpaladinglowingradiance002", 0.2, {105802,eSkillExt}});
			else
				table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectpaladinglowingradiance002", 0.2});
			end
			noHaveTree = false;
			bAddMusic = true;
		end
		if SpriteSkillBufferPool:IsHaveBuff(nAttackTag, 20069) then
			if bAddMusic then
				table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectpaladinglowingradiance003", 0.2,{105802,eSkillExt}});
			else
				table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectpaladinglowingradiance003", 0.2});
			end
			noHaveTree = false;
		end
		if noHaveTree then
			table.insert(tInfo, {SceneSkillType.ARMTURE_TYPE, SceneSkillEnum.SPRITE_TYPE, "Effectpaladinglowingradiance001", 0.2, {105802,eSkillExt}});
		end
		table.insert(tBeAttackInfo, tInfo);
		table.insert(tSkillInfo, tBeAttackInfo);
		return tSkillInfo;
	else
		cclog("***技能的表现未配置,请在SceneSkillEffectPool中配置 SkillID="..nSkillID.."---");
	end
	return nil;
end


function t:NormalAttackSkillInfo(nRoleType, bSkiilHit, tReMusic, tBeMusic)
	-- [[没有武器]]	    0,
	-- [[右手双面斧头]] 1,-- [[右手当面斧头]] 2,-- [[右手长戟]] 3,-- [[右手短剑]] 4,
	-- [[左手弓箭]] 5,-- [[左手法杖]] 6,
	local eShowType 	= SceneSkillType.ARMTURE_TYPE;
	local eAddType  	= SceneSkillEnum.SPRITE_TYPE;
	if nRoleType == 1 then		
		local sHitArmture	= "Effecthwblow";
		if not bSkiilHit then
			sHitArmture = nil;
		end
		return {{{eShowType, eAddType, "Effecthwattack", 0, tReMusic}, nil},{{{eShowType, eAddType, sHitArmture, 0.2, tBeMusic}}, nil}};
	elseif nRoleType == 2 then
		local sHitArmture	= "Effectmwblow";
		if not bSkiilHit then
			sHitArmture = nil;
		end
		return {{{eShowType, eAddType, "Effectmwattack", 0, tReMusic}, nil},{{{eShowType, eAddType, sHitArmture, 0.2, tBeMusic}}, nil}};
	elseif nRoleType == 3 or  nRoleType == 0 then
		local sHitArmture	= "Effectlhwblow";
		if not bSkiilHit then
			sHitArmture = nil;
		end
		return {{{eShowType, eAddType, "Effectlhwattack", 0, tReMusic}, nil},{{{eShowType, eAddType, sHitArmture, 0.2, tBeMusic}}, nil}};
	elseif nRoleType == 4 then
		local sHitArmture	= "Effectlwblow";
		if not bSkiilHit then
			sHitArmture = nil;
		end
		return {{{eShowType, eAddType, "Effectlwattack", 0, tReMusic}, nil},{{{eShowType, eAddType, sHitArmture, 0.2, tBeMusic}}, nil}};
	elseif nRoleType == 5 then
		local sHitArmture	= "Effectbowblow";
		if not bSkiilHit then
			-- sHitArmture = nil;
		end
		return {{{eShowType, eAddType, "Effectbowattack", 0, tReMusic}, nil},{{{eShowType, eAddType, sHitArmture, 0.2, tBeMusic}}, nil}};
	elseif nRoleType == 6 then
		local sHitArmture	= "Effectstaffblow";
		if not bSkiilHit then
			-- sHitArmture = nil;
		end
		return {{{eShowType, eAddType, "Effectstaffattack", 0, tReMusic}, nil},{{{eShowType, eAddType, sHitArmture, 0.2, tBeMusic}}, nil}};
	else
		cclog("***释放技能ID=10010, 超出界限nRoleType="..nRoleType.."---");
	end
end

--技能是否播放受击动作
function t:IsPlayStrikeAction(nSkillID)
	
	local tSkillInfo = CfgData["cfg_skill"][nSkillID];
	if tSkillInfo ~= nil then
		if tSkillInfo["show_hit"] == 0 then
			return false;
		end
	end
	return true;
end

--技能施法
--[[
SkillExtEnum = {
	SKILL_RELSEAS_1 = 1,	--技能施法1()
	SKILL_RELSEAS_2 = 2,	--技能施法2
	SKILL_RELSEAS_3 = 3,	--技能施法3
}
local EnumDamage =
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
}
--]]

--技能的扩展参数
--同个技能不同施法的接口
function t:SkillExternEnum(nSkillID, nAttackType)
	if nSkillID == 11000 then --魔战士(乱数)
		return t:GetExtEnum(nAttackType)
	end
	return nil;
end

function t:GetExtEnum(nAttackType)
	if nAttackType == EnumDamage.NORMAL then --普通命中
		return SkillExtEnum.SKILL_RELSEAS_1;
	elseif nAttackType == EnumDamage.CIRTICAL then--暴击
		return SkillExtEnum.SKILL_RELSEAS_1;
	elseif nAttackType == EnumDamage.DODGE then--闪避
		return SkillExtEnum.SKILL_RELSEAS_1;
	elseif nAttackType == EnumDamage.PARRY then--格挡
		return SkillExtEnum.SKILL_RELSEAS_1;
	elseif nAttackType == EnumDamage.CURE then--治疗
		return SkillExtEnum.SKILL_RELSEAS_2;
	elseif nAttackType == EnumDamage.SUCK then--吸血
		return SkillExtEnum.SKILL_RELSEAS_1;
	elseif nAttackType == EnumDamage.REBOUND then--反弹
		return SkillExtEnum.SKILL_RELSEAS_1;
	elseif nAttackType == EnumDamage.BATBACK then--反击
		return SkillExtEnum.SKILL_RELSEAS_1;
	elseif nAttackType == EnumDamage.BUFF then--状态
		return SkillExtEnum.SKILL_RELSEAS_1;
	elseif nAttackType == EnumDamage.REVIVE then--复活
		return SkillExtEnum.SKILL_RELSEAS_1;
	elseif nAttackType == EnumDamage.SELF then--自伤
		return SkillExtEnum.SKILL_RELSEAS_1;
	elseif nAttackType == EnumDamage.VERTIGO then--眩晕
		return SkillExtEnum.SKILL_RELSEAS_1;
	elseif nAttackType == EnumDamage.BUFFERMOVE then--消除Buff
		return SkillExtEnum.SKILL_RELSEAS_1;
	elseif nAttackType == EnumDamage.NONE then--什么都没有
		return SkillExtEnum.SKILL_RELSEAS_3;
	else
		cclog("***技能施法获取其他类型出错(SceneSkillEffectPool)---");
	end
	return nil;
end

return t;