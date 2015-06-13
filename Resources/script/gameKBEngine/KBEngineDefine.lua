-- KBE定义
KBEngineDefine = {};
local p = KBEngineDefine;

--
KBENetState = 
{
	On_UnknowCondition	= -1,
	On_MessageReceived	= 0,
	On_Connected		= 1,
	On_ConnectTimeout	= 2,
	On_Disconnected		= 3,
	On_ExceptionCaught	= 4,
	
	--Socket执行到的步骤
	KBENGINE_STEP_1		= 100,	--Loginapp_hello
	KBENGINE_STEP_2		= 101,
	KBENGINE_STEP_3		= 102,
	KBENGINE_STEP_4		= 103,
	KBENGINE_STEP_5		= 104,
	
};
--]]

--客户端需要注册的消息ID枚举
EnumKEBMessageID = 
{
	--创建账号成功和失败回调
	eCreateAccountResult = 501,
	--客户端登陆到loginapp，服务器返回成功
	eLoginSuccessfully	 = 502,
	--客户端登陆到loginapp，服务器返回失败
	eLoginFailed		 = 503,	
	--服务器端已经创建了一个与客户端关联的代理Entity在登录时也可表达成功回调
	eCreatedProxies	 = 504,
	--服务器端已经创建了一个与客户端关联的代理Entity在登录时也可表达成功回调
	eCreatedEntity		 = 513,
	--客户端登陆到网关，服务器返回失败
	eLoginGatewayFailed = 505,
	--调用一个远程方法
	eRemoteMethodCall	 = 506,
	--[[/*
		一个entity进入世界(初次登录时第一个进入世界的是自己这个ENTITY， 其后理论是其他entity， 对比ID来判断)。
		当有entity进入玩家的AOI时则会触发客户端这个接口。 (AOI: area of interest, 也可理解为服务器上可视范围)
	*/--]]
	eEntityEnterWorld  = 507,
	--[[/*
		一个entity进入世界(初次登录时第一个进入世界的是自己这个ENTITY， 其后理论是其他entity， 对比ID来判断)。
		当有entity离开玩家的AOI时则会触发客户端这个接口
	*/--]]
	eEntityLeaveWorld = 508,
	--[[/*
		一个entity进入世界(初次登录时第一个进入世界的是自己这个ENTITY， 其后理论是其他entity， 对比ID来判断)。
		当有entity进入玩家的AOI时则会触发客户端这个接口。 (AOI: area of interest, 也可理解为服务器上可视范围)
	*/--]]
	eEntityEnterSpace  = 509,
	--[[/*
		一个entity进入世界(初次登录时第一个进入世界的是自己这个ENTITY， 其后理论是其他entity， 对比ID来判断)。
		当有entity离开玩家的AOI时则会触发客户端这个接口
	*/--]]
	eEntityLeaveSpace = 510,
	--某个entity的属性被更新了
	eUpdatePropertys  = 511,
	--告诉客户端某个entity销毁了， 此类entity通常是还未onEntityEnterWorld
	eEntityDestroyed = 512,
	--服务器告知客户端数据流开始下载
	eStreamDataStarted = 514,
	--客户端接收到数据流
	eStreamDataRecv  = 515, 
	--服务器告知客户端数据流下载完成
	eStreamDataCompleted = 516,
	--服务器已经踢出该客户端
	eKicked = 517,
	--服务器返回的协议包
	eImportClientMessages = 518,
	--服务器返回的entitydef数据
	eImportClientEntityDef = 519, 
	--服务器向客户端添加几何映射
	eaddSpaceGeometryMapping  = 520,
	--hello的回调
	eHelloCB = 521 ,
	--脚本版本不匹配
	eScriptVersionNotMatch = 522,
	--引擎版本不匹配
	eVersionNotMatch = 523
};


--KBE客户端登陆枚举类型
KBEClientEnum = 
{
	CLIENT_TYPE_MOBILE				= 1,
	CLIENT_TYPE_PC					= 2,
	CLIENT_TYPE_BROWSER				= 3,
	CLIENT_TYPE_BOTS				= 4,
	CLIENT_TYPE_MINI				= 5,
}


KBEServiceErrorCode =
{
	-- 	成功。
	SUCCESS = 0,
		
	-- 	服务器没有准备好。
	SERVER_ERR_SRV_NO_READY = 1,
	
	-- 服务器负载过重。
	SERVER_ERR_SRV_OVERLOAD = 2,

	-- 非法登录。
	SERVER_ERR_ILLEGAL_LOGIN = 3,
	
	-- 用户名或者密码不正确。
	SERVER_ERR_NAME_PASSWORD = 4,
	
	-- 用户名不正确。
	SERVER_ERR_NAME = 5,
	
	-- 密码不正确。
	SERVER_ERR_PASSWORD = 6,
	
	-- 创建账号失败（已经存在一个相同的账号）。
	SERVER_ERR_ACCOUNT_CREATE_FAILED = 7,
		
	-- 操作过于繁忙(例如：在服务器前一次请求未执行完毕的情况下连续N次创建账号)。
	SERVER_ERR_BUSY = 8,
		
	-- 当前账号在另一处登录了。
	SERVER_ERR_ACCOUNT_LOGIN_ANOTHER = 9,
		
	-- 账号已登陆。
	SERVER_ERR_ACCOUNT_IS_ONLINE = 10,
	
	-- 与客户端关联的proxy在服务器上已经销毁。
	SERVER_ERR_PROXY_DESTROYED = 11,
	
	-- EntityDefs不匹配。
	SERVER_ERR_ENTITYDEFS_NOT_MATCH = 12,
		
	-- 服务器正在关闭中。
	SERVER_ERR_SERVER_IN_SHUTTINGDOWN = 13,
		
	-- Email地址错误。
	SERVER_ERR_NAME_MAIL = 14,
		
	-- 账号被冻结。
	SERVER_ERR_ACCOUNT_LOCK = 15,
		
	-- 账号已过期。
	SERVER_ERR_ACCOUNT_DEADLINE = 16,
		
	-- 账号未激活。
	SERVER_ERR_ACCOUNT_NOT_ACTIVATED = 17,
		
	-- 与服务端的版本不匹配。
	SERVER_ERR_VERSION_NOT_MATCH = 18,
		
	-- 操作失败。
	SERVER_ERR_OP_FAILED = 19,
		
	-- 服务器正在启动中。
	SERVER_ERR_SRV_STARTING = 20,
		
	-- 未开放账号注册功能。
	SERVER_ERR_ACCOUNT_REGISTER_NOT_AVAILABLE = 21,
	
	-- 	不能使用email地址。	
	SERVER_ERR_CANNOT_USE_MAIL= 22,
	
	-- 	找不到此账号。
	SERVER_ERR_NOT_FOUND_ACCOUNT = 23,
	
	-- 	数据库错误(请检查dbmgr日志和DB)。
	SERVER_ERR_DB = 24,
}

function ShowSocketCodeInfo(nCode)
	if KBEServiceErrorCode.SUCCESS == nCode then
		Dlog("	成功")
	elseif KBEServiceErrorCode.SERVER_ERR_SRV_NO_READY == nCode then
		Dlog("	服务器没有准备好")
	elseif KBEServiceErrorCode.SERVER_ERR_SRV_OVERLOAD == nCode then
		Dlog("服务器负载过重")
	elseif KBEServiceErrorCode.SERVER_ERR_ILLEGAL_LOGIN == nCode then
		Dlog("非法登录")
	elseif KBEServiceErrorCode.SERVER_ERR_NAME_PASSWORD == nCode then
		Dlog("用户名或者密码不正确")
	elseif KBEServiceErrorCode.SERVER_ERR_NAME == nCode then
		Dlog("用户名不正确")
	elseif KBEServiceErrorCode.SERVER_ERR_PASSWORD == nCode then
		Dlog("密码不正确")
	elseif KBEServiceErrorCode.SERVER_ERR_ACCOUNT_CREATE_FAILED == nCode then
		Dlog("创建账号失败（已经存在一个相同的账号）")
	elseif KBEServiceErrorCode.SERVER_ERR_BUSY == 8 then
		Dlog("操作过于繁忙(例如：在服务器前一次请求未执行完毕的情况下连续N次创建账号)")
	elseif KBEServiceErrorCode.SERVER_ERR_ACCOUNT_LOGIN_ANOTHER == nCode then
		Dlog("当前账号在另一处登录了")
	elseif KBEServiceErrorCode.SERVER_ERR_ACCOUNT_IS_ONLINE == nCode then
		Dlog("账号已登陆")
	elseif KBEServiceErrorCode.SERVER_ERR_PROXY_DESTROYED == nCode then
		Dlog("与客户端关联的proxy在服务器上已经销毁")
	elseif KBEServiceErrorCode.SERVER_ERR_ENTITYDEFS_NOT_MATCH == nCode then
		Dlog("EntityDefs不匹配")
	elseif KBEServiceErrorCode.SERVER_ERR_SERVER_IN_SHUTTINGDOWN == nCode then
		Dlog("服务器正在关闭中")
	elseif KBEServiceErrorCode.SERVER_ERR_NAME_MAIL == nCode then
		Dlog("Email地址错误")
	elseif KBEServiceErrorCode.SERVER_ERR_ACCOUNT_LOCK == nCode then
		Dlog("账号被冻结")
	elseif KBEServiceErrorCode.SERVER_ERR_ACCOUNT_DEADLINE == nCode then
		Dlog("账号已过期")
	elseif KBEServiceErrorCode.SERVER_ERR_ACCOUNT_NOT_ACTIVATED == nCode then
		Dlog("账号未激活")
	elseif KBEServiceErrorCode.SERVER_ERR_VERSION_NOT_MATCH == nCode then
		Dlog("与服务端的版本不匹配")
	elseif KBEServiceErrorCode.SERVER_ERR_OP_FAILED == nCode then
		Dlog("操作失败")
	elseif KBEServiceErrorCode.SERVER_ERR_SRV_STARTING == nCode then
		Dlog("服务器正在启动中")
	elseif KBEServiceErrorCode.SERVER_ERR_ACCOUNT_REGISTER_NOT_AVAILABLE == nCode then
		Dlog("未开放账号注册功能")
	elseif KBEServiceErrorCode.SERVER_ERR_CANNOT_USE_MAIL== nCode then
		Dlog("	不能使用email地址")	
	elseif KBEServiceErrorCode.SERVER_ERR_NOT_FOUND_ACCOUNT == nCode then
		Dlog("	找不到此账号")
	elseif KBEServiceErrorCode.SERVER_ERR_DB == nCode then
		Dlog("	数据库错误(请检查dbmgr日志和DB)")
	else
		Dlog("Socket 未知错误")
	end
end