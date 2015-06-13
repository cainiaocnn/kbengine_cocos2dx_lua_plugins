--GUI 实例代码
NormalGui = class("NormalGui", StudioGuiTableView);

local p = NormalGui;

function p:Init()
	local pButton = self:GetStudioUINode("Button_start", "Button");
	local function buttonEvent()
		cclog("***Button Event***");
	end
	self:RegisteredTouchEvent(pButton, buttonEvent)
end
