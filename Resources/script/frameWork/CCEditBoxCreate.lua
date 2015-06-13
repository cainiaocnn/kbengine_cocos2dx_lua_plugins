-- 
-- 描述:输入框创建
CCEditBoxCreate = {};
local p = CCEditBoxCreate;

-- tSize, 
-- pszBackImage, 
-- nTouchPriority, 

function p:CreateEditBox(tSize, pszBackImage, nTouchPriority, aPoint, nFontSize, cColor, strPlaceHolder, cColor2, maxLen, fucHandle)
		
	local pEditName = CCEditBox:create(tSize, CCScale9Sprite:create(pszBackImage))
	pEditName:setTouchPriority(0);
	local targetPlatform = CCApplication:sharedApplication():getTargetPlatform()
	if kTargetIphone == targetPlatform or kTargetIpad == targetPlatform then
		pEditName:setFontName("Marker Felt")
	else
		pEditName:setFontName("fonts/Marker Felt.ttf")
	end
	pEditName:setAnchorPoint(aPoint); --ccp(0,0);
	pEditName:setFontSize(nFontSize);  --
	pEditName:setFontColor(cColor);	--ccc3(255,0,0)
	pEditName:setPlaceHolder(strPlaceHolder);
	pEditName:setPlaceholderFontColor(cColor2); --ccc3(255,255,255)
	pEditName:setMaxLength(maxLen);
	pEditName:setReturnType(kKeyboardReturnTypeDone);
	--Handler
	if fucHandle ~= nil then
		pEditName:registerScriptEditBoxHandler(fucHandle);
	else
		local function editBoxTextEventHandle(strEventName,pSender)
		end
		pEditName:registerScriptEditBoxHandler(editBoxTextEventHandle);
	end
	return pEditName;
end
