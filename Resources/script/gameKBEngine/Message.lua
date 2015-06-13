-- KBE Message
MessageMain = {};
local p = MessageMain;
p.loginappMessages = {};
p.baseappMessages = {};
p.clientMessages = {};
p.messages = {};

function p.MessageInit()
	p.loginappMessages = {};
	p.baseappMessages = {};
	p.clientMessages = {};
	p.messages = {};
	
	--[[
	p.messages["Loginapp_importClientMessages"] = Message(5, "importClientMessages", 0, 0, {}, nil);
	p.messages["Loginapp_hello"] = Message(4, "hello", -1, -1, {}, nil);
	
	p.messages["Baseapp_importClientMessages"] = Message(207, "importClientMessages", 0, 0, {}, nil);
	p.messages["Baseapp_importClientEntityDef"] = Message(208, "importClientMessages", 0, 0, {}, nil);
	p.messages["Baseapp_hello"] = Message(200, "hello", -1, -1, {}, nil);
	
	p.messages["Client_onHelloCB"] = Message(521, "Client_onHelloCB", -1, -1, {}, 
		KBEngineApp.app.GetType().GetMethod("Client_onHelloCB"));
	p.clientMessages[Message.messages["Client_onHelloCB"].id] = Message.messages["Client_onHelloCB"];
	
	p.messages["Client_onScriptVersionNotMatch"] = Message(522, "Client_onScriptVersionNotMatch", -1, -1, {}, 
		KBEngineApp.app.GetType().GetMethod("Client_onScriptVersionNotMatch"));
	p.clientMessages[Message.messages["Client_onScriptVersionNotMatch"].id] = Message.messages["Client_onScriptVersionNotMatch"];

	p.messages["Client_onVersionNotMatch"] = Message(523, "Client_onVersionNotMatch", -1, -1, {}, 
		KBEngineApp.app.GetType().GetMethod("Client_onVersionNotMatch"));
	p.clientMessages[Message.messages["Client_onVersionNotMatch"].id] = Message.messages["Client_onVersionNotMatch"];
	
	p.messages["Client_onImportClientMessages"] = Message(518, "Client_onImportClientMessages", -1, -1, {}, 
		KBEngineApp.app.GetType().GetMethod("Client_onImportClientMessages"));
	p.clientMessages[Message.messages["Client_onImportClientMessages"].id] = Message.messages["Client_onImportClientMessages"];
	
	--]]
end


--------------------------------------------------------------------------

function Message(msgid, msgname, length, argstype, msgargtypes, msghandler)
	local t = {}
	
	t.id = msgid;
	t.name = msgname;
	t.msglen = length;
	t.handler = msghandler;
	t.argsType = argstype;
	
	
	
	return t;
end


