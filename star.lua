-- title:  Star
-- author: @ATS_xp
-- desc:   Your mission is to find a star on a dangerous planet.
-- script: lua

t=0

to=table.insert
del=table.remove
ceil=math.ceil 
max=math.max
min=math.min
rand=math.random
sqrt=math.sqrt
cos=math.cos
sin=math.sin

palMenu={3,3,3,0,0,0,0,0,0,0,0}

text={
 [1]="Your oxygen cylinder won't last forever,\nso use the \"green\" machines by getting\nclose and pressing the action button to\nrefill your oxygen tank.",
 [2]="Damn it! Those parasites have infested\nthe base, use the attack button to defeat\nthem!",
 [3]="If you need to get back somewhere very\nhigh, don't hesitate to use your jet pack. \nRemembering that there is fuel, if you run\nout of fuel you will have to find a \"red\"\nmachine to refuel.",
 [4]="Welcome astronaut! Thank you for\naccepting this quest, your objective is to\nfind a star, it will be used to power the\ncities of Mars. Good luck.",
 [10]="\n\n\n\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\bYou dead",
 [11]="You found the Star! Your mission is\ncomplete.\n\n\n\n\n\n\n\t\t\t\t\t\t\t\t\t\t\t\t\tThanks for playing 'v'",
 [12]="You get a Keycard!"
}

txt={
 on=false,
 x=0,
 y=0,
 w=240,
 h=68,
 t=0,
}

dirs={ -- directions of boomerang
 {-1,0},
 {1,0},
}

function txt:textbox()
	if self.on then
	 p.move=false
		rect(self.x,self.y,self.w,self.h,0)
		rectb(self.x,self.y,self.w,self.h,3)
	 print(text[txt.t],5,self.y+6,3)
	else
		p.move=true
	end
	
	for i,v in ipairs(ents)do
		if v.id=="board"then
			if colt(p.x,p.y-8,p.w,p.h+8,240) then
			 self.t=1
			elseif colt(p.x,p.y-8,p.w,p.h+8,241)then
				self.t=2
			elseif colt(p.x,p.y-8,p.w,p.h+8,242)then
				self.t=3
			elseif colt(p.x,p.y-8,p.w,p.h+8,244)then
				self.t=4
			elseif gameOver then
			 self.t=10
			elseif win then
				self.t=11
			elseif p.keys==1 then
				self.t=12
			else
			 self.t=0
			end
		end
	end
end


function isEnemy(v)
 return v.id=="worm" or v.id=="zorb"
end

function addEnts()
 for x=0,240 do
  for y=0,136 do
   local id=mget(x,y)
   if id==224 then p.x=x*8;p.y=y*8
   elseif id==225 then
   	to(ents,ents:new("oxygen_cilinder",id,x*8,y*8,8,8,0))
   elseif id==227 then
    to(ents,ents:new("gas_cilinder",id,x*8,y*8,8,8,0))
   elseif id==226 then
    to(ents,ents:new("board",id,x*8,y*8,8,8,0))
   elseif id==228 then
    to(ents,ents:new("band_aid",id,x*8,y*8,8,8,0))
   elseif id==229 then
    to(ents,ents:new("worm",id,x*8,y*8,8,8,0,5))
   elseif id==208 then
    to(ents,ents:new("cilinder_o",id,x*8,y*8,8,8,0))
   elseif id==209 then
    to(ents,ents:new("cilinder_g",id,x*8,y*8,8,8,0))
   elseif id==230 then
    to(ents,ents:new("zorb",id,x*8,y*8,8,8,0,5))
   end
  end
 end
end

function angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end
function anim(f,s) f,s=f or {},s or 8;return f[((t//s)%#f)+1]end
function remap(id,x,y) if fget(mget(x,y),1)then id=0 end return id end
function col(x1,y1,w1,h1,x2,y2,w2,h2) return x1<x2+w2 and y1<y2+h2 and x2<x1+w1 and y2<y1+h1 end
function col2(x1,y1,w1,h1,x2,y2,w2,h2) return x1<=x2+w2 and y1<=y2+h2 and x2<=x1+w1 and y2<=y1+h1 end
function colt(x,y,w,h,t) if mget(x//8,y//8)==t or mget((x+w-1)//8,y//8)==t or mget(x//8,(y+h-1)//8)==t or mget((x+w-1)//8,(y+h-1)//8)==t then return true end end

function game_over()
 if gameOver then
		timeShowText=timeShowText-1
	end
	local w=print("Press B to reset",0,-6,3)
	if timeShowText<0 then
	 music()
		sfx(5,"B-1",30)
		print("Press B to reset",(240-w)//2,88,2)
	 if btnp(5)then
			init()
		end
	end
end

boom_dir=2
function weapon()
	boom={}
	boom_t=t
	boom.x=p.x+4
	boom.y=p.y
	boom.vx=dirs[boom_dir][1]*3
	boom.vy=0
end

function weaponUpd()
	if boom then
	 spr(263,boom.x-mx,boom.y-my,0,1,0,(t/4)%8)
		if t-boom_t<30 then
		 if (t/2)%8==0 then
				parts:new(boom.x,boom.y+2,1,10)
			end
			if fget(mget((boom.x+boom.vx)//8,(boom.y+boom.vy)//8),0)or fget(mget((boom.x+7+boom.vx)//8,(boom.y+boom.vy)//8),0)or fget(mget((boom.x+boom.vx)//8,(boom.y+7+boom.vy)//8),0)or fget(mget((boom.x+7+boom.vx)//8,(boom.y+7+boom.vy)//8),0)then		
				sfx(6,"C-7",5,0,5)
				parts:new(boom.x,boom.y,1,3)
				boom_t=t-40
			end
		end
		
		boom.x=boom.x+boom.vx
		boom.y=boom.y+boom.vy
		if t-boom_t>30 then
		 local a=angle(boom.x,boom.y,p.x,p.y)
			boom.vx=cos(a)*3
			boom.vy=sin(a)*3
			if col2(boom.x,boom.y,8,8,p.x,p.y,p.w,p.h)then
				boom=nil
			end
		end
		
	end
end

function Player()
	local p=ents:new(
		"player",
		256,
		0,
		0,
		8,
		8,
		0,
		60
	)
	p.keys=0
	p.move=true
	p.extraVel=0
	p.oxy=50
	p.gas=50
	p.paletteGas={7,14,10}
	
	function p:Drw()
		spr(self.spr,self.x-mx,self.y-my,self.c,1,self.f)
	end
	
	function p:Anim()
		if self.vx>0 then self.spr=self.anim.walk self.f=0
		elseif self.vx<0 then self.spr=self.anim.walk self.f=1 
		else self.spr=self.anim.idle end
	 if self.vy~=0 then self.spr=260 end
	 if boom then if t-boom_t>0 and self.vx==0  then self.spr=261 end end
	 if gameOver then self.spr=self.anim.die end
	end
	
	function p:Effects()
		if self.vx~=0 and self.vy==0 and self.f==0 then
			if (t/2)%4==0 then
				parts:new(self.x,self.y+8,1,3,5)
			end
		elseif self.vx~=0 and self.vy==0 and self.f==1 then
			if (t/2)%4==0 then
				parts:new(self.x+8,self.y+8,1,3,5)
			end
		end
		if self.vy>3 then
		 parts:new(self.x+4,self.y-1,1,8,2)
		end
		if gameOver then
  	if (t/2)%4==0 then
   	parts:new(self.x+4,self.y,1,3,20,0,-1)
   end
		end
	end
	
	function p:Cam()
		if self.x>120 and self.x<225*8 then
			mx=self.x-120
		end
		if self.y>88 and self.y<136*8 then
		 my=self.y-88
		end
	end
	
	function p:Upd()
	 if not txt.on then
			if btn(2)then self.vx=-1-self.extraVel boom_dir=1
			elseif btn(3)then self.vx=1+self.extraVel boom_dir=2
			else self.vx=0 end
			if btnp(4)and self.vy==0 then sfx(4,"D#4",10,0,5) self.vy=-1 if self.vx>1 or self.vx<-1 then self.vy=-1.5 end end
			if btn(7)and self.gas>0 then sfx(3,"G#2",15,0,8)  self.vy=-rand(1,2)/2 self.gas=self.gas-(1/8) parts:new(self.x+(self.f>0 and 8 or 0),self.y+10,2,self.paletteGas[((t//8)%#self.paletteGas)+1]) end
			if btn(5)and self.vy==0 and self.vx~=0 then self.extraVel=0.5;self.oxy=self.oxy-(0.5/8)else self.extraVel=0 end
		 if btnp(6)then
				if not boom then weapon() sfx(1,"A-5",20)end
			end
		end
		
		if self.vx~=0 and self.vy==0 then self.oxy=self.oxy-(0.1/8) end
		if self.gas>50 then self.gas=50 end
		
		if self.oxy<=0 then
			if self.hp>0 then
				self.hp=self.hp-(1/24)
			end
		end
		
		if self.hp>60 then self.hp=60 end
		if self.hp<=0 then gameOver=true txt.on=true end
		if colt(self.x,self.y,self.w,self.h,7)or colt(self.x,self.y,self.w,self.h,23) then
			gameOver=true txt.on=true
		end
		
		self.gas=self.gas+(0.2/64)
		
		self.anim.walk=anim({258,259})
		self.anim.idle=anim({256,257},32)
		self.anim.die=anim({264,265,266,267,268,269})
		
		self:getSol()
		self:Anim()
		self:Effects()
	end
	
	return p
end

function items()
	for i,v in ipairs(ents)do
		if v.id=="cilinder_o" then
			spr(v.spr,v.x-mx,v.y-my+(sin((t/24)*2)*2)-2,v.c,1)
			
			if col(v.x,v.y,v.w,v.h,p.x,p.y,p.w,p.h)then
				sfx(2,"C#7",30)
				del(ents,i)
				p.oxy=p.oxy+20
			end
		elseif v.id=="cilinder_g"then
		 spr(v.spr,v.x-mx,v.y-my+(sin((t/24)*2)*2)-2,v.c,1)
			
			if col(v.x,v.y,v.w,v.h,p.x,p.y,p.w,p.h)then
				sfx(2,"C#7",30)
				del(ents,i)
				p.gas=p.gas+20
			end
		elseif v.id=="band_aid" then
			spr(v.spr,v.x-mx,v.y-my+(sin((t/24)*2)*2)-2,v.c,1)
			
			if col(v.x,v.y,v.w,v.h,p.x,p.y,p.w,p.h)then
				sfx(2,"C#7",30)
				del(ents,i)
				p.hp=p.hp+10
			end
		end
	end
end

function wormDrw()
	for _,v in ipairs(ents)do
		if v.id=="worm"then
			
		end
	end
end

function mobUpd()
	for i,v in ipairs(ents)do
	 if v.id=="worm" then
		 spr(v.spr,v.x-mx,v.y-my,v.c,1,v.f)
			
			if v.vx~=0 then v.spr=v.anim.walk end
			
			local dx=p.x-v.x
			local dy=p.y-v.y
			local dst=sqrt(dx^2+dy^2)
			if dst<40 then
				v.vx=dx>0 and 0.5 or -0.5
			end
			
			v.anim.walk=anim({272,273})
			if boom and col(v.x,v.y,v.w,v.h,boom.x,boom.y,8,8)then
				v.spr=274
			else
			 v.spr=229
			end
		
		elseif v.id=="zorb"then
		 spr(v.spr,v.x-mx,v.y-my,v.c,1,v.f)
			v.anim.idle=anim({230,288},16)
			v.vx=0
			
			v.spr=v.anim.idle
			if boom and col(v.x,v.y,v.w,v.h,boom.x,boom.y,8,8)then
				v.spr=289
			else
			 v.spr=v.anim.idle
			end
		end
		
		
		if isEnemy(v)then
			if col(v.x+v.vx,v.y+v.vy,v.w,v.h,p.x+p.vx,p.y+p.vy,p.w,p.h)then
				local a=angle(v.x,v.y,p.x,p.y)
				sfx(7,"F-1",10)
				parts:new(p.x,p.y,1,10)
				p.hp=p.hp-(rand(1,2)/8)
				p.vx=cos(a)*2
				p.vy=sin(a)*2
				p.spr=262
			end
			
			if boom then
				if col(v.x+v.vx,v.y+v.vy,v.w,v.h,boom.x,boom.y,8,8)then
					local a=angle(boom.x,boom.y,v.x,v.y)
					sfx(7,"F-1",10)
					parts:new(v.x,v.y,1,10)
					v.hp=v.hp-((rand(1,3))/8)
					v.vx=cos(a)*4
					v.vy=sin(a)*4
					boom_t=t-40
				end
			end
			
			ents.getSol(v)
			
			v.f=v.vx>0 and 0 or 1
			
			if v.hp<=0 then
			 del(ents,i)
				local obj=rand(1,3)
				
				if obj==1 then
					to(ents,ents:new("band_aid",228,v.x,v.y,8,8,0))
				elseif obj==2 then
				 to(ents,ents:new("cilinder_o",208,v.x,v.y,8,8,0))
				elseif obj==3 then
					to(ents,ents:new("cilinder_g",209,v.x,v.y,8,8,0))
				end
				
			end
			
		end
	end
end

function oxygen()
	for i,v in ipairs(ents)do
		if v.id=="oxygen_cilinder" then
		
			for i=0,2 do
				if (t/8)%4==0 then
					parts:new(3*i+v.x,v.y-2,1,3,30,0,-1,"rectangle")
			 end
			end
			
			if p.oxy>0 then
				p.oxy=p.oxy-(0.5/32)
			end
			if p.oxy>50 then p.oxy=50 end
			
			spr(v.spr,v.x-mx,v.y-my,v.c,1)
			
			if col(v.x,v.y,v.w,v.h,p.x,p.y,p.w,p.h)then
			 spr(510,v.x-mx,(v.y-my)+((t//16)%2)-8,0,1)
				if btnp(5)then
				 sfx(5,"F-2",15)
					p.oxy=50
				end
			end
		end
	end
end

function gas()
	for i,v in ipairs(ents)do
		if v.id=="gas_cilinder" then
			spr(v.spr,v.x-mx,v.y-my,v.c,1)
			
			for i=0,2 do
				if (t/8)%4==0 then
					parts:new(3*i+v.x,v.y-2,1,3,30,0,-1,"rectangle")
			 end
			end
			
			if col(v.x,v.y,v.w,v.h,p.x,p.y,p.w,p.h)then
				spr(510,v.x-mx,(v.y-my)+((t//16)%2)-8,0,1)
				if btnp(5)then
					sfx(5,"B-1",20)
					p.gas=50
				end
			end
		end
	end
end

function board()
	for i,v in ipairs(ents)do
		if v.id=="board" then
			spr(v.spr,v.x-mx,v.y-my,v.c,1)
			
			if col(v.x,v.y,v.w,v.h,p.x,p.y,p.w,p.h)then
				spr(510,v.x-mx,(v.y-my)+((t//16)%2)-8,0,1)
			 if btnp(5)then
					sfx(5,"B-1",20)
					txt.on=not txt.on
				end
			end
		end
	end
end

function hud()
 -- Oxygen
	rect(6,10,p.oxy,5,3)
	--rectb(8,10,50,5,2)
	spr(96,3,9,0,1)spr(98,50,9,0,1)
	for i=0,4 do spr(97,8*i+11,9,0,1)end
	spr(508,60,8,0,1)
	-- Gas
	rect(12,18,p.gas,4,3)
	--rectb(10,17,50,5,10)
	spr(112,9,16,0,1)spr(114,57,16,0,1)
	for i=0,4 do spr(113,8*i+17,16,0,1)end
	spr(509,0,17,0,1)
	
	-- Hp
	rect(3,127,p.hp,4,7)
	spr(128,0,125,0,1)spr(130,58,125,0,1)
	for i=0,6 do spr(129,8*i+8,125,0,1)end
 spr(507,67,125,0,1)
 
 if p.keys>0 then
  spr(210,210,115,0,2)
 end
end

function init()
 musicOn=false
	win=false
	gameOver=false
	txt.on=false
	timeShowText=10
	timeShowTextCard=70
	
 parts={
 	system=function(self)
  	for i,v in ipairs(self)do
   	v.mode=v.mode or "circle"
   	v.t=(v.t and v.t+1)or 0
    v.x=v.x+rand(-1,1)
    v.y=v.y+rand(-1,1)
    v.x=v.x+(v.vx or 0)
    v.y=v.y+(v.vy or 0)
    
    if v.mode=="circle" then
    	circ(v.x-mx,v.y-my,v.r or 1,v.c or 0)
    elseif v.mode=="rectangle" then
     rect(v.x-mx,v.y-my,v.w or 1,v.h or 1,v.c or 0)
    end
    
    if v.t>(v.max or 20)then del(self,i) end    
   end
  end,
  new=function(self,x,y,r,c,max,vx,vy,mode,w,h)
  	to(self,{
	   x=x or 0,
	   y=y or 0,
				r=r,
				w=w,
				h=h,
				c=c,
				vx=vx,
				vy=vy,
				max=max,
				mode=mode,
   }
   )
  end,
 }
 
	ents={
		new=function(self,id,spr,x,y,w,h,c,hp)
			local mob={
				id=id,
				spr=spr or 511,
				hp=hp or 1,
				anim={},
				x=x or 0,
				y=y or 0,
				w=w or 8,
				h=h or 8,
				c=c or 0,
				f=0,
				vx=0,
				vy=0,
			}
			
			self.__index=self
			return setmetatable(mob,self)
		end,
		getSol=function(self)
			if fget(mget((self.x+self.vx)//8,(self.y+self.vy)//8),0)or fget(mget((self.x+(self.w-1)+self.vx)//8,(self.y+self.vy)//8),0)or fget(mget((self.x+self.vx)//8,(self.y+(self.h-1)+self.vy)//8),0)or fget(mget((self.x+(self.w-1)+self.vx)//8,(self.y+(self.h-1)+self.vy)//8),0)then
				self.vx=0
			end
			
			if fget(mget((self.x)//8,(self.y+(self.h)+self.vy)//8),0)or fget(mget((self.x+(self.w-1))//8,(self.y+(self.h)+self.vy)//8),0)then
				self.vy=0
			else
			 self.vy=self.vy+0.2/6
			end
			
			if self.vy<0 and (fget(mget((self.x+self.vx)//8,(self.y+self.vy)//8),0)or fget(mget((self.x+(self.w-1)+self.vx)//8,(self.y+self.vy)//8),0))then
				self.vy=0
			end
			
			if not txt.on then
			self.x=self.x+self.vx
			self.y=self.y+self.vy
			end
		end,
	}
	
	p=Player()

	mset(6,31,210)
	for i=0,6 do
		mset(i+64,35,5)
	end
 
	mx=0
	my=0
	addEnts()
end

init()
mode="menu"

function TIC()
 if mode=="menu" then
 	cls()
  
  for i=0,29 do
  	for j=0,16 do
   	circ(8*i+5+sin((t/8)*2)*2,8*j+5+cos((t/8)*2)*2,cos((t/16)/2)*8,1)
  	end
  end
  
  circ(120,68,50+cos((t/16)/2)*8,0)
  circ(0,108,50+cos((t/16)/2)*8,0)
  circ(230,108,50+cos((t/16)/2)*8,0)
  
  local w=print("play",0,-6,3)
  local w2=print("Star",0,-12,10,false,2)
  
  print("Star",(238-w2)//2,60,9,false,2)
  print("Star",(240-w2)//2,60,10,false,2)
  
  print("play",(238-w)//2,78,1)
  print("play",(240-w)//2,78,3)
  
  print("<",((288-w)//2)+((t/16)%2),78,1)
  print("<",((290-w)//2)+((t/16)%2),78,3)
  
  if btnp(5)then
   sfx(0,"D-4",5,0)
   mode=""
  end
 else
		cls()
		
		if not musicOn then
		 if p.x>51*8 then
				music(0,0,0)
				musicOn=true
			end
		end
		
		p:Cam()
		if p.keys>0 then
		 timeShowTextCard=timeShowTextCard-1
		end
		map(mx//8,my//8,31,18,-(mx%8),-(my%8),0,1,remap)
		
		print("Jump",28*8-mx,11*8-my,3)
		print("Attack",24*8-mx-5,28*8-my,3)
		print("Action",21*8-mx-3,2*8-my,3)
		print("Fly",56*8-mx-3,28*8-my,3)
		
		gas()
		oxygen()
		board()
		weaponUpd()
		items()
		
		p:Drw()
		p:Upd()
		
		mobUpd()
		
		parts:system()	
		
		parts:new(131*8+4,7*8+6,1,2,20,0,-1)
		
		if colt(p.x,p.y,p.w,p.h,243)then
		 spr(510,p.x-mx,(p.y-my)+((t//16)%2)-8,0,1)

			if btnp(5)and p.keys==1 then
			 sfx(3,"D-4",10)
			 mset(64,35,0)
				mset(65,35,0)
				mset(66,35,0)
				mset(67,35,0)
				mset(68,35,0)
				mset(69,35,0)
				p.keys=0
			elseif btnp(5) and p.keys==0 then
			 sfx(4,"C-1",10)
			end
		end
		
		if colt(p.x,p.y,p.w,p.h,247)then
		 music()
		 win=true
			txt.on=true
		end
		if win then
		 if btnp(5)then
			 init()
			end
		end
		if colt(p.x,p.y,p.w,p.h,210)then
		 sfx(2,"C#7",30)
			mset(6,31,0)
			p.keys=1		
			txt.on=true
		end
		if timeShowTextCard<0 then
			txt.on=false
			timeShowTextCard=100000
		end
		
		hud()
		txt:textbox()
		game_over()
	end
	t=t+1
end
