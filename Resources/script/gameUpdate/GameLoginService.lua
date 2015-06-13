-- @module
GameLoginService = {}
local p = GameLoginService;

local m_JsonData = nil;
--请求获取服务器列表
function p.GetServerList(successFunc , funcErrorFunc)
	
	local function getServiceListCallBack(logMesg, pHttpMsg)
		local pHttp = tolua.cast(pHttpMsg, "CCHttpMessage");
		if pHttp == nil then
			print("**************严重错误***************");
			return;
		end
		local pNDTransData = pHttp:GetMessageBuffer();
		if pNDTransData ~= nil then
			m_JsonData = pNDTransData:readWholeData();
			--[[
			print("--------------------------");
			print(m_JsonData);
			print("--------------------------");
			--]]
		end
		
		if successFunc ~= nil then
			successFunc();
			successFunc = nil;
		end
	end
	
	local pSendMsg = CCHttpMessage:create();
	if pSendMsg ~=nil then
		pSendMsg:registerScriptHandler(getServiceListCallBack);
		pSendMsg:registerNetErrorHander(funcErrorFunc);
		pSendMsg:GetHttpMessage(GameConfig.LoginServicesUrl, "LoginService");
	end
end

function p.GetLoginServiceJsonData()
	if m_JsonData ~= nil then
		return m_JsonData;
	end
	return "";
end
