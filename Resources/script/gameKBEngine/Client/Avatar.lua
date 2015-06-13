-- Avatar

function Avatar()
	local superEntity = Entity()
	local t = class("Avatar", superEntity);
	
   	t.combat = {};

	function t:__init__()	
		t.combat = Combat(t);
	end
		
	function t:relive(ntype)
		self:cellCall("relive", ntype);
	end
		
	function t:useTargetSkill(skillID, targetID)

		local skill = SkillBoxInst():get(skillID);
		if skill == nil then
			return false;
		end

		local scobject = SCEntityObject(targetID);
		if skill.validCast(this, scobject) then
			skill.use(this, scobject);
		end

		return true;
	end
		
	function t:jump()
		t:cellCall("jump");
	end
		
	function t:onJump()
		Dlg(tostring(t.className).."::onJump: "..tostring(t.id));
		-- Event.fireOut("otherAvatarOnJump", new object[]{this});
	end
		
	function t:onAddSkill(skillID)
		
		-- Dbg.DEBUG_MSG(className + "::onAddSkill(" + skillID + ")"); 
		-- Event.fireOut("onAddSkill", new object[]{this});
		
		local skill = Skill();
		skill.id = skillID;
		skill.name = tostring(skillID).." ";
		if skillID == 1 then
				
		elseif skillID ==1000101 then
			skill.canUseDistMax = 20;
				
		elseif skillID ==2000101 then
			skill.canUseDistMax = 20;
			
		elseif skillID ==3000101 then
			skill.canUseDistMax = 20;
				
		elseif skillID ==4000101 then
			skill.canUseDistMax = 20;
				
		elseif skillID ==5000101 then
			skill.canUseDistMax = 20;
				
		elseif skillID ==6000101 then
			skill.canUseDistMax = 20;
		end

		SkillBoxInst():add(skill);
	end
		
	function t:onRemoveSkill( skillID)
		-- Dbg.DEBUG_MSG(className + "::onRemoveSkill(" + skillID + ")"); 
		-- Event.fireOut("onRemoveSkill", new object[]{this});
		SkillBoxInst():remove(skillID);
	end
		
	function t:onEnterWorld()
		--[[
		t.super:onEnterWorld();

		if(isPlayer())
		{
			Event.fireOut("onAvatarEnterWorld", new object[]{KBEngineApp.app.entity_uuid, id, this});				
			SkillBox.inst.pull();
		}
		--]]
	end
	
	return t;
end

