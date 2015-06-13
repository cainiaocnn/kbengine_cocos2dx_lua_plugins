-- Account

function Account()
	local superEntity = Entity()
	local t = class("Account", superEntity);
	
	t.avatars = {};
	t.args    = {};
	
	function t:__init__()
		-- Event.fireOut("onLoginSuccessfully", new object[]{KBEngineApp.app.entity_uuid, id, this});
		self:baseCall("reqAvatarList", {});
	end

	function t:onCreateAvatarResult(tData)--(retcode, info)
		Dlog("Account:onCreateAvatarResult");
		
		if tData == nil then
			tData = t.args;
		end
		if tData ~= nil then
			local retcode = tData[1];
			if retcode == 0 then
				local newAccount = {};
				newAccount = tData[2];
				t.avatars[tostring(newAccount["dbid"])] = newAccount;
				gameAccount:ReflashData("avatars", t.avatars);
				gameAccount:ReflashStudioGUI("avatars");
			else
				Elog("Account::onCreateAvatarResult: retcode="..tostring(retcode));
			end
		end
		-- // ui event
		-- Event.fireOut("onCreateAvatarResult", new object[]{retcode, info, avatars});
	end

	function t:onRemoveAvatar(dbid)
		if dbid == nil then
			dbid = t.args;
		end
		Dlog("Account:onRemoveAvatar");
		for k ,v in pairs(dbid) do
			t.avatars[tostring(v)] = nil;
		end
		gameAccount:ReflashData("avatars", t.avatars);
		gameAccount:ReflashStudioGUI("avatars");
	end

	function t:onReqAvatarList( infos)
		
		if infos == nil then
			infos = t.args;
		end
		Dlog("Account:onReqAvatarList");
		
		t.avatars = {};
		for i, v in ipairs(infos) do
			if v["values"] ~= nil then
				for j, d in ipairs(v["values"]) do
					-- table.insert(t.avatars, d);
					t.avatars[tostring(d["dbid"])] = d;
				end
			else
				Wlog("Value Not Found onReqAvatarList");
			end
		end
		
		StudioGuiManager.OpenStudioGUI(StudioGuiTag.GUI_GAME_CHOOSE);
		
		gameAccount:ReflashData("avatars", t.avatars);
		gameAccount:ReflashStudioGUI("avatars");
		
		StudioGuiManager.CloseStudioGUI(StudioGuiTag.GUI_GAME_LOGIN);
		
	end

	function t:reqCreateAvatar(roleType, name)
		Dlog("Account:reqCreateAvatar ,roleType="..tostring(roleType));
		self:baseCall("reqCreateAvatar", {roleType, name});
	end

	function t:reqRemoveAvatar( name)
		Dlog("Account:reqRemoveAvatar ,name="..tostring(name));
		self:baseCall("reqRemoveAvatar", {name});
	end

	function t:selectAvatarGame( dbid)
		Dlog("Account:selectAvatarGame ,dbid="..tostring(dbid));
		self:baseCall("selectAvatarGame", {dbid});
	end
	
	return t;
end

