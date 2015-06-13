-- 文字战斗 
GameFightTextBattle = {};
local p = GameFightTextBattle;

local bFirst = true;
local m_bIsOpen = false;

p.ui = nil;
p.uiLayer = nil;

p.ShowEditer = nil;

local m_EnumColor = {};

--战斗英雄数据(主要使用名字)
local m_tHeroInfo = {};

local m_LogObjNumber = 0;
local m_LogLineNumber= 0;

--账号注销回调函数
function p.gameLoginOut()
	bFirst = true;
	m_bIsOpen = false;
	p.ui = nil;
	p.uiLayer = nil;
	p.ShowEditer = nil;
	m_EnumColor = {};
	m_tHeroInfo = {};
	m_LogObjNumber = 0;
	m_LogLineNumber= 0;
end

--UI
function p.create()
	if p.uiLayer == nil then
		p.uiLayer = TouchGroup:create()
		p.ui = ui_delegate(GUIReader:shareReader():widgetFromJsonFile("UserUI/TextAlert.json"))
		p.uiLayer:addWidget(p.ui.nativeUI);		
		if p.ShowEditer == nil then
			p.ShowEditer = RichText:create()
			p.ShowEditer:setAutoRolling(true);
			p.ShowEditer:setAnchorPoint(ccp(0,0));
			p.ShowEditer:ignoreContentAdaptWithSize(false);
			local pScrollView = tolua.cast(p.ui.ScrollView_3,"ScrollView");
			if pScrollView ~= nil then
				pScrollView:setTouchEnabled(false);
				local size = pScrollView:getContentSize();
				p.ShowEditer:setSize(size);
				p.ShowEditer:setPosition(ccp(0, 22));
				p.ui.ScrollView_3:addChild(p.ShowEditer);
			end
		end
	end
    return p.uiLayer;
end

--
function p.OpenTextBattleLog()
	local pTouchLayer = p.create();
	if pTouchLayer and bFirst then
		bFirst = false;
		GameFightCenter.uiLayer:addChild(pTouchLayer, -1);
		GameFightCenter.Layer:setVisible(false);
		GameFightCenter.ShowLogText(false);
		return;
	end
	local bShow = not pTouchLayer:isVisible();
	GameFightCenter.Layer:setVisible(not bShow);
	GameFightCenter.ShowLogText(not bShow);
	pTouchLayer:setVisible(bShow);
end

--更具枚举显示文字颜色
function p.GetEnumColro(eColor)
	if m_EnumColor[tostring(eColor)] ~= nil then
		return m_EnumColor[tostring(eColor)];
	else
		--战斗文字
		if eColor == 30 then 		--角色名字
			m_EnumColor[tostring(eColor)] = ccc3(160, 32, 240);
		elseif eColor == 31 then 	--怪物名字
			m_EnumColor[tostring(eColor)] = ccc3( 0, 0, 200);
		elseif eColor == 32 then 	--攻击了
			m_EnumColor[tostring(eColor)] = ccc3( 0, 0, 0);
		elseif eColor == 33 then 	--技能颜色
			m_EnumColor[tostring(eColor)] = ccc3(0,128,192);
		else
			if eColor == 0 then --普通命中
				m_EnumColor[tostring(eColor)] = ccc3(176,23,31);
			elseif 	eColor == 1 then --暴击
				m_EnumColor[tostring(eColor)] = ccc3(200,100, 0);
			elseif 	eColor == 2 then --闪避
				m_EnumColor[tostring(eColor)] = ccc3(0,204,255);
			elseif 	eColor == 3 then --格挡
				m_EnumColor[tostring(eColor)] = ccc3(0,204,255);
			elseif 	eColor == 4 then --治疗
				m_EnumColor[tostring(eColor)] = ccc3(0, 128,0);
			elseif 	eColor == 5 then --吸血
				m_EnumColor[tostring(eColor)] = ccc3(0, 128,0);
			elseif 	eColor == 6 then --反弹
				m_EnumColor[tostring(eColor)] = ccc3(176,23,31);
			elseif 	eColor == 7 then --反击
				m_EnumColor[tostring(eColor)] = ccc3(176,23,31);
			elseif 	eColor == 8 then --状态
				m_EnumColor[tostring(eColor)] = ccc3(176,23,31);
			elseif 	eColor == 9 then --复活
				m_EnumColor[tostring(eColor)] = ccc3(0,204,255);
			elseif 	eColor == 10 then --自伤
				m_EnumColor[tostring(eColor)] = ccc3(176,23,31);
			elseif 	eColor == 11 then --眩晕
				m_EnumColor[tostring(eColor)] = ccc3(176,23,31);
			elseif 	eColor == 12 then --消除Buff
				m_EnumColor[tostring(eColor)] = ccc3(0,204,255);
			elseif 	eColor == 13 then --什么都没有
				m_EnumColor[tostring(eColor)] = ccc3(0,204,255);
			elseif 	eColor == 25 then --文字显示
				m_EnumColor[tostring(eColor)] = ccc3(0,204,255);
			else
				--未知
				if GameFightCenter:IsShowLog() then
					cclog("***文字战报字体颜色异常:%s***",tostring(eColor));
				end
				eColor = 26;
				m_EnumColor[tostring(eColor)] = ccc3(0,204,255);
			end
		end
		return m_EnumColor[tostring(eColor)];
	end
end

-- 富文本显示
function p.InsertBattleText(strBatLog, nFontSize, eColor)
	
	if bFirst then
		return;
	end
	
	if strBatLog == nil then
		cclog("");
	end
	----------------------------------------
	if m_LogObjNumber > 100 and m_LogLineNumber == 1 or m_LogObjNumber > 250 then
		local nRemoveNum = m_LogObjNumber - 100;
		for i=0,nRemoveNum do
			p.ShowEditer:removeElement(0);
			m_LogObjNumber = m_LogObjNumber - 1;
		end
		p.ShowEditer:setTextRenderFormat(true);
		p.ShowEditer:formatText();
		p.ShowEditer:setTextRenderFormat(false);
	end
	----------------------------------------
	local cColor = p.GetEnumColro(eColor);
	local pEnum = RTE(tostring(strBatLog), nFontSize, cColor);
	p.ShowEditer:pushBackElement(pEnum);
	m_LogObjNumber = m_LogObjNumber + 1;
	
end

--
function p.AddLineIndex()
	if p.ShowEditer ~= nil then
		local pLine = RTE(tostring("["..m_LogLineNumber.."]"), 22, ccc3(100,100,100));
		p.ShowEditer:pushBackElement(pLine);
		m_LogObjNumber = m_LogObjNumber + 1;
	end
end

--
function p.AddBattleTextStr(strText, nFront, cColor)
	if p.ShowEditer ~= nil then
		local pLine = RTE(tostring(strText), nFront, cColor);
		p.ShowEditer:pushBackElement(pLine);
		m_LogObjNumber = m_LogObjNumber + 1;
	end
end

--
function p.ShowBattleHeroDeath(nHeroTag, bDeath)
	if p.ShowEditer ~= nil then
		local strEx = nil;
		local cColor= nil;
		if not bDeath then
			strEx = ZhTextSet_50110;
			cColor= ccc3(0, 128,0);
		else
			strEx = ZhTextSet_50111;
			cColor= ccc3(0, 0,0);
		end
		local strText = p.GetHeroNameByHeroId(nHeroTag, nil);
		local pLine = RTE(tostring(strText), 22, ccc3(200,100, 0));
		p.ShowEditer:pushBackElement(pLine);
		m_LogObjNumber = m_LogObjNumber + 1;
		
		local pLine = RTE(tostring(strEx), 22, cColor);
		p.ShowEditer:pushBackElement(pLine);
		m_LogObjNumber = m_LogObjNumber + 1;		
		
	end
end

--初始化文字战报英雄数据
function p.InitTextBattleInfo(tHeroInfo)
	m_LogLineNumber = 0;
	m_tHeroInfo = {};
	if tHeroInfo ~= nil then
		for i,d in ipairs(tHeroInfo) do
			for j,v in ipairs(d) do
				m_tHeroInfo[tostring(v.nId)] = v;
			end
		end
	else
		cclog("*** Text Battle GameFightTextBattle Init Info Error***");
	end
end

--解析文字战斗内容
function p.ParsFightRoundText(tMessages)
	
	--攻击者名字
	local nBattleHeroId  = nil;
	local tBeBattleHeroId = {};
	local nSkillId		 = nil;
	local nAttackType	 = nil;
	local tHurtInfo		 = {};
	local tBufferInfo	 = {};
	local tOtherHurt	 = {};
	
	m_LogLineNumber = m_LogLineNumber + 1;
	
	--行动回合数据设置
	for i,v in ipairs(tMessages[1]) do
		if i==1 then
		
			if v.nAttackType == EnumDamage.WORLD then --战斗对话
				return;
			end
			-- i=1表示是施法的对象,第一次对象赋予驱动攻击精灵
			nBattleHeroId = v.nAttackId;
			table.insert(tBeBattleHeroId, v.nBeAttackId[1]);
			
			nSkillId 	= v.nSkillId;
			nAttackType = v.nAttackType;
			for k, value in pairs(v.nDamageHurt) do
				table.insert(tHurtInfo,{v.nBeAttackId[1], value, v.nAttackType});
			end
			--如果是移除或者添加Buff
			if v.nAttackType == EnumDamage.BUFF or v.nAttackType == EnumDamage.BUFFERMOVE then
				--是buffer
				local bAdd = true;
				if v.nAttackType ~= EnumDamage.BUFF then
					bAdd = false;
				end
				
				local tAdditional = Split(v.sAdditional, ",", false);
				for i, d in pairs(tAdditional) do
					local nBufferId = tonumber(d);
					if nBufferId ~= nil then
						table.insert(tBufferInfo,{nBufferId, v.nBeAttackId[1], bAdd});
					end
				end
			else				
				--可能存在Buff
				local tAdditional = Split(v.sAdditional, ",", false);
				for i, d in pairs(tAdditional) do
					local nBufferId = tonumber(d);
					if nBufferId ~= nil then
						table.insert(tBufferInfo,{nBufferId, v.nBeAttackId[1], true});
					end
				end
			end
		else
			--
			--判断是否是添加或者移除Buff
			if v.nAttackType ~= EnumDamage.BUFF and v.nAttackType ~= EnumDamage.BUFFERMOVE  then
				--不是buff
				--判断战斗是否是AOE
				if v.nSkillId == nSkillId then
					if v.nAttackType == EnumDamage.NORMAL then
						-- AOE
						-- 人物
						table.insert(tBeBattleHeroId, v.nBeAttackId[1]);
						-- 伤害
						for k, value in pairs(v.nDamageHurt) do
							table.insert(tHurtInfo, {v.nBeAttackId[1], value, v.nAttackType});
						end
					else
						-- 暂时处理按照AOE处理
						-- AOE
						-- 人物
						table.insert(tBeBattleHeroId, v.nBeAttackId[1]);
						-- 伤害
						for k, value in pairs(v.nDamageHurt) do
							table.insert(tHurtInfo, {v.nBeAttackId[1], value, v.nAttackType});
						end
					end
				else
					-- 由于Buff造成的伤害
					for k, value in pairs(v.nDamageHurt) do
						table.insert(tOtherHurt,{v.nSkillId, v.nAttackType, value, v.nBeAttackId[1]});
					end
				end
			else
				--是buffer
				local bAdd = true;
				if v.nAttackType ~= EnumDamage.BUFF then
					bAdd = false;
				end
				local tAdditional = Split(v.sAdditional, ",", false);
				for i, d in pairs(tAdditional) do
					local nBufferId = tonumber(d);
					if nBufferId ~= nil then
						table.insert(tBufferInfo,{nBufferId, v.nBeAttackId[1], bAdd});
					end
				end
			end
		end
	end
	
	--状态回合
	local tStateBuffs	 = {};
	local tStateHurts	 = {};
	if tMessages[2] ~= nil then
		for i,v in ipairs(tMessages[2]) do
			if v.nAttackType == EnumDamage.BUFF or v.nAttackType == EnumDamage.BUFFERMOVE then
				--是buffer
				local bAdd = true;
				if v.nAttackType ~= EnumDamage.BUFF then
					bAdd = false;
				end
				table.insert(tStateBuffs,{v.nSkillId, v.nBeAttackId[1], bAdd});
			else
				-- 伤害类型
				table.insert(tStateHurts,{v.nBeAttackId[1], v.nDamageHurt, v.nAttackType, v.nSkillId});
			end
		end
	end
	p.ShowBattleTextLog(nBattleHeroId, nSkillId, tBeBattleHeroId, nAttackType, tHurtInfo, tBufferInfo, tOtherHurt);
	
	----
	if #tStateHurts > 0 then
		p.GetStateHurtWords(tStateHurts, nBattleHeroId);
	end
	if #tStateBuffs > 0 then
		p.GetBufferStateDes(tStateBuffs, nBattleHeroId)
	end
	
end

--显示文字战斗内容
function p.ShowBattleTextLog(nHeroId, nSkillId ,tBattleHeroId, nAttackType, tHurtInfo, tBufferInfo, tOtherHurt)
	
	if GameFightCenter:IsShowLog() then
		cclog("------------------------------------------------");
	end
	--攻击名字
	p.AddLineIndex();
	local str = p.GetHeroNameByHeroId(nHeroId, nil);
	p.InsertBattleText(str.." ", 22, 30);
	
	--判断是不是对自己释放技能
	local strToMySelf = "";
	if #tBattleHeroId == 1 then
		if tBattleHeroId[1] == nHeroId then
			strToMySelf = ZhTextSet_50112;
		end
	end
	
	--用什么技能攻击
	str = str.." "..p.GetBattleWordsBySkillId(nSkillId, nAttackType, strToMySelf);
	--有没有暴击回避什么的
	local bShow, showStr = p.GetHurtTypeDes(nAttackType);
	
	--攻击哪个英雄
	if strToMySelf == "" then	--如果不是对自己的那么就可能对别人要显示
		str = str..p.GetHurtHeros(tBattleHeroId, nHeroId, bShow);
	end

	if bShow then
		if showStr ~= "" then
			p.InsertBattleText(showStr, 22, 32);
			str = str..showStr;
			if GameFightCenter:IsShowLog() then
				cclog(str);
			end
		end
		
		if GameFightCenter:IsShowLog() then
			cclog(str);
		end
		p.GetHurtWords(tHurtInfo, nHeroId);
		
	else
		p.InsertBattleText(showStr.."\n", 22, 32);
		str = str.." "..showStr;
		if GameFightCenter:IsShowLog() then
			cclog(str);
		end
	end
	--产生了Buffer
	p.GetBufferDes(tBufferInfo, nSkillId, nHeroId);
	--由于Buff造成的伤害
	p.GetBufferHurts(tOtherHurt, nHeroId);
end

---------------------------------------------------
--使用技能Id获取攻击文字
function p.GetBattleWordsBySkillId(nSkillId, nHurtType, strToMySelf)
	if nSkillId == 10010 then
		local str = ZhTextSet_50113;
		p.InsertBattleText(str, 22, 32);
		return str;
	else
		if nSkillId < 20000 then
			-- 技能攻击
			local tCfgSkill = CfgData["cfg_skill"][nSkillId];
			if tCfgSkill ~= nil then
				local str = strToMySelf..ZhTextSet_50114;
				p.InsertBattleText(str, 22, 32);
				local skillName = tCfgSkill["name"];
				p.InsertBattleText(skillName, 22, 33);
				return str..skillName..p.GetHurtTypeWord(nHurtType);
			else
				cclog("*** Text Battle 获取攻击技能文字技能ID:%d  Error***",nSkillId);
				return "";
			end
		else
			-- Buff攻击
			-- 谁 ..由于 Buffer 11(眩晕) 回合行动停止
			local tCfgBuffe = CfgData["cfg_Buffer"][nSkillId];
			if tCfgBuffe ~= nil then
				local showStr = p.GetHurtTypeDesForBuf(nHurtType);
				local strBuffName = tCfgBuffe["state_name"];
				local str = "由于 "..strBuffName..showStr;
				
				p.InsertBattleText(ZhTextSet_50115, 22, 32);
				p.InsertBattleText(strBuffName, 22, 33);
				p.InsertBattleText(showStr, 22, 32);

				return str;
			else
				cclog("***Log Text Error Buffer***");
				return "";
			end
		end
	end
end

--对英雄造成伤害
function p.GetHurtWords(tHurtInfo, nHeroId)
	
	if #tHurtInfo > 1 then
		for k,v in ipairs(tHurtInfo) do
			
			
			local strName = p.GetHeroNameByHeroId(v[1], nHeroId);
			p.InsertBattleText(strName, 22, 31);
			local str_1, str_2 = p.GetHurtTypeForBufEx(v[3]);
			if str_1 ~= "" then
				p.InsertBattleText(str_1, 22, 32);
			end
			--伤害
			p.InsertBattleText(tostring(v[2]), 22, v[3]);
			if str_2 ~= "" then
				p.InsertBattleText(str_2.."\n", 22, 32);
			end
			
			if GameFightCenter:IsShowLog() then
				local str = strName..str_1..v[2]..str_2;
				cclog(str);
			end
		end
	else
		if tHurtInfo[1][2] > 0 then
			--谁 受到了 10 伤害
			local strName = p.GetHeroNameByHeroId(tHurtInfo[1][1], nHeroId);
			p.InsertBattleText(strName, 22, 31);
			local str_1, str_2 = p.GetHurtTypeForBufEx(tHurtInfo[1][3]);
			if str_1 ~= "" then
				p.InsertBattleText(str_1, 22, 32);
			end
			--伤害
			p.InsertBattleText(tostring(tHurtInfo[1][2]), 22, tHurtInfo[1][3]);
			if str_2 ~= "" then
				p.InsertBattleText(str_2.."\n", 22, 32);
			end
			
			if GameFightCenter:IsShowLog() then
				local str = strName..str_1..tHurtInfo[1][2]..str_2;
				cclog(str);
			end
		else
			--没有伤害时候要给换行
			p.InsertBattleText("\n", 22, 32);
		end
	end
end

--对应受伤害的英雄
function p.GetHurtHeros(tHeroId, nHeroId, bShow)
	local str = "";
	for k,v in ipairs(tHeroId) do
		if k == 1 then
			str = str..p.GetHeroNameByHeroId(v, nHeroId);
		else
			str = str.."、"..p.GetHeroNameByHeroId(v, nHeroId);
		end
	end
	if bShow then
		p.InsertBattleText(str.."\n", 22, 31);
	else
		p.InsertBattleText(str, 22, 31);
	end
	return str;
end

--产生Buffer描述
function p.GetBufferDes(tBuffers, nSkillId, nHeroId)
	local str = "";
	for k,v in ipairs(tBuffers) do
		-- {nBufferId, v.nAttackId, bAdd}
		if v[3] then
			
			local tCfgSkill = CfgData["cfg_skill"][nSkillId];
			local tCfgBuffe = CfgData["cfg_Buffer"][v[1]];
			if tCfgSkill == nil or tCfgBuffe == nil then
				cclog("*** Text Battle GetBufferDes 1 Error:%s, %s***", tostring(nSkillId), tostring(v[1]));
			else
				local skillName   = tCfgSkill["name"];
				local strBuffName = tCfgBuffe["state_name"];
				local strHeroName = p.GetHeroNameByHeroId(v[2], nHeroId);
				-- str = str.."产生了Buffer"..strBuffName;
				--好的Buff应该是(获得),坏的应该是(产生)
				
				p.InsertBattleText(ZhTextSet_50116, 22, 32);
				p.InsertBattleText(skillName.." ", 22, 33);
				p.InsertBattleText(strHeroName, 22, 31);
				p.InsertBattleText(ZhTextSet_50117, 22, 32);
				p.InsertBattleText(strBuffName, 22, 33);
				p.InsertBattleText(ZhTextSet_50118, 22, 32);
				if GameFightCenter:IsShowLog() then
					local str = "因技能 "..skillName.." "..strHeroName.." 获得 "..strBuffName.." 效果";
					cclog(str);
				end
			end
		else
			local tCfgBuffer = CfgData["cfg_Buffer"][v[1]];
			if tCfgBuffer ~= nil then
				local strBuffName = tCfgBuffer["state_name"];
				local strHeroName = p.GetHeroNameByHeroId(v[2], nHeroId);
				p.InsertBattleText(strHeroName, 22, 31);
				p.InsertBattleText(ZhTextSet_50119, 22, 32);
				p.InsertBattleText(strBuffName, 22, 33);
				if GameFightCenter:IsShowLog() then
					local str = strHeroName.." 移除了 "..strBuffName;
					cclog(str);
				end
			else
				cclog("*** Text Battle GetBufferDes 2 Error:%s***", tostring(v[1]));
			end
		end
	end
end

--对State英雄造成伤害
function p.GetStateHurtWords(tHurtInfo, nHeroId)
	
	if #tHurtInfo > 1 then
		for k,v in ipairs(tHurtInfo) do
			local strName = p.GetHeroNameByHeroId(v[1], nHeroId);
			p.InsertBattleText(strName, 22, 31);
			
			local str_1, str_2 = p.GetHurtTypeForBufEx(v[3]);
			if str_1 ~= "" then
				p.InsertBattleText(str_1, 22, 32);
			end
			--伤害
			p.InsertBattleText(tostring(v[2]), 22, v[3]);
			if str_2 ~= "" then
				p.InsertBattleText(str_2.."\n", 22, 32);
			end
			if GameFightCenter:IsShowLog() then
				local str = strName..str_1..v[2]..str_2;
				cclog(str);
			end
		end
	else
		if tHurtInfo[1][2] > 0 then
			--谁 因 ?? 受到了 ?? 伤害
			local tCfgBuffer = CfgData["cfg_Buffer"][tHurtInfo[1][4]];
			if tCfgBuffer ~= nil then
				local strName = p.GetHeroNameByHeroId(tHurtInfo[1][1], nHeroId);
				p.InsertBattleText(strName, 22, 31);
				p.InsertBattleText(ZhTextSet_50120, 22, 32);
				local strBuffName = tCfgBuffer["state_name"];
				p.InsertBattleText(strBuffName.." ", 22, 33);
				local str_1, str_2 = p.GetHurtTypeForBufEx(tHurtInfo[1][3]);
				if str_1 ~= "" then
					p.InsertBattleText(str_1, 22, 32);
				end
				--伤害
				p.InsertBattleText(tostring(tHurtInfo[1][2]), 22, tHurtInfo[1][3]);
				if str_2 ~= "" then
					p.InsertBattleText(str_2.."\n", 22, 32);
				end
				if GameFightCenter:IsShowLog() then
					local str = strName.."因"..strBuffName..str_1..tHurtInfo[1][2]..str_2;
					cclog(str);
				end
			else
				cclog("*** Text Battle GetStateHurtWords Error:%s***", tostring(tHurtInfo[1][4]));
			end
		end
	end
end

--状态产生Buffer描述
function p.GetBufferStateDes(tBuffers, nHeroId)
	local str = "";
	for k,v in ipairs(tBuffers) do
		-- {nBufferId, v.nAttackId, bAdd}
		if v[3] then
			-- local strBuffName = CfgData["cfg_Buffer"][v[1]]["state_name"];
			-- local strHeroName = p.GetHeroNameByHeroId(v[2], nHeroId);
			-- str = str.."产生了Buffer"..strBuffName;
			-- 好的Buff应该是(获得),坏的应该是(产生)
			-- cclog("因技能 "..skillName.." "..strHeroName.." 获得 "..strBuffName.." 效果");
			cclog("******* Text Battle GetBufferStateDes*******");
		else
			local tCfgBuffer = CfgData["cfg_Buffer"][v[1]];
			if tCfgBuffer ~= nil then
				local strHeroName = p.GetHeroNameByHeroId(v[2], nHeroId);
				local strBuffName = tCfgBuffer["state_name"];
				
				p.InsertBattleText(strHeroName, 22, 31);
				p.InsertBattleText(ZhTextSet_50119, 22, 32);
				p.InsertBattleText(strBuffName, 22, 33);
				p.InsertBattleText(ZhTextSet_50118, 22, 32);
				
				if GameFightCenter:IsShowLog() then
					local str = strHeroName.." 移除了 "..strBuffName.." 效果";
					cclog(str);
				end
			else
				cclog("*** Text Battle GetBufferStateDes Error:%s***", tostring(v[1]));
			end
		end
	end
end

--Buff产生的伤害描述
function p.GetBufferHurts(tBuffHurts, nHeroId)
	local str = "";
	for k,v in ipairs(tBuffHurts) do
		-- {v.nSkillId, v.nAttackType, v.nDamageHurt, v.nBeAttackId[1]}
		local tCfgBuffer = CfgData["cfg_Buffer"][v[1]]
		if tCfgBuffer ~= nil then
			local strBuffName = tCfgBuffer["state_name"];
			local strHeroName = p.GetHeroNameByHeroId(v[4], nHeroId);
			local str_1,str_2 = p.GetHurtTypeForBuf(v[2]);
			
			p.InsertBattleText(strHeroName, 22, 31);
			p.InsertBattleText(ZhTextSet_50120, 22, 32);
			p.InsertBattleText(strBuffName, 22, 33);
			p.InsertBattleText(str_1, 22, 32);
			p.InsertBattleText(tostring(v[3]), 22, v[2]);
			p.InsertBattleText(str_2.."\n", 22, 32);
			
			if GameFightCenter:IsShowLog() then
				local str = strHeroName.." 因 "..strBuffName..str_1..v[3]..str_2;
				cclog(str);
			end
		else
			cclog("***Text Battle In Function GetBufferHurts Error:%s", tostring(v[1]));
		end
	end
	return str;
end

--攻击类型文字描述
function p.GetHurtTypeDes(nHurtType)

	if nHurtType == EnumDamage.NORMAL then --普通命中
		return true,"";
	elseif nHurtType == EnumDamage.CIRTICAL	then --暴击
		return true,"";
	elseif nHurtType == EnumDamage.DODGE then--闪避
		return false,ZhTextSet_50121;
	elseif nHurtType == EnumDamage.PARRY then --格挡
		return true,ZhTextSet_50122;
	elseif nHurtType == EnumDamage.CURE then--治疗
		return true,"";
	elseif nHurtType == EnumDamage.SUCK	then --吸血
		return true,"";
	elseif nHurtType == EnumDamage.REBOUND	then --反弹
		return true,"";
	elseif nHurtType == EnumDamage.BATBACK	then --反击
		return true,"";
	elseif nHurtType == EnumDamage.BUFF	then --状态
		return true,"";
	elseif nHurtType == EnumDamage.REVIVE	then --复活
		return true,"";
	elseif nHurtType == EnumDamage.SELF		then--自伤
		return true,"";
	elseif nHurtType == EnumDamage.VERTIGO	then--眩晕
		return true,"";
	elseif nHurtType == EnumDamage.BUFFERMOVE	then--消除Buff
		return true,"";
	elseif nHurtType == EnumDamage.NONE		then--什么都没有
		return true,"";
	elseif nHurtType == EnumDamage.WORLD	then--文字显示
		return true,"";
	end
	return true,"";
end

--攻击类型文字描述
function p.GetHurtTypeDesForBuf(nHurtType)

	if nHurtType == EnumDamage.NORMAL then --普通命中
		return "";
	elseif nHurtType == EnumDamage.CIRTICAL	then --暴击
		return "";
	elseif nHurtType == EnumDamage.DODGE then--闪避
		return false," "..ZhTextSet_50121;
	elseif nHurtType == EnumDamage.PARRY then --格挡
		return false," "..ZhTextSet_50122;
	elseif nHurtType == EnumDamage.CURE then--治疗
		return "";
	elseif nHurtType == EnumDamage.SUCK	then --吸血
		return "";
	elseif nHurtType == EnumDamage.REBOUND	then --反弹
		return "";
	elseif nHurtType == EnumDamage.BATBACK	then --反击
		return "";
	elseif nHurtType == EnumDamage.BUFF	then --状态
		return "";
	elseif nHurtType == EnumDamage.REVIVE	then --复活
		return "";
	elseif nHurtType == EnumDamage.SELF		then--自伤
		return "";
	elseif nHurtType == EnumDamage.VERTIGO	then--眩晕
		return ZhTextSet_50123;
	elseif nHurtType == EnumDamage.BUFFERMOVE	then--消除Buff
		return "";
	elseif nHurtType == EnumDamage.NONE		then--什么都没有
		return "";
	elseif nHurtType == EnumDamage.WORLD	then--文字显示
		return "";
	end
	return "";
end

--攻击文字描述
function p.GetHurtTypeWord(nHurtType)
	local str = "";
	if nHurtType == EnumDamage.NORMAL then --普通命中
		str =  ZhTextSet_50124;
	elseif nHurtType == EnumDamage.CIRTICAL	then --暴击
		str =  ZhTextSet_50124;
	elseif nHurtType == EnumDamage.DODGE then --闪避
		str =  ZhTextSet_50124;
	elseif nHurtType == EnumDamage.PARRY then --格挡
		str =  ZhTextSet_50124;
	elseif nHurtType == EnumDamage.CURE then --治疗
		str =  "";
	elseif nHurtType == EnumDamage.SUCK	then --吸血
		str =  ZhTextSet_50124;
	elseif nHurtType == EnumDamage.REBOUND	then --反弹
		str =  ZhTextSet_50124;
	elseif nHurtType == EnumDamage.BATBACK	then --反击
		str =  ZhTextSet_50124;
	elseif nHurtType == EnumDamage.BUFF	then --状态
		str =  ZhTextSet_50124;
	elseif nHurtType == EnumDamage.REVIVE	then --复活
		str =  ZhTextSet_50124;
	elseif nHurtType == EnumDamage.SELF		then--自伤
		str =  ZhTextSet_50124;
	elseif nHurtType == EnumDamage.VERTIGO	then--眩晕
		str =  ZhTextSet_50124;
	elseif nHurtType == EnumDamage.BUFFERMOVE	then--消除Buff
		str =  ZhTextSet_50124;
	elseif nHurtType == EnumDamage.NONE		then--什么都没有
		str =  "";
	elseif nHurtType == EnumDamage.WORLD	then--文字显示
		str =  "";
	end
	if str ~= "" then
		p.InsertBattleText(str, 22, 32);
	end
	return str;
end

--Buff攻击状态描述
function p.GetHurtTypeForBuf(nHurtType)
	if nHurtType == EnumDamage.NORMAL then --普通命中
		return ZhTextSet_50125, ZhTextSet_50126;
	elseif nHurtType == EnumDamage.CIRTICAL	then --暴击
		return ZhTextSet_50125, ZhTextSet_50126;
	elseif nHurtType == EnumDamage.DODGE then--闪避
		return ZhTextSet_50125, ZhTextSet_50126;
	elseif nHurtType == EnumDamage.PARRY then --格挡
		return ZhTextSet_50125, ZhTextSet_50126;
	elseif nHurtType == EnumDamage.CURE then--治疗
		return ZhTextSet_50127, ZhTextSet_50129;
	elseif nHurtType == EnumDamage.SUCK	then --吸血
		return ZhTextSet_50128, ZhTextSet_50129;
	elseif nHurtType == EnumDamage.REBOUND	then --反弹
		return ZhTextSet_50130, ZhTextSet_50126;
	elseif nHurtType == EnumDamage.BATBACK	then --反击
		return ZhTextSet_50125, ZhTextSet_50126;
	elseif nHurtType == EnumDamage.BUFF	then --状态
		return ZhTextSet_50125, ZhTextSet_50126;
	elseif nHurtType == EnumDamage.REVIVE	then --复活
		return ZhTextSet_50131, ZhTextSet_50129;
	elseif nHurtType == EnumDamage.SELF		then--自伤
		return ZhTextSet_50125, ZhTextSet_50126;
	elseif nHurtType == EnumDamage.VERTIGO	then--眩晕
		return ZhTextSet_50125, ZhTextSet_50126;
	elseif nHurtType == EnumDamage.BUFFERMOVE	then--消除Buff
		return ZhTextSet_50125, ZhTextSet_50126;
	elseif nHurtType == EnumDamage.NONE		then--什么都没有
		return ZhTextSet_50125, ZhTextSet_50126;
	elseif nHurtType == EnumDamage.WORLD	then--文字显示
		return ZhTextSet_50125, ZhTextSet_50126;
	end
	return "", "";
end


--Buff攻击状态描述
function p.GetHurtTypeForBufEx(nHurtType)
	if nHurtType == EnumDamage.NORMAL then --普通命中
		return ZhTextSet_50132, ZhTextSet_50126;
	elseif nHurtType == EnumDamage.CIRTICAL	then --暴击
		return ZhTextSet_50132, ZhTextSet_50126;
	elseif nHurtType == EnumDamage.DODGE then--闪避
		return ZhTextSet_50132, ZhTextSet_50126;
	elseif nHurtType == EnumDamage.PARRY then --格挡
		return ZhTextSet_50132, ZhTextSet_50126;
	elseif nHurtType == EnumDamage.CURE then--治疗
		return ZhTextSet_50127, ZhTextSet_50134;
	elseif nHurtType == EnumDamage.SUCK	then --吸血
		return ZhTextSet_50128, ZhTextSet_50134;
	elseif nHurtType == EnumDamage.REBOUND	then --反弹
		return ZhTextSet_50133, ZhTextSet_50126;
	elseif nHurtType == EnumDamage.BATBACK	then --反击
		return ZhTextSet_50132, ZhTextSet_50126;
	elseif nHurtType == EnumDamage.BUFF	then --状态
		return ZhTextSet_50132, ZhTextSet_50126;
	elseif nHurtType == EnumDamage.REVIVE	then --复活
		return ZhTextSet_50131, ZhTextSet_50134;
	elseif nHurtType == EnumDamage.SELF		then--自伤
		return ZhTextSet_50132, ZhTextSet_50126;
	elseif nHurtType == EnumDamage.VERTIGO	then--眩晕
		return ZhTextSet_50132, ZhTextSet_50126;
	elseif nHurtType == EnumDamage.BUFFERMOVE	then--消除Buff
		return ZhTextSet_50132, ZhTextSet_50126;
	elseif nHurtType == EnumDamage.NONE		then--什么都没有
		return ZhTextSet_50132, ZhTextSet_50126;
	elseif nHurtType == EnumDamage.WORLD	then--文字显示
		return ZhTextSet_50132, ZhTextSet_50126;
	end
	return "", "";
end

--********************************************************
--获取英雄名字
function p.GetHeroNameByHeroId(nId, nHeroId)
	if m_tHeroInfo[tostring(nId)] ~= nil then
		if m_tHeroInfo[tostring(nId)].sName ~= nil then
			if nId == nHeroId then
				return ZhTextSet_50135;
			end
			return m_tHeroInfo[tostring(nId)].sName;
		end
	end
	return "";
end


return p;