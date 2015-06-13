--GUI 实例代码
MutipleTableviewGui = class("MutipleTableviewGui", StudioGuiTableView);

local p = MutipleTableviewGui;

function p:Init()
	local pButton = self:GetStudioUINode("Button_start", "Button");
	local function buttonEvent()
		cclog("***Button Event***");
	end
	self:RegisteredTouchEvent(pButton, buttonEvent)
end
