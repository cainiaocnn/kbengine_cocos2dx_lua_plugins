-- KBE 数据类型
DataType = {};
local p = DataType;

EnumDataType = 
{
	UINT8 =1,
	UINT16 = 2,
	UINT32 = 4,
	UINT64 = 8,

	INT8 = 1,
	INT16 =	2,
	INT32 =	4,
	INT64 =	8,
	-- FLOAT =	4,
	-- DOUBLE = 8,
	-- VECTOR2 = 12,
	-- VECTOR3 = 16,
	-- VECTOR4 = 20,
}

function p:DataLength(strDataType, value, keys)
	local dataLen = 0;
	if EnumDataType[strDataType] ~= nil then
		dataLen = EnumDataType[strDataType];
	elseif strDataType == "UNICODE" then
		dataLen = 4 + string.len(value);
	else
		Elog("**********DataType:DataLength  %s**************", strDataType);
	end
	return dataLen;
end

function p:writeData(streamBuffer, strDataType, value, keys)
	if strDataType == "INT8" then
		KBEngineBuffer:writeInt8(streamBuffer, value);
	elseif strDataType == "INT16" then
		KBEngineBuffer:writeInt16(streamBuffer, value);
	elseif strDataType == "INT32" then
		KBEngineBuffer:writeInt32(streamBuffer, value);
	elseif strDataType == "INT64" then
		KBEngineBuffer:writeInt64(streamBuffer, value);
	elseif strDataType == "UINT8" then
		KBEngineBuffer:writeUint8(streamBuffer, value);
	elseif strDataType == "UINT16" then
		KBEngineBuffer:writeUint16(streamBuffer, value);
	elseif strDataType == "UINT32" then
		KBEngineBuffer:writeUint32(streamBuffer, value);
	elseif strDataType == "UINT64" then
		KBEngineBuffer:writeUint64(streamBuffer, value);
	elseif strDataType == "UNICODE" then
		KBEngineBuffer:writeBlob(streamBuffer, value);
	else
		Elog("********UnKnowDataType:%s************",strDataType);
	end
end

function p:readData(streamBuffer, strDataType)
	if strDataType == "INT8" then
		return KBEngineBuffer:readInt8(streamBuffer, value);
	elseif strDataType == "INT16" then
		return KBEngineBuffer:readInt16(streamBuffer, value);
	elseif strDataType == "INT32" then
		return KBEngineBuffer:readInt32(streamBuffer, value);
	elseif strDataType == "INT64" then
		return KBEngineBuffer:readInt64(streamBuffer, value);
	elseif strDataType == "UINT8" then
		return KBEngineBuffer:readUint8(streamBuffer, value);
	elseif strDataType == "UINT16" then
		return KBEngineBuffer:readUint16(streamBuffer, value);
	elseif strDataType == "UINT32" then
		return KBEngineBuffer:readUint32(streamBuffer, value);
	elseif strDataType == "UINT64" then
		return KBEngineBuffer:readUint64(streamBuffer, value);
	elseif strDataType == "UNICODE" then
		return KBEngineBuffer:readBlob(streamBuffer, value);
	else
		Elog("********UnKnowDataType:%s************",strDataType);
	end
	return 0;
end

--[[
	entitydef所支持的基本数据类型
	改模块中的类抽象出了所有的支持类型并提供了这些类型的数据序列化成二进制数据与反序列化操作
	(主要用于网络通讯的打包与解包)
--]]
------------------------------------------------------------------------------------
function p:CreateDataObject(strDataType)
	local t = {};
	if strDataType == "UINT8" then
		t = KBEDATATYPE_UINT8();
	elseif strDataType == "UINT16" then
		t = KBEDATATYPE_UINT16();
	elseif strDataType == "UINT32" then
		t = KBEDATATYPE_UINT32();
	elseif strDataType == "UINT64" then
		t = KBEDATATYPE_UINT64();
		
	elseif strDataType == "INT8" then
		t = KBEDATATYPE_INT8();
	elseif strDataType == "INT16" then
		t = KBEDATATYPE_INT16();
	elseif strDataType == "INT32" then
		t = KBEDATATYPE_INT32();
	elseif strDataType == "INT64" then
		t = KBEDATATYPE_INT64();
	
	elseif strDataType == "STRING" then
		t = KBEDATATYPE_STRING();
	elseif strDataType == "UNICODE" then
		t = KBEDATATYPE_UNICODE();	
	elseif strDataType == "FLOAT" then
		t = KBEDATATYPE_FLOAT();
	elseif strDataType == "DOUBLE" then
		t = KBEDATATYPE_DOUBLE();
	elseif strDataType == "PYTHON" then
		t = KBEDATATYPE_PYTHON();
	elseif strDataType == "PY_DICT" then
		Wlog("******%s,The DataType is Not Def", strDataType);
	elseif strDataType == "PY_TUPLE" then
		Wlog("******%s,The DataType is Not Def", strDataType);
	elseif strDataType == "PY_LIST" then
		Wlog("******%s,The DataType is Not Def", strDataType);
	elseif strDataType == "MAILBOX" then
		t = KBEDATATYPE_MAILBOX();
	elseif strDataType == "BLOB" then
		-- Wlog("******%s,The DataType is Not Def", strDataType);
		t = KBEDATATYPE_BLOB();
	elseif strDataType == "VECTOR2" then
		t = KBEDATATYPE_VECTOR2();
	elseif strDataType == "VECTOR3" then
		t = KBEDATATYPE_VECTOR3();
	elseif strDataType == "VECTOR4" then
		t = KBEDATATYPE_VECTOR4();
	else
		Wlog("******%s,The DataType is Not Def", strDataType);	
	end
	return t;
end
------------------------------------------------------------------------------------
function KBEDATATYPE_BASE()
	local t = class("KBEDATATYPE_BASE");
	function t.isNumeric(v)
		return nil;
	end

	function t.bind()
	end
	
	function t.createFromStream(streamBuffer)
		return nil;
	end
	
	function t.addToStream(streamBuffer, v)
	end
	
	function t.parseDefaultValStr(v)
		return nil;
	end
	
	function t.isSameType(v)
		if v == nil then
			return true
		end
		return false;
	end
end

-----------------
function KBEDATATYPE_INT8()
	
	local superKBEDATATYPE = KBEDATATYPE_BASE();
	local t = class("KBEDATATYPE_INT8", superKBEDATATYPE);
	
	function t.createFromStream(streamBuffer)
		return KBEngineBuffer:readInt8(streamBuffer);
	end

	function t.addToStream(streamBuffer, v)
		KBEngineBuffer:writeInt8(streamBuffer,v);
	end	

	function t.parseDefaultValStr(v)
		local ret = 0;
		-- SByte.TryParse(v, out ret);
		Elog("KBEDATATYPE_INT8:parseDefaultValStr");
		return ret;
	end
	
	function t.isSameType(v)
		Elog("KBEDATATYPE_INT8:isSameType");
		--[[
		if (!KBEDATATYPE_BASE.isNumeric (v))
			return false;
		decimal v1 = Convert.ToDecimal (v);
		return v1 >= sbyte.MinValue && v1 <= sbyte.MaxValue;
		--]]
	end
	
	return t;
	
end
	
---------
function KBEDATATYPE_INT16()
	
	local superKBEDATATYPE = KBEDATATYPE_BASE();
	local t = class("KBEDATATYPE_INT16", superKBEDATATYPE);

	function t.createFromStream(streamBuffer)
		return KBEngineBuffer:readInt16();
	end
	
	function t.addToStream(streamBuffer, v)
		KBEngineBuffer:writeInt16(streamBuffer, v);
	end
	
	function t.parseDefaultValStr(v)
		local ret = 0;
		-- Int16.TryParse(v, out ret);
		Elog("KBEDATATYPE_INT16:parseDefaultValStr");
		return ret;
	end
	
	function t.isSameType(v)
		--[[
		if (!KBEDATATYPE_BASE.isNumeric (v))
			return false;

		decimal v1 = Convert.ToDecimal (v);
		return v1 >= Int16.MinValue && v1 <= Int16.MaxValue;
		--]]
		Elog("KBEDATATYPE_INT16:isSameType");
	end
	
	return t;
end

function KBEDATATYPE_INT32()
	
	local superKBEDATATYPE = KBEDATATYPE_BASE();
	local t = class("KBEDATATYPE_INT32", superKBEDATATYPE);

	function t.createFromStream(streamBuffer)
		return KBEngineBuffer:readInt32(streamBuffer);
	end
	
	function t.addToStream(streamBuffer, v)
		KBEngineBuffer:writeInt32(streamBuffer, v);
	end
	
	function t.parseDefaultValStr(v)
		local ret = 0;
		-- Int32.TryParse(v, out ret);
		Elog("KBEDATATYPE_INT32:parseDefaultValStr");
		return ret;
	end
	
	function t.isSameType(v)
		--[[
		if (!KBEDATATYPE_BASE.isNumeric (v))
			return false;

		decimal v1 = Convert.ToDecimal (v);
		return v1 >= Int32.MinValue && v1 <= Int32.MaxValue;
		--]]
		Elog("KBEDATATYPE_INT32:isSameType");
	end
	
	return t;
end

function KBEDATATYPE_INT64()
	
	local superKBEDATATYPE = KBEDATATYPE_BASE();
	local t = class("KBEDATATYPE_INT64", superKBEDATATYPE);

	function t.createFromStream(streamBuffer)
		return KBEngineBuffer:readInt64(streamBuffer);
	end
	
	function t.addToStream(streamBuffer, v)
		KBEngineBuffer:writeInt64(streamBuffer, v);
	end
	
	function t.parseDefaultValStr(v)
		local ret = 0;
		-- Int64.TryParse(v, out ret);
		return ret;
	end
	
	function t.isSameType(v)
		--[[
		if (!KBEDATATYPE_BASE.isNumeric (v))
			return false;

		decimal v1 = Convert.ToDecimal (v);
		return v1 >= Int64.MinValue && v1 <= Int64.MaxValue;
		--]]
	end
	
	return t;
end

function KBEDATATYPE_UINT8()
	
	local superKBEDATATYPE = KBEDATATYPE_BASE();
	local t = class("KBEDATATYPE_UINT8", superKBEDATATYPE);

	function t.createFromStream(streamBuffer)
		return KBEngineBuffer:readUint8(streamBuffer);
	end
	
	function t.addToStream(streamBuffer, v)
		KBEngineBuffer:writeUint8(streamBuffer, v);
	end
	
	function t.parseDefaultValStr(v)
	
		local ret = 0;
		-- Byte.TryParse(v, out ret);
		return ret;
	end
	
	function t.isSameType(v)
		--[[
		if (!KBEDATATYPE_BASE.isNumeric (v))
			return false;

		decimal v1 = Convert.ToDecimal (v);
		return v1 >= Byte.MinValue && v1 <= Byte.MaxValue;
		--]]
	end
	
	return t;
end

function KBEDATATYPE_UINT16()
	
	local superKBEDATATYPE = KBEDATATYPE_BASE();
	local t = class("KBEDATATYPE_UINT16", superKBEDATATYPE);

	function t.createFromStream(streamBuffer)
		return KBEngineBuffer:readUint16(streamBuffer);
	end
	
	function t.addToStream(streamBuffer, v)
		KBEngineBuffer:writeUint16(streamBuffer, v);
	end
	
	function t.parseDefaultValStr(v)
		local ret = 0;
		-- UInt16.TryParse(v, out ret);
		return ret;
	end
	
	function t.isSameType(v)
		--[[
		if (!KBEDATATYPE_BASE.isNumeric (v))
			return false;

		decimal v1 = Convert.ToDecimal (v);
		return v1 >= UInt16.MinValue && v1 <= UInt16.MaxValue;
		--]]
	end
	
	return t;
end

function KBEDATATYPE_UINT32()
	
	local superKBEDATATYPE = KBEDATATYPE_BASE();
	local t = class("KBEDATATYPE_UINT32", superKBEDATATYPE);

	function t.createFromStream(streamBuffer)
		return KBEngineBuffer:readUint32(streamBuffer);
	end
	
	function t.addToStream(streamBuffer, v)
		KBEngineBuffer:writeUint32(streamBuffer, v);
	end
	
	function t.parseDefaultValStr(v)
		local ret = 0;
		-- UInt32.TryParse(v, out ret);
		return ret;
	end
	
	function t.isSameType(v)
		--[[
		if (!KBEDATATYPE_BASE.isNumeric (v))
			return false;

		decimal v1 = Convert.ToDecimal (v);
		return v1 >= UInt32.MinValue && v1 <= UInt32.MaxValue;
		--]]
	end
	
	return t;
end

function KBEDATATYPE_UINT64()
	
	local superKBEDATATYPE = KBEDATATYPE_BASE();
	local t = class("KBEDATATYPE_UINT64", superKBEDATATYPE);

	function t.createFromStream(streamBuffer)
		return KBEngineBuffer:readUint64(streamBuffer);
	end
	
	function t.addToStream(streamBuffer, v)
		KBEngineBuffer:writeUint64(streamBuffer, v);
	end
	
	function t.parseDefaultValStr(v)
		local ret = 0;
		-- UInt64.TryParse(v, out ret);
		return ret;
	end
	
	function t.isSameType(v)
		--[[
		if (!KBEDATATYPE_BASE.isNumeric (v))
			return false;

		decimal v1 = Convert.ToDecimal (v);
		return v1 >= UInt64.MinValue && v1 <= UInt64.MaxValue;
		--]]
	end
	
	return t;
end

function KBEDATATYPE_FLOAT()
	
	local superKBEDATATYPE = KBEDATATYPE_BASE();
	local t = class("KBEDATATYPE_FLOAT", superKBEDATATYPE);

	function t.createFromStream(streamBuffer)
		return KBEngineBuffer:readFloat(streamBuffer);
	end
	
	function t.addToStream(streamBuffer, v)
		KBEngineBuffer:writeFloat(streamBuffer, v);
	end
	
	function t.parseDefaultValStr(v)
		local ret = 0;
		-- float.TryParse(v, out ret);
		return ret;
	end
	
	function t.isSameType(v)
		--[[
		if(v is float)
			return (float)v >= float.MinValue && (float)v <= float.MaxValue;
		else if(v is double)
			return (double)v >= float.MinValue && (double)v <= float.MaxValue;
		
		return false;
		--]]
	end
	
	return t;
end

function KBEDATATYPE_DOUBLE()
	
	local superKBEDATATYPE = KBEDATATYPE_BASE();
	local t = class("KBEDATATYPE_DOUBLE", superKBEDATATYPE);

	function t.createFromStream(streamBuffer)
		return KBEngineBuffer:readDouble(streamBuffer);
	end
	
	function t.addToStream(streamBuffer, v)
		KBEngineBuffer:writeDouble(streamBuffer, v);
	end
	
	function t.parseDefaultValStr(v)
		local ret = 0.0;
		-- double.TryParse(v, out ret);
		return ret;
	end
	
	function t.isSameType(v)
		--[[
		if(v is float)
			return (float)v >= double.MinValue && (float)v <= double.MaxValue;
		else if(v is double)
			return (double)v >= double.MinValue && (double)v <= double.MaxValue;
		
		return false;
		--]]
	end
	
	return t;
end

function KBEDATATYPE_STRING()
	
	local superKBEDATATYPE = KBEDATATYPE_BASE();
	local t = class("KBEDATATYPE_STRING", superKBEDATATYPE);

	function t.createFromStream(streamBuffer)
		local data = KBEngineBuffer:readString(streamBuffer);
		streamBuffer:readChar();
		return data;
	end
	
	function t.addToStream(streamBuffer, v)
		KBEngineBuffer:writeString(streamBuffer, v);
	end
	
	function t.parseDefaultValStr(v)
		return v;
	end
	
	function t.isSameType(v)
		--return v != null && v.GetType() == typeof(string);
	end
	
	return t;
end

function KBEDATATYPE_VECTOR2()
	
	local superKBEDATATYPE = KBEDATATYPE_BASE();
	local t = class("KBEDATATYPE_VECTOR2", superKBEDATATYPE);

	function t.createFromStream(streamBuffer)
		local size = KBEngineBuffer:readUint32(streamBuffer);
		if 2 ~= size then
			Dbg.ERROR_MSG("KBEDATATYPE_VECTOR2::createFromStream: size(%d) is error!", size);
		end
		local v1 = KBEngineBuffer:readFloat(streamBuffer);
		local v2 = KBEngineBuffer:readFloat(streamBuffer);
		return Vector2(v1, v2);
	end
	
	function t.addToStream(streamBuffer, v)
		KBEngineBuffer:writeUint32(streamBuffer,2);
		KBEngineBuffer:writeFloat(streamBuffer, v.x);
		KBEngineBuffer:writeFloat(streamBuffer, v.y);
	end
	
	function t.parseDefaultValStr(v)
		return Vector2(0, 0);
	end
	
	function t.isSameType(v)
		-- return v != null && v.GetType() == typeof(Vector2);
	end
	
	return t;
end

function KBEDATATYPE_VECTOR3()
	
	local superKBEDATATYPE = KBEDATATYPE_BASE();
	local t = class("KBEDATATYPE_VECTOR3", superKBEDATATYPE);

	function t.createFromStream(streamBuffer)
		local size = KBEngineBuffer:readUint32(streamBuffer);
		if 3 ~= size then
			Elog("KBEDATATYPE_VECTOR3::createFromStream: size(%d) is error!", size);
		end	
		local v1 = KBEngineBuffer:readFloat(streamBuffer);
		local v2 = KBEngineBuffer:readFloat(streamBuffer); 
		local v3 = KBEngineBuffer:readFloat(streamBuffer);
		return Vector3(v1,v2,v3);
	end
	
	function t.addToStream(streamBuffer, v)
		KBEngineBuffer:writeUint32(streamBuffer, 3);
		KBEngineBuffer:writeFloat(streamBuffer, v.x);
		KBEngineBuffer:writeFloat(streamBuffer, v.y);
		KBEngineBuffer:writeFloat(streamBuffer, v.z);
	end
	
	function t.parseDefaultValStr(v)
		return Vector3(0, 0, 0);
	end
	
	function t.isSameType(v)
		-- return v != null && v.GetType() == typeof(Vector3);
	end
	
	return t;
end

function KBEDATATYPE_VECTOR4()
	
	local superKBEDATATYPE = KBEDATATYPE_BASE();
	local t = class("KBEDATATYPE_VECTOR4", superKBEDATATYPE);

	function t.createFromStream(streamBuffer)
		local size = KBEngineBuffer:readUint32(streamBuffer);
		if 4 ~= size then
			Elog("KBEDATATYPE_VECTOR4::createFromStream: size(%d) is error!", size);
		end
		local v1 = KBEngineBuffer:readFloat(streamBuffer);
		local v2 = KBEngineBuffer:readFloat(streamBuffer); 
		local v3 = KBEngineBuffer:readFloat(streamBuffer);
		local v4 = KBEngineBuffer:readFloat(streamBuffer);
		return Vector4(v1,v2,v3,v4);
	end
	
	function t.addToStream(streamBuffer, v)
		KBEngineBuffer:writeUint32(streamBuffer, 4);
		KBEngineBuffer:writeFloat(streamBuffer, v.x);
		KBEngineBuffer:writeFloat(streamBuffer, v.y);
		KBEngineBuffer:writeFloat(streamBuffer, v.z);
		KBEngineBuffer:writeFloat(streamBuffer, v.w);
	end
	
	function t.parseDefaultValStr(v)
		return Vector4(0, 0, 0, 0);
	end
	
	function t.isSameType(v)
		-- return v != null && v.GetType() == typeof(Vector4);
	end
	
	return t;
end

function KBEDATATYPE_PYTHON()
	
	local superKBEDATATYPE = KBEDATATYPE_BASE();
	local t = class("KBEDATATYPE_PYTHON", superKBEDATATYPE);

	function t.createFromStream(streamBuffer)
		return KBEngineBuffer:readBlob(streamBuffer);
	end
	
	function t.addToStream(streamBuffer, v)
		KBEngineBuffer:writeBlob(streamBuffer, v);
	end
	
	function t.parseDefaultValStr(v)
		return "";
	end
	
	function t.isSameType(v)
		-- return v != null && v.GetType() == typeof(byte[]);
	end
	
	return t;
end

function KBEDATATYPE_UNICODE()
	
	local superKBEDATATYPE = KBEDATATYPE_BASE();
	local t = class("KBEDATATYPE_UNICODE", superKBEDATATYPE);

	function t.createFromStream(streamBuffer)
		return KBEngineBuffer:readBlob(streamBuffer);
	end

	function t.addToStream(streamBuffer, v)
		KBEngineBuffer:writeBlob(streamBuffer, v);
	end
	
	function t.parseDefaultValStr(v)
		return "";
	end
	
	function t.isSameType(v)
		-- return v != null && v.GetType() == typeof(string);
	end
	
	return t;
end

function KBEDATATYPE_MAILBOX()
	
	local superKBEDATATYPE = KBEDATATYPE_BASE();
	local t = class("KBEDATATYPE_MAILBOX", superKBEDATATYPE);

	function t.createFromStream(streamBuffer)
		return KBEngineBuffer:readBlob(streamBuffer);
	end
	
	function t.addToStream(streamBuffer, v)
		KBEngineBuffer:writeBlob(streamBuffer, v);
	end
	
	function t.parseDefaultValStr(v)
		return "";
	end
	
	function t.isSameType(v)
		-- return v != null && v.GetType() == typeof(byte[]);
	end
	
	return t;
end

function KBEDATATYPE_BLOB()
	
	local superKBEDATATYPE = KBEDATATYPE_BASE();
	local t = class("KBEDATATYPE_BLOB", superKBEDATATYPE);

	function t.createFromStream(streamBuffer)
		return KBEngineBuffer:readBlob(streamBuffer);
	end
	
	function t.addToStream(streamBuffer, v)
		KBEngineBuffer:writeBlob(streamBuffer, v);
	end
	
	function t.parseDefaultValStr(v)
		return "";
	end
	
	function t.isSameType(v)
		-- return v != null && v.GetType() == typeof(byte[]);
	end
	
	return t;
end

function KBEDATATYPE_ARRAY()
	
	local superKBEDATATYPE = KBEDATATYPE_BASE();
	local t = class("KBEDATATYPE_ARRAY", superKBEDATATYPE);

	t.vtype = {};
	
	function t.bind()
		-- Dlog(tostring(t.vtype));
		if tostring(t.vtype) == "KBEngine.KBEDATATYPE_BASE" then
			t.vtype.bind();
		else
			if EntityDef.iddatatypes[tostring(t.vtype)] ~= nil then
				t.vtype = EntityDef.iddatatypes[tostring(t.vtype)];
			end
		end
	end
	
	function t.createFromStream(streamBuffer)
		--
		local size = KBEngineBuffer:readUint32(streamBuffer);
		local datas = {};
		for i=1, size do
			local value = t.vtype["createFromStream"](streamBuffer);
			table.insert(datas, value);
		end;
		return datas;
	end
	
	function t.addToStream(streamBuffer, v)
		--
		KBEngineBuffer:writeUint32(streamBuffer, #v);
		for i=1, #v do
			t.vtype["addToStream"](streamBuffer, v[i]);
		end
		--]]
	end
	
	function t.parseDefaultValStr(v)
		return "";
	end
	
	function t.isSameType(v)
		--[[
		if(vtype.GetType ().BaseType.ToString() != "KBEngine.KBEDATATYPE_BASE")
		
			Dbg.ERROR_MSG(string.Format("KBEDATATYPE_ARRAY::isSameType: has not bind!"));
			return false;
		end

		if(v == null || v.GetType() != typeof(List<object>))
		
			return false;
		end
		
		for(int i=0; i<((List<object>)v).Count; i++)
		
			if(!((KBEDATATYPE_BASE)vtype).isSameType(((List<object>)v)[i]))
			
				return false;
		end
		--]]
		return true;
	end
	
	return t;
end

function KBEDATATYPE_FIXED_DICT()
	
	local superKBEDATATYPE = KBEDATATYPE_BASE();
	local t = class("KBEDATATYPE_FIXED_DICT", superKBEDATATYPE);

	t.implementedBy = "";
	t.dicttype = {};
	t.dicttype.Keys = {};
	function t.bind()
		-- for itemkey, v in pairs(t.dicttype) do
		for _, itemkey in pairs(t.dicttype.Keys) do
			local sType = tostring(t.dicttype[itemkey]);	
			if sType == "KBEngine.KBEDATATYPE_BASE" then
				-- ((KBEDATATYPE_BASE)type).bind();
			else
				if EntityDef.iddatatypes[sType] ~= nil then
					t.dicttype[itemkey] = EntityDef.iddatatypes[sType];
				end
			end
		end
	end
	
	function t.createFromStream(streamBuffer)
		local datas = {};
		-- for itemkey, v in pairs(t.dicttype) do
		for _, itemkey in ipairs(t.dicttype.Keys) do
			datas[itemkey] = t.dicttype[itemkey]["createFromStream"](streamBuffer);
		end
		return datas;
	end
	
	function t.addToStream(streamBuffer, v)
		--[[
		foreach(string itemkey in dicttype.Keys)
		
			((KBEDATATYPE_BASE)dicttype[itemkey]).addToStream(stream, ((Dictionary<string, object>)v)[itemkey]);
		end
		--]]
	end
	
	function t.parseDefaultValStr(v)
		--[[
		Dictionary<string, object> datas = new Dictionary<string, object>();
		foreach(string itemkey in dicttype.Keys)
		
			datas[itemkey] = ((KBEDATATYPE_BASE)dicttype[itemkey]).parseDefaultValStr("");
		end
		
		return datas;
		--]]
	end
	
	function t.isSameType(v)
		--[[
		if(v == null || v.GetType() != typeof(Dictionary<string, object>))
			return false;
				
		foreach(KeyValuePair<string, object> item in dicttype)
		
			local value = {};
			if(((Dictionary<string, object>)v).TryGetValue(item.Key, out value))
				if(!((KBEDATATYPE_BASE)item.Value).isSameType(value))
					return false;
				end
			else	
				return false;
			end
		end

		return true;
		--]]
	end
	
	return t;
end
 


