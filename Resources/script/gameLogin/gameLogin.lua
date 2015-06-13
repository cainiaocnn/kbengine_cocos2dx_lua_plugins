-- 游戏登陆
gameLogin = class("gameLogin", StudioGuiNormal);
local p = gameLogin;


local m_pEditAccount = nil;
local m_pEditPassWord= nil;

--获取窗口
function p:GetMainGUIGroup()
	local guiLayer = p:CreateGUI("GameLogin.json", "GameLoginGUI", p.onNodeEvent);
	if guiLayer == nil then
		Elog("GameLoginGUI Create Failed!");
	else
		-- guiLayer:setZOrder();
	end
	return guiLayer;
end

--窗口加载完毕和退出结束事件
function p.onNodeEvent(event)
	if "enter" == event then
		p.InitGUI();
		p.InitEvent();
	elseif "exit" == event then

	end
end

--初始化事件
function p:InitGUI()
	-- cclog("---没有重写初始化UI函数:InitGUI---");
	local pImageAccount =  p:GetStudioUINode("Image_Account", "ImageView");
	if pImageAccount ~= nil then
		local tSize 		= pImageAccount:getSize();
		local pszBackImage 	= "EditBoxImage/1.png";
		local pEdit = CCEditBoxCreate:CreateEditBox(tSize, pszBackImage, 0, ccp(0,0), 25, ccc3(0,0,0), "请输入账号", ccc3(0,0,0), 48, nil);
		if pEdit ~= nil then
			m_pEditAccount = pEdit;
			pEdit:setPosition(ccp(-tSize.width/2,-tSize.height/2));
			pEdit:setText("ccccccc")
			pImageAccount:addNode(pEdit,1,100);
		end
	end
	
	local pImagePassWord =  p:GetStudioUINode("Image_PassWord", "ImageView");
	if pImagePassWord ~= nil then
		local tSize 		= pImagePassWord:getSize();
		local pszBackImage 	= "EditBoxImage/1.png";
		local pEdit = CCEditBoxCreate:CreateEditBox(tSize, pszBackImage, 0, ccp(0,0), 25, ccc3(0,0,0), "请输入密码", ccc3(0,0,0), 48, nil);
		if pEdit ~= nil then
			m_pEditPassWord = pEdit;
			pEdit:setPosition(ccp(-tSize.width/2,-tSize.height/2));
			pEdit:setText("1111111")
			pImagePassWord:addNode(pEdit,1,200);
		end
	end
	
	-- p:InitSockte();
end

-- 初始化Sockte
function p:InitSockte()
	KBEngineSocket:InitSocket();
end

--初始化事件
function p:InitEvent()
	-- cclog("---没有重写初始化事件函数:InitEvent---");
	p:RegisteredTouchEventByNodeName("Button_Enter",  p.LoginEnter);
	p:RegisteredTouchEventByNodeName("Button_Create", p.LoginCreate);
end

function p.LoginEnter(sender,eventType)
	Dlog("------------1");
	
	local strAccount = "";
	local pImageAccount =  p:GetStudioUINode("Image_Account", "ImageView");
	if pImageAccount ~= nil then
		local pEditAccount = tolua.cast(pImageAccount:getNodeByTag(100), "CCEditBox");
		if pEditAccount ~= nil then
			strAccount = m_pEditAccount:getText();
		end
	end
	local strPassWord = "";
	local pImagePassWord =  p:GetStudioUINode("Image_PassWord", "ImageView");
	if pImagePassWord ~= nil then
		local pEditPassWord = tolua.cast(pImagePassWord:getNodeByTag(200), "CCEditBox");
		if pEditPassWord ~= nil then
			strPassWord = m_pEditPassWord:getText();
		end
	end

	--保存账号密码
	KBEngineSocket.loginUserName = strAccount;
	KBEngineSocket.loginPassWord = strPassWord;
	
	KBEngine.login_loginapp(true);
	--[[
	--判断Scoket是否连接上了
	if KBEngineSocket:CheckState(KBENetState.On_Connected) then

		KBEngineSocket:RegiestCallBack(EnumKEBMessageID.eHelloCB, p.LoginApp_Client_onHelloCB, nil, {strAccount,strPassWord}, true);
		KBEngineMessageSend:Loginapp_hello(nil, "0.6.0", "0.1.0", "kbengine_unity3d_demo");
	else
		--没有连接上Socket的话就先连接Socket
		p:InitSockte();
		KBEngineSocket:RegiestCallBack(KBENetState.On_Connected, p.LoginEnter, nil, nil, true);
	end
	--]]
end

--执行登陆游戏
function p.LoginApp_Client_onHelloCB(nMsgId, tReceMsg, streamBuffer, tParam)
	if not KBEngineSocket.loginappMessageImported then
		KBEngine.currserver = "loginapp"
		KBEngineMessageSend:Loginapp_importClientMessages(nil);
	else
		KBEngineMessageReive.Client_onHelloCB(nMsgId, tReceMsg, streamBuffer);
		KBEngineSocket:RegiestCallBack(EnumKEBMessageID.eLoginSuccessfully, p.Client_LoginAppCallBack, nil, tParam, true);
		KBEngineSocket:RegiestCallBack(EnumKEBMessageID.eLoginFailed, p.Client_LoginAppCallBack, nil, nil, true);
		KBEngineMessageSend:Loginapp_login(nil, KBEClientEnum.CLIENT_TYPE_MINI, tParam[1], tParam[2], "kbengine_unity3d_demo");
	end
end

--登陆游戏回调
function p.Client_LoginAppCallBack(nMsgId, tReceMsg, streamBuffer, tParam)
	if nMsgId == EnumKEBMessageID.eLoginSuccessfully then
		
		local tMyReceMsg = {};
		KBEngineMessageReive.Client_onLoginSuccessfully(nMsgId, tMyReceMsg, streamBuffer);
		--登陆BaseApp
		KBEngineSocket:ColseSocket();

		-- local function disConnetCall()
			KBEngineSocket:InitSocket(tMyReceMsg.strAddress, tMyReceMsg.nPort);
			KBEngineSocket:RegiestCallBack(KBENetState.On_Connected, p.BaseAppLogin, nil, tParam, true);
		-- end
		-- KBEngineSocket:RegiestCallBack(KBENetState.On_Disconnected, disConnetCall, nil, nil, true);
		
	elseif nMsgId == EnumKEBMessageID.eLoginFailed then
		KBEngineMessageReive.Client_onLoginFailed(nMsgId, tReceMsg, streamBuffer);
	else
		Dlog("登陆未知错误");
	end
end

function p.LoginCreate(sender,eventType)
	Dlog("------------2");
	--判断Scoket是否连接上了
	if KBEngineSocket:CheckState(KBENetState.On_Connected) then
		local strAccount = "";
		local pImageAccount =  p:GetStudioUINode("Image_Account", "ImageView");
		if pImageAccount ~= nil then
			local pEditAccount = tolua.cast(pImageAccount:getNodeByTag(100), "CCEditBox");
			if pEditAccount ~= nil then
				strAccount = m_pEditAccount:getText();
			end
		end
		local strPassWord = "";
		local pImagePassWord =  p:GetStudioUINode("Image_PassWord", "ImageView");
		if pImagePassWord ~= nil then
			local pEditPassWord = tolua.cast(pImagePassWord:getNodeByTag(200), "CCEditBox");
			if pEditPassWord ~= nil then
				strPassWord = m_pEditPassWord:getText();
			end
		end
		if strAccount == nil or strAccount=="" then
			Dlog("请输入账号");
			return;
		end
		if strPassWord == nil or strPassWord=="" then
			Dlog("请输入密码");
			return;
		end

		--保存账号密码
		KBEngineSocket.loginUserName = strAccount;
		KBEngineSocket.loginPassWord = strPassWord;

		KBEngineSocket:RegiestCallBack(EnumKEBMessageID.eHelloCB, p.LoginAppCreate, nil, {strAccount,strPassWord}, true);
		KBEngineMessageSend:Loginapp_hello(nil, "0.6.0", "0.1.0", "kbengine_unity3d_demo");
	else
		p:InitSockte();
		KBEngineSocket:RegiestCallBack(KBENetState.On_Connected, p.LoginCreate, nil, nil, true);
	end
	
end

function p.LoginAppCreate(nMsgId, tReceMsg, streamBuffer, tParam)
	KBEngineMessageReive.Client_onHelloCB(nMsgId, tReceMsg, streamBuffer);
	KBEngineSocket:RegiestCallBack(EnumKEBMessageID.eCreateAccountResult, p.Client_onCreateAccountResult, nil, nil, true);
	KBEngineMessageSend:Loginapp_reqCreateAccount(nil, tParam[1], tParam[2], "kbengine_unity3d_demo");
end
		
--创建账号回调
function p.Client_onCreateAccountResult(nMsgId, tReceMsg, streamBuffer, tParam)
	KBEngineMessageReive.Client_onCreateAccountResult(nMsgId, tReceMsg, streamBuffer);
end

--
function p.BaseAppLogin(nMsgId, tReceMsg, streamBuffer, tParam)
	Dlog("BaseAppLogin");
	Dlog("BaseApp strAccount :"..tParam[1]);
	Dlog("BaseApp strPassWord:"..tParam[2]);

	-- KBEngineMessageSend:Baseapp_loginGateway(nil, tParam[1], tParam[2]);
	KBEngineSocket:RegiestCallBack(EnumKEBMessageID.eHelloCB, p.BaseApp_Client_onHelloCB, nil, tParam, true);
	KBEngineMessageSend:Baseapp_hello(nil, "0.6.0", "0.1.0", "kbengine_unity3d_demo");
end

--执行登陆游戏
function p.BaseApp_Client_onHelloCB(nMsgId, tReceMsg, streamBuffer, tParam)
	KBEngineMessageReive.Client_onHelloCB(nMsgId, tReceMsg, streamBuffer);
	
	if not KBEngineSocket.entitydefImported then
		--如果客户端实体数据没有导入的话
		KBEngineMessageSend:Baseapp_importClientEntityDef(nil);
	else
	
	end
end
