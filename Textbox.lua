t=0
 
global_hitpause = 0

dialog = {}
dialog_color = 12
dialog_pos = 1
text_pos = 1
function StartDialog(di,col)
	dialog = di
	dialog_color = col or 12
	dialog_pos=1
	text_pos=1
end

function dist(x1,y1,x2,y2)
	return math.max(math.abs(x1-x2),math.abs(y1-y2))
end
function col(a,b)
	if a~=b then
		if 
			a.x<b.x+b.w and
			a.y<b.y+b.h and
			b.x<a.x+a.w and
			b.y<a.y+a.h then
			return true
		end
	else
		return false
	end
end

function Mob(x,y)
	local s = {}
	s.type = "undefined"
	s.sp = s.sp
	s.x = x or 0
	s.y = y or 0
	s.w = s.w or 8
	s.h = s.h or 8 
	s.f = 0
	s.vx = 0
	s.vy = 0
	s.c = 0
	
	function s.draw(s)
		spr(s.sp,s.x,s.y,s.c,1,s.f)
	end
	function s.update(s)
	end
	return s
end

local mobs = {}
local p = Mob(6*8,6*8)

p.sp = 1
p.c = 0

function p.draw(s)
	spr(s.sp,s.x,s.y,s.c,1,s.f)
end

function p.update(s)
	if btn(0)then
		s.y = s.y - 1
	elseif btn(1)then
		s.y = s.y + 1
	end
	if btn(2)then
		s.x = s.x - 1
		s.f = 1
	elseif btn(3)then
		s.x = s.x + 1
		s.f = 0
	end
		
	if btnp(5)then
		Interact(s)
	end
end
	
table.insert(mobs,p)

function Statue(x,y)
	local s = Mob(x,y)
	s.sp = 32
	function s.draw(s)
		spr(s.sp,s.x,s.y-8,s.c,1,s.f,0,1,2)
	end
	return s
end

function powerUp(x,y)
	local s = Mob(x,y)
	s.type = "item"
	s.spr = s.spr
	s.pickUp = false
	s.w = 8
	s.h = 8
	
	function s.draw(s)
		if not s.pickUp then
			spr(s.spr,s.x,s.y,s.c,1,s.f)
		end
	end
	function s.update(s)
		if s.pickUp then return end
		
		if col(p,s) then
			s:onPickUp()
			s.pickUp = true
		end
	end
	return s
end

function Gem(x,y)
	local s = powerUp(x,y)
	s.spr = 2
	
	function s.onPickUp(s)
		StartDialog({"You got a Gem!"})
	end
	return s
end

function NPC(sp,dialogs)
	local function fn(x,y)
		local s = Mob(x,y)
		s.type = "npc"
		s.sp = sp
		s.over = s.sp < 3
		s.dpos = 0
		
		function s.onInteract(s)
			s.dpos = (s.dpos%#dialogs)+1
			StartDialog(dialogs[s.dpos])
			s.over = true
		end
		
		function s.draw(s)
			if t%30 == 1 and s.sp >=3 then
				if p.x > s.x then
					s.f = 0
				else
					s.f = 1
				end
			end
			spr(s.sp,s.x,s.y,s.c,1,s.f)
			if not s.over then
				spr(16+((t/16)%3),s.x+4,s.y-8,0,1)
			end
		end
		return s
	end
	return fn
end

function depth(a,b)
	if a.y == b.y then return b.x < a.x end
	return a.y < b.y
end

function Interact(a)
	for i,m in ipairs(mobs) do
		if m.onInteract ~= nil and 
		col(a,m) then
			m:onInteract()
		end
	end
end

local spawntile = {}
spawntile[2] = Gem
spawntile[32] = Statue

spawntile[3] = NPC(3,{
	{
		"???: Ola amigo, como vai? Voce esta\nobservando um sistema de dialogo com NPC",
		"Tenha um bom dia!"
	}
})
spawntile[4] = NPC(4,{
	{
		"Homem Bombado: Ola!",
		"O que achou deste lugar? Vazio nao?\nBem, tudo certo...",
		"Hey... o que acha dos meus musculos?"
	}
})

function spawn()
	for x = 0,30 do
		for y = 0,17 do
			--local mob
			local spawn = spawntile[mget(x,y)]
			if spawn ~= nil then
				local mob = spawn(x*8,y*8)
				table.insert(mobs,mob)
				mset(x,y,0)
			end
		end
	end
end

function TIC()
	
	if global_hitpause > 0 then
		global_hitpause = global_hitpause - 1
	else
		spawn()
		for i,m in ipairs(mobs) do		
			m:update()
		end
		
	end
	
	cls()
	map(0,0,31,18)
	
	table.sort(mobs,depth)
	
	for i,m in ipairs(mobs)do
		m:draw()
	end

	if dialog ~= nil and dialog[dialog_pos] ~= nil then
		local str = dialog[dialog_pos]
		local len = string.len(str)
		
		if btnp(5) and text_pos >= 2 then
			if text_pos < len then
				text_pos = len
			else
				text_pos = 1
				dialog_pos = dialog_pos + 1
			end
		end
		
		if dialog_pos <= #dialog then
			rect(0,0,240,70,0)
			rectb(0,0,240,70,12)
			print(string.sub(str,1,text_pos),5,5,
			dialog_color)
			print("^",220,57+((t/16)%2),12,false,2)
			global_hitpause = 1
			if text_pos < len and t%4 == 0 then
				text_pos = text_pos + 1
			end
		end
	else
		dialog_pos = 1
		dialog = nil
	end
	
	t=t+1
end
