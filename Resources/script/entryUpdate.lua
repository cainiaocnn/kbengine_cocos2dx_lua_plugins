require "frameWork/define.lua"
require "gameNetWork/define.lua"
require "gameLogin/define.lua"
require "gameAccount/define.lua"
require "gameKBEngine/define.lua"


-- avoid memory leak
collectgarbage("setpause", 100)
collectgarbage("setstepmul", 5000)
-- cclog
cclog = function(...)
    print("NOramlLog:"..string.format(...))
end

Dlog = function(...)
    print("DebugLog:"..string.format(...))
end

Wlog = function(...)
    print("WaringLog:"..string.format(...))
end

Elog = function(...)
    print("ErrorLog:"..string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)


	local debugMsg = debug.traceback();
	if __G_ENTRY_TRACKBACK__ ~= nil then
		__G_ENTRY_TRACKBACK__(msg.."||"..debugMsg)
	end
	
	--Win32
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debugMsg)
    cclog("----------------------------------------")
	--]]
end
---------------------------------------------------------

--添加搜索路径
function AddSearchPath()
	local fileWritePath = CCFileUtils:sharedFileUtils():getWritablePath();
	--添加搜索路径到最先搜索
	--最后搜索脚本路径
	local script		= fileWritePath.."Resources/script/";
	CCFileUtils:sharedFileUtils():addSearchPathToFront(script);
	--再然后资源包中的GUI资源
	CCFileUtils:sharedFileUtils():addSearchPathToFront("res/StudioGUI/");
	--然后资源部的内部资源
	CCFileUtils:sharedFileUtils():addSearchPathToFront("res/");
	--其次下载Gui的路径
	local guiResExt		= fileWritePath.."Resources/res/StudioGUI/";
	CCFileUtils:sharedFileUtils():addSearchPathToFront(guiResExt);
	--最先搜索下载的资源
	local resExt		= fileWritePath.."Resources/res/";
	CCFileUtils:sharedFileUtils():addSearchPathToFront(resExt);
end



function MainEntery()
	--[[
    -- runGame
	local targetPlatform = CCApplication:sharedApplication():getTargetPlatform()
	if kTargetAndroid == targetPlatform then --Android
		GameUpdate.UpdateEntery(true);	--开启热更新
	else
		GameUpdate.UpdateEntery(true);	--开启热更新
	end
	--]]
	
	AddSearchPath();
	local sceneGame = CCScene:create();
	-- local login  = gameLogin:GetMainGUIGroup();
	-- sceneGame:addChild(login,10,10);
	StudioGuiManager.OpenStudioGUI(StudioGuiTag.GUI_GAME_LOGIN, sceneGame);
	CCDirector:sharedDirector():runWithScene(sceneGame);
	
end

-------------------------------------------
--脚本代码入口函数是(p.MainEntery)
xpcall(MainEntery, __G__TRACKBACK__)