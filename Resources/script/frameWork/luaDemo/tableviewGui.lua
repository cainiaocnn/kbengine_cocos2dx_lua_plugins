--GUI 实例代码
TableviewGui = class("TableviewGui", StudioGuiTableView);

local p = TableviewGui;

--横屏还是竖屏Demo
local m_DemoType = 0;--0:竖屏 1:横屏

local m_kDirection = nil;

function p:Init()

	local pButton = self:GetStudioUINode("Button_start", "Button");
	local function InitTable()
		if m_DemoType == 0 then
			p:InitTableViewVertical();
		elseif m_DemoType == 1 then
			p:InitTableViewHorizontal();
		end
	end
	self:RegisteredTouchEvent(pButton, InitTable)
end

-- 竖屏(垂直)
function p:InitTableViewVertical()
	if self:TableViewInit(120, 350, kCCScrollViewDirectionVertical) then
		
		m_kDirection = kCCScrollViewDirectionVertical
		
		local pBgImage = self:GetStudioUINode("Image_bg", "ImageView");
		if pBgImage ~= nil then
			pBgImage:addNode(self.tableView);
			self.tableView:setPosition(CCPointMake(-100, -320))
			self.tableView:reloadData();
			cclog("TableviewGui");
		end
	end
end

-- 横屏(水平)
function p:InitTableViewHorizontal()
	if self:TableViewInit(350, 180, kCCScrollViewDirectionHorizontal) then
		
		m_kDirection = kCCScrollViewDirectionHorizontal
		
		local pBgImage = self:GetStudioUINode("Image_bg", "ImageView");
		if pBgImage ~= nil then
			pBgImage:addNode(self.tableView);
			self.tableView:setPosition(CCPointMake(-100, -120))
			self.tableView:reloadData();
			cclog("TableviewGui");
		end
	end
end

-------------------------------------------------
function p.tableCellPostion(table, cell, nRow, nCol)
	local nW, nH = p.cellSizeForTable(table, nRow);
	if kCCScrollViewDirectionVertical == m_kDirection then--(LUA表垂直)
		local posX = nW*nCol;
		local posY = 0;
		return ccp(posX, posY);
	elseif kCCScrollViewDirectionHorizontal == m_kDirection then --(LUA表水平)
		local posX = 0;
		local posY = -nW*nCol;
		return ccp(posX, posY);
	end
	return ccp(0,0);
end

--单元点击响应
function p.tableCellTouched(table, cell)
    cclog("cell touched at index: %d,%d",cell:getIdx(), cell:getSel());
end

--设置单元的大小
function p.cellSizeForTable(table,idx)
    return 60, 60;--(宽高)
end

--创建表单元
function p.tableCellAtIndexRowCol(table, cell, nRow, nCol)
	
	local spriteTag = nCol+1;

	local sprite = tolua.cast(cell:getChildByTag(spriteTag),"CCSprite")
	if nil ~= sprite then
		local strValue = string.format("%d_%d", nRow, nCol)
		label = tolua.cast(sprite:getChildByTag(1),"CCLabelTTF")
		if nil ~= label then
			label:setString(strValue)
		else
			label = CCLabelTTF:create(strValue, "Helvetica", 20.0)
			label:setAnchorPoint(CCPointMake(0,0))
			label:setTag(1);
			sprite:addChild(label);
		end
	else
		sprite = CCSprite:create("images/Icon.png");
		sprite:setAnchorPoint(CCPointMake(0,0));
		
		local pos = p.tableCellPostion(table, cell, nRow, nCol);
		sprite:setPosition(pos);
		sprite:setTag(spriteTag);
		
		
		local strValue = string.format("%d_%d", nRow, nCol)
		label = tolua.cast(sprite:getChildByTag(1),"CCLabelTTF")
		if nil ~= label then
			label:setString(strValue)
		else
			label = CCLabelTTF:create(strValue, "Helvetica", 20.0)
			label:setAnchorPoint(CCPointMake(0,0))
			label:setTag(1);
			sprite:addChild(label);
		end
		cell:addChild(sprite);		
	end
	    
end

--创建表单元
function p.tableCellAtIndex(table, idx)
	local cell = table:dequeueCell();    
    if nil == cell then
        cell = CCTableViewCell:new();
		local nCol = p.numberOfCellsInTableViewCol();
		for i=0, nCol-1 do
			p.tableCellAtIndexRowCol(table, cell, idx, i);
		end
	else
		local nCol = p.numberOfCellsInTableViewCol();
		for i=0, nCol-1 do
			p.tableCellAtIndexRowCol(table, cell, idx, i);
		end		
    end
    return cell;
end


--单元行数
function p.numberOfCellsInTableViewRow(table)
	return 100;
end

--单元列数
function p.numberOfCellsInTableViewCol()
	return 3;
end