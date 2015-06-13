-- @module
GameLoginOut = {}
local p = GameLoginOut;

local m_ScriptTb = {};

--账号注销回调函数
function p.gameLoginOut()

end

my_require = function(luaFullName)
    local t = require(luaFullName);
	if t ~= nil then
		table.insert(m_ScriptTb, t);
		if type(t) == "boolean" then
			cclog("******  "..tostring(luaFullName)..":Forget Return Table ******");
		else
			if type(t.gameLoginOut) ~= "function" then
				cclog("******  "..tostring(luaFullName)..":Forget Create gameLoginOut function ******");
			end
		end

	else
		cclog("~~~My Lua Require Ret Nil~~~");
	end
end

function p.LoginOutMain()
	-- 1:清理所有 Scheduler 定时器
	Scheduler.unscheduleAllGlobal();
	
	-- 2:执行所有脚本情况函数
	for k, v in pairs(m_ScriptTb) do
		if type(v.gameLoginOut) == "function" then
			v.gameLoginOut();
		end
	end
	-- m_ScriptTb = {};
	
	--设置
	GameUpdate.SetLoginOut(true);
	
	--Last:执行重新脚本
	local pGameUpdate = CGameUpdate:sharedGameUpdate();
	if pGameUpdate ~= nil then
		pGameUpdate:enterGameExecuteScriptFile("script/entryUpdate.lua");
	end
	
	--清理内存
	CCPlistCache:sharedPlistCache():removeUnusedPlists();
	CCTextureCache:sharedTextureCache():removeUnusedTextures();
	
	--告诉平台注销
	if LoginForSDK.LoginSDKType == LoginForSDK.LoginSDKEnum.YAOWANSDK then
		--YaoWan
		local pLoginSDK = CGameForSDK:sharedCGameForSDK();
		if pLoginSDK ~= nil then
			pLoginSDK:GameLoginOut(1);
		else
			cclog("***Game LoginOut YaoWan Error Dure To No Find CGameForSDK***");
		end
	elseif LoginForSDK.LoginSDKMain == LoginForSDK.MainSDKEnum.MSDK_MAIN then
		--MSDK
		local pLoginSDK = CGameForSDK:sharedCGameForSDK();
		if pLoginSDK ~= nil then
			pLoginSDK:SetLoginState(MSDKEnum.eFlag_Local_Invalid);
			pLoginSDK:GameLoginOut(1);
		else
			cclog("***Game LoginOut MSDK Error Dure To No Find CGameForSDK***");
		end
	end
end
