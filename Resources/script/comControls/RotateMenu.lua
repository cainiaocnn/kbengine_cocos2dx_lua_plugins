RotateMenu = {}

function RotateMenu.create()
	local p = {};
	p.menuLayer = nil;
	p._angle = 0;
	p._unitAngle = 0;
	p._selectedItem = nil;
	p.animationDuration = 0.3;
	p._items = {};
	p.prev = {x = 0, y = 0}
	p.m_tBeginPos = ccp(0, 0)
	p._bMoveType = false;
	PI = 3.141592654535;
	
	function p.onTouchBegan(x, y)
		p.prev.x = x
		p.prev.y = y
			
		p.m_tBeginPos.x = x;
		p.m_tBeginPos.y = y;
		p._bMoveType = false;
		local size = table.getn(p._items);
		for i=0, size-1 do
			p._items[i + 1]:stopAllActions();  
		end
		
		if p._selectedItem ~= nil then
			p._selectedItem:unselected();
			--p._selectedItem:setEnabled(false);			
		end
		
		local position = p.menuLayer:convertToNodeSpace(ccp(x, y));
		local size = p.menuLayer:getContentSize(); 
		local rect =  CCRectMake(0, 0, size.width, size.height);  
		local b =  rect:containsPoint(position);
		if b then
			return true;
		end
		
		return false;
	end

	function p.onTouchMoved(x, y)
		p._bMoveType = true;
		--p.m_tBeginPos = ccp(x, y)
		local angle = p.disToAngle(x - p.prev.x);
		p.setAngle(p.getAngle() + angle);
		p.updatePosition();
		
		p.prev.x = x
		p.prev.y = y
		
		return;
	end

	function p.onTouchEnded(x, y)

		local xDelta = x - p.m_tBeginPos.x;
		p.rectify(xDelta > 0);
		-- local nAng1 = p.disToAngle(math.abs(xDelta));
		-- print("====nAng1£º" .. nAng1)
		-- local nAng2 = p.getUnitAngle()/10;
		-- print("====nAng2£º" .. nAng2)
		if p.disToAngle(math.abs(xDelta)) < p.getUnitAngle()/50 and p._selectedItem ~= nil then 
			p._selectedItem:activate();
		end
		p.updatePostionWithAnimation();
	end

	function p.onTouch(eventType, x, y)
		if eventType == "began" then
			return p.onTouchBegan(x, y)
		elseif eventType == "moved" then
			return p.onTouchMoved(x, y)
		elseif  eventType == "ended" then
			return p.onTouchEnded(x, y)
		end
	end
		
	function p.addMenuItem(item)
		local menuSize = p.menuLayer:getContentSize();
		local disY = menuSize.height/2;
		local disX = menuSize.width/2;
		
		item:setPosition(ccp(disX,disY));
		p.menuLayer:addChild(item); 
		table.insert(p._items,item);
		local size = table.getn(p._items)
		p.setUnitAngle(2*PI/size);
		p.reset();
		p.updatePostionWithAnimation();
	end

	function p.updatePosition()
		local menuSize = p.menuLayer:getContentSize();
		local disY =0-- menuSize.height/15;
		local disX = menuSize.width/3;
		local size = table.getn(p._items);
		for i=0, size-1 do
			local x = menuSize.width / 2 + disX*math.sin(i*p._unitAngle+p.getAngle());  
			local y = menuSize.height / 2 + disY*math.cos(i*p._unitAngle+p.getAngle());  
			p._items[i+1]:setPosition(ccp(x,y));
			local nFadeValue = 192 + 63 * math.cos(i*p._unitAngle+p.getAngle());
			p._items[i+1]:setOpacity(nFadeValue);
			p._items[i+1]:setZOrder(nFadeValue);
			--p._items[i+1]:setEnabled(false);
			p._items[i+1]:setScale(0.85 + 0.15 * math.cos(i*p._unitAngle+p.getAngle()));
		end
	end

	function p.updatePostionWithAnimation()
		local size = table.getn(p._items);

		for i=0, size - 1 do
			p._items[i + 1]:stopAllActions();  
		end
		
		local menuSize = p.menuLayer:getContentSize();
		local disY =0 --menuSize.height/15;
		local disX = menuSize.width/3;
		
		for i=0, size - 1 do
			local x = menuSize.width / 2 + disX*math.sin(i*p._unitAngle+p.getAngle());  
			local y = menuSize.height / 2 + disY*math.cos(i*p._unitAngle+p.getAngle());  
			local moveTo = CCMoveTo:create(p.animationDuration, ccp(x,y))
			p._items[i + 1]:runAction(moveTo);  
			
			local nFadeValue = 192 + 63 * math.cos(i*p._unitAngle+p.getAngle());
			local fadeTo = CCFadeTo:create(p.animationDuration, nFadeValue)
			p._items[i + 1]:runAction(fadeTo);  
			
			local scaleTo = CCScaleTo:create(p.animationDuration, 0.85 + 0.15 * math.cos(i*p._unitAngle+p.getAngle()))
			p._items[i + 1]:runAction(scaleTo);  
			p._items[i + 1]:setZOrder(nFadeValue);
		end
		
		Scheduler.scheduleNodeOnce(p.menuLayer, p.actionEndCallBack, p.animationDuration);
	end

	function p.rectify(forward)
		local angle = p.getAngle();

		while(angle<0) do
			angle = angle + PI * 2;  
		end
		
		while(angle>PI * 2) do
			angle = angle - PI * 2;  
		end
		
		if forward == true then
			angle = getIntPart(((angle + (p.getUnitAngle() / 3)*2)/p.getUnitAngle())) * p.getUnitAngle();
			-- print(angle)
			-- angle = getIntPart(angle);
		else
			angle = getIntPart(((angle + p.getUnitAngle() / 3)/p.getUnitAngle())) * p.getUnitAngle();
			-- print(angle)
			-- angle = getIntPart(angle);
		end

		
		p.setAngle(angle);
	end

	function p.init()
		p._angle = 0;
		p._items = {};
		p.menuLayer:ignoreAnchorPointForPosition(false);  
		p._selectedItem = nil;
		local s = CCDirector:sharedDirector():getWinSize();
		p.menuLayer:setContentSize(CCSizeMake(s.width, s.height/3*2));
		p.menuLayer:setAnchorPoint(ccp(0.5,0.5));
	end

	function p.reset()
		p._angle = 0; 
	end

	function p.setAngle(angle)
		p._angle = angle; 
	end

	function p.getAngle()
		return p._angle;
	end

	function p.setUnitAngle(angle)
		p._unitAngle = angle;  
	end

	function p.getUnitAngle()
	   return p._unitAngle;
	end

	function p.disToAngle(dis)
		local menuSize = p.menuLayer:getContentSize();
		local  width = menuSize.width / 2;  
		return dis/width*p.getUnitAngle();  
	end

	function p.getCureentItem()
		local size = table.getn(p._items);
		if size == 0 then
			return nil;
		end
		
		local index = ((2 * PI - p.getAngle())/ p.getUnitAngle() + 0.1 * p.getUnitAngle());
		index = getIntPart(index);

		index = index % size;
		return p._items[index + 1];
	end

	function p.actionEndCallBack()
		p._selectedItem  = p.getCureentItem();
		if p._selectedItem ~= nil then
			p._selectedItem:selected();
			--p._selectedItem:setEnabled(true);		
		end
	end


	p.menuLayer = CCLayer:create()
    p.menuLayer:setTouchEnabled(true)
    p.menuLayer:registerScriptTouchHandler(p.onTouch)
	p.init();
	
	function p.regeitTouchHandler()
		 p.menuLayer:setTouchEnabled(true)
		 p.menuLayer:registerScriptTouchHandler(p.onTouch)
	end
	
	return p;
end



--[[	example
		--test hgw
		local function pCall(index)
			print(index);
		end
		
		local pLayer = RotateMenu.create();
		pLayer.menuLayer:setContentSize(CCSizeMake(740,320))
		local item1 = CCMenuItemImage:create("res/UserUI/Guild/expedition.png", "res/UserUI/Guild/expedition.png")
		item1:registerScriptTapHandler(pCall)
		local item2 = CCMenuItemImage:create("res/UserUI/Guild/guild_pve.png", "res/UserUI/Guild/guild_pve.png")
		item2:registerScriptTapHandler(pCall)
		local item3 = CCMenuItemImage:create("res/UserUI/Guild/TeamBattle.png", "res/UserUI/Guild/TeamBattle.png")
		item3:registerScriptTapHandler(pCall)
		pLayer.addMenuItem(item1);
		pLayer.addMenuItem(item2);
		pLayer.addMenuItem(item3);
		
		pLayer.menuLayer:setPosition(ccp(320,600));
		p.layer:addChild(pLayer.menuLayer,2000,2000);
		--]]