ents = {} -- Table for entities

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
