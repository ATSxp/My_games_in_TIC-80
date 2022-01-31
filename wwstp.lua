-- title:  Who will save the princess?
-- author: @ATS_xp
-- desc:   Escape from the Demon King's dungeon to freedom!
-- script: lua
-- saveid: save_game
-- input: keyboard/gamepad

trace(string.upper("\ngame compiled\nand\nsuccessfully run"),6)

t = 0

_GAME = {}
_GAME.on = false
_GAME.fps = false
_GAME.state = 1

local False,True = 0,1
local exp = math.random(1,50)

keyb,but = false,true
buts = {
	{id = "up",key = 23,bid = 0},
	{id = "down",key = 19,bid = 1},
	{id = "left",key = 1,bid = 2},
	{id = "right",key = 4,bid = 3},
	{id = "a",key = 11,bid = 4},
	{id = "b",key = 12,bid = 5},
	{id = "x",key = 10,bid = 6},
	{id = "y",key = 9,bid = 7},
}

function butn(id)
	if but then
		for _,v in ipairs(buts)do
			v.fn = function(num)return btn(num)end
			if id == v.id then if v.fn(v.bid)then return true end end
		end
	elseif keyb then
		for _,v in ipairs(buts)do
			v.fn = function(num)return key(num)end
			if id == v.id then if v.fn(v.key)then return true end end
		end
	end
end

function butnp(id)
	if but then
		for _,v in ipairs(buts)do
			v.fn = function(num,hold,period)local hold,period = hold or -1,period or -1 return btnp(num,hold,period)end
			if id == v.id then if v.fn(v.bid)then return true end end end
	elseif keyb then
		for _,v in ipairs(buts)do
			v.fn = function(num,hold,period)local hold,period = hold or -1,period or -1 return keyp(num,hold,period)end
			if id == v.id then if v.fn(v.key)then return true end end
		end
	end
end

FPS={fps=0,frames=0,lastTime=-1000,x=120,y=1,color=9,w=0,h=0,layer=0}
function FPS:upd() --original by Al Rado https://tic.computer/play?cart=123
	if (time()-self.lastTime<=1000) then
		self.frames=self.frames+1
	else 
		self.fps=self.frames
		self.frames=0
		self.lastTime=time()
	end
end
function FPS:drw()
	printc("FPS: "..self.fps,self.x,self.y,self.color,false,1,false,8)
end

function set(tbl)
	local s = {}
	for i,l in ipairs(tbl)do s[l] = true end
	function s.contains(s,e)
		return s[e] == true
	end
	function s.add(s,e)
		s[e] = true
	end
	function s.rem(s,e)
		s[e] = nil
	end
	return s
end

SOLID = set{1,2,3,4,5,8,9,17,19,21,24,25,29,34,35,36,37,44,45,46,47,
60,61,62,63,72,73,74,75,76,77,78,79,92,93,94,95,108,109,
110,111,124,125,126,127,140,141,142,143}

function anim(f,s)local f,s = f or {},s or 8;return f[((t//s)%#f)+1] end
function angle(x1,y1,x2,y2)return math.atan2(y2-y1,x2-x1)end
function sol(x,y)
	for _,m in ipairs(mobs)do
		local hit = col(x,y,0,0,m.x,m.y,m.w,m.h)
		if m.collide == True and hit then return true end
	end
	return SOLID:contains(mget(x//8,y//8))
end
function sprc(id,x,y,c,s,f,r,w,h)
	local x,y,c,s,f,r,w,h = x or 0,y or 0,c or -1,s or 1,f or 0,r or 0,w or 1,h or 1
	spr(id,x-mx,y-my,c,s,f,r,w,h)
end

dirs = {
	{1,0},{0,1},{1,1},{-1,-1},{-1,0},{0,-1},{-1,1},{1,-1}
}
function printb(text,x,y,c,fix,s,sm,cb)
	local fix,s,sm,cb = fix or false,s or 1,sm or false,cb or 0
	for d=1,#dirs do
		print(text,dirs[d][1]+x,dirs[d][2]+y,cb,fix,s,sm)
	end
	print(text,x,y,c,fix,s,sm)
	return print(text,x,y,c,fix,s,sm,cb)
end
-- By: Nesbox / mod by me
function printc(s,x,y,c,f,sc,sm,cb)
    local w=print(s,0,-18,c,f or false,sc or 1,sm or false,cb or 0)
    printb(s,x-(w/2),y,c or 15,f or false,sc or 1,sm or false,cb or 0)
end
-- By Nesbox
function pal(c0,c1)
 if(c0==nil and c1==nil)then for i=0,15 do poke4(0x3FF0*2+i,i)end
 else poke4(0x3FF0*2+c0,c1) end
end

function col(x1,y1,w1,h1,x2,y2,w2,h2)return x1<x2+w2 and y1<y2+h2 and x2<x1+w1 and y2<y1+h1 end
function col2(a,b)if a ~= b and col(a.x,a.y,a.w,a.h,b.x,b.y,b.w,b.h)then return true end end
function col3(x1,y1,w1,h1,x2,y2,w2,h2)return x1+w1>=x2 and x1<=x2+w2 and y1+h1>=y2 and y1<=y2+h2 end
function colT(x,y,w,h,tile)local x,y,w,h,tile = x or 0,y or 0,w or 8,h or 8,tile or 0;if mget((x+1)//8,(y+((h/2)+1))//8) == tile or mget((x+(w-1))//8,(y+((h/2)+1))//8) == tile or mget((x+1)//8,(y+(h-1))//8) == tile or mget((x+(w-1))//8,(y+(h-1))//8) == tile then return true end end
function layer(a,b)if a.y == b.y then return b.x < a.x end return a.y < b.y end

local textOn = false
-- If you are curious to know how this 
-- Text Box system works, read my tutorial 
-- here: https://github.com/nesbox/TIC-80/wiki/How-to-make-Text-box
function addDialog(di,col,spr,name)
	dialog = di
	dialog_color = col or 0
	dialog_pos = 1
	dialog_spr = spr or 20
	dialog_name = name or nil
	text_pos = 1
end

function drawTextBox()
	rect(dix + 8,diy + 1,240 - 16,68 - 1,3)
	
	for i = 1,29 - 1 do
		spr(302,8 * i + dix,diy,11,1)
		spr(302,8 * i + dix,diy + 68 - 8,11,1,0,2)
	end
	for i = 1,(17 / 2) - 1 do
		spr(302,dix,8 * i + diy,11,1,1,1)
		spr(302,dix + 240 - 8,8 * i + diy,11,1,0,1)
	end
	for i = 1,16 do
		spr(303,16 * i + dix,diy,11,1)
		spr(303,16 * i + dix,diy + 68 - 8,11,1,0,2)
	end
	for i = 1,(17 / 2) - 5 do
		spr(303,dix,16 * i + diy,11,1,1,1)
		spr(303,dix + 240 - 8,16 * i + diy,11,1,0,1)
	end
	
	spr(301,dix,diy,11,1)
	spr(301,dix + 240 - 8,diy,11,1,1)
	spr(301,dix,diy + 68 - 8,11,1,1,2)
	spr(301,dix + 240 - 8,diy + 68 - 8,11,1,2,1)
	
	if dialog_name ~= nil then
		-- icon
		for d=1,#dirs do
			for i = 0,15 do
				pal(i,3)
				spr(dialog_spr,dirs[d][1]+(dix + 2),dirs[d][2]+diy + (diy == 68 and - 33 or (8 * 8) + 5),11,4)
			end
		end
		pal()
		spr(dialog_spr,dix + 2,diy + (diy == 68 and - 33 or (8 * 8) + 5),11,4)
		-- name 
		local w = print(dialog_name,0,- 6,0,false,1,true)
		rect(dix + 37,diy + (diy == 68 and - 12 or (8 * 8) + 4),w + 5,11,3)
		rectb(dix + 37,diy + (diy == 68 and - 12 or (8 * 8) + 4),w + 5,11,2)
		printb(dialog_name,dix + 40,diy + (diy == 68 and - 9 or (8 * 8) + 7),2,false,1,true,0)
	end
end

function updateDialog()
	if dialog ~= nil and dialog[dialog_pos] ~= nil then
		if p.y - my > 68 then diy = 10 else diy = 68 end
		local str = dialog[dialog_pos]
		local len = string.len(str)
		
		if butnp("a") and text_pos >= 2 then
			if text_pos < len then
				text_pos = len
			else
				text_pos = 1
				dialog_pos = dialog_pos + 1
			end
		end
		
		if dialog_pos <= #dialog then
			drawTextBox()
			printb(string.sub(str,1,text_pos),dix + 10,diy + 10,2,false,1,false)
			spr(anim({507,508},24),dix + 240 - 24,diy + 68 - 22,11,2)
			global_hitpause = 1
			if text_pos < len and t%4==0 then text_pos = text_pos + 1 sfx(7,"D-3",-1,1,4)end
		end
		textOn = true
	else
		dialog_pos = 1
		dialog = nil
		textOn = false
	end
end

function Interact(v)
	for _,m in ipairs(mobs)do
		local hit = col(v.x,v.y,v.w,v.h,m.x,m.y,m.w + 1,m.h)
		if m.onInteract ~= nil and hit then
			m:onInteract()
		end
	end
end

-- I learned how to make this kind 
-- of effect in the game "Antvania" 
-- created by Muhammad Fauzan 
-- please play Antvania, here: https://tic80.com/play?cart=2438
function fade(mz,x,x2,mode)
	local f = {
		x = x or 0,
		x2 = x2 or 120,
		z = mz,
		mode = mode or 1,
	}
	table.insert(rec,f)
end

function drawFade()
	for i,f in ipairs(rec)do
		f.x = f.x + f.z
		f.x2 = f.x2 - f.z
		
		
		if f.z < 0 and f.x + 128 < 0 then table.remove(rec,i)
		else global_hitpause = 1 end
		
		rect(f.x,0,120,136,0)
		rect(f.x2,0,120,136,0)
		
		for j = 0,16 do
			spr(64,f.x + 120,8 * j,11,1)
			spr(64,f.x2 - 8,8 * j,11,1,1)
		end
		
	end
end

-- Particles modes:
-- 1 - circle/fill
-- 2 - text
-- 3 - rectangle/fill
-- 4 - circle/line
-- 5 - circle/line art
function addParts(tbl)if global_hitpause == 0 then table.insert(parts,tbl) end end
function drawParts()
	for _,v in ipairs(parts)do
		if v.mode == 1 then
			circ(v.x - mx,v.y - my,v.s or 1,v.c or 0)
		elseif v.mode == 2 then
			printb(v.text or nil,v.x - mx,v.y - my,v.c or 0,v.fix or false,v.scale or 1,v.small or false)
		elseif v.mode == 3 then
			rect(v.x - mx,v.y - my,v.w or 1,v.h or 1,v.c or 0)
		elseif v.mode == 4 then
			circb(v.x - mx,v.y - my,v.s or 1,v.c or 0)
		elseif v.mode == 5 then
			circ(v.x - mx,v.y - my,v.s or 1,v.c or 0)
			circb(v.x - mx,v.y - my,v.s or 1,v.cb or 0)
		end
	end
end

function updateParts()
	for i,v in ipairs(parts)do
		v.t = (v.t and v.t + 1)or 0
		v.x = v.x + math.random(- 1,1)
		v.y = v.y + math.random(- 1,1)
		v.x = v.x + (v.vx or 0)
		v.y = v.y + (v.vy or 0)
		v.mode = v.mode or 1
		v.map = v.map or true
		
		if v.t > (v.max or 20) then table.remove(parts,i) end
	end
end

function bulletDraw()
	for _,v in ipairs(bullet)do
		local sp = 272
		if bChange then
			if p.da == True then
				sp = 277
			else
				sp = 273
			end
		else
			if p.da == True then
				sp = 276
			else
				sp = 272
			end
		end
		sprc(sp,v.x,v.y,11,1,v.f,v.r)
		if _GAME.on then rectb(v.x-mx,v.y-my,v.w,v.h,9)end
	end	
end

function bulletUpdate()
	for i,v in ipairs(bullet)do
		local x,y,w,h = v.x + v.vx,v.y + v.vy,v.w,v.h
		if sol(x,y +(h / 2 + 1))or sol(x + (w - 1),y + (h / 2 + 1))or sol(x,y + (h - 1))or sol(x + (w - 1),y + (h - 1))then
			sfx(12,"E-4")
			local Oldx,Oldy = v.x,v.y
			addParts({x = Oldx,y = Oldy,s = math.random(2,5),c = math.random(0,2),vx = math.random(-1,1),vy = math.random(-1,1)})
			addParts({mode = 4,x = Oldx,y = Oldy,s = math.random(2,5),c = math.random(0,2),vx = math.random(-1,1),vy = math.random(-1,1)})
			addParts({x = Oldx,y = Oldy,c = 1,vy = 1,w = math.random(1,4),h = math.random(1,4)})
			table.remove(bullet,i)
		end
		
		if p.dir == 1 then v.r = 3 -- up
		elseif p.dir == 2 then v.r = 1 end -- down
		if p.dir == 3 then v.f = 1 v.r = 0 -- left
		elseif p.dir == 4 then v.f = 0 v.r = 0 end -- right
		if p.dir == 5 then v.f = 1 end -- up/left
		if p.dir == 7 and bChange then v.r = 1 v.f = 1 -- down/left
		elseif p.dir == 8 and bChange then v.r = 1 v.f = 0 end -- down/right
	
		if v.x - mx < 0 or v.x - mx > 240 or v.y - my < 0 or v.y - my > 136 then table.remove(bullet,i) end
		
		v.x = v.x + v.vx
		v.y = v.y + v.vy
	end	
end

function Mob(x,y)
	local s = {}
	s.type = "undefined"
	s.name = "?"
	s.t = 0
	s.hp = 1
	s.sp = s.sp
	s.spawntile = 1
	s.spawmx = x // 8
	s.spawmy = y // 8
	s.tile = 16
	s.anims = {}
	s.die = False
	s.collide = False
	s.atk = false
	s.vanish = 0
	s.timer = 0
	s.hit = 0
	s.dmg = 0
	s.hitpause = 0
	s.range = 0
	s.fov = 12
	s.minDelayAtk = 30
	s.maxDelayAtk = 90
	s.x = x or 0
	s.y = y or 0
	s.w = 8
	s.h = 8
	s.vx = 0
	s.vy = 0
	s.dy = 0
	s.speed = 0.4
	s.animSpeed = 8
	s.f = 0
	s.c = 11
	
	function s.seePlayer(s,x1,y1)
		local dx = x1 - s.x
		local dy = y1 - s.y
		local dst = math.sqrt((dx^2+dy^2))
		local a = math.atan2(dy,dx)	
		if dst > s.fov then if dst <= s.range then if math.abs(dx) >= s.speed then s:move(math.cos(a)*s.speed,0) end if math.abs(dy) >= s.speed then s:move(0,math.sin(a)*s.speed) end end end
	end
	
	function s.move(s,dx,dy)
		if s.die == True or s.atk then return end
		s.vx = dx
		s.vy = dy
		
		local x,y,w,h = s.x + s.vx,s.y + s.vy,s.w,s.h
		if sol(x+1,y+((h/2)+1))or sol(x+(w-1),y+((h/2)+1))or sol(x+1,y+(h-1))or sol(x+(w-1),y+(h-1))then
			s.vx,s.vy = 0,0
		end
		
		s.x = s.x + s.vx
		s.y = s.y + s.vy
	end
	
	function s.despawn(s)
		mset(s.spawnx,s.spawny,s.spawntile)
	end
	
	function s.damage(s,amount)
		if not (s.die == True) then
			s.hit = 5
			local amt = amount or 1
			s.hp = s.hp - amt
		end
	end
	
	function s.attack(s)
		if not s.atk then
			sfx(4,"C-6",30,0,13) -- sound atk
			if p.shield <= 0 then 
				p:damage(s.dmg)
				local oldx,oldy = p.x,p.y
				addParts({x = oldx,y = oldy,mode = 2,text = -s.dmg,vy = -0.5,vx = 0,c = 1,max = 40})
				addParts({x = p.x,y = p.y,c = 1,vx = math.cos(t),vy = math.sin(t)})
			else
				addParts({x = p.x,y = p.y,c = 2,vx = math.cos(t),vy = math.sin(t)})
			end
			s.hitpause = 40
			s.atk = true
		end
	end
	
	local rnd = math.random(32,128)
	local rnd2 = math.random(211*8,238*8)
	local rnd3 = math.random(102*8,134*8)
	function s.update(s)
		s:updateEnemy()
	end
	
	function s.draw(s)
		if s.hit > 0 then
			for i=0,15 do
				pal(i,2)
			end
		end
		if s.timer < 105 and (s.timer//3)%2 == 0 then
			sprc(271,s.x,s.y+3,0,1)
			sprc(s.sp,s.x,s.y,s.c,1,s.f)
			if _GAME.on then rectb(s.x-mx,s.y-my,s.w,s.h,9)end
		end
		pal()
	end
	
	function s.updateEnemy(s)
		if s.type == "enemy" then
			
			if s.vx ~= 0 then s.f = s.vx < 0 and 1 or 0 end
			if s.die == True then s.vanish = s.vanish + 1 end
			if s.vanish > 100 then s.timer = s.timer + 1 end
			
			if s.hit > 0 then s.hit = s.hit - 1 end
			if s.hitpause <= 0 then s.atk = false end
			
			if s.timer > 105 then for i=#mobs,1,-1 do local m = mobs[i];if m == s and m.name ~= "king_demon" then	table.remove(mobs,i)	end	end end
			
			if s.die == True then return end
			
			local dx = p.x - s.x
			local dy = p.y - s.y
			local dst = math.sqrt((dx^2+dy^2))
			local a = math.atan2(dy,dx)
			
			if  s.hitpause > 0 then
				s.hitpause = s.hitpause - 1
				s.hit = 0
			else
			
				if dst > s.fov then
					if dst <= s.range then
						if math.abs(dx) >= s.speed then
							s:move(math.cos(a)*s.speed,0)
						end
						if math.abs(dy) >= s.speed then
							s:move(0,math.sin(a)*s.speed)
						end
					else
						s.vx,s.vy = 0,0
					end
				else
					s.vx,s.vy = 0,0
				end			
			end
			
			local dst = math.sqrt(((p.x-s.x)^2+(p.y-s.y)^2))
			if dst <= s.fov then
				if p.x > s.x then s.f = 0 else s.f = 1 end
				if t > s.t then
					s:attack()
					s.t = t + math.random(s.minDelayAtk,s.maxDelayAtk)
				end
			else
				s.t = t + math.random(0,s.maxDelayAtk)
			end
			
			for _,v in ipairs(bullet)do
				if col(v.x,v.y,v.w,v.h,s.x,s.y,s.w,s.h) then
					sfx(12,"E-4")
					s:damage(p.dmg)
					table.remove(bullet,_)
					addParts({x = s.x,y = s.y,c = 2,vx = math.cos(t),vy = math.sin(t)})
					local oldx,oldy = s.x,s.y
					addParts({x = oldx,y = oldy,mode = 2,text = -p.dmg,vy = -0.5,vx = 0,c = 2,max = 40})
				end
			end
			
			if s.vx ~= 0 or s.vy ~= 0 then s.sp = anim(s.anims.walk,s.animSpeed)
			elseif s.vx == 0 and s.vy == 0 then  s.sp = anim(s.anims.idle,s.animSpeed) end
			if s.hp <= 0 then s.die = True s.sp = anim(s.anims.die,s.animSpeed) s.hit = 0
			elseif s.atk then s.sp = anim(s.anims.atk,16)end
			
			if colT(s.x,s.y,s.w,s.h,49) then s.die = True end
			
			if s.die == True then
				s.sp = anim(s.anims.die,s.animSpeed)
				for i=0,4 do
					addParts({x = 2*i+s.x,y = s.y,c = 1,vy = - math.random(1,2)/2})
				end
				if s.name ~= "king_demon" then
					table.insert(mobs,chest_item[1][math.random(1,2)](s.x,s.y+4))
					table.insert(mobs,Exp(s.x,s.y))
				end
			end
			
		end
	end
	return s
end

function Goblin(x,y)
	local s = Mob(x,y)
	s.type = "enemy"
	s.name = "goblin"
	s.sp = 304
	s.hp = 5
	s.anims = {
		walk = {305,306},
		idle = {304},
		die = {309},
		atk = {307,308}
	}
	s.dmg = math.random(1,2)
	s.range = 50
	s.speed = 0.5
	s.minDelayAtk = 30
	s.maxDelayAtk = 60
	s.supUpdate = s.update
	
	function s.update(s)
		s:supUpdate()
		s.dmg = math.random(1,2)
	end
	
	return s
end

function Bat(x,y)
	local s = Mob(x,y)
	s.type = "enemy"
	s.name = "bat"
	s.sp = 320
	s.dy = 0
	s.anims = {
		idle = {320,321},
		walk = {320,321},
		die = {324},
		atk = {322,323},
	}
	s.hp = math.random(1,2)
	s.range = 60
	s.speed = 0.5
	s.dmg = 1
	s.minDelayAtk = 10
	s.maxDelayAtk = 50
	s.supUpdate = s.update
	
	function s.update(s)
		s:supUpdate()
		s.dy = math.sin(t/8)*2
	end
	
	function s.draw(s)
		if s.hit > 0 then
			for i=0,15 do
				pal(i,12)
			end
		end
		if s.timer < 105 and (s.timer//3)%2 == 0 then
			if not (s.die == True) then
				sprc(271,s.x,s.y+3,0,1)
			end
			sprc(s.sp,s.x,s.y-4 + (s.die == True and 0 or (s.atk and 0 or s.dy)),s.c,1,s.f)
			if _GAME.on then rectb(s.x-mx,s.y-4+(s.die == True and 0 or (s.atk and 0 or s.dy))-my,s.w,s.h,9)end
		end
		pal()
	end
	
	return s
end

function Skeleton(x,y)
	local s = Mob(x,y)
	s.type = "enemy"
	s.name = "skeleton"
	s.sp = 336
	s.anims = {
		idle = {336},
		walk = {337,338},
		atk = {339,340},
		die = {341},
	}
	s.hp = 50
	s.speed = 0.3
	s.range = 20
	s.dmg = 3
	s.minDelayAtk = 0
	s.maxDelayAtk = 190
	s.supUpdate = s.update
	
	function s.update(s)
		s:supUpdate()	
	end
	
	return s
end

function Cerberus(x,y)
	local s = Mob(x,y)
	s.type = "enemy"
	s.name = "cerberus"
	s.sp = 352
	s.anims = {
		idle = {352,353},
		walk = {354,355},
		atk = {356,357},
		die = {358},
	}
	s.hp = 5
	s.range = 80
	s.speed = 1
	s.dmg = math.random(1,3)
	s.minDelayAtk = 30
	s.maxDelayAtk = 60
	s.supUpdate = s.update
	
	function s.update(s)
		s:supUpdate()
		s.dmg = math.random(1,3)
	end
	
	return s
end

function Hunter(x,y)
	local s = Mob(x,y)
	s.type = "enemy"
	s.name = "adventurer_hunter"
	s.sp = 368
	s.dmg = 1
	s.hp = 5
	s.range = 130
	s.fov = 8*12
	s.supUpdate = s.update
	s.anims = {
		idle = {368,369},
		walk = {370,371},
		atk = {372,373},
		die = {374},
	}
	
	function s.createBullet(s,x,y,vx,vy)
		local b = Bullet(x,y,vx,vy)
		b.sp = {291,292}
		b.animSpeed = 2
		b.dmg = s.dmg
		b.range = s.range
		return b
	end
	
	function s.attack(s)
		if not s.atk then
			sfx(5,"C-6",20,0,13)
			local speed,dir,a = 1.5,(s.x-p.x)>0 and 0 or 2,angle(p.x,p.y,s.x,s.y)
			local b = s:createBullet(s.x+dir,s.y+2,-speed*math.cos(a),-speed*math.sin(a))
			table.insert(enemyBullet,b)
			s.hitpause = 40
			s.atk = true
		end
	end
	
	function s.update(s)
		s:supUpdate()
		s.dmg = math.random(1,2)
	end
	return s
end

function forsakenGoblin(x,y)
	local s = Mob(x,y)
	s.type = "enemy"
	s.name = "forsaken_goblin"
	s.sp = 384
	s.anims = {
		idle = {384,385},
		walk = {386,387},
		atk = {388,389},
		die = {390},
	}
	s.hp = 3
	s.dmg = 1
	s.range = 140
	s.fov = 8*10
	s.supUpdate = s.update
	
	function s.createBullet(s,x,y,vx,vy)
		local b = Bullet(x,y,vx,vy)
		b.sp = {289,290}
		b.animSpeed = 1
		b.dmg = s.dmg
		b.range = s.range
		return b
	end
	
	function s.attack(s)
		if not s.atk then
			sfx(5,"C-6",20,0,13)
			local speed,dir,a = 1.5,(s.x-p.x)>0 and 0 or 2,angle(p.x,p.y,s.x,s.y)
			local b = s:createBullet(s.x+dir,s.y+4,-speed*math.cos(a),-speed*math.sin(a))
			table.insert(enemyBullet,b)
			s.hitpause = 40
			s.atk = true
		end
	end
	
	function s.update(s)
		s:supUpdate()
	end
	return s
end

function Boss(x,y)
	local s = Mob(x,y)
	s.type = "enemy"
	s.name = "king_demon"
	s.sp = 400
	s.anims = {
		idle = {400,402},
		walk = {404,406},
		atk = {432,434},
		die = {436},
	}
	s.maxHp = 100
	s.hp = s.maxHp
	s.w = 16
	s.h = 16
	s.range = 150
	s.fov = 8*8
	s.dmg = 1
	s.animSpeed = 16
	s.minDelayAtk = 40
	s.maxDelayAtk = 120
	s.spawnMobTimer = 100
	s.supUpdate = s.update
	local mob = {
		Goblin,Bat,Skeleton,Cerberus,
	}
	
	function s.createBullet(s,x,y,vx,vy)
		local b = Bullet(x,y,vx,vy)
		b.dmg = s.dmg
		b.range = s.range
		b.sp = {293,294,295,295,294,293}
		b.animSpeed = s.animSpeed
		return b
	end
	
	function s.attack(s)
		if not s.atk then
			for i=1,4 do
				local speed,dir,a = 1.5,4
				if s.hp < s.maxHp/2 then
					a = math.random()*4*math.pi
				else
					a = angle(p.x,p.y,s.x,s.y)
				end
				local b = s:createBullet(s.x+dir,s.y+2,-speed*math.cos(a),-speed*math.sin(a))
				table.insert(enemyBullet,b)
				sfx(3,"C#5") -- sound shoot
			end
			s.hitpause = 80
			s.atk = true
		end
	end
	
	function s.regenerate(s)
		if s.hitpause < 10  and s.hp < s.maxHp then
			s.hp = s.hp + (1/32)
			if s.hp > s.maxHp then s.hp = s.maxHp end
			addParts({x=s.x+8,y=s.y+8,c=3,vy=-math.random(1,3),mode=5,max=5})
		end
	end
	
	function s.update(s)
		if bossBattle and not bossDead then
			s:supUpdate()
			if s.spawnMobTimer > 0 then s.spawnMobTimer = s.spawnMobTimer -1 end
			s.dmg = math.random(1,5)
			if s.hp <= 3 then
				s.minDelayAtk = 0
				s.maxDelayAtk = 10
				s.animSpeed = 8
			end
			if s.spawnMobTimer <= 0 then
				local rnd = math.random(1,#mob)
				table.insert(mobs,mob[rnd](s.x,s.y))
				s.spawnMobTimer = 100
			end
			s:regenerate()
		end
		
		if s.die == True then
			bossDead = true
			unlockRoom(224,102,226,102)
			bossBattle = false
	 end
	end
	
	function s.draw(s)
		if s.hit > 0 then
			for i=0,15 do
				pal(i,2)
			end
		end
		sprc(268,s.x,s.y+3,0,1,0,0,2,2)
		sprc(s.sp,s.x,s.y,s.c,1,s.f,0,2,2)
		if _GAME.on then rectb(s.x-mx,s.y-my,s.w,s.h,9)end
		if bossBattle then
			spr(412,240-8,0,11,1)
			spr(412,240-8,136-8,11,1,0,2)
			for i=1,22-1 do
				spr(413,240-8,6*i,-1,1)
			end
			for i=1,s.hp do
				spr(478,240-8,6*i-4,s.c,1)
			end
		end
		pal()
		--printb(s.hp,0,100,1)
	end
	return s
end

function Player(x,y)
	local s = Mob(x,y)
	s.type = "hero"
	s.name = "princess"
	s.money = 0
	s.maxHp = 5
	s.hp = s.maxHp
	s.exp = 0
	s.keys = 0
	s.potions = 0
	s.ma = False -- "Multiplied Arrows" Upgrade
	s.da = False -- "Diamond Arrows" Upgrade
	s.shield = 0
	s.sp = 256
	s.f = 1
	s.dmgExtra = s.maxHp - 5
	s.dmg = 1 + s.dmgExtra
	s.speed = 1
	s.supMove = s.move
	s.dir = 0
	
	function s.move(s,dx,dy)
		s:supMove(dx,dy)		
		if s.vx ~= 0 then s.f = s.vx<0 and 1 or 0 end
	end
	
	function s.cam(s)
		local x,y = s.x//240*240,s.y//136*136
		if p.x > 210*8 and (p.y > 101*8 and p.y < 135*8) then
			my = math.min(119*8,math.max(102*8,math.floor(p.y) - 68))
		else
		if x ~= mx or y ~= my then
			mx = x
			my = y
		end
		end
	end
	
	function s.anim(s)
		if s.vx ~= 0 or s.vy ~= 0 then s.sp = s.anims.walk  
		elseif butn("x") then s.sp = s.anims.atk 
		else s.sp = s.anims.idle end
	end
	
	function s.onPotion(s)
		if not (s.die == False) and s.hp < s.maxHp  and s.potions > 0 then
			s.potions = s.potions - 1
			s.hp = s.hp + 20
			if s.hp > s.maxHp then s.hp = s.maxHp end
			local oldx,oldy = s.x,s.y
			addParts({x = oldx,y = oldy,mode = 2,text = "+"..20,vy = -0.5,vx = 0,c = 2})
		end
	end
	
	function s.levelUp(s)
		if s.exp > 100 then
			addDialog({"Level up!!","One more heart has been added to your\nhealth bar"})
			s.exp = 0
			s.exp = s.exp + exp
			s.maxHp = s.maxHp + 1
			s.hp = s.maxHp
			s.dmgExtra = s.dmgExtra + 1
			if s.exp > 21 then s.exp = 21 end
		end
	end
	
	function s.update(s)
		if s.hp <= 0 then s.sp = s.anims.die end
		
		if s.die == True then return end
		s.vx = 0
		s.vy = 0
		bullet_timer = bullet_timer - 1
		if s.hit > 0 then s.hit = s.hit - 1 end
		if s.shield > 0 then s.shield = s.shield - 1 end
		if s.ma == True then bmax_timer = 10 end
		if s.da == True then s.dmg = math.random(2+s.dmgExtra,5+s.dmgExtra) 
		else s.dmg = math.random(1+s.dmgExtra,2+s.dmgExtra)end
		
		s.anims.walk = anim({257,258})
		s.anims.atk = anim({259,260},16)
		s.anims.idle = 256
		s.anims.die = 261
		
		if not butn("x")then
			if butn("up")then bvx,bvy = 0,- 2 bChange = false s.dir = 1 end
			if butn("down")then bvx,bvy = 0,2 bChange = false s.dir = 2 end
			if butn("left")then bvx,bvy = -2,0 bChange = false s.dir = 3 end
			if butn("right")then bvx,bvy = 2,0 bChange = false s.dir = 4 end
		end
		
		if butn("up") and butn("left")then bvx,bvy = - 2,- 2 bChange = true s.dir = 5 end -- up/left
		if butn("up") and butn("right")then bvx,bvy = 2,- 2 bChange = true s.dir = 6 end -- up/right
		if butn("down") and butn("left")then bvx,bvy = - 2,2 bChange = true s.dir = 7 end -- down/left
		if butn("down") and butn("right")then bvx,bvy = 2,2 bChange = true s.dir = 8 end -- down/right
		
		if butn("up")then s:move(0,- s.speed)end -- up
		if butn("down")then s:move(0,s.speed)end -- down
		if butn("left")then s:move(- s.speed,0)end -- left 
		if butn("right")then s:move(s.speed,0)end -- right

		if butnp("a")then Interact(s) end -- interacts with NPCs
		if butnp("b")then s:onPotion()end -- Use Potion
		if butn("x") and bullet_timer < 0 then  -- shoot
			sfx(8,"D-4") -- sound atk
			bullet_timer = bmax_timer
			table.insert(bullet,{sp = 272,x = s.x,y = s.y,vx = bvx*2,vy = bvy*2,f = bf,r = br,w = 8,h = 8})
		end
		if s.hp <= 0 then s.die = True s.hit = 0 end
		

		s:cam()
		s:anim()
		s:levelUp()
	end
	
	function s.draw(s)
		if s.hit > 0 then
			for i=0,15 do
				pal(i,2)
			end
		end
		sprc(271,s.x,s.y+3,0,1)
		sprc(s.sp,s.x,s.y,s.c,1,s.f)
		pal()
		if s.shield > 0 then circb(s.x-mx+4,s.y-my+4,5,2)end
		if _GAME.on then rectb(s.x-mx,s.y-my,s.w,s.h,9)end
	end
	return s
end

function Fairy(x,y)
	local s = Mob(x,y)
	s.type = "friend"
	s.name = "fairy"
	s.sp = 274
	s.speed = 0.9
	s.fov = 8*2
	s.range = 1000
	s.timer = 100
	s.dy = 0
	
	function s.update(s)
		if (s.vx ~= 0 or s.vy ~= 0) and t%8 == 0 then
			addParts({mode = 5,x = s.x,y = s.y,c = 2,max = 30})
		else
			if t%16 == 0 then
				addParts({mode = 5,x = s.x,y = s.y,c = 2})
			end
		end
		
		s:seePlayer(p.x,p.y)
		
		if (p.x > s.x + 40 or p.y > s.y + 40) or (p.x < s.x - 40 or p.y < s.y - 40) then
			s.timer = s.timer - 1
		else
			s.timer = 100
		end
		
		if	 s.timer < 0 then
			local oldx,oldy = p.x,p.y
			s.x = oldx + (math.random(-15,15))
			s.y = oldy
			addParts({x = s.x,y = s.y,s = math.random(2,4),c = 2,vy = -1})
			s.timer = 100
		end
		
		s.sp = anim({274,275})
		s.dy = math.sin((t/4)/2)
	end
	
	function s.draw(s)
		sprc(271,s.x,s.y + 3,0,1)
		sprc(s.sp,s.x,s.y + s.dy - 4,s.c,1)
	end
	return s
end

function safePoint(x,y)
	local s = Mob(x,y)
	s.type = "magic"
	s.name = "safePoint"
	s.tile = 50
	
	function s.update(s)
		if col2(s,p)and butnp("a")then
			if p.hp < p.maxHp then
				sfx(1,"D-5",30,0)
				p.hp = p.maxHp
				addDialog({"You have been restored"})
			else
				addDialog({"You don't need to be restored"})
			end
			Save()
		end
		if col2(s,p)then end
		s.dy = math.cos((t/16))*2
	end
	
	function s.draw(s)
		if (t/4)%8 == 0 then
			addParts({x = s.x+4,y = s.y,vy = - 0.5,c = 2,mode = 5,max = 80})
		end
		if col2(s,p)then
			sprc(509,s.x,(s.y-10)+s.dy,11,1)
		end
	end
	return s
end

function NPC(name,sp,dialogs,type,spawn)
	local function func(x,y)
		local s = Mob(x,y)
		s.type = type or "npc"
		s.name = name
		s.hp = nil
		s.sp =  sp
		s.dpos = 0
		s.dcolor = 0
		s.over = not type == "npc"
		s.collide = True
		
		function s.onInteract(s)
			s.dpos = (s.dpos%#dialogs)+1
			if s.dpos == #dialogs then
				s.over = true
			end
			addDialog(dialogs[s.dpos],s.dcolor,s.sp,name)
		end
		
		function s.update(s)
			s.dy = math.sin((t/16))*2
		end
		
		function s.draw(s)
			if s.sp > 207 and s.sp < 216 and t%32 == 0 then
				if p.x > s.x then s.f = 0 else s.f = 1 end
			end		
			sprc(271,s.x,s.y+2,0,1)
			
			if s.type == "npc" or s.type == "board" or s.type == "dummy"then
				s.collide = True
			else
				s.collide = False
			end
			
			sprc(s.sp,s.x,s.y,s.c,1,s.f)
			
			if not s.over and s.type == "npc" then
				sprc(anim({491,492,493,494},16),s.x+4,(s.y-10),11,1)
			end
			
			if s.type == "board" then
				s.over = true
				if col(p.x,p.y,p.w,p.h,s.x,s.y,s.w+1,s.h) then 
					sprc(509,s.x,(s.y-10)+s.dy,11,1)
				end
			end
			
		end
		return s
	end
	return func
end

function Item(x,y)
	local s = Mob(x,y)
	s.type = "item"
	s.pickUp = False
	s.collide = False
	s.t = 0
	s.timer = 0
	s.dy = 0
	s.fov = 0
	s.range = 50
	
	function s.update(s)
		if s.pickUp == True then return end
		
		if s.name ~= "chest" then 
		s.dy = math.cos(t/16)*2 end
		
		s.timer = s.timer + 1
		
		if col2(p,s)then
			s:onPickUp()
			s.pickUp = True
		else
			if s.timer > 40 then
				s.t = s.t + 1
			end
		end
	end

	function s.draw(s)
		if not (s.pickUp == True) then
			sprc(271,s.x,s.y+2,0,1)
			sprc(s.sp,s.x,s.y+s.dy,s.c,1)
			if _GAME.on then rectb(s.x-mx,s.y-my,s.w,s.h,9)end
		end
	end
	return s
end

function Coin(x,y)
	local s = Item(x,y)
	s.name = "coin"
	s.sp = 241
	s.speed = 2
	s.supUpdate = s.update
	
	function s.onPickUp(s)
		local rnd = math.random(5,10)
		p.money = p.money + rnd
		addParts({text = "+"..rnd,x = s.x,y = s.y,mode = 2,c = 3,small = true})
		sfx(10,"A-6",30,3)
	end
	
	function s.update(s)
		if s.pickUp == True then return end
		s:supUpdate()
		s:seePlayer(p.x,p.y)
		s.sp = anim({241,459,459})
	end
	return s
end

function coinExchange(x,y)
	local s = Item(x,y)
	s.name = "ce"
	s.sp = 242
	
	function s.onPickUp(s)
		local rnd = math.random(20,50)
		p.money = p.money + rnd
		addParts({text = "+"..rnd,x = s.x,y = s.y,mode = 2,c = 3})
	end
	return s
end

function Potion(x,y)
	local s = Item(x,y)
	s.name = "potion"
	s.sp = 225
	
	function s.onPickUp(s)
		p.potions = p.potions + 1
		addDialog({"You got a POTION!"})
	end
	return s
end

function diamondArrow(x,y)
	local s = Item(x,y)
	s.name = "da"
	s.sp = 228
	function s.onPickUp(s)
		addDialog({"You got Diamond Arrow!","Now your arrow is stronger!!"})
		p.da = 1
	end
	return s
end

function multipleArrows(x,y)
	local s = Item(x,y)
	s.name = "ma"
	s.sp = 227
	function s.onPickUp(s)
		addDialog({"You got \"Multiplied Arrows!\"","Now you can shoot more arrows than\nbefore!!"})
		p.ma = 1
	end
	return s
end

function magicShield(x,y)
	local s = Item(x,y)
	s.name = "shield"
	s.sp = 229
	function s.onPickUp(s)
		addDialog({"You got \"Magic Shield\""})
		p.shield = 500
	end
	return s
end

chest_item = {
	-- 1, 2				3,   								4,    						5,  6,
	{Coin,Coin,coinExchange,magicShield,Bat,Potion},
	-- 1, 2, 3,  4,   5,                     6,
	{nil,nil,nil,nil,"Watch out! A bat!!!",nil}
}

function Chest(x,y)
	local s = Item(x,y)
	s.name = "chest"
	s.sp = 224
	s.collide = True
	s.open = False
	function s.update(s)
		if s.open == True then s.vanish = s.vanish + 1 end
		if s.vanish > 100 then s.timer = s.timer + 1 end
		if s.timer > 105 then s.collide = False for i=#mobs,1,-1 do local m = mobs[i];if m == s then 	table.remove(mobs,i) end end end
		
		if s.open == True then return end	
		for _,m in ipairs(mobs)do if m.type == "enemy" and col2(m,s)then s.collide = False else s.collide = True end end	
		if col2(p,s)and butnp("a")then
			s.open = True
			local id = math.random(1,#chest_item[1])
			table.insert(mobs,chest_item[1][id](s.x,s.y+6))
			addDialog({chest_item[2][id]})
		end		
		s.dy = math.sin((t/8))*2
	end
	
	local flip = math.random(0,1)
	function s.draw(s)
		if s.timer < 105 and (s.timer//3)%2 == 0 then
			sprc(271,s.x,s.y,0,1)
			if not (s.open == True) then 
				sprc(s.sp,s.x,s.y,s.c,1,flip)
				if col2(p,s)then
					sprc(509,s.x,s.y-8+s.dy,11,1)
				end
			else 
				sprc(240,s.x,s.y,s.c,1)
			end
			if _GAME.on then rectb(s.x-1-mx,s.y+2-my,s.w+2,s.h-1,9)end
		end
	end
	return s
end

function Key(x,y)
	local s = Item(x,y)
	s.name = "key"
	s.sp = 243
	
	function s.onPickUp(s)
		addDialog({"You found a key!"})
		p.keys = p.keys + 1
		sfx(13,"E-6",30,3)
	end
	return s
end

function Exp(x,y)
	local s = Item(x,y)
	s.name = "exp"
	s.sp = 246
	s.speed = 1.5
	s.supUpdate = s.update
	
	function s.onPickUp(s)
		p.exp = p.exp + exp
		
		local oldx,oldy = s.x,s.y
		addParts({x = oldx,y = oldy,c = 3,mode = 2,vy = - 0.5,text = "+"..exp.." exp"})
		sfx(9,"D-6",30,3)
	end
	
	function s.update(s)
		if s.pickUp == True then return end
		s:supUpdate()
		s:seePlayer(p.x,p.y)
	end
	return s
end

function Door(x,y)
	local s = Mob(x,y)
	s.type = "tile"
	s.name = "door"
	s.sp = 244
	s.collide = True
	s.open = False
	
	function s.onInteract(s)
		if butnp("a")and p.keys > 0 and s.open == False then
			sfx(6,"C-5")
			addDialog({"Unlocked"})
			s.open = True
			s.collide = False
			p.keys = p.keys - 1
		else
			if not (s.open == True) then
				sfx(14,"C#1",15)
				addDialog({"Locked"})
			end
		end
		
		if s.open == True then
		end
	end
	function s.draw(s)
		if not (s.open == True) then
			sprc(s.sp,s.x,s.y,s.c,1)
		else
			sprc(245,s.x,s.y,s.c,1)
		end
	end
	return s
end

function doorRoom(oldId,nextId,textScreen)
	local function func(x,y)
		local s = Mob(x,y)
		s.type = "tile"
		s.name = "doorRoom"
		s.id = oldId
		s.sp = 443
		textScreen = textScreen or ""
		s.enter = false
		s.tile = 1
		
		function s.onInteract(s)
			if butnp("a")then
				for _,m in ipairs(mobs)do
					if m.name == "doorRoom"then
						if m.id == nextId then
							p.x,p.y = m.x,m.y + 10
						end
					end
				end
				s.enter = true
				fade(-2)
				showTextScreen(textScreen)
			end
		end		
		
		function s.update(s)			
			s.dy = math.cos(t/16)*2
		end
		
		function s.draw(s)
			local wp = printb(textScreen,0,-6,2,false,1,true)
			local cb,doorx,doory = 0,(s.x-wp//3),s.y-16+s.dy
			if mget(doorx//8,doory//8) == 0 then cb = 1 else cb = 0 end
		
			if col2(p,s)then
				sprc(509,s.x,s.y-10+s.dy,11,1)
				if s.enter then	
					printb(textScreen,doorx-mx,doory-my,2,false,1,true,cb)
				end
			end
			sprc(s.sp,s.x,s.y,s.c,1)
		end
		return s
	end
	return func
end

function Shop(x,y)
	local s = Mob(x,y)
	s.type = "sold"
	s.collide = True
	s.price = 100
	s.dy = 0
	
	function s.update(s)
		if butnp("a")and col2(s,p) then
			if type(s.price) == "number" then
				if p.money >= s.price then
					p.money = p.money - s.price
					s.price = s.price * 2
					s:buy()
				else
					addDialog({"You don't have enough coins"})
				end
			end
			sfx(9,"D-6",30,3)
		end
		s.dy = math.sin(t/16)*2
		s.dy2 = math.cos((t/16))*2
	end
	
	function s.draw(s)
		sprc(s.sp,s.x,s.y-6+s.dy,s.c,1)
		printb(s.price,s.x-mx,s.y+10-my,2,false,1,true)
		
		if col2(s,p)then
			sprc(509,s.x,(s.y-16)+s.dy2,11,1)
		end
	end
	return s
end

function potionShop(x,y)
	local s = Shop(x,y)
	s.name = "potionShop"
	s.sp = 225
	
	function s.buy(s)
		p.potions = p.potions + 1
		addDialog({"You bought a POTION!"})
	end
	
	function s.draw(s)
		mset(s.x//8,s.y//8,29)
		sprc(s.sp,s.x,s.y-6+s.dy,s.c,1)
		printb(s.price,s.x-mx,s.y+10-my,2,false,1,true)
		
		if col2(s,p)then
			sprc(509,s.x,(s.y-16)+s.dy2,11,1)
		end
	end
	return s
end

function maShop(x,y)
	local s = Shop(x,y)
	s.name = "maShop"
	s.sp = 227
	s.price = 100
	
	function s.buy(s)
		p.ma = 1
		s.price = "sold"
		addDialog({"You bought a \"Multiplied Arrows!\"","Now you can shoot more arrows than\nbefore!!"})
	end
	
	function s.draw(s)
		mset(s.x//8,s.y//8,29)
		sprc(s.sp,s.x,s.y-6+s.dy,s.c,1)
		printb(s.price,s.x-mx,s.y+10-my,2,false,1,true)
		
		if col2(s,p)then
			sprc(509,s.x,(s.y-16)+s.dy2,11,1)
		end
	end
	return s
end

function Wall(sp)
	local function func(x,y)
		local s = Mob(x,y)
		s.type = "tile"
		s.name = "wall"
		s.collide = True
		s.sp = sp
		
		function s.draw(s)
			if s.sp == 446 then s.collide = False else s.collide = True end
			if s.sp == 128 then s.c = 11 end
			sprc(s.sp,s.x,s.y-8,s.c,1,0,0,1,2)
		end
		return s
	end
	return func
end

function Bestiary(x,y)
	local s = Mob(x,y)
	s.type = "book"
	s.name = "bestiary"
	s.collide = True
	s.sp = 156
	
	function s.update(s)
		if butnp("a")and col2(s,p)then
			trace("\n============ \nBESTIARY ON\n============",4)
			bestiaryOn = true
		end
		
		s.dy = math.sin((t/16))*2
	end
	
	function s.draw(s)
		if col2(s,p)then
			sprc(509,s.x,(s.y-10)+s.dy,11,1)
		end
		sprc(s.sp,s.x,s.y,s.c,1)
	end
	return s
end

function bestiaryUpdate()
	local beast = {
		{
			name = "Zamon's Bestiary",
			desc = "\t\tHello dear reader, I am happy to be\nreading this research of mine that it\ntook me so many years to complete it.\t\tIn\nthis book I categorized all the\nmonsters seen in this dungeon, I drew\nthem to represent them and all have\ntheir names named by various scholars,\nso If you find any bad names, don't\njudge me.\t\tIn the lower left corner\nthere will be a table with some\ninformation about the monsters, such as\ntheir durability (HP), their level of\ndanger and their strength (ATK).",
			info = {},
		},
		{
			desc = "\t\tFinally, I want to thank an unnamed\nadventurer who wanted to help me for\ncompleting this book, unfortunately he\nfell into a hole in a dungeon and I never\nsaw him again... he had a certain addiction\nto collecting things.",
			info = {},
		},
		{
			name = "Bat",
			sp = {320,321,322,323,324},
			desc = "\t\tA rather annoying and annoying being,\nhe uses his echolocation to fly around\nthe dungeon.\t\tThey are fast, but also\nquite weak, most of them walk in packs,\nmaking it easier to attack the chosen\ntarget.",
			info = {"Level: low","Hp: 1/2","Atk: 1"},
		},
		{
			name = "Goblin",
			sp = {304,305,306,307,308,309},
			desc = "\t\tA being that likes to attack any\nadventurer, he is often armed with a\ndagger using his rags.\t\tBe careful if you\nfind him with his pack, they are stronger\nthan they seem together.",
			info = {"Level: low","Hp: 5","Atk: 1/2"},
		},
		{
			name = "Skeleton",
			sp = {336,337,338,339,340,341},
			desc = "\t\tIt is believed that in his lifetime he\nwas a soldier of some tribe, kingdom or\nany civilization.\t\tThe Demon King saw an\nopportunity to use the dead as his\nsubjects so he used necromancy magic to\n\"revive\" the dead.\t\tThis monster is one\nof the strongest among the other\ndungeon monsters.",
			info = {"Level: hard","Hp: 10","Atk: 3"},
		},
		{
			name = "Cerberus",
			sp = {352,354,356,357,358},
			desc = "\t\tUndoubtedly the fastest monster in\nthe dungeon, if you see him, I recommend\nyou to run!\t\tAlthough even running he\ncan catch you... well... me... just good\nluck with him.",
			info = {"Level: middle","Hp: 5","Atk: 1/3"},
		},
		{
			name = "Forsaken Goblin",
			sp = {384,385,386,387,388,389,390},
			desc = "\t\tIn the goblin tribe, if a goblin decides\nto leave the group he will be forced to\nroam the dungeons without a pack,\nalone.\t\tThey usually carry a type of\ncircular saw, it REALLY cuts!",
			info = {"Level: middle","Hp: 3","Atk: 1"},
		},
		{
			name = "Adventurer Hunter",
			sp = {368,369,370,371,372,373,374},
			desc = "\t\tIn some places there are groups of\nhunters who like to go after\nadventurers, and with dungeon\nadventurers it would be no different.\n\t\tThey attack the target looking to kill\nhim and steal all his items, they\nusually carry knives, they are masters\nat throwing them.",
			info = {"Level: hard","Hp: 5","Atk: 1/2"},
		},
	}
	
	if	bossDead then
		table.insert(beast,{
			name="King Demon",
			sp = {400},
			desc="\t\tWe have arrived at the terrible,\ngreat, powerful and famous Demon\nKing!\t\tI don't have much to say\nabout him, just a very powerful\nbeing with unknown powers, no\nknight was able to defeat him.\t\tI\nwonder when he will be defeated.\n\t\tsurely it will be by a great\nknight.",
			info = {},
		})
	end
	global_hitpause = 1
	clip(10,10,240-20,136-20)
	cls()
	
	if butnp("left") and beast_state > 1 then
		beast_state = beast_state - 1
	elseif butnp("right") and beast_state < #beast then
		beast_state = beast_state + 1
	end
	
	local w,h
	local sw,pw,bw = 0,70,146
	for _,v in ipairs(beast)do
		if v.name == "King Demon" then sw = 19;pw = 89;bw = 127;w,h = 2,2 else sw = 0;pw = 70;bw = 146;w,h = 1,1 end
		if _ == beast_state then		
			local x,y,s = 20,20,4
			for d=1,#dirs do
				for i=0,15 do
					pal(i,3)
					spr((v.sp~=nil and anim(v.sp)or 20),dirs[d][1]+x,dirs[d][2]+y,11,s,0,0,w,h)
				end
			end
			pal()
			spr((v.sp~=nil and anim(v.sp)or 20),x,y,11,s,0,0,w,h)
			for i=1,#v.info do
				printb(v.info[i],x-3,8*i+y+28,3,false,1,true,1)
			end
			if #v.info > 0 then  rectb(x-6,y+34,51,68,3)end
			printc(v.name or "",120,15,3,false,1,false,1)
			printb(v.desc or "",pw,30,3,false,1,true,1)
			if v.desc ~= "" then rectb(67+sw,27,bw,95,3)	end
			printb(_.."/"..#beast,12,12,3,false,1,true)
		end
	end
	
	rectb(10,10,240-20,136-20,3)
	clip()
	printc((but and "B" or "L").." to back",120,136-8,3,false,1,false,1)
	if butnp("b")then bestiaryOn = false end
end

function Bullet(x,y,vx,vy)
	local s = {}
	s.name = "bullet"
	s.sp = nil
	s.f = 0
	s.x = x or 0
	s.y = y or 0
	s.vx = vx or 0
	s.vy = vy or 0
	s.w = 8
	s.h = 8
	s.size = 8
	s.startx = x or 0
	s.starty = y or 0
	s.range = 40
	s.dmg = 1
	s.collided = false
	s.animSpeed = 8
	
		function s.move(s)
		s.vx = vx
		s.vy = vy
		
		local x = s.x + s.vx
		local y = s.y + s.vy
		local w = s.w
		local h = s.h
		if 
			sol(x+1,y+((h/2)+1))or 
			sol(x+(w-1),y+((h/2)+1))or 
			sol(x+1,y+(h-1))or
			sol(x+(w-1),y+(h-1))then
			s:collide()
		end
		
		s.x = s.x + s.vx
		s.y = s.y + s.vy
	end
	
	function s.update(s)
		if s.collided then return end
		if s.vx ~= 0 then s.f = s.vx<0 and 0 or 1 end
		s:move()
		
		local dx,dy = p.x - s.x,p.y - s.y
		local dst = math.sqrt(dx^2+dy^2)
		if dst <= 8 then
			s:collide()
			if p.shield <= 0 then 
				p:damage(s.dmg)
				local oldx,oldy = p.x,p.y
				addParts({x = oldx,y = oldy,mode = 2,text = -s.dmg,vy = -0.5,vx = 0,c = 1,max = 40})
				addParts({x = p.x,y = p.y,c = 1,vx = math.cos(t),vy = math.sin(t)})
			else
				addParts({x = p.x,y = p.y,c = 2,vx = math.cos(t),vy = math.sin(t)})
			end
			s.hitpause = 40
		end
		
		local dx,dy = s.x - s.startx,s.y - s.starty
		if math.sqrt(dx^2+dy^2) > s.range then s:collide()end
	end
	
	function s.collide(s)
		if not s.collided then
			local oldx,oldy = s.x,s.y
			addParts({x=oldx,y=oldy,c=math.random(1,2),vy=-2,s=2,mode=4})
			addParts({x=oldx,y=oldy,c=math.random(1,2),vy=-2,s=2,mode=4})
			s.collided = true
		end
	end
	
	function s.draw(s)
		if not s.collided then
			if s.sp ~= nil then
				sprc(anim(s.sp,s.animSpeed),s.x,s.y,11,1,s.f)
			else
				circ(s.x-mx,s.y-my,s.size,2)
				circb(s.x-mx,s.y-my,s.size,1)
			end
		end
	end
	return s 
end

function spawnMobs()
	spawntiles = {
		-- Mobs
		[192] = Goblin,
		[193] = Bat,
		[194] = Skeleton,
		[195] = Cerberus,
		[196] = Hunter,
		[197] = forsakenGoblin,
		[198] = Boss,
		
		[160] = Wall(446),
		[161] = Wall(447),
		[128] = Wall(128),
		[162] = Wall(415),
		[244] = Door,
		[230] = safePoint,
		[156] = Bestiary,
		[129] = doorRoom("1-a","1-b","Boko's Store"), -- old door and next door
		[130] = doorRoom("1-b","1-a","Dungeon"),
		[131] = doorRoom("2-a","2-b","Zamon's Classroom"),
		[132] = doorRoom("2-b","2-a","Dungeon"),
		[133] = doorRoom("3-a","3-b","Zamon's library"),
		[134] = doorRoom("3-b","3-a","Dungeon"),
		[152] = doorRoom("!-a","!-b","Demon King's Room"),
		[153] = doorRoom("!-b","!-a"),
		
		-- Items
		[241] = Coin,
		[242] = coinExchange,
		[224] = Chest,
		[225] = Potion,
		[227] = multipleArrows,
		[228] = diamondArrow,
		[243] = Key,
		[229] = magicShield,
		[176] = potionShop,
		[177] = maShop,
		
		-- NPCs
		-- Scavenger
		[208] = NPC("Scavenger",208,{
			{"Hello handsome travele-...",
			"PRINCESS!!!! What are you doing here?",
			"Hum... hmm...",
			"so...",
			"you mean the knights who have been\nordered to rescue you so far won't arrive\nand you've decided to leave this dungeon\non your own?",
			"Hahahahahahahaha!",
			"this is a beautiful story",
			"Since you're here, I must warn you, there\nare monsters in front of this hallway,\njust be very careful with them."}
		},"npc"),		
		[210] = NPC("Boko The Seller",210,{
			{"Oh! Hello! Apparently it was a great idea\nto come to this dungeon to continue the\nfamily business!",
			"By the way my name is Boko, I'm the 6th\nsalesman of my family's generation.",
			"I learned everything I know from my\nfather...",
			"who learned from my grandfather...",
			"who learned from my great-grandfather...",
			"who learned from my\ngreat-great-grandfather...",
			"who also learned from my\ngreat-great-great-grandfather...",
			"and finally learned from my\ngreat-great-great-great-grandfather.",
			"Well... what will you want?",}
		},"npc"),		
		[211] = NPC("Efal",211,{
			{"Hi, my name is Efal",
			"I love reading books =)",
			"Let me tell you a story",
			"once a customer came here and \"buy\"\nsomething without paying, my dad hates\npeople who want their products for free",
			"So daddy used that sword on the wall and\nattacked the boy, never saw him again",
			"Never try to do this to him, always come\nback =).",}
		},"npc"),
		[212] = NPC("dummy",208,{{}},"dummy"),
		[213] = NPC("Zamon The Dungeon Historian",213,{
			{"Did you come to my class?",
			"No? No time? Okay...",
			"my name is Zamon, I study the\narchitecture, the items and even the\nbeasts of this dungeon!",
			"If you happen to\nfind one of my bookstores, try to be\ninterested in my research.",}
		},"npc"),
		
		-- Boards/notes etc
		-- Board 1
		[218] = NPC(nil,444,{
			{"Boko's new store opened today!!!",
			"come visit us!!",}
		},"board"),
		[216] = NPC(nil,460,{
			{"Welcome to Evil Dungeon, a dungeon with\nthe worst monsters in THE ENTIRE KINGDOM!\nPlease leave your note at the end of the\ndungeon, the Demon King thanks you."}
		},"board"),
		[217] = NPC(nil,461,{
			{"A-I-M-E-U-C-U"}
		},"board"),
	}
	for x = 0,240 do
		for y = 0,136 do
			local spawn = spawntiles[mget(x,y)]
			if spawn ~= nil then
				local mob = spawn(x*8,y*8)
				mob.spawnx = x
				mob.spawny = y
				mob.spawntile = mget(x,y)
				table.insert(mobs,mob)
				mset(x,y,mob.tile)
			end
		end
	end
end

button = {}

function buttonUpdate()
	button[1] = {
		{
			str = "New Game",
			desc = "Start your story!",
			on = function(s)
				trace("\n============ \nGAME\n============",4)
				newGame()
				_GAME.state = STATE_LOADING
			end
		},
		{
			str = "Load Game",
			desc = "Start your story!",
			on = function(s)
				trace("\n============ \nGAME\n============",4)
				if pmem(0)>0 then
					_GAME.state = STATE_LOADING
				end
			end
		},
		{
			str = "Options",
			desc = "",
			on = function(s)
				trace("\n============ \nOPTIONS\n============",4)
				Music()
				fade(-3)
				_GAME.state = STATE_OPTION
			end,
		},
		{
			str = "Credits",
			desc = "Thanks and tributes to\nprogrammers, without them\nand their respective games\nI would never have learned\ncertain mechanics that are\nbeing used in this game.",
			on = function(s)
				trace("\n============ \nCREDITS\n============",4)
				fade(-3)
				_GAME.state = STATE_CREDITS
			end,
		},
		{
			str = "Exit",
			desc = "Are you already going? :(",
			on = function(s)
				trace("\n============ \nEXIT\n============",4)
				exit()
				trace("Thankyou for playing =)",5)
			end
		},
	}

	if butnp("up") and menu_state > 1 then
		menu_state = menu_state - 1
	elseif butnp("down") and menu_state < #button[1] then
		menu_state = menu_state + 1
	end
		
	for i,s in ipairs(button[1])do
		if i == menu_state then
			printb(s.desc,90,78,2,false,1,false,1)
			local w = print(s.str,0,-6,12)
			if butnp("a")then
				s:on()
			end
				printb("<",w+4,8*i+70,3)
		end
		local w = print(s.str,0,-6,12)
		printb(s.str,1,8*i+70,3,false,1,false,1)
	end
end

function Hud()
	local x,y = 0,3
	for i=1,p.maxHp do
		spr(475,x,y,11)
		x = x + 9
		if x > 8 * 7 then x = 0;y = y + 8 end
	end
		
	if p.hit > 0 then
		for i=0,3 do pal(i,3)end
	end
		
	local x,y = 0,3
	for i=1,p.hp do
		spr(476,x,y,11)
		x = x + 9
		if x > 8 * 7 then x = 0;y = y + 8 end
	end
	
	rect(5+10,136-9,p.exp,8,3)
	spr(428,5+8,136-9,11,1)
	spr(428,5*24-11,136-9,11,1,1)
	for i = 1,11 do
		spr(429,8*i+(5+8),136-9,11,1)
	end
	printb("EXP",((13*9)//2),136-8,3,false,1,true,1)
	
	local cb,potx,keyx,monx = 0,8*8,5,210
	
	if mget(potx//8,0) == 0 or mget(keyx//8,11) == 0 then cb = 1 else cb = 2 end
	
	if p.potions > 0 then spr(225,8*8,0,11,1) printb(p.potions,8*8+2,8,3,false,1,true,cb)end
	if p.ma == True then spr(227,8*8,1,11,1) end
	if p.da == True then spr(228,8*10,1,11,1) end
	if p.shield > 0 then spr(229,8*11,1,11,1)end
	
	printb("$"..p.money,monx,136-7,3,false,1,false,cb)
	
	if p.keys > 0 then
		spr(510,keyx,136-9,11,1)
		spr(243,keyx,136-9,11,1)
		printb(p.keys,keyx+2,136-15,12,false,1,true,cb)
	end
	pal()
end

function showTextScreen(text)
	textScreen = text
	textScreenTimer = t
end

function showTextScreenUpdate()
	if t-textScreenTimer < 80 then
		textScreenY = 68
	else
		textScreenY = textScreenY - 2
	end
	local w = printc(textScreen,0,-6,2,false,1,false,cb)
	local tx,cb = 120,0
	if colT(tx,textScreenY,w,5,0) then
		cb = 1
	else
		cb = 0
	end
	printc(textScreen,tx,textScreenY,2,false,1,false,cb)
end

function lockRoom(l,u,r,d)
	for i=l,r do
		for j=u,d do
			if mget(i,j) == 18 then
				mset(i,j,17)
			end
		end
	end
end

function unlockRoom(l,u,r,d)
	for i=l,r do
		for j=u,d do
			if mget(i,j) == 17 then
				mset(i,j,18)
			end
		end
	end
end

function chooseInput()
	cls()
	printc("Choose your Input",120,10,2,false,1,false,1)
	local bx,kx = (240-48*2)//2,(240+48/2)//2
	spr(anim({316,318},16),bx,48,0,2,0,0,2,2)
	spr(anim({348,350},16),kx,48,0,2,0,0,2,2)
	printb("Gamepad",(240-48*2.2)//2,88,3,false,1,false,1)
	printb("Keyboard",(240+48//4)//2,88,3,false,1,false,1)
	
	local x,y,press = mouse()
	if col3(x,y,8,8,bx,48,32,32)then
		rectb(bx,50,32,32,3)
		if press then but = true _GAME.state = STATE_MENU end
	elseif col3(x,y,8,8,kx,48,32,32)then
		rectb(kx,50,32,32,3)
		if press then keyb = true _GAME.state = STATE_MENU end
	end
end

function menuUpdate()
	mx,my = p.x//240*240,p.y//136*136
	openingTimer = openingTimer - 1
	if openingTimer <= 0 then
		cls(0)
		
		Music(0,0,0,true)
		printc("Who will",120+(math.cos(t/6)*2)*2,28,2,false,2,false,1)
		printc("save",120+(math.sin(t/6)*2)*2,38,1,false,2)
		printc("the princess?",120+(math.cos(t/6)*2)*2,48,3,false,2,false,2)
		buttonUpdate()
		drawFade()
	else
		local w = print("-- @ATS_xp --",0,-6,12)
		clip(0,0,240,136)
		cls(0)
		spr(14,(240 - (16 * 4))//2,30,11,4,0,0,2,2)
		printb("-- @ATS_xp --",(240-w)//2,108,3,false,1,false,1)
		clip()
	end
end

local save = {}
function Save()
	trace("\n============ \nSAVED\n============",5)
	save.px,save.py = math.floor(p.x),math.floor(p.y)
	save.fx = math.floor(p.x) save.fy = math.floor(p.y)
	pmem(0,save.px)pmem(1,save.py)pmem(2,False)
	pmem(3,p.maxHp)pmem(4,save.fx)pmem(5,save.fy)
	pmem(6,p.exp)
	for i=#mobs,1,-1 do
		local m = mobs[i]
		if m~=p and m~=s and m.name ~= "fairy" and m.name ~= "door" and m.type ~= "item" then
			m:despawn()
			table.remove(mobs,i)
		end
	end
	enemyBullet = {}
	spawnMobs()
end

function Load()
	trace("\n============ \nLOADED\n============",2)
	fade(-1)
	bossBattle = false
	p.x = pmem(0)p.y = pmem(1)p.die = pmem(2)
	p.hp = pmem(3)f.x = pmem(4)+10 f.y = pmem(5)
	p.exp = pmem(6)-10
	for i=#mobs,1,-1 do
		local m = mobs[i]
		if m~=p and m~=s and m.name ~= "fairy" then
			m:despawn()
			table.remove(mobs,i)
		end
	end
	enemyBullet = {}
	spawnMobs()
end

function newGame()
	trace("\n============ \nSAVE RESTART\n============",5)
	fade(-1)
	for i=#mobs,1,-1 do
		local m = mobs[i]
		if m~=p and m~=s and m.name ~= "fairy" then
			m:despawn()
			table.remove(mobs,i)
		end
	end
	spawnMobs()
	bossBattle = false
	pmem(0,0)
	p.x,p.y = 26*8,77*8
	p.die = False
	p.hp = p.maxHp
end

function Music(track,loop)
	if not startMusic then
		music(track,-1,-1,loop)
		startMusic = true
	end
end

local loadAnim = {
	{274,275}, -- Fairy
	{307,308}, -- Goblin
	{321,322}, -- Bat
	{339,340}, -- Skeleton
	{356,357}, -- Cerberus
	{257,258}, -- Princess
}
local loadMsg = {
	{"Use the fairy to activate the runes to","restore yourself"},
	{"Are you in need of items?","Go to the Boko store!"},
	{"The runes that look like an X are runes used in rituals","to protect yourself from monsters, if you are running away from a","monster it will definitely be of great help."},
}
local indexLoadAnim = math.random(1,#loadAnim)
local indexLoadMsg = math.random(1,#loadMsg)
loadingTimer = math.random(100,500)
function Loading()
	cls()
	loadingTimer = loadingTimer - 1
	
	local dy = math.sin(t/8)*4
	local y = 21
	
	for i=0,3 do
		pal(i,3)
		for d=1,#dirs do
			spr(anim(loadAnim[indexLoadAnim],16),240-17+dirs[d][1],136-y+dy+dirs[d][2],11,2,1)
		end
	end
	pal()
	spr(anim(loadAnim[indexLoadAnim],16),240-17,136-y+dy,11,2,1)
	
	for i=1,#loadMsg[indexLoadMsg] do
		printc(loadMsg[indexLoadMsg][i],120,8*i+90,3,false,1,true,1)
	end
	--print(indexLoadMsg,10,10,3)
	
	if loadingTimer < 0 then
		if pmem(0)>0 then
			Load()
			_GAME.state = STATE_GAME
		else
			_GAME.state = STATE_GAME
		end
		showTextScreen("Dungeon")
		music()
	end
end

function Event()
	if p.x >= 211 and p.y > 104*8 then
		lockRoom(224,102,226,102)
		bossBattle = true
	elseif	bossBattle == false then
		unlockRoom(224,102,226,102)
	end
end

function gameUpdate()
	if global_hitpause > 0 then
		global_hitpause = global_hitpause - 1
	else
		for _,m in ipairs(mobs)do
			m:update()
		end
		for _,b in ipairs(enemyBullet)do
			b:update()
		end
		bulletUpdate()
		updateParts()
	end
	
	if textOn then
		for c=1,3 do
			pal(c,c-1)
		end
	end
	
	cls()
	map(mx//8,my//8,31,18,-(mx%8),-(my%8),0)
	
	table.sort(mobs,layer)
	
	for _,m in ipairs(mobs)do
		if textOn then
			for c=1,3 do
				pal(c,c-1)
			end
		end
		m:draw()
	end
	
	for _,b in ipairs(enemyBullet)do
		b:draw()
	end
	
	drawParts()
	bulletDraw()
	Hud()
	updateDialog()
	drawFade()
	showTextScreenUpdate()
	gameOver()
	if bestiaryOn then
		bestiaryUpdate()
	end
	Event()
end

function optionUpdate()
	cls()
	button[2] = {
		{
			str = "Input: ",
			desc = but == false and "keyboard" or "gamepad",
			on = function(s)
				trace("\n============ \nINPUT EXCHANGEDT\n============",4)
				keyb = not keyb
				but = not but
			end,
		},
	}
	
	if #rec <= 0 then
		if butnp("up") and option_state > 1 then
			option_state = option_state - 1
		elseif butnp("down") and option_state < #button[2] then
			option_state = option_state + 1
		end
		if butnp("b") then _GAME.state = STATE_MENU fade(-3)end
	end
		
	for i,s in ipairs(button[2])do
		if i == option_state then
			local w = print(s.str..s.desc,0,-6,12)
			--printb(s.desc,11,8*i+10,2,false,1,false,1)
			if butnp("a")then
				s:on()
			end
				printb("<",w+4,8*i+10,3)
		end
		local w = print(s.str,0,-6,12)
		printb(s.str..s.desc,1,8*i+10,3,false,1,false,1)
		printb((but and "B" or "L").." to back",1,136-8,3,false,1,false,1)
	end
	drawFade()
end

local gy,by,b = -16,-136-8,0
function gameOver()
	local str,str2 = "You die","Press Z to restart"
	if p.hp <= 0 then
		pal()
		textOn = true
		gy = gy + (gy<60 and 1 or 0)
		local w = printb(str,0,-16,3,false,2,false,1)
		spr(380,(240-(16*4))//2,11,11,4,0,0,2,2)
		spr(382,(240-32)//2,25,11,2,0,0,2,2)
		printc(str,120,gy,3,false,2,false)
		printc(gy == 60 and str2 or "",120,80,2)
		rect(0,by,240,136,0)
		for i=0,29 do
			spr(65,8*i,by+136,11,1)
		end
		by = by + b
		
		if butnp("a") and gy == 60 then
			b = 2
		end
		if by > - 1 then
			if pmem(0) > 0 then Load()
			else newGame()end
			gy,by,b = -16,-136,0
		end
	end
end

function Debug()
	text_debug = {
		[1] = {
			{str = "X: "..math.floor(p.x)},
			{str = "Y: "..math.floor(p.y)},
			{str = "Hp: "..p.hp},
			{str = "Speed: "..p.speed},
			{str = "bTimer: "..bullet_timer},
			{str = "MapX: "..mx},
			{str = "MapY: "..my},
			{str = "Bullets: "..#bullet},
			{str = "Particles: "..#parts},
			{str = "Ents: "..#mobs},
		},
	}
	if _GAME.on then
		for i=1,#text_debug[1] do
			printb(text_debug[1][i].str,0,8*i+5,9,false,1,true)
		end
	end
end

function Credits()
	for c=1,3 do
		pal(c,c-1)
	end
	cls()
	map(mx//8,my//8,31,18,-(mx%8),-(my%8))
	mx,my = math.cos(t/180)*(240/2)+((240*4)-116),math.sin(t/180)*(136/2)+((136*4)-80)
	for _,m in ipairs(mobs)do
		for c=1,3 do
			pal(c,c-1)
		end
		if m.name ~= "princess" and m.name ~= "fairy" then
			m:update()
			m:draw()
		end 
	end
	
	local credit = {
		"-- Creator - Game - twitter --",
		"",
		"petet - Balmung",
		"Trelemar - Amrogue/Bare Bones - @trelemar",
		"Borb - EMUUROM/Moving in with friends - @borbware",
		"Wolfy CyberWare - - @WCyberware",
		"MFauzan - Antvania/Steel War/The Greedy Hero - @MFauzan80",
		"Dan - Desarmonia (it's not an TIC game) - @ikigaidan_",
		"Deck - QUEST FOR GLORY -",
		"",
		"Nesbox - TIC-80 =)",
	}
	for i=1,#credit do
		printc(credit[i],120,8*i,3,false,1,true,1)
	end
	printb((but and "B" or "L").." to back",1,136-8,3,false,1,false,1)
	
	if butnp("b") and #rec <= 0 then _GAME.state = STATE_MENU fade(-3)end
	Debug()
	drawFade()
end

function init()
	STATE_INPUT = - 1
	STATE_MENU = 0
	STATE_GAME = 1
	STATE_LOADING = 2
	STATE_OPTION = 3
	STATE_CREDITS = 4
	startMusic = false
	bestiaryOn = false
	bossBattle = false
	bossDead = false
	openingTimer = 100
	loadingTimer = math.random(100,500)
	
	global_hitpause = 0
	parts = {}
	mobs = {}
	rec = {}
	
	p = Player(26*8,77*8)
	table.insert(mobs,p)
	f = Fairy(5*8,77*8)
	table.insert(mobs,f)
	bullet = {}
	bmax_timer = 30
	bullet_timer = bmax_timer
	bChange = false
	bvx,bvy = 2,0
	bf,br = 0,0
	enemyBullet = {}
	
	textScreen = ""
	textScreenTimer = -80
	textScreenY = 68
	
	dialog = {}
	dialog_color = 12
	dialog_pos = 1
	dialog_spr = 20
	dialog_name = nil
	text_pos = 1
	dix,diy = 0,60
	
	menu_state = 1
	option_state = 1
	beast_state = 1
	timerText = 0
	
	mx,my = p.x//240*240,p.y//136*136
	spawnMobs()
end
init()
function TIC()
	if _GAME.state == STATE_INPUT then
		chooseInput()
	elseif _GAME.state == STATE_MENU then
		menuUpdate()
	elseif _GAME.state == STATE_OPTION then
		optionUpdate()
	elseif _GAME.state == STATE_LOADING then
		Loading()
	elseif _GAME.state == STATE_GAME then
		gameUpdate()
		Debug()
	elseif _GAME.state == STATE_CREDITS then
		Credits()
	end
	if _GAME.fps then
		FPS:drw()
	end
	FPS:upd()
	t=t+1
end
