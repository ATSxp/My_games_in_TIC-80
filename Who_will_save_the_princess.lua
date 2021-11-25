-- title:  Who will save the princess?
-- author: @ATS_xp
-- desc:   Escape from the Demon King's dungeon to freedom!
-- script: lua

t=0

_GAME = {
	on = false,
	state = 	1,
}

local SPAWN_FLOOR = 16

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

SOLID = set{1,2,3,4,35,37}
BOARD = set{216}
INTERACTS = set{35}

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
end

-- By: Nesbox
function printc(s,x,y,c)
    local w=print(s,0,-8)
    printb(s,x-(w/2),y,c or 15)
end

-- By Nesbox
function pal(c0,c1)
 if(c0==nil and c1==nil)then for i=0,15 do poke4(0x3FF0*2+i,i)end
 else poke4(0x3FF0*2+c0,c1) end
end

function dist(x1,y1,x2,y2) return math.max(math.abs(x1-x2),math.abs(y1-y2))end
function col(x1,y1,w1,h1,x2,y2,w2,h2)return x1<x2+w2 and y1<y2+h2 and x2<x1+w1 and y2<y1+h1 end
function col2(a,b)if col(a.x,a.y,a.w,a.h,b.x,b.y,b.w,b.h)then return true end end

function layer(a,b)
	if a.y == b.y then return b.x < a.x end
	return a.y < b.y
end

function addDialog(di,col)
	dialog = di
	dialog_color = col or 12
	dialog_pos = 1
	text_pos = 1
end

function drawTextBox()
	spr(510,dix,diy,11,1)
	spr(510,dix+(240-8),diy,11,1,1)
	spr(510,dix,diy+60-12,11,1,1,2)
	spr(510,dix+(240-8),diy+60-12,11,1,0,2)
	for i = 0,27 do 
		spr(511,8*i+dix+8,diy,11,1) 
		spr(511,8*i+dix+8,diy+60-12,11,1,0,2)
	end
	for i = 0,4 do
		spr(511,dix,8*i+diy+8,11,1,1,1)
		spr(511,dix+240-8,8*i+diy+8,11,1,0,1)
	end
	rect(8,diy+8,224,60-16,13)
end

function updateDialog()
	if dialog ~= nil and dialog[dialog_pos] ~= nil then
		if p.y + p.h > 68 then diy = 10 else diy = 68 end
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
			printb(string.sub(str,1,text_pos),dix+10,diy+10,dialog_color,false,1)
			spr(anim({507,508},24),dix+240-24,diy+68-34,0,2)
			printb(">",(dix+240-32)+((t/24)%2),diy+70-34,12,false,2,true)
			global_hitpause = 1
			if text_pos < len and t%4==0 then text_pos = text_pos + 1 end
		end
		
	else
		dialog_pos = 1
		dialog = nil
	end
end

function Interact(v)
	for _,m in ipairs(mobs)do
		local hit = col(v.x,v.y,v.w,v.h,m.x,m.y,m.w+1,m.h)
		if m.onInteract ~= nil and 
		hit then
			m:onInteract()
		end
	end
end

function addParts(tbl)table.insert(parts,tbl)end
function drawParts()
	for _,v in ipairs(parts)do
		if v.mode == 1 then
			circ(v.x-mx,v.y-my,v.s or 1,v.c or 0)
		else
			rect(v.x-mx,v.y-my,v.w or 1,v.h or 1,v.c or 0)
		end
	end
end
function updateParts()
	for i,v in ipairs(parts)do
		v.t = (v.t and v.t+1)or 0
		v.x = v.x + math.random(-1,1)
		v.y = v.y + math.random(-1,1)
		v.x = v.x + (v.vx or 0)
		v.y = v.y + (v.vy or 0)
		v.mode = v.mode or 1
		
		if v.t > (v.max or 20) then table.remove(parts,i) end
	end
end

function bulletUpdate()
	for i,v in ipairs(bullet)do
		addParts({x = v.x+(v.vx<0 and 8 or 0),y = v.y+4,c = math.random(1,3),max = 10})
		
		local x = v.x + v.vx
		local y = v.y + v.vy
		local w = v.w
		local h = v.h
		if 
			sol(x,y+(h/2))or 
			sol(x+(w-1),y+(h/2))or 
			sol(x,y+(h-1))or
			sol(x+(w-1),y+(h-1))then
			local oldx,oldy = v.x,v.y
			addParts({x = oldx,y = oldy,s = math.random(2,5),c = math.random(13,15),vx = math.random(-1,1),vy = math.random(-1,1)})
			table.remove(bullet,i)
		end
		
		if v.vy < 0 then v.r = 3 -- up
		elseif v.vy > 0 then v.r = 1 end -- down
		if v.vx < 0 then v.f = 1 v.r = 0 -- left
		elseif v.vx > 0 then v.f = 0 v.r = 0 end -- right
		if v.vy > 0 and v.vx < 0 and bChange then v.r = 1 end -- down/left
		if v.vy > 0 and v.vx > 0 and bChange then v.r = 1 end -- down/right
		
		if v.x-mx < 0 or v.x-mx > 240 or v.y-my < 0 or v.y-my > 136 then table.remove(bullet,i) end
		
		v.x = v.x + v.vx
		v.y = v.y + v.vy
		if bChange then
			sprc(273,v.x,v.y,11,1,v.f,v.r)
		end
		if not bChange then
			sprc(272,v.x,v.y,11,1,v.f,v.r)
		end
	end	
end

function Mob(x,y)
	local s = {}
	s.type = "undefined"
	s.name = "?"
	s.t = 0
	s.hp = 1
	s.sp = s.sp
	s.anims = {}
	s.die = false
	s.collide = false
	s.atk = false
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
		
		if dst > s.fov then
			if dst <= s.range then
				if t%2==0 then
					if math.abs(dx) >= s.speed then 
						s:move(dx > 0 and s.speed or - s.speed,0)
					end
					if math.abs(dy) >= s.speed then 
						s:move(0,dy > 0 and s.speed or - s.speed)
					end
				end
			else
				s.vx,s.vy = 0,0
			end
		else
			s.vx,s.vy = 0,0
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
			sol(x,y+(h/2))or 
			sol(x+(w-1),y+(h/2))or 
			sol(x,y+(h-1))or
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
			p:damage(s.dmg)
			s.hitpause = 40
			addParts({x = p.x,y = p.y,c = 2,vx = math.cos(t),vy = math.sin(t)})
			s.atk = true
		end
	end
	
	function s.update(s)
		if s.type == "enemy" then
			if s.die then return end
			
			if s.hit > 0 then s.hit = s.hit - 1 end
			if s.hitpause <= 0 then s.atk = false end
			
			local dst = math.sqrt(((p.x-s.x)^2+(p.y-s.y)^2))
			if dst <= s.fov then
				if p.x > s.x then s.f = 0 else s.f = 1 end
				if t > s.t then
					s:attack()
					s.t = t + math.random(30,130)
				end
			else
				s.t = t + math.random(0,130)
			end
			
			for _,v in ipairs(bullet)do
				if col(v.x,v.y,v.w,v.h,s.x,s.y,s.w,s.h) then
					s:damage(p.dmg)
					table.remove(bullet,_)
					addParts({x = s.x,y = s.y,c = 2,vx = math.cos(t),vy = math.sin(t)})
				end
			end
			
			if s.vx ~= 0 then s.f = s.vx < 0 and 1 or 0 end
			if s.vx ~= 0 or s.vy ~= 0 then s.sp = anim(s.anims.walk)
			elseif s.vx == 0 and s.vy == 0 then  s.sp = anim(s.anims.idle) end
			if s.hp <= 0 then s.die = true s.sp = anim(s.anims.die) s.hit = 0
			elseif s.atk then s.sp = anim(s.anims.atk,4)end
			
			if s.die then
				for i=0,4 do
					addParts({x = 2*i+s.x,y = s.y,c = 1,vy = - math.random(1,2)/2})
				end
			end
		end
	end
	
	function s.draw(s)
		if s.hit > 0 then
			for i=0,15 do
				pal(i,12)
			end
		end
		sprc(271,s.x,s.y+3,0,1)
		sprc(s.sp,s.x,s.y,s.c,1,s.f)
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
	s.dmg = 2
	s.range = 50
	s.speed = 1
	s.supUpdate = s.update
	
	function s.update(s)
		s:supUpdate()	
		if not s.die then			
			s:seePlayer(p.x,p.y)
		end
	end
	
	return s
end

function Bat(x,y)
	local s = Mob(x,y)
	s.type = "enemy"
	s.name = "bat"
	s.hp = math.random(5,8)
	s.sp = 320
	s.c = 11
	s.dy = 0
	s.anims = {
		idle = {320,321},
		walk = {320,321},
		die = {323},
		atk = {322},
	}
	s.range = 60
	s.speed = 0.5
	s.dmg = math.random(1,3)
	s.supUpdate = s.update
	
	function s.update(s)
		s:supUpdate()	
		if not s.die then			
			s:seePlayer(p.x,p.y)
			
			s.y = s.y + s.dy
			
			if s.atk  then -- stop fly
			else if s.vx == 0 and s.vy == 0 then s.dy = math.cos(t/16)/6 end 
			end
			
		end
	end
	
	return s
end

function Player(x,y)
	local s = Mob(x,y)
	s.type = "hero"
	s.name = "princess"
	s.maxHp = 50
	s.hp = s.maxHp
	s.potions = 0
	s.sp = 256
	s.c = 11
	s.dmg = 2
	s.speed = 1
	s.supMove = s.move
	
	function s.move(s,dx,dy)
		s:supMove(dx,dy)
		
		if s.vx ~= 0 then s.f = s.vx<0 and 1 or 0 end
	end
	
	function s.cam(s)
		if s.x//240*240 ~= mx or s.y//136*136 ~= my then
			mx = s.x//240*240
			my = s.y//136*136
		end
	end
	
	function s.anim(s)
		if s.vx ~= 0 or s.vy ~= 0 then s.sp = s.anims.walk  
		elseif btn(6) then s.sp = s.anims.atk 
		elseif s.hp <= 0 then s.sp = s.anims.die
		else s.sp = s.anims.idle end
	end
	
	function s.onPotion(s)
		if not s.die and s.hp < s.maxHp then
			s.potions = s.potions - 1
			s.hp = s.hp + 20
			if s.hp > s.maxHp then s.hp = s.maxHp end
		end
	end
	
	function s.update(s)
		if s.die then return end
		s.vx = 0
		s.vy = 0
		bullet_timer = bullet_timer - 1
		if s.hit > 0 then s.hit = s.hit - 1 end
		
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
		if (btn(6) and bullet_timer < 0 ) then  -- shoot
			bullet_timer = 30
			table.insert(bullet,{sp = 272,x = s.x,y = s.y,vx = bvx*2,vy = bvy*2,f = bf,r = br,w = 8,h = 8})
		end
		if s.hp <= 0 then s.die = true s.hit = 0 end
		
		s:cam()
		s:anim()
	end
	return s
end

function NPC(sp,dialogs)
	local function fn(x,y)
		local s = Mob(x,y)
		s.type = "npc"
		s.hp = nil
		s.c = 0 
		s.sp =  sp
		s.dpos = 0
		s.dcolor = 12
		s.over = sp > 208 and sp < 215
		s.collide = true
		
		function s.onInteract(s)
			s.dpos = (s.dpos%#dialogs)+1
			addDialog(dialogs[s.dpos],s.dcolor)
			s.over = true
		end
		function s.draw(s)
			if s.sp > 207 and s.sp < 216 and t%30==1 then
				if p.x > s.x then s.f = 0 else s.f = 1 end
			end
			
			if INTERACTS:contains(s.sp) then s.over = true end
			if not over and BOARD:contains(s.sp) then
				sprc(270,s.x,s.y+3,0,1)
			end
			sprc(s.sp,s.x,s.y,s.c,1,s.f)
			if not s.over then
				s.dcolor = 12
				sprc(anim({491,492,493,494},16),s.x+4,(s.y-10),0,1)
			end			
			if BOARD:contains(s.sp) then
				s.dcolor = 4
				s.over = true
				local hit = col(p.x,p.y,p.w,p.h,s.x,s.y,s.w+1,s.h)
				if hit then sprc(509,s.x,(s.y-10)+math.cos((t/16))*2,0,1)end
			end
		
		end
		return s
	end
	return fn
end
-- How to use: NPC(sprite of npc,{text})

function Item(x,y)
	local s = Mob(x,y)
	s.type = "item"
	s.pickUp = false
	s.collide = false
	s.c = - 1
	s.dy = 0
	
	function s.update(s)
		if s.pickUp then return end
		
		if col2(p,s)then
			s:onPickUp()
			s.pickUp = true
		end
	end

	function s.draw(s)
		if not s.pickUp then
			sprc(s.sp,s.x,s.y+s.dy,s.c,1)
		end
	end
	return s
end

function Potion(x,y)
	local s = Item(x,y)
	s.name = "potion"
	s.supUpdate = s.update
	s.sp = 225
	s.c = 0
	
	function s.onPickUp(s)
		p.potions = p.potions + 1
		addDialog({"You got a POTION!"},2)
	end
	function s.update(s)
		s:supUpdate()
		s.dy = math.cos(t/16)*2
	end
	
	return s
end

function Chest(x,y)
	local s = Item(x,y)
	s.name = "chest"
	s.sp = 224
	s.collide = true
	s.c = 0
	s.open = false
	function s.update(s)
		if s.open then return end
		for _,v in ipairs(bullet)do
			if col2(v,s)then
				s.open = true
				if math.random(1,6) == 1 then
					table.insert(mobs,Potion(s.x,s.y))
				elseif math.random(1,6) == 2 then
					addDialog({"Watch out! A bat!!!"})
					table.insert(mobs,Bat(s.x,s.y+8))
				else
					addDialog({"There's nothing..." ,"Good luck next time."})
				end
			end
		end
		
	end
	
	function s.draw(s)
		if not s.open then sprc(s.sp,s.x,s.y,s.c,1)
		else sprc(240,s.x,s.y,s.c,1)end
	end
	return s
end

function Wall(sp)
	local function fn(x,y)
		local s = Mob(x,y)
		s.type = "tile"
		s.name = "wall"
		s.collide = true
		s.sp = sp
		s.c = 2
		
		function s.draw(s)
			if s.sp == 446 then s.collide = false else s.collide = true end
			if s.sp == 128 then s.c = 11 end
			sprc(s.sp,s.x,s.y-8,s.c,1,0,0,1,2)
		end
		return s
	end
	return fn
end

spawntiles = {}
-- Mobs
spawntiles[192] = Goblin
spawntiles[193] = Bat

spawntiles[160] = Wall(446)
spawntiles[161] = Wall(447)
spawntiles[128] = Wall(128)

-- Items
spawntiles[224] = Chest
spawntiles[225] = Potion

-- NPCs
-- Scavenger
spawntiles[208] = NPC(208,
{
	{
		"Scavenger: Hello handsome travele-...",
		"PRINCESS!!!! What are you doing here?",
		"Hum... hmm...",
		"so...",
		"you mean the knights who have been\nordered to rescue you so far won't arrive\nand you've decided to leave this dungeon\non your own?",
		"Hahahahahahahaha!",
		"this is a beautiful story",
		"Since you're here, I must warn you, there\nare monsters in front of this hallway,\njust be very careful with them."
	}
})
-- Board 1
spawntiles[216] = NPC(216,
{
	{
		"Welcome to Evil Dungeon, a dungeon with\nthe worst monsters in THE ENTIRE KINGDOM!\nPlease leave your note at the end of the\ndungeon, the Demon King thanks you."
	}
})
-- Door locked
spawntiles[221] = NPC(35,
{
	{
		"Is locked."
	}
})

function spawnMobs()
	for x = 0,240 do
		for y = 0,136 do
			local spawn = spawntiles[mget(x,y)]
			if spawn ~= nil then
				local mob = spawn(x*8,y*8)
				table.insert(mobs,mob)
				mset(x,y,SPAWN_FLOOR)
			end
		end
	end
end

function Hud()
	if not p.die then
		if p.hit > 0 then
			pal(2,4)
		end
		rect(2,0,p.hp,8,2)
		pal()
		spr(476,7*8,0,0,1)
	else
		spr(475,7*8,0,0,1)
	end
	spr(502,0,0,0,1)
	spr(504,6*8-2,0,0,1)
	for i = 0,4 do
		spr(503,8*i+8,0,0,1)
	end
	if p.potions > 0 then spr(225,8*8,0,0,1)end
end

function menuUpdate()
	if time()>3000 then
		cls(0)
		printc("Who will save the princess?",120,68,11)
		
		if btnp(4)then _GAME.state = STATE_GAME end
	else
		local w = print("@ATS_xp",0,-6,12)
		clip(0,0,240,136)
		cls()
		
		for i=0,15 do pal(i,12)end
		spr(14,(240-16*5)//2-1,28,11,5,0,0,2,2)
		spr(14,(240-16*5)//2,28-1,11,5,0,0,2,2)
		spr(14,(240-16*5)//2,28+1,11,5,0,0,2,2)
		spr(14,(240-16*5)//2+1,28,11,5,0,0,2,2)
		pal()
		spr(14,(240-16*5)//2,28,11,5,0,0,2,2)
		printb("@ATS_xp",(240-w)//2,120,0,false,1,false,12)
		clip()
	end
end

function gameUpdate()
	if global_hitpause > 0 then
		global_hitpause = global_hitpause - 1
	else
		for _,m in ipairs(mobs)do
			if m.hitpause > 0 then
				m.hitpause = m.hitpause - 1
				m.hit = 0
			else
				m:update()
			end
		end
		updateParts()
	end
	
	cls()
	map(mx//8,my//8,31,18)
	
	table.sort(mobs,layer)
	
	for _,m in ipairs(mobs)do
		m:draw()
	end
	drawParts()
	updateDialog()
	bulletUpdate()
	Hud()
end

function Debug()
	if _GAME.on then
		print("X: "..p.x,0,0,12,false,1,true)
		print("Y: "..p.y,0,10,12,false,1,true)
		print("Hp: "..p.hp,0,20,12,false,1,true)
		print("MapX: "..mx,200,0,12,false,1,true)
		print("MapY: "..my,200,10,12,false,1,true)
		print("Mobs: "..#mobs,0,80,12,false,1,true)
		print("Bullets: "..#bullet,0,90,12,false,1,true)
		print("Particles: "..#parts,0,100,12,false,1,true)
		print("Debug Mode: "..tostring(STATE_DEBUG),0,130,12,false,1,true)
		if btnp(4)and btnp(5)then STATE_DEBUG = not STATE_DEBUG end
	end
end

function debugMode()
	if STATE_DEBUG then
		global_hitpause = 1
		clip(5,5,230,131-5)
		cls(0)
		
		rectb(5,5,230,131-5,12)
		clip()
	end
end

function init()
	STATE_MENU = 0
	STATE_GAME = 1
	STATE_DEBUG = false
	
	global_hitpause = 0
	parts = {}
	mobs = {}
	
	p = Player(7*8,9*8)
	bullet = {}
	bullet_timer = 30
	bChange = false
	bvx,bvy = 2,0
	bf,br = 0,0
	
	table.insert(mobs,p)
	
	dialog = {}
	dialog_color = 12
	dialog_pos = 1
	text_pos = 1
	dix,diy = 0,60
	
	mx,my = 0,0
	spawnMobs()
end

init()
function TIC()
	if _GAME.state == STATE_MENU then
		menuUpdate()
	elseif _GAME.state == STATE_GAME then
		gameUpdate()
		Debug()
		debugMode()
	end
	t=t+1
end
