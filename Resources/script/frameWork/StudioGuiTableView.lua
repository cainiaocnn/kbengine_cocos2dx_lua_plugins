-- CLJ 
-- 描述:Studio窗口基础继承
StudioGuiTableView = class("StudioGuiTableView", StudioGuiNormal);
local p = StudioGuiTableView;

-- kCCScrollViewDirectionVertical  (LUA表垂直)
-- kCCScrollViewDirectionHorizontal(LUA表水平)


-- 初始化表
function p:TableViewInit(nWidth, nHeight, kDirectionVertical)
	
	self.tableView = CCTableView:create(CCSizeMake(nWidth, nHeight));
	if self.tableView~=nil then
		-- self.tableView:setPosition(ccp(0, 0));
		-- self.tableView:setAnchorPoint(ccp(0.5,0.5));	
		--设置方向
		p:setDirection(kDirectionVertical)
		
		self.tableView:setDirection(kDirectionVertical);
		-- //列表设置为从小到大显示，及idx从0开始
		self.tableView:setVerticalFillOrder(kCCTableViewFillTopDown);
		--UI事件
		self.tableView:registerScriptHandler(self.scrollViewDidScroll,CCTableView.kTableViewScroll);
		self.tableView:registerScriptHandler(self.scrollViewDidZoom,CCTableView.kTableViewZoom);
		self.tableView:registerScriptHandler(self.tableCellTouched,CCTableView.kTableCellTouched);
		self.tableView:registerScriptHandler(self.cellSizeForTable,CCTableView.kTableCellSizeForIndex);
		self.tableView:registerScriptHandler(self.tableCellAtIndex,CCTableView.kTableCellSizeAtIndex);
		self.tableView:registerScriptHandler(self.numberOfCellsInTableViewRow,CCTableView.kNumberOfCellsInTableView);
		self.tableView:registerScriptHandler(self.numberOfCellsInTableViewCol,CCTableView.kNumberOfCellsColInTableView);
		-- 更新当前显示的单元
		-- self.tableView:reloadData();
		return true;
	else
		cclog("**** TableViewInit Error ***");
	end
	return false;
end

function p:setDirection(kDirection)
	self.kDirection = kDirection;
end

-----------------------------------------------------------------------
--获取单元位置
function p.tableCellPostion(table, cell, nRow, nCol)
	local nW, nH = self.cellSizeForTable(table, nRow);
	local kDirection = self.tableView:getDirection();
	if kCCScrollViewDirectionVertical == kDirection then--(LUA表垂直)
		local posX = nW*nRow;
		local posY = 0;
		return ccp(posX, posY);
	elseif kCCScrollViewDirectionHorizontal == kDirection then --(LUA表水平)
		local posX = 0;
		local posY = nW*nRow;
		return ccp(posX, posY);
	end
	return ccp(0,0)
end

--
-- 创建表单元
function p.tableCellAtIndexRowCol(table, cell, nRow, nCol)

end

-- TableView滚动事件
function p.scrollViewDidScroll(view)
   -- cclog("scrollViewDidScroll");
end
-- TableView变焦事件
function p.scrollViewDidZoom(view)
    --cclog("scrollViewDidZoom");
end

--单元点击响应
function p.tableCellTouched(table, cell)
    cclog("cell touched at index: " .. cell:getIdx());
end

--设置单元的大小
function p.cellSizeForTable(table,idx)
	--0:W  0:H
    return 32, 32;
end

--创建表单元
function p.tableCellAtIndex(table, idx)
	local cell = table:dequeueCell();    
    if nil == cell then
        cell = CCTableViewCell:new();
		
		local nCol = self.numberOfCellsInTableViewCol();
		for i=0, nCol do
			p.tableCellAtIndexRowCol(table, cell, idx, nCol);
		end
		--[[
		local strImage = "images/"..(idx+1)..".png"
		local item2 = CCMenuItemImage:create(strImage, strImage, strImage)		
		local menu = CCMenu:create()
		menu:addChild(item2,1,99)
		menu:alignItemsVertically()
		menu:setPosition(ccp(0,0));
		local function menuCallback2(sender)
			cclog("Menu"..tostring(idx));
		end
		item2:setEnabled(true);
		item2:registerScriptTapHandler(menuCallback2)
		cell:addChild(menu, 1);
		--]]
    end
    return cell;
end

--单元行数
function p.numberOfCellsInTableViewRow(table)
   return 1;
end

--单元列数
function p.numberOfCellsInTableViewCol()
	return 1;
end

