--游戏战斗音乐
GameFightMusic = {};
local p = GameFightMusic;

MusicEnum = {
	MUSIC_RUSH = {"rush.mp3"},						--冲刺
	MUSIC_LIGHTWEAPON_ATK = {"lightweapon_atk.mp3"},		--轻武器攻击
	MUSIC_LIGHTWEAPON_BEATK = {"lightweapon_beatked.mp3"},	--轻武器被击
	MUSIC_MDLWEAPON_ATK = {"mdlweapon_atk.mp3"},		--中武器攻击
	MUSIC_MDLWEAPON_BEATK = {"mdlweapon_beatked.mp3"},	--中武器被击
	MUSIC_HEAWEAPON_ATK = {"heavyweapon_atk.mp3"},			--重武器攻击
	MUSIC_HEAWEAPON_BEATK = {"heavyweapon_beatked.mp3"},	--重武器被击
	MUSIC_LONGWEAPON_ATK = {"longweapon_atk.mp3"},			--长柄武器攻击
	MUSIC_LONGWEAPON_BEATK = {"longweapon_beatked.mp3"},	--长柄武器被击
	MUSIC_BOWWEAPON_ATK = {"bow_atk.mp3"},			--弓箭武器攻击
	MUSIC_BOWWEAPON_BEATK = {"bow_beatked.mp3"},	--弓箭武器被击

	MUSIC_MAGICWEAPON_ATK = {"releasemagic.mp3"},	--法杖武器攻击
	MUSIC_MAGICWEAPON_BEATK = {"wand_beatked.mp3"},	--法杖武器被击	
	MUSIC_WEAPON_BLOCK = {"block.mp3"},				--武器格挡
	
	MUSIC_MAP_WALK = {"move_loop.mp3"},				--地图走路
	MUSIC_MAP_RUN = {"run_loop.mp3"},				--地图走路
};

MusicSkillTB = {
	-- MUSIC_10010 then --普通攻击
	MUSIC_10000 = {"release.mp3"}, --通用施法
	
	MUSIC_10020 = {"ATKskill2.mp3"}, --猛击
	MUSIC_10026 = {"ATKskill1.mp3"}, --冲撞
	MUSIC_10040 = {"contain.mp3"}, --牵制
		
	--10023
	MUSIC_100231 = {"fightbellow_atk.mp3"}, 	--战吼 释放
	MUSIC_100232 = {"fightbellow_beatked.mp3"}, --战吼 受记
	MUSIC_100233 = {"fightbellow_hit.mp3"}, --战吼 受记
	
	MUSIC_10055	=  {"fire_ball.mp3"},			 --火球术	2
	MUSIC_10060 = {"magicball.mp3"}, --魔法攻击	2
	MUSIC_10085 = {"ATKskill2.mp3"}, --迅捷一击	2
	MUSIC_10090 = {"ATKskill1.mp3"}, --穿刺攻击	2
	MUSIC_10120 = {"AOEskill.mp3"}, --顺势斩	2
	MUSIC_10130	= {"EnchantAtk.mp3"},	--附魔攻击	2
	MUSIC_10155 = {"ridicule.mp3"}, --群体嘲讽	1
	MUSIC_10160 = {"ATKskill1.mp3"}, --身体冲撞	2
	MUSIC_10200	= {"burst_fire_ball.mp3"},	--连发火球	2
	MUSIC_10220 = {"magiccrit.mp3"}, --魔法暴击	2
	MUSIC_102401 = {"punishstrike_atk.mp3"}, --惩罚刺击	1
	MUSIC_102402 = {"punishstrike_beatked.mp3"}, --惩罚刺击	2
	MUSIC_102403 = {"punishstrike_hit.mp3"}, --惩罚刺击	3
	MUSIC_10290 = {"poisontooth.mp3"}, --毒牙	2
	MUSIC_10330 = {"AOEskill.mp3"}, --破邪一击	2
	MUSIC_10350 = {"secchopped.mp3"}, --二段斩	2
	MUSIC_10360 = {"violenttornado.mp3"}, --狂暴旋风	2
	MUSIC_103801 = {"violentheart_atk.mp3"}, --狂暴之心释放	1
	MUSIC_103802 = {"violentheart_beatked.mp3"}, --狂暴之心受击	2
	MUSIC_103803 = {"violentheart_hit.mp3"}, --狂暴之心受击	4
	MUSIC_10390 = {"GZYZ.mp3"}, --孤注一掷	2
	MUSIC_104101 = {"tradedeficit_atk.mp3"}, 	--逆差攻击	1
	MUSIC_104102 = {"tradedeficit_beatked.mp3"}, --逆差攻击	2
	MUSIC_10420 = {"tentacleplague.mp3"}, --瘟疫之触	2
	MUSIC_10460 = {"deathfrost.mp3"}, --死亡霜寒	2
	MUSIC_10470 = {"vampiretentacle.mp3"}, --吸血鬼之触	2
	MUSIC_104801 = {"spiralimpact_atk.mp3"}, --螺旋冲击	1
	MUSIC_104802 = {"spiralimpact_beatked.mp3"}, --螺旋冲击	2
	MUSIC_104803 = {"spiralimpact_hit.mp3"}, --螺旋冲击	2
	MUSIC_104901 = {"weakenatk_atk.mp3"}, --削弱攻击	1
	MUSIC_104902 = {"weakenatk_beatked.mp3"}, --削弱攻击	2
	MUSIC_10520	= {"DefStance.mp3"},	--防御姿态	2
	MUSIC_10530 = {"YGYS.mp3"}, --寓攻于守	1
	MUSIC_105401 = {"paladin_atk.mp3"}, --圣骑技能释放音效	1
	MUSIC_105402 = {"arun_beatked.mp3"}, --虔诚光环	2
	MUSIC_105501 = {"paladin_atk.mp3"}, --圣骑技能释放音效	1
	MUSIC_105502 = {"arun_beatked.mp3"}, --专注光环	2
	MUSIC_105701 = {"paladin_atk.mp3"}, --圣骑技能释放音效	1
	MUSIC_105702 = {"arun_beatked.mp3"}, --荆棘光环	2
	MUSIC_105801 = {"paladin_atk.mp3"}, --圣骑技能释放音效	1
	MUSIC_105802 = {"fervorlight.mp3"}, --炽热光辉	2
	MUSIC_10600 = {"blazingstar.mp3"}, --炽焰之星	2
	MUSIC_106101 = {"charge_atk.mp3"}, --充能攻击释放	1
	MUSIC_106102 = {"charge_beatked.mp3"}, --充能攻击受击	2
	MUSIC_10620 = {"fireshield.mp3"}, --火焰护盾	1
	MUSIC_10630 = {"foreverfire.mp3"}, --不熄之炎	2
	MUSIC_10640 = {"firestorm.mp3"}, --烈焰风暴	2
	MUSIC_10660 = {"soulword.mp3"}, --言灵咒	2
	MUSIC_10670 = {"fire_word.mp3"}, --火言咒	2
	MUSIC_10680 = {"magneticshield.mp3"}, --力场护盾	1
	MUSIC_10700 = {"worddoll.mp3"}, --咒缚人偶	2
	MUSIC_10710 = {"deathimprint.mp3"}, --死神印记	2
	MUSIC_10720 = {"baptism.mp3"}, --洗礼	2
	MUSIC_10730 = {"disperse.mp3"}, --驱散	2
	MUSIC_10740 = {"innocenthand.mp3"}, --无罪之手	2
	MUSIC_10770 = {"saintword.mp3"}, --圣言	2
	MUSIC_10780 = {"sunder.mp3"}, --破甲攻击	2
	MUSIC_10790 = {"trialanger.mp3"}, --审判之怒	2
	MUSIC_10800 = {"powtrial.mp3"}, --力之审判	2
	MUSIC_10820 = {"verdictlight.mp3"}, --裁决之光	2
	MUSIC_10840 = {"shadowcloak.mp3"}, --暗影斗篷	1
	MUSIC_10850 = {"exoticshiv.mp3"}, --异域毒刃	2
	MUSIC_108601 = {"backstab_atk.mp3"}, --背刺	1
	MUSIC_108602 = {"backstab_beatked.mp3"}, --背刺	2
	MUSIC_108603 = {"backstab_hit.mp3"}, --背刺	2
	MUSIC_10880 = {"smog.mp3"}, --毒雾喷射	2
	MUSIC_10890	= {"shadow_thorn.mp3"},	--暗影之刺	2
	MUSIC_10900 = {"shadowstrick.mp3"}, --暗影闪击	2
	MUSIC_10910 = {"dexbatter.mp3"}, --灵巧连击	2
	MUSIC_10950 = {"danceofdeath.mp3"}, --死亡之舞	2
	MUSIC_10960 = {"NS.mp3"}, --内视	2
	MUSIC_10970 = {"arithmetic.mp3"}, --算术	2
	MUSIC_110001 = {"random_atk.mp3"}, --乱数攻击	2
	MUSIC_110002 = {"random_filed.mp3"}, --乱数失败	1
	MUSIC_110003 = {"heal.mp3"}, --乱数治疗
	MUSIC_11010 = {"realvision.mp3"}, --真实视觉	2
	MUSIC_11020 = {"vertigoatk.mp3"}, --眩晕攻击	2
	MUSIC_11050 = {"aimhorn.mp3"}, --集火号角	2
	MUSIC_11060 = {"soulshock.mp3"}, --灵魂震慑	2
	
	MUSIC_10270 = {"heal.mp3"},--治疗
	MUSIC_10560 = {"heal.mp3"},--治疗

}



--For SpriteSkillRelease
function p.InsertPlayEffect(actionArray, tEnumMusic)
	--播放冲刺音效
	table.insert(actionArray,{nil, nil, ActionEnum.MUSIC_ACTION, tEnumMusic});
end

function p.InsertPlayEffectByRoleType(actionArray, nType, isAttack, bSkillType)
	if nType == 1 then		--[[右手双面斧头(重型)]]
		if isAttack then
			table.insert(actionArray,{nil, nil, ActionEnum.MUSIC_ACTION, MusicEnum.MUSIC_HEAWEAPON_ATK});
		else
			if bSkillType == 1 then
				table.insert(actionArray,{nil, nil, ActionEnum.MUSIC_ACTION, MusicEnum.MUSIC_HEAWEAPON_BEATK});
			elseif bSkillType == 2 then
				table.insert(actionArray,{nil, nil, ActionEnum.MUSIC_ACTION, MusicEnum.MUSIC_WEAPON_BLOCK});
			end
		end
	elseif nType == 2 then --[[右手当面斧头(中型)]]
		if isAttack then
			table.insert(actionArray,{nil, nil, ActionEnum.MUSIC_ACTION, MusicEnum.MUSIC_MDLWEAPON_ATK});
		else
			if bSkillType == 1 then
				table.insert(actionArray,{nil, nil, ActionEnum.MUSIC_ACTION, MusicEnum.MUSIC_MDLWEAPON_BEATK});
			elseif bSkillType == 2 then
				table.insert(actionArray,{nil, nil, ActionEnum.MUSIC_ACTION, MusicEnum.MUSIC_WEAPON_BLOCK});
			end
		end
	elseif nType == 3 or nType == 0 then --[[右手长戟,没有武器(长柄)]]
		if isAttack then
			table.insert(actionArray,{nil, nil, ActionEnum.MUSIC_ACTION, MusicEnum.MUSIC_LONGWEAPON_ATK});
		else
			if bSkillType == 1 then
				table.insert(actionArray,{nil, nil, ActionEnum.MUSIC_ACTION, MusicEnum.MUSIC_LONGWEAPON_BEATK});
			elseif bSkillType == 2 then
				table.insert(actionArray,{nil, nil, ActionEnum.MUSIC_ACTION, MusicEnum.MUSIC_WEAPON_BLOCK});
			end
		end
	elseif nType == 4 then --[[右手短剑]]
		if isAttack then
			table.insert(actionArray,{nil, nil, ActionEnum.MUSIC_ACTION, MusicEnum.MUSIC_LIGHTWEAPON_ATK});
		else
			if bSkillType == 1 then
				table.insert(actionArray,{nil, nil, ActionEnum.MUSIC_ACTION, MusicEnum.MUSIC_LIGHTWEAPON_BEATK});
			elseif bSkillType == 2 then
				table.insert(actionArray,{nil, nil, ActionEnum.MUSIC_ACTION, MusicEnum.MUSIC_WEAPON_BLOCK});
			end
		end
	elseif nType == 5 then --[[左手弓箭]]
		if isAttack then
			table.insert(actionArray,{nil, nil, ActionEnum.MUSIC_ACTION, MusicEnum.MUSIC_BOWWEAPON_ATK});
		else
			if bSkillType == 1 then
				table.insert(actionArray,{nil, nil, ActionEnum.MUSIC_ACTION, MusicEnum.MUSIC_BOWWEAPON_BEATK});
			elseif bSkillType == 2 then
				table.insert(actionArray,{nil, nil, ActionEnum.MUSIC_ACTION, MusicEnum.MUSIC_WEAPON_BLOCK});
			end
		end
	elseif nType == 6 then --[[左手法杖]]
		if isAttack then
			table.insert(actionArray,{nil, nil, ActionEnum.MUSIC_ACTION, MusicEnum.MUSIC_MAGICWEAPON_ATK});
		else
			if bSkillType == 1 then
				table.insert(actionArray,{nil, nil, ActionEnum.MUSIC_ACTION, MusicEnum.MUSIC_MAGICWEAPON_BEATK});
			elseif bSkillType == 2 then
				table.insert(actionArray,{nil, nil, ActionEnum.MUSIC_ACTION, MusicEnum.MUSIC_WEAPON_BLOCK});
			end
		end
	else
		cclog("***Play Fight Music Error RoleType***");
	end
end

--For SceneSkillEffectPool

function p.PlaySkillEffectMusic(tMusicInfo)
	
	if tMusicInfo ~= nil then
		local nSkillID = tMusicInfo[1];
		local eSkillExt= tMusicInfo[2];
		local tMusicCfg = MusicSkillTB["MUSIC_"..tostring(nSkillID)];
		if tMusicCfg ~= nil then
			p.PlayEffect(tMusicCfg, false);
		else
			cclog("***技能ID:%d,没有音效***", nSkillID);
		end
	end
end

-----------------------------------------------------------------------------
function p.PlayWalkOnMap(bPlay)
	if bPlay then
		-- p.PlayEffect(MusicEnum.MUSIC_MAP_WALK, true)
	else
		-- p.UnLoadMusic(MusicEnum.MUSIC_MAP_WALK)
	end
end

function p.PlayRunOnMap(bPlay)
	if bPlay then
		-- p.PlayEffect(MusicEnum.MUSIC_MAP_RUN, true)
	else
		-- p.UnLoadMusic(MusicEnum.MUSIC_MAP_RUN)
	end
end


--播放一个战斗特效音乐
function p.FightIsShow()
	if GameFightCenter.FightBattleIsShow() then
		if GameFightCenter.Layer ~= nil then
			return GameFightCenter.Layer:isVisible()
		end
	end
	return false
end

--播放战斗背景音乐
function p.PlayFightBackMusic()
	-- if p.FightIsShow() then
		AudioEngine.playMusic("res/sound/fight.mp3", true)
	-- end
end

function p.PlayFightEndMusic(bSuccess)
	if p.FightIsShow() and UserData.effectOn then
		local fileMusic = "";
		if bSuccess then
			fileMusic = "res/sound/success.mp3"
		else
			fileMusic = "res/sound/fail.mp3"
		end
		SimpleAudioEngine:sharedEngine():playEffect(fileMusic, false)
	end
end

function p.RestPlayBackMusic()
	AudioEngine.playMusic("res/sound/BGM_MAIN_THEME.mp3", true)
end

function p.PlayEffect(tEnumMusic, isLoop)
    local loopValue = false;
    if nil ~= isLoop then
        loopValue = isLoop
    end
	local filename = "fightMusic/"..tEnumMusic[1];
	if p.FightIsShow() and UserData.effectOn then
		SimpleAudioEngine:sharedEngine():playEffect(filename, loopValue)
	end
end

function p.UnLoadMusic(tEnumMusic)
	local filename = "fightMusic/"..tEnumMusic[1];
	-- if p.FightBattleIsShow() then
		SimpleAudioEngine:sharedEngine():unloadEffect(filename)
	-- end
end



