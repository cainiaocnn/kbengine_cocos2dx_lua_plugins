-- 组装KBEngine 消息发送包
KBEngineMessageSend = {};
local p = KBEngineMessageSend;

-- 发送消息
----------------------------
--***************************************************************************************************
--[[
	<id>1</id>
	<descr>客户端请求断线。</descr>
--]]
function p:Loginapp_reqClose(streamBuffer)
	local pKBEngine = KBEngineApp:shareKBEngineApp();
	if pKBEngine ~= nil then
		if streamBuffer == nil then
			streamBuffer = CCBuffer:create();
		end
		pKBEngine:send(streamBuffer);
	end
end

--[[
	<id>2</id>
	<descr>客户端请求创建一个账号。</descr>
	<arg>STRING</arg> <!-- 账号名 -->
	<arg>STRING</arg> <!-- 密码 -->
	<arg>UINT8_ARRAY</arg> <!-- 二进制流， 具体由开发者来解析 -->
--]]
function p:Loginapp_reqCreateAccount(streamBuffer, strAccount, strPassWord, externBuffer)
	local pKBEngine = KBEngineApp:shareKBEngineApp();
	if pKBEngine ~= nil then
		--[[
			bundle.writeString(username);
			bundle.writeString(password);
			bundle.writeBlob(KBEngineApp.app._clientdatas);
		--]]
		if streamBuffer == nil then
			streamBuffer = CCBuffer:create();
		end
		
		local msgLen = string.len(strAccount) + 1 + string.len(strPassWord) + 1 + 4;
		if externBuffer ~= nil then
			msgLen = msgLen + string.len(externBuffer);
		end

		KBEngineBuffer:writeUint16(streamBuffer, 2);		--//MSG ID
		KBEngineBuffer:writeUint16(streamBuffer, msgLen);	--//数据长度			
		streamBuffer:writeString(strAccount);		--账号名称
		streamBuffer:writeChar(0);
		streamBuffer:writeString(strPassWord);		--账号密码
		streamBuffer:writeChar(0);
		if externBuffer ~= nil then
			KBEngineBuffer:writeBlob(streamBuffer,externBuffer);
		end
		pKBEngine:send(streamBuffer);
	end
end

--[[
	<id>3</id>
	<descr>客户端请求登录到服务器的loginapp进程， 此进程收到请求验证合法后会返回一个网关地址。</descr>
	<arg>STRING</arg> <!-- 前端类别 0:调试前端, 1:手机前端, n.. -->
	<arg>UINT8_ARRAY</arg> <!-- 具体由开发者来解析 -->
	<arg>STRING</arg> <!-- 账号名 -->
	<arg>STRING</arg> <!-- 密码 -->
--]]
function p:Loginapp_login(streamBuffer, eClientType, strAccount, strPassWord, externBuffer)
	local pKBEngine = KBEngineApp:shareKBEngineApp();
	if pKBEngine ~= nil then
		--[[
		bundle.writeInt8((sbyte)_args.clientType); // clientType
		bundle.writeBlob(KBEngineApp.app._clientdatas);
		bundle.writeString(username);
		bundle.writeString(password);
		--]]
		if streamBuffer == nil then
			streamBuffer = CCBuffer:create();
		end
		
		local msgLen = string.len(strAccount) + 1 + string.len(strPassWord) + 1 + 4;
		if externBuffer ~= nil then
			msgLen = msgLen + string.len(externBuffer);
		end

		KBEngineBuffer:writeUint16(streamBuffer, 3);		--//MSG ID
		KBEngineBuffer:writeUint16(streamBuffer, msgLen);	--//数据长度		
		streamBuffer:writeChar(eClientType);
		if externBuffer ~= nil then
			KBEngineBuffer:writeBlob(streamBuffer,externBuffer);
		end
		streamBuffer:writeString(strAccount);
		streamBuffer:writeChar(0);
		streamBuffer:writeString(strPassWord);
		streamBuffer:writeChar(0);
		pKBEngine:send(streamBuffer);
	end
end

--[[
	<id>4</id>
	<descr>hello。</descr>
--]]
function p:Loginapp_hello(streamBuffer, clientVersion, clientScriptVersion, externBuffer)
	local pKBEngine = KBEngineApp:shareKBEngineApp();
	if pKBEngine ~= nil then
		--[[
			bundle.writeString(clientVersion);
			bundle.writeString(clientScriptVersion);
			bundle.writeBlob(_encryptedKey);
		--]]
		if streamBuffer == nil then
			streamBuffer = CCBuffer:create();
		end
		
		local msgLen = string.len(clientVersion) + 1 + string.len(clientScriptVersion) + 1 + 4;
		if externBuffer ~= nil then
			msgLen = msgLen + string.len(externBuffer);
		end
		
		KBEngineBuffer:writeUint16(streamBuffer, 4);		--//MSG ID
		KBEngineBuffer:writeUint16(streamBuffer, msgLen);	--//数据长度		
		streamBuffer:writeString(clientVersion);		--//clientVersion 客户端版本
		streamBuffer:writeChar(0);
		streamBuffer:writeString(clientScriptVersion);	--//clientScriptVersion 客户端脚本版本
		streamBuffer:writeChar(0);
		if externBuffer ~= nil then
			KBEngineBuffer:writeBlob(streamBuffer,externBuffer);
		end
		pKBEngine:send(streamBuffer);
	end
end


--[[
	<id>5</id>
	<descr>客户端请求导入消息协议。</descr>
--]]
function p:Loginapp_importClientMessages(streamBuffer)
	local pKBEngine = KBEngineApp:shareKBEngineApp();
	if pKBEngine ~= nil then
		if streamBuffer == nil then
			streamBuffer = CCBuffer:create();
		end
		KBEngineBuffer:writeUint16(streamBuffer, 5);		--//MSG ID
		pKBEngine:send(streamBuffer);
	end
end

--[[
	<id>6</id>
	<descr>客户端请求创建一个mail账号。</descr>
	<arg>STRING</arg> <!-- 账号名 -->
	<arg>STRING</arg> <!-- 密码 -->
	<arg>UINT8_ARRAY</arg> <!-- 二进制流， 具体由开发者来解析 -->
--]]
function p:Loginapp_reqCreateMailAccount(streamBuffer, strAccount, strPassWord, externBuffer)
	local pKBEngine = KBEngineApp:shareKBEngineApp();
	if pKBEngine ~= nil then
		if streamBuffer == nil then
			streamBuffer = CCBuffer:create();
		end
		pKBEngine:send(streamBuffer);
	end
end

-------------------------------------------------------------------------------------------
--[[ Baseapp--]]
-------------------------------------------------------------------------------------------

--[[
	<id>200</id>
	<descr>hello。</descr>
--]]
function p:Baseapp_hello(streamBuffer, clientVersion, clientScriptVersion, externBuffer)
	local pKBEngine = KBEngineApp:shareKBEngineApp();
	if pKBEngine ~= nil then
		--[[
			bundle.writeString(clientVersion);
			bundle.writeString(clientScriptVersion);
			bundle.writeBlob(_encryptedKey);
		--]]
		if streamBuffer == nil then
			streamBuffer = CCBuffer:create();
		end
		
		local msgLen = string.len(clientVersion) + 1 + string.len(clientScriptVersion) + 1 + 4;
		if externBuffer ~= nil then
			msgLen = msgLen + string.len(externBuffer);
		end
		
		KBEngineBuffer:writeUint16(streamBuffer, 200);		--//MSG ID
		KBEngineBuffer:writeUint16(streamBuffer, msgLen);	--//数据长度		
		streamBuffer:writeString(clientVersion);		--//clientVersion 客户端版本
		streamBuffer:writeChar(0);
		streamBuffer:writeString(clientScriptVersion);	--//clientScriptVersion 客户端脚本版本
		streamBuffer:writeChar(0);
		if externBuffer ~= nil then
			KBEngineBuffer:writeBlob(streamBuffer,externBuffer);
		end
		pKBEngine:send(streamBuffer);
	end
end

--[[
	<id>201</id>
	<descr>客户端请求断线。</descr>
--]]
function p:Baseapp_reqClose()
	local pKBEngine = KBEngineApp:shareKBEngineApp();
	if pKBEngine ~= nil then
		if streamBuffer == nil then
			streamBuffer = CCBuffer:create();
		end
		pKBEngine:send(streamBuffer);
	end
end

--[[
	<id>202</id>
	<descr>客户端请求登录到服务器的网关进程， 如果合法则将进入游戏。</descr>
	<arg>STRING</arg> <!-- 账号名 -->
	<arg>STRING</arg> <!-- 密码 -->
--]]
function p:Baseapp_loginGateway(streamBuffer, strAccount, strPassWord)
	local pKBEngine = KBEngineApp:shareKBEngineApp();
	if pKBEngine ~= nil then
		--[[
		bundle.writeString(username);
		bundle.writeString(password);
		--]]
		if streamBuffer == nil then
			streamBuffer = CCBuffer:create();
		end
		
		local msgLen = string.len(strAccount) + 1 + string.len(strPassWord) + 1;
		KBEngineBuffer:writeUint16(streamBuffer, 202);		--//MSG ID
		KBEngineBuffer:writeUint16(streamBuffer, msgLen);	--//数据长度
		streamBuffer:writeString(strAccount);
		streamBuffer:writeChar(0);
		streamBuffer:writeString(strPassWord);
		streamBuffer:writeChar(0);
		pKBEngine:send(streamBuffer);
	end
end

--[[
	<descr>重新登录 快速与网关建立交互关系(前提是之前已经登录了， 
	之后断开在服务器判定该前端的Entity未超时销毁的前提下可以快速与服务器建立连接并达到操控该entity的目的)
	</descr>
	<arg>UINT64</arg> <!-- 64位随机GUID码 -->
	<arg>INT32</arg> <!-- ENTITY_ID -->
--]]
function p:Baseapp_reLoginGateway()
	local pKBEngine = KBEngineApp:shareKBEngineApp();
	if pKBEngine ~= nil then
		if streamBuffer == nil then
			streamBuffer = CCBuffer:create();
		end
		pKBEngine:send(streamBuffer);
	end
end

--[[
	<Baseapp::onRemoteCallCellMethodFromClient>
	<id>205</id>
	<descr>调用一个cell远程方法。</descr>
	<arg>INT32</arg> <!-- entityID -->
	<arg>UINT8_ARRAY</arg> <!-- 方法参数二进制流， 具体由方法来解析 -->
	</Baseapp::onRemoteCallCellMethodFromClient>
--]]
function p:Baseapp_onRemoteCallCellMethodFromClient(streamBuffer, bSend, nEntityID, intArray)
	local pKBEngine = KBEngineApp:shareKBEngineApp();
	if pKBEngine ~= nil then

		if streamBuffer == nil then
			streamBuffer = CCBuffer:create();
		end
		
		local msgLen = 4 + 4;
		if intArray ~= nil then
			msgLen = msgLen + string.len(intArray) ;
		end
		
		KBEngineBuffer:writeUint16(streamBuffer, 205);		--//MSG ID
		KBEngineBuffer:writeUint16(streamBuffer, msgLen);	--//数据长度
		
		KBEngineBuffer:writeInt32(streamBuffer, nEntityID);	--//entityID
		if intArray ~= nil then
			KBEngineBuffer:writeBlob(streamBuffer,intArray);
		end
		
		if bSend then
			pKBEngine:send(streamBuffer);
		end
	end
end

--[[
	<id>206</id>
	<descr>客户端的tick。</descr>
--]]
function p:Baseapp_onClientActiveTick()
	Dlog("--Send-----Baseapp_onClientActiveTick-------");
	local pKBEngine = KBEngineApp:shareKBEngineApp();
	if pKBEngine ~= nil then
		if streamBuffer == nil then
			streamBuffer = CCBuffer:create();
		end
		pKBEngine:send(streamBuffer);
	end
end
--[[
	<id>207</id>
	<descr>客户端请求导入消息协议。</descr>
--]]
function p:Baseapp_importClientMessages()
	local pKBEngine = KBEngineApp:shareKBEngineApp();
	if pKBEngine ~= nil then
		if streamBuffer == nil then
			streamBuffer = CCBuffer:create();
		end
		KBEngineBuffer:writeUint16(streamBuffer, 207);		--//MSG ID
		pKBEngine:send(streamBuffer);
	end
end

--[[
	<id>208</id>
	<descr>客户端entitydef导出。</descr>
--]]
function p:Baseapp_importClientEntityDef(streamBuffer)
	Dlog("--Send-----Baseapp_importClientEntityDef-------");
	local pKBEngine = KBEngineApp:shareKBEngineApp();
	if pKBEngine ~= nil then
		if streamBuffer == nil then
			streamBuffer = CCBuffer:create();
		end
		KBEngineBuffer:writeUint16(streamBuffer, 208);	--//MSG ID
		pKBEngine:send(streamBuffer);
	end
end

--[[
	<id>301</id>
	<descr>调用一个base远程方法。</descr>
	<arg>INT32</arg> <!-- entityID -->
	<arg>UINT16</arg> <!-- 方法ID -->
	<arg>UINT8_ARRAY</arg> <!-- 方法参数二进制流， 具体由方法来解析 -->
--]]
function p:Base_onRemoteMethodCall(streamBuffer, bSend, nEntityID, funcID, intArray)
	local pKBEngine = KBEngineApp:shareKBEngineApp();
	if pKBEngine ~= nil then

		if streamBuffer == nil then
			streamBuffer = CCBuffer:create();
		end
		
		local msgLen = 4 + 2 + 4;
		if intArray ~= nil then
			msgLen = msgLen + string.len(intArray);
		end
		
		KBEngineBuffer:writeUint16(streamBuffer, 205);		--//MSG ID
		KBEngineBuffer:writeUint16(streamBuffer, msgLen);	--//数据长度
		
		KBEngineBuffer:writeInt32(streamBuffer, nEntityID);	--//entityID
		KBEngineBuffer:writeUint16(streamBuffer, funcID);	--//funcID
		if intArray ~= nil then
			KBEngineBuffer:writeBlob(streamBuffer,intArray);
		end
		
		if bSend then
			pKBEngine:send(streamBuffer);
		end
	end
end


------------------Entity----------------------
--[[
	<id>302</id>
	<descr>调用一个cell远程方法。</descr>
	<arg>INT32</arg> <!-- entityID -->
	<arg>UINT16</arg> <!-- 方法ID -->
	<arg>UINT8_ARRAY</arg> <!-- 方法参数二进制流， 具体由方法来解析 -->
--]]
function p:Entity_onRemoteMethodCall( nEntityID,  funcID )

end

---------------------------------------------
------------------Proxy----------------------
--[[
	<id>401</id>
	<descr>服务器将cell信息初始化给客户端后， 客户端应该告知服务器这个回调供服务器确定。
	</descr>
--]]
function p:Proxy_onClientGetCell()

end

