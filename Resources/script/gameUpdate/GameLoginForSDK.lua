-- @module
LoginForSDK = {}
local p = LoginForSDK;

-- 主的SDK类型(一个SDK中包含多个登陆时候需要设置)
p.MainSDKEnum = {
	NONE_MAIN 	= 0,				--没有SDK
	MSDK_MAIN 	= 1,				--腾讯MSDK
	YAOWAN_MAIN = 2,				--要玩SDK
}

-- 所有SDK枚举(和服务器匹配的数据)
p.LoginSDKEnum={
	NONESDK 		= 1,	--无SDK
	YAOWANSDK		= 2,	--要玩SDK
	MSDKQQSDK		= 3,	--MSDK For QQ
	MSDKWeiXinSDK	= 4,	--MSDK For WeiXin
}

-- QQ SDK登陆返回状态枚举
MSDKEnum = {
  eFlag_Succ = 0,
  eFlag_QQ_NoAcessToken = 1000,
  eFlag_QQ_UserCancel = 1001,
  eFlag_QQ_LoginFail = 1002,
  eFlag_QQ_NetworkErr = 1003,
  eFlag_QQ_NotInstall = 1004,
  eFlag_QQ_NotSupportApi = 1005,
  eFlag_QQ_AccessTokenExpired = 1006,
  eFlag_QQ_PayTokenExpired = 1007,
  eFlag_WX_NotInstall = 2000,
  eFlag_WX_NotSupportApi = 2001,
  eFlag_WX_UserCancel = 2002,
  eFlag_WX_UserDeny = 2003,
  eFlag_WX_LoginFail = 2004,
  eFlag_WX_RefreshTokenSucc = 2005,
  eFlag_WX_RefreshTokenFail = 2006,
  eFlag_WX_AccessTokenExpired = 2007,
  eFlag_WX_RefreshTokenExpired = 2008,
  eFlag_Error = -1,
  eFlag_Local_Invalid = -2,
  eFlag_NotInWhiteList = -3,
  eFlag_LbsNeedOpenLocationService = -4,
  eFlag_LbsLocateFail = -5,
  eFlag_NeedLogin = 3001,
  eFlag_UrlLogin = 3002,
  eFlag_NeedSelectAccount = 3003,
  eFlag_AccountRefresh = 3004,
}


--SDK登陆相关
p.LoginSDKMain  = nil;		--登陆SDK主类型
p.LoginSDKType	= nil;		--登陆SDK类型

--登陆请求平台相关
--------------------------------------------------------------------------------------------
function p.LoginExternStr()
	local targetPlatform = CCApplication:sharedApplication():getTargetPlatform()
	if kTargetAndroid == targetPlatform then --Android For SDK
		local pLoginSDK = CGameForSDK:sharedCGameForSDK();
		if pLoginSDK ~= nil then
			local str = ",";
			local macimei = pLoginSDK:GetSysIMEIString();	--设备唯一标识符
			if macimei == nil or macimei == "" then
				cclog("**IMEI Error**")
				macimei = pLoginSDK:GetSysMAC();    		--MAC地址
				if macimei == nil or macimei == "" then
					macimei = "Error";
					cclog("**MAC Error**")
				end
			end
			local devicesys = pLoginSDK:GetDeviceSys();   	--设备系统详情
			local devicetype = pLoginSDK:GetDeviceType();   --Android Iphone Ipa
			local deviceinfo = pLoginSDK:GetDeviceinfo();   --设备型号 小米 三星什么的
			str = str.."macidfa="..tostring(macimei);
			str = str..",devicesys="..tostring(devicesys);
			str = str..",devicetype="..tostring(devicetype);
			str = str..",deviceinfo="..tostring(deviceinfo);
			cclog(str);
			return str;
		end
	end
	return "";
end

--SDK登陆请求协议入口
function p.SDKLoginReq(pCallBack)
	
	-- 初始化服务器地址
	local targetPlatform = CCApplication:sharedApplication():getTargetPlatform()
	if kTargetAndroid == targetPlatform then --Android For SDK
	--安卓登陆
		local pLoginSDK = CGameForSDK:sharedCGameForSDK();
		if pLoginSDK ~= nil then
			--无SDK
			if p.LoginSDKType == p.LoginSDKEnum.NONESDK then
				local strTalkMsg = UserDataConfig.Get_Key_Value("UserName",UserDataConfig.DataType_STRING);
				if strTalkMsg == nil or strTalkMsg == "" then
					math.randomseed(os.time());
					strTalkMsg = tostring(os.time()) .. math.random(0,100000);
				end
				p.UserName = strTalkMsg; 
				p.SaveServerInfo();
			
				if pCallBack == nil then
					cclog("***Login Http CallBack Is Nil***");
				else
					NetReq.RequestLogin(tostring(strTalkMsg), "1", p.LoginSDKEnum.NONESDK, "", login2.LoginSever, pCallBack);
				end
			--要玩SDK
			elseif p.LoginSDKType == p.LoginSDKEnum.YAOWANSDK then
				local nCode = pLoginSDK:GetLoginState();
				if nCode == 1 then
					local userUid 		= pLoginSDK:GetLoginUid();
					local userName 		= pLoginSDK:GetLoginUsername();
					local userSession	= pLoginSDK:GetLoginSessionId();
					cclog("YAOWAN SDK LOGIN: UserUid  = %s", tostring(userUid));
					cclog("YAOWAN SDK LOGIN: UserName = %s", tostring(userName));
					cclog("YAOWAN SDK LOGIN: Session  = %s", tostring(userSession));
					local sParam = "sessionid="..tostring(userSession);
					sParam = sParam..p.LoginExternStr();
					sParam = sParam..",sdkusername="..tostring(userName);
					cclog("YAOWAN SDK LOGIN: sParam  = %s", tostring(sParam));
					if pCallBack == nil then
						cclog("***Login Http CallBack Is Nil***");
					else
						NetReq.RequestLogin(tostring(userUid), userUid, p.LoginSDKType, sParam, login2.LoginSever, pCallBack);
					end
				else
					cclog("***YAOWAN LOGIN CODE:%d***", nCode);
					pLoginSDK:OpenSDKLoginView();
				end
			-- 腾讯MSDK登陆
			elseif p.LoginSDKMain  == p.MainSDKEnum.MSDK_MAIN then
				--MSDK QQ SDK
				if p.LoginSDKType == p.LoginSDKEnum.MSDKQQSDK then
					local nMSDKCode = pLoginSDK:GetLoginState();
					if nMSDKCode == MSDKEnum.eFlag_Succ then
						local openid 		= pLoginSDK:GetLoginUsername();
						local openkey 		= pLoginSDK:GetLoginSessionId();
						cclog("MSDK QQ SDK LOGIN: openId  = %s", tostring(openid));
						cclog("MSDK QQ SDK LOGIN: openKey  = %s", tostring(openkey));
						local sParam = "openkey="..tostring(openkey);
						sParam = sParam..p.LoginExternStr();
						if pCallBack == nil then
							cclog("***Login Http CallBack Is Nil***");
						else
							NetReq.RequestLogin(tostring(openid), "QQ", p.LoginSDKType, sParam, login2.LoginSever, pCallBack);
						end
					elseif nMSDKCode == MSDKEnum.eFlag_WX_UserCancel then
						-- //用户取消授权逻辑
						pLoginSDK:SendToSDKPlatform(6);
					elseif nMSDKCode == MSDKEnum.eFlag_WX_UserCancel then
						-- //用户取消授权逻辑
						pLoginSDK:SendToSDKPlatform(6);
					elseif nMSDKCode == MSDKEnum.eFlag_QQ_AccessTokenExpired then
						-- //QQ登陆授权过期
						pLoginSDK:SendToSDKPlatform(6);
					elseif nMSDKCode == MSDKEnum.eFlag_Local_Invalid then
						-- //未进行过授权
						pLoginSDK:SendToSDKPlatform(6);
					elseif nMSDKCode == MSDKEnum.eFlag_QQ_NotInstall then
						pLoginSDK:SetPayExternStr2("");
						-- //玩家设备未安装QQ客户端逻辑
						local function fucNotInstallQQ()
						end
						TipsManager.ShowConfirmBox("提示", "你的设备未安装QQ,请选择其他登陆方式!", fucNotInstallQQ);
					elseif nMSDKCode == MSDKEnum.eFlag_QQ_NotSupportApi then
						pLoginSDK:SetPayExternStr2("");
						-- //玩家手Q客户端不支持此接口逻辑
						local function fucNotSupportQQ()
						end
						TipsManager.ShowConfirmBox("提示", "你的设备不支持QQ登陆,请选择其他登陆方式!", fucNotSupportQQ);
					elseif nMSDKCode == MSDKEnum.eFlag_NotInWhiteList then
						pLoginSDK:SetPayExternStr2("");
						-- //玩家账号不在白名单中逻辑
						local function fucNotInSupportQQ()
						end
						TipsManager.ShowConfirmBox("提示", "你的账号不在白名单中逻辑,请选择其他登陆方式!", fucNotInSupportQQ);
					else
						pLoginSDK:SetPayExternStr2("");
						-- // 其余登录失败逻辑
						local function fucOtherFailQQ()
						end
						TipsManager.ShowConfirmBox("提示", "QQ登陆未知错误,请选择其他登陆方式!", fucOtherFailQQ);
					end
					cclog("***************MSDK Code = %d****************", nMSDKCode);
				--MSDK WeiXin SDK
				elseif p.LoginSDKType == p.LoginSDKEnum.MSDKWeiXinSDK then						
					local nMSDKCode = pLoginSDK:GetLoginState();
					if nMSDKCode == MSDKEnum.eFlag_Succ then
						local openid 		= pLoginSDK:GetLoginUsername();
						local refreshToken 	= pLoginSDK:GetLoginSessionId();
						cclog("MSDK QQ SDK LOGIN: openId  = %s", tostring(openid));
						cclog("MSDK QQ SDK LOGIN: openKey  = %s", tostring(openkey));
						
						local sParam = "refreshToken="..tostring(refreshToken)
						sParam = sParam..p.LoginExternStr();
						if pCallBack == nil then
							cclog("***Login Http CallBack Is Nil***");
						else
							NetReq.RequestLogin(tostring(openid), "WeiXin", p.LoginSDKType, sParam, login2.LoginSever, pCallBack);
						end
					elseif nMSDKCode == MSDKEnum.eFlag_WX_UserCancel then
						-- //用户取消授权逻辑
						pLoginSDK:SendToSDKPlatform(7);
					elseif nMSDKCode == MSDKEnum.eFlag_WX_UserCancel then
						-- //用户取消授权逻辑
						pLoginSDK:SendToSDKPlatform(7);
					elseif nMSDKCode == MSDKEnum.eFlag_WX_UserDeny then
						-- //用户拒绝微信授权逻辑
						pLoginSDK:SendToSDKPlatform(7);
					elseif nMSDKCode == MSDKEnum.eFlag_WX_AccessTokenExpired then
						-- //微信授权过期
						pLoginSDK:SendToSDKPlatform(7);
					elseif nMSDKCode == MSDKEnum.eFlag_WX_RefreshTokenExpired then
						-- //微信授权过期
						pLoginSDK:SendToSDKPlatform(7);
					elseif nMSDKCode == MSDKEnum.eFlag_Local_Invalid then
						-- //未进行过授权
						pLoginSDK:SendToSDKPlatform(7);
					elseif nMSDKCode == MSDKEnum.eFlag_WX_NotInstall then
						pLoginSDK:SetPayExternStr2("");
						-- //玩家设备未安装微信客户端逻辑
						local function fucNotInstallWeiXin()
						end
						TipsManager.ShowConfirmBox("提示", "你的设备未安装微信,请选择其他登陆方式!", fucNotInstallWeiXin);
					elseif nMSDKCode == MSDKEnum.eFlag_WX_NotSupportApi then
						pLoginSDK:SetPayExternStr2("");
						-- //玩家微信客户端不支持此接口逻辑
						local function fucNotSupportWeiXin()
						end
						TipsManager.ShowConfirmBox("提示", "你的设备不支持微信登陆,请选择其他登陆方式!", fucNotSupportWeiXin);
					elseif nMSDKCode == MSDKEnum.eFlag_NotInWhiteList then
						pLoginSDK:SetPayExternStr2("");
						-- //玩家账号不在白名单中逻辑
						local function fucNotInSupportWeiXin()
						end
						TipsManager.ShowConfirmBox("提示", "你的账号不在白名单中逻辑,请选择其他登陆方式!", fucNotInSupportWeiXin);
					else
						pLoginSDK:SetPayExternStr2("");
						-- // 其余登录失败逻辑
						local function fucOtherFailWeiXin()
						end
						TipsManager.ShowConfirmBox("提示", "微信登陆未知错误,请选择其他登陆方式!", fucOtherFailWeiXin);
					end
					cclog("***************MSDK Code = %d****************", nMSDKCode);
				end
			end
		end
	
	elseif kTargetIphone == targetPlatform or targetPlatform == kTargetIpad then
	--IOS 登陆
		local strTalkMsg = UserDataConfig.Get_Key_Value("UserName",UserDataConfig.DataType_STRING);
		if strTalkMsg == nil or strTalkMsg == "" then
			math.randomseed(os.time());
			strTalkMsg = tostring(os.time()) .. math.random(0,100000);
		end
		p.UserName = strTalkMsg; 
		p.SaveServerInfo();
		if pCallBack == nil then
			cclog("***Login Http CallBack Is Nil***");
		else
			NetReq.RequestLogin(tostring(strTalkMsg), "1", p.LoginSDKEnum.NONESDK, "", login2.LoginSever, pCallBack);
		end
	else
		if pCallBack == nil then
			NetReq.RequestLogin(tostring(strTalkMsg), "1", LoginForSDK.LoginSDKEnum.NONESDK, "", p.LoginSever, p.onHttpMessageResponse);
		else
			NetReq.RequestLogin(tostring(strTalkMsg), "1", LoginForSDK.LoginSDKEnum.NONESDK, "", p.LoginSever, pCallBack);
		end
	end
	
	--语音SDK登陆
	VoiceControl:sharedInstance():init(VoiceRoom.Key,"com.shy.idlegame");
end

