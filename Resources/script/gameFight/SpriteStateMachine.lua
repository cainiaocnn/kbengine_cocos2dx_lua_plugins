--给物体添加状态机

-- 测试状态机
-- t.fsm:doEvent("move");

--[[--
-- 在任何事件开始前被激活
onbeforeevent = function()
	cclog("onenteridle_____444")
end,
-- 在离开任何状态时被激活
onleavestate = function()
	cclog("onenteridle_____555")
end,
-- 在进入任何状态时被激活
onenterstate = function()
	cclog("onenteridle_____666")
end,
-- 在任何事件结束后被激活
onafterevent = function()
	cclog("onenteridle_____777")
end,
-- 当状态发生改变的时候被激活
onchangestate = function()
	cclog("onenteridle_____888")
end,
]]

--人种族状态机
function addHumanStateMachine(t)
	local tMachine = {  
		initial = "normal",  
		events = {
			--[[站立]]{name = "normal", from = {"badstate","move", "dash","attack", "mgattack","beattack", "dodge", "parry"}, to = "normal"},
			--[[移动]]{name = "move",   from = {"badstate","normal","dash","run"}, to = "move"},
			--[[冲击]]{name = "dash",   from = {"badstate","normal"}, to = "dash"},
			--[[冲击]]{name = "run",   from = {"badstate","normal","move"}, to = "run"},
			--[[物伤]]{name = "attack", from = {"badstate","normal", "move","dash","beattack"}, to = "attack"},
			--[[法伤]]{name = "mgattack", from = {"badstate","normal", "move","dash"}, to = "mgattack"},
			--[[被击]]{name = "beattack", from = {"badstate","normal", "move","dash","attack"}, to = "beattack"},
			--[[闪避]]{name = "dodge",  from = {"badstate","normal", "beattack"}, to = "dodge"},
			--[[格挡]]{name = "parry",  from = {"badstate","normal", "beattack"}, to = "parry"},
			--[[眩晕]]{name = "badstate",  from = {"normal"}, to = "badstate"},
		},  
  
		callbacks = {  
			onenternormal = function ()  
				t:PlayAnimationByName("standby");
			end,  
			
			onentermove = function ()  
				t:PlayAnimationByName("move",nil,nil,1);
			end,  
			
  			onenterdash = function ()  
				t:PlayAnimationByName("dash",nil,nil,1);
			end,  
			
  			onenterrun = function ()  
				t:PlayAnimationByName("run",nil,nil,1);
			end,  			
			
			onenterattack = function ()
				-- t:PlayAnimationByName("lweaponattack");
				t:DoNormalAttack()
			end,
			
			onentermgattack = function ()
				t:PlayAnimationByName("releaseskill");
			end,
			
			onenterbeattack = function ()
				t:PlayAnimationByName("blow",0,nil,0);
			end,
			
			onenterdodge = function ()
				t:PlayAnimationByName("dodge")
			end,
			
			onenterparry = function ()
				t:PlayAnimationByName("parry")
			end,
			
			onenterbadstate = function ()
				t:PlayAnimationByName("badstate")
			end,			
			
		},
	}
	t.fsm:setupState(tMachine)
end

--亡灵族(哥布林)状态机
function addUnDeadStateMachine(t)
	local tMachine = {  
		initial = "normal",  
		events = {
			--[[站立]]{name = "normal", from = {"badstate","move", "dash","attack", "mgattack","beattack", "dodge", "parry"}, to = "normal"},
			--[[移动]]{name = "move",   from = {"badstate","normal","dash","run"}, to = "move"},
			--[[冲击]]{name = "dash",   from = {"badstate","normal"}, to = "dash"},
			--[[冲击]]{name = "run",   from = {"badstate","normal","move"}, to = "run"},
			--[[物伤]]{name = "attack", from = {"badstate","normal", "move","dash","beattack"}, to = "attack"},
			--[[法伤]]{name = "mgattack", from = {"badstate","normal", "move","dash"}, to = "mgattack"},
			--[[被击]]{name = "beattack", from = {"badstate","normal", "move","dash","attack"}, to = "beattack"},
			--[[闪避]]{name = "dodge",  from = {"badstate","normal", "beattack"}, to = "dodge"},
			--[[格挡]]{name = "parry",  from = {"badstate","normal", "beattack"}, to = "parry"},
			--[[眩晕]]{name = "badstate",  from = {"normal"}, to = "badstate"},
		},  
  
		callbacks = {  
			onenternormal = function ()  
				t:PlayAnimationByName("standby");
			end,  
			
			onentermove = function ()  
				-- t:PlayAnimationByName("move",nil,nil,1);
			end,  
			
  			onenterdash = function ()  
				t:PlayAnimationByName("dash",nil,nil,1);
			end,  
			
  			onenterrun = function ()  
				-- t:PlayAnimationByName("run",nil,nil,1);
			end,  			
			
			onenterattack = function ()
				t:DoNormalAttack()
			end,
			
			onentermgattack = function ()
				t:PlayAnimationByName("releaseskill");
			end,
			
			onenterbeattack = function ()
				t:PlayAnimationByName("blow",0,nil,0);
			end,
			
			onenterdodge = function ()
				t:PlayAnimationByName("dodge")
			end,
			
			onenterparry = function ()
				t:PlayAnimationByName("parry")
			end,
			
			onenterbadstate = function ()
				-- cclog("***亡灵族(哥布林)状态机 badstate 错误---");
				t:PlayAnimationByName("badstate")
			end,			
			
		},
	}
	t.fsm:setupState(tMachine)
end

--老鼠族状态机
function addMouseStateMachine(t)
	local tMachine = {  
		initial = "normal",  
		events = {
			--[[站立]]{name = "normal", from = {"badstate","move", "dash","attack", "mgattack","beattack", "dodge", "parry"}, to = "normal"},
			--[[移动]]{name = "move",   from = {"badstate","normal","dash","run"}, to = "move"},
			--[[冲击]]{name = "dash",   from = {"badstate","normal"}, to = "dash"},
			--[[冲击]]{name = "run",   from = {"badstate","normal","move"}, to = "run"},
			--[[物伤]]{name = "attack", from = {"badstate","normal", "move","dash","beattack"}, to = "attack"},
			--[[法伤]]{name = "mgattack", from = {"badstate","normal", "move","dash"}, to = "mgattack"},
			--[[被击]]{name = "beattack", from = {"badstate","normal", "move","dash","attack"}, to = "beattack"},
			--[[闪避]]{name = "dodge",  from = {"badstate","normal", "beattack"}, to = "dodge"},
			--[[格挡]]{name = "parry",  from = {"badstate","normal", "beattack"}, to = "parry"},
			--[[眩晕]]{name = "badstate",  from = {"normal"}, to = "badstate"},
		},  
  
		callbacks = {  
			onenternormal = function ()  
				t:PlayAnimationByName("standby");
			end,  
			
			onentermove = function ()  
				-- t:PlayAnimationByName("move",nil,nil,1);
			end,  
			
  			onenterdash = function ()  
				t:PlayAnimationByName("dash",nil,nil,1);
			end,  
			
  			onenterrun = function ()  
				t:PlayAnimationByName("run",nil,nil,1);
			end,  			
			
			onenterattack = function ()
				t:PlayAnimationByName("beastattack");
			end,
			
			onentermgattack = function ()
				t:PlayAnimationByName("releaseskill");
			end,
			
			onenterbeattack = function ()
				t:PlayAnimationByName("blow",0,nil,0);
			end,
			
			onenterdodge = function ()
				t:PlayAnimationByName("dodge")
			end,
			
			onenterparry = function ()
				t:PlayAnimationByName("parry")
			end,
			
			onenterbadstate = function ()
				-- cclog("***老鼠状态机 badstate 错误---");
				t:PlayAnimationByName("badstate")
			end,
			
		},
	}
	t.fsm:setupState(tMachine)
end

--蜘蛛族状态机
function addSpiderStateMachine(t)
	local tMachine = {  
		initial = "normal",  
		events = {
			--[[站立]]{name = "normal", from = {"badstate","move", "dash","attack", "mgattack","beattack", "dodge", "parry"}, to = "normal"},
			--[[移动]]{name = "move",   from = {"badstate","normal","dash","run"}, to = "move"},
			--[[冲击]]{name = "dash",   from = {"badstate","normal"}, to = "dash"},
			--[[冲击]]{name = "run",   from = {"badstate","normal","move"}, to = "run"},
			--[[物伤]]{name = "attack", from = {"badstate","normal", "move","dash","beattack"}, to = "attack"},
			--[[法伤]]{name = "mgattack", from = {"badstate","normal", "move","dash"}, to = "mgattack"},
			--[[被击]]{name = "beattack", from = {"badstate","normal", "move","dash","attack"}, to = "beattack"},
			--[[闪避]]{name = "dodge",  from = {"badstate","normal", "beattack"}, to = "dodge"},
			--[[格挡]]{name = "parry",  from = {"badstate","normal", "beattack"}, to = "parry"},
			--[[眩晕]]{name = "badstate",  from = {"normal"}, to = "badstate"},
		},  
  
		callbacks = {  
			onenternormal = function ()  
				t:PlayAnimationByName("standby");
			end,  
			
			onentermove = function ()  
				-- t:PlayAnimationByName("move",nil,nil,1);
			end,  
			
  			onenterdash = function ()  
				t:PlayAnimationByName("dash",nil,nil,1);
			end,  
			
  			onenterrun = function ()  
				-- t:PlayAnimationByName("run",nil,nil,1);
			end,  			
			
			onenterattack = function ()
				t:DoNormalAttack()
			end,
			
			onentermgattack = function ()
				t:PlayAnimationByName("releaseskill");
			end,
			
			onenterbeattack = function ()
				t:PlayAnimationByName("blow",0,nil,0);
			end,
			
			onenterdodge = function ()
				t:PlayAnimationByName("dodge")
			end,
			
			onenterparry = function ()
				t:PlayAnimationByName("parry")
			end,
			
			onenterbadstate = function ()
				cclog("***蜘蛛族状态机 badstate 错误---");
				t:PlayAnimationByName("badstate")
			end,			
			
		},
	}
	t.fsm:setupState(tMachine)
end

--牛人族状态机(外包)
function addTaurenStateMachine(t)
	local tMachine = {  
		initial = "normal",  
		events = {
			--[[站立]]{name = "normal", from = {"badstate","move", "dash","attack", "mgattack","beattack", "dodge", "parry"}, to = "normal"},
			--[[移动]]{name = "move",   from = {"badstate","normal","dash","run"}, to = "move"},
			--[[冲击]]{name = "dash",   from = {"badstate","normal"}, to = "dash"},
			--[[冲击]]{name = "run",   from = {"badstate","normal","move"}, to = "run"},
			--[[物伤]]{name = "attack", from = {"badstate","normal", "move","dash","beattack"}, to = "attack"},
			--[[法伤]]{name = "mgattack", from = {"badstate","normal", "move","dash"}, to = "mgattack"},
			--[[被击]]{name = "beattack", from = {"badstate","normal", "move","dash","attack"}, to = "beattack"},
			--[[闪避]]{name = "dodge",  from = {"badstate","normal", "beattack"}, to = "dodge"},
			--[[格挡]]{name = "parry",  from = {"badstate","normal", "beattack"}, to = "parry"},
			--[[眩晕]]{name = "badstate",  from = {"normal"}, to = "badstate"},
		},  
  
		callbacks = {  
			onenternormal = function ()  
				t:PlayAnimationByName("standby", nil, nil, 1);
			end,  
			
			onentermove = function ()  
				-- t:PlayAnimationByName("move",nil,nil,1);
			end,  
			
  			onenterdash = function ()  
				t:PlayAnimationByName("dash",nil,nil,1);
			end,  
			
  			onenterrun = function ()  
				-- t:PlayAnimationByName("run",nil,nil,1);
			end,  			
			
			onenterattack = function ()
				t:PlayAnimationByName("attack",nil,nil,0);
			end,
			
			onentermgattack = function ()
				t:PlayAnimationByName("releaseskill",0,nil,0);
			end,
			
			onenterbeattack = function ()
				t:PlayAnimationByName("blow",0,nil,0);
			end,
			
			onenterdodge = function ()
				t:PlayAnimationByName("dodge",0,nil,0);
			end,
			
			onenterparry = function ()
				t:PlayAnimationByName("parry",0,nil,0);
			end,
			
			onenterbadstate = function ()
				-- cclog("***外包种族状态机错误---");
				t:PlayAnimationByName("badstate")
			end,			
			
		},
	}
	t.fsm:setupState(tMachine)
end

--邪神
function addDaalStateMachine(t)
	local tMachine = {  
		initial = "normal",  
		events = {
			--[[站立]]{name = "normal", from = {"badstate","move", "dash","attack", "mgattack","beattack", "dodge", "parry"}, to = "normal"},
			--[[移动]]{name = "move",   from = {"badstate","normal","dash","run"}, to = "move"},
			--[[冲击]]{name = "dash",   from = {"badstate","normal"}, to = "dash"},
			--[[冲击]]{name = "run",   from = {"badstate","normal","move"}, to = "run"},
			--[[物伤]]{name = "attack", from = {"badstate","normal", "move","dash","beattack"}, to = "attack"},
			--[[法伤]]{name = "mgattack", from = {"badstate","normal", "move","dash"}, to = "mgattack"},
			--[[被击]]{name = "beattack", from = {"badstate","normal", "move","dash","attack"}, to = "beattack"},
			--[[闪避]]{name = "dodge",  from = {"badstate","normal", "beattack"}, to = "dodge"},
			--[[格挡]]{name = "parry",  from = {"badstate","normal", "beattack"}, to = "parry"},
			--[[眩晕]]{name = "badstate",  from = {"normal"}, to = "badstate"},
		},  
  
		callbacks = {  
			onenternormal = function ()  
				t:PlayAnimationByName("standby", nil, nil, 1);
			end,  
			
			onentermove = function ()  
				-- t:PlayAnimationByName("move",nil,nil,1);
			end,  
			
  			onenterdash = function ()  
				t:PlayAnimationByName("dash",nil,nil,1);
			end,  
			
  			onenterrun = function ()  
				-- t:PlayAnimationByName("run",nil,nil,1);
			end,  			
			
			onenterattack = function ()
				t:PlayAnimationByName("attack",nil,nil,0);
			end,
			
			onentermgattack = function ()
				t:PlayAnimationByName("releaseskill",0,nil,0);
			end,
			
			onenterbeattack = function ()
				t:PlayAnimationByName("blow",0,nil,0);
			end,
			
			onenterdodge = function ()
				t:PlayAnimationByName("dodge",0,nil,0);
			end,
			
			onenterparry = function ()
				t:PlayAnimationByName("parry",0,nil,0);
			end,
			
			onenterbadstate = function ()
				-- cclog("***外包种族状态机错误---");
				t:PlayAnimationByName("badstate")
			end,			
			
		},
	}
	t.fsm:setupState(tMachine)
end

--邪神
function addWingSirenStateMachine(t)
	local tMachine = {  
		initial = "normal",  
		events = {
			--[[站立]]{name = "normal", from = {"badstate","move", "dash","attack", "mgattack","beattack", "dodge", "parry"}, to = "normal"},
			--[[移动]]{name = "move",   from = {"badstate","normal","dash","run"}, to = "move"},
			--[[冲击]]{name = "dash",   from = {"badstate","normal"}, to = "dash"},
			--[[冲击]]{name = "run",   from = {"badstate","normal","move"}, to = "run"},
			--[[物伤]]{name = "attack", from = {"badstate","normal", "move","dash","beattack"}, to = "attack"},
			--[[法伤]]{name = "mgattack", from = {"badstate","normal", "move","dash"}, to = "mgattack"},
			--[[被击]]{name = "beattack", from = {"badstate","normal", "move","dash","attack"}, to = "beattack"},
			--[[闪避]]{name = "dodge",  from = {"badstate","normal", "beattack"}, to = "dodge"},
			--[[格挡]]{name = "parry",  from = {"badstate","normal", "beattack"}, to = "parry"},
			--[[眩晕]]{name = "badstate",  from = {"normal"}, to = "badstate"},
		},  
  
		callbacks = {  
			onenternormal = function ()  
				t:PlayAnimationByName("standby", nil, nil, 1);
			end,  
			
			onentermove = function ()  
				-- t:PlayAnimationByName("move",nil,nil,1);
			end,  
			
  			onenterdash = function ()  
				t:PlayAnimationByName("dash",nil,nil,1);
			end,  
			
  			onenterrun = function ()  
				-- t:PlayAnimationByName("run",nil,nil,1);
			end,  			
			
			onenterattack = function ()
				t:PlayAnimationByName("lhweaponattack",nil,nil,0);
			end,
			
			onentermgattack = function ()
				t:PlayAnimationByName("releaseskill",0,nil,0);
			end,
			
			onenterbeattack = function ()
				t:PlayAnimationByName("blow",0,nil,0);
			end,
			
			onenterdodge = function ()
				t:PlayAnimationByName("dodge",0,nil,0);
			end,
			
			onenterparry = function ()
				t:PlayAnimationByName("parry",0,nil,0);
			end,
			
			onenterbadstate = function ()
				-- cclog("***外包种族状态机错误---");
				t:PlayAnimationByName("badstate")
			end,			
			
		},
	}
	t.fsm:setupState(tMachine)
end
