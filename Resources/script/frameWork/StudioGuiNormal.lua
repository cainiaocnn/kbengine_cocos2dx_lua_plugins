-- CLJ 
-- 描述:Studio窗口基础继承
StudioGuiNormal = class("StudioGuiNormal");
local p = StudioGuiNormal;

--游戏数据存放
p.data = {};

-- EVENT(控件事件)
TouchEvent_Began 	= 0;
TouchEvent_Moved 	= 1;
TouchEvent_Ended 	= 2;
TouchEvent_Canceled = 3;

-- 创建Cocostudio编辑的窗口
-- strJsonFullPath, 窗口JSON文件
-- strDescribe, 	窗口描述
-- funcEvent		窗口事件(enter, exit)
function p:CreateGUI(strJsonFullPath, strDescribe, funcEvent)
	self.touchGroup = TouchGroup:create();
	self.studioGui = GUIReader:shareReader():widgetFromJsonFile(strJsonFullPath);
	if self.studioGui ~= nil then
	
		self.strDescribe = strDescribe;
		self.touchGroup:addWidget(self.studioGui);
		if funcEvent ~= nil then
			self.touchGroup:registerScriptHandler(funcEvent);
		end
		--
		self:InitGUI();
		self:InitEvent();
		
		return self.touchGroup;
	else
		cclog("***Studio CreateGUI Error***");
	end
	return nil;
end

--获取窗口
function p:GetMainGUIGroup()
	cclog("---没有重写初始化窗口创建函数:GetMainGUIGroup---");
	return nil;
end

--初始化事件
function p:InitGUI()
	cclog("---没有重写初始化UI函数:InitGUI---");
end

--初始化事件
function p:InitEvent()
	cclog("---没有重写初始化事件函数:InitEvent---");
end

--刷新数据
function p:ReflashData(typeInfo, tDataInfo)
	p.data[tostring(typeInfo)] = tDataInfo;
end

function p:GetReflashData(typeInfo)
	local tDataInfo = p.data[tostring(typeInfo)];
	if tDataInfo == nil then
		Elog("lua file:%s, lua func:%s","StudioGuiNormal","GetReflashData");
	end
	return tDataInfo;
end

--刷新界面
function p:ReflashStudioGUI(typeInfo)
	if typeInfo == nil then
	
	end
end

function p:GetTouchGroup()

end

function p:GetStudioGui()

end

-- 获取节点
-- Label 、 ImageView 、 ListView 、 LabelBMFont 、 Button 、 Widget、 TextField
function p:GetStudioUINode(strNodeName, NodeClassName)
	if self.studioGui ~= nil then
		local pWidget = UIHelper:seekWidgetByName( self.studioGui, strNodeName);
		if pWidget ~= nil then
			local pNode = tolua.cast(pWidget, NodeClassName)
			if pNode ~= nil then
				return pNode;
			else
				Elog("*************************************");
				Elog(tostring(self.strDescribe)..",窗口没有控件名为 :%s ***", strNodeName);
			end
		else
			Elog("*************************************");
			Elog(tostring(self.strDescribe)..",获取窗口控件失败");
		end
	else
		Elog("*************************************");
		Elog(tostring(self.strDescribe)..",窗口没有被创建请调用:CreateGui");
	end
	return nil;
end

-- StudioGUI 根据Tag获取节点
-- getChildByTag(int tag);	获取StudioGUI的节点
-- getNodeByTag(int tag);	获取非StudioGUI的节点
-- 添加节点
-- addChild 添加StudioGUI的节点
-- addNode  添加非StudioGUI的节点

-- 添加GUI节点
function p:addChild(pNode, zOrder, nTag)
	self.touchGroup:addChild(pNode, zOrder, nTag);
end

-- 添加非GUI节点
function p:addNode(pNode, zOrder, nTag)
	self.touchGroup:addNode(pNode, zOrder, nTag);
end

-- 注册按钮事件(结束事件)
-- callEndFunc(必须是p.的方式,不能是p:)
function p:RegisteredTouchEventByNode(pNode, callEndFunc)
	if pNode ~= nil then
		pNode:addTouchEventListener(
			function(sender,eventType)
				if eventType == TouchEvent_Ended then
					callEndFunc(sender,eventType)
				end
			end
		)
	else
		Elog("***Studio RegisteredTouchEvent Error***");
	end
end

-- 注册按钮事件(结束事件)
-- callEndFunc(必须是p.的方式,不能是p:)
function p:RegisteredTouchEventByNodeName(strNodeName, callEndFunc)
	local pNode = UIHelper:seekWidgetByName( self.studioGui, strNodeName);
	if pNode ~= nil then
		pNode:addTouchEventListener(
			function(sender,eventType)
				if eventType == TouchEvent_Ended then
					if callEndFunc ~= nil then
						callEndFunc(sender,eventType)
					else
						Dlog(tostring(self.strDescribe)..",点击事件回调函数失败,"..tostring(strNodeName));
					end
				end
			end
		)
	else
		Elog("***Studio RegisteredTouchEvent Error***");
	end
end

-- 窗口描述
function p:GuiDescribe()
	return tostring(self.strDescribe);
end
