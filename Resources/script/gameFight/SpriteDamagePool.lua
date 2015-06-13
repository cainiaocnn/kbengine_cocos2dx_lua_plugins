
-- 给战斗精灵伤害数据池
SpriteDamagePool = {};
local t = SpriteDamagePool;

local m_ShowActionList = {};
local m_DamageHurtList = {};

--(Demo)例子
-- tDamage = {1, 2, DamageEnum.NORMAL_DAMAGE, {{HurtEnum.NORMAL_HURT, 100},{HurtEnum.NORMAL_HURT,200}}};
-- SpriteDamagePool:PushInActionFromQueue(tDamage)


-- 数据部分*******************************************
------------------------------------------------------
--账号注销回调函数
function t.gameLoginOut()
	m_ShowActionList = {};
	m_DamageHurtList = {};
end

--伤害枚举
HurtEnum = {
	--[[跳过伤害]]NOSHOW_HURT = 0,
	--[[普通伤害]]NORMAL_HURT = 1,
	--[[文字提示]]NORMAL_TIPS = 2,
	--[[伤害加血]]ADDHP_HURT  = 3,
	--[[中毒减血]]POISON_HURT = 4,
	--[[伤害暴击]]CIRT_HURT   = 5,
	--[[移除Buff]]REMOVEBUFF  = 12,
};


-- 推入一个伤害数据
-- {nAttackSpriteTag, nBeAttackSpriteTag, DamageEnum.NORMAL_DAMAGE, {{HurtEnum.NORMAL_HURT,nAttackHurt}, {HurtEnum.NORMAL_HURT,nBeAttackHurt}}}
function t:PushInActionFromQueue(tDamage)
	table.insert(m_DamageHurtList, tDamage);
end

-- 推出一个伤害数据
function t:PushOutActionFromQueue()
	if #m_DamageHurtList > 0 then
		local tDamage = m_DamageHurtList[1];
		table.remove(m_DamageHurtList, 1);
		return tDamage;
	end
	return nil;
end


-- 显示部分******************************************
-----------------------------------------------------

-- 伤害数据解析
function t:ShowDamageHurt(tDamageList)
	if tDamageList ~= nil then
		for k,v in pairs(tDamageList) do
			
			local nHurtSpriteMainTag = v[1][1];
			local nHurtSpriteTag 	 = v[1][2];			
			if nHurtSpriteTag == nil then
				cclog("***伤害数据池,接受伤害角色错误***");
				if nHurtSpriteMainTag == nil then
					cclog("***伤害数据池,释放伤害角色错误***");
				end
			end

			local nHurtDamage 		= v[2];
			local eHurtEnum 		= v[3];
			local nHurtID 			= v[4];
			if nHurtID == nil then
				cclog("***伤害触发的ID未空---");
				cclog("---造成伤害的ID = %d---", nHurtID);
			end
			-- if not t:IsNowHeroShowNumAction(nHurtSpriteTag) then
				local nLeadBuffId = SpriteSkillBufferPool:GetBuffLeadToBuff(nHurtID);
				if nLeadBuffId ~= nil then
					local tBuffer = {};
					SkillReleaseCenter:BufferList(tBuffer, nLeadBuffId, nHurtSpriteMainTag, 1);
					if #tBuffer > 0 then
						SpriteSkillBufferPool:PushInBufferToQueue(tBuffer);
					end
				end
				--
				local tBufferMain = {};
				SkillReleaseCenter:BufferList(tBufferMain, nHurtID, nHurtSpriteTag, 1);
				if #tBufferMain > 0 then
					SpriteSkillBufferPool:PushInBufferToQueue(tBufferMain);
				end
				t:HurtPerformance(nHurtSpriteTag, nHurtDamage, eHurtEnum);
			-- else
				-- t:PushInActionFromQueue({v});
			-- end
		end
	end
end

-- 伤害表现
function t:HurtPerformance(nHurtSpriteTag, nHurtDamage, eHurtEnum)

	-------------------------------------------
	if eHurtEnum ~= nil and nHurtDamage ~= nil then
		if eHurtEnum ~= HurtEnum.NOSHOW_HURT then
			if nHurtDamage ~= 0 then
				-- local tAttackSprite = SpriteArmaturePool:GetArmature(nHurtSpriteTag);
				local tAttackSprite = SpriteArmaturePool:GetArmatureIgnoreDeath(nHurtSpriteTag);
				if tAttackSprite ~= nil then
					local fScale = 0.8;
					local hurtLabel = nil;
					if eHurtEnum == HurtEnum.NORMAL_HURT then
						local str = "-"..tostring(nHurtDamage);
						hurtLabel = CCLabelBMFont:create(str, "fonts/red_number.fnt");				
					elseif eHurtEnum == HurtEnum.NORMAL_TIPS then
						hurtLabel = CCLabelBMFont:create(tostring(nHurtDamage), "fonts/red_number.fnt");				
					elseif eHurtEnum == HurtEnum.ADDHP_HURT then
						local str = "+"..tostring(nHurtDamage);
						hurtLabel = CCLabelBMFont:create(str, "fonts/green_number.fnt");				
					elseif eHurtEnum == HurtEnum.POISON_HURT then
						local str = "-"..tostring(nHurtDamage);
						hurtLabel = CCLabelBMFont:create(str , "fonts/red_number.fnt");
					elseif  eHurtEnum == HurtEnum.CIRT_HURT then
						local str = "-"..tostring(nHurtDamage);
						hurtLabel = CCLabelBMFont:create(str , "fonts/orange_number.fnt");
						fScale = 1.1;
					elseif  eHurtEnum == HurtEnum.REMOVEBUFF then --移除Buff
						cclog("---移除buff导致的伤害不为0,错误---");
						return;
					end
					if hurtLabel == nil then
						cclog("***严重错误,创建字体失败---");
						return;
					end
					hurtLabel:setAnchorPoint( ccp(0.5, 0.5) );
					hurtLabel:setPosition(ccp(0,tAttackSprite.Height+30));
					hurtLabel:setScale(0.1);			
					tAttackSprite.Sprite:addChild(hurtLabel);
					----
					if eHurtEnum == HurtEnum.NORMAL_HURT or eHurtEnum == HurtEnum.CIRT_HURT then
						
						if eHurtEnum == HurtEnum.CIRT_HURT then
							--伤害暴击抖屏
							GameFightCenter:LayerMoveAction();
						end
						--
						if tAttackSprite.ArmatrureHP ~= 0 then
							tAttackSprite.ArmatrureHP = tAttackSprite.ArmatrureHP - nHurtDamage;
						end
						if tAttackSprite.ArmatrureHP <= 0 then
							
							if tAttackSprite.ArmatrureHP ~= 0 or not tAttackSprite.IsDeath then
								--死亡去除所有身上buff
								SpriteSkillBufferPool:RemoveSpriteAllBuffer(nHurtSpriteTag);
							
								tAttackSprite.ArmatrureHP = 0;
								GameFightCenter:UpdateHp(tAttackSprite.SpriteTag, tAttackSprite.ArmatrureHP);
								SpriteArmaturePool:RemoveArmature(nHurtSpriteTag);
								if tAttackSprite.IsEnemy then
									--敌方角色死亡,渐变消失
									local array = CCArray:create();
									array:addObject(CCFadeOut:create(0.8));--1.5
									array:addObject(CCHide:create());
									local pAction = CCSequence:create(array);
									pAction:setTag(1000);--设置死亡Action的Tag
									tAttackSprite.Sprite:runAction(pAction);
								else
									--自己方角色死亡是跪舔模式
									tAttackSprite:PlayAnimationByName("rest",nil,nil,1);
								end
								--文字战报
								GameFightTextBattle.ShowBattleHeroDeath(nHurtSpriteTag, true)
							end
						else
							GameFightCenter:UpdateHp(tAttackSprite.SpriteTag, tAttackSprite.ArmatrureHP);
						end
					elseif eHurtEnum == HurtEnum.NORMAL_TIPS then

					elseif eHurtEnum == HurtEnum.ADDHP_HURT then
						tAttackSprite.ArmatrureHP = tAttackSprite.ArmatrureHP + nHurtDamage;
						-- 如果是死亡的精灵加血,那么就是复活了
						if tAttackSprite.IsDeath then
							
							SpriteArmaturePool:AddArmature(nHurtSpriteTag);
							--清除掉英雄死亡的Action
							tAttackSprite.Sprite:stopActionByTag(1000);
							--动作队列
							local array = CCArray:create();
							array:addObject(CCShow:create());
							array:addObject(CCFadeIn:create(0.8));--1.5
							local pAction = CCSequence:create(array);
							tAttackSprite.Sprite:runAction(pAction);
							--复活后要恢复普通的状态
							tAttackSprite:PlayAnimationByName("standby");
							
							--文字战报
							GameFightTextBattle.ShowBattleHeroDeath(nHurtSpriteTag, false)
						end
						GameFightCenter:UpdateHp(tAttackSprite.SpriteTag, tAttackSprite.ArmatrureHP);
												
					elseif eHurtEnum == HurtEnum.POISON_HURT then
						if tAttackSprite.ArmatrureHP ~= 0 then
							tAttackSprite.ArmatrureHP = tAttackSprite.ArmatrureHP - nHurtDamage;
						end
						if tAttackSprite.ArmatrureHP <= 0 then
							if tAttackSprite.ArmatrureHP ~= 0 or not tAttackSprite.IsDeath then
								--死亡去除所有身上buff
								SpriteSkillBufferPool:RemoveSpriteAllBuffer(nHurtSpriteTag);
								
								tAttackSprite.ArmatrureHP = 0;
								GameFightCenter:UpdateHp(tAttackSprite.SpriteTag, tAttackSprite.ArmatrureHP);
								SpriteArmaturePool:RemoveArmature(nHurtSpriteTag);
								
								if tAttackSprite.IsEnemy then
									tAttackSprite.Sprite:runAction(CCFadeOut:create(1.5));
								else
									tAttackSprite:PlayAnimationByName("rest",nil,nil,1);
								end
								
								--文字战报
								GameFightTextBattle.ShowBattleHeroDeath(nHurtSpriteTag, true)
							end
						else
							GameFightCenter:UpdateHp(tAttackSprite.SpriteTag, tAttackSprite.ArmatrureHP);
						end
					else
						cclog("***严重错误,伤害数据异常,请检查伤害数据---");
					end
					--执行动作
					
					local array = CCArray:create();
					if tAttackSprite.bFlipX then
						array:addObject(CCScaleTo:create(0.25, -1*fScale, 1*fScale));
					else
						array:addObject(CCScaleTo:create(0.25, 1*fScale, 1*fScale));
					end
					array:addObject(CCEaseOut:create(CCMoveBy:create(0.75, ccp(0, 60)),0.5));
					local pCSpawn = CCSpawn:create(array);	
					
					local array2 = CCArray:create();
					local fDelay = t:GetNowHeroShowNumAction(nHurtSpriteTag);
					if fDelay > 0 then
						array2:addObject(CCDelayTime:create(fDelay*0.1));
					end
					array2:addObject(pCSpawn);
					t:SetIsNowHeroShowNumAction(nHurtSpriteTag, 1);
					local function func()
						t:SetIsNowHeroShowNumAction(nHurtSpriteTag, -1);
					end
					array2:addObject(CCCallFunc:create(func));
					array2:addObject(CCRemoveSelf:create(true));
					local pAction = CCSequence:create(array2);	
					hurtLabel:runAction(pAction);
				end
			end
		end
	else
		cclog("***严重错误,伤害数据池读取数据错误---");
	end	
end

--是否该精灵有飘字的动作
function t:GetNowHeroShowNumAction(nSpriteTag)
	if m_ShowActionList[tostring(nSpriteTag)] ~= nil then
		return m_ShowActionList[tostring(nSpriteTag)];
	end
	return 1;
end

function t:SetIsNowHeroShowNumAction(nSpriteTag, nValue)
	if m_ShowActionList[tostring(nSpriteTag)] == nil then
		m_ShowActionList[tostring(nSpriteTag)] = 1;
	else
		m_ShowActionList[tostring(nSpriteTag)] = m_ShowActionList[tostring(nSpriteTag)] + nValue;
	end
end

function t:RemoveNumActionList()
	m_ShowActionList = {};
end

return t;