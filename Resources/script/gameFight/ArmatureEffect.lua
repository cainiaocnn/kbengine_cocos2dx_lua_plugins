--创建骨骼表现
-------------------------------------
function CreateArmatureEffect()
	local t = {};

	--变量
	----------------------------------------
	t.Sprite = nil;					--骨骼动画对象
	t.MovementFunc = {};			--骨骼动画播放结束事件
	t.FramesFunc = {};				--骨骼动画关键帧事件
	t.isAutoRelease = true;
	t.AutoReleaseCallFun = nil;
	t.AutoReleaseParam = nil;
	--函数
	----------------------------------------
	-- 特效精灵
	-- effectSpriteName	骨骼动画精灵名称
	function t:CreateEffectSprite(effectSpriteName, bLoop, isAutoRelease)
		-- 加载资源
		local spriteExportJson = "skill/"..effectSpriteName.."/"..effectSpriteName..".ExportJson";
		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(spriteExportJson);
		-- 创建骨骼动画
		t.Sprite = CCArmature:create(effectSpriteName);
		if t.Sprite == nil then
			cclog("***Create ArmatureSprite Faild---");
			return nil;
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
		t.isAutoRelease = isAutoRelease;
		
		t:PlayAnimationByIndex(0, nil, nil, bLoop);
		
		return t.Sprite;
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
			cclog("***PlayAnimationByIndex faild dure to: sprite not create---");
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
	
	--设置骨骼精灵面向
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
		end
		t.Sprite:setScaleX(xScale);
		
		local yScale = math.abs(t.Sprite:getScaleY());
		if bFlipY or bFlipY==nil then
			yScale = -yScale;
		end
		t.Sprite:setScaleY(yScale);
	end

	--设置位置
	function t:SetPostion(pos)
		if t.Sprite == nil then
			cclog("***PlayAnimationByIndex faild dure to: sprite not create---");
			return;
		end
		t.Sprite:setPosition(pos);
	end
	
	--设置缩放
	function t:SetScale(fScale)
		if t.Sprite == nil then
			cclog("***PlayAnimationByIndex faild dure to: sprite not create---");
			return;
		end
		t.Sprite:setScale(fScale);
	end
	
	function t:SetAutoInfo(callFunc, funcParam)
		t.AutoReleaseCallFun = callFunc;
		t.AutoReleaseParam = funcParam;
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
			if t.isAutoRelease then
				t.Sprite:removeFromParentAndCleanup(true);
				if t.AutoReleaseCallFun ~= nil then
					t.AutoReleaseCallFun(t.AutoReleaseParam);
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
		cclog("frameEvent:%s",evt);
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
