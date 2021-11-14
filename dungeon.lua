-- title:  project dungeon
-- author: @ATS_xp
-- desc:   short description
-- script: lua

t=0

mx,my = 0,0
room = 0

-- By Nesbox
function pal(c0,c1)
 if(c0==nil and c1==nil)then for i=0,15 do poke4(0x3FF0*2+i,i)end
 else poke4(0x3FF0*2+c0,c1) end
end

local parts = {}
function parts:Add(tbl)
	local tbl = tbl or {}
	table.insert(self,tbl)
end

function parts:Update()
	for i,v in ipairs(self)do
		v.t = (v.t and v.t+1)or 0
		v.x = v.x + math.random(-1,1)
		v.y = v.y + math.random(-1,1)
		v.x = v.x + (v.vx or 0)
		v.y = v.y + (v.vy or 0)
		
		circ(v.x-mx,v.y-my,v.s or 1,v.c or 0)
	
		if v.t>(v.max or 20)then table.remove(self,i)end
	end
end

function rm(tbl)
	for i,v in ipairs(tbl)do table.remove(tbl,i)end
end

function set(ls)
	local s = {}
	for i,l in ipairs(ls)do s[l] = true end
	function s.Contains(s,e)
		return s[e] == true
	end
	function s.Add(s,e)
		s[e] = true
	end
	return s
end

SOLID = set({1,2,3,4,5,6,7,8,9,10,11,12,23,24,17,207,190})

function anim(f,s)local f,s = f or {},s or 8;return f[((t//s)%#f)+1]end
function sol(x,y)return SOLID:Contains(mget(x//8,y//8))end
function AABB(x1,y1,w1,h1,x2,y2,w2,h2)return x1<x2+w2 and y1<y2+h2 and x2<x1+w1 and y2<y1+h1 end
function sprc(id,x,y,c,s,f,r,w,h)spr(id,x-mx,y-my,c,s,f,r,w,h)end

function lockDoor(l,u,r,d)
	for i = l,r do
		for j = u,d do
			if mget(i,j) == 191 then
				mset(i,j,190)
			end
		end
	end
end

function unlockDoor(l,u,r,d)
	for i = l,r do
		for j = u,d do
			if mget(i,j) == 190 or mget(i,j) == 207 then
				mset(i,j,191)
			end
		end
	end
end

function Mob(x,y)
	local s = {}
	s.spr = s.spr or 0
	s.anims = {}
	s.hp = 1
	s.die = false
	s.attack = false
	s.x = x or 0
	s.y = y or 0
	s.w = 16
	s.h = 16
	s.c = 0
	s.f = 0
	s.vx = 0
	s.vy = 0
	s.dir = 1
	s.proximity = 16+2
	s.enemy = false
	s.speed = 0.3 + math.random() * 0.1
	
	function s.Draw(s)
	end
	
	function s.Coll(s)
		local x = s.x+s.vx or 0
		local y = s.y+s.vy or 0
		local w = s.w or 8
		local h = s.h or 8
		
		if sol(x,y+(h/2))or sol(x+(w-1),y+(h/2))or sol(x,y+(h-1))or sol(x+(w-1),y+(h-1))then
			s.vx,s.vy = 0,0
		end
		
		s.x = s.x + s.vx
		s.y = s.y + s.vy
	end
	
	function s.Update(s)
		if s.die then return end
		if s.enemy then
			s.f = s.vx > 0 and 0 or 1
			
			local dx = s.x - p.x
			local dy = s.y - p.y
			local dst = math.sqrt(dx^2 + dy^2)
			
			if dst < 40 then
				if dst >= s.proximity then
					
					if math.abs(dx)>= s.speed then s.vx = dx>0 and -s.speed or s.speed end
					if math.abs(dy)>= s.speed then s.vy = dy>0 and -s.speed or s.speed end
					
				end
			end
			
			local hit = AABB(p.x,p.y,p.w,p.h,s.x,s.y,s.w,s.h)
			
			s:Coll()
		end
	end
	return s
end

local function Player(x,y)
	local s = Mob(x,y)
	
	s.spr = 256
	s.c = 11
	s.keys = 0
	
	function s.Draw(s)
		--for i=13,15 do pal(i,12)pal(0,12)end
		sprc(s.spr,s.x,s.y,s.c,1,s.f,0,2,2)
		pal()
	end
	
	function s.Anim(s)
		s.anims.WALKD = anim({288,320})
		s.anims.WALKLR = anim({292,324})
		s.anims.WALKU = anim({290,322})
		s.anims.IDLE = {256,258,260}
		s.anims.ATK = {352,354,356}
		
		if s.vx == 0 or s.vy == 0 then s.spr = s.anims.IDLE[s.dir] end
		if s.vy < 0 then s.spr = s.anims.WALKU end
		if s.vy > 0 then s.spr = s.anims.WALKD end
		if s.vx > 0 or s.vx < 0 then
			s.spr = s.anims.WALKLR
		end
		if btn(6)then s.spr = s.anims.ATK[s.dir] end
	end
	
	function s.Parts(s)
		if s.vx ~= 0 or s.vy ~= 0 then 
			if (t/4)%4==0 then
			parts:Add({
				x = s.x + 8,
				y = s.y + 16,
				c = math.random(14,15),
				max = 10,
			})
			end
		end
	end
	
	function s.Cam(s)
		if s.x//240*240 ~= mx or s.y//136*136 ~= my then
			mx = s.x//240*240
			my = s.y//136*136
		end
	end
	
	function s.Atk(s)
		if s.attack then
			--print("hello")
			s.vx,s.vy = 0,0
			
			
			
		end
		s.attack = true 
	end
	
	function s.Update(s)
		if s.die then return end
		if btn(0)then s.vy = -1 s.dir = 2
		elseif btn(1)then s.vy = 1 s.dir = 1
		else s.vy = 0 end
		if btn(2)then s.vx = -1 s.f = 1 s.dir = 3
		elseif btn(3)then s.vx = 1 s.f = 0 s.dir = 3
		else s.vx = 0 end
		
		if btn(6)then s:Atk()end
		
		s:Coll()
		s:Anim()
		s:Parts()
		s:Cam()
		
	end
	return s
end
p = Player(120,68)

local mobs = {}
local function MoonRang(x,y)
	local s = Mob(x,y)
	s.spr = 384
	s.hp = 5
	s.c = 11
	s.enemy = true
	
	function s.Draw(s)
		local y = s.y + math.cos(t/10)*2
		circ(s.x-mx+8,s.y-my+14,4+math.cos(t/10)*2,14)
		sprc(s.spr,s.x,y,s.c,1,s.f,0,2,2)
	end
	return s
end

local items = {}
function Items()
	for i,v in ipairs(items)do
		local hit = AABB(p.x,p.y,p.w,p.h,v.x,v.y,v.w,v.h)
		
		if v.tag == "key" then
			local y = v.y + math.cos(t/10)*2
			circ(v.x-mx+4,v.y-my+8,3+math.cos(t/10)*2,14)
			sprc(v.spr,v.x,y,v.c,1,0,0,1,1)
			
			if hit then
				table.remove(items,i)
				parts:Add({
					x = v.x + 4,
					y = v.y + 4,
					c = 4,
					vy = - 1
				})
				p.keys = p.keys + 1
			end
			
		end
	
	end
end

spawnmobstiles = {}
spawnmobstiles[209] = MoonRang

obj = {}
obj[210] = {tag = "key", spr = 210, w = 8, h = 8, c = 2}

function spawnMobs()
	for x = 0,240 do
		for y = 0,136 do
			local mob
			local spawn = spawnmobstiles[mget(x,y)]
			if spawn ~= nil then
				mob = spawn(x*8+4,y*8+4)
				table.insert(mobs,mob)
				mset(x,y,80)
			end
			
			if obj[mget(x,y)]~=nil then
				local e = {}
				
				for i,d in pairs(obj[mget(x,y)])do
					e[i] = d
				end
				
				e.x,e.y = x * 8,y * 8
				
				table.insert(items,e)
				mset(x,y,80)
			end
			
		end
	end
end

function roomUpdate()
	if p.y>19*8 then lockDoor(12,17,15,18)end
end

function drawMonsters()
	for i,m in ipairs(mobs)do
		m:Draw()
	end
end

function updateMonsters()
	for i,m in ipairs(mobs)do
		m:Update()
	end
end

spawnMobs()
function TIC()
	cls()
	map(mx//8,my//8,31,18,-(mx%8),-(my%8),0,1)
	
	p:Draw()
	p:Update()
	
	drawMonsters()
	updateMonsters()
	Items()
	
	parts:Update()
	roomUpdate()
	
	t=t+1
end

-- <TILES>
-- 001: ddedddddffdfffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 002: eedddddddefffffffdeeffffffddefffffffdfffffffffffffffffffffffffff
-- 003: dddddddefffffffeffffffedfffffedffffffdffffffffffffffffffffffffff
-- 004: edddddeddfffffdfffffffffffffffffffffffffffffffffffffffffffffffff
-- 005: ddedddddffdfffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 006: eeddddddddffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 007: 0000000d0000000d0000000d0000000d0000000d0000000d0000000d0000000d
-- 008: 0000000d0000000d0000000d0000000d0000000d0000000d0000000d0000000d
-- 009: fffffffff0000000f0000000f0000000f0000000f0000000f0000000f0000000
-- 010: ffffffff00000000000000000000000000000000000000000000000000000000
-- 011: fffddfff000ff000000000000000000000000000000000000000000000000000
-- 012: fffffffd0000000d0000000d0000000d0000000d0000000d0000000d0000000d
-- 016: f0f0f0f00f0f0f0ff0f0f0f00f0f0f0f0f0f0f0ff0f0f0f00f0f0f0ff0f0f0f0
-- 017: ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 023: 0000000d0000000d0000000d000000de000000de0000000d0000000d0000000d
-- 024: f0000000f0000000f0000000df000000df000000f0000000f0000000f0000000
-- 080: dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 081: deeeeeededdddddeeddddddeeddddddeeddddddeeddddddeeddddddedeeeeeed
-- 082: deeeedddedddddddedddddddeddddddddddddddeeddddddeeddddddedeeddeed
-- 083: ddddedddddddeddddddcedddccceedcceeecddeedddecdddddddedddddddeddd
-- 096: eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 097: effffffefeeeeeeffeeeeeeffeeeeeeffeeeeeeffeeeeeeffeeeeeefeffffffe
-- 098: effffeeefeeeeeeefeeeeeeefeeeeeeeeeeeeeeffeeeeeeffeeeeeefeffeeffe
-- 099: eeeefeeeeeeefeeeeeedfeeedddffeddfffdeeffeeefdeeeeeeefeeeeeeefeee
-- 190: ddddddddef0dfffdeff0dffdef0dfffdefffffddeffffd0defffd0fdeeeeeeee
-- 191: eeeeeeeedf0efffedff0effedf0efffedfffffeedffffe0edfffe0fedddddddd
-- 207: fc3c34cecfe0feec4fe0fee44fee0ee33fe0fee44fe0fee4f3feee3efe4344ee
-- 208: 22222200222220cc22220ddd2220dddd2220dddd220d0d0d220d0d0d220d0d0d
-- 209: 2222222202222222c00222224cc022224f4c022244ff0222044e4022204e4022
-- 210: 222002222204c022204004022204402222204022220440222203402222200222
-- 211: 2222222222244222224cc42224cccc4224cccc42224cc4222224422222222222
-- 224: 022222202000c002200cc0022000c0022000c0022000c002200ccc0202222220
-- 225: 022222202000000220cccc0220000cc2200ccc0220cc000220ccccc202222220
-- </TILES>

--<SPRITES>
-- 256: bbbbbb00bbbbb0ccbbbb0dddbbb0ddddbbb0ddddbb0d0d0dbb0d0d0dbb0d0d0d
-- 257: 00bbbbbbcc0bbbbbccc0bbbbddcc0bbbdddd0bbbd0d0d0bbd0d0d0bbd0d0d0bb
-- 258: bbbbbb00bbbbb0ccbbbb0cddbbb0cdddbbb0ddddbb0dddddbb0dddddbb0edddd
-- 259: 00bbbbbbcc0bbbbbddc0bbbbdddc0bbbdddd0bbbddddd0bbddddd0bbdddde0bb
-- 260: bbbb0000bbb0cccdbb0cddddbb0dddddb0ddddddb0ddddddb0eeddddb0eeeedd
-- 261: 0bbbbbbbd00bbbbbddd0bbbbddd0bbbb0d0d0bbb0d0dd0bb0d0de0bbfd0eee0b
-- 262: bbbbbbbbbbbbccccbbccccccbbcbbcccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 263: bbbbbbbbbbbbbbbbccbbbbbbccbbbbbbcccbbbbbbccbbbbbbccbbbbbbbcbbbbb
-- 264: bbbbbbbbbbbbbbbbbbccccccbbbcccccbbbbbbccbbbbbbbbbbbbbbbbbbbbbbbb
-- 265: bbbbbbbbbbbbbbbbccbbbbbbccbbbbbbcccbbbbbccccbbbbccccbbbbccccbbbb
-- 266: bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 267: bbbbbbbbbbbbbbbbbbbbbbbbcbbbbbbbbcbbbbbbccbbbbbbccbbbbbbccbbbbbb
-- 272: bb0efd0dbbb0eefdbb000eeeb0ddd0feb0edd0ffb0eee0dfbb000dfdb0000000
--</SPRITES>

--<PALETTE>
-- 00bbbbbbcc0bbbbbccc0bbbbddcc0bbbdddd0bbbd0d0d0bbd0d0d0bbd0d0d0bb
--</PALETTE>
