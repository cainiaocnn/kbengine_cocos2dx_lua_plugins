
function Skill()
	local t = {};
	
	t.name = "";
    t.descr= "";
	t.id   = 0;
	t.canUseDistMin = 0;
    t.canUseDistMax = 3;
    	
		
	function t:validCast(caster, target)
		--[[
			float dist = Vector3.Distance(target.getPosition(), caster.position);
			if(dist > canUseDistMax)
				return false;
		--]]
		return true;
	end
		
	function t:use( caster,  target)
		-- caster.cellCall("useTargetSkill", id, ((SCEntityObject)target).targetID);
    end
	
	return t;
end
