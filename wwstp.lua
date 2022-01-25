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
_GAME.state =	1

local exp = math.random(1,10)

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

SOLID = set{1,2,3,4,5,17,19,21,29,34,35,36,37,44,45,46,47,
60,61,62,63,72,73,74,75,76,77,78,79,92,93,94,95,108,109,
110,111,124,125,126,127,140,141,142,143}

function anim(f,s)local f,s = f or {},s or 8;return f[((t//s)%#f)+1] end

function sol(x,y)
	for _,m in ipairs(mobs)do
		local hit = col(x,y,0,0,m.x,m.y,m.w,m.h)
		if m.collide and hit then return true end
	end
	return SOLID:contains(mget(x//8,y//8))
end

function sprc(id,x,y,c,s,f,r,w,h)
	local x = x or 0
	local y = y or 0
	local c = c or -1
	local s = s or 1
	local f = f or 0
	local r = r or 0
	local w = w or 1
	local h = h or 1
	spr(id,x-mx,y-my,c,s,f,r,w,h)
end

function printb(text,x,y,c,fix,s,sm,cb)
	local fix,s,sm,cb = fix or false,s or 1,sm or false,cb or 0
	print(text,x-1,y,cb,fix,s,sm)
	print(text,x+1,y,cb,fix,s,sm)
	print(text,x,y-1,cb,fix,s,sm)
	print(text,x,y+1,cb,fix,s,sm)
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

function layer(a,b)
	if a.y == b.y then return b.x < a.x end
	return a.y < b.y
end

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
		spr(503,8 * i + dix,diy,11,1)
		spr(503,8 * i + dix,diy + 68 - 8,11,1,0,2)
	end
	for i = 1,(17 / 2) - 1 do
		spr(503,dix,8 * i + diy,11,1,1,1)
		spr(503,dix + 240 - 8,8 * i + diy,11,1,0,1)
	end
	for i = 1,16 do
		spr(504,16 * i + dix,diy,11,1)
		spr(504,16 * i + dix,diy + 68 - 8,11,1,0,2)
	end
	for i = 1,(17 / 2) - 5 do
		spr(504,dix,16 * i + diy,11,1,1,1)
		spr(504,dix + 240 - 8,16 * i + diy,11,1,0,1)
	end
	
	spr(502,dix,diy,11,1)
	spr(502,dix + 240 - 8,diy,11,1,1)
	spr(502,dix,diy + 68 - 8,11,1,1,2)
	spr(502,dix + 240 - 8,diy + 68 - 8,11,1,2,1)
	
	if dialog_name ~= nil then
		-- icon
		for i = 0,15 do
			pal(i,3)
			spr(dialog_spr,(dix + 2) - 1,diy + (diy == 68 and - 33 or (8 * 8) + 5),11,4)
			spr(dialog_spr,(dix + 2) + 1,diy + (diy == 68 and - 33 or (8 * 8) + 5),11,4)
			spr(dialog_spr,(dix + 2),diy + (diy == 68 and - 33 or (8 * 8) + 5) - 1,11,4)
			spr(dialog_spr,(dix + 2),diy + (diy == 68 and - 33 or (8 * 8) + 5) + 1,11,4)
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
		
		if btnp(4) and text_pos >= 2 then
			if text_pos < len then
				text_pos = len
			else
				text_pos = 1
				dialog_pos = dialog_pos + 1
			end
		end
		
		if dialog_pos <= #dialog then
			drawTextBox()
			printb(string.sub(str,1,text_pos),dix + 10,diy + 10,dialog_color,false,1,false,2)
			spr(anim({507,508},24),dix + 240 - 24,diy + 68 - 22,11,2)
			global_hitpause = 1
			if text_pos < len and t % 4 == 0 then text_pos = text_pos + 1 end
		end
	else
		dialog_pos = 1
		dialog = nil
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
		
		
		if f.z < 0 and f.x + 128 < 0 then table.remove(rec,i)music()
		elseif f.z > 0 and f.x + 128 > 120 then table.remove(rec,i)music()
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
function addParts(tbl)table.insert(parts,tbl)end
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
		
		if v.t > (v.max or 20) then table.remove(parts,i) end
	end
end

function bulletDraw()
	for _,v in ipairs(bullet)do
		if bChange then
			sprc(273,v.x,v.y,11,1,v.f,v.r)
		end
		if not bChange then
			sprc(272,v.x,v.y,11,1,v.f,v.r)
		end
	end	
end

function bulletUpdate()
	for i,v in ipairs(bullet)do
		local x = v.x + v.vx
		local y = v.y + v.vy
		local w = v.w
		local h = v.h
		if 
			sol(x,y +(h / 2 + 1))or 
			sol(x + (w - 1),y + (h / 2 + 1))or 
			sol(x,y + (h - 1))or
			sol(x + (w - 1),y + (h - 1))then
			local Oldx,Oldy = v.x,v.y
			addParts({x = Oldx,y = Oldy,s = math.random(2,5),c = math.random(0,2),vx = math.random(-1,1),vy = math.random(-1,1)})
			addParts({mode = 4,x = Oldx,y = Oldy,s = math.random(2,5),c = math.random(0,2),vx = math.random(-1,1),vy = math.random(-1,1)})
			addParts({x = Oldx,y = Oldy,c = 1,vy = 1,w = math.random(1,4),h = math.random(1,4)})
			table.remove(bullet,i)
		end
		
		if v.vy < 0 then v.r = 3 -- up
		elseif v.vy > 0 then v.r = 1 end -- down
		if v.vx < 0 then v.f = 1 v.r = 0 -- left
		elseif v.vx > 0 then v.f = 0 v.r = 0 end -- right
		if v.vy > 0 and v.vx < 0 and bChange then v.r = 1 end -- down/left
		if v.vy > 0 and v.vx > 0 and bChange then v.r = 1 end -- down/right
		
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
	s.spawntile = s.spawntile or 16
	s.anims = {}
	s.die = false
	s.collide = false
	s.atk = false
	s.vanish = 0
	s.timer = 0
	s.hit = 0
	s.dmg = 0
	s.hitpause = 0
	s.range = 0
	s.fov = 12
	s.x = x or 0
	s.y = y or 0
	s.w = 8
	s.h = 8
	s.vx = 0
	s.vy = 0
	s.speed = 0.4
	s.f = 0
	s.c = - 1
	
	function s.seePlayer(s,x1,y1)
		local dx = x1 - s.x
		local dy = y1 - s.y
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
	end
	
	function s.move(s,dx,dy)
		s.vx = dx
		s.vy = dy
		
		local x = s.x + s.vx
		local y = s.y + s.vy
		local w = s.w
		local h = s.h
		if 
			sol(x+1,y+((h/2)+1))or 
			sol(x+(w-1),y+((h/2)+1))or 
			sol(x+1,y+(h-1))or
			sol(x+(w-1),y+(h-1))then
			s.vx,s.vy = 0,0
		end
		
		s.x = s.x + s.vx
		s.y = s.y + s.vy
	end
	
	function s.damage(s,amount)
		if not s.die then
			s.hit = 5
			local amt = amount or 1
			s.hp = s.hp - amt
		end
	end
	
	function s.attack(s)
		if not s.atk and not s.die then
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
	
	function s.update(s)
		if s.type == "enemy" then
		
			if s.die then s.vanish = s.vanish + 1 end
			if s.vanish > 100 then s.timer = s.timer + 1 end
			
			if s.die then return end
			
			if s.vx ~= 0 then s.f = s.vx < 0 and 1 or 0 end
			
			if s.hit > 0 then s.hit = s.hit - 1 end
			if s.hitpause <= 0 then s.atk = false end
			
			local dst = math.sqrt(((p.x-s.x)^2+(p.y-s.y)^2))
			if dst <= s.fov then
				if p.x > s.x then s.f = 0 else s.f = 1 end
				if t > s.t then
					s:attack()
					s.t = t + math.random(30,90)
				end
			else
				s.t = t + math.random(0,90)
			end
			
			for _,v in ipairs(bullet)do
				if col(v.x,v.y,v.w,v.h,s.x,s.y,s.w,s.h) then
					s:damage(p.dmg)
					table.remove(bullet,_)
					addParts({x = s.x,y = s.y,c = 2,vx = math.cos(t),vy = math.sin(t)})
					local oldx,oldy = s.x,s.y
					addParts({x = oldx,y = oldy,mode = 2,text = -p.dmg,vy = -0.5,vx = 0,c = 2,max = 40})
				end
			end
			
			if s.vx ~= 0 or s.vy ~= 0 then s.sp = anim(s.anims.walk)
			elseif s.vx == 0 and s.vy == 0 then  s.sp = anim(s.anims.idle) end
			if s.hp <= 0 then s.die = true s.sp = anim(s.anims.die) s.hit = 0
			elseif s.atk then s.sp = anim(s.anims.atk,16)end
			
			if colT(s.x,s.y,s.w,s.h,49) then s.die = true end
			
			if s.die then
				s.sp = anim(s.anims.die)
				for i=0,4 do
					addParts({x = 2*i+s.x,y = s.y,c = 1,vy = - math.random(1,2)/2})
				end
				table.insert(mobs,chest_item[1][math.random(1,3)](s.x,s.y+4))
				table.insert(mobs,Exp(s.x,s.y))
			end
			
		end
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
		end
		pal()
	end
	return s
end

function Goblin(x,y)
	local s = Mob(x,y)
	s.type = "enemy"
	s.name = "goblin"
	s.sp = 304
	s.hp = 15
	s.c = 11
	s.anims = {
		walk = {305,306},
		idle = {304},
		die = {309},
		atk = {307,308}
	}
	s.dmg = math.random(1,2)
	s.range = 50
	s.speed = 0.5
	s.supUpdate = s.update
	
	function s.update(s)
		s:supUpdate()
		if not s.die then			
			s:seePlayer(p.x,p.y)
			s.dmg = math.random(1,2)
		end
	end
	
	return s
end

function Bat(x,y)
	local s = Mob(x,y)
	s.type = "enemy"
	s.name = "bat"
	s.sp = 320
	s.c = 11
	s.dy = 0
	s.anims = {
		idle = {320,321},
		walk = {320,321},
		die = {323},
		atk = {322},
	}
	s.hp = math.random(5,8)
	s.range = 60
	s.speed = 0.5
	s.dmg = 1
	s.supUpdate = s.update
	
	function s.update(s)
		s:supUpdate()	
		if not s.die then			
			s:seePlayer(p.x,p.y)
			s.dy = math.sin(t/8)*2
		end
	end
	
	function s.draw(s)
		if s.hit > 0 then
			for i=0,15 do
				pal(i,12)
			end
		end
		if s.timer < 105 and (s.timer//3)%2 == 0 then
			if not s.die then
				sprc(271,s.x,s.y+3,0,1)
			end
			sprc(s.sp,s.x,s.y-4 + (s.die and 0 or (s.atk and 0 or s.dy)),s.c,1,s.f)
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
	s.c = 11
	s.anims = {
		idle = {336},
		walk = {337,338},
		atk = {339,340},
		die = {341},
	}
	s.hp = 20
	s.speed = 0.3
	s.range = 20
	s.dmg = 4
	s.supUpdate = s.update
	
	function s.update(s)
		s:supUpdate()	
		if not s.die then			
			s:seePlayer(p.x,p.y)
		end
	end
	
	return s
end

function Cerberus(x,y)
	local s = Mob(x,y)
	s.type = "enemy"
	s.name = "cerberus"
	s.sp = 352
	s.c = 11
	s.anims = {
		idle = {352,353},
		walk = {354,355},
		atk = {356,357},
		die = {358},
	}
	s.hp = 10
	s.range = 80
	s.speed = 1
	s.dmg = math.random(1,3)
	s.supUpdate = s.update
	
	function s.update(s)
		s:supUpdate()
		if not s.die then			
			s:seePlayer(p.x,p.y)
			s.dmg = math.random(1,3)
		end
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
	s.boost = 0
	s.ma = 0 -- "Multiplied Arrows" Power Up
	s.da = 0 -- "Diamond Arrows" Power Up
	s.shield = 0
	s.sp = 256
	s.c = 11
	s.f = 1
	s.dmgExtra = 0
	s.dmg = 1 + s.dmgExtra
	s.speed = 0.9
	s.supMove = s.move
	
	function s.move(s,dx,dy)
		s:supMove(dx,dy)		
		if s.vx ~= 0 then s.f = s.vx<0 and 1 or 0 end
	end
	
	function s.cam(s)
		local x,y = s.x//240*240,s.y//136*136
		if x ~= mx or y ~= my then
			mx = x
			my = y
		end
	end
	
	function s.anim(s)
		if s.vx ~= 0 or s.vy ~= 0 then s.sp = s.anims.walk  
		elseif btn(6) then s.sp = s.anims.atk 
		else s.sp = s.anims.idle end
	end
	
	function s.onPotion(s)
		if not s.die and s.hp < s.maxHp  and s.potions > 0 then
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
		end
	end
	
	function s.update(s)
		if s.hp <= 0 then s.sp = s.anims.die end
		if s.die then return end
		s.vx = 0
		s.vy = 0
		bullet_timer = bullet_timer - 1
		if s.hit > 0 then s.hit = s.hit - 1 end
		if s.shield > 0 then s.shield = s.shield - 1 end
		if s.ma > 0 then bmax_timer = 10 end
		if s.da > 0 then s.dmg = math.random(2+s.dmgExtra,5+s.dmgExtra) 
		else s.dmg = math.random(1+s.dmgExtra,2+s.dmgExtra)end
		if s.boost > 0 then s.boost = s.boost - 1 s.speed = 1.6
		else s.speed = 0.9 end
		
		s.anims.walk = anim({257,258})
		s.anims.atk = anim({259,260},16)
		s.anims.idle = 256
		s.anims.die = 261
		
		if btn(0)then s:move(0,- s.speed) bvx,bvy = 0,- 2 bChange = false end -- up
		if btn(1)then s:move(0,s.speed) bvx,bvy = 0,2 bChange = false end -- down
		if btn(2)then s:move(- s.speed,0) bvx,bvy = -2,0 bChange = false end -- left 
		if btn(3)then s:move(s.speed,0) bvx,bvy = 2,0 bChange = false end -- right
		if btn(0) and btn(2)then bvx,bvy = - 2,- 2 bChange = true end -- up/left
		if btn(0) and btn(3)then bvx,bvy = 2,- 2 bChange = true end -- up/right
		if btn(1) and btn(2)then bvx,bvy = - 2,2 bChange = true end -- down/left
		if btn(1) and btn(3)then bvx,bvy = 2,2 bChange = true end -- down/right
		if btnp(4)then Interact(s) end -- interacts with NPCs
		if btnp(5)then s:onPotion()end -- Use Potion
		if btn(6) and bullet_timer < 0 then  -- shoot
			bullet_timer = bmax_timer
			table.insert(bullet,{sp = 272,x = s.x,y = s.y,vx = bvx*2,vy = bvy*2,f = bf,r = br,w = 8,h = 8})
		end
		if s.hp <= 0 then s.die = true s.hit = 0 end
		
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
	end
	return s
end

function Fairy(x,y)
	local s = Mob(x,y)
	s.type = "friend"
	s.name = "fairy"
	s.sp = 274
	s.c = 11
	s.speed = 0.9
	s.fov = 23
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
	s.spawntile = 50
	
	function s.update(s)
		if col2(s,p)and btnp(4)then
			if p.hp < p.maxHp then
				p.hp = p.maxHp
				addDialog({"You have been restored"})
			else
				addDialog({"You don't need to be restored"})
			end
		end
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
		s.c = 11
		s.sp =  sp
		s.dpos = 0
		s.dcolor = 0
		s.over = not type == "npc"
		s.collide = true
		s.spawntile = spawn or 16
		
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
				s.collide = true
			else
				s.collide = false
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
	s.pickUp = false
	s.collide = false
	s.t = 0
	s.timer = 0
	s.c = - 1
	s.dy = 0
	s.fov = 0
	s.range = 50
	
	function s.update(s)
		if s.pickUp then return end
		
		if s.name ~= "chest" then 
		s.dy = math.cos(t/16)*2 end
		
		s.timer = s.timer + 1
		
		if col2(p,s)then
			s:onPickUp()
			s.pickUp = true
		else
			if s.timer > 40 then
				s.t = s.t + 1
			end
		end
		
		
	end

	function s.draw(s)
		if not s.pickUp then
			sprc(271,s.x,s.y+2,0,1)
			sprc(s.sp,s.x,s.y+s.dy,s.c,1)
		end
	end
	return s
end

function Coin(x,y)
	local s = Item(x,y)
	s.name = "coin"
	s.sp = 241
	s.c = 11
	s.supUpdate = s.update
	
	function s.onPickUp(s)
		local rnd = math.random(5,10)
		p.money = p.money + rnd
		addParts({text = "+"..rnd,x = s.x,y = s.y,mode = 2,c = 3,small = true})
	end
	
	function s.update(s)
		if s.pickUp then return end
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
	s.c = 11
	
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
	s.c = 11
	
	function s.onPickUp(s)
		p.potions = p.potions + 1
		addDialog({"You got a POTION!"})
	end
	return s
end

function Boost(x,y)
	local s = Item(x,y)
	s.name = "boost"
	s.sp = 226
	s.c = 11
	
	function s.onPickUp(s)
		addDialog({"You got a \"Boost\"","You can run faster for a limited time."})
		p.boost = 500
	end
	return s
end

function diamondArrow(x,y)
	local s = Item(x,y)
	s.name = "da"
	s.sp = 228
	s.c = 11
	
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
	s.c = 11
	
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
	s.c = 11
	
	function s.onPickUp(s)
		addDialog({"You got \"Magic Shield\""})
		p.shield = 500
	end
	return s
end

chest_item = {
	-- 1, 2,           3,   4,    5,          6,  7,
	{Coin,coinExchange,Coin,Boost,magicShield,Bat,Potion},
	-- 1, 2, 3,  4,  5,  6,                    7,
	{nil,nil,nil,nil,nil,"Watch out! A bat!!!",nil}
}

function Chest(x,y)
	local s = Item(x,y)
	s.name = "chest"
	s.sp = 224
	s.collide = true
	s.c = 11
	s.open = false
	function s.update(s)
		if s.open then return end	
		for _,m in ipairs(mobs)do if m.type == "enemy" and col2(m,s)then s.collide = false else s.collide = true end end	
		for _,v in ipairs(bullet)do
			if col(v.x-1,v.y,v.w+2,v.h,s.x-2,s.y,s.w+4,s.h+2)then
				s.open = true
				local id = math.random(1,#chest_item[1])
				table.insert(mobs,chest_item[1][id](s.x,s.y+2))
				addDialog({chest_item[2][id]})
			end
		end
		
	end
	
	function s.draw(s)
		sprc(271,s.x,s.y,0,1)
		if not s.open then sprc(s.sp,s.x,s.y,s.c,1)
		else sprc(240,s.x,s.y,s.c,1)end
		--rectb(s.x-mx-2,s.y-my,s.w+4,s.h+2,12)
	end
	return s
end

function Key(x,y)
	local s = Item(x,y)
	s.name = "key"
	s.sp = 243
	s.c = 11
	
	function s.onPickUp(s)
		addDialog({"You found a key!"})
		p.keys = p.keys + 1
	end
	return s
end

function Exp(x,y)
	local s = Item(x,y)
	s.name = "exp"
	s.sp = 246
	s.c = 11
	s.speed = 1.5
	s.supUpdate = s.update
	
	function s.onPickUp(s)
		p.exp = p.exp + exp
		
		local oldx,oldy = s.x,s.y
		addParts({x = oldx,y = oldy,c = 3,mode = 2,vy = - 0.5,text = "+"..exp.." exp"})
	end
	
	function s.update(s)
		if s.pickUp then return end
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
	s.collide = true
	s.open = false
	s.c = 11
	s.spawntile = 16
	
	function s.onInteract(s)
		if btnp(4)and p.keys > 0 and s.open == false then
			addDialog({"Unlocked"})
			s.open = true
			p.keys = p.keys - 1
		else
			if not s.open then
				addDialog({"Locked"})
			end
		end
		
		if s.open == true then
			s.collide = false
		end
	end
	function s.draw(s)
		if not s.open then
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
		s.c = 11
		s.sp = 443
		s.spawntile = 1
		textScreen = textScreen or ""
		s.enter = false
		
		function s.update(s)
			if btnp(4)and col2(p,s) then
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
	s.c = 11
	s.collide = true
	s.price = 100
	s.dy = 0
	
	function s.update(s)
		if btnp(4)and col2(s,p) then
			if type(s.price) == "number" then
				if p.money >= s.price then
					p.money = p.money - s.price
					s.price = s.price * 2
					s:buy()
				else
					addDialog({"You don't have enough coins"})
				end
			end
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
	s.spawntile = 29
	
	function s.buy(s)
		p.potions = p.potions + 1
		addDialog({"You bought a POTION!"})
	end
	return s
end

function maShop(x,y)
	local s = Shop(x,y)
	s.name = "maShop"
	s.sp = 227
	s.price = 100
	s.spawntile = 29
	
	function s.buy(s)
		p.ma = 1
		s.price = "sold"
		addDialog({"You bought a \"Multiplied Arrows!\"","Now you can shoot more arrows than\nbefore!!"})
	end
	return s
end

function Wall(sp)
	local function func(x,y)
		local s = Mob(x,y)
		s.type = "tile"
		s.name = "wall"
		s.collide = true
		s.sp = sp
		s.c = 11
		
		function s.draw(s)
			if s.sp == 446 then s.collide = false else s.collide = true end
			if s.sp == 128 then s.c = 11 end
			sprc(s.sp,s.x,s.y-8,s.c,1,0,0,1,2)
		end
		return s
	end
	return func
end

local spawntiles = {}
function spawnMobs()
	-- Mobs
	spawntiles[192] = Goblin
	spawntiles[193] = Bat
	spawntiles[194] = Skeleton
	spawntiles[195] = Cerberus
	spawntiles[209] = Fairy
	
	spawntiles[160] = Wall(446)
	spawntiles[161] = Wall(447)
	spawntiles[128] = Wall(128)
	spawntiles[244] = Door
	spawntiles[230] = safePoint
	spawntiles[232] = doorRoom("1-a","1-b","Boko's Store") -- old door and next door
	spawntiles[233] = doorRoom("1-b","1-a","Dungeon")
	spawntiles[234] = doorRoom("2-a","2-b","Zamon's Classroom")
	spawntiles[235] = doorRoom("2-b","2-a","Dungeon")
	spawntiles[248] = doorRoom("!-a","!-b")
	spawntiles[249] = doorRoom("!-b","!-a")
	
	-- Items
	spawntiles[241] = Coin
	spawntiles[242] = coinExchange
	spawntiles[224] = Chest
	spawntiles[225] = Potion
	spawntiles[226] = Boost
	spawntiles[227] = multipleArrows
	spawntiles[228] = diamondArrow
	spawntiles[243] = Key
	spawntiles[229] = magicShield
	spawntiles[176] = potionShop
	spawntiles[177] = maShop
	
	-- NPCs
	-- Scavenger
	spawntiles[208] = NPC("Scavenger",208,{
		{"Hello handsome travele-...",
		"PRINCESS!!!! What are you doing here?",
		"Hum... hmm...",
		"so...",
		"you mean the knights who have been\nordered to rescue you so far won't arrive\nand you've decided to leave this dungeon\non your own?",
		"Hahahahahahahaha!",
		"this is a beautiful story",
		"Since you're here, I must warn you, there\nare monsters in front of this hallway,\njust be very careful with them."}
	},"npc")
	
	spawntiles[210] = NPC("Boko The Seller",210,{
		{"Oh! Hello! Apparently it was a great idea\nto come to this dungeon to continue the\nfamily business!",
		"By the way my name is Boko, I'm the 6th\nsalesman of my family's generation.",
		"I learned everything I know from my\nfather...",
		"who learned from my grandfather...",
		"who learned from my great-grandfather...",
		"who learned from my\ngreat-great-grandfather...",
		"who also learned from my\ngreat-great-great-grandfather...",
		"and finally learned from my\ngreat-great-great-great-grandfather.",
		"Well... what will you want?",}
	},"npc")
	
	spawntiles[211] = NPC("Efal",211,{
		{"Hi, my name is Efal",
		"I love reading books =)",
		"Let me tell you a story",
		"once a customer came here and \"buy\"\nsomething without paying, my dad hates\npeople who want their products for free",
		"So daddy used that sword on the wall and\nattacked the boy, never saw him again",
		"Never try to do this to him, always come\nback =).",}
	},"npc")
	
	spawntiles[212] = NPC("dummy",208,{{}},"dummy")
	
	spawntiles[213] = NPC("Zamon The Dungeon Historian",213,{
		{"Did you come to my class?",
		"No? No time? Okay...",
		"my name is Zamon, I study the\narchitecture, the items and even the\nbeasts of this dungeon!",
		"If you happen to\nfind one of my bookstores, try to be\ninterested in my research.",}
	},"npc")
	
	-- Boards/notes etc
	-- Board 1
	spawntiles[218] = NPC(nil,444,{
		{"Boko's new store opened today!!!",
		"come visit us!!",}
	},"board")
	
	spawntiles[216] = NPC(nil,460,{
		{"Welcome to Evil Dungeon, a dungeon with\nthe worst monsters in THE ENTIRE KINGDOM!\nPlease leave your note at the end of the\ndungeon, the Demon King thanks you."}
	},"board")
	
	spawntiles[217] = NPC(nil,461,{
		{"A-I-M-E-U-C-U"}
	},"board")

	for x = 0,240 do
		for y = 0,136 do
			local spawn = spawntiles[mget(x,y)]
			if spawn ~= nil then
				local mob = spawn(x*8,y*8)
				table.insert(mobs,mob)
				mset(x,y,mob.spawntile)
			end
		end
	end
end

function buttonUpdate()
	if btnp(0) and menu_state > 1 then
			menu_state = menu_state - 1
		elseif btnp(1) and menu_state < #butn then
			menu_state = menu_state + 1
		end
		
	for i,s in ipairs(butn)do
		if s.id == menu_state then
			local w = print(s.str,0,-6,12)
			if btnp(4) then
				s:on()
			end
				printb("<",w+4,8*i+70,3)
		end
		local w = print(s.str,0,-6,12)
		printb(s.str,0,8*i+70,3,false,1,false,1)
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
	pal()
	
	rect(5+10,136-9,p.exp,8,3)
	spr(505,5+8,136-9,11,1)
	spr(505,5*24-11,136-9,11,1,1)
	for i = 1,11 do
		spr(506,8*i+(5+8),136-9,11,1)
	end
	printb("EXP",((13*9)//2),136-8,3,false,1,true,1)
	
	local cb,potx,keyx,monx = 0,8*8,5,210
	
	if mget(potx//8,0) == 0 or mget(keyx//8,11) == 0 then cb = 1 else cb = 2 end
	
	if p.potions > 0 then spr(225,8*8,0,11,1) printb(p.potions,8*8+2,8,3,false,1,true,cb)end
	if p.boost > 0 then spr(226,8*9,0,11,1) end
	if p.ma > 0 then spr(227,8*10,1,11,1) end
	if p.da > 0 then spr(228,8*11,1,11,1) end
	if p.shield > 0 then spr(229,8*12,1,11,1)end
	
	printb("$"..p.money,monx,136-7,3,false,1,false,cb)
	
	if p.keys > 0 then
		spr(510,keyx,136-9,11,1)
		spr(243,keyx,136-9,11,1)
		printb(p.keys,keyx+2,136-15,12,false,1,true,cb)
	end
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
	local tx,cb = 120,0
	if mget(tx//8,textScreenY//8) == 0 then
		cb = 1
	else
		cb = 0
	end
	printc(textScreen,tx,textScreenY,2,false,1,false,cb)
end

function menuUpdate()
	if time()>3000 then
		cls(0)
		
		Music(0,true)
		printc("Who will",120+(math.cos(t/6)*2)*2,28,2,false,2)
		printc("save",120+(math.sin(t/6)*2)*2,38,1,false,2)
		printc("the princess?",120+(math.cos(t/6)*2)*2,48,3,false,2)
		
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
	"Use the fairy to activate the runes to\nrestore yourself",
	"Are you in need of items?  Go to the Boko store!",
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
		spr(anim(loadAnim[indexLoadAnim],16),240-17-1,136-y+dy,11,2,1)
		spr(anim(loadAnim[indexLoadAnim],16),240-17+1,136-y+dy,11,2,1)
		spr(anim(loadAnim[indexLoadAnim],16),240-17,136-y-1+dy,11,2,1)
		spr(anim(loadAnim[indexLoadAnim],16),240-17,136-y+1+dy,11,2,1)
	end
	pal()
	spr(anim(loadAnim[indexLoadAnim],16),240-17,136-y+dy,11,2,1)
	
	printc(loadMsg[indexLoadMsg],120,110,3,false,1,true,1)
	--print(indexLoadMsg,10,10,3)
	
	if loadingTimer < 0 then
		_GAME.state = STATE_GAME
		fade(-1)
	end
end

function gameUpdate()
	if global_hitpause > 0 then
		global_hitpause = global_hitpause - 1
	else
		for _,m in ipairs(mobs)do
			m:update()
		end
		bulletUpdate()
		updateParts()
	end
	
	cls()
	map(mx//8,my//8,31,18,-(mx%8),-(my%8),0)
	
	table.sort(mobs,layer)
	
	for _,m in ipairs(mobs)do
		m:draw()
	end
	drawParts()
	bulletDraw()
	Hud()
	updateDialog()
	drawFade()
	showTextScreenUpdate()
end

function optionUpdate()
	cls()
end

function Debug()
	text_debug = {
		[1] = {
			{str = "X: "..math.floor(p.x)},
			{str = "Y: "..math.floor(p.y)},
			{str = "Hp: "..p.hp},
			{str = "Speed: "..p.speed},
			{str = "Boost: "..p.boost},
			{str = "bTimer: "..bullet_timer},
			{str = "MapX: "..mx},
			{str = "MapY: "..my},
			{str = "Bullets: "..#bullet},
			{str = "Particles: "..#parts},
			{str = "Ents: "..#mobs},
			{str = "Debug Mode: "..tostring(STATE_DEBUG)},
		},
	}
	if _GAME.on then
		for i=1,#text_debug[1] do
			printb(text_debug[1][i].str,0,8*i+5,9,false,1,true)
		end
	end
end

function init()
	STATE_MENU = 0
	STATE_GAME = 1
	STATE_LOADING = 2
	STATE_OPTION = 3
	STATE_GAMEOVER = 4
	startMusic = false
	saved = false
	loadingTimer = math.random(100,500)
	
	global_hitpause = 0
	parts = {}
	mobs = {}
	rec = {}
	
	p = Player(26*8,77*8)
	bullet = {}
	bmax_timer = 30
	bullet_timer = bmax_timer
	bChange = false
	bvx,bvy = 2,0
	bf,br = 0,0
	
	textScreen = ""
	textScreenTimer = -80
	textScreenY = 68
	
	table.insert(mobs,p)
	
	dialog = {}
	dialog_color = 12
	dialog_pos = 1
	dialog_spr = 20
	dialog_name = nil
	text_pos = 1
	dix,diy = 0,60
	
	menu_state = 1
	timerText = 0
	
	butn = {
		{
			id = 1,
			str = "Start Game",
			on = function(s)
				trace("============ GAME ============",4)
				_GAME.state = STATE_LOADING
				--fade(-1)
			end
		},
		{
			id = 2,
			str = "Options",
			on = function(s)
				trace("============ OPTIONS ============",4)
				_GAME.state = STATE_OPTION
				fade(-1)
			end,
		},
		{
			id = 3,
			str = "Exit",
			on = function(s)
				trace("============ EXIT ============",4)
				exit()
				trace("Thankyou for playing =)",5)
			end
		},
	}
	
	mx,my = p.x//240*240,p.y//136*136
	spawnMobs()
end

init()
function TIC()
	if _GAME.state == STATE_MENU then
		menuUpdate()
	elseif _GAME.state == STATE_LOADING then
		Loading()
	elseif _GAME.state == STATE_GAME then
		gameUpdate()
		Debug()
	elseif _GAME.state == STATE_OPTION then
		optionUpdate()
	end
	t=t+1
end
