-- 客户端热更新文件
-- 说明:
--[[
1:热更新下载文件存在
	local fileWritePath = CCFileUtils:sharedFileUtils():getWritablePath();
	local sDownLoadPath = fileWritePath.."down/";
	
2:解压后的文件存放在
	local fileWritePath = CCFileUtils:sharedFileUtils():getWritablePath();
	local sUnCompressPath = fileWritePath.."Resources/";
	
3:热更新后的zip包只允许有三个文件夹
	解压完毕后需要添加三个目录
	fileWritePath+Resources/
	fileWritePath+Resources/res/
	fileWritePath+Resources/script/
--]]
GameUpdate = {};
local p = GameUpdate;
local pUpdateLayer = nil;
local ui = nil;

local ASSETSMANAGER_MESSAGE_UPDATE_SUCCEED             =   0;
local ASSETSMANAGER_MESSAGE_RECORD_DOWNLOADED_VERSION  =   1;
local ASSETSMANAGER_MESSAGE_PROGRESS                   =   2;
local ASSETSMANAGER_MESSAGE_ERROR                      =   3;
local ASSETSMANAGER_MESSAGE_VERSION                    =   4;

local m_NowUpToVersion = nil;

local m_IsLoginOut = false;

function p.SetLoginOut(bLoginOut)
	m_IsLoginOut = bLoginOut
end

function p.IsGameLoginOut()
	return m_IsLoginOut;
end

function p.CreateLayer(callFunc)
	pUpdateLayer = TouchGroup:create();
	ui = GUIReader:shareReader():widgetFromJsonFile("UserUI/LoginLoad.json");		
	local pCarImage = p.GetUINode("Image_card", "ImageView")
	if pCarImage ~= nil then
		local arry = CCArray:create();
		arry:addObject(CCOrbitCamera:create(2,1, 0, 0, 360, 0, 0))
		arry:addObject(CCDelayTime:create(1))
		local seq = CCSequence:create(arry);
		local repAction = CCRepeatForever:create(seq);
		pCarImage:runAction(repAction);
	end
	local pLabel = p.GetUINode("Label_State", "Label")
	if pLabel ~= nil then
		if callFunc ~= nil then
			pLabel:runAction(CCCallFunc:create(callFunc));
		end
	end
	
	local pLabel2 = p.GetUINode("Label_cardDes_1_2", "Label")
	pLabel2:setText(ZhTextSet_30347);
		
	p.setShowLabel(ZhTextSet_30341);
	p.setShowLabel(ZhTextSet_30341);
	pUpdateLayer:addWidget(ui);
	return pUpdateLayer;
end
	
function p.setShowLabel(strLabel)
	local pLabel = p.GetUINode("Label_State", "Label")
	if pLabel ~= nil then
		pLabel:setText(strLabel);
	end
end
	
function p.updateProcess(fPercent)
	local pWidget = UIHelper:seekWidgetByName( ui, "ProgressBar_load");
	local pProgress = tolua.cast(pWidget, "LoadingBar")
	if pProgress ~= nil then
		if fPercent >=0 and fPercent <= 100 then
			pProgress:setPercent(fPercent);
			local pLabel = p.GetUINode("Label_pro", "Label");
			if pLabel ~= nil then
				pLabel:setText(tostring(fPercent));
			end
		end
	end
end

function p.runShowIntroduce()
	local pLabel5 = p.GetUINode("Label_cardDes", "Label")
	if pLabel5 ~= nil then
		local pLabel1 = p.GetUINode("Label_cardDes_0", "Label")		--1
		local pLabel2 = p.GetUINode("Label_cardDes_1_2", "Label")	--2
		local pLabel3 = p.GetUINode("Label_cardDes_1", "Label")		--3
		-- local pLabel4 = p.GetUINode("Label_cardDes_2", "Label")
		local function listener()
			if pLabel1 ~= nil and pLabel2 ~= nil and pLabel3~= nil then
				local strTb = GameUpdateInfo.GetUpdateWords(nil);
				pLabel1:setText(tostring(strTb[1]));
				pLabel2:setText(tostring(strTb[2]));
				pLabel3:setText(tostring(strTb[3]));
				-- pLabel4:setText(tostring(strTb[4]));
				-- pLabel5:setText(tostring(strTb[5]));
			end
		end
		--
		p.ShowIntroduce(GameUpdateInfo.GetUpdateWords(1));
		local delay = CCDelayTime:create(4);
		local sequence = CCSequence:createWithTwoActions(delay, CCCallFunc:create(listener));
		pLabel5:runAction(CCRepeatForever:create(sequence))
	end
end

-- 显示更新期间的趣意段子
function p.ShowIntroduce(tWorlds)
	if tWorlds ~= nil then
		local pLabel5 = p.GetUINode("Label_cardDes", "Label")
		if pLabel5 ~= nil then
			pLabel5:stopAllActions()
			local pLabel1 = p.GetUINode("Label_cardDes_0", "Label")
			local pLabel2 = p.GetUINode("Label_cardDes_1_2", "Label")
			local pLabel3 = p.GetUINode("Label_cardDes_1", "Label")
			-- local pLabel4 = p.GetUINode("Label_cardDes_2", "Label")
			if pLabel1 ~= nil and pLabel2 ~= nil and pLabel3~= nil then
				pLabel1:setText(tostring(tWorlds[1]));
				pLabel2:setText(tostring(tWorlds[2]));
				pLabel3:setText(tostring(tWorlds[3]));
				-- pLabel4:setText(tostring(tWorlds[4]));
				-- pLabel5:setText(tostring(tWorlds[5]));
			end
		end
	end
end

-- 获取节点
function p.GetUINode(nodeName, strNode)
	local pWidget = UIHelper:seekWidgetByName( ui, nodeName);
	local pNode = tolua.cast(pWidget, strNode)
	if pNode ~= nil then
		return pNode;
	end
	return nil;
end

-- 热更新脚本回调函数
function p.HttpRespond(logMessage, pAcceptObject)
	local pArray = tolua.cast(pAcceptObject,"CCArray");
	if pArray ~= nil then
		local pCodeValue   =  tolua.cast(pArray:objectAtIndex(0),"CCInteger");
		if pCodeValue ~= nil then
			local nCode = pCodeValue:getValue();
			cclog("nCode="..nCode);
			
			--请求服务器的客户端版本号
			if nCode == ASSETSMANAGER_MESSAGE_VERSION then
				local nClienVersion = 0;
				local pSeverVersion = tolua.cast(pArray:objectAtIndex(1),"CCInteger");
				if pSeverVersion ~= nil then
					local nSeverVersion = pSeverVersion:getValue();
					cclog("---nSeverVersion="..nSeverVersion);
					local pCGameUpdate = CGameUpdate:sharedGameUpdate();
					if pCGameUpdate ~= nil then
						nClienVersion = pCGameUpdate:getClienVersion();
						cclog("---nClienVersion="..nClienVersion);
					end
					local pGameUpdate = CGameUpdate:sharedGameUpdate();
					if nSeverVersion > nClienVersion then
						cclog("---nSeverVersion > nClienVersion");
						p.setShowLabel(ZhTextSet_30342);
						if pGameUpdate ~= nil then
							p.runShowIntroduce();
							--重新创建
							local fileWritePath = CCFileUtils:sharedFileUtils():getWritablePath();
							local sDownLoadPath = fileWritePath.."down/";
							pGameUpdate:setDownLoadPath(sDownLoadPath);
							
							m_NowUpToVersion = nClienVersion + 1;
							local filePakageName = nClienVersion.."_"..m_NowUpToVersion..".zip";
							pGameUpdate:downLoadFile(GameConfig.DownLoadUrl, filePakageName);
						end
					else
						if pGameUpdate ~= nil then
							p.AfterUpdateVersion(pGameUpdate);
						end
					end
				end
			--请求下载文件进度
			elseif nCode == ASSETSMANAGER_MESSAGE_PROGRESS then
				local pPercent = tolua.cast(pArray:objectAtIndex(1),"CCInteger");
				if pPercent ~= nil then
					local nPercent = pPercent:getValue();
					cclog("---Lua Percent.."..nPercent);
					p.updateProcess(nPercent);
				end
			--下载文件成功
			elseif nCode == ASSETSMANAGER_MESSAGE_RECORD_DOWNLOADED_VERSION then
				local pFileName = tolua.cast(pArray:objectAtIndex(1),"CCString");
				if pFileName ~= nil then
				
					local sFileName = pFileName:getCString();
					local str = ZhTextSet_30343 ..tostring(sFileName).."..."
					p.setShowLabel(str);
					cclog("---Lua DownLoad Success.."..sFileName);
					local pGameUpdate = CGameUpdate:sharedGameUpdate();
					if pGameUpdate ~= nil then
						local fileWritePath = CCFileUtils:sharedFileUtils():getWritablePath();
						cclog("---------"..fileWritePath)
						local sDownLoadPath = fileWritePath.."down/"..sFileName;
						cclog(sDownLoadPath)
						pGameUpdate:uncompress(sDownLoadPath,true);
					end
				end
			--更新成功
			elseif nCode == ASSETSMANAGER_MESSAGE_UPDATE_SUCCEED then
				--更新客户端版本号
				local pGameUpdate = CGameUpdate:sharedGameUpdate();
				if pGameUpdate ~= nil then
					local nSeverClientVersion = pGameUpdate:getSeverVersion();
					-- pGameUpdate:setClienVersion(nSeverClientVersion);
					pGameUpdate:setClienVersion(m_NowUpToVersion);
					if m_NowUpToVersion < nSeverClientVersion then
						p.setShowLabel(ZhTextSet_30341);
						pGameUpdate:checkSeverVersion();						
					else
						p.AfterUpdateVersion(pGameUpdate);
					end
				end
			--错误异常
			elseif nCode == ASSETSMANAGER_MESSAGE_ERROR then
				--错误ID
				local nErrorCode = tolua.cast(pArray:objectAtIndex(1),"CCInteger");
				if nErrorCode == -1 then
					p.ShowIntroduce(GameUpdateInfo.GetUpdateWords(2));
				else
					p.ShowIntroduce(GameUpdateInfo.GetUpdateWords(2));
				end
				p.setShowLabel(ZhTextSet_30344);
			end
		end
	end
end	


--检查更新结束后请求选服列表数据
function p.AfterUpdateVersion(pGameUpdate)
	
	p.setShowLabel(ZhTextSet_30345);
	local function funcErrorFunc()
		p.ShowIntroduce(GameUpdateInfo.GetUpdateWords(3));
	end
	GameLoginService.GetServerList(p.AfterGetServiceList , funcErrorFunc)
end

--热更新执行完毕后执行脚本函数
function p.AfterGetServiceList()
	local pGameUpdate = CGameUpdate:sharedGameUpdate();
	if pGameUpdate ~= nil then
		local targetPlatform = CCApplication:sharedApplication():getTargetPlatform()
		if kTargetWindows == targetPlatform then --WIN
			-- 执行游戏入口脚本
			p.setShowLabel(ZhTextSet_30346);
			pGameUpdate:enterGameExecuteScriptFile("entryScript.lua");
		elseif kTargetAndroid == targetPlatform then --Android
			-- 告诉平台更新更新完毕,准备执行进入游戏入口脚本
			if pUpdateLayer ~= nil then						
				--[[
				local delay = CCDelayTime:create(1);
				local function listener()
					if CGameForSDK:sharedCGameForSDK():GetLoginSuccess() == 1 then
						p.setShowLabel("进入游戏...");
						pGameUpdate:enterGameExecuteScriptFile("entryScript.lua");
					else
						cclog("***Waiting For Android SDK Login Return***");
					end
				end
				local sequence = CCSequence:createWithTwoActions(delay, CCCallFunc:create(listener));
				pUpdateLayer:runAction(CCRepeatForever:create(sequence))
				--]]
				p.setShowLabel(ZhTextSet_30346);
				pGameUpdate:enterGameExecuteScriptFile("entryScript.lua");
			else
				cclog("***Android Login Failed By SDK Dure To(pUpdateLayer=nil)***");
			end
		else --IOS
			p.setShowLabel(ZhTextSet_30346);
			pGameUpdate:enterGameExecuteScriptFile("entryScript.lua");
		end
	end
end

--执行热更新函数
-- 参数1:是否执行热更新
function p.UpdateEntery(bUpdateVersion)
	
	--
	local pDirector = CCDirector:sharedDirector()
	if pDirector ~= nil then
		pDirector:setBackground("res/UserUI/temp/back.jpg");
	end
	--]]
	
	-- 是否检测版本更新
	if bUpdateVersion then
		-- 添加搜索路径
		p.AddSearchPath();
		-- 执行游戏场景
		local sceneGame = CCScene:create();
		-----------------------------------------------
		--确保函数是在场景加载后运行
		local function callFunc()
			local pGameUpdate = CGameUpdate:sharedGameUpdate();
			if pGameUpdate ~= nil then
				--无论什么平台都执行热更新
				local fileWritePath = CCFileUtils:sharedFileUtils():getWritablePath();
				local sDownLoadPath = fileWritePath.."down/";
				local sUnCompressPath = fileWritePath.."Resources/";
				pGameUpdate:setDownLoadPath(sDownLoadPath);
				pGameUpdate:setUnCompressPath(sUnCompressPath);
				pGameUpdate:setServerVersionUrl(GameConfig.CheckVersionUrl);
				pGameUpdate:registerScriptHandler(p.HttpRespond);
				
				pGameUpdate:checkSeverVersion();
				
				--[[
				-- 执行检查更新
				if kTargetWindows == targetPlatform then --WIN
					--WIN32不执行热更新代码
					pGameUpdate:checkSeverVersion();
				elseif kTargetAndroid == targetPlatform then
					--Android
					pGameUpdate:checkSeverVersion();
				else --IOS
					pGameUpdate:checkSeverVersion();
				end
				--]]
			end	
		end
		-----------------------------------------------
		local layerMenu = p.CreateLayer(callFunc);
		sceneGame:addChild(layerMenu);
		if not m_IsLoginOut then
			CCDirector:sharedDirector():runWithScene(sceneGame);
		else
			CCDirector:sharedDirector():replaceScene(sceneGame);
		end
	else
		local pGameUpdate = CGameUpdate:sharedGameUpdate();
		if pGameUpdate ~= nil then
			pGameUpdate:enterGameExecuteScriptFile("entryScript.lua");
		end
	end
end

--添加搜索路径
function p.AddSearchPath()
	local fileWritePath = CCFileUtils:sharedFileUtils():getWritablePath();
	--添加搜索路径到最先搜索
	--最后搜索脚本路径
	local script		= fileWritePath.."Resources/script/";
	CCFileUtils:sharedFileUtils():addSearchPathToFront(script);
	--再然后资源包中的GUI资源
	CCFileUtils:sharedFileUtils():addSearchPathToFront("res/UserUI/");
	--然后资源部的内部资源
	CCFileUtils:sharedFileUtils():addSearchPathToFront("res/");
	--其次下载Gui的路径
	local guiResExt		= fileWritePath.."Resources/res/UserUI/";
	CCFileUtils:sharedFileUtils():addSearchPathToFront(guiResExt);
	--最先搜索下载的资源
	local resExt		= fileWritePath.."Resources/res/";
	CCFileUtils:sharedFileUtils():addSearchPathToFront(resExt);
end
