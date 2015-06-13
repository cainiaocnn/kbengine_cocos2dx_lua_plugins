
GameUpdateInfo = {};
local p = GameUpdateInfo;

--更新时候说的话
p.tWorlds = {};

function p.GetUpdateWords(nIndex)
	if nIndex == nil then
		local nMyIndex = math.random(4,#(p.tWorlds))
		if nMyIndex < 4 then
			nMyIndex = 4;
		end
		return p.tWorlds[nMyIndex];
	else
		return p.tWorlds[nIndex];
	end
end