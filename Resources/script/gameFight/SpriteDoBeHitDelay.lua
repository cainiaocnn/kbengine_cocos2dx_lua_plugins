--角色显示被击延迟处理
SpriteDoBeHitDelay = {};
local p = SpriteDoBeHitDelay;

---
function p:GetDoBeDelay(nSkillID, bSkillType)
	if bSkillType == 1 then
		if nSkillID == 10800 then --审判(力之审判)
			return 0.15;
		elseif nSkillID == 10820 then --审判(裁决之光)
			return 0.25;
		elseif nSkillID == 10580 then --圣骑士(帜热光辉)
			return 0.2;
		elseif nSkillID == 10480 then --守望者(螺旋冲击)
			return 0.1;
		elseif nSkillID == 10490 then --守望者(削弱攻击)
			return 0.2;
		elseif nSkillID == 10600 then --占星术士(炽焰之星)
			return 0.2;
		elseif nSkillID == 10610 then --占星术士(蓄力攻击)
			return 0.1;
		end
	end
	return 0;
end