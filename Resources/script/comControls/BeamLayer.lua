--闪亮标题效果
BeamLayer = {}
local p = BeamLayer;
p.clipTitle = nil;

function p.create(res, pos)
	--local titleStencil = CCSprite:create("res/UserUI/temp/logo.png");
	local titleStencil = CCSprite:create("res/UserUI/temp/logo.png");
	p.clipTitle = CCClippingNode:create(titleStencil);  
    p.clipTitle:setAnchorPoint(ccp(0.5,0.5));  
    --p.clipTitle:setPosition(ccp(311,655));  
	p.clipTitle:setPosition(pos); 
    p.clipTitle:setAlphaThreshold(0);  
    layer:addChild(p.clipTitle); 

    --Beam 光束  
    local beam = CCSprite:create("res/UserUI/temp/beam.png");  
    beam:setAnchorPoint(ccp(0.5, 0.5));  
    local toRight = CCMoveTo:create(0.5, ccp(200, 50));  
    local toLeft = CCMoveTo:create(0.5, ccp(-200, 50));  
	local seq = CCSequence:createWithTwoActions(toRight, toLeft)
    local move = CCRepeatForever:create(seq);  
    beam:runAction(move);  
    p.clipTitle:addChild(beam);
	return p;
end
