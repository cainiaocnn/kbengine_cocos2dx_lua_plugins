--游戏战斗对话
GameFightHeroTalk = {};
local p = GameFightHeroTalk;

p.ui = nil;
p.uiLayer = nil;

--账号注销回调函数
function p.gameLoginOut()
	p.ui = nil;
	p.uiLayer = nil;
end

--UI Cocostudio 的窗口
function p:create()
	if p.uiLayer == nil then
		p.uiLayer = TouchGroup:create()
		p.ui = ui_delegate(GUIReader:shareReader():widgetFromJsonFile("UserUI/LoginFight.json"));
		p.uiLayer:addWidget(p.ui.nativeUI);
		
		p:ShowAllFalse();
		--注册按钮事件
		-- ui_add_click_listener(p.ui.Button_40_0,p.changeMap); --切换地图
		-- ui_add_click_listener(p.ui.Button_40_1,p.SpeedFight); --快速战斗
		-- ui_add_click_listener(p.ui.Button_40,p.battleSet); --战斗设置
	end
    return p.uiLayer;
end

--显示英雄说的文字
function p:ShowHeroWorld(bLeft , strName, strWorld)
	
	local showIndex = 0;
	local showCount = 1;
	local textLenth = string.len(strWorld);
	local showText  = nil;
	local pLabel = tolua.cast(p.ui["Label_Des"], "Label");
	if pLabel ~= nil then
		p:ShowHeroName(bLeft, strName);
		pLabel:setText("");
		local function func()
			
			local useStr = string.sub(strWorld, 1, showIndex);	
			local nValue = string.byte(strWorld, showCount)
			local byteCount = 1;
			if nValue ~= nil then
				if nValue > 0 and nValue < 127 then
					byteCount = 1;
				elseif nValue>=192 and nValue<223 then
					byteCount = 2;
				elseif nValue>=224 and nValue<239 then
					byteCount = 3;
				elseif nValue>=240 and nValue<=247 then
					byteCount = 4;
				else
					byteCount = 3;
				end
			end
			showIndex = showIndex + byteCount;
			showCount = showCount + byteCount;
			
			if showIndex >= textLenth then
				pLabel:stopAllActions();
				pLabel:setText(strWorld);
				--p:ShowAllFalse();
			else
				pLabel:setText(tostring(useStr));
			end
		end
		Scheduler.scheduleNode(pLabel, func, 0.03);
	end
    
end

--显示战斗对话的名字
function p:ShowHeroName(bLeft, strName)
	--显示左边英雄名字
	local pImageLeft = tolua.cast(p.ui["Image_39"], "ImageView");
	if pImageLeft ~= nil then
		pImageLeft:setVisible(bLeft);
		if bLeft then
			local pLabel = tolua.cast(p.ui["Label_MyName"], "Label");
			if pLabel ~= nil then
				pLabel:setText(strName);
			end
		end
	end

	--显示右边英雄名字
	local pImageRight = tolua.cast(p.ui["Image_39_0"], "ImageView");
	if pImageRight ~= nil then
		pImageRight:setVisible(not bLeft);
		if not bLeft then
			local pLabel = tolua.cast(p.ui["Label_Name"], "Label");
			if pLabel ~= nil then
				pLabel:setText(strName);
			end
		end
	end
end

--全部不显示
function p:ShowAllFalse()
	local pImageLeft = tolua.cast(p.ui["Image_39"], "ImageView");
	if pImageLeft ~= nil then
		pImageLeft:setVisible(false);
	end

	--显示右边英雄名字
	local pImageRight = tolua.cast(p.ui["Image_39_0"], "ImageView");
	if pImageRight ~= nil then
		pImageRight:setVisible(false);
	end
	
	local pLabel = tolua.cast(p.ui["Label_Des"], "Label");
	if pLabel ~= nil then
		pLabel:setText("");
	end
end

return p;