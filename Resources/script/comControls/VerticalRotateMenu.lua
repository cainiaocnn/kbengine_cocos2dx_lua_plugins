-- @module
VerticalRotateMenu = {}
local p = VerticalRotateMenu;

function p.create(nSize)
	local tMenu = {};
	
	tMenu.itemVec = {};
	tMenu._lastIndex = 0;   
	tMenu._index = 0;
	tMenu._selectedItem = nil;
	tMenu._beganPos = {x=0,y=0};
	tMenu._curPos ={x=0,y=0};
	tMenu.ScrollCall = nil;
	tMenu.prev = {x = 0, y = 0}
	tMenu._layer = Layout:create();
	tMenu._layer:setTouchEnabled(true);
	tMenu._layer:setClippingEnabled(true);
	
	tMenu.endCallFunc = nil;
	local ANIMATION_DURATION = 0.3;
	local MENU_SCALE = 0.5 ;
	local MENU_ASLOPE = 60
	local ITEM_SIZE_SCALE = 0.3;
	
	tMenu.pSize = nSize;
	tMenu._layer:ignoreAnchorPointForPosition(false);  
	tMenu._layer:setSize(tMenu.pSize);
	
	function tMenu:setEndCallback(callFunc)
		tMenu.endCallFunc = callFunc;
	end
	
	function tMenu:onTouchBegan(x, y)
		tMenu._beganPos.x = x;
		tMenu._beganPos.y = y;
		tMenu.prev.x = x
		tMenu.prev.y = y
		for k,v in pairs(tMenu.itemVec) do
			v:stopAllActions();
		end
		if (tMenu._selectedItem) then
			tMenu._selectedItem:unselected(); 
		end
		local position = tMenu._layer:convertToNodeSpace(ccp(x,y));  
		local size = tMenu._layer:getContentSize();      
		local rect = CCRect(0, 0, size.width, size.height);      
		if (rect:containsPoint(position)) then
			return true; 
		end
		return false;  
	end

	function tMenu:onTouchMoved(x, y)
		local xDelta = y - tMenu.prev.y;      
		local size = tMenu._layer:getContentSize();
		tMenu._lastIndex = tMenu._index;    
		tMenu._index = tMenu._index -  (xDelta / (size.width *ITEM_SIZE_SCALE));  
		tMenu:updatePosition();    
		
		tMenu.prev.x = x
		tMenu.prev.y = y
		return;   
	end

	function tMenu:onTouchEnded(x, y)
		 local size = tMenu._layer:getContentSize();    
		 local xDelta = y - tMenu._beganPos.y;     
		 tMenu:rectify(xDelta>0);      
		 if (math.abs(xDelta) < size.width / 3 and tMenu._selectedItem) then     
			tMenu._selectedItem:activate();
		 end			 
		 tMenu:updatePositionWithAnimation();      
		 return;   
	end
	 

	function onTouch(sender,eventType)
		if eventType == ccs.TouchEventType.began then
		   local point = sender:getTouchStartPos();
           tMenu:onTouchBegan(point.x, point.y)
        elseif eventType == ccs.TouchEventType.moved then
		   local point = sender:getTouchMovePos();
           tMenu:onTouchMoved(point.x, point.y)
        elseif eventType == ccs.TouchEventType.ended then
		   local point = sender:getTouchEndPos();
           tMenu:onTouchEnded(point.x, point.y)
		elseif eventType == ccs.TouchEventType.canceled then  
		   local point = sender:getTouchEndPos();
           tMenu:onTouchEnded(point.x, point.y)
        end
	end
	
	function tMenu:rectify(forward)
		local index = tMenu:getIndex();  
		if (index <= 0)  then 
			index = 1; 
		end
		if (index > GetTableNum(tMenu.itemVec) )  then   
			index = GetTableNum(tMenu.itemVec);
		end
		if (forward) then
			index = getIntPart(index + 0.5); 
		else  
			index = getIntPart(index + 0.5);  
		end
		if (index <= 0)  then 
			index = 1; 
		end
		tMenu:setIndex(index);   
	end
	
	function tMenu:SetFordIndexWithAction(forward)
		local index = tMenu:getIndex();  
		if (index <= 0)  then 
			index = 1; 
		end
		if (index > GetTableNum(tMenu.itemVec))  then   
			index = GetTableNum(tMenu.itemVec);
		end

		index = index + forward; 
		
		if (index <= 0)  then 
			index = 1; 
		end
		if (index > GetTableNum(tMenu.itemVec) )  then   
			index = GetTableNum(tMenu.itemVec);
		end
		tMenu:setIndex(index);   
		tMenu:updatePositionWithAnimation();
	end
	
	function tMenu:SetForwardByIndex(nIndex)
		tMenu:setIndex(nIndex);   
		tMenu:updatePosition();
		--tMenu:setColor(ccc3(128,128,128));
	end
	
	
	
	tMenu._layer:addTouchEventListener(onTouch)


	function tMenu:reset()
		tMenu._lastIndex = 1;   
		tMenu._index = 1;
	end
	
	function tMenu:IndexCorrect(nIndex)
		local nSize = #tMenu.itemVec;
		
		if nSize == 3 then
			if nIndex == 1 then 
				nIndex = 2 ;
			elseif nIndex == 2 then
				nIndex = 1;
			end
		end
		
		if nSize == 4 then
			if nIndex == 1 then 
				nIndex = 3 ;
			elseif nIndex == 3 then
				nIndex = 1;
			end
		end
		return nIndex;
	end
	
	local function calcFunction(index,width)
		return (width + width * 0.3)*index;
	end
			
	function tMenu:updatePosition()
		for k,v in pairs(tMenu.itemVec) do
			
			local y = calcFunction(k - tMenu._index, tMenu.pSize.height / 2);
			v:setPosition(ccp(tMenu.pSize.width/2, tMenu.pSize.height/2 + y));
			v:setZOrder(-math.abs(k - tMenu._index)*100)
			v:setScale(1- math.abs(calcFunction(k - tMenu._index,MENU_SCALE)));
			
			local nColorValue = 255 * (1- math.abs(calcFunction(k - tMenu._index,MENU_SCALE)));
			
			--v:setOpacity(255- math.abs(k - tMenu._index)*100);
			--v:setColor(ccc3(128,128,128));
			v:setColor(ccc3(nColorValue,nColorValue,nColorValue));
			--local orbit1 =  CCOrbitCamera:create(0, 1, 0, calcFunction(k - tMenu._lastIndex, MENU_ASLOPE),calcFunction(k - tMenu._lastIndex, MENU_ASLOPE) - calcFunction(k - tMenu._index, MENU_ASLOPE), 0,0)
			--v:runAction(orbit1);
		end
	end
	
	function tMenu:updatePositionWithAnimation()
		for k,v in pairs(tMenu.itemVec) do
			v:stopAllActions();
		end
		
		for k,v in pairs(tMenu.itemVec) do
			v:setZOrder(-math.abs((k - tMenu._index)*100));
			local y = calcFunction(k - tMenu._index ,tMenu.pSize.height / 2);
			local pMoveTo = CCMoveTo:create(ANIMATION_DURATION,ccp(tMenu.pSize.width / 2 ,tMenu.pSize.height / 2  + y))
			v:runAction(pMoveTo);
			local pScaleTo = CCScaleTo:create(ANIMATION_DURATION, (1 - math.abs(calcFunction(k - tMenu._index,MENU_SCALE))));
			v:runAction(pScaleTo);
			--local  orbit1 = CCOrbitCamera:create(ANIMATION_DURATION, 1, 0, calcFunction(k - tMenu._lastIndex,MENU_ASLOPE),calcFunction(k - tMenu._index, MENU_ASLOPE) - calcFunction(k - tMenu._lastIndex, MENU_ASLOPE), 0,0)
			--v:runAction(orbit1);
		end
		
		local function HandCall()
			tMenu:actionEndCallBack();
		 end
		Scheduler.performWithDelayGlobal(HandCall, ANIMATION_DURATION)
	end
	
	function tMenu:actionEndCallBack()
		if  (tMenu._selectedItem) then
			tMenu._selectedItem:setColor(ccc3(128,128,128));
		end
		 tMenu._selectedItem = tMenu:getCurrentItem();
		 if (tMenu._selectedItem) then
			tMenu._selectedItem:selected(); 
			tMenu._selectedItem:setColor(ccc3(255,255,255));
			--tMenu._selectedItem:setColor(COLOR_TYPE.White)
			if tMenu.endCallFunc ~= nil then
				tMenu.endCallFunc(tMenu._selectedItem:getTag())
			end

			if tMenu.ScrollCall ~= nil then
				if tMenu._index ~= -1  then
					tMenu.ScrollCall(tMenu._index)
				end
			end
		 end
	end
	
	--对外接口1
	function tMenu:addMenuItem(item)
		if item ~= nil then
			item:setPosition(ccp(tMenu.pSize.width / 2,tMenu.pSize.height / 2))
			tMenu._layer:addNode(item);
			table.insert(tMenu.itemVec,item);
			tMenu:reset();
			tMenu:updatePosition();   
		end
	end
	
	function tMenu:setRigisterScrollEvent(pCallback)
		tMenu.ScrollCall = pCallback;
		
	end
	
	function tMenu:setIndex(index)
		tMenu._lastIndex = index; 
		tMenu._index = index;
	end
	
	function tMenu:getIndex()
		return tMenu._index;
	end
	
	function tMenu:getCurrentItem()
		return tMenu.itemVec[tMenu._index];
	end
	
	
	return tMenu;
end


--[[ example
		--test ljm
		local function pCall(index)
			print(index);
		end
		local function pCallRollex(index)
			print(index);
		end
		local pLayer = UIHeroScrov.create();
		local item1 = CCMenuItemImage:create("res/UserUI/Guild/expedition.png", "res/UserUI/Guild/expedition.png")
		item1:registerScriptTapHandler(pCall)
		local item2 = CCMenuItemImage:create("res/UserUI/Guild/guild_pve.png", "res/UserUI/Guild/guild_pve.png")
		item2:registerScriptTapHandler(pCall)
		local item3 = CCMenuItemImage:create("res/UserUI/Guild/TeamBattle.png", "res/UserUI/Guild/TeamBattle.png")
		item3:registerScriptTapHandler(pCall)
		pLayer:addMenuItem(item1);
		pLayer:addMenuItem(item2);
		pLayer:addMenuItem(item3);
		
		pLayer:setRigisterScrollEvent(pCallRollex)
		
		pLayer._layer:setPosition(ccp(320,600));
		p.layer:addChild(pLayer._layer,2000,2000);
--]]

