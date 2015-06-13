-- CLJ 
-- 描述:Studio GUI控制
StudioGuiManager = {};
local p = StudioGuiManager;

local m_OpenGuiTagList  = {};
local m_CloseGuiTagList = {};

--窗口枚举
StudioGuiTag = 
{
	GUI_GAME_LOGIN  = 1,		--登陆界面
	GUI_GAME_CHOOSE = 2,		--选择界面
	
}

-- 所有UI创建入口
function p.CreateStudioGui(nGUITag)
	local guiHandle = nil;
	if nGUITag == StudioGuiTag.GUI_GAME_LOGIN then
		guiHandle = gameLogin:GetMainGUIGroup();
	elseif nGUITag == StudioGuiTag.GUI_GAME_CHOOSE then
		guiHandle = gameAccount:GetMainGUIGroup();	
	else
		Elog("CreateStudioGui %s", tostring(nGUITag));
	end
	return guiHandle;
end

-- 打开一个StduioGui窗口
function p.OpenStudioGUI(nGUITag, sceneGame)
	local curScene = sceneGame;
	if curScene == nil then
		curScene = CCDirector:sharedDirector():getRunningScene();
	end
	if curScene ~= nil then
		local guiHandle = p.CreateStudioGui(nGUITag);
		if guiHandle ~= nil then
			curScene:addChild(guiHandle);
		end
	else
		Elog("OpenStudioGUI is Faild");
	end
end

-- 关闭一个StduioGui窗口
function p.CloseStudioGUI(nGUITag)
	local curScene = CCDirector:sharedDirector():getRunningScene();
	if curScene ~= nil then
		local guiHandle = curScene:getChildByTag(nGUITag);
		if guiHandle ~= nil then
			guiHandle:setVisible(true);
			guiHandle:setTouchEnabled(false);
			guiHandle:removeFromParentAndCleanup(false);
		end
	else
		Elog("CloseStudioGUI is Faild");
	end
end

-- 获取一个StduioGui窗口
function p.GetStudioGUI()
	
end

-- 改变一个StduioGui层次
function p.ChangeGUIZorder()

end