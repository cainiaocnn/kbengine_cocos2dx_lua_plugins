-- KBE 实体管理部分
KBEngineEntityManager = {};
local p = KBEngineEntityManager;

local m_PlayerEntityID 		= nil;
local m_PlayerEntityUUID 	= nil;
local m_PlayerEntityType 	= nil;


--客户端存储实体数据表
local m_tEntities = {};

--实体创建信息数据
local m_bufferedCreateEntityMessage = {};

--
local m_entityIDAliasIDList = {};
local m_entityIDAliasIDList_Count = 0;

--是否客户端已经存在该实体
function p:ContainsEntityKey(nEid)
	if m_tEntities[tostring(nEid)] ~= nil then
		return true;
	end
	return false;
end

--获取实体数据
function p:GetEntityValue(nEid)
	return m_tEntities[tostring(nEid)];
end

--设置实体信息数据
function p:SetEntityValue(nEid, value)
	m_tEntities[tostring(nEid)] = nil;
	m_tEntities[tostring(nEid)] = value;
end

function p:ClearButPlayer(bAll)
	if not bAll then
		for k, v in pairs(m_tEntities) do
			if tonumber(k) ~= m_PlayerEntityID then
				m_tEntities[k] = nil;
			end
		end
	else
		m_tEntities = {};
	end
end

--实体Buffer信息数据
function p:ContainsEntityBufferKey(nEid)
	if m_bufferedCreateEntityMessage[tostring(nEid)] ~= nil then
		return true;
	end
	return false;
end

--获取实体Buffer信息数据
function p:GetBufferValue(nEid)
	return m_bufferedCreateEntityMessage[tostring(nEid)]
end

--设置实体Buffer信息数据
function p:SetBufferValue(nEid, value)
	m_bufferedCreateEntityMessage[tostring(nEid)] = nil;
	m_bufferedCreateEntityMessage[tostring(nEid)] = value;
end

--
function p:GetIDAliasValue(nEid)
	return m_entityIDAliasIDList[tostring(nEid)];
end

function p:SetIDAliasValue(nEid, value)
	if value ~= nil then
		m_entityIDAliasIDList_Count = m_entityIDAliasIDList_m_entityIDAliasIDList + 1;
	else
		if m_entityIDAliasIDList_Count > 0 then
			m_entityIDAliasIDList_Count = m_entityIDAliasIDList_Count - 1;
		end
	end
	m_entityIDAliasIDList[tostring(nEid)] = value;
end

function p:GetIDAliasCount()
	return m_entityIDAliasIDList_Count;
end

function p:IDAliasValueClear()
	m_entityIDAliasIDList_Count = 0;
	m_entityIDAliasIDList = {};
end

--设置游戏玩家
function p:SetPlayerInfo(entity_uuid, entity_id, entity_type)
	m_PlayerEntityUUID 	= entity_uuid;
	m_PlayerEntityID 	= entity_id;
	m_PlayerEntityType 	= entity_type;
end

function p:GetPlayerEntityID()
	return m_PlayerEntityID;
end

function p:GetPlayerEntity()
	local entity = m_tEntities[tostring(m_PlayerEntityID)];
	if entity == nil then
		Elog("lua file:%s error func:%s", "KBEngineEntityManager","GetPlayerEntity");
	end
	return entity;
end

--创建实体数据
function p:CreateEntity(className)
	local tEntity = {};
	if className == "Account" then
		return Account();
	elseif className == "Avatar" then
		return Avatar();
	end
	return tEntity;
end