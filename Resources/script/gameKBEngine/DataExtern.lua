-- KBE 数据类型
DataExtern = {};
local p = DataExtern;

function Vector2(x,y)
	local t = {}
	t.x = x;
	t.y = y;
	return t;
end

function Vector3(x,y,z)
	local t = {}

	return t;
end

function Vector4(x,y,z,w)
	local t = {}
	
	return t;
end

function PackFloatXType()
	local t = {}
	
	t.fv = 0; --float
	t.uv = 0; --UInt32
	t.iv = 0; --Int32
	
	return t;
end
