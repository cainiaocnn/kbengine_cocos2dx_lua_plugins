--技能释放前的角色动作

SkillDoReleaseBefore = {};
local t = SkillDoReleaseBefore;

-- 数据
local tSkillStorageEffectQueue = {};

--账号注销回调函数
function t.gameLoginOut()
	tSkillStorageEffectQueue = {};
end

BeforeSkillType = {
	ARMTURE_TYPE = 1, --骨骼动画表现
	PARTICLE_TYPE= 2, --粒子特效表现
}

--[[
SceneSkillEnum = {
	LAYER_TYPE = 1,		--显示在层
	SPRITE_TYPE = 2,	--显示在英雄
};
--]]

-- 压入一个特效数据
function t:PushInStorageToQueue(tStorageEffect)
	table.insert(tSkillStorageEffectQueue, tStorageEffect);
end

-- 推出一个特效数据
function t:PushOutStorageFromQueue()
	if #tSkillStorageEffectQueue > 0 then
		local tStorageEffect = tSkillStorageEffectQueue[1];
		table.remove(tSkillStorageEffectQueue, 1);
		return tStorageEffect;
	end
	return nil;
end

-- 技能蓄力特效解析
function t:ShowStorageEffect(tStorageEffect)
	if tStorageEffect ~= nil then
		--这个数据由 SpriteActionPool发送来的
		local nSpriteTag		= tStorageEffect[1];--攻击精灵
		local tBeSpiteTags		= tStorageEffect[2];--被击精灵表
		local tParam			= tStorageEffect[3];--技能参数 1.表示类型, 2表示特效
		--
		t:ShowStorageSkill(nSpriteTag, tBeSpiteTags, tParam);
	end
end

--解析蓄力动作
function t:ShowStorageSkill(nSpriteTag, tBeSpiteTags, tParam)
	if tParam ~= nil then
		local nShowType 	= tParam[1];
		local sShowName 	= tParam[2];
		local fDelyTime 	= tParam[3];
		local fDeleteTime	= tParam[4];
		local nZorder		= tParam[5];
		local tMusicInfo    = tParam[6];
		
		if nShowType == BeforeSkillType.ARMTURE_TYPE then
			t:ShowBeforeArmatureSprite(nSpriteTag, sShowName, fDelyTime, fDeleteTime, nZorder, tMusicInfo);
		elseif nShowType == BeforeSkillType.PARTICLE_TYPE then
			t:ShowBeforeParticleSprite(nSpriteTag, sShowName, fDelyTime, fDeleteTime, nZorder, tMusicInfo);
		else
			cclog("********客户端蓄力特效数据构造错误**********");
		end
	end
end


--显示一个特效(添加到精灵中的)
function t:ShowBeforeParticleSprite(nSpriteTag, sShowName, fDelyTime, fDeleteTime, nZorder, tMusicInfo)
	local tShowArmature = SpriteArmaturePool:GetArmature(nSpriteTag);
	if tShowArmature ~= nil then
		local function func()
			--创建粒子
			local pParticle = CCParticleSystemQuad:create(sShowName);
			--加入显示纹理
			local pShowBatch = CCParticleBatchNode:createWithTexture(pParticle:getTexture());
			if tShowArmature.bFlipX then
				pShowBatch:setScaleX(-1);				
			end
			pShowBatch:addChild(pParticle);
			--播放完毕删除
			local function listener()
				if SpriteArmaturePool:GetArmature(nSpriteTag) ~= nil then
					if pShowBatch ~= nil then
						pShowBatch:removeFromParentAndCleanup(true);
					else
						cclog("***删除蓄力特效失败,由于创建时候失败nil---");
					end
				else
					cclog("---Sprite is dead so it not be delete---");
				end
			end
			Scheduler.performWithDelayGlobal(listener, fDeleteTime);
			--暂时处理
			-- tShowArmature.Sprite:addChild(pShowBatch, 100);
			tShowArmature.Sprite:addChild(pShowBatch, nZorder);
			
			--Music
			GameFightMusic.PlaySkillEffectMusic(tMusicInfo);
		end
		--延时播放
		if fDelyTime > 0 then
			Scheduler.performWithDelayGlobal(func, fDelyTime);
		else
			func();
		end
	else
		cclog("***---");
	end	
end


--显示一个骨骼(添加到精灵中)
function t:ShowBeforeArmatureSprite(nSpriteTag, sShowName, fDelyTime, fDeleteTime, nZorder, tMusicInfo)
	local tShowArmature = SpriteArmaturePool:GetArmature(nSpriteTag);
	if tShowArmature ~= nil then
		local function func()
			if sShowName ~= nil then
				local tArmatureEffect = CreateArmatureEffect();
				local pEffect = tArmatureEffect:CreateEffectSprite(sShowName, 0, true);
				if pEffect ~= nil then
					local nTag = tShowArmature:AddArmatureEffect(tArmatureEffect);
					tArmatureEffect:SetAutoInfo(tShowArmature.RemoveArmatureEffect, nTag);
					if tShowArmature.bFlipX then
						tArmatureEffect:SetFlip(true, false);
					end
					--Music
					GameFightMusic.PlaySkillEffectMusic(tMusicInfo);
				else
					cclog("***显示一个蓄力骨骼动画失败,由于创建失败---");
				end
			end
		end
		if fDelyTime > 0 then
			Scheduler.performWithDelayGlobal(func, fDelyTime);
		else
			func();
		end
	else
		cclog("***---");
	end
end



--获取蓄力技能配置
function t:GetStorageSkillBefore(nSkillId, nAttackSprite, tBeAttackSprite)
	if nSkillId == 10790 then --审判(审判之怒)
		local sShowName   = "EffectTrialByFury";
		local fDelTime    = 0.0; --延时播放
		local fDeleteTime = 0.0; --播放多久后删除删除时间 粒子特效有删除时间,骨骼动画没有删除时间自动删除的
		local nZorder     = 100; --显示层次
		return {nAttackSprite, tBeAttackSprite, {BeforeSkillType.ARMTURE_TYPE, sShowName, fDelTime, fDeleteTime, nZorder, {10790, nil}}};
	elseif nSkillId == 10630 then --占星术士(不息之炎)
		local sShowName   = "EffectEndlessinflammation";
		local fDelTime    = 0.0; --延时播放
		local fDeleteTime = 0.0; --播放多久后删除删除时间 粒子特效有删除时间,骨骼动画没有删除时间自动删除的
		local nZorder     = 100; --显示层次
		return {nAttackSprite, tBeAttackSprite, {BeforeSkillType.ARMTURE_TYPE, sShowName, fDelTime, fDeleteTime, nZorder, {10630,nil}}};
	end
	return nil;
end

return t;