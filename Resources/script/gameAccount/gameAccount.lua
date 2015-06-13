-- 游戏账号列表
gameAccount = class("gameAccount", StudioGuiNormal);
local p = gameAccount;

--获取窗口
function p:GetMainGUIGroup()
	local guiLayer = p:CreateGUI("GameChooseAccount.json", "GameChooseAccount", p.onNodeEvent);
	if guiLayer == nil then
		Elog("GameChooseAccount Create Failed!");
	end
	return guiLayer;
end

--窗口加载完毕和退出结束事件
function p.onNodeEvent(event)
	if "enter" == event then

	elseif "exit" == event then

	end
end

--初始化事件
function p:InitGUI()
	-- cclog("---没有重写初始化UI函数:InitGUI---");
end

--初始化事件
function p:InitEvent()
	-- cclog("---没有重写初始化事件函数:InitEvent---");
	p:RegisteredTouchEventByNodeName("Button_Enter",  p.GameEnter);
	p:RegisteredTouchEventByNodeName("Button_Create", p.AccountCreate);
	p:RegisteredTouchEventByNodeName("Button_Delete", p.AccountDelete);
end

--刷新数据
--[[直接使用继承的父类接口
function p:ReflashData(typeInfo, tDataInfo)

end
--]]

--刷新界面
function p:ReflashStudioGUI(typeInfo)
	local dataInfo = self:GetReflashData(typeInfo);
	if dataInfo ~= nil then
		p.ReflashAccountList(dataInfo);
	end
end

-- 进入游戏
function p.GameEnter(sender, event)
	local account = KBEngineEntityManager:GetPlayerEntity();
	if account ~= nil then
		local tAccountInfo = p:GetReflashData("selectAccount");
		if tAccountInfo ~= nil then
			local selAvatarDBID = tAccountInfo["dbid"];
			if selAvatarDBID ~= nil then
				account:selectAvatarGame(selAvatarDBID);
			else
				Elog("lua file:%s ,lua func:%s", "gameAccount", "GameEnter");
			end
		else
			Dlog("请选择登陆游戏账号");
		end
	end					
end

-- 创建角色
function p.AccountCreate(sender, event)
	
	local pTextField =  p:GetStudioUINode("TextField_4", "TextField");
	if pTextField ~= nil then
		local stringAvatarName = pTextField:getStringValue();
		if stringAvatarName == nil or stringAvatarName == "" then
			Dlog("请输入用户名");
			return;
		end
		local account = KBEngineEntityManager:GetPlayerEntity();
		if account ~= nil then
			account:reqCreateAvatar(1, stringAvatarName);
		end
	end
end

-- 删除角色
function p.AccountDelete(sender, event)
	local account = KBEngineEntityManager:GetPlayerEntity();
	if account ~= nil then
		local tAccount = p:GetReflashData("selectAccount");
		if tAccount ~= nil then
			account:reqRemoveAvatar(tAccount["name"]);
		else
			Dlog("请选择删除角色");
		end
	end
end

-- 刷新账号列表
function p.ReflashAccountList(avatarsList)
	local pListView =  p:GetStudioUINode("ListView_2", "ListView");
	if pListView ~= nil then
		pListView:removeAllItems()
		for k, v in pairs(avatarsList) do
			local accountItem =  GUIReader:shareReader():widgetFromJsonFile("AccountItem.json");
			local uButton = UIHelper:seekWidgetByName(accountItem, "Button_1");
			if uButton ~= nil then
				local pButton = tolua.cast(uButton, "Button");
				if pButton ~= nil then
					pButton:setTitleText(v["name"]);
					local function callEndFunc()
						p:ReflashData("selectAccount", v);
						Dlog(tostring(v["name"]));
					end
					p:RegisteredTouchEventByNode(pButton, callEndFunc)
				end
			end
			pListView:pushBackCustomItem(accountItem);
		end
	end
end
