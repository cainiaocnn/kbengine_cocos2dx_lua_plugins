require "common/define.lua"
require "quick_x/define.lua"

-- avoid memory leak
collectgarbage("setpause", 100);
collectgarbage("setstepmul", 5000);

entryScript = {};
local p = entryScript;

function p.MainEntery()
    --------------
    -- run
    local sceneGame = CCScene:create();
	local login  = login2.create();
	sceneGame:addChild(login,10,10);
	local targetPlatform = CCApplication:sharedApplication():getTargetPlatform()
	if kTargetWindows == targetPlatform then --WIN
		cclog("do Enter Scene For WIN32");
		CCDirector:sharedDirector():replaceScene(sceneGame);--WIN32调用这接口
	elseif kTargetAndroid == targetPlatform then --Android
		cclog("do Enter Scene For Android");
		CCDirector:sharedDirector():replaceScene(sceneGame);--安卓调用这接口
	else --IOS
		cclog("do Enter Scene For IOS");
		CCDirector:sharedDirector():replaceScene(sceneGame);--IOS调用这接口	
	end
	
end

function p.PushErrorInfo(pszServerAddress, postData, strFlag)
	local pSendMsg = CCHttpMessage:create();
	if pSendMsg ~=nil then
		local function callBack()
		end
        pSendMsg:registerScriptHandler(callBack);
		pSendMsg:PostHttpMessage(pszServerAddress , postData, strFlag);
	end
end

-------------------------------------------
function __G_ENTRY_TRACKBACK__(msg)
	--脚本Crash上传服务器
	--[[
	local pGameUpdate = CGameUpdate:sharedGameUpdate();
	if pGameUpdate ~= nil then
		local nSysPlatFrom = pGameUpdate:getSysPlatform();
		if nSysPlatFrom ~= 3 then ----IOS Android
			
			local strGame = "Idle";
			local pGameUpdate = CGameUpdate:sharedGameUpdate();
			if pGameUpdate ~= nil then
				local nSeverClientVersion = pGameUpdate:getSeverVersion();
				strGame = strGame..tostring(nSeverClientVersion);
			end
			local postData = string.format("userid=%s&crashlog=%s&game=%s", tostring(UserData.UserID), msg, strGame);
			p.PushErrorInfo(GameConfig.CrashServiceAddress, postData, "PushCrashLog");
		end
	end
	--]]
end

--脚本代码入口函数是(p.MainEntery)
xpcall(p.MainEntery, __G_ENTRY_TRACKBACK__)