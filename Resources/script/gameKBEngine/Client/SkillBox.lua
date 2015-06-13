
local m_SkillBoxInst = nil;

function SkillBoxInst()
	if m_SkillBoxInst == nil then
		m_SkillBoxInst = SkillBox();
	end
	return m_SkillBoxInst;
end

function SkillBox()

	local t = {};
	
	t.skills = {};
	
	function t:pull()
	
		t:clear();
		--local player = KBEngineApp.app.player();
		local player = KBEngineEntityManager:GetPlayerEntity();
		if player ~= nil then
			player:cellCall("requestPull");
		end
	end
	
	function t:clear()
		t.skills = {};
	end
	
	function t:add(skill)
	
		for i=1, #t.skills do
		
			if t.skills[i].id == skill.id then
				Wlog("SkillBox::add: "..tostring(skill.id).." is exist!");
				return;
			end
		end
		table.insert(t.skills, skill);
	end
	
	function t:remove(id)

		for i=1, #t.skills do
			if t.skills[i].id == id then
				t.skills[i] = nil
				return;
			end
		end
	end
	
	function t:get(id)
		for i=1, #t.skills do
			if t.skills[i].id == id then
				return t.skills[i];
			end
		end
		return nil;
	end

	return t;
end

