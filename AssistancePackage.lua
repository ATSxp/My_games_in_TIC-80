-- title:  Assistance Package
-- author: @ATS_xp
-- desc:   System with the purpose of manipulating game entities
-- script: lua

t = 0

ents = {} -- Table for entities
--																																	|
-- This is where the magic happens v
-- Add to table
function ents:add(obj)
	setmetatable(self,{__index = obj})
end

-- Create entity
function ents:new()
	local e = {} -- Table
	
	e.id = e.id or "entity" -- Id
	e.spr = e.spr or 0 -- Sprite
	e.x = e.x or 0 -- X-axis
	e.y = e.y or 0 -- Y-axis
	e.w = e.w or 8 -- Width
	e.h = e.h or 8 -- Height
	e.c = 0 -- Chroma key
	e.f = 0 -- Flip
	e.vx = 0 -- Speed X-axis
	e.vy = 0 -- Speed Y-axis
 
	function e:draw()end -- Methods
	function e:upd()end -- Methods
	function e:Coll(type) -- Methods
	local type = type or "top-down"

	if type == "top-down" then
		
		-- Left/Right/Up/Down
		if fget(mget((self.x+self.vx)//8,(self.y+self.vy)//8),0)or 
		fget(mget((self.x+(self.w-1)+self.vx)//8,(self.y+self.vy)//8),0)or 
		fget(mget((self.x+self.vx)//8,(self.y+(self.h-1)+self.vy)//8),0)or 
		fget(mget((self.x+(self.w-1)+self.vx)//8,(self.y+(self.h-1)+self.vy)//8),0)then
			self.vx,self.vy = 0,0
		end
	
	elseif type == "side-scroll" then
		
		-- Left/Right
		if fget(mget((self.x+self.vx)//8,(self.y+self.vy)//8),0)or 
		fget(mget((self.x+(self.w-1)+self.vx)//8,(self.y+self.vy)//8),0)or 
		fget(mget((self.x+self.vx)//8,(self.y+(self.h-1)+self.vy)//8),0)or 
		fget(mget((self.x+(self.w-1)+self.vx)//8,(self.y+(self.h-1)+self.vy)//8),0)then
			self.vx = 0
		end
		
		-- Down
		if fget(mget((self.x)//8,(self.y+(self.h)+self.vy)//8),0)or 
		fget(mget((self.x+self.w-1)//8,(self.y+(self.h)+self.vy)//8),0)then
			self.vy = 0
		else
			self.vy = self.vy + 0.2 -- gravity
		end
		
		-- Up
		if self.vy<0 and (fget(mget((self.x+self.vx)//8,(self.y+self.vy)//8),0)or 
		fget(mget((self.x+(self.w-1)+self.vx)//8,(self.y+self.vy)//8),0))then
			self.vy = 0
		end
		
	end
end
	
	self.add(e) -- Added entity
	return e
end
-- This is where the magic happens ^
--																																	|

function Player()
	local p = ents:new() -- Created entity
	p.id = "player" -- Id
	p.spr = 1 -- Sprite
	p.x = 120 -- X-axis
	p.y = 68 -- Y-axis
	
	function p:draw() -- Draw Player
		spr(self.spr, self.x, self.y, self.c, 1, self.f)
	end
	
	function p:upd() -- Update Player
		if btn(0) and self.y>0 then -- Up
			self.vy = -1
		elseif btn(1) and self.y + self.h <136 then -- Down
			self.vy = 1
		else
			self.vy = 0
		end
		if btn(2) and self.x>0 then -- Left
			self.vx = -1
		elseif btn(3) and self.x + self.w <240 then -- Right
			self.vx = 1
		else
			self.vx = 0
		end
		
		self:Coll("top-down")
		
		self.x = self.x + self.vx
		self.y = self.y + self.vy
	end
	
	return p
end

-- Return the Player
p = Player()

function Enemy()
	local e = ents:new()
	e.id = "enemy" -- Id
	e.spr = 2 -- Sprite
	e.x = math.random(0,240-8) -- X-axis
	e.y = math.random(0,136-8) -- Y-axis
	e.vx = math.random(-1,1) -- Speed X-axis
	e.vy = math.random(-1,1) -- Speed Y-axis
	
	function e:draw() -- Draw Enemy
		spr(self.spr,self.x,self.y,self.c,1)
	end
	
	function e:upd() -- Update Enemy
		if self.y<0 then
			self.vy = - self.vy
		elseif self.y + self.h>136 then
		 self.vy = - self.vy
		end
		if self.x<0 then
			self.vx = - self.vx
		elseif self.x + self.w>240 then
		 self.vx = - self.vx
		end
		
		if self.vx == 0 then
			self.vx = math.random(-1,1)
		elseif self.vy == 0 then
		 self.vy = math.random(-1,1)
		end
		
		self.x = self.x + self.vx
		self.y = self.y + self.vy
	end
	
	return e
end

-- Spawn the Enemy
table.insert(ents, Enemy())
table.insert(ents, Enemy())
table.insert(ents, Enemy())
table.insert(ents, Enemy())
table.insert(ents, Enemy())
table.insert(ents, Enemy())

function TIC()
	cls()
	map()
	 
	p:draw()
	p:upd()
	 
	for _,v in ipairs(ents)do
	 if v.id == "enemy" then
	  v:draw()
	  v:upd()
	 end
	end
	
	t = t + 1
end
