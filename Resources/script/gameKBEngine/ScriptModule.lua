-- KBE ScriptModule

function ScriptModule(name)
	local t = {};
	
	t.name = name;
	t.usePropertyDescrAlias = false;
	t.useMethodDescrAlias = false;
	
	t.propertys = {};
	t.idpropertys = {};
	
	t.methods = {};
	t.base_methods = {};
	t.cell_methods = {};
	
	t.idmethods = {};
	t.idbase_methods = {};
	t.idcell_methods = {};
	t.script = name;
	
	return t;
end