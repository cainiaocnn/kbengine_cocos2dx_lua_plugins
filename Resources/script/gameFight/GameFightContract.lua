--关卡战斗请求

GameFightContract = {
	
	_NormalStageId = nil;

	_reqStageId = nil;
	_reqChangeStageId = nil;
	_dropList = {};
	_bHaveBoss = false;
	
	--竞技场
	_bHaveOPP  = false;
	_OPPUserID = nil;
	_OPPCallFunc = nil;
	
	--战斗回放
	_bHaveBattleLog = false;
	_RecordId = nil;
	_bBattleLogWin = false;
	_BattleLogCallFunc = nil;
	--
	
	--副本战斗
	_bHaveGuildBattel = false;
	_GuildId = nil;			--公会副本ID
	_GuildUserId = nil;		--公会玩家ID
	_GuildHeroId = nil;		--公会玩家英雄ID
	_GuildCallBack = nil;	--战斗结束回调函数	
	
	--活动之卡牌掉落战斗
	_bHaveCardBattel = false;
	_nCardHard	= nil;
	_nCardStageId = nil;
	_CardCallBack = nil;
	
	--工会战
	_bGongHuiBattle = false;
	_nGongHuiRepId	= nil;
	_bGongHuiBattleWin = false;
	_bGongHuiChangePos = false;
	_GongHuiBatteCallBack = nil;
	
	_BattleType = nil;--(上一场战斗类型)
};
--[[
_BattleType
0:巅峰战斗
1:普通战斗
2:Boss战斗
3:竞技场
4:战斗回放
5:副本
6:活动之卡牌掉落战斗
7:工会战
--]]

local p = GameFightContract;
local m_TimmerHandle = nil;
local m_IsFirstBegin = true;

--账号注销回调函数
function p.gameLoginOut()
	p._NormalStageId = nil;

	p._reqStageId = nil;
	p._reqChangeStageId = nil;
	p._dropList = {};
	p._bHaveBoss = false;
	
	--竞技场
	p._bHaveOPP  = false;
	p._OPPUserID = nil;
	p._OPPCallFunc = nil;
	
	--战斗回放
	p._bHaveBattleLog = false;
	p._RecordId = nil;
	p._bBattleLogWin = false;
	p._BattleLogCallFunc = nil;
	--
	
	--副本战斗
	p._bHaveGuildBattel = false;
	p._GuildId = nil;			--公会副本ID
	p._GuildUserId = nil;		--公会玩家ID
	p._GuildHeroId = nil;		--公会玩家英雄ID
	p._GuildCallBack = nil;	--战斗结束回调函数	
	
	--活动之卡牌掉落战斗
	p._bHaveCardBattel = false;
	p._nCardHard	= nil;
	p._nCardStageId = nil;
	p._CardCallBack = nil;
	
	--工会战
	p._bGongHuiBattle = false;
	p._nGongHuiRepId	= nil;
	p._bGongHuiBattleWin = false;
	p._bGongHuiChangePos = false;
	p._GongHuiBatteCallBack = nil;
	
	p._BattleType = nil;--(上一场战斗类型)
	m_TimmerHandle = nil
	m_IsFirstBegin = true;
end

--所有战斗总的请求
function p.BattleMainRequest( isFirst,bReConnect )
	
	local isWinFight  = false;
	local isBossFight = false;
	
	--显示战斗安全度
	if p._dropList.Info ~= nil or UserData.OnhookStageId ~= p._NormalStageId then
		GameFightCenter:ShowBattleInfo(p._dropList.Info);
		p._NormalStageId = UserData.OnhookStageId;
	else
		GameFightCenter:ShowBattleInfo(UserData.DropInfo);
	end
	
	if p._dropList.WinFlag == 1 then
		if p._dropList.isHaveData ~= nil then --预防没有数据时候进入函数导致错误
			-- 开始新一场战斗时候把上一场的物品掉落收集起来
			if p._BattleType == 2 or p._BattleType == 5 then
				 p.ShowGetNum(p._dropList, p._BattleType);
			else
				UICommonDrop.commonDrop(p._dropList);
			end
			
		end
		if p._BattleType == 2 then
			p.updateUserStage(p._dropList.StageID);			
		end

		if p._BattleType >= 2 then
			isBossFight = true;
			GameFightMusic.PlayFightEndMusic(true);
		end

		p._dropList = {};
		isWinFight =  true;
	else
		if p._BattleType ~= 1 and p._BattleType ~= 0 then
			GameFightMusic.PlayFightEndMusic(false);
		end
	end
	if bReConnect ~= true then
		if p._BattleType == 3 or p._BattleType == 4 or p._BattleType == 2  or p._BattleType == 7 or p._BattleType == 5  then 
			local nRank = nil;
			if p._BattleType == 3 then
				nRank = UserData.tArenaInfo.Rank;
			end
			p.ShowAreanResult(isWinFight, nRank);
		end
	end
	
	local function func()
		
		if p._BattleType ~= 1 and p._BattleType ~= 0 then
			GameFightMusic.RestPlayBackMusic()
			GameFightCenter.BattleBeginCall(true);
		end
		
		if p._BattleType == 3 then
			--竞技场战斗结束回调函数
			if p._OPPCallFunc~=nil then
				p._OPPCallFunc();
				p._OPPCallFunc = nil;
			end
		elseif p._BattleType == 4 then	
			-- 战斗回放结束回调函数
			if p._BattleLogCallFunc ~= nil then
				p._BattleLogCallFunc(isWinFight);
				p._BattleLogCallFunc = nil;
			end
		elseif p._BattleType == 5 then
			--公会副本
			if p._GuildCallBack ~= nil then
				p._GuildCallBack(isWinFight);
				p._GuildCallBack = nil;
			end
		elseif p._BattleType == 6 then
			--活动之卡牌掉落战斗
			if p._CardCallBack ~= nil then
				p._CardCallBack();
				p._CardCallBack = nil;
			end
		elseif p._BattleType == 7 then
			--公会战斗
			if p._GongHuiBatteCallBack ~= nil then
				p._GongHuiBatteCallBack();
				p._GongHuiBatteCallBack = nil;
			end
		end
	
		if p._bHaveBoss then
			GameFightCenter.ShowNextGate(nil, false);
			NetReq.ReqStageBoss(p._reqStageId,p.pBossCallback);
		elseif p._bHaveOPP then
			GameFightCenter.ShowNextGate(nil, false);
			NetReq.ReqBattleWithOpp(p._OPPUserID, p.pBattleWithOppCallback);
		elseif p._bHaveBattleLog then
			GameFightCenter.ShowNextGate(nil, false);
			NetReq.ReqShowPlayBattleRecord(p._RecordId, p.pShowFightLog)
		elseif p._bHaveGuildBattel then
			GameFightCenter.ShowNextGate(nil, false);
			NetReq.ReqFightGuildCopy(p._GuildId, p._GuildUserId, p._GuildHeroId, p.pGuildFightCallBack);
		elseif p._bHaveCardBattel then
			GameFightCenter.ShowNextGate(nil, false);
			NetReq.ReqOpenFightTCard(p._nCardStageId, p._nCardHard, p.pCardGetFightCallBack)
		elseif p._bGongHuiBattle then
			GameFightCenter.ShowNextGate(nil, false);
			NetReq.GetGuildFightRecord(p._nGongHuiRepId,p.pGongHuiFightCallBack);
		else
			p.ContractRequest();
		end
	end
	
	if isBossFight then
		p.DoCheerAction(func);
		GameFightTextBattle.AddBattleTextStr("\n胜利\n ",22, ccc3(0,0,0));
	else
		if isWinFight or isFirst then
			func();
			if isWinFight then
				GameFightTextBattle.AddBattleTextStr("\n胜利\n ",22, ccc3(0,0,0));
			end
			
		else			
			if p._BattleType == 0 then
				-- GameFightMusic.RestPlayBackMusic();
				func();
			else			
				local fTime = 10;
				if p._BattleType == 4 then
					fTime = 2;
				end
				if p._BattleType ~= 0 then
					p.DoFaildAction();
				end
				Scheduler.performWithDelayGlobal(func, fTime);
				GameFightTextBattle.AddBattleTextStr("\n失败\n",22, ccc3(0, 0, 0));			
			end
		end
	end
	
end

function p.ShowGetNum(tDrop,battleType)
	local message={}
	table.insert(message, {message="获得:", color=COLOR_TYPE.White})
	
	--掉落物品
	for k,v in pairs(tDrop.tItem) do
		UserData.AddGoodsItemNum(v);
		local cfg = CfgData.cfg_item[v.typeId]
		if v.typeId == 203 then
			local str = cfg.name .. "+"
			str = str..tostring(v.MutilNum);
			table.insert(message, {message=str, color=COLOR_TYPE.Orange,Itemtype = v.typeId})
		end
	end
	
	--经验
	if tDrop.Exp > 0 then
		UserData.AddExp(tDrop.Exp)
		local str = ZhTextSet_50028;
		str = str..tostring(tDrop.Exp);
		table.insert(message, {message=str, color=COLOR_TYPE.Green})
	end
	
	--金币
	if tDrop.Coin > 0 then
		AddCoin(tDrop.Coin);
		local str = ZhTextSet_50029;
		str = str..tostring(tDrop.Coin);
		table.insert(message, {message=str, color=COLOR_TYPE.Green})
	end
	
	for k,v in pairs(tDrop.tEquip) do
		local itemA = CfgData.cfg_equip[v.EquipmentType];
		local strName = GetAddWordEquipName(v);

		local nowcolor =  GetQualityColor(v.nQuality)
		strName = strName.."*1";
		table.insert(message, {message=strName,color = nowcolor})
		UserData.addEquipItem(v);
	end
	
	local function pGuildCall()
		local nValue = UserData.bDataByteValue(UserData.UserGuideNum,26);
		if nValue == 0 then
			local function pCallDig()
				local nNewStep = UserData.SetDataByteValue(UserData.UserGuideNum,26)
				NetReq.ReqSaveGuildIndex(nNewStep,UIGuide.SendGuildCall)
				UserData.UserGuideNum = nNewStep;
			end
			TipsManager.ShowSinglTalk(50157,pCallDig)
		end
	end
	OpenLayer(UI_TAG.UI_COMTIP,0,110);
	UIComTip.showMessage(message,0,pGuildCall);
	--p.ShowGetInfo(tDrop.tEquip,message);
end

function p.ShowGetInfo(tDEquip,message)
	for k,v in pairs(tDEquip) do
		local itemA = CfgData.cfg_equip[v.EquipmentType];
		local strName = GetAddWordEquipName(v);

		local nowcolor =  GetQualityColor(v.nQuality)
		strName = strName.."*1";
		table.insert(message, {message=strName,color = nowcolor})
		UserData.addEquipItem(v);
	end
	OpenLayer(UI_TAG.UI_COMTIP,0,110);
	UIComTip.showMessage(message);
end

--Boss战斗胜利执行欢呼动作
function p.DoCheerAction(func)
	--
	local spriteTb = SpriteArmaturePool:GetFriendTeam();
	for k,v in pairs(spriteTb) do
		local tSprite = SpriteArmaturePool:GetArmatureIgnoreDeath(v);
		if SpriteArmaturePool:IsHumaction(tSprite.SpriteName) then
			local strAnimation = "victory01";
			if tSprite.RoleType == 1 or tSprite.RoleType == 3 then
				strAnimation = "victory03";
			elseif tSprite.RoleType == 2 or tSprite.RoleType == 4 then
				strAnimation = "victory02";
			else
				cclog("*****Boss战斗胜利执行欢呼动作*******");
			end
			tSprite:PlayAnimationByName(strAnimation,nil,nil,0);
		else
			tSprite:PlayAnimationByName("victory",nil,nil,0);
		end
	end
	--]]
	Scheduler.performWithDelayGlobal(func, 1.5);
	
end

--战斗失败,执怪物胜利动作
function p.DoFaildAction()
	
	local spriteTb = SpriteArmaturePool:GetEnemyTeam();
	for k,v in pairs(spriteTb) do
		local tSprite = SpriteArmaturePool:GetArmatureIgnoreDeath(v);
		
		if SpriteArmaturePool:IsHumaction(tSprite.SpriteName) then
		
			local strAnimation = "victory01";
			if tSprite.RoleType == 1 or tSprite.RoleType == 3 then
				strAnimation = "victory03";
			elseif tSprite.RoleType == 2 or tSprite.RoleType == 4 then
				strAnimation = "victory02";
			else
				cclog("*****战斗失败,执怪物胜利动作*******");
			end
			
			local function evenFunc()
				local array = CCArray:create()
				-- array:addObject(CCDelayTime:create(2));
				array:addObject(CCJumpBy:create(0.2, ccp(300, 0), 50, 1));
				array:addObject(CCHide:create());
				local seq1 = CCSequence:create(array);
				tSprite.Sprite:runAction(seq1);	
			end
			tSprite:RegiestMovementFunc(strAnimation, evenFunc, true, nil, nil)
			tSprite:PlayAnimationByName(strAnimation,nil,nil,0);
		else
			local function evenFunc()
				local array = CCArray:create()
				-- array:addObject(CCDelayTime:create(2));
				array:addObject(CCJumpBy:create(0.2, ccp(300, 0), 50, 1));
				array:addObject(CCHide:create());
				local seq1 = CCSequence:create(array);
				tSprite.Sprite:runAction(seq1);	
			end
			tSprite:RegiestMovementFunc("victory", evenFunc, true, nil, nil)
			tSprite:PlayAnimationByName("victory",nil,nil,1);
		end
		
	end
	-- Scheduler.performWithDelayGlobal(func, 1.5);
end

--普通战斗
function p.pStageCallback(logMesg, pHttpMsg)
	
	local pHttp = tolua.cast(pHttpMsg, "CCHttpMessage");
	if pHttp == nil then
		cclog("**************严重错误***************");
		return;
	end
	local pNDTransData = pHttp:GetMessageBuffer();
	if pNDTransData ~= nil then
		local tCode = {};
		if MsgClassConvern.HttpMessageHead(pNDTransData, tCode) then
		
			p._BattleType= 1;
			
			local nHeader = pNDTransData:readInt();   
			local nHeader2 = pNDTransData:readInt();
			
			--掉落数据
			p._dropList = {};
			p._dropList.isHaveData = true;
			p._dropList.StageID = pNDTransData:readInt(); --关卡ID
			p._dropList.WinFlag = pNDTransData:readInt(); --胜利失败标志
			
			local fValueTime    = pNDTransData:readInt(); --该场战斗时间
			
			--战斗信息
			p._dropList.Info = {};
			p._dropList.Info.FightTime = pNDTransData:readInt(); --战斗时间
			p._dropList.Info.BattleNum = pNDTransData:readInt(); --战斗次数
			p._dropList.Info.CoinPHour = pNDTransData:readInt(); --战斗金币
			p._dropList.Info.ExpPeHour = pNDTransData:readInt(); --战斗经验
			p._dropList.Info.DropRate  = pNDTransData:readInt(); --装备掉率
			p._dropList.Info.SafetyVal = pNDTransData:readInt(); --战斗安全
			p._dropList.Info.CoinRate = pNDTransData:readInt(); --金币暴率
			p._dropList.Info.ExpRate = pNDTransData:readInt(); --经验暴率
			p._dropList.Info.EquipRate = pNDTransData:readInt(); --装备暴率
			
			if m_IsFirstBegin then
				GameFightCenter:ShowBattleInfo(p._dropList.Info);
				m_IsFirstBegin = false;
			end
			
			--战斗数据
			local strLen = pNDTransData:readInt();
			if strLen > 0 then
				local battleStr = pNDTransData:readString(strLen);
				-- fValueTime = CfgData["cfg_Stage"][p._dropList.StageID]["battle_time"] - fValueTime;
				if p._dropList.WinFlag == 2 then
					GameFightCenter.ShowNextGate(40101, true, "搜索怪物中...");
					
					GameFightTextBattle.AddBattleTextStr("搜索怪物中...\n", 22, ccc3(100,100,100));
					
					if fValueTime <= 0 then
						fValueTime = 3;
						-- cclog("---服务器下发时间问题---");
					end
				else
					fValueTime = nil;
					GameFightCenter.ShowNextGate(nil, false);
				end
				GameFightCenter:ChangeMapImage(p._dropList.StageID, battleStr, false, fValueTime);
			end
			
			--掉落
			if  p._dropList.WinFlag == 1 then
				MsgClassConvern.CommonDrop(p._dropList,pNDTransData, 2);
				--自动卖出记录
				local strLen = pNDTransData:readInt();
				if strLen > 0 then
					local sellStr = pNDTransData:readString(strLen);
				end
			end
		else
			-- 战斗请求失败
			p.reConnectFight(tCode);
		end
	end
end

--Boss战斗
function p.pBossCallback(logMesg, pHttpMsg)
	
	
	local pHttp = tolua.cast(pHttpMsg, "CCHttpMessage");
	if pHttp == nil then
		cclog("**************严重错误***************");
		return;
	end

	local pNDTransData = pHttp:GetMessageBuffer();
	if pNDTransData ~= nil then
		p._bHaveBoss = false;
		p._BattleType= 2;
		local tCode = {};
		if MsgClassConvern.HttpMessageHead(pNDTransData, tCode) then
			local nHeader = pNDTransData:readInt();   
			local nHeader2 = pNDTransData:readInt();
			
			
			--掉落数据
			p._dropList = {};
			p._dropList.isHaveData = true;
			p._dropList.StageID = pNDTransData:readInt(); --关卡ID
			p._dropList.WinFlag = pNDTransData:readChar(); --胜利失败标志
			
					
			--战斗数据
			local strLen = pNDTransData:readInt();
			if strLen ~= nil and strLen ~= 0 then
				GameFightMusic.PlayFightBackMusic()
				GameFightCenter.BattleBeginCall(false);
				local battleStr = pNDTransData:readString(strLen);
				GameFightCenter:ChangeMapImage(p._dropList.StageID, battleStr, true);
			end
		
			--BOSS战斗胜利时候减去一张Boss挑战卷
			if p._dropList.WinFlag==1 then
				UserData.ChallengeTime = UserData.ChallengeTime -1;
				MsgClassConvern.CommonDrop(p._dropList, pNDTransData, 2);
				
				--先减去boss挑战券
				if CheckT(p._dropList.tItem) then
					for k,v in pairs(p._dropList.tItem)  do
						if k == 202 then
							UserData.DeleteGoodsItem(202,1);
							p._dropList.tItem[k] = nil;
						end
					end
				end
				
				--自动卖出记录
				local strLen = pNDTransData:readInt();
				if strLen ~= nil and strLen ~= 0 then
					local sellStr = pNDTransData:readString(strLen);
				end
			else
				--失败时候不读取掉落物品
			end
		else
			-- 战斗请求失败
			p.reConnectFight(tCode);
		end
	end

end

--竞技场战斗
function p.pBattleWithOppCallback(logMesg, pHttpMsg)
	local pHttp = tolua.cast(pHttpMsg, "CCHttpMessage");
	if pHttp == nil then
		cclog("**************严重错误***************");
		return;
	end
	
	local pNDTransData = pHttp:GetMessageBuffer();
	if pNDTransData ~= nil then
		
		local tCode = {};
		if MsgClassConvern.HttpMessageHead(pNDTransData, tCode) then
			MsgClassConvern.ReadHead(pNDTransData,2);	
			
			p._BattleType = 3;
			p._bHaveOPP = false;
			
			p._dropList = {};
			
			p._dropList.WinFlag = pNDTransData:readChar(); --胜利失败标志
			-- local nwinFlg = pNDTransData:readChar();
			
			local battleStr = nil;
			local nLen = pNDTransData:readInt();
			if nLen > 0 then
				battleStr = pNDTransData:readString(nLen);
			end
			local newRank = pNDTransData:readInt();
			UserData.tArenaInfo.Rank = newRank;
			UserData.tArenaInfo.tPlayer = nil;
			UserData.tArenaInfo.tPlayer = {};
			local nNum = pNDTransData:readInt();
			for k=1,nNum do
				local tPlayerItem = {};
				MsgClassConvern.ArenaPlayer(tPlayerItem,pNDTransData, 1)
				table.insert(UserData.tArenaInfo.tPlayer,tPlayerItem)
			end
			
			--挑战次数更新
			UserData.tArenaInfo.ChallengeTimes = UserData.tArenaInfo.ChallengeTimes -1;
			
			if battleStr ~= nil then
				--进入战斗
				GameFightMusic.PlayFightBackMusic();
				GameFightCenter.BattleBeginCall(false);
				GameFightCenter:ChangeMapImage(42000, battleStr, true);
			end
		else
			p.reConnectFight(tCode);
		end
	end
end

--战斗回放
function p.pShowFightLog(logMesg, pHttpMsg)
	local pHttp = tolua.cast(pHttpMsg, "CCHttpMessage");
	if pHttp == nil then
		cclog("**************严重错误***************");
		return;
	end
	
	local pNDTransData = pHttp:GetMessageBuffer();
	if pNDTransData ~= nil then
	
		local tCode = {};
		if MsgClassConvern.HttpMessageHead(pNDTransData, tCode) then
			p._BattleType = 4;
			p._bHaveBattleLog = false;
		
			MsgClassConvern.ReadHead(pNDTransData,2);
			
			p._dropList = {};
			p._dropList.WinFlag = 0;
			if p._bBattleLogWin then
				p._dropList.WinFlag = 1; --胜利失败标志
			end
			
			local battleStr = nil;
			local strLen = pNDTransData:readInt(); --
			if strLen > 0 then
				battleStr = pNDTransData:readString(strLen);
			end
		
			--播放战报
			if battleStr ~= nil then
				GameFightMusic.PlayFightBackMusic()
				GameFightCenter.BattleBeginCall(false);
				GameFightCenter:ChangeMapImage(42000, battleStr, true);
			end
		else
			p.reConnectFight(tCode)
		end
	end
end

--公会副本战斗
function p.pGuildFightCallBack(logMesg, pHttpMsg)
	local pHttp = tolua.cast(pHttpMsg, "CCHttpMessage");
	if pHttp == nil then
		cclog("**************严重错误***************");
		return;
	end
	
	local pNDTransData = pHttp:GetMessageBuffer();
	if pNDTransData ~= nil then
		
		local tCode = {};
		if MsgClassConvern.HttpMessageHead(pNDTransData, tCode) then
			p._BattleType = 5;
			p._bHaveGuildBattel = false;
		
			MsgClassConvern.ReadHead(pNDTransData,2);	
			
			--
			p._dropList = {};
			p._dropList.WinFlag = pNDTransData:readChar(); --胜利失败标志
			p._dropList.isHaveData = true;
			
			--战报
			local battleStr = nil;
			local strLen = pNDTransData:readInt(); --
			if strLen > 0 then
				battleStr = pNDTransData:readString(strLen);
			end
		
			--掉落
			MsgClassConvern.CommonDrop(p._dropList,pNDTransData, 2);		
		
			--播放战报
			if battleStr ~= nil then
				GameFightMusic.PlayFightBackMusic()
				GameFightCenter.BattleBeginCall(false);
				GameFightCenter:ChangeMapImage(p.GetMapId(), battleStr, true);
			end
		else
			p.reConnectFight(tCode)
		end
	end
end

--活动之卡牌掉落战斗
function p.pCardGetFightCallBack(logMesg, pHttpMsg)
	local pHttp = tolua.cast(pHttpMsg, "CCHttpMessage");
	if pHttp == nil then
		cclog("**************严重错误***************");
		return;
	end
	
	local pNDTransData = pHttp:GetMessageBuffer();
	if pNDTransData ~= nil then
		
		local tCode = {};
		if MsgClassConvern.HttpMessageHead(pNDTransData, tCode) then
			p._BattleType = 6;
			p._bHaveCardBattel = false;
			
			MsgClassConvern.ReadHead(pNDTransData,2);
				
			--
			p._dropList = {};
			p._dropList.WinFlag = pNDTransData:readChar(); --胜利失败标志
			
			--播放战报
			local battleStr = nil;
			local strLen = pNDTransData:readInt(); --
			if strLen > 0 then
				battleStr = pNDTransData:readString(strLen);
			end
			
			--掉落
			if p._dropList.WinFlag == 1 then
				p._dropList.isHaveData = true;
				MsgClassConvern.CommonDrop(p._dropList, pNDTransData, 2);		
			end
			
			if battleStr ~= nil then
				GameFightMusic.PlayFightBackMusic()
				GameFightCenter.BattleBeginCall(false);
				GameFightCenter:ChangeMapImage(p.GetMapId(), battleStr, true);
			end
		else
			p.reConnectFight(tCode)
		end
	end
end

--公会战斗
function p.pGongHuiFightCallBack(logMesg, pHttpMsg)
	local pHttp = tolua.cast(pHttpMsg, "CCHttpMessage");
	if pHttp == nil then
		cclog("**************严重错误***************");
		return;
	end
	
	local pNDTransData = pHttp:GetMessageBuffer();
	if pNDTransData ~= nil then
		
		local tCode = {};
		if MsgClassConvern.HttpMessageHead(pNDTransData, tCode) then
			p._BattleType = 7;
			p._bGongHuiBattle = false;
			
			MsgClassConvern.ReadHead(pNDTransData,2);
				
			--
			p._dropList = {};
			if p._bGongHuiBattleWin then
				p._dropList.WinFlag = 1; --胜利失败标志
			else
				p._dropList.WinFlag = 0; --胜利失败标志
			end
			
			--播放战报
			local battleStr = nil;
			local strLen = pNDTransData:readInt(); --
			if strLen > 0 then
				battleStr = pNDTransData:readString(strLen);
			end
						
			if battleStr ~= nil then
				GameFightMusic.PlayFightBackMusic()
				GameFightCenter.BattleBeginCall(false);
				GameFightCenter:ChangeMapImage(p.GetMapId(), battleStr, true, nil, p._bGongHuiChangePos);
			end
		else
			p.reConnectFight(tCode);
		end
	end
end


--切换地图挂机
function p.ChangeStageCall(logMesg, pHttpMsg)
	local pHttp = tolua.cast(pHttpMsg, "CCHttpMessage");
	if pHttp == nil then
		cclog("**************严重错误***************");
		return;
	end
	local pNDTransData = pHttp:GetMessageBuffer();
	if pNDTransData ~= nil then
		if MsgClassConvern.HttpMessageHead(pNDTransData) then
			UserData.OnhookStageId = p._reqChangeStageId;
		end
	end
end

function p.updateUserStage(nStageId)
	--local cfg = CfgData.cfg_Stage[UserData.LatestStageId];
	local cfg = CfgData.cfg_Stage[nStageId];
	if UserData.LatestStageId < tonumber(cfg.afterstage_id) then
		UserData.LatestStageId = tonumber(cfg.afterstage_id)
		UserData.OnhookStageId = UserData.LatestStageId;
	end
end

--关卡战斗请求
function p.ContractRequest()
	NetReq.ReqBattleLog(p.pStageCallback);
end

--Boss挑战请求
function p.StageBossReq(stageId)
	--
	p._bHaveOPP = false;
	p._bHaveBattleLog = false;
	p._bHaveGuildBattel= false;
	p._bHaveCardBattel = false;
	p._bGongHuiBattle = false;
	p._bHaveBoss = true;
	
	p._reqStageId = stageId;
	
	if GameFightCenter:InHeroWalkRunBattle() then
		GameFightCenter.ShowNextGate(stageId, true);
	end
end

--竞技场战斗请求
function p.BattleWithOpp(nUserId, func)
	
	p._bHaveBoss	= false;
	p._bHaveBattleLog = false;
	p._bHaveGuildBattel= false;
	p._bHaveCardBattel = false;
	p._bGongHuiBattle = false;
	p._bHaveOPP 	= true;
	p._OPPUserID	= nUserId;
	p._OPPCallFunc  = func;
	if GameFightCenter:InHeroWalkRunBattle() then
		GameFightCenter.ShowNextGate(42000, true, "即将挑战竞技场");
	end
end

--战斗回放请求
function p.BattleLogReq(nReCordId, bWin, func)
	p._bHaveBoss = false;
	p._bHaveOPP  = false;
	p._bHaveGuildBattel= false;
	p._bHaveCardBattel = false;
	p._bGongHuiBattle = false;
	p._bHaveBattleLog = true;
	p._RecordId = nReCordId;
	p._bBattleLogWin = bWin;
	p._BattleLogCallFunc = func;
	if GameFightCenter:InHeroWalkRunBattle() then
		GameFightCenter.ShowNextGate(42000, true, "即将播放对战记录");
	end
end

--副本战请求
function p.BattleGuildReq(nGuildId, nUserId, nHeroId, callBack)
	
	p._bHaveBoss = false;
	p._bHaveOPP  = false;
	p._bHaveBattleLog = false;
	p._bHaveCardBattel = false;
	p._bGongHuiBattle = false;
	p._bHaveGuildBattel= true;
	
	p._GuildId = nGuildId;			--公会副本ID
	p._GuildUserId = nUserId;		--公会玩家ID
	p._GuildHeroId = nHeroId;		--公会玩家英雄ID
	p._GuildCallBack = callBack;	--战斗结束回调函数
	if GameFightCenter:InHeroWalkRunBattle() then
		GameFightCenter.ShowNextGate(40101, true, "即将挑战公会副本");
	end
end

--活动之卡牌掉落战斗
function p.BattleCardGetReq(nHard, nStageId, callBack)
	
	p._bHaveBoss = false;
	p._bHaveOPP  = false;
	p._bHaveBattleLog = false;
	p._bHaveGuildBattel= false;
	p._bGongHuiBattle = false;
	p._bHaveCardBattel = true;
	
	p._nCardHard	= nHard;
	p._nCardStageId = nStageId;
	p._CardCallBack = callBack;	

	if GameFightCenter:InHeroWalkRunBattle() then
		GameFightCenter.ShowNextGate(40101, true, "即将挑战活动副本");
	end
end

--公会战斗(团)
function p.GongHuiBattleReq(nReqId,  bWin, bChangePos, callBack)
	p._bHaveBoss = false;
	p._bHaveOPP  = false;
	p._bHaveBattleLog = false;
	p._bHaveGuildBattel= false;
	p._bHaveCardBattel = false;
	p._bGongHuiBattle = true;
	
	
	p._nGongHuiRepId = nReqId;
	p._bGongHuiBattleWin = bWin;
	p._bGongHuiChangePos = bChangePos;
	p._GongHuiBatteCallBack = callBack;
	
	if GameFightCenter:InHeroWalkRunBattle() then
		GameFightCenter.ShowNextGate(40101, true, "即将开始工会战");
	end
end


--切换挂机地图
function p.changeStageIdRequest(nStageId)
	p._reqChangeStageId = nStageId;
	if CfgData["cfg_Stage"][nStageId] ~= nil then
		local str = CfgData["cfg_Stage"][nStageId]["name"];
		local strName = "即将挑战关卡:"..str;
		GameFightCenter.ShowNextGate(40101, true, strName);
	end
	NetReq.ReqChangeStage(nStageId,p.ChangeStageCall)
end

--断线重新连接战斗
function p.reConnectFight(tCode)
	
	UserData.IsUserLogin = false;
	if tCode ~= nil then		
		if tCode[1] == 13 or tCode[1] == 17 then
			if m_TimmerHandle ~= nil then
				Scheduler.unscheduleGlobal(m_TimmerHandle);
				m_TimmerHandle = nil;
			end
			local function func()
				if UserData.IsUserLogin then
					Scheduler.unscheduleGlobal(m_TimmerHandle);
					m_TimmerHandle = nil;
					-- UserData.IsUserLogin = false;
					p.BattleMainRequest(nil,true);
					UserData.IsUserLogin = false;
				end
			end
			m_TimmerHandle = Scheduler.scheduleGlobal(func, 1.0);
		else
			p.BattleMainRequest(nil,true);
		end
	else

	end
end

function p.GetMapId()
	local Num = math.random(1,8);
	local tb = {40101,40201,40301,40401,40501,40601,40701,40801};
	return tb[Num];
end

--测试看效果如何
--竞技场结果展示
function p.ShowAreanResult(bWin,rank)
	GameFightCenter.ShowAreanResult(bWin,rank)
end


return p;
