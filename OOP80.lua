Object = {
	add = function(self,table)
		self.Mytable = table or {}
		setmetatable(self.Mytable,{__index = self})
		return self.Mytable
	end,
	new = function(self,x,y,w,h,spr,name)
		self.x = x or 0
		self.y = y or 0
		self.w = w or 8
		self.h = h or 8
		self.spr = spr or 0
		self.name = self.name or ""
		self.c = 0
		
		table.insert(self.Mytable,self)
	end,
	update = function(self)
	end,
	draw = function(self,camX,camY)
		local camX,camY = camX or 0,camY or 0
		spr(self.spr,self.x - camX,self.y - camY,self.c,1)
	end
}
