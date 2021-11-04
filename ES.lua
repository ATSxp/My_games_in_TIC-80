-- Table for entities
ents = {
	
	new = function(self) -- Create entity
		local o = {} -- Objects/Entities 
		
		o.type = o.type or "undefined"
		o.id = o.id or "entity" -- Id
		o.spr = o.spr or 0 -- Sprite
		o.x = o.x or 0 -- X-axis
		o.y = o.y or 0 -- Y-axis
		o.w = o.w or 8 -- Width
		o.h = o.h or 8 -- Height
		o.c = 0 -- Chroma key
		o.f = 0 -- Flip
		o.vx = 0 -- Speed X-axis
		o.vy = 0 -- Speed Y-axis
		o.sx = 1 -- Sprite scale X
		o.sy = 1 -- Sprite scale Y
	 
		function o:draw() -- Methods
			spr(self.spr,self.x,self.y,self.c,1,self.f,0,self.sx,self.sy)
		end
		function o:Coll(type) -- Methods
		local type = type or "top-down"
	
		if type == "top-down" then
			
			-- Left/Right/Up/Down
			if 
			fget(mget((self.x+self.vx)//8,(self.y+self.vy)//8),0)or 
			fget(mget((self.x+(self.w-1)+self.vx)//8,(self.y+self.vy)//8),0)or 
			fget(mget((self.x+self.vx)//8,(self.y+(self.h-1)+self.vy)//8),0)or 
			fget(mget((self.x+(self.w-1)+self.vx)//8,(self.y+(self.h-1)+self.vy)//8),0)then
				self.vx,self.vy = 0,0
			end
		
		elseif type == "side-scroll" then
			
			-- Left/Right
			if 
			fget(mget((self.x+self.vx)//8,(self.y+self.vy)//8),0)or 
			fget(mget((self.x+(self.w-1)+self.vx)//8,(self.y+self.vy)//8),0)or 
			fget(mget((self.x+self.vx)//8,(self.y+(self.h-1)+self.vy)//8),0)or 
			fget(mget((self.x+(self.w-1)+self.vx)//8,(self.y+(self.h-1)+self.vy)//8),0)then
				self.vx = 0
			end
			
			-- Down
			if 
			fget(mget((self.x)//8,(self.y+(self.h)+self.vy)//8),0)or 
			fget(mget((self.x+self.w-1)//8,(self.y+(self.h)+self.vy)//8),0)then
				self.vy = 0
			else
				self.vy = self.vy + 0.2 -- gravity
			end
			
			-- Up
			if 
			self.vy<0 and 
			(fget(mget((self.x+self.vx)//8,(self.y+self.vy)//8),0)or 
			fget(mget((self.x+(self.w-1)+self.vx)//8,(self.y+self.vy)//8),0))then
				self.vy = 0
			end
			
		end
	end
		
		setmetatable(self,{__index = o}) -- Added entity
		return o
	end
	
}
