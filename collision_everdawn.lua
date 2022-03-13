-- title:  game title
-- author: game developer
-- desc:   short description
-- script: lua

t=0
function sign(n) return n>0 and 1 or n<0 and -1 or 0 end

function Vector(x,y)
	local s = {}
	s.x,s.y = x or 0,y or 0
	
	s.add=function(other)
		return Vector(s.x+other.x,s.y+other.y)
	end;
	
	s.minus=function(other)
		return Vector(s.x-other.x,s.y-other.y)
	end;
	
	s.times=function(other)
		return Vector(s.x*other.x,s.y*other.y)
	end;
	
	s.mult=function(n)
		return Vector(s.x*n,s.y*n)
	end;
	
	s.dot=function(other)
		return s.x*other.x+s.y*other.y 
	end;
	
	s.length=function()
		return math.sqrt(s.dot(s))
	end;
	
	s.tile=function()
		return mget(s.x//8,s.y//8)
	end
	
	s.draw=function(c)
		pix(s.x,s.y,c)
	end
	
	s.mod=function(n)
		return Vector(s.x % n, s.y % n)
	end; 
	
	s.copy=function()
		return Vector(s.x,s.y)
	end 
	return s
end

function Box(center,size)
	local this={} 
	this.center=center 
	this.size=size
	
	this.tl=function()
		return this.center.minus(this.size.mult(0.5))
	end
	
	this.tr=function()
		return this.center.add(this.size.times(Vector(0.5,- 0.5)))
	end
	
	this.br=function()
		return this.center.add(this.size.mult(0.5))
	end
	
	this.bl=function()
		return this.tl().add(Vector(0,this.size.y))
	end
	
	this.draw=function(c)
		rectb(this.tl().x,this.tl().y,this.size.x,this.size.y,c)
	end
	
	this.tiles=function()
		return {this.tl().tile(),this.tr().tile(),this.br().tile(),this.bl().tile()}
	end
	
	this.hits=function(other)
		return this.tl().x < other.br().x and this.br().x > other.tl().x and this.tl().y < other.br().y and this.br().y > other.tl().y 
	end
	
	this.copy=function()
		return Box(this.center.copy(), this.size.copy())
	end
	
	this.shift=function(dv)
		this.center=this.center.add(dv)
	end
	
	this.fill=function(c)
		rect(this.tl().x,this.tl().y,this.size.x,this.size.y,c)
	end 
	return this
end

function dpad(player)
	local v = Vector(0,0);
	local s=7*(player-1);
	if btn(0)then 
		v.y=v.y-1 
	end;
	if btn(1)then 
		v.y=v.y+1 
	end;
	if btn(2)then 
		v.x=v.x-1 
	end;
	if btn(3)then 
		v.x=v.x+1 
	end;
	return v 
end

function is_wall(t)return t >= 9 and t < 160 end

function has_wall(bx)
	local t = bx.tiles()
	return is_wall(t[1])or is_wall(t[2])or is_wall(t[3])or is_wall(t[4])
end

function move_entity(bx,dv)
 local trial = bx.copy();
	trial.shift(dv);
	if not has_wall(trial)then return trial end
	trial = bx.copy();
	trial.shift(Vector(0,dv.y));
	if has_wall(trial)then trial.shift(Vector(0,-dv.y))end;
	trial.shift(Vector(dv.x,0));
	if has_wall(trial)then trial.shift(Vector(-dv.x,0))end;
	return trial
end

function Camera(center,size,bounds)
	local s = Box(center,size); 
	s.bnd = bounds; 
	s.affixed = false
	
	Camera = s
	
	Camera.constructor = Camera
	
	Camera.follow=function(p)
		if s.affixed then return;end 
		if math.abs(s.center.x-p.x) > 16 then 
			s.center.x = p.x-16*sign(p.x-s.center.x)
		end
		if math.abs(s.center.y-p.y) > 10 then 
			s.center.y=p.y-10*sign(p.y-s.center.y)
		end
		s.center.x = math.max(math.min(s.center.x,s.bnd.tr().x-s.size.x*0.5),s.bnd.tl().x+s.size.x*0.5)
		s.center.y = math.max(math.min(s.center.y,s.bnd.br().y-s.size.y*0.5),s.bnd.tl().y+s.size.y*0.5)
	end
	
	Camera.set = function(p)
		if s.affixed then return end 
		s.center = p.copy(); 
		s.center.x = math.max(math.min(s.center.x,s.bnd.tr().x-s.size.x*0.5),s.bnd.tl().x+s.size.x*0.5);
		s.center.y = math.max(math.min(s.center.y,s.bnd.br().y-s.size.y*0.5),s.bnd.tl().y+s.size.y*0.5)
	end
	
	Camera.affix = function(x,y)
		s.center = Vector((x-1)*240+120,(y-1)*136+68);s.affixed=true 
	end
		
	Camera.release = function()
		s.affixed=false
	end
	
	Camera.translate = function(p)
		return p.minus(s.center).add(s.size.mult(0.5))
	end
	return s
end

function Anim(name,speed,frames,loop)
	local s = {
		speed = speed or 60,
		frame = frames[1],
		loop = loop or false,
		t = 0,
		indx = 0,
		frames = frames or {},
		name = name,
		
		update = function(self)
			if t >= self.t and #self.frames > 0 then
				if self.loop then
					self.indx = (self.indx+1)%#self.frames
					self.frame = self.frames[self.indx+1]
				else
					self.indx = self.indx < #self.frames and self.indx+1 or #self.frames
					self.frame = self.frames[self.indx]
				end
				self.t = t + self.speed
			end
		end,
		randomIndx = function(self)
			self.indx = math.random(#self.frames)
		end,
		reset = function(self)
			self.indx = 0
		end,
	}
	return s
end

function Sprite(anim)
	local s = {}
	s.states = {} 
	s.state = anim.name
	s.anchor = Vector(8, 8)
	s.c = -1
	s.f = 0
	s.r = 0
	s.s = 1
	s.w = 1
	s.h = 1

	s.set = function(name)
		s.state = name
		s.states[name]:reset()
	end
	
	s.add = function(anim)
		s.states[anim.name] = anim
	end
	s.add(anim)
	
	s.update = function()
		s.states[s.state]:update()
	end
	
	s.draw = function(p)
		local p = p.minus(s.anchor)
		spr(s.states[s.state].frame,p.x,p.y,s.c,s.s,s.f,s.r,s.w,s.h)
	end
	return s
end

function Mob(x,y,sp)
	local s = {}
	s.bnd = Box(Vector(x,y),Vector(16,16))
	s.sp = sp
	s.sp.w,s.sp.h = 2,2
	s.sp.c = 14
	s.speed = 100
	
	function s.move(dp)
		if dp.x ~= 0 then s.sp.f = dp.x > 0 and 1 or 0 end
		local speed = 0.016 * s.speed
		dp = dp.mult(speed)
		s.bnd = move_entity(s.bnd,dp)
	end
	
	function s.update()
	end
	
	function s.draw()
	end
	return s
end

function Player(x,y,sp)
	local s = Mob(x,y,sp)
	
	function s.update()
		s.sp.update()
		s.move(dpad(1))
	end
	
	function s.draw(camera)
		local screen_pos = camera.translate(s.bnd.center)
		s.sp.draw(screen_pos)
		s.bnd.draw(12)
	end
	return s
end

p = Player(120,68,Sprite(Anim("1-a",16,{1,3},true)))
p.sp.add(Anim("1-b",16,{5,7},true))

cam = Camera(Vector(32,32), Vector(240,136), Box(Vector(7*240/2,7*136/2), Vector(7*240,7*136)))
cam.set(p.bnd.center)

function TIC()
	cls()
 local offset = cam.tl();
	offset.x = offset.x - offset.x // 8 * 8
	offset.y = offset.y - offset.y // 8 * 8
	p.update()
	--cam.follow(p.bnd.center)	
	map(cam.tl().x//8,cam.tl().y//8,31,18,-offset.x,-offset.y)
	p.draw(cam)

	if btn(4)then p.sp.set("1-b")
	elseif btn(5)then p.sp.set("1-a")end
	
	print(p.sp.state,0,0,12)
	t=t+1
end
