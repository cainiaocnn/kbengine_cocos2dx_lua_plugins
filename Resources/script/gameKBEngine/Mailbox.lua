-- KBE Mailbox部分

EnumMailbox = 
{
	MAILBOX_TYPE_CELL = 0,		-- CELL_MAILBOX
	MAILBOX_TYPE_BASE = 1		-- BASE_MAILBO
}

function Mailbox()
	local t = {}
	
	--数据部分
	t.id = 0;
	t.className = "";
	t.type = EnumMailbox.MAILBOX_TYPE_CELL;
	
	t.sendBuffer = {};
		
	function t:isBase()
		if t.type == EnumMailbox.MAILBOX_TYPE_BASE then
			return true;
		end
		return false;
	end
	
	function t:isCell()
		if t.type == EnumMailbox.MAILBOX_TYPE_CELL then
			return true;
		end
		return false;
	end
	
	function t:pushBuffer(valueType, value, keys)
		table.insert(t.sendBuffer, {valueType,  value, keys});
	end
	
	function t:newMail()
	
		t.sendBuffer = {};
		
		local streamBuffer = CCBuffer:create();
		if streamBuffer ~= nil then
			if t.type == EnumMailbox.MAILBOX_TYPE_CELL then
				-- KBEngineMessageSend:Baseapp_onRemoteCallCellMethodFromClient(streamBuffer, false, t.id, nil);
				table.insert(t.sendBuffer, {"UINT16", 205});	--消息ID
			else
				-- KBEngineMessageSend:Base_onRemoteMethodCall(streamBuffer, false, t.id, funcID, nil);
				table.insert(t.sendBuffer, {"UINT16", 301});	--消息ID
			end
			t:pushBuffer("INT32", t.id);
		end
		return streamBuffer;
	end
	
	function t:postMail()
		local pKBEngine = KBEngineApp:shareKBEngineApp();
		if pKBEngine ~= nil then
			local msgLen = 0;
			for i, v in ipairs(t.sendBuffer) do
				if i~= 1 then
					msgLen = msgLen + DataType:DataLength(v[1], v[2], v[3])
				end
			end
			
			local streamBuffer = CCBuffer:create();
			if streamBuffer ~= nil then
				for i, v in ipairs(t.sendBuffer) do
					if i == 1 then
						KBEngineBuffer:writeUint16(streamBuffer, v[2]);		--//MSG ID
						KBEngineBuffer:writeUint16(streamBuffer, msgLen);	--//数据长度
					else
						DataType:writeData(streamBuffer, v[1], v[2], v[3]);
					end
				end
				pKBEngine:send(streamBuffer);
			end
		end
	end

	
	return t;
end


