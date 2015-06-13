-- KBE
KBEngine = {};
local p = KBEngine;

p.currserver = "";
p.currstate  = "";

p.spaceID = 0;
p.isLoadedGeometry = false;
p._spacedatas = {};
p.spaceResPath = "";
p._entityIDAliasIDList = {};
p._entityServerPos = {};

function p.clearSpace( isall)
	KBEngineEntityManager:IDAliasValueClear();
	p._spacedatas = {}
	p.clearEntities(isall);
	p.isLoadedGeometry = false;
	p.spaceID = 0;
end

function p.clearEntities(isall)
	if not isall then
		KBEngineEntityManager:ClearButPlayer(isall);
	else
		KBEngineEntityManager:ClearButPlayer(isall);
	end
end


function p._updateVolatileData(entityID,  x,  y,  z,  yaw,  pitch,  roll,  isOnGound)

	local entity = KBEngineEntityManager:GetEntityValue(entityID);
	if entity == nil then
		-- // 如果为0且客户端上一步是重登陆或者重连操作并且服务端entity在断线期间一直处于在线状态
		-- // 则可以忽略这个错误, 因为cellapp可能一直在向baseapp发送同步消息， 当客户端重连上时未等
		-- // 服务端初始化步骤开始则收到同步信息, 此时这里就会出错。
		Elog("KBEngine::_updateVolatileData: entity("..entityID..") not found!");
		return;
	end
	
	-- // 小于0不设置
	if isOnGound >= 0 then
		if isOnGound > 0 then
			entity.isOnGound = true;
		else
			entity.isOnGound = false;
		end
	end

	local changeDirection = false;
	--[[
	if(roll != KBEDATATYPE_BASE.KBE_FLT_MAX)
	{
		changeDirection = true;
		entity.direction.x = KBEMath.int82angle((SByte)roll, false) * 360 / ((float)System.Math.PI * 2);
	}

	if(pitch != KBEDATATYPE_BASE.KBE_FLT_MAX)
	{
		changeDirection = true;
		entity.direction.y = KBEMath.int82angle((SByte)pitch, false) * 360 / ((float)System.Math.PI * 2);
	}
	
	if(yaw != KBEDATATYPE_BASE.KBE_FLT_MAX)
	{
		changeDirection = true;
		entity.direction.z = KBEMath.int82angle((SByte)yaw, false) * 360 / ((float)System.Math.PI * 2);
	}
	--]]
	local done = false;
	--[[
	if(changeDirection == true)
	{
		Event.fireOut("set_direction", new object[]{entity});
		done = true;
	}
	
	if(!KBEMath.almostEqual(x + y + z, 0f, 0.000001f))
	{
		Vector3 pos = new Vector3(x + _entityServerPos.x, y + _entityServerPos.y, z + _entityServerPos.z);
		
		entity.position = pos;
		done = true;
		Event.fireOut("update_position", new object[]{entity});
	}
	--]]
	if done then
		entity:onUpdateVolatileData();
	end
end

-- 通过流数据获得AOI实体的ID
function p.getAoiEntityIDFromStream(streamBuffer)

	local id = 0;
	if KBEngineEntityManager:GetIDAliasCount() > 255 then
	
		id = KBEngineBuffer:readInt32(streamBuffer);
		
		-- // 如果为0且客户端上一步是重登陆或者重连操作并且服务端entity在断线期间一直处于在线状态
		-- // 则可以忽略这个错误, 因为cellapp可能一直在向baseapp发送同步消息， 当客户端重连上时未等
		-- // 服务端初始化步骤开始则收到同步信息, 此时这里就会出错。
		if KBEngineEntityManager:GetIDAliasCount() == 0 then
			return 0;
		end
	else
	
		local aliasID = KBEngineBuffer:readUint8(streamBuffer);
		
		-- // 如果为0且客户端上一步是重登陆或者重连操作并且服务端entity在断线期间一直处于在线状态
		-- // 则可以忽略这个错误, 因为cellapp可能一直在向baseapp发送同步消息， 当客户端重连上时未等
		-- // 服务端初始化步骤开始则收到同步信息, 此时这里就会出错。
		if KBEngineEntityManager:GetIDAliasCount() == 0 then
			return 0;
		end
		id = KBEngineEntityManager:GetIDAliasValue(aliasID);
	end
	
	return id;
end

function p.createDataTypeFromStream(streamBuffer, canprint)

	local utype = KBEngineBuffer:readUint16(streamBuffer);
	
	local name = KBEngineBuffer:readString(streamBuffer);
	streamBuffer:readChar();
	
	local valname = KBEngineBuffer:readString(streamBuffer);
	streamBuffer:readChar()
	
	if EntityDef.datatypes[name] ~= nil then
		Elog("***********************************");
		Elog("EntityDef.datatypes name = %s", name);
	end
	
	if valname == "FIXED_DICT" then
	
		local datatype = KBEDATATYPE_FIXED_DICT();
		datatype.valname = valname;
		local keysize = KBEngineBuffer:readUint8(streamBuffer);
		
		datatype.implementedBy = KBEngineBuffer:readString(streamBuffer);
		streamBuffer:readChar();
		
		for i=1, keysize do
		
			local keyname = KBEngineBuffer:readString(streamBuffer);
			streamBuffer:readChar();
			
			local keyutype = KBEngineBuffer:readUint16(streamBuffer);
			datatype.dicttype[keyname] = keyutype;
			table.insert(datatype.dicttype.Keys, keyname);
		end
		EntityDef.datatypes[name] = datatype;
	
	elseif valname == "ARRAY" then
	
		local uitemtype = KBEngineBuffer:readUint16(streamBuffer);
		local datatype = KBEDATATYPE_ARRAY();
		datatype.valname = valname;
		datatype.vtype = uitemtype;
		EntityDef.datatypes[name] = datatype;
	
	else
		local datatype = DataType:CreateDataObject(valname);
		datatype.valname = valname;
		EntityDef.datatypes[name] = datatype;
	end

	EntityDef.iddatatypes[tostring(utype)] = EntityDef.datatypes[name];
	EntityDef.datatype2id[name] = EntityDef.datatype2id[valname];
	
end

function p.onImportClientEntityDef(streamBuffer)

	local aliassize = KBEngineBuffer:readUint16(streamBuffer);
	Dlog("KBEngine::Client_onImportClientEntityDef: importAlias(size="..tostring(aliassize)..")!");
	
	for i=1, aliassize do
		p.createDataTypeFromStream(streamBuffer, true);
	end
	Dlog("createDataTypeFromStream Finish");
	
	--
	for k, v in pairs(EntityDef.datatypes) do
		Dlog(tostring(k));
		if type(EntityDef.datatypes[k]["bind"]) == "function" then
			EntityDef.datatypes[k].bind();
		else
			-- Wlog("Cann't Find Bind Fuc In %s", tostring(k));
		end
	end
	--]]
	
	while streamBuffer:isReadable() do
	
		local scriptmethod_name = KBEngineBuffer:readString(streamBuffer);
		streamBuffer:readChar();
		
		local scriptUtype = KBEngineBuffer:readUint16(streamBuffer);
		local propertysize = KBEngineBuffer:readUint16(streamBuffer);
		local methodsize = KBEngineBuffer:readUint16(streamBuffer);
		local base_methodsize = KBEngineBuffer:readUint16(streamBuffer);
		local cell_methodsize = KBEngineBuffer:readUint16(streamBuffer);
		
		Dlog("KBEngine::Client_onImportClientEntityDef: import("..tostring(scriptmethod_name).."), propertys("..tostring(propertysize).."), ".."clientMethods("..tostring(methodsize).."), baseMethods("..tostring(base_methodsize).."), cellMethods("..tostring(cell_methodsize)..")!");
		
		
		local scriptModule =  ScriptModule(scriptmethod_name);
		EntityDef.moduledefs[scriptmethod_name] = scriptModule;
		EntityDef.idmoduledefs[scriptUtype] = scriptModule;

		local Class = scriptModule.script;
		for i=1, propertysize do
		
			local properUtype = KBEngineBuffer:readUint16(streamBuffer);
			local ialiasID = KBEngineBuffer:readInt16(streamBuffer);
			local name = KBEngineBuffer:readString(streamBuffer);
			streamBuffer:readChar();
			
			local defaultValStr = KBEngineBuffer:readString(streamBuffer);
			streamBuffer:readChar();
			
			local utypeDef = KBEngineBuffer:readUint16(streamBuffer)
			local utype = EntityDef.iddatatypes[tostring(utypeDef)];
			
			local setmethod = nil;
			if Class ~= nil then
				if type(Class["set_"..tostring(name)]) == "function" then
					setmethod = Class["set_"..tostring(name)];
				else
					Wlog("setmethod nil");
				end
			end
	
			
			local savedata = Property();
			savedata.name = name;
			savedata.utype = utype;
			savedata.properUtype = properUtype;
			savedata.aliasID = ialiasID;
			savedata.defaultValStr = defaultValStr;
			savedata.setmethod = setmethod;
			savedata.val = utype["parseDefaultValStr"](defaultValStr);
			
			scriptModule.propertys[name] = savedata;
			
			if ialiasID >= 0 then
				scriptModule.usePropertyDescrAlias = true;
				scriptModule.idpropertys[tostring(ialiasID)] = savedata;
			else
				scriptModule.usePropertyDescrAlias = false;
				scriptModule.idpropertys[tostring(properUtype)] = savedata;
			end
		end
		
		for i=1, methodsize do
		
			local methodUtype = KBEngineBuffer:readUint16(streamBuffer);
			local ialiasID = KBEngineBuffer:readInt16(streamBuffer);
			local name = KBEngineBuffer:readString(streamBuffer);
			streamBuffer:readChar();
			
			local argssize = KBEngineBuffer:readUint8(streamBuffer);
			
			local args = {};
			for j=1, argssize do
				local utypeDef = KBEngineBuffer:readUint16(streamBuffer)
				local t = EntityDef.iddatatypes[tostring(utypeDef)];
				table.insert(args, t);
			end
			
			local savedata = Method();
			savedata.name = name;
			savedata.methodUtype = methodUtype;
			savedata.aliasID = ialiasID;
			savedata.args = args;
			
			if Class ~= nil then
				-- 暂时不写
				-- savedata.handler = Class.GetMethod(name);
			end

			scriptModule.methods[name] = savedata;
			if ialiasID >= 0 then
				scriptModule.useMethodDescrAlias = true;
				scriptModule.idmethods[tostring(ialiasID)] = savedata;
			else
				scriptModule.useMethodDescrAlias = false;
				scriptModule.idmethods[tostring(methodUtype)] = savedata;
			end
		end
		
		
		for i=1, base_methodsize do
			
			local methodUtype = KBEngineBuffer:readUint16(streamBuffer);
			local ialiasID = KBEngineBuffer:readInt16(streamBuffer);
			local name = KBEngineBuffer:readString(streamBuffer);
			streamBuffer:readChar();
			
			local argssize = KBEngineBuffer:readUint8(streamBuffer);
			
			local args = {};
			for j=1, argssize do
				local utypeDef = KBEngineBuffer:readUint16(streamBuffer)
				local t = EntityDef.iddatatypes[tostring(utypeDef)];
				table.insert(args, t);
			end
			
			local savedata = Method();
			savedata.name = name;
			savedata.methodUtype = methodUtype;
			savedata.aliasID = ialiasID;
			savedata.args = args;
			
			scriptModule.base_methods[name] = savedata;
			scriptModule.idbase_methods[tostring(methodUtype)] = savedata;
		end
		
		for i=1, cell_methodsize do

			local methodUtype = KBEngineBuffer:readUint16(streamBuffer);
			local ialiasID = KBEngineBuffer:readInt16(streamBuffer);
			local name = KBEngineBuffer:readString(streamBuffer);
			streamBuffer:readChar();
			
			local argssize = KBEngineBuffer:readUint8(streamBuffer);
			
			local args = {};
			for j=1, argssize do
				local utypeDef = KBEngineBuffer:readUint16(streamBuffer)
				local t = EntityDef.iddatatypes[tostring(utypeDef)];
				table.insert(args, t);
			end
			
			local savedata = Method();
			savedata.name = name;
			savedata.methodUtype = methodUtype;
			savedata.aliasID = ialiasID;
			savedata.args = args;
		
			scriptModule.cell_methods[name] = savedata;
			scriptModule.idcell_methods[tostring(methodUtype)] = savedata;
		end
		
		if scriptModule.script == nil then
			Elog("KBEngine::Client_onImportClientEntityDef: module("..scriptmethod_name..") not found!");
		end
		--[[
		for name, v in scriptModule.methods do
			--
			if scriptModule.script ~= nil and scriptModule.script.GetMethod(name) == nil)
				Wlog(scriptmethod_name.."("..module.script.."):: method("..name..") no implement!");
			end
			--
		end
		--]]
	end
	p.onImportEntityDefCompleted();
end

function p.onImportEntityDefCompleted()

	Dlog("KBEngine::onImportEntityDefCompleted: successfully!");
	KBEngineSocket.entitydefImported = true;
	
	if not KBEngineSocket.loadingLocalMessages then
		p.login_baseapp(false);
	end
end

function p.login_baseapp( noconnect, tReceMsg)
  
	if noconnect then
		KBEngineSocket:ColseSocket();
		KBEngineSocket:InitSocket(tReceMsg.strAddress, tReceMsg.nPort, false);
		KBEngineSocket:RegiestCallBack(KBENetState.On_Connected, p.onConnectTo_baseapp_callback, nil, tParam, true);
	else
		KBEngineMessageSend:Baseapp_loginGateway(nil, KBEngineSocket.loginUserName, KBEngineSocket.loginPassWord);
	end
end

function p.onConnectTo_baseapp_callback()

	p.currserver = "baseapp";
	p.currstate = "";
	
	Dlog("KBEngine::login_baseapp(): connect  is successfully!");

	p.hello();
end

function p.onImportClientMessages(streamBuffer)
	
	local msgcount = KBEngineBuffer:readUint16(streamBuffer);
	Dlog("KBEngine::Client_onImportClientMessages: start currserver="..p.currserver..", msgsize="..msgcount);	
	
	for i=1, msgcount do
	
		local msgid = KBEngineBuffer:readUint16(streamBuffer);
		local msglen = KBEngineBuffer:readInt16(streamBuffer);
		
		local msgname = KBEngineBuffer:readString(streamBuffer);
		streamBuffer:readChar();
		
		local argstype = KBEngineBuffer:readInt8(streamBuffer);
		local argsize = KBEngineBuffer:readUint8(streamBuffer);
		
		local argstypes = {};
		for i=1, argsize do
			table.insert(argstypes, KBEngineBuffer:readUint8(streamBuffer));
		end
		
		local handler = nil;
		local isClientMethod = false;
		local a,b=string.find(msgname, "Client_")
		if a ~= nil and b~= nil then
			isClientMethod = true;
		end
		
		if isClientMethod then
			
			if type(KBEngineMessageReive[msgname]) == "function" then
				handler = KBEngineMessageReive[msgname];
				KBEngineSocket:RegiestCallBack(msgid, handler, nil, nil, false);
			else
				Dlog("Please Improt Func: %s", tostring(msgname))
			end
		end
		
		if string.len(msgname) > 0 then
		
			MessageMain.messages[msgname] = Message(msgid, msgname, msglen, argstype, argstypes, handler);

			if isClientMethod then
				MessageMain.clientMessages[msgid] = MessageMain.messages[msgname];
			else			
				if p.currserver == "loginapp" then
					MessageMain.loginappMessages[tostring(msgid)] = MessageMain.messages[msgname];
				else
					MessageMain.baseappMessages[tostring(msgid)] = MessageMain.messages[msgname];
				end
			end
		else
			local msg = Message(msgid, msgname, msglen, argstype, argstypes, handler);
			if p.currserver == "loginapp" then
				MessageMain.loginappMessages[tostring(msgid)] = msg;
			else
				MessageMain.baseappMessages[tostring(msgid)] = msg;
			end
		end
	end
	
	p.onImportClientMessagesCompleted();
	
end

function p.onImportClientMessagesCompleted()

	Dlog("KBEngine::onImportClientMessagesCompleted: successfully! currserver="..p.currserver..", currstate="..p.currstate);
	if p.currserver == "loginapp" then
		
		--[[
		if(!isImportServerErrorsDescr_ && !loadingLocalMessages_)
		{
			Dbg.DEBUG_MSG("KBEngine::onImportClientMessagesCompleted(): send importServerErrorsDescr!");
			isImportServerErrorsDescr_ = true;
			Bundle bundle = new Bundle();
			bundle.newMessage(Message.messages["Loginapp_importServerErrorsDescr"]);
			bundle.send(_networkInterface);
		}
		--]]
		
		if p.currstate == "login" then
			p.login_loginapp(false);
		elseif p.currstate == "autoimport" then

		elseif p.currstate == "resetpassword" then
			-- p.resetpassword_loginapp(false);
		elseif p.currstate == "createAccount" then
			-- p.createAccount_loginapp(false);
		else
		
		end

		KBEngineSocket.loginappMessageImported = true;
	
	else
	
		KBEngineSocket.baseappMessageImported = true;
		if not KBEngineSocket.entitydefImported and not KBEngineSocket.loadingLocalMessages then
			KBEngineMessageSend:Baseapp_importClientEntityDef(nil);
		else
			p.onImportEntityDefCompleted();
		end
	end
end

function p.login_loginapp(noconnect)
	if noconnect then
		
		KBEngineSocket:InitSocket(nil, nil , true);
		KBEngineSocket:RegiestCallBack(KBENetState.On_Connected, p.onConnectTo_loginapp_callback, nil, nil, true);
		
	else
		Dlog("KBEngine::login_loginapp(): send login! username="..tostring(KBEngineSocket.loginUserName));
		KBEngineMessageSend:Loginapp_login(nil, KBEClientEnum.CLIENT_TYPE_MINI, KBEngineSocket.loginUserName, KBEngineSocket.loginPassWord, "kbengine_unity3d_demo");
	end
end

function p.onConnectTo_loginapp_callback()
	
	p.currserver = "loginapp";
	p.currstate = "login";
	
	p.hello();
end

function p.hello()

	if p.currserver == "loginapp" then
		KBEngineMessageSend:Loginapp_hello(nil, "0.6.0", "0.1.0", "kbengine_unity3d_demo");
	else
		KBEngineMessageSend:Baseapp_hello(nil, "0.6.0", "0.1.0", "kbengine_unity3d_demo");
	end
end

function p.onLogin_baseapp()

	if not KBEngineSocket.baseappMessageImported then
		KBEngineMessageSend:Baseapp_importClientMessages();
	else
		p.onImportClientMessagesCompleted();
	end
end

function p.onLogin_loginapp()

	if not KBEngineSocket.loginappMessageImported then
		KBEngineMessageSend:Loginapp_importClientMessages(nil);
	else
		p.onImportClientMessagesCompleted();
	end
end

function p.Client_onEntityDestroyed(eid)
	
	Dlog("KBEngine::Client_onEntityDestroyed: entity("..eid..")");
	
	local entity = KBEngineEntityManager:GetEntityValue(eid)
	if entity == nil then
	
		Elog("KBEngine::Client_onEntityDestroyed: entity("..eid..") not found!");
		return;
	end
	
	if entity.inWorld then
		entity:leaveWorld();
	end
	
	entity:onDestroy();
	KBEngineEntityManager:SetEntityValue(eid, nil);
	
end

function p.Client_onHelloCB(streamBuffer)

	Dlog("serverVersion = %s",streamBuffer:readStringEndByZero());
	streamBuffer:readChar();
	Dlog("serverScriptVersion = %s",streamBuffer:readStringEndByZero());
	streamBuffer:readChar();
	Dlog("serverProtocolMD5 = %s",streamBuffer:readStringEndByZero());
	streamBuffer:readChar();
	Dlog("serverEntitydefMD5 = %s",streamBuffer:readStringEndByZero());
	streamBuffer:readChar();
	local cType = streamBuffer:readChar();
	Dlog("cilentType=%d", cType);
	
	-- onServerDigest();
	
	if p.currserver == "baseapp" then
		p.onLogin_baseapp();
	else
		p.onLogin_loginapp();
	end
	
end

-- 登录loginapp成功了
function p.Client_onLoginSuccessfully(streamBuffer)
	local tReceMsg = {};
	Dlog("内部账号名称 = %s",streamBuffer:readStringEndByZero());
	streamBuffer:readChar();
	
	tReceMsg.strAddress = streamBuffer:readStringEndByZero();
	Dlog("网关ip地址 = %s", tostring(tReceMsg.strAddress));
	streamBuffer:readChar();
	
	tReceMsg.nPort = KBEngineBuffer:readInt16(streamBuffer)
	Dlog("网关端口 = %d", tReceMsg.nPort);
	-- streamBuffer:readChar();
	Dlog("二进制流 = %s", KBEngineBuffer:readBlob(streamBuffer));
	streamBuffer:readChar();
	
	p.login_baseapp(true, tReceMsg);
end

--[[
	重登录baseapp失败了
--]]
function p.Client_onReLoginGatewayFailed(streamBuffer)
	local failedcode = 0;
	-- Event.fireAll("onReLoginGatewayFailed", new object[]{failedcode});
end

-- 服务端错误描述导入了
function p.Client_onImportServerErrorsDescr(streamBuffer)
	--[[
	UInt16 size = stream.readUint16();
	while(size > 0)
	{
		size -= 1;
		
		ServerErr e;
		e.id = stream.readUint16();
		e.name = System.Text.Encoding.UTF8.GetString(stream.readBlob());
		e.descr = System.Text.Encoding.UTF8.GetString(stream.readBlob());
		
		serverErrs.Add(e.id, e);

	end
	--]]
end

--[[
	服务端使用优化的方式通知一个实体离开了世界(如果实体是当前玩家则玩家离开了space
	如果是其他实体则是其他实体离开了玩家的AOI)
--]]
function p.Client_onEntityLeaveWorldOptimized(streamBuffer)
	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	p.Client_onEntityLeaveWorld(eid);
end


-- 服务端通知一个实体离开了世界(如果实体是当前玩家则玩家离开了space
-- 如果是其他实体则是其他实体离开了玩家的AOI)

function p.Client_onEntityLeaveWorld( eid)

	local entity = KBEngineEntityManager:GetEntityValue(eid)
	if entity == nil then
		Elog("KBEngine::Client_onEntityLeaveWorld: entity("..eid..") not found!");
		return;
	end
	
	if entity.inWorld then
		entity:leaveWorld();
	end
	
	if KBEngineEntityManager:GetPlayerEntityID() == eid then
		p.clearSpace(false);
		entity.cellMailbox = nil;
	else
		KBEngineEntityManager:SetEntityValue(eid, nil);
		KBEngineEntityManager:SetIDAliasValue(eid, nil);
	end
end


-- 服务端使用优化的方式调用实体方法
function p.Client_onRemoteMethodCallOptimized(nMsgID, tReceMsg, streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	p.onRemoteMethodCall_(eid, streamBuffer);
end

function p.onRemoteMethodCall_(eid, streamBuffer)
	Dlog("-------Client_onRemoteMethodCall-------");
	local entityID = eid;
	
	local tEntity = KBEngineEntityManager:GetEntityValue(entityID);
	if tEntity == nil then
		--获取不到实体数据
		Elog("KBEngine::Client_onRemoteMethodCall: entity("..tostring(entityID)..") not found!");
		return;
	end
	
	local methodUtype = 0;
	if EntityDef.moduledefs[tEntity.className].useMethodDescrAlias then
		methodUtype = KBEngineBuffer:readUint8(streamBuffer);
	else
		methodUtype = KBEngineBuffer:readUint16(streamBuffer);
	end
	
	--
	local methoddata = EntityDef.moduledefs[tEntity.className].idmethods[tostring(methodUtype)];
	
	--
	local argsValues = {};
	for i,v in ipairs(methoddata.args) do
		local strDataType = v["valname"];
		-- local tData = DataType:readData(streamBuffer, strDataType)
		local tData = methoddata.args[i]["createFromStream"](streamBuffer);
		table.insert(argsValues, tData);
	end
	
	if #argsValues ~=  #(methoddata.args) then
		Elog("Client_onRemoteMethodCall args num:%s", #(methoddata.args));
	end
	
	if type(tEntity[methoddata.name]) == "function" then
		tEntity.args = argsValues;
		tEntity[methoddata.name](argsValues);
	end
end

function p.Client_onUpdatePropertysOptimized(nMsgID, tReceMsg, streamBuffer)
	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	p.onUpdatePropertys_(eid, streamBuffer);
end

function p.Client_onUpdatePropertys(streamBuffer)
		
	local eid = KBEngineBuffer:readInt32(streamBuffer);
	p.onUpdatePropertys_(eid, streamBuffer);
end

function p.onUpdatePropertys_(eid, streamBuffer)
	local entity = KBEngineEntityManager:GetEntityValue(eid);
	if entity == nil then
		local entityMessage = KBEngineEntityManager:GetBufferValue(eid);
		if entityMessage ~= nil then
			Elog("KBEngine::Client_onUpdatePropertys: entity("..eid..") not found!");
			return;
		end
		
		--[[
		MemoryStream stream1 = new MemoryStream();
		stream1.wpos = stream.wpos;
		stream1.rpos = stream.rpos - 4;
		Array.Copy(stream.data(), stream1.data(), stream.data().Length);
		_bufferedCreateEntityMessage[eid] = stream1;
		--]]
		return;		
	end
			
	local sm = EntityDef.moduledefs[entity.className];
	local pdatas = sm.idpropertys;

	while(streamBuffer:isReadable()) do
	
		local utype = 0;
		if sm.usePropertyDescrAlias then
			utype = KBEngineBuffer:readUint8(streamBuffer);
		else
			utype = KBEngineBuffer:readUint16(streamBuffer);
		end
	
		local propertydata = pdatas[tostring(utype)];
		utype = propertydata.properUtype;
		local setmethod = propertydata.setmethod;

		local val = propertydata.utype.createFromStream(streamBuffer);
		local oldval = entity.getDefinedProptertyByUType(utype);

		entity.setDefinedProptertyByUType(utype, val);
		if type(setmethod) == "function" then
			setmethod(entity, oldval);
		end
	end
end

--[[
	服务端强制设置了玩家的坐标 
	例如：在服务端使用avatar.position=(0,0,0), 或者玩家位置与速度异常时会强制拉回到一个位置
--]]
function p.Client_onSetEntityPosAndDir(streamBuffer)

	local eid = KBEngineBuffer:readInt32(streamBuffer);
	local entity = KBEngineEntityManager:GetEntityValue(eid);
	if entity == nil then
		Elog("KBEngine::Client_onSetEntityPosAndDir: entity("..eid..") not found!");
		return;
	end
	--[[
	entity.position.x = KBEngineBuffer:readFloat();
	entity.position.y = KBEngineBuffer:readFloat();
	entity.position.z = KBEngineBuffer:readFloat();
	
	entity.direction.x = KBEMath.int82angle((local)KBEngineBuffer:readFloat(), false) * 360 / ((float)System.Math.PI * 2);
	entity.direction.y = KBEMath.int82angle((local)KBEngineBuffer:readFloat(), false) * 360 / ((float)System.Math.PI * 2);
	entity.direction.z = KBEMath.int82angle((local)KBEngineBuffer:readFloat(), false) * 360 / ((float)System.Math.PI * 2);
	
	Vector3 position = (Vector3)entity.getDefinedPropterty("position");
	Vector3 direction = (Vector3)entity.getDefinedPropterty("direction");
	
	position.x = entity.position.x;
	position.y = entity.position.y;
	position.z = entity.position.z;
	
	direction.x = entity.direction.x;
	direction.y = entity.direction.y;
	direction.z = entity.direction.z;
	
	_entityLastLocalPos = entity.position;
	_entityLastLocalDir = entity.direction;
	Event.fireOut("set_direction", new object[]{entity});
	Event.fireOut("set_position", new object[]{entity});
	--]]
end

--[[
	服务端更新玩家的基础位置， 客户端以这个基础位置加上便宜值计算出玩家周围实体的坐标
--]]
function p.Client_onUpdateBasePos(streamBuffer)

	--[[
	_entityServerPos.x = KBEngineBuffer:readFloat(streamBuffer);
	_entityServerPos.y = KBEngineBuffer:readFloat(streamBuffer);
	_entityServerPos.z = KBEngineBuffer:readFloat(streamBuffer);
	--]]
end


function p.Client_onUpdateBasePosXZ(streamBuffer)
	--[[
	_entityServerPos.x = stream.readFloat();
	_entityServerPos.z = stream.readFloat();
	--]]
end

function p.Client_onUpdateData(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	local entity = KBEngineEntityManager:GetEntityValue(eid);
	if entity == nil then
		Elog("KBEngine::Client_onSetEntityPosAndDir: entity("..eid..") not found!");
		return;
	end
	
end

function p.Client_onUpdateData_ypr(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	
	local y = KBEngineBuffer:readInt8(streamBuffer);
	local p = KBEngineBuffer:readInt8(streamBuffer);
	local r = KBEngineBuffer:readInt8(streamBuffer);
	
	-- p._updateVolatileData(eid, 0.0, 0.0, 0.0, y, p, r, -1);
end

function p.Client_onUpdateData_yp(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	
	local y = KBEngineBuffer:readInt8(streamBuffer);
	local p = KBEngineBuffer:readInt8(streamBuffer);
	
	-- p._updateVolatileData(eid, 0.0, 0.0, 0.0, y, p, KBEDATATYPE_BASE.KBE_FLT_MAX, -1);
end

function p.Client_onUpdateData_yr(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	
	local y = KBEngineBuffer:readInt8();
	local r = KBEngineBuffer:readInt8();
	
	-- p._updateVolatileData(eid, 0.0, 0.0, 0.0, y, KBEDATATYPE_BASE.KBE_FLT_MAX, r, -1);
end

function p.Client_onUpdateData_pr(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	
	local p = KBEngineBuffer:readInt8(streamBuffer);
	local r = KBEngineBuffer:readInt8(streamBuffer);
	
	-- p._updateVolatileData(eid, 0.0, 0.0, 0.0, KBEDATATYPE_BASE.KBE_FLT_MAX, p, r, -1);
end

function p.Client_onUpdateData_y(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	
	local y = KBEngineBuffer:readPackY(streamBuffer);
	
	-- p._updateVolatileData(eid, 0.0, 0.0, 0.0, y, KBEDATATYPE_BASE.KBE_FLT_MAX, KBEDATATYPE_BASE.KBE_FLT_MAX, -1);
end

function p.Client_onUpdateData_p(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	
	local p = KBEngineBuffer:readInt8(streamBuffer);
	
	-- p._updateVolatileData(eid, 0.0, 0.0, 0.0, KBEDATATYPE_BASE.KBE_FLT_MAX, p, KBEDATATYPE_BASE.KBE_FLT_MAX, -1);
end

function p.Client_onUpdateData_r(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	
	local r = KBEngineBuffer:readInt8(streamBuffer);
	
	-- p._updateVolatileData(eid, 0.0, 0.0, 0.0, KBEDATATYPE_BASE.KBE_FLT_MAX, KBEDATATYPE_BASE.KBE_FLT_MAX, r, -1);
end

function p.Client_onUpdateData_xz(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	
	local xz = KBEngineBuffer:readPackXZ(streamBuffer);
	
	-- p._updateVolatileData(eid, xz[0], 0.0, xz[1], KBEDATATYPE_BASE.KBE_FLT_MAX, KBEDATATYPE_BASE.KBE_FLT_MAX, KBEDATATYPE_BASE.KBE_FLT_MAX, 1);
end

function p.Client_onUpdateData_xz_ypr(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	
	local xz = KBEngineBuffer:readPackXZ(streamBuffer);

	local y = KBEngineBuffer:readInt8(streamBuffer);
	local p = KBEngineBuffer:readInt8(streamBuffer);
	local r = KBEngineBuffer:readInt8(streamBuffer);
	
	-- p._updateVolatileData(eid, xz[0], 0.0, xz[1], y, p, r, 1);
end

function p.Client_onUpdateData_xz_yp(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	
	local xz = KBEngineBuffer:readPackXZ(streamBuffer);

	local y = KBEngineBuffer:readInt8(streamBuffer);
	local p = KBEngineBuffer:readInt8(streamBuffer);
	
	-- p._updateVolatileData(eid, xz[0], 0.0, xz[1], y, p, KBEDATATYPE_BASE.KBE_FLT_MAX, 1);
end

function p.Client_onUpdateData_xz_yr(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	
	local xz = KBEngineBuffer:readPackXZ(streamBuffer);

	local y = KBEngineBuffer:readInt8(streamBuffer);
	local r = KBEngineBuffer:readInt8(streamBuffer);
	
	-- p._updateVolatileData(eid, xz[0], 0.0, xz[1], y, KBEDATATYPE_BASE.KBE_FLT_MAX, r, 1);
end

function p.Client_onUpdateData_xz_pr(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	
	local xz = KBEngineBuffer:readPackXZ(streamBuffer);

	local p = KBEngineBuffer:readInt8(streamBuffer);
	local r = KBEngineBuffer:readInt8(streamBuffer);
	
	-- p._updateVolatileData(eid, xz[0], 0.0, xz[1], KBEDATATYPE_BASE.KBE_FLT_MAX, p, r, 1);
end

function p.Client_onUpdateData_xz_y(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	local xz = KBEngineBuffer:readPackXZ(streamBuffer);
	local yaw = KBEngineBuffer:readInt8(streamBuffer);
	-- p._updateVolatileData(eid, xz[0], 0.0, xz[1], yaw, KBEDATATYPE_BASE.KBE_FLT_MAX, KBEDATATYPE_BASE.KBE_FLT_MAX, 1);
end

function p.Client_onUpdateData_xz_p(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	
	local xz = KBEngineBuffer:readPackXZ(streamBuffer);

	local p = KBEngineBuffer:readInt8(streamBuffer);
	
	-- p._updateVolatileData(eid, xz[0], 0.0, xz[1], KBEDATATYPE_BASE.KBE_FLT_MAX, p, KBEDATATYPE_BASE.KBE_FLT_MAX, 1);
end

function p.Client_onUpdateData_xz_r(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	
	local xz = KBEngineBuffer:readPackXZ(streamBuffer);

	local r = KBEngineBuffer:readInt8(streamBuffer);
	
	-- p._updateVolatileData(eid, xz[0], 0.0, xz[1], KBEDATATYPE_BASE.KBE_FLT_MAX, KBEDATATYPE_BASE.KBE_FLT_MAX, r, 1);
end

function p.Client_onUpdateData_xyz(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	
	local xz = KBEngineBuffer:readPackXZ(streamBuffer);
	local y = KBEngineBuffer:readPackY(streamBuffer);
	
	-- p._updateVolatileData(eid, xz[0], y, xz[1], KBEDATATYPE_BASE.KBE_FLT_MAX, KBEDATATYPE_BASE.KBE_FLT_MAX, KBEDATATYPE_BASE.KBE_FLT_MAX, 0);
end

function p.Client_onUpdateData_xyz_ypr(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	
	local xz = KBEngineBuffer:readPackXZ(streamBuffer);
	local y = KBEngineBuffer:readPackY(streamBuffer);
	
	local yaw = KBEngineBuffer:readInt8(streamBuffer);
	local p = KBEngineBuffer:readInt8(streamBuffer);
	local r = KBEngineBuffer:readInt8(streamBuffer);
	
	-- p._updateVolatileData(eid, xz[0], y, xz[1], yaw, p, r, 0);
end

function p.Client_onUpdateData_xyz_yp(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(ststreamBufferream);
	
	local xz = KBEngineBuffer:readPackXZ(streamBuffer);
	local y = KBEngineBuffer:readPackY(streamBuffer);
	
	local yaw = KBEngineBuffer:readInt8(streamBuffer);
	local p = KBEngineBuffer:readInt8(streamBuffer);

	-- p._updateVolatileData(eid, xz[0], y, xz[1], yaw, p, KBEDATATYPE_BASE.KBE_FLT_MAX, 0);
end

function p.Client_onUpdateData_xyz_yr(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	
	local xz = KBEngineBuffer:readPackXZ(streamBuffer);
	local y = KBEngineBuffer:readPackY(streamBuffer);
	
	local yaw = KBEngineBuffer:readInt8(streamBuffer);
	local r = KBEngineBuffer:readInt8(streamBuffer);
	
	-- p._updateVolatileData(eid, xz[0], y, xz[1], yaw, KBEDATATYPE_BASE.KBE_FLT_MAX, r, 0);
end

function p.Client_onUpdateData_xyz_pr(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	
	local xz = KBEngineBuffer:readPackXZ(streamBuffer);
	local y = KBEngineBuffer:readPackY(streamBuffer);
	
	local p = KBEngineBuffer:readInt8(streamBuffer);
	local r = KBEngineBuffer:readInt8(streamBuffer);
	
	-- p._updateVolatileData(eid, xz[0], y, xz[1], KBEDATATYPE_BASE.KBE_FLT_MAX, p, r, 0);
end

function p.Client_onUpdateData_xyz_y(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	
	local xz = KBEngineBuffer:readPackXZ(streamBuffer);
	local y = KBEngineBuffer:readPackY(streamBuffer);
	
	local yaw = KBEngineBuffer:readInt8(streamBuffer);
	-- p._updateVolatileData(eid, xz.x, y, xz.y, yaw, KBEDATATYPE_BASE.KBE_FLT_MAX, KBEDATATYPE_BASE.KBE_FLT_MAX, 0);
end

function p.Client_onUpdateData_xyz_p(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	
	local xz = KBEngineBuffer:readPackXZ(streamBuffer);
	local y = KBEngineBuffer:readPackY(streamBuffer);
	
	local p = KBEngineBuffer:readInt8(streamBuffer);
	
	-- p._updateVolatileData(eid, xz[0], y, xz[1], KBEDATATYPE_BASE.KBE_FLT_MAX, p, KBEDATATYPE_BASE.KBE_FLT_MAX, 0);
end

function p.Client_onUpdateData_xyz_r(streamBuffer)

	local eid = p.getAoiEntityIDFromStream(streamBuffer);
	
	local xz = KBEngineBuffer:readPackXZ(streamBuffer);
	local y = KBEngineBuffer:readPackY(streamBuffer);
	
	local r = KBEngineBuffer:readInt8(streamBuffer);
	
	-- p._updateVolatileData(eid, xz[0], y, xz[1], KBEDATATYPE_BASE.KBE_FLT_MAX, KBEDATATYPE_BASE.KBE_FLT_MAX, r, 0);
end

--------------------
--[[
	服务端初始化客户端的spacedata， spacedata请参考API
--]]
function p.Client_initSpaceData(streamBuffer)

	p.clearSpace(false);
	local spaceID = KBEngineBuffer:readUint32(streamBuffer);
	
	while streamBuffer:isReadable() do
	
		local key = KBEngineBuffer:readString(streamBuffer);
		streamBuffer:readChar();
		local val = KBEngineBuffer:readString(streamBuffer);
		streamBuffer:readChar();
		p.Client_setSpaceData(spaceID, key, val);
	end
	
end

--[[
	服务端设置客户端的spacedata， spacedata请参考API
--]]
function p.Client_setSpaceData( spaceID,  key,  value)

	p._spacedatas[key] = value;
	
	if key == "_mapping" then
		p.addSpaceGeometryMapping(spaceID, value);
	end
	
	-- Event.fireOut("onSetSpaceData", new object[]{spaceID, key, value});
end

--[[
	当前space添加了关于几何等信息的映射资源
	客户端可以通过这个资源信息来加载对应的场景
--]]
function p.addSpaceGeometryMapping( uspaceID, respath)

	Dlog("KBEngine::addSpaceGeometryMapping: spaceID("..uspaceID.."), respath("..respath..")!");
	
	p.isLoadedGeometry = true;
	p.spaceID = uspaceID;
	p.spaceResPath = respath;
	-- Event.fireOut("addSpaceGeometryMapping", new object[]{spaceResPath});
end

--[[
	服务端删除客户端的spacedata， spacedata请参考API
--]]
function p.Client_delSpaceData( spaceID,  key)
	p._spacedatas[key] = nil;
	-- Event.fireOut("onDelSpaceData", new object[]{spaceID, key});
end

function p.Client_onEntityEnterWorld(streamBuffer)
	
	local eid =  KBEngineBuffer:readInt32(streamBuffer);
	
	local entity_id = KBEngineEntityManager:GetPlayerEntityID();
	if entity_id > 0 and entity_id ~= eid then
		-- _entityIDAliasIDList.Add(eid);
		p._entityIDAliasIDList[tostring(eid)] = eid;
	end
	
	--
	local uentityType = 0;
	if EntityDef.GetIdmoduledefsCount() > 255 then
		uentityType = KBEngineBuffer:readUint16(streamBuffer);
	else
		uentityType = KBEngineBuffer:readUint8(streamBuffer);
	end
	
	local isOnGound = 1;
	if streamBuffer:isReadable() then
		isOnGound = KBEngineBuffer:readInt8(streamBuffer);
	end
	
	local entityType = EntityDef.idmoduledefs[uentityType].name;

	local entity = KBEngineEntityManager:GetEntityValue(eid);
	if entity == nil then
		
		local entityMessage = KBEngineEntityManager:GetBufferValue(eid);
		if entityMessage == nil then
			Elog("KBEngine::Client_onEntityEnterWorld: entity("..eid..") not found!");
			return;
		end
		
		local scrModule = EntityDef.moduledefs[tostring(entityType)];
		if scrModule == nil then
			Elog("KBEngine::Client_onEntityEnterWorld: not found module("..entityType..")!");
		end
		
		local runclass = scrModule.script;
		if runclass == nil then
			return;
		end
		
		local entity = KBEngineEntityManager:CreateEntity(entityScript);
		entity.id = eid;
		entity:setClassName(entityType);
		
		entity:setCellMailbox(Mailbox());
		
		entity.cellMailbox.id = eid;
		entity.cellMailbox.className = entityType;
		entity.cellMailbox.type = EnumMailbox.MAILBOX_TYPE_CELL;
		
		KBEngineEntityManager:SetEntityValue(eid, entity);
		
		p.Client_onUpdatePropertys(entityMessage);
		
		KBEngineEntityManager:SetBufferValue(eid, nil);
		
		entity.isOnGound = false;
		if isOnGound > 0 then
			entity.isOnGound = true;
		end
		
		entity:__init__();
		entity:enterWorld();
		entity:set_direction(entity:getDefinedPropterty("direction"));
		entity:set_position(entity:getDefinedPropterty("position"));
		
	else
	
		if not entity.inWorld then
			-- // 安全起见， 这里清空一下
			-- // 如果服务端上使用giveClientTo切换控制权
			-- // 之前的实体已经进入世界， 切换后的实体也进入世界， 这里可能会残留之前那个实体进入世界的信息
			
			p._entityIDAliasIDList = {};
			p.clearEntities(false);
			
			KBEngineEntityManager:SetEntityValue(entity.id, entity);
		
			entity:setCellMailbox(Mailbox());
			entity.cellMailbox.id = eid;
			entity.cellMailbox.className = entityType;
			entity.cellMailbox.type = EnumMailbox.MAILBOX_TYPE_CELL;
			
			p._entityServerPos = entity.position;
			
			entity.isOnGound = false;
			if isOnGound > 0 then
				entity.isOnGound = true;
			end
			
			entity:onEnterWorld();
		end
	end
	
end
