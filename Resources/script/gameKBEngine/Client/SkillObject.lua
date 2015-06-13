
function SCObject()

	local t = class("SCObject");
	
	function t:valid( caster)
		return true;
	end
	
	function t:getPosition()
		-- return Vector3.zero;
		return {};
	end
	
	return t;
end

function SCEntityObject(targetID)
	
	local superEntity = SCObject()
	local t = class("SCEntityObject", superEntity);
	
	t.targetID = targetID;

	function t:valid(caster)
		return true;
	end
		
	function t:getPosition()
		
		local entity = KBEngineEntityManager:GetEntityValue(t.targetID)
		if entity == nil then
			return t.super:getPosition();
		end
		return entity.position;
	end
	
	return t;
end
	
function SCPositionObject(position)
	
	local superEntity = SCObject()
	local t = class("SCPositionObject", superEntity);
	
	t.targetPos = position;

	function t:valid(caster)
		return true;
	end
		
	function t:getPosition()
		return t.targetPos;
	end
	
	return t;
end
	
function SRObject()
	local t = class("SRObject");

	function t:valid(receiver)
		return true;
	end
	
	return t;
end
