-- 游戏网络(消息接收、打包)
KBEngineMessageReive = {};
local p = KBEngineMessageReive;

-- 接收消息
----------------------------
--固定消息接收
function p.MessageReiveLen( nMsgID )
	if nMsgID == EnumKEBMessageID.eLoginGatewayFailed then
		--505	UINT16;
		return 2;
	elseif nMsgID == EnumKEBMessageID.eEntityLeaveWorld then
		--508
		return 8;
	elseif nMsgID == EnumKEBMessageID.eEntityLeaveSpace then
		--510
		return 8;
	elseif nMsgID == EnumKEBMessageID.eEntityDestroyed then
		--512 INT32
		return 4;
	elseif nMsgID == EnumKEBMessageID.eStreamDataCompleted then
		--516
		return 1;
	elseif nMsgID == EnumKEBMessageID.eKicked then
		--517
		return 1;
	end
	return 0;
end


--***************************************************************************************************
-----------------Client---------------------
--[[
	<id>501</id>
	<descr>创建账号成功和失败回调。</descr>
	<arg>UINT16</arg> <!-- 错误码 MERCURY_ERR_SRV_NO_READY:服务器没有准备好, 
	MERCURY_ERR_ACCOUNT_CREATE:创建失败（已经存在）, 
	MERCURY_SUCCESS:账号创建成功 -->
	<arg>UINT8_ARRAY</arg> <!-- 二进制流， 具体由开发者来解析 -->
--]]
function p.Client_onCreateAccountResult(nMsgID, tReceMsg, streamBuffer)
	Dlog("-------Client_onCreateAccountResult-------");
	local nCode = KBEngineBuffer:readUint16(streamBuffer);
	ShowSocketCodeInfo(nCode);
end

--[[
	<id>502</id>
	<descr>客户端登陆到loginapp，服务器返回成功。</descr>
	<arg>STRING</arg> <!-- 内部账号名称 -->
	<arg>STRING</arg> <!-- 网关ip地址 -->
	<arg>UINT16</arg> <!-- 网关端口 -->
	<arg>UINT8_ARRAY</arg> <!-- 二进制流， 具体由开发者来解析 -->
--]]
function p.Client_onLoginSuccessfully(nMsgID, tReceMsg, streamBuffer)
	Dlog("-------Client_onLoginSuccessfully-------");
	KBEngine.Client_onLoginSuccessfully(streamBuffer)
	
end

--[[
	<id>503</id>
	<descr>客户端登陆到loginapp，服务器返回失败。</descr>
	<arg>UINT16</arg> <!-- 错误码 MERCURY_ERR_SRV_NO_READY:服务器没有准备好, 
	MERCURY_ERR_SRV_OVERLOAD:服务器负载过重, 
	MERCURY_ERR_NAME_PASSWORD:用户名或者密码不正确 -->
	<arg>UINT8_ARRAY</arg> <!-- 二进制流， 具体由开发者来解析 -->
--]]
function p.Client_onLoginFailed(nMsgID, tReceMsg, streamBuffer)
	Dlog("-------Client_onLoginFailed-------");
	local nCode = KBEngineBuffer:readUint16(streamBuffer);
	ShowSocketCodeInfo(nCode);
	-- streamBuffer:readChar();
	Dlog("二进制流 = %s", KBEngineBuffer:readBlob(streamBuffer));
	streamBuffer:readChar();
end

--[[
	<id>504</id>
	<descr>		服务器端已经创建了一个与客户端关联的代理Entity
	在登录时也可表达成功回调。</descr>
	<arg>UINT64</arg> <!-- 与entity关联用来短连接身份确认的guid码 -->
	<arg>INT32</arg> <!-- entityID -->
	<arg>STRING</arg> <!-- 脚本类型 -->
--]]
function p.Client_onCreatedProxies(nMsgID, tReceMsg, streamBuffer)
	Dlog("-------Client_onCreatedProxies-------");
	
	local entity_uuid 	= KBEngineBuffer:readInt64(streamBuffer);
	Dlog("UUID = %d", entity_uuid);

	local entityID		= KBEngineBuffer:readInt32(streamBuffer);
	Dlog("EntityID = %d", entityID);
	
	local entityScript		= KBEngineBuffer:readString(streamBuffer);
	Dlog("实体脚本类型 = %s", entityScript);
	streamBuffer:readChar();
	
	--
	if KBEngineEntityManager:ContainsEntityKey(entityID) then
		KBEngine.Client_onEntityDestroyed(entityID);
	end
	
	local entityMessage = KBEngineEntityManager:GetBufferValue(entityID);	
	--
	--当前玩家数据
	KBEngineEntityManager:SetPlayerInfo(entity_uuid, entityID, entityScript);

	--
	local scriptModule = EntityDef.moduledefs[tostring(entityScript)];
	if scriptModule == nil then
		Elog("KBEngine::Client_onCreatedProxies: not found module("..tostring(entityScript)..")!");
	end
	
	local runclass = scriptModule.script;
	if runclass == nil then
		return;
	end
	
	local entity = KBEngineEntityManager:CreateEntity(entityScript);
	entity.id = entityID;
	entity:setClassName(entityScript);
	
	entity:setBaseMailbox(Mailbox());
	
	entity.baseMailbox.id = entityID;
	entity.baseMailbox.className = entityScript;
	entity.baseMailbox.type = EnumMailbox.MAILBOX_TYPE_BASE;

	KBEngineEntityManager:SetEntityValue(entityID, entity);
	
	if entityMessage ~= nil then
		KBEngine.Client_onUpdatePropertys(entityMessage);
		KBEngineEntityManager:SetBufferValue(entityID, nil);
	end
	
	entity:__init__();
	--]]
end

--[[
	<Client::onCreatedEntity>
	<id>513</id>
	<descr>		服务器端已经创建了一个与客户端关联的代理Entity
	在登录时也可表达成功回调。</descr>
	<arg>INT32</arg> <!-- entityID -->
	<arg>STRING</arg> <!-- 脚本类型 -->
	
--]]
function p.Client_onCreatedEntity(nMsgID, tReceMsg, streamBuffer)
	Dlog("-------Client_onCreatedEntity-------");
end

--[[
	<id>505</id>
	<descr>客户端登陆到网关，服务器返回失败。</descr>
	<arg>UINT16</arg> <!-- 错误码 MERCURY_ERR_SRV_NO_READY:服务器没有准备好, 
	MERCURY_ERR_ILLEGAL_LOGIN:非法登录, 
	MERCURY_ERR_NAME_PASSWORD:用户名或者密码不正确 -->
--]]
function p.Client_onLoginGatewayFailed(nMsgID, tReceMsg, streamBuffer)
	Dlog("-------Client_onLoginGatewayFailed-------");
end

--[[
	<id>506</id>
	<descr>调用一个远程方法。</descr>
	<arg>INT32</arg> <!-- entityID -->
	<arg>UINT16</arg> <!-- 方法ID -->
	<arg>UINT8_ARRAY</arg> <!-- 方法参数二进制流， 具体由方法来解析 -->
--]]
function p.Client_onRemoteMethodCall(nMsgID, tReceMsg, streamBuffer)
	Dlog("-------Client_onRemoteMethodCall-------");
	local entityID = KBEngineBuffer:readInt32(streamBuffer);
	KBEngine.onRemoteMethodCall_(entityID, streamBuffer)
end

--[[
	<id>507</id>
	<descr>一个entity进入世界(初次登录时第一个进入世界的是自己这个ENTITY， 其后理论是其他entity， 对比ID来判断)。
	当有entity进入玩家的AOI时则会触发客户端这个接口。 (AOI: area of interest, 也可理解为服务器上可视范围)
	</descr>
	<arg>INT32</arg> <!-- 进入世界的entityID int32 -->
	<arg>UINT32</arg> <!-- spaceID uint32 -->		
--]]
function p.Client_onEntityEnterWorld(nMsgID, tReceMsg, streamBuffer)
	Dlog("-------Client_onEntityEnterWorld-------");
	KBEngine.Client_onEntityEnterWorld(streamBuffer);
end

--[[
	<id>508</id>
	<descr>一个entity进入世界(初次登录时第一个进入世界的是自己这个ENTITY， 其后理论是其他entity， 对比ID来判断)。
	当有entity离开玩家的AOI时则会触发客户端这个接口。
	</descr>
	<arg>INT32</arg> <!-- 进入世界的entityID int32 -->
	<arg>UINT32</arg> <!-- spaceID uint32 -->
--]]
function p.Client_onEntityLeaveWorld(nMsgID, tReceMsg, streamBuffer)
	Dlog("-------Client_onEntityLeaveWorld-------");
end

--[[
	<id>509</id>
	<descr>一个entity进入世界(初次登录时第一个进入世界的是自己这个ENTITY， 其后理论是其他entity， 对比ID来判断)。
	当有entity进入玩家的AOI时则会触发客户端这个接口。 (AOI: area of interest, 也可理解为服务器上可视范围)
	</descr>
	<arg>UINT32</arg> <!-- 一个场景的ID uint32-->
	<arg>INT32</arg> <!-- 进入世界的entityID int32 -->
--]]
function p.Client_onEntityEnterSpace(nMsgID, tReceMsg, streamBuffer)
	Dlog("-------Client_onEntityEnterSpace-------");
	local eid = KBEngineBuffer:readInt32(streamBuffer);
	Dlog("");
	--[[
	sbyte isOnGound = 1;
	
	if(stream.length() > 0)
		isOnGound = stream.readInt8();
	
	Entity entity = null;
	
	if(!entities.TryGetValue(eid, out entity))
	{
		Dbg.ERROR_MSG("KBEngine::Client_onEntityEnterSpace: entity(" + eid + ") not found!");
		return;
	}
	
	entity.isOnGound = isOnGound > 0;
	_entityServerPos = entity.position;
	entity.enterSpace();
	--]]
end

--[[
	<id>510</id>
	<descr>一个entity进入世界(初次登录时第一个进入世界的是自己这个ENTITY， 其后理论是其他entity， 对比ID来判断)。
	当有entity离开玩家的AOI时则会触发客户端这个接口。
	</descr>
	<arg>UINT32</arg> <!-- 一个场景的ID uint32-->
	<arg>INT32</arg> <!-- 进入世界的entityID int32 -->
--]]
function p.Client_onEntityLeaveSpace(nMsgID, tReceMsg, streamBuffer)
	Dlog("-------Client_onEntityLeaveSpace-------");
	
end

--[[
	<id>511</id>
	<descr>某个entity的属性被更新了。
	</descr>
	<arg>INT32</arg> <!-- entityID int32 -->
	<arg>UINT8_ARRAY</arg> <!-- 属性更新包， 需要解析 -->
--]]
function p.Client_onUpdatePropertys(nMsgID, tReceMsg, streamBuffer)
	Dlog("-------Client_onUpdatePropertys-------");
	
	KBEngine.Client_onUpdatePropertys(streamBuffer);
	--[[
	local entityID = KBEngineBuffer:readInt32(streamBuffer);
	Dlog("EntityID = %d", entityID);

	local tEntity = KBEngineEntityManager:GetEntityValue(entityID);
	if tEntity == nil then
		--获取不到实体数据
		if KBEngineEntityManager:ContainsEntityBufferKey(entityID) == nil then
			Elog("KBEngine::Client_onUpdatePropertys: entity("..tostring(entityID)..") not found!");
			return;
		end
		
		
		nMsgID, tReceMsg, streamBuffer1 = new MemoryStream();
		stream1.wpos = stream.wpos;
		stream1.rpos = stream.rpos - 4;
		Array.Copy(stream.data(), stream1.data(), stream.data().Length);
		_bufferedCreateEntityMessage[eid] = stream1;
		
		KBEngineEntityManager:SetBufferValue(entityID, value);
		
		return;
	end
	
	--获取到实体数据
	
	local sm = EntityDef.moduledefs[tEntity.className];
	local pdatas = sm.idpropertys;
	while streamBuffer:isReadable() do
	
		local utype = 0;
		if sm.usePropertyDescrAlias then
			utype = KBEngineBuffer:readUint8(streamBuffer);
		else
			utype = KBEngineBuffer:readUint16(streamBuffer);
		end
	
		local propertydata = pdatas[tostring(utype)];
		utype = propertydata.properUtype;
		-- local setmethod = propertydata.setmethod;

		local val = propertydata.utype.createFromStream(streamBuffer);
		local oldval = tEntity.getDefinedProptertyByUType(utype);

	
		tEntity.setDefinedProptertyByUType(utype, val);
		if setmethod ~= nil then
			setmethod.Invoke(tEntity, new object[]{oldval});
		end
	end
	--]]
end

--[[
	<id>512</id>
	<descr>告诉客户端某个entity销毁了， 此类entity通常是还未onEntityEnterWorld。</descr>
	<arg>INT32</arg> <!-- entityID int32 -->
--]]
function p.Client_onEntityDestroyed(nMsgID, tReceMsg, streamBuffer)
	Dlog("-------Client_onEntityDestroyed-------");
	local entityID = KBEngineBuffer:readInt32(streamBuffer);
	KBEngine.Client_onEntityDestroyed(entityID);
end

--[[
	<id>514</id>
	<descr>服务器告知客户端数据流开始下载。
	</descr>
	<arg>INT16</arg> <!-- 一个下载句柄 INT16 -->
	<arg>STRING</arg> <!-- 描述 -->
	</Client::onStreamDataStarted>
--]]
function p.Client_onStreamDataStarted(nMsgID, tReceMsg, streamBuffer)
	Dlog("-------Client_onStreamDataStarted-------");
end

--[[
	<id>515</id>
	<descr>客户端接收到数据流。
	</descr>
	<arg>INT16</arg> <!-- 一个下载句柄 INT16 -->
	<arg>UINT32</arg> <!-- 本次接收的数据大小 -->
	<arg>UINT8_ARRAY</arg> <!-- 二进制流 -->
--]]
function p.Client_onStreamDataRecv(nMsgID, tReceMsg, streamBuffer)
	Dlog("-------Client_onStreamDataRecv-------");
end

--[[
	<id>516</id>
	<descr>服务器告知客户端数据流下载完成。
	</descr>
	<arg>INT16</arg> <!-- 一个下载句柄 INT16 -->
--]]
function p.Client_onStreamDataCompleted(nMsgID, tReceMsg, streamBuffer)
	Dlog("-------Client_onStreamDataCompleted-------");
end

--[[
	<id>517</id>
	<descr>服务器已经踢出该客户端。
	</descr>
	<arg>UINT16</arg> <!-- 错误码 mercury_errors.xml -->
--]]
function p.Client_onKicked(nMsgID, tReceMsg, streamBuffer)
	Dlog("-------Client_onKicked-------");
end

--[[
	<id>518</id>
	<descr>服务器返回的协议包。
	</descr>
	<arg>UINT8_ARRAY</arg> <!-- 需要解析 -->
--]]
function p.Client_onImportClientMessages(nMsgID, tReceMsg, streamBuffer)
	Dlog("-------Client_onImportClientMessages-------");
	KBEngine.onImportClientMessages(streamBuffer);
end

--[[
	<id>519</id>
	<descr>服务器返回的entitydef数据。
	</descr>
	<arg>UINT8_ARRAY</arg> <!-- 需要解析 -->
--]]
function p.Client_onImportClientEntityDef(nMsgID, tReceMsg, streamBuffer)
	Dlog("-------Client_onImportClientEntityDef-------");	
	KBEngine.onImportClientEntityDef(streamBuffer);

end

--[[
	<id>520</id>
	<descr>服务器向客户端添加几何映射。
	</descr>
	<arg>UINT32</arg> <!-- spaceID -->
	<arg>STRING</arg> <!-- respath -->
--]]
function p.Client_addSpaceGeometryMapping(nMsgID, tReceMsg, streamBuffer)
	Dlog("-------Client_addSpaceGeometryMapping-------");
end

--[[
	<id>521</id>
	<descr>hello的回调。</descr>
--]]
function p.Client_onHelloCB(nMsgID, tReceMsg, streamBuffer)
	Dlog("-------Client_onHelloCB-------");
	KBEngine.Client_onHelloCB(streamBuffer)
end

--[[
	<id>522</id>
	<descr>脚本版本不匹配。</descr>
--]]
function p.Client_onScriptVersionNotMatch(nMsgID, tReceMsg, streamBuffer)
	Dlog("-------Client_onScriptVersionNotMatch-------");
end

--[[
	<id>523</id>
	<descr>引擎版本不匹配。</descr>
--]]
function p.Client_onVersionNotMatch(nMsgID, tReceMsg, streamBuffer)
	Dlog("-------Client_onVersionNotMatch-------");
end

--[[
	重登录baseapp失败了
--]]
function p.Client_onReLoginGatewayFailed(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onReLoginGatewayFailed");	
	KBEngine.Client_onReLoginGatewayFailed(streamBuffer)
end


function p.Client_onImportServerErrorsDescr(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onImportServerErrorsDescr");	
	KBEngine.Client_onImportServerErrorsDescr(streamBuffer)
end


--[[
	服务端使用优化的方式通知一个实体离开了世界(如果实体是当前玩家则玩家离开了space
	如果是其他实体则是其他实体离开了玩家的AOI)
--]]
function p.Client_onEntityLeaveWorldOptimized(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onEntityLeaveWorldOptimized");
	KBEngine.Client_onEntityLeaveWorldOptimized(streamBuffer);
end


-- 服务端使用优化的方式调用实体方法
function p.Client_onRemoteMethodCallOptimized(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onRemoteMethodCallOptimized");
	KBEngine.Client_onRemoteMethodCallOptimized(streamBuffer);

end

--[[
	服务端使用优化的方式更新实体属性数据
--]]
function p.Client_onUpdatePropertysOptimized(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdatePropertysOptimized");
	KBEngine.Client_onUpdatePropertysOptimized(streamBuffer);
end

-- 服务端强制设置了玩家的坐标 
function p.Client_onSetEntityPosAndDir(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onSetEntityPosAndDir");
	KBEngine.Client_onSetEntityPosAndDir(streamBuffer);
	
end

--[[
	服务端更新玩家的基础位置， 客户端以这个基础位置加上便宜值计算出玩家周围实体的坐标
--]]
function p.Client_onUpdateBasePos(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateBasePos");
	KBEngine.Client_onUpdateBasePos(streamBuffer);
end

function p.Client_onUpdateBasePosXZ(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateBasePosXZ");
	KBEngine.Client_onUpdateBasePosXZ(streamBuffer);
end

function p.Client_onUpdateData(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData");
	KBEngine.Client_onUpdateData(streamBuffer);
end

function p.Client_onUpdateData_ypr(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData_ypr");
	KBEngine.Client_onUpdateData_ypr(streamBuffer);
end

function p.Client_onUpdateData_yp(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData_yp");
	KBEngine.Client_onUpdateData_yp(streamBuffer);
end

function p.Client_onUpdateData_yr(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData_yr");
	KBEngine.Client_onUpdateData_yr(streamBuffer);
end

function p.Client_onUpdateData_pr(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData_pr");
	KBEngine.Client_onUpdateData_pr(streamBuffer);
end

function p.Client_onUpdateData_y(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData_y");
	KBEngine.Client_onUpdateData_y(streamBuffer);
end

function p.Client_onUpdateData_p(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData_p");
	KBEngine.Client_onUpdateData_p(streamBuffer);
end

function p.Client_onUpdateData_r(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData_r");
	KBEngine.Client_onUpdateData_r(streamBuffer);
end

function p.Client_onUpdateData_xz(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData_xz");
	KBEngine.Client_onUpdateData_xz(streamBuffer);
end

function p.Client_onUpdateData_xz_ypr(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData_xz_ypr");
	KBEngine.Client_onUpdateData_xz_ypr(streamBuffer);
end

function p.Client_onUpdateData_xz_yp(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData_xz_yp");
	KBEngine.Client_onUpdateData_xz_yp(streamBuffer);
end

function p.Client_onUpdateData_xz_yr(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData_xz_yr");
	KBEngine.Client_onUpdateData_xz_yr(streamBuffer);
end

function p.Client_onUpdateData_xz_pr(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData_xz_pr");
	KBEngine.Client_onUpdateData_xz_pr(streamBuffer);
end

function p.Client_onUpdateData_xz_y(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData_xz_y");
	KBEngine.Client_onUpdateData_xz_y(streamBuffer)
end

function p.Client_onUpdateData_xz_p(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData_xz_p");
	KBEngine.Client_onUpdateData_xz_p(streamBuffer)
end

function p.Client_onUpdateData_xz_r(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData_xz_r");
	KBEngine.Client_onUpdateData_xz_r(streamBuffer)
end

function p.Client_onUpdateData_xyz(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData_xyz");
	KBEngine.Client_onUpdateData_xyz(streamBuffer)
end

function p.Client_onUpdateData_xyz_ypr(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData_xyz_ypr");
	KBEngine.Client_onUpdateData_xyz_ypr(streamBuffer)
end

function p.Client_onUpdateData_xyz_yp(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData_xyz_yp");
	KBEngine.Client_onUpdateData_xyz_yp(streamBuffer)
end

function p.Client_onUpdateData_xyz_yr(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData_xyz_yr");
	KBEngine.Client_onUpdateData_xyz_yr(streamBuffer)
end

function p.Client_onUpdateData_xyz_pr(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData_xyz_pr");
	KBEngine.Client_onUpdateData_xyz_pr(streamBuffer)
end

function p.Client_onUpdateData_xyz_y(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData_xyz_y");
	KBEngine.Client_onUpdateData_xyz_y(streamBuffer)
end

function p.Client_onUpdateData_xyz_p(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData_xyz_p");
	KBEngine.Client_onUpdateData_xyz_p(streamBuffer)
end

function p.Client_onUpdateData_xyz_r(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_onUpdateData_xyz_r");
	KBEngine.Client_onUpdateData_xyz_r(streamBuffer)
end


--[[
	服务端初始化客户端的spacedata， spacedata请参考API
--]]
function p.Client_initSpaceData(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_initSpaceData");
	KBEngine.Client_initSpaceData(streamBuffer)
end

--[[
	服务端设置客户端的spacedata， spacedata请参考API
--]]
function p.Client_setSpaceData(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_setSpaceData");
	KBEngine.Client_setSpaceData(streamBuffer)
end

--[[
	服务端删除客户端的spacedata， spacedata请参考API
--]]
function p.Client_delSpaceData(nMsgID, tReceMsg, streamBuffer)
	Dlog("KBEngine::Client_delSpaceData");
	KBEngine.Client_delSpaceData(streamBuffer)
end



