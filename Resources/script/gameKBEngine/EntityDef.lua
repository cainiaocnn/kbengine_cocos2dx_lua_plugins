-- KBE 实体定义部分
EntityDef = {};
local p = EntityDef;

p.moduledefs = {};
p.datatypes	 = {};
p.iddatatypes = {};
p.datatype2id = {};
p.idmoduledefs = {};
		
local m_bHaveInit = false;

--初始化所有实体Def
function p.InitEnityDef()
	if not m_bHaveInit then
		p.initDataType();
		p.bindMessageDataType();
		m_bHaveInit = true;
	end
end

function p.GetIdmoduledefsCount()
	local count = 0;
	for k,v in pairs(p.idmoduledefs) do
		count = count + 1;
	end
	return count;
end


function p.GetEntityDef(className)
	local tEntity = p.moduledefs[className];
	if tEntity ~= nil then
		return tEntity;
	end
	return nil
end

function p.GetEntityMethod(strclassName , methodName)
	local tEntity = p.moduledefs[strclassName];
	if tEntity ~= nil then
		local tMethods = tEntity.methods;
		if tMethods ~= nil then
			local tMethod = tMethods[tostring(methodName)];
			if tMethod ~= nil then
				return tMethod;
			else
				Dlog("***EntityDef Cann't Find In ClassName=%s Method=%s", tostring(strclassName), tostring(methodName));
			end
		end
	else
		Dlog("***EntityDef Cann't Find ClassName:%s", tostring(strclassName));
	end
	return nil;
end

--Account
function p.initDataType()
	--[[
	m_tEntityDef["Account"] = {};
	m_tEntityDef["Account"]["reqAvatarList"] 	= {methodUtype = 10001, args = 0};
	m_tEntityDef["Account"]["reqCreateAvatar"] 	= {methodUtype = 10002, args = 2};
	m_tEntityDef["Account"]["selectAvatarGame"]	= {methodUtype = 10004, args = 1};
	m_tEntityDef["Account"]["reqRemoveAvatar"]	= {methodUtype = nil, 	args = 1};
	--]]
	
	p.datatypes["UINT8"] = KBEDATATYPE_UINT8();
	p.datatypes["UINT16"] = KBEDATATYPE_UINT16();
	p.datatypes["UINT32"] = KBEDATATYPE_UINT32();
	p.datatypes["UINT64"] = KBEDATATYPE_UINT64();
	
	p.datatypes["INT8"] = KBEDATATYPE_INT8();
	p.datatypes["INT16"] = KBEDATATYPE_INT16();
	p.datatypes["INT32"] = KBEDATATYPE_INT32();
	p.datatypes["INT64"] = KBEDATATYPE_INT64();
	
	p.datatypes["FLOAT"] = KBEDATATYPE_FLOAT();
	p.datatypes["DOUBLE"] = KBEDATATYPE_DOUBLE();
	
	p.datatypes["STRING"] = KBEDATATYPE_STRING();
	p.datatypes["VECTOR2"] = KBEDATATYPE_VECTOR2();
	p.datatypes["VECTOR3"] = KBEDATATYPE_VECTOR3();
	p.datatypes["VECTOR4"] = KBEDATATYPE_VECTOR4();
	p.datatypes["PYTHON"] = KBEDATATYPE_PYTHON();
	p.datatypes["UNICODE"] = KBEDATATYPE_UNICODE();
	p.datatypes["MAILBOX"] = KBEDATATYPE_MAILBOX();
	p.datatypes["BLOB"] = KBEDATATYPE_BLOB();

end

function p.bindMessageDataType()

	-- if(datatype2id.Count > 0)
		-- return;
	
	p.datatype2id["STRING"] = 1;
	p.datatype2id["STD::STRING"] = 1;

	p.iddatatypes["1"] = p.datatypes["STRING"];
	
	p.datatype2id["UINT8"] = 2;
	p.datatype2id["BOOL"] = 2;
	p.datatype2id["DATATYPE"] = 2;
	p.datatype2id["CHAR"] = 2;
	p.datatype2id["DETAIL_TYPE"] = 2;
	p.datatype2id["MAIL_TYPE"] = 2;

	p.iddatatypes["2"] = p.datatypes["UINT8"];
	
	p.datatype2id["UINT16"] = 3;
	p.datatype2id["UNSIGNED SHORT"] = 3;
	p.datatype2id["SERVER_ERROR_CODE"] = 3;
	p.datatype2id["ENTITY_TYPE"] = 3;
	p.datatype2id["ENTITY_PROPERTY_UID"] = 3;
	p.datatype2id["ENTITY_METHOD_UID"] = 3;
	p.datatype2id["ENTITY_SCRIPT_UID"] = 3;
	p.datatype2id["DATATYPE_UID"] = 3;

	p.iddatatypes["3"] = p.datatypes["UINT16"];
	
	p.datatype2id["UINT32"] = 4;
	p.datatype2id["UINT"] = 4;
	p.datatype2id["UNSIGNED INT"] = 4;
	p.datatype2id["ARRAYSIZE"] = 4;
	p.datatype2id["SPACE_ID"] = 4;
	p.datatype2id["GAME_TIME"] = 4;
	p.datatype2id["TIMER_ID"] = 4;

	p.iddatatypes["4"] = p.datatypes["UINT32"];
	
	p.datatype2id["UINT64"] = 5;
	p.datatype2id["DBID"] = 5;
	p.datatype2id["COMPONENT_ID"] = 5;

	p.iddatatypes["5"] = p.datatypes["UINT64"];
	
	p.datatype2id["INT8"] = 6;
	p.datatype2id["COMPONENT_ORDER"] = 6;

	p.iddatatypes["6"] = p.datatypes["INT8"];
	
	p.datatype2id["INT16"] = 7;
	p.datatype2id["SHORT"] = 7;

	p.iddatatypes["7"] = p.datatypes["INT16"];
	
	p.datatype2id["INT32"] = 8;
	p.datatype2id["INT"] = 8;
	p.datatype2id["ENTITY_ID"] = 8;
	p.datatype2id["CALLBACK_ID"] = 8;
	p.datatype2id["COMPONENT_TYPE"] = 8;

	p.iddatatypes["8"] = p.datatypes["INT32"];
	
	p.datatype2id["INT64"] = 9;

	p.iddatatypes["9"] = p.datatypes["INT64"];
	
	p.datatype2id["PYTHON"] = 10;
	p.datatype2id["PY_DICT"] = 10;
	p.datatype2id["PY_TUPLE"] = 10;
	p.datatype2id["PY_LIST"] = 10;
	p.datatype2id["MAILBOX"] = 10;

	p.iddatatypes["10"] = p.datatypes["PYTHON"];
	
	p.datatype2id["BLOB"] = 11;

	p.iddatatypes["11"] = p.datatypes["BLOB"];
	
	p.datatype2id["UNICODE"] = 12;

	p.iddatatypes["12"] = p.datatypes["UNICODE"];
	
	p.datatype2id["FLOAT"] = 13;

	p.iddatatypes["13"] = p.datatypes["FLOAT"];
	
	p.datatype2id["DOUBLE"] = 14;

	p.iddatatypes["14"] = p.datatypes["DOUBLE"];
	
	p.datatype2id["VECTOR2"] = 15;

	p.iddatatypes["15"] = p.datatypes["VECTOR2"];
	
	p.datatype2id["VECTOR3"] = 16;

	p.iddatatypes["16"] = p.datatypes["VECTOR3"];
	
	p.datatype2id["VECTOR4"] = 17;

	p.iddatatypes["17"] = p.datatypes["VECTOR4"];
	
	p.datatype2id["FIXED_DICT"] = 18;
	-- // 这里不需要绑定，FIXED_DICT需要根据不同类型实例化动态得到id
	-- //iddatatypes[18] = p.datatypes["FIXED_DICT"];
	
	p.datatype2id["ARRAY"] = 19;
	-- // 这里不需要绑定，ARRAY需要根据不同类型实例化动态得到id
	-- //iddatatypes[19] = p.datatypes["ARRAY"];

end
