--创建精灵的总类
--可以直接用骨骼的变量名称直接使用
local tt={
	__index = function(t,k)
		local pBone = tolua.cast(t.Sprite:getBone(k),"CCBone");
		rawset(t,k,pBone);
		return pBone;
    end
}
-------------------------------------
function CreateArmatureSprite()
	local t = {};
	setmetatable(t, tt);
	--变量
	----------------------------------------
	t.SpriteName = nil;
	t.Sprite = nil;					--骨骼动画对象
	t.SpriteTag = nil;				--骨骼动画下标(方便查找)
	t.ArmatureEffectTag = 100;		--骨骼表现的开始节点
	t.MovementFunc = {};			--骨骼动画播放结束事件
	t.FramesFunc = {};				--骨骼动画关键帧事件
	t.ParticleContainer = {};		--特效容器
	t.fsm = CreateStateMachine();	--状态机
	t.ProgressTimer 	= nil;			--怪物的蓝色血条
	t.ProgressTimerRed 	= nil;			--怪物的红色血条

	t.tBoneKeys = {};				--骨骼精灵外套类型表
	t.tWeapons	= {};				--骨骼精灵武器类型表
	-- t.tSkillType= {};
	t.RoleType  = nil;				--职业类型


	t.bFlipX = false;				--X翻转
	t.bFlipY = false;				--Y翻转

	t.Height = 150;					--高度
	t.Width  = 100;					--宽度

	t.ScaleX = 1.0;					--x缩放
	t.ScaleY = 1.0;					--y缩放

	--战斗数据
	t.IsEnemy = false;				--战队标示
	t.ArmatrureHP = 0;				--角色血量

	--函数
	----------------------------------------
	-- 创建战斗精灵
	-- spriteName	骨骼动画精灵名称
	-- spriteWearing 套装下标(0是默认装备从1开始)
	function t:CreateSprite(spriteName, spriteWearing)
		-- 加载资源
		local spriteExportJson = "hero/"..spriteName.."/"..spriteName..".ExportJson";
		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(spriteExportJson);
		-- 创建骨骼动画
		t.Sprite = CCArmature:create(spriteName);
		if t.Sprite == nil then
			cclog("**Create ArmatureSprite Faild---");
			return nil;
		end
		
		t.SpriteName = spriteName;
		if spriteWearing > 0 then
			t:ChangeWearing(spriteName, spriteWearing);
		else
			t:ChangeParticle(spriteName);
		end
		-- 注册事件
		local function animationEvent(armatureBack,movementType,movementID)
			t:animationEvent(armatureBack,movementType,movementID)
		end
		t.Sprite:getAnimation():setMovementEventCallFunc(animationEvent);
		local function onFrameEvent( bone,evt,originFrameIndex,currentFrameIndex)
			t:frameEvent( bone,evt,originFrameIndex,currentFrameIndex)
		end
		t.Sprite:getAnimation():setFrameEventCallFunc(onFrameEvent);
		return t.Sprite;
	end

	-- 修改套装
	-- spriteName	骨骼动画精灵名称
	-- spriteWearing 套装下标(0是默认装备从1开始)
	function t:ChangeWearing(spriteName, spriteWearing)
		local pSpriteFrameCache = CCSpriteFrameCache:sharedSpriteFrameCache();
		if pSpriteFrameCache ~= nil then
			local spritePlist = "hero/"..spriteName.."/"..spriteName..spriteWearing..".plist";
			local spritePng   = "hero/"..spriteName.."/"..spriteName..spriteWearing..".png";
			pSpriteFrameCache:addSpriteFramesWithFile(spritePlist, spritePng);

			for k,v in pairs(t.tBoneKeys) do
				local pBone = t[k];
				if pBone == nil then
					cclog("***error:------------------"..k);
					break;
				end

				local disPlayNode = nil;
				if v[2] == "png" then
					local sSkinPng = v[1]..".png";
					if spriteWearing ~= 0 then
						sSkinPng = v[1].."_"..spriteWearing..".png";
					end
					
					disPlayNode = CCSkin:createWithSpriteFrameName(sSkinPng);
					if disPlayNode ~= nil then
						local pCArmturalHelp = CArmturalHelp:sharedCArmturalHelp();
						if(pCArmturalHelp) then
							if disPlayNode == nil then
								cclog(sSkinPng);
							end
							local pos = pCArmturalHelp:getArmturaSpriteAnchorPoint(v[1]);
							disPlayNode:ignoreAnchorPointForPosition(false);
							disPlayNode:setAnchorPoint(pos);
							
						else
							cclog("***error ChangeWearing faild dure to:CArmturalHelp:sharedCArmturalHelp is nil---");
						end
					else
						cclog("****ChangeWearing Faile Not Found：%s*****", sSkinPng);
					end
				else
					local sParticle = v[1].."_"..spriteWearing..".plist";
					local sFullName = "hero/"..spriteName.."/"..sParticle;
					disPlayNode = CCParticleSystemQuad:create(sFullName);
					if disPlayNode ~= nil then
						disPlayNode:setPositionType(kCCPositionTypeRelative);
					else
						cclog("***Armatrure Create Particle Node Error***");
					end
				end

				pBone:addDisplay(disPlayNode,0);
				pBone:changeDisplayWithIndex(0,false);
			end
		else
			cclog("*******Get SpriteFrameCache Faild");
		end
	end

	
	-- 骨骼动画中粒子节点遍历
	function t:ChangeParticle(spriteName)
		for k,v in pairs(t.tBoneKeys) do
			local pBone = t[k];
			if pBone == nil then
				cclog("***error:------------------"..k);
				break;
			end
			if v[2] == "plist" then
				local pNode = pBone:getDisplayRenderNode();
				if pNode ~= nil then
					local pParti = tolua.cast(pNode, "CCParticleSystemQuad");
					if pParti ~= nil then
						pParti:setPositionType(kCCPositionTypeRelative);
					end
				end
			end
		end
	end
	
	-- 设置武器模式
	-- eWeapon 武器类型
	function t:WeaponModule(eWeapon, nSkinIndex)
		local strVisable = nil;
		for k,v in ipairs(t.tWeapons) do
			if v ~= nil then
				if k == eWeapon then
					strVisable = v[1];
					t:HideBone(v[1], true);
					t:ChangeWeaponSkin(v[1], v[2], eWeapon, nSkinIndex);
				else
					if v[1] ~= strVisable then
						t:HideBone(v[1], false);
					end
				end
			end
		end
		t.RoleType = eWeapon;
	end

	-- 更新武器外形
	function t:ChangeWeaponSkin(kBonde , sAnchorPoint, eWeapon, nSkinIndex)
		if nSkinIndex ~= nil and nSkinIndex ~=0 then

			local sSkinPng = "";
			if eWeapon == 1 then	 --[[右手双面斧头]]
				sSkinPng = "weapons/Axe/Axe"..nSkinIndex..".png"
			elseif eWeapon == 2 then --[[右手当面斧头]]
				sSkinPng = "weapons/MAweapon/MAweapon000"..nSkinIndex..".png"
			elseif eWeapon == 3  then --[[右手长戟,没有武器]]
				sSkinPng = "weapons/Spear/Spear"..nSkinIndex..".png"
			elseif eWeapon == 4 then --[[右手短剑]]
				sSkinPng = "weapons/Lweapon/Lweapon"..nSkinIndex..".png"
			elseif eWeapon == 5 then --[[左手弓箭]]
				sSkinPng = "weapons/Bow/Bow"..nSkinIndex..".png"
			elseif eWeapon == 6 then --[[左手法杖]]
				sSkinPng = "weapons/Staff/Staff000"..nSkinIndex..".png"
			end
			if sSkinPng ~= "" then
				local pBone = t[kBonde];
				if pBone ~= nil then
					local skin = CCSkin:create(sSkinPng);
					if skin ~= nil then
						local pCArmturalHelp = CArmturalHelp:sharedCArmturalHelp();
						if pCArmturalHelp~=nil then
							local pos = pCArmturalHelp:getArmturaSpriteAnchorPoint(sAnchorPoint);
							skin:ignoreAnchorPointForPosition(false);
							skin:setAnchorPoint(pos);
						else
							cclog("error ChangeWearing faild dure to:CArmturalHelp:sharedCArmturalHelp is nil");
						end
						pBone:addDisplay(skin,0);
						pBone:changeDisplayWithIndex(0,true);
					else
						cclog("武器换装失败");
						cclog("***武器资源不存在: %s***", tostring(sSkinPng));
					end
				end
			end
		end
	end

	--隐藏部件
	-- boneName, 骨骼名称
	-- bVisible, 是否显示
	function t:HideBone(boneName, bVisible)
		if boneName ~= nil then
			local pBone = t[boneName];
			if pBone ~= nil then
				pBone:getDisplayRenderNode():setVisible(bVisible);
			else
				cclog("***ArmatureSprite is not have Bone:"..boneName.."---");
			end
		end
	end

	-- 执行攻击
	function t:DoNormalAttack()

		if t.RoleType == 1 then		--[[右手双面斧头]]
			t:PlayAnimationByName("hweaponattack");
		elseif t.RoleType == 2 then --[[右手当面斧头]]
			t:PlayAnimationByName("mweaponattack");
		elseif t.RoleType == 3 or t.RoleType == 0 then --[[右手长戟,没有武器]]
			t:PlayAnimationByName("lhweaponattack");
		elseif t.RoleType == 4 then --[[右手短剑]]
			t:PlayAnimationByName("lweaponattack");
		elseif t.RoleType == 5 then --[[左手弓箭]]
			t:PlayAnimationByName("bowattack");
		elseif t.RoleType == 6 then --[[左手法杖]]
			t:PlayAnimationByName("staffattack");
		end
	end

	--显示战斗血条 1
	function t:CreateProgressTimer(szfileName, szfileNameBk, szfileNameBkImg)
		if t.ProgressTimer == nil and t.Sprite ~= nil then
			t.ProgressTimer = CCProgressTimer:create(CCSprite:create(szfileName));
			t.ProgressTimer:setType(kCCProgressTimerTypeBar);
			t.ProgressTimer:setMidpoint(ccp(0, 0));
			t.ProgressTimer:setBarChangeRate(ccp(1, 0));
			t.ProgressTimer:setPosition(ccp(0, t.Height*1.2));
			t.ProgressTimer:setPercentage(100);

			--红色血条
			t.ProgressTimerRed = CCProgressTimer:create(CCSprite:create(szfileNameBk));
			t.ProgressTimerRed:setAnchorPoint(ccp(0,0));
			t.ProgressTimerRed:setType(kCCProgressTimerTypeBar);
			t.ProgressTimerRed:setMidpoint(ccp(0, 0));
			t.ProgressTimerRed:setBarChangeRate(ccp(1, 0));
			t.ProgressTimerRed:setPercentage(100);
			t.ProgressTimer:addChild(t.ProgressTimerRed,-1);

			local sprite = CCSprite:create(szfileNameBkImg);
			sprite:setAnchorPoint(ccp(0,0));
			sprite:setPosition(ccp(1.5, -2));
			t.ProgressTimer:addChild(sprite,-2);

			t.Sprite:addChild(t.ProgressTimer);
		end
	end

	--显示战斗血条 2
	function t:CreateProgressTimer2(szfileName, szfileNameBk, szfileNameBkImg, strName, strLevel)
		if t.ProgressTimer == nil and t.Sprite ~= nil then

			--蓝色血条
			t.ProgressTimer = CCProgressTimer:create(CCSprite:create(szfileName));
			t.ProgressTimer:setType(kCCProgressTimerTypeBar);
			t.ProgressTimer:setMidpoint(ccp(0, 0));
			t.ProgressTimer:setBarChangeRate(ccp(1, 0));
			t.ProgressTimer:setPosition(ccp(20, t.Height*1.21));
			t.ProgressTimer:setPercentage(100);
			--红色血条
			t.ProgressTimerRed = CCProgressTimer:create(CCSprite:create(szfileNameBk));
			t.ProgressTimerRed:setAnchorPoint(ccp(0,0));
			t.ProgressTimerRed:setType(kCCProgressTimerTypeBar);
			t.ProgressTimerRed:setMidpoint(ccp(0, 0));
			t.ProgressTimerRed:setBarChangeRate(ccp(1, 0));
			t.ProgressTimerRed:setPercentage(100);
			t.ProgressTimer:addChild(t.ProgressTimerRed,-1);

			--bgImage
			local sprite = CCSprite:create(szfileNameBkImg);
			sprite:setAnchorPoint(ccp(0,0));
			sprite:setPosition(ccp(-46, -10));
			t.ProgressTimer:addChild(sprite,-2);

			--Lev Image
			local sprite = CCSprite:create("image/level.png");
			sprite:setAnchorPoint(ccp(0,0));
			sprite:setPosition(ccp(-35, 15));
			if t.bFlipX then
				sprite:setFlipX(true);
			end
			t.ProgressTimer:addChild(sprite,0);

			-- Name
			local pLable = CCLabelTTF:create(strName, "Marker Felt", 18)
			if t.bFlipX then
				pLable:setFlipX(true);
			end
			pLable:setPosition(ccp(45, 20));
			t.ProgressTimer:addChild(pLable,0);

			-- Lev
			local pLable = CCLabelTTF:create(tostring(strLevel), "Marker Felt", 14)
			if t.bFlipX then
				pLable:setFlipX(true);
			end
			pLable:setPosition(ccp(-22, 8));
			t.ProgressTimer:addChild(pLable,0);
			t.Sprite:addChild(t.ProgressTimer, -1);

		end
	end

	--显示战斗血条 3
	function t:CreateProgressTimer3(szfileName, szfileNameBk, szfileNameBkImg, szfileCirl, strName, strLevel)
		if t.ProgressTimer == nil and t.Sprite ~= nil then

			--蓝色血条
			t.ProgressTimer = CCProgressTimer:create(CCSprite:create(szfileName));
			t.ProgressTimer:setType(kCCProgressTimerTypeBar);
			t.ProgressTimer:setMidpoint(ccp(0, 0));
			t.ProgressTimer:setBarChangeRate(ccp(1, 0));
			t.ProgressTimer:setPosition(ccp(20, t.Height*1.21));
			t.ProgressTimer:setPercentage(100);
			--红色血条
			t.ProgressTimerRed = CCProgressTimer:create(CCSprite:create(szfileNameBk));
			t.ProgressTimerRed:setAnchorPoint(ccp(0,0));
			t.ProgressTimerRed:setType(kCCProgressTimerTypeBar);
			t.ProgressTimerRed:setMidpoint(ccp(0, 0));
			t.ProgressTimerRed:setBarChangeRate(ccp(1, 0));
			t.ProgressTimerRed:setPercentage(100);
			t.ProgressTimer:addChild(t.ProgressTimerRed,-1);

			--bgImage
			local sprite = CCSprite:create(szfileNameBkImg);
			sprite:setAnchorPoint(ccp(0,0));
			sprite:setPosition(ccp(1, -1.5));
			t.ProgressTimer:addChild(sprite,-2);

			--Lev Image
			local sprite = CCSprite:create(szfileCirl);
			sprite:setAnchorPoint(ccp(0,0));
			sprite:setPosition(ccp(-46, -19));
			if t.bFlipX then
				sprite:setFlipX(true);
			end
			t.ProgressTimer:addChild(sprite,-1);

			-- Name
			local pLable = CCLabelTTF:create(strName, "Marker Felt", 20);
			pLable:setColor(ccc3(255, 255, 255));
			--描边
			--pLable:enableStroke(ccc3(0,0,0),3,true);
			if t.bFlipX then
				pLable:setFlipX(true);
			end
			pLable:setPosition(ccp(45, 25));
			t.ProgressTimer:addChild(pLable,0);

			-- Lev
			local pLable = CCLabelTTF:create(tostring(strLevel), "Marker Felt", 20);
			if t.bFlipX then
				pLable:setFlipX(true);
			end
			pLable:setPosition(ccp(-22, 0));
			t.ProgressTimer:addChild(pLable,0);
			t.Sprite:addChild(t.ProgressTimer, 100);

		end
	end


	--给骨骼添加一个粒子特效
	-- particleName,  	粒子特效名称
	-- parentBoneName, 	父骨骼节点
	-- pParticle, 		粒子特效容器
	-- bFallowMoveMent	特效是否跟随骨骼运行(默认要传true)
	function t:AddParticle(particleName,  parentBoneName, pParticle, bFallowMoveMent)
		
		--
		particleName = "effect_"..particleName;
		--先删除原有的
		t:RemoveParticle(particleName, bRecursion);
		
		local particleBone = CCBone:create(particleName);
		if particleBone ~= nil then
			local pParentBone = t[parentBoneName];
			if pParentBone ~= nil then
				local zOrder = pParentBone:getZOrder();
				particleBone:addDisplay(pParticle, 0);
				particleBone:changeDisplayWithIndex(0, true);
				particleBone:setIgnoreMovementBoneData(true);
				particleBone:setZOrder(zOrder);
				if bFallowMoveMent then
					pParentBone:addChildBone(particleBone);
				else
					--*********可能有问题
					particleBone:setParentBone(pParentBone);
				end

				t.Sprite:addBone(particleBone, particleName);
				-------
				local tbParticle = {
					["parent"] = parentBoneName;
					["move"] = bFallowMoveMent;
				};
				t.ParticleContainer[particleName] = tbParticle;
			end
		end
	end

	--删除骨骼上的粒子特效
	-- particleName, 特效名称
	-- bRecursion	是否遍历字骨骼删除
	function t:RemoveParticle(particleName, bRecursion)
		if t.Sprite ~= nil then
			particleName = "effect_"..particleName;
			local tbParticle = t.ParticleContainer[particleName];
			if tbParticle ~= nil and tbParticle ~= {} then
				local pBone = t[particleName];
				if pBone ~= nil then
					if tbParticle["move"] then
						local pParentBone = t[tbParticle["parent"]];
						if pParentBone ~= nil then
							pBone:removeDisplay(0);
							pParentBone:removeChildBone(pBone,bRecursion);
							t.Sprite:removeBone(pBone, bRecursion);
							t[particleName] = nil;
							if t[particleName] ~= nil then
								cclog("delete faild *****");
							end
						end
					else
						pBone:setParentBone(nil);
						pBone:removeDisplay(0);
						t.Sprite:removeBone(pBone, bRecursion);
						t[particleName] = nil;
						if t[particleName] ~= nil then
							cclog("***delete faild---");
						end
					end
				end
				t.ParticleContainer[particleName] = nil;
			end
		else
			cclog("***ArmatureSprite is not create---");
		end
	end

	
	--给武器添加特效
	function t:AddWeaponEffect(nWeapons, effectSpriteName, strBoneName)
		local tWeaponBone = t.tWeapons[nWeapons];
		if tWeaponBone ~= nil then
			-- local effectSpriteName = "EffectstoneStarburstlv004";
			local spriteExportJson = "weaeffects/"..effectSpriteName.."/"..effectSpriteName..".ExportJson";
			CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(spriteExportJson);
			-- 创建骨骼动画
			local tEffSprite = CCArmature:create(effectSpriteName);
			if tEffSprite == nil then
				cclog("***Create ArmatureSprite Faild---");
				return nil;
			end
			tEffSprite:getAnimation():playWithIndex(0, -1, -1, 1);

			t:AddParticle(strBoneName,  tWeaponBone[1], tEffSprite, true);
		end
	end
	
	--添加一个骨骼精灵的表现
	function t:AddArmatureEffect(tArmatureEffect)
		t.Sprite:addChild(tArmatureEffect.Sprite, t.ArmatureEffectTag);
		t.ArmatureEffectTag = t.ArmatureEffectTag + 1;
		return t.ArmatureEffectTag;
	end

	--删除一个骨骼精灵的表现
	function t:RemoveArmatureEffect(nArmatureEffectTag)
		t.ArmatureEffectTag = t.ArmatureEffectTag - 1;
		-- cclog("remove --------%d",t.ArmatureEffectTag);
	end

	--播放动作
	-- animationIndex,(播放动画索引下标)
	-- animationName (播放动画名称)
	-- durationTo, (播放动画开始贞)
	-- durationTween, (播放动画结束贞)
	-- loop	(0=播放一次, >0=循环播放)
	function t:PlayAnimationByIndex(animationIndex, durationTo, durationTween, loop)
		if durationTo == nil then
			durationTo = -1;
		end
		if durationTween == nil then
			durationTween = -1;
		end
		if loop == nil then
			loop = -1;
		end
		if t.Sprite == nil then
			cclog("******PlayAnimationByIndex faild dure to: sprite not create");
			return;
		end
		t.Sprite:getAnimation():playWithIndex(animationIndex, durationTo, durationTween, loop);
	end
	function t:PlayAnimationByName(animationName, durationTo, durationTween, loop)
		if durationTo == nil then
			durationTo = -1;
		end
		if durationTween == nil then
			durationTween = -1;
		end
		if loop == nil then
			loop = -1;
		end
		if t.Sprite == nil then
			cclog("***PlayAnimationByIndex faild dure to: sprite not create---");
			return;
		end
		t.Sprite:getAnimation():play(animationName, durationTo, durationTween, loop);
	end


	--播放动画从第x贞开始
	-- nBeginFrame,播放开始贞
	function t:PlayAnimationFromFrame(nBeginFrame)
		if t.Sprite == nil then
			cclog("***PlayAnimationByIndex faild dure to: sprite not create---");
			return;
		end
		t.Sprite:getAnimation():gotoAndPlay(nBeginFrame);
	end

	--动画播放暂停在x贞
	-- nPauseFrame,暂停贞
	function t:PlayAnimationFromFrame(nPauseFrame)
		if t.Sprite == nil then
			cclog("***PlayAnimationByIndex faild dure to: sprite not create---");
			return;
		end
		t.Sprite:getAnimation():gotoAndPause(nPauseFrame);
	end


	-- 动画播放管理
	-- 动画暂停
	function t:AnimationPause()
		if t.Sprite == nil then
			cclog("***PlayAnimationByIndex faild dure to: sprite not create---");
			return;
		end
		t.Sprite:getAnimation():pause();
	end
	-- 动画恢复
    function t:AnimationResume()
		if t.Sprite == nil then
			cclog("***PlayAnimationByIndex faild dure to: sprite not create---");
			return;
		end
		t.Sprite:getAnimation():resume();
	end
	-- 动画停止
    function t:AnimationStop()
		if t.Sprite == nil then
			cclog("***PlayAnimationByIndex faild dure to: sprite not create---");
			return;
		end
		t.Sprite:getAnimation():stop();
	end
	-- 设置播放速度
	function t:SetSpeedScale(fScale)
		if t.Sprite == nil then
			cclog("***PlayAnimationByIndex faild dure to: sprite not create---");
			return;
		end
		t.Sprite:getAnimation():setSpeedScale(fScale);
	end

	-- 设置骨骼精灵面向
	-- bFlipX, X翻转
	-- bFlipY, Y翻转
	function t:SetFlip(bFlipX, bFlipY)
		if t.Sprite == nil then
			cclog("***PlayAnimationByIndex faild dure to: sprite not create---");
			return;
		end
		local xScale = math.abs(t.Sprite:getScaleX());
		if bFlipX or bFlipX==nil then
			xScale = -xScale;
			t.bFlipX = true;
		end
		t.Sprite:setScaleX(xScale);

		local yScale = math.abs(t.Sprite:getScaleY());
		if bFlipY or bFlipY==nil then
			yScale = -yScale;
			t.bFlipY = true;
		end
		t.Sprite:setScaleY(yScale);
	end

	-- 设置位置
	function t:SetPostion(pos)
		if t.Sprite == nil then
			cclog("***PlayAnimationByIndex faild dure to: sprite not create---");
			return;
		end
		t.Sprite:setPosition(pos);
	end

	-- 设置缩放
	-- fScaleX, fScaleY(都大于0)
	function t:SetScale(fScaleX, fScaleY)
		if t.Sprite == nil then
			cclog("***PlayAnimationByIndex faild dure to: sprite not create---");
			return;
		end

		t.ScaleX = fScaleX;	--x缩放
		t.ScaleY = fScaleY;	--y缩放

		if t.bFlipX then
			fScaleX = -fScaleX;
		end
		t.Sprite:setScaleX(fScaleX);
		if t.bFlipY then
			fScaleY = -fScaleY;
		end
		t.Sprite:setScaleY(fScaleY);

	end

	-- 设置宽高
	function t:SetSpriteSize(nWidth, nHeight)
		t.Width	= nWidth;
		t.Height= nHeight;
	end
	-- 获取宽高(已经包括缩放)
	function t:GetWidthAndHeight()
		return t.Width*t.ScaleX,t.Height*t.ScaleY;
	end

	-- 骨骼动画事件管理
	-- 动画播放事件回调注册(播放一个动画结束后会回调注册的函数)
	function t:RegiestMovementFunc(eventStr, evenFunc, isOnce, param1, param2)
		if t.Sprite == nil then
			cclog("***PlayAnimationByIndex faild dure to: sprite not create---");
			return;
		end

		t.MovementFunc[eventStr] = {};
		t.MovementFunc[eventStr].func   = evenFunc;
		t.MovementFunc[eventStr].isOnce = isOnce;
		t.MovementFunc[eventStr].param1 = param1;
		t.MovementFunc[eventStr].param2 = param2;
	end
	function t:UnRegiestMovementFunc(eventStr)
		if t.MovementFunc ~= nil then
			t.MovementFunc[eventStr] = nil;
		end
	end
	function t:animationEvent(armatureBack,movementType,movementID)
		-- cclog("animationEvent:%s",movementID);
		if movementType == 1 or  movementType == 2 then
			if t.MovementFunc ~= nil then
				if t.MovementFunc[movementID] ~= nil then
					t.MovementFunc[movementID]["func"](t.MovementFunc[movementID]["param1"],t.MovementFunc[movementID]["param2"]);
					if t.MovementFunc[movementID]["isOnce"] then
						t.MovementFunc[movementID] = nil;
					end
				end
			end
		end
	end

	--贞动画事件注册(在UI编辑器中使用填写'贞事件'后注册函数将会回调)
	function t:RegiestFramesFunc(eventStr, evenFunc, isOnce, param1, param2)
		if t.Sprite == nil then
			cclog("***PlayAnimationByIndex faild dure to: sprite not create---");
			return;
		end
		t.FramesFunc[eventStr] = {};
		t.FramesFunc[eventStr].func   = evenFunc;
		t.FramesFunc[eventStr].isOnce = isOnce;
		t.FramesFunc[eventStr].param1 = param1;
		t.FramesFunc[eventStr].param2 = param2;
	end
	function t:UnRegiestFramesFunc(eventStr)
		if t.FramesFunc ~= nil then
			t.FramesFunc[eventStr] = nil;
		end
	end
	function t:frameEvent(bone,evt,originFrameIndex,currentFrameIndex)
		-- cclog("frameEvent:%s",evt);
		if t.FramesFunc ~= nil then
			if t.FramesFunc[evt] ~= nil then
				t.FramesFunc[evt]["func"](t.FramesFunc[evt]["param1"],t.FramesFunc[evt]["param2"]);
				if t.FramesFunc[evt]["isOnce"] then
					t.FramesFunc[evt] = nil;
				end
			end
		end
	end

	return t;
end





