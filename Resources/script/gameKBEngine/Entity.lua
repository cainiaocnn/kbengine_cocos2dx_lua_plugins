-- KBE 实体部分

function Entity()

	local t = class("Entity");
	local p = t;

	p.id = 0;
	p.className = "";
	p.position = {0, 0, 0};
	p.direction = {0, 0, 0};
	p.velocity = 0;
	p.isOnGound = true;
	p.renderObj = nil;
	p.baseMailbox = nil;
	p.cellMailbox = nil;
	p.inWorld = false;

	function p:__init__()
		-- // entityDef属性，服务端同步过来后存储在这里
		-- private Dictionary<string, Property> defpropertys_ = new Dictionary<string, Property>();
		-- private Dictionary<UInt16, Property> iddefpropertys_ = new Dictionary<UInt16, Property>();
	end

	function p:setClassName(className)
		p.className = className;
	end

	function p:setBaseMailbox(baseMailbox)
		p.baseMailbox = baseMailbox;
	end
	
	function p:setCellMailbox(baseMailbox)
		p.cellMailbox = baseMailbox;
	end
	
	function p:clear()

	end

	function p:onDestroy()
	
	end
	
	function p:isPlayer()
		-- return id == KBEngineApp.app.entity_id;
	end
		
	function p:addDefinedPropterty(name, v)
		--[[
		Property newp = new Property();
		newp.name = name;
		newp.properUtype = 0;
		newp.val = v;
		newp.setmethod = null;
		defpropertys_.Add(name, newp);
		--]]
	end
		
	function p:getDefinedPropterty(name)
		--[[
		Property obj = null;
		if(!defpropertys_.TryGetValue(name, out obj))
		{
			return null;
		}

		return defpropertys_[name].val;
		--]]
	end

	function p:setDefinedPropterty(name, val)
		-- defpropertys_[name].val = val;
	end

	function p:getDefinedProptertyByUType(utype)
		--[[
		Property obj = null;
		if(!iddefpropertys_.TryGetValue(utype, out obj))
		{
			return null;
		}
		return iddefpropertys_[utype].val;
		-]]
	end
		
	function p:setDefinedProptertyByUType(utype, val)
		-- iddefpropertys_[utype].val = val;
	end
		


	function p:baseCall(methodname, arguments)
		
		--[[
		if(KBEngineApp.app.currserver == "loginapp" then
			Dbg.ERROR_MSG(className + "::baseCall(" + methodname + "), currserver=!" + KBEngineApp.app.currserver);  
			return;
		end
		--]]
		
		
		local base_methods = EntityDef.moduledefs[p.className].base_methods;
		local tMethod = base_methods[tostring(methodname)];
		if tMethod==nil then
			Elog(tostring(p.className).."::baseCall("..tostring(methodname).."), not found method!");  
			return;
		end
		
		local methodID = tMethod.methodUtype;
		if #arguments ~= #(tMethod.args) then
			Elog(tostring(p.className)..":baseCall__参数个数不匹配");
			return;
		end
		
		
		p.baseMailbox:newMail();
		p.baseMailbox:pushBuffer("UINT16", methodID);
		
		--
		for i=1, #tMethod.args do
			-- if(method.args[i].isSameType(arguments[i]))
				-- method.args[i].addToStream(baseMailbox.bundle, arguments[i]);
				p.baseMailbox:pushBuffer(tMethod.args[i].valname, arguments[i]);
			-- end
		end
		--]]
		p.baseMailbox:postMail();
	end
		
	function p:cellCall( methodname,  arguments)
		--[[
			if(KBEngineApp.app.currserver == "loginapp")
			{
				Dbg.ERROR_MSG(className + "::cellCall(" + methodname + "), currserver=!" + KBEngineApp.app.currserver);  
				return;
			}
			
			Method method = null;
			if(!EntityDef.moduledefs[className].cell_methods.TryGetValue(methodname, out method))
			{
				Dbg.ERROR_MSG(className + "::cellCall(" + methodname + "), not found method!");  
				return;
			}
			
			UInt16 methodID = method.methodUtype;
			
			if(arguments.Length != method.args.Count)
			{
				Dbg.ERROR_MSG(className + "::cellCall(" + methodname + "): args(" + (arguments.Length) + "!= " + method.args.Count + ") size is error!");  
				return;
			}
			
			if(cellMailbox == null)
			{
				Dbg.ERROR_MSG(className + "::cellCall(" + methodname + "): no cell!");  
				return;
			}
			
			cellMailbox.newMail();
			cellMailbox.bundle.writeUint16(methodID);
				
			try
			{
				for(var i=0; i<method.args.Count; i++)
				{
					if(method.args[i].isSameType(arguments[i]))
					{
						method.args[i].addToStream(cellMailbox.bundle, arguments[i]);
					}
					else
					{
						throw new Exception("arg" + i + ": " + method.args[i].ToString());
					}
				}
			}
			catch(Exception e)
			{
				Dbg.ERROR_MSG(className + "::cellCall(" + methodname + "): args is error(" + e.Message + ")!");  
				cellMailbox.bundle = null;
				return;
			}

			cellMailbox.postMail(null);
		--]]
	end

	function p:enterWorld()
		--[[
			// Dbg.DEBUG_MSG(className + "::enterWorld(" + getDefinedPropterty("uid") + "): " + id); 
			inWorld = true;
			
			try{
				onEnterWorld();
			}
			catch (Exception e)
			{
				Dbg.ERROR_MSG(className + "::onEnterWorld: error=" + e.ToString());
			}

			Event.fireOut("onEnterWorld", new object[]{this});
		--]]
	end
		
	function p:onEnterWorld()

	end

	function p:leaveWorld()
		--[[
			// Dbg.DEBUG_MSG(className + "::leaveWorld: " + id); 
			inWorld = false;
			
			try{
				onLeaveWorld();
			}
			catch (Exception e)
			{
				Dbg.ERROR_MSG(className + "::onLeaveWorld: error=" + e.ToString());
			}

			Event.fireOut("onLeaveWorld", new object[]{this});
		--]]
	end
		
	function p:onLeaveWorld()
	end

	function p:enterSpace()
		--[[
			// Dbg.DEBUG_MSG(className + "::enterSpace(" + getDefinedPropterty("uid") + "): " + id); 
			inWorld = true;
			
			try{
				onEnterSpace();
			}
			catch (Exception e)
			{
				Dbg.ERROR_MSG(className + "::onEnterSpace: error=" + e.ToString());
			}
			
			Event.fireOut("onEnterSpace", new object[]{this});
		--]]
	end
		
	function p:onEnterSpace()
	end
		
	function p:leaveSpace()
		--[[
			// Dbg.DEBUG_MSG(className + "::leaveSpace: " + id); 
			inWorld = false;
			
			try{
				onLeaveSpace();
			}
			catch (Exception e)
			{
				Dbg.ERROR_MSG(className + "::onLeaveSpace: error=" + e.ToString());
			}
			
			Event.fireOut("onLeaveSpace", new object[]{this});
		--]]
	end

	function p:onLeaveSpace()
	end
		
	function p:set_position(old)
		--[[{
			Vector3 v = (Vector3)getDefinedPropterty("position");
			position = v;
			//Dbg.DEBUG_MSG(className + "::set_position: " + old + " => " + v); 
			
			if(isPlayer())
				KBEngineApp.app.entityServerPos(position);
			
			Event.fireOut("set_position", new object[]{this});
		}--]]
	end

	function p:onUpdateVolatileData()
	end
		
	function p:set_direction(old)
		--[[{
			Vector3 v = (Vector3)getDefinedPropterty("direction");
			
			v.x = v.x * 360 / ((float)System.Math.PI * 2);
			v.y = v.y * 360 / ((float)System.Math.PI * 2);
			v.z = v.z * 360 / ((float)System.Math.PI * 2);
			
			direction = v;
			
			//Dbg.DEBUG_MSG(className + "::set_direction: " + old + " => " + v); 
			Event.fireOut("set_direction", new object[]{this});
		}--]]
	end
	
	return p;
end
