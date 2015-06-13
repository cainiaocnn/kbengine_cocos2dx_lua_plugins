--战斗状态部分
SpriteStateCenter = {}
local t = SpriteStateCenter;

-- 伤害类型
function t:StateAssembly(tMessage)
	local actionArray = {};
	local eHurtEnum = SkillReleaseCenter:GetHurtType(tMessage.nAttackType);
	if eHurtEnum == HurtEnum.REMOVEBUFF then
		-- 删除Buff(这个时候nSkillId是BuffId)
		local tBuffer = {};
		SkillReleaseCenter:BufferList(tBuffer, tMessage.nSkillId, tMessage.nBeAttackId[1], -1);
		table.insert(actionArray,{tMessage.nAttackId, tMessage.nBeAttackId[1], ActionEnum.BUFFER_ACTION, tBuffer});
	else
		--造成伤害
		table.insert(actionArray,{tMessage.nAttackId, tMessage.nBeAttackId[1], ActionEnum.HURT_ACTION, {{{tMessage.nAttackId,tMessage.nBeAttackId[1]}, tMessage.nDamageHurt, eHurtEnum, tMessage.nSkillId}}});
	end
	return actionArray;
end
