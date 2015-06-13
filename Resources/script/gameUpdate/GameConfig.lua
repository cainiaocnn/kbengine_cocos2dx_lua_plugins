-- @module
GameConfig = {}
local p = GameConfig;
--[[
游戏配置文件:
	打包前要确认下
--]]

--游戏聊天相关设置

--这个Key是给要玩用户
--**************************************************************************************
--语言包设置(只对简体繁体中文生效)
GameConfig.IsFT = false;

--Idle原住民使用聊天地址
VoiceRoom={
	--原住民
	Key = "bcbe8cb3-0d58-47bb-a9ff-2dff4f751097",
	worldRoom = 910342;
}
--]]
--[[
VoiceRoom={
	--ForYaoWan
	Key = "07d1acfc-6515-45c7-88b8-1c6c4ffcc24e",
	worldRoom = 2060059;
}
--]]

--崩溃收集地址
p.CrashServiceAddress = "http://114.215.211.10:50/CrashLogCollect.aspx";

--登陆MD5校验KEY
p.MD5KEY = "44CAC8ED53714BF18D60C5C7B6296000";

--**************************************************************************************
--选服列表请求地址--
-- Idle原住民选服列表
p.LoginServicesUrl = "http://114.215.211.10:60/GameServerList.aspx?serverlist=Regionid=1"
-- 要玩地址
-- p.LoginServicesUrl = "http://123.59.12.11:60/GameServerList.aspx?serverlist=Regionid=1"

--**************************************************************************************
--游戏热更新地址
-- Idle原住民地址
p.CheckVersionUrl 	= "http://114.215.211.10/version/TalkingDataIdleGame/talkDataIdleGame.txt";
-- 要玩地址
-- p.CheckVersionUrl 	= "http://123.59.15.64/GameUpdate/YaoWanChannel/YaoWanVersion.txt"

--**************************************************************************************
--游戏热更新下载默认地址
-- Idle原住民地址
p.DownLoadUrl		= "http://114.215.211.10/version/TalkingDataIdleGame/DownLoad/";
-- 要玩的地址
-- p.DownLoadUrl	= "http://123.59.15.64/GameUpdate/YaoWanChannel/DownLoad/"

--SDK登陆主类型(如果一个SDK含多个需要定义 LoginSDKMain数据)
LoginForSDK.LoginSDKMain  	= nil;

--和服务器匹配的数据
--登陆SDK类型(一个SDK没有其他SDK时候就定义LoginSDKType即可)()
LoginForSDK.LoginSDKType	= LoginForSDK.LoginSDKEnum.YAOWANSDK;
