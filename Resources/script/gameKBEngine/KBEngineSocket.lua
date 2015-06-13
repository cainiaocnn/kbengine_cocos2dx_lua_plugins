-- KBE 网络中心
KBEngineSocket = {};
local p = KBEngineSocket;


local m_SocketState = nil;
local m_tSocketCallBack = {};

p.loginappMessageImported = false;
p.baseappMessageImported = false;
p.entitydefImported = false;
p.loadingLocalMessages = false;

p.isImportServerErrorsDescr = false;
p.loadingLocalMessages = false;

--用户账号密码保存
p.loginUserName  = "";
p.loginPassWord  = "";

--[[
nMsgId, 	注册消息ID
callFunc, 	对应回调函数
tParam, 	回调参数表
bOnece		是否回调完马上删除
--]]
function p:RegiestCallBack(nMsgId, callFunc, tReceMsg, tParam, bOnece)
	m_tSocketCallBack[tostring(nMsgId)] = nil;
	
	local tCallInfo = {};
	tCallInfo.MsgId 	= nMsgId;
	tCallInfo.Function 	= callFunc;
	tCallInfo.tReceMsg	= tReceMsg;
	tCallInfo.tParam 	= tParam;
	tCallInfo.bOnece	= bOnece;
	m_tSocketCallBack[tostring(nMsgId)] = tCallInfo;
	
end

--
--nMsgId 		执行消息ID
--streamBuffer	字节流
function p:PerformRegiestFunc(nMsgId, streamBuffer)
	local tCallInfo = m_tSocketCallBack[tostring(nMsgId)];
	if tCallInfo ~= nil then
		if type(tCallInfo.Function) == "function" then
			tCallInfo.Function(nMsgId, tCallInfo.tReceMsg, streamBuffer, tCallInfo.tParam);
			if tCallInfo.bOnece then
				m_tSocketCallBack[tostring(nMsgId)] = nil;
			end
		else
			Elog("PerformRegiestFunc MSGID=%d callFunc is Not Function", nMsgId);
		end
	end
end

--接收消息拆包
local m_isPackFull = true;
local m_noFullStr = "";
local m_lastLen = 0;	--上个包缺多少数据长度
local m_fullLen = 0;	--上个包总的数据长度

local m_beforeMsgId  = 0;
local m_beforeMsgLen = 0;

function p:GetFullMssagePack(tPackList, streamBuffer)
	
	if streamBuffer:length() < 5 then
		Elog("-------------------------------------------");
		Elog("-------------数据长度不足------------------");
		Elog("-------------数据长度不足------------------");
		Elog("-------------数据长度不足------------------");
		Elog("-------------------------------------------");
	end
	if m_isPackFull then
		local msgId 	= KBEngineBuffer:readUint16(streamBuffer);
		local minLen	= 2;
		local msgLength = KBEngineMessageReive.MessageReiveLen(msgId);
		if msgLength == 0 then
			msgLength = KBEngineBuffer:readUint16(streamBuffer);
			minLen = 4;
		end
		
		--这里加4个长度是因为读取了4个长度
		local fullLen = streamBuffer:length();
		local lastLen = fullLen - msgLength- minLen;
		if lastLen >=0 then
			--有足够数据组包
			local pBuffer = streamBuffer:readData(msgLength);
			table.insert(tPackList, {msgId, pBuffer, msgLength});
			
			Dlog("MsgID :%d", msgId);
			Dlog("MsgLen Sevrvice Us Len:%d", msgLength);
			Dlog("MsgDate Get Data Len:%d", pBuffer:length());
			p:PerformRegiestFunc(msgId, pBuffer);
			
			m_isPackFull = true;
			--判断是否还有剩余
			if lastLen > 0 then
				local pLastBuffer = streamBuffer:readData(lastLen);
				p:GetFullMssagePack(tPackList, pLastBuffer);
			end
		else
			m_isPackFull = false;
			--读取剩余数据保存到字符串中,等待下个包过来组成新数据包
			m_lastLen = lastLen;
			m_fullLen = fullLen;
			m_beforeMsgId  = msgId;
			m_beforeMsgLen = msgLength;
			m_noFullStr = streamBuffer:readString(fullLen - 4);
			Dlog("*************出现半包情况啦啦啦-1*****************");
		end
	else
		--重新组包
		local newBufferLen = streamBuffer:length();
		if (newBufferLen+m_lastLen) >= 0 then
			--有新包了
			m_noFullStr = m_noFullStr..streamBuffer:readString(-m_lastLen);
			local pBuffer = CCBuffer:create();
			if pBuffer~= nil then
				-- pBuffer:writeData(m_noFullStr,m_fullLen);
				pBuffer:writeString(m_noFullStr);
				
				table.insert(tPackList, {m_beforeMsgId, pBuffer, m_beforeMsgLen});
				Dlog("MsgID :%d", m_beforeMsgId);
				Dlog("MsgLen Sevrvice Us Len:%d", m_beforeMsgLen);
				Dlog("MsgDate Get Data Len:%d",pBuffer:length());
				p:PerformRegiestFunc(m_beforeMsgId, pBuffer);
			end
			m_isPackFull = true;
			lastLen = newBufferLen+m_lastLen;
			--判断是否还有剩余
			if lastLen > 0 then
				local pLastBuffer = streamBuffer:readData(lastLen);
				p:GetFullMssagePack(tPackList, pLastBuffer);
			end
		else
			m_noFullStr = m_noFullStr..streamBuffer:readString(newBufferLen);
		end
		
	end
end

function p:CheckState(eState)
	if eState == m_SocketState then
		return true;
	end
	return false;
end

function p:SetSocketState(nState)
	m_SocketState = nState;
end

--
function p:GetSocketState()
	return m_SocketState;
end

function p:InitSocket(strAddress, nPort, bRegiest)
	if strAddress ==nil and nPort == nil then
		strAddress = "192.168.1.201";
		nPort = 20013;
	end

	local pKBEngine = KBEngineApp:shareKBEngineApp();
	if pKBEngine ~= nil then
		pKBEngine:registerScriptHandler(gameSocketNet.onSocketMessageReceived);
		pKBEngine:InitLoginAppAddres(strAddress, nPort);
		if bRegiest then
			p:RegiestAllDefineMessageCallBack();
		end
	end
	Dlog("strAddress :%s", strAddress);
	Dlog("nPort :%d", nPort);
	EntityDef.InitEnityDef();
	
end

function p:DisConnectSocket()
	local pKBEngine = KBEngineApp:shareKBEngineApp();
	if pKBEngine ~= nil then
		pKBEngine:disconnect();
	end
end

function p:ColseSocket()
	local pKBEngine = KBEngineApp:shareKBEngineApp();
	if pKBEngine ~= nil then
		pKBEngine:close();
	end
end

--清理所有消息
function p:ClearAllMsgCallBack()
	for k, v in pairs(m_tSocketCallBack) do
		v = nil;
	end
	m_tSocketCallBack = {};
end

--定义所有KBEngine消息回调函数
function p:RegiestAllDefineMessageCallBack()
	p:ClearAllMsgCallBack();
	
	p:RegiestCallBack(EnumKEBMessageID.eCreatedProxies, KBEngineMessageReive.Client_onCreatedProxies, nil, nil, false)
	p:RegiestCallBack(EnumKEBMessageID.eUpdatePropertys, KBEngineMessageReive.Client_onUpdatePropertys, nil, nil, false)
	p:RegiestCallBack(EnumKEBMessageID.eImportClientEntityDef, KBEngineMessageReive.Client_onImportClientEntityDef, nil, nil, false)
	p:RegiestCallBack(EnumKEBMessageID.eRemoteMethodCall, KBEngineMessageReive.Client_onRemoteMethodCall, nil, nil, false)
	p:RegiestCallBack(EnumKEBMessageID.eEntityDestroyed, KBEngineMessageReive.Client_onEntityDestroyed, nil, nil, false)
	p:RegiestCallBack(EnumKEBMessageID.eEntityEnterWorld, KBEngineMessageReive.Client_onEntityEnterWorld, nil, nil, false)
	p:RegiestCallBack(EnumKEBMessageID.eEntityEnterSpace, KBEngineMessageReive.Client_onEntityEnterSpace, nil, nil, false)
	p:RegiestCallBack(EnumKEBMessageID.eImportClientMessages, KBEngineMessageReive.Client_onImportClientMessages, nil, nil, false)
	p:RegiestCallBack(EnumKEBMessageID.eCreateAccountResult, KBEngineMessageReive.Client_onCreateAccountResult, nil, nil, false);
	p:RegiestCallBack(EnumKEBMessageID.eHelloCB, KBEngineMessageReive.Client_onHelloCB, nil, nil, false);
	p:RegiestCallBack(EnumKEBMessageID.eLoginSuccessfully, KBEngineMessageReive.Client_onLoginSuccessfully, nil, tParam, false);
	--[[
	p:RegiestCallBack(nMsgId, callFunc, nil, false);
	--]]
end
