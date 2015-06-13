-- 游戏网络(长连接)
gameSocketNet = {};
local p = gameSocketNet;

local m_isHaveDealWithPack = false;

--Socket接收中心
function p.onSocketMessageReceived(msgLog, msgArray)
	if msgArray ~= nil then
		local pArray = tolua.cast(msgArray,"CCArray");
		if pArray ~= nil then
			local pCodeValue   =  tolua.cast(pArray:objectAtIndex(0),"CCInteger");
			if pCodeValue ~= nil then
				local nCode = pCodeValue:getValue();
				if nCode == KBENetState.On_UnknowCondition then
					Dlog("onSocket  On_UnknowCondition");
					KBEngineSocket:SetSocketState(nCode);
					KBEngineSocket:PerformRegiestFunc(nCode);
				elseif nCode == KBENetState.On_MessageReceived then
					Dlog("onSocket  On_MessageReceived");
					local pCCBuffer   =  tolua.cast(pArray:objectAtIndex(1),"CCBuffer");
					if pCCBuffer ~= nil then
						
						if not m_isHaveDealWithPack then
							m_isHaveDealWithPack = true
							local tPackList = {};
							KBEngineSocket:GetFullMssagePack(tPackList, pCCBuffer);
							m_isHaveDealWithPack = false;
						else
							Elog("**********************************************");
							Elog("上个消息包数据还没有处理完毕");
							Elog("**********************************************");
						end
						--[[
						--[[
						for i,v in ipairs(tPackList) do
							--执行回调函数
							-- v[1] = 消息ID
							-- v[2] = 字节流
							Dlog("MsgID :%d", v[1]);
							Dlog("MsgLen Sevrvice Us Len:%d", v[3]);
							Dlog("MsgDate Get Data Len:%d", v[2]:length());
							KBEngineSocket:PerformRegiestFunc(v[1], v[2]);
						end
						--]]
						--[[
						local first = pCCBuffer:readUChar();
						local secon = pCCBuffer:readUChar();
						Dlog("first:%d", first);
						Dlog("secon:%d", secon);
						local msgId = bit:_lshift(secon,8)   + first;
						Dlog("MsgID:%d", msgId);
						
						local msgLength = pCCBuffer:readUChar();
						Dlog("MsgLen:%d", msgLength);
						pCCBuffer:readUChar(); --读取结束0
						Dlog("MsgLen:%d", pCCBuffer:length());
						KBEngineSocket:PerformRegiestFunc(msgId , pCCBuffer);
						--]]
					end
				elseif nCode == KBENetState.On_Connected then
					Dlog("onSocket  On_Connected");
					KBEngineSocket:SetSocketState(nCode);
					KBEngineSocket:PerformRegiestFunc(nCode);
				elseif nCode == KBENetState.On_ConnectTimeout then
					Dlog("onSocket  On_ConnectTimeout");
					KBEngineSocket:SetSocketState(nCode);
					KBEngineSocket:PerformRegiestFunc(nCode);
				elseif nCode == KBENetState.On_Disconnected then
					Dlog("onSocket  On_Disconnected");
					KBEngineSocket:SetSocketState(nCode);
					KBEngineSocket:PerformRegiestFunc(nCode);
				elseif nCode == KBENetState.On_ExceptionCaught then
					Dlog("onSocket  On_ExceptionCaught");
					KBEngineSocket:SetSocketState(nCode);
					KBEngineSocket:PerformRegiestFunc(nCode);
				else
					Elog("onSocket Error Code:%d", nCode);
				end
			end
		end
	end
end



