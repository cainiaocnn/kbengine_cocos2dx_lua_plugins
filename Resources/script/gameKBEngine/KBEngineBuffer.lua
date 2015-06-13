-- 游戏网络(数据处理)
KBEngineBuffer = {};
local p = KBEngineBuffer;

function p:writeInt8(streamBuffer, v)
	local writeSize = 0;
	if streamBuffer ~= nil then
		if type(v) == "number" then
			streamBuffer:writeChar(v);
			writeSize = 1;
		else
			Elog("gameSocketBuffer writeInt8");
		end
	end
	return writeSize;
end

function p:writeInt16(streamBuffer, v)
	local writeSize = 0;
	if streamBuffer ~= nil then
		if type(v) == "number" then
		
			local value1 = CCBit:_and(v, 0xff) 
			writeSize = p:writeInt8(streamBuffer, value1);
			
			local value2 = CCBit:_rshift(v, 8)
			value2 = CCBit:_and(value2, 0xff) 
			writeSize = writeSize + p:writeInt8(streamBuffer, value2);
		else
			Elog("gameSocketBuffer writeInt16");
		end
	end
	return writeSize;
end
	
function p:writeInt32(streamBuffer, v)
	local writeSize = 0;
	if streamBuffer ~= nil then
		if type(v) == "number" then
			for i=0,3 do
				local value = CCBit:_rshift(v, i*8);
				value = CCBit:_and(value, 0xff) 
				writeSize = writeSize + p:writeInt8(streamBuffer, value);
			end
		else
			Elog("gameSocketBuffer writeInt32");
		end
	end
	return writeSize;
end

function p:writeInt64(streamBuffer, v)
	local writeSize = 0;
	if streamBuffer ~= nil then
		if type(v) == "number" then
			for i=0,7 do
				local value = bit:_rshift(v, i*8);
				--[[
				local value = CCBit:_rshift(v, i*8);
				--]]
				value = CCBit:_and(value, 0xff);

				writeSize = writeSize + p:writeInt8(streamBuffer, value);
			end
		else
			Elog("gameSocketBuffer writeInt32");
		end
	end
	return writeSize;
end

function p:writeUint8(streamBuffer, v)
	local writeSize = 0;
	if streamBuffer ~= nil then
		if type(v) == "number" then
			streamBuffer:writeUChar(v);
			writeSize = 1;
		else
			Elog("gameSocketBuffer writeUint8");
		end
	end
	return writeSize;
end

function p:writeUint16(streamBuffer, v)
	local writeSize = 0;
	if streamBuffer ~= nil then
		if type(v) == "number" then
			local value1 = CCBit:_and(v, 0xff) 
			writeSize = writeSize+ p:writeUint8(streamBuffer, value1);
			
			local value2 = CCBit:_rshift(v, 8)
			value2 = CCBit:_and(value2, 0xff) 
			writeSize = writeSize+ p:writeUint8(streamBuffer, value2);
		else
			Elog("gameSocketBuffer writeUint8");
		end
	end
	return writeSize
end
	
function p:writeUint32(streamBuffer, v)
	local writeSize = 0;
	if streamBuffer ~= nil then
		if type(v) == "number" then
			for i=0,3 do
				local value = CCBit:_rshift(v, i*8);
				value = CCBit:_and(value, 0xff) 
				writeSize = writeSize + p:writeUint8(streamBuffer, value);
			end
		else
			Elog("gameSocketBuffer writeUint32");
		end
	end
	return writeSize;
end

function p:writeUint64(streamBuffer, v)
	local writeSize = 0;
	if streamBuffer ~= nil then
		if type(v) == "number" then
			for i=0,7 do
				local value = bit:_rshift(v, i*8);
				--[[
				local value = CCBit:_rshift(v, i*8);
				--]]
				value = CCBit:_and(value, 0xff);

				
				writeSize = writeSize + p:writeUint8(streamBuffer, value);
			end
		else
			Elog("gameSocketBuffer writeInt32");
		end
	end
	return writeSize;
end

function p:writeFloat(streamBuffer, v)
	local writeSize = 0;
	--[[
	byte[] getdata = BitConverter.GetBytes(v);
	for(int i=0; i<getdata.Length; i++)
	
		datas_[wpos++] = getdata[i];
	end
	--]]
	return writeSize;
end

function p:writeDouble(streamBuffer, v)
	local writeSize = 0;
	--[[
	byte[] getdata = BitConverter.GetBytes(v);
	for(int i=0; i<getdata.Length; i++)
	
		datas_[wpos++] = getdata[i];
	end
	--]]
	return writeSize;
end

function p:writeBlob(streamBuffer, v)
	local writeSize = 0;
	if streamBuffer ~= nil then
		if type(v) == "string" then
			local size = string.len(v);
			writeSize = writeSize + p:writeUint32(streamBuffer, size);
			writeSize = writeSize + p:writeString(streamBuffer, v);
		end
	end
	return writeSize;
end

function p:writeString(streamBuffer, v)
	local writeSize = 0;
	if streamBuffer ~= nil then
		if type(v) == "string" then
			streamBuffer:writeString(v);
		else
			Elog("gameSocketBuffer writeString");
		end
	end
	return writeSize;
end

--------------------------------------------------------------
function p:readInt8(streamBuffer)
	local value = 0;
	if streamBuffer ~= nil then
		value = streamBuffer:readChar();
	end
	return value;
end

function p:readInt16(streamBuffer)
	local value = 0;
	if streamBuffer ~= nil then
		for i=0,1 do
			local data = p:readInt8(streamBuffer);
			value = value + CCBit:_lshift(data,i*8)
		end
	end
	return value;
end
	
function p:readInt32(streamBuffer)
	local value = 0;
	if streamBuffer ~= nil then
		for i=0,3 do
			local data = p:readInt8(streamBuffer);
			data = CCBit:_and(data,0xff);
			value = value + CCBit:_lshift(data,i*8)
		end
	end
	return value;
end

function p:readInt64(streamBuffer)
	local value = 0;
	if streamBuffer ~= nil then
		for i=0,7 do
			local data = p:readInt8(streamBuffer);
			data = CCBit:_and(data,0xff);
			value = value + CCBit:_lshift(data,i*8)
		end
	end
	return value;
end

function p:readUint8(streamBuffer)
	local value = 0;
	if streamBuffer ~= nil then
		value = streamBuffer:readUChar();
	end
	return value;
end

function p:readUint16(streamBuffer)
	local value = 0;
	if streamBuffer ~= nil then
		for i=0,1 do
			local data = p:readUint8(streamBuffer);
			value = value + CCBit:_lshift(data,i*8)
		end
	end
	return value;
end

function p:readUint32(streamBuffer)
	local value = 0;
	if streamBuffer ~= nil then
		for i=0,3 do
			local data = p:readUint8(streamBuffer);
			data = CCBit:_and(data,0xff);
			value = value + CCBit:_lshift(data,i*8)
		end
	end
	return value;
end

function p:readUint64(streamBuffer)
	local value = 0;
	if streamBuffer ~= nil then
		for i=0,7 do
			local data = p:readUint8(streamBuffer);
			data = CCBit:_and(data,0xff);
			value = value + CCBit:_lshift(data,i*8)
		end
	end
	return value;
end

function p:readFloat(streamBuffer)
	local value = 0;
	if streamBuffer ~= nil then
		value = streamBuffer:readFloat();
	end
	return value;
end

function p:readDouble(streamBuffer)
	local value = 0;
	if streamBuffer ~= nil then
		value = streamBuffer:readDouble();
	end
	return value;
end

function p:readString(streamBuffer, uSize)
	if streamBuffer ~= nil then
		if uSize == nil then
			return streamBuffer:readStringEndByZero();
		else
			if uSize ~= 0 then
				return streamBuffer:readString(uSize);
			else
				return "";
			end
		end
	end
	return nil;
end

function p:readBlob(streamBuffer)
	local buf = nil;
	if streamBuffer ~= nil then
		local size = p:readUint32(streamBuffer);
		buf = p:readString(streamBuffer, size);
	end
	return buf;
end

function p:readPackXZ(streamBuffer)
	
	local xPackData = PackFloatXType();
	local zPackData = PackFloatXType();
	
	xPackData.fv = 0;
	zPackData.fv = 0;
	
	xPackData.uv = 0x40000000;
	zPackData.uv = 0x40000000;

	local v1 = p:readUint8(streamBuffer);
	local v2 = p:readUint8(streamBuffer);
	local v3 = p:readUint8(streamBuffer);
	
	local data = 0;
	-- data |= ((UInt32)v1 << 16);
	data = CCBit:_or(CCBit:_lshift(v1,16), data);
	-- data |= ((UInt32)v2 << 8);
	data = CCBit:_or(CCBit:_lshift(v2,8), data);
	-- data |= (UInt32)v3;
	data = CCBit:_or(v3, data);
	
	-- xPackData.uv |= (data & 0x7ff000) << 3;
	local uvData1 = CCBit:_and(data, 0x7ff00);
	local uvData2 = CCBit:_lshift(uvData1, 3);
	xPackData.uv = CCBit:_or(xPackData.uv, uvData2);
	
	-- zPackData.uv |= (data & 0x0007ff) << 15;
	local uvData1 = CCBit:_and(data, 0x0007ff);
	local uvData2 = CCBit:_lshift(uvData1, 15);
	zPackData.uv = CCBit:_or(zPackData.uv, uvData2);
	
	
	xPackData.fv = xPackData.fv - 2;
	zPackData.fv = zPackData.fv - 2;

	-- xPackData.uv |= (data & 0x800000) << 8;
	local uvData1 = CCBit:_and(data, 0x800000);
	local uvData2 = CCBit:_lshift(uvData1, 8);
	xPackData.uv = CCBit:_or(xPackData.uv, uvData2);
	
	-- zPackData.uv |= (data & 0x000800) << 20;
	local uvData1 = CCBit:_and(data, 0x000800);
	local uvData2 = CCBit:_lshift(uvData1, 20);
	zPackData.uv = CCBit:_or(zPackData.uv, uvData2);


	local vec = Vector2(xPackData.fv, zPackData.fv);
	return vec;
	
end

function p:readPackY(streamBuffer)
	
	local yPackData = PackFloatXType(); 
	yPackData.fv = 0;
	yPackData.uv = 0x40000000;

	local data = p:readUint16(streamBuffer);

	-- yPackData.uv |= ((UInt32)data & 0x7fff) << 12;
	local uvData1 = CCBit:_and(data, 0x7fff);
	local uvData2 = CCBit:_lshift(uvData1, 12);
	yPackData.uv = CCBit:_or(yPackData.uv, uvData2);
	
	yPackData.fv =  yPackData.fv - 2;
	
	--[[
	-- yPackData.uv |= ((UInt32)data & 0x8000) << 16;
	local uvData1 = CCBit:_and(data, 0x8000);
	local uvData2 = CCBit:_lshift(uvData1, 16);
	yPackData.uv = CCBit:_or(yPackData.uv, uvData2);
	--]]
	
	return yPackData.fv;
end

