--弹幕效果封装
BarrageLayer = {}
local p = BarrageLayer;
p.menuLayer = nil;
p.Index = 8;
--当前是否有新增字幕
p.bNewAdd = false; 

--弹幕颜色
local numcolors = {
    [0] = ccc3(0x77,0x6e,0x65),
    [1] = ccc3(0x77,0x6e,0x65),
    [2] = ccc3(0x77,0x6e,0x65),
    [3] = ccc3(0x77,0x6e,0x65),
    [4] = ccc3(0x77,0x6e,0x65),
    [5] = ccc3(0x77,0x6e,0x65),
    [6] = ccc3(0x77,0x6e,0x65),
    [7] = ccc3(0x77,0x6e,0x65),
}

function p.create(height)
	p.menuLayer = CCLayer:create()
	p.menuLayer:ignoreAnchorPointForPosition(false);  
	local s = CCDirector:sharedDirector():getWinSize();
	p.menuLayer:setContentSize(CCSizeMake(s.width, height));
	p.menuLayer:setAnchorPoint(ccp(0.5,0.5));
	
	--[[p.menuLayer2 = CCLayer:create()
	math.randomseed(os.time());
	local nNum = math.random(1,7);
	local function func1()
		p.AccordOneWordLabel("弹幕效果测试");
	end
	p.menuLayer:addChild(p.menuLayer2);
	Scheduler.scheduleNode(p.menuLayer2, func1, 1);]]--

	return p;
end

--显示一条弹幕(传入显示内容)
function p.AccordOneWordLabel(word)
	local wordSize = 30;	--弹幕大小
	local wordPosY = 0;		--弹幕初始高度
	local wordSpeed = 0;	--弹幕速度
	local spaceY = 28; 		--弹幕Y轴间距

	
	wordPosY = p.Index * spaceY;
	p.Index = p.Index - 1;
	if p.Index < 0 then 
		p.Index = 8;
	end
	
	math.randomseed(os.time());
	local wordSpeed = 10 + math.random(0,5);
	local size = CCDirector:sharedDirector():getWinSize();
	local label = CCLabelTTF:create(word, "Marker Felt", wordSize);
	if label ~= nil then 
		label:setAnchorPoint(ccp(0,0.5));
		label:setPosition(ccp(size.width+320, wordPosY+480));
		
		local move = CCMoveBy:create(wordSpeed, ccp(-size.width * 2,0))
		local array = CCArray:create()
		array:addObject(move);
		array:addObject(CCRemoveSelf:create());
		local seq = CCSequence:create(array);
		label:runAction(seq);
		p.menuLayer:addChild(label,100,100);
		
		p.menuLayer:stopAllActions();
		local function func2()
			p.Index = 8;
		end
		Scheduler.scheduleNodeOnce(p.menuLayer, func2, 2);
	
	end

end