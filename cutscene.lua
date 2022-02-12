-- title:  game title
-- author: game developer
-- desc:   short description
-- script: lua

t=0

tran = {
	on = true,
	t = 25,
	mt = 50,
}
mx,my = 0,0

function Timer(duration)
	local s = {}
	s.time=time();	
	s.duration=duration*1000

	s.complete=function()
		return time()-s.time > s.duration
	end
	
	s.fraction=function()
		return math.min((time()-s.time)/s.duration,1.0)
	end
	
	s.reset=function()
		s.time=time()
	end
	return s
end

function stateManager()
	local s = {}
	s.states = {}
	s.state_overlay = {}
	s.active_state = ""
	
	function s.active(name)
		s.active_state = name
		s.states[name].on_active()
	end
	
	function s.add(e,name)
		s.mgr = s
		s.states[name] = e
	end
	
	function s.pop()
		table.remove(s.state_overlay,1)
		if #s.state_overlay > 1 then
			s.state[1].on_active()
		end
	end
	
	function s.push(e)
		s.mgr = s
		table.insert(s.state_overlay,1,e)
		e.on_active()
	end
	
	function s.update()
		for i=#s.state_overlay,1,-1 do
			s.state_overlay[i].update()
		end
		s.states[s.active_state].update()
	end
	
	function s.draw()
		s.states[s.active_state].draw()
		for i=#s.state_overlay,1,-1 do
			s.state_overlay[i].draw()
		end
	end
	return s
end

function sol(x,y)
	return fget(mget(x//8,y//8),0)
end

function col(x1,y1,w1,h1,x2,y2,w2,h2)
	return	x1<=x2+w2 and
								x2<=x1+w1 and
								y1<=y2+h2 and
								y2<=y1+h1
end

function Evt()
	local s = {}
	function s.on_active()end
	function s.done()mgr.pop()end
	function s.launch()mgr.push(s)end
	function s.preUpdate()end
	function s.posUpdate()end
	function s.update()s.preUpdate()s.posUpdate()end
	function s.draw()end
	return s
end

function printEvt(text,x,y,c,complete)
	local s = Evt()
 s.timer = Timer(1.5)
	function s.preUpdate()
		if s.timer.complete() then
			s.done()
			complete()
		end
	end
	
	function s.draw()
		print(text,x,y,c)
	end
	return s
end

function waitEvt(timer,complete)
	local s = Evt()
	s.timer = Timer(timer)
	function s.preUpdate()
		if s.timer.complete() then
			s.done()
			complete()
		end
	end
	return s
end

function Sq(script,nostart)
 local s = {}
 local self = s
	s.script = script
	s.update=function()
	 --cam.follow(player.bnd.center)
	end
	s.on_complete=function()end
 s.pop_script=function()
	 if #self.script == 0 then
		 self.on_complete()
		 return
		end
		local e = table.remove(self.script,1)--self.script.shift()
		local t = e[1]
		local evt
		if t == "move" then
		 --evt=new MoveEvt(e[1],e[2],e[3],e[4],self.pop_script)
		elseif t == "wait" then
			evt = waitEvt(e[2],self.pop_script)
		 --evt=new WaitEvt(e[1],self.pop_script)
		elseif t == "dialogue" then
			evt = printEvt(e[2],e[3],e[4],e[5],self.pop_script)
		 --var d=new Dialogue(e[1],e[2],false)
			--d.on_complete=self.pop_script
		elseif t == "flash" then
		 --evt=new FlashEvt(e[1],e[2],self.pop_script)
		elseif t=="sfx" then
		 --sfx(e[1],e[2])
			--s:pop_script()
		else
		 --evt=new WaitEvt(0.05,self.pop_script)
		end
		if evt then
		 evt.posUpdate = self.update
		 evt.launch()
		end
	end
	s.launch=function()
	 self.script = script
		self.pop_script()
	end
	if not nostart then s.launch()end
	return s
end

function Title()
	local s = {}
	function s.on_active()
		
	end
	
	function s.update()
		if btnp(4)then mgr.active("game")end
	end
	
	function s.draw()
		cls()
		local w = print("Cuzin Hoje?",0,-6,12)
		print("Cuzin Hoje?",(240-w)//2,68,12)
	end
	return s
end

function Game()
	local s = {}
	function s.on_active()
		u = Sq({{"dialogue","Ola mundo",120,68,2},{"wait",5},{"dialogue","Ola bu",120,68,2}})
		--[[u.on_complete = function()
			initTran()
		end--]]
	end
	
	function s.update()
		checkWarp()
		p.update()
	end
	
	function s.draw()
		cls()
		map(mx//8,my//8,31,18)
		--print(table.concat(u.script[1],"\n\n"),0,0,12)
		p.draw()
		drawTran()
	end
	return s
end

mgr = stateManager()
mgr.add(Title(),"menu")
mgr.add(Game(),"game")
mgr.active("menu")

function drawTran()
	if tran ~= nil and tran.on then
		local dist = math.sin((tran.t/tran.mt)*math.pi)*(136/2)+8
		rect(0,136-dist,240,136//2+8,0)
		rect(0,dist-136/2-8,240,136//2+8,0)
		tran.t = tran.t + 1
		if tran.t > tran.mt then
			tran.on = false
			tran = nil
		end
	end
end

function initTran()
	tran = {
		on = true,
		t = 25,
		mt = 50,
	}
end

function Player(x,y)
	local s = {}
	s.x = x or 0
	s.y = y or 0
	s.w = 8
	s.h = 8
	s.vx,s.vy = 0,0
	
	function s.update()
		if s.x//240*240 ~= mx or s.y//136*136 ~= my then
			mx,my = s.x//240*240,s.y//136*136
		end
		
		if btn(0)then
			s.vy = - 1
		elseif btn(1)then
			s.vy = 1
		else
			s.vy = 0
		end
		if btn(2)then
			s.vx = - 1
		elseif btn(3)then
			s.vx = 1
		else
			s.vx = 0
		end
		
		local x,y,w,h = s.x + s.vx,s.y + s.vy,s.w,s.h
		if sol(x,y+(h/2))or sol(x+(w-1),y+(h/2))or sol(x,y+(h-1))or sol(x+(w-1),y+(h-1))then
			s.vx,s.vy = 0,0
		end
		
		s.x = s.x + s.vx
		s.y = s.y + s.vy
	end
	
	function s.movePlayer(x,y)
		s.x,s.y = math.floor(x*8),math.floor(y*8)
	end
	
	function s.draw()
		rect(s.x-mx,s.y-my,s.w,s.h,12)
	end
	return s
end

p = Player(120,68)

warps = {}
function Wp(x,y,fn)
	local s = {}
	s.x,s.y = x,y
	s.onHit = fn
	table.insert(warps,s) 
end

function checkWarp()
	for i,w in ipairs(warps)do
		if col(math.floor(w.x*8),math.floor(w.y*8)+3,8,2,p.x,p.y,p.w,p.h)then
			w:onHit()
		end
	end
end

function enterRoom(px,py)
	p.movePlayer(px,py)
	initTran()
end

function exitRoom(px,py)
	p.movePlayer(px,py)
	initTran()
end

Wp(19,8,function(s)enterRoom(46,7)end)
Wp(46,8,function(s)exitRoom(19,9)end)

function TIC()
	mgr.update()
	mgr.draw()
	t=t+1
end
