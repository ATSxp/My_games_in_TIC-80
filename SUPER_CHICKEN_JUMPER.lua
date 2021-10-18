-- title:  Super Chicken Jumper
-- author: @ATS_xp
-- desc:   Super Chicken Jumper in TIC-80 engine
-- script: lua

rand=math.random
cos=math.cos
sin=math.sin
to=table.insert
del=table.remove

function init()
 t=0
 debug=false
 solid=true
 damaged=true
 mode="game"
 menuState=0
 gameOverState=0
 timerWorld=70
 paleteCredit={1,11,10,9,8}
 
 score=0
 
 world={}
 world.cloud={}
 world.ents={}
 world.parts={}
 
 p={
  name="player",
  die=false,
  stamina=1,
  spr=256,
  anim={
   walk={258,260},
  },
  x=0,
  y=10*8,
  w=16,
  h=16,
  vx=0,
  vy=0,
  r=0,
  speed=1,
  c=10
 }
 
 k={
  name="knife",
  isAttacking=false,
  spr=264,
  x=0,
  y=0,
  w=16,
  h=8,
  vx=0,
  r=0,
 }
 
 
 buttons={
  
  gm={
   reset={
    spr=496,
    x=120-32,
    y=146,
    w=24,
    h=24,
    vy=0,
   },
   home={
    spr=497,
    x=120+32,
    y=146,
    w=24,
    h=24,
    vy=0,
   },
  },
  
  mn={
   play={
   	x=(240-50)//2,
   	y=60,
   },
   credits={
    x=(240-50)//2,
    y=90,
   },
  },
 }
 
 objDelay=50
 timeToMakeObj=objDelay
 canMakeObj=false
 obj2Delay=200
 timeToMakeObj2=obj2Delay
 canMakeObj2=false
 
 cloudDelay=20
 timeToMakeCloud=cloudDelay
 canMakeCloud=false
 
 mx,my=0,0
end

function sol(x,y)
 if solid then
 	return fget(mget(x//8,y//8),0)
 end
end

function col(x1,y1,w1,h1,x2,y2,w2,h2)
 return x1<=x2+w2 and x2<=x1+w1 and y1<=y2+h2 and y2<=y1+h1
end

function anim(frames,speed,scale)
 local frames = frames or {}
 local speed = speed or 8
 local scale = scale or 1
 
 return frames[((t//speed)%#frames)+1]*scale
end

function partsUpd()
 for i,v in ipairs(world.parts)do
  v.t=(v.t and v.t+1)or 0
  v.mode=v.mode or 0
  v.x=v.x+(v.vx or 0)
  v.y=v.y+(v.vy or 0)
  v.x=v.x+rand(-1,1)
  v.y=v.y+rand(-1,1)
  v.size=v.size or 1.5
  
  if v.mode==0 then
   circ(v.x,v.y,v.size,v.c or 12)
  elseif v.mode==1 then
   rect(v.x,v.y,v.w or 1,v.h or 1,v.c or 12)
  end
  
  if v.t>(v.max or 20)then
   del(world.parts,i)
  end
  
 end
end

function playerDrw()
 spr(p.spr,p.x,p.y,p.c,1,0,p.r,2,2)
 spr(k.spr,k.x,k.y,p.c,1,0,k.r,2,1)
end

function playerUpd()
 if not p.die then
	 
	 if btn(2)and p.x>0 then
	  p.vx=-p.speed
	  p.spr=anim(p.anim.walk)
	 elseif btn(3)and p.x+p.w<240 then
	  p.vx=p.speed
	  p.spr=anim(p.anim.walk)
	 else
	  p.vx=0
	  p.spr=256
	 end
		
	 if btnp(4)and p.vy==0 then
	  p.vy=-3
			to(world.parts,{x=p.x,p,y=p.y+5,c=0})
	 elseif btnp(4)and p.vy<2.5 and p.stamina>0 then
	  p.vy=-2.5
			to(world.parts,{mode=1,w=2,h=2,x=p.x,y=p.y+5,c=0})
			p.stamina=p.stamina-1
	 end
		
		if p.vy==0 then
		 p.stamina=1
		end
		
		if (btn(2)or btn(3)) and p.vy==0 then
		 if (t/2)%8==0 then
			 to(world.parts,{mode=0,x=p.x+8,y=p.y+15,vx=p.vx/4,vy=p.vy/4,size=2,c=rand(12,13)})
		 end
		end
		
 end

 if sol(p.x+p.vx,p.y+p.vy)or sol(p.x+15+p.vx,p.y+p.vy)or sol(p.x+p.vx,p.y+15+p.vy)or sol(p.x+15+p.vx,p.y+15+p.vy)then
  p.vx=0
 end
 if sol(p.x+p.vx,p.y+p.vy)or sol(p.x+15+p.vx,p.y+p.vy)or sol(p.x+p.vx,p.y+16+p.vy)or sol(p.x+15+p.vx,p.y+16+p.vy)then
  p.vy=0
 else
  p.vy=p.vy+0.2
 end
 
 if p.vy>0 then p.spr=262 end
 
 if p.die==true then
  p.r=0+((t/8)%3)
  k.r=0+((t/8)%3)
  to(world.parts,{mode=1,x=p.x,y=p.y,vy=1,w=3,h=3,c=2})
  damaged=false
 end
 
 p.x=p.x+p.vx
 p.y=p.y+p.vy
end

function attack()
 if not p.die then
  if btn(6)then
   k.isAttacking=true
   k.vx=6+cos((t/1000))
  else
   k.vx=0
   k.isAttacking=false
	 end
 end
 
 k.x,k.y=p.x+2,p.y+7
 k.x=k.x+k.vx
end
 
function treeDrw(v)
 spr(v.spr,v.x,v.y,v.c,1,0,0,2,2)
end
function rockDrw(v)
 spr(v.spr,v.x,v.y,v.c,1,0,0,4,2)
end

function treeUpd()
 timeToMakeObj=timeToMakeObj-1
 if timeToMakeObj<0 then
  canMakeObj=true
 end
 
 if canMakeObj then
  local newObj={name="tree",spr=288,x=rand(260,280),y=10*8,w=14,h=14,vx=0,speed=1,c=10}
  to(world.ents,newObj)
  timeToMakeObj=objDelay
  canMakeObj=false
 end
 
 for i,o in ipairs(world.ents)do
  if o.name=="tree"then
	  o.vx=-o.speed
	  o.x=o.x+o.vx
	  if o.x<-16 then
	   del(world.ents,i)
	   if not p.die then
	    score=score+1
	   end
			elseif col(k.x,k.y,k.w,k.h,o.x+1,o.y+2,o.w,o.h)and k.isAttacking then
				score=score+1
				local oldX,oldY=o.x,o.y
				del(world.ents,i)
				to(world.parts,{mode=1,x=oldX+rand(-3,3),y=oldY+rand(-1,1),w=2,h=2,vy=2,c=0,max=40})
				to(world.parts,{mode=1,x=oldX+rand(-3,3),y=oldY+rand(-1,1),w=1,h=1,vy=2,c=0,max=40})
			 to(world.parts,{mode=1,x=oldX+rand(-3,3),y=oldY+rand(-1,1),w=3,h=3,vy=2,c=0,max=40})
			end
	  
	  if damaged then
		  if col(p.x,p.y,p.w,p.h,o.x+1,o.y+2,o.w,o.h)then
		   p.vy=cos(t)*6
		   p.die=true
		   solid=false
		  end
	  end
  end
 end
end

function rockUpd()
 timeToMakeObj2=timeToMakeObj2-1
 if timeToMakeObj2<0 then
  canMakeObj2=true
 end
 
 if canMakeObj2 then
  local newObj={name="rock",spr=320,x=rand(310,390),y=10*8,w=30,h=14,vx=0,speed=1,c=10}
  to(world.ents,newObj)
  timeToMakeObj2=obj2Delay
  canMakeObj2=false
 end
 
 for i,o in ipairs(world.ents)do
  if o.name=="rock"then
	  o.vx=-o.speed
	  o.x=o.x+o.vx
	  if o.x<-36 then
	   del(world.ents,i)
	   if not p.die then
	    score=score+1
	   end
			elseif col(k.x,k.y,k.w,k.h,o.x+1,o.y+2,o.w,o.h)and k.isAttacking then
			 score=score+1
				local oldX,oldY=o.x,o.y
				del(world.ents,i)
				to(world.parts,{mode=1,x=oldX+rand(-3,3),y=oldY+rand(-1,1),w=2,h=2,vy=2,c=0,max=40})
				to(world.parts,{mode=1,x=oldX+rand(-3,3),y=oldY+rand(-1,1),w=1,h=1,vy=2,c=0,max=40})
			 to(world.parts,{mode=1,x=oldX+rand(-3,3),y=oldY+rand(-1,1),w=3,h=3,vy=2,c=0,max=40})
			end
	  
	  if damaged then
		  if col(p.x,p.y,p.w,p.h,o.x+1,o.y+2,o.w,o.h)then
		   p.vy=cos(t)*4
		   p.die=true
		   solid=false
		  end
	  end
  end
 end
end


function Clouds()
 timeToMakeCloud=timeToMakeCloud-1
 if timeToMakeCloud<0 then
  canMakeCloud=true
 end
 
 if canMakeCloud then
  local newCloud={spr=34,x=260,y=rand(1,60),c=0,vx=0,speed=1}
  to(world.cloud,newCloud)
  timeToMakeCloud=cloudDelay
  canMakeCloud=false
 end
 
 for i,c in ipairs(world.cloud)do
  spr(c.spr,c.x,c.y,c.c,1,0,0,4,1)
  spr(54,c.x,c.y+112,10,1,0,0,4,1)
  c.vx=-c.speed
  c.x=c.x+c.vx
  if c.x<-32 then
   del(world.cloud,i)
  end
 end
end

function GameOver()
 local x,y,p=mouse()
 
 spr(buttons.gm.reset.spr,buttons.gm.reset.x+cos((t/24)*2)*4,buttons.gm.reset.y+sin((t/24)*2)*4,-1,3)
 spr(buttons.gm.home.spr,buttons.gm.home.x+cos((t/24)*2)*4,buttons.gm.home.y+sin((t/24)*2)*4,-1,3) 
 
 buttons.gm.reset.vy=-1
 buttons.gm.home.vy=-1
 
 if buttons.gm.reset.y<60 or buttons.gm.home.y<60 then
  buttons.gm.reset.vy=0
  buttons.gm.home.vy=0
 
	 if gameOverState==0 then
	  rectb(buttons.gm.reset.x+cos((t/24)*2)*4,buttons.gm.reset.y+sin((t/24)*2)*4,buttons.gm.reset.w,buttons.gm.reset.h,12)
	  if btnp(3)then
	   gameOverState=1
	  elseif btnp(4)then
	   init()
	  end
	 elseif gameOverState==1 then
	  rectb(buttons.gm.home.x+cos((t/24)*2)*4,buttons.gm.home.y+sin((t/24)*2)*4,buttons.gm.home.w,buttons.gm.home.h,12)
	  if btnp(2)then
	   gameOverState=0
	  elseif btnp(4)then
	   mode="menu"
	  end
	 end
 end
 
 buttons.gm.reset.y=buttons.gm.reset.y+buttons.gm.reset.vy
 buttons.gm.home.y=buttons.gm.home.y+buttons.gm.home.vy
end

function Menu()
 local w=print("Play",0,-6,13)
 local w2=print("Credits",0,-6,13)
 
 rect(buttons.mn.play.x,buttons.mn.play.y,50,20,0) 
 print("Play",(240-w)//2,66,13)
 rectb(buttons.mn.play.x,buttons.mn.play.y,50,20,13)
 rect(buttons.mn.credits.x,buttons.mn.credits.y,50,20,0)
 print("Credits",(240-w2)//2,96,13)
 rectb(buttons.mn.credits.x,buttons.mn.credits.y,50,20,13)
 
 if menuState==0 then
  print("Play",(240-w)//2,66,12)
  rectb(buttons.mn.play.x,buttons.mn.play.y,50,20,12)
  if btnp(1)then
   menuState=1
  elseif btnp(4)then
   mode="world"
  end
 elseif menuState==1 then
  print("Credits",(240-w2)//2,96,12)
  rectb(buttons.mn.credits.x,buttons.mn.credits.y,50,20,12)  
  if btnp(0)then
   menuState=0
  elseif btnp(4)then
   mode="credits"
  end
 end
end

init()
mode="menu"
function TIC()
 if mode=="menu" then
	 cls()
		map(0,17*3,31,18)
		
		elli(30,122-cos((t/32)*2)*2,10,5,11)
		ellib(30,122-cos((t/32)*2)*2,10,5,12)
		circ(30,30-cos((t/32)*2)*2,10,12)
		circb(30,30-cos((t/32)*2)*2,10,11)
		spr(256,0,40+cos((t/16)*2)*6,10,4,0,0,2,2)
		spr(256,110+16*4,40+sin((t/16)*2)*6,10,4,1,0,2,2)
		
		local w=print(" Super\nChicken\n Jumper",0,-64,12,false,2)
		print(" Super\nChicken\n Jumper",(240-w)//2,10,11,false,2)
		
		Menu()
		
	elseif mode=="world"then
	 cls()	
		timerWorld=timerWorld-1
		
		local w=print("World 1",0,-6)
		print("World 1",(240-w)//2,68,12)
		
		if timerWorld<0 then
		 mode="game"
		end
		
	elseif mode=="game"then
	 cls(0) 
	 map(mx//8,my//8,31,18,-(mx%8),-(my%8),-1,1)
		Clouds()
		mx=mx+1
		
		attack()
		playerDrw()
		playerUpd()
		
		
		for _,v in ipairs(world.ents)do
		 if v.name=="tree"then
			 treeDrw(v)
			elseif v.name=="rock"then
			 rockDrw(v)
			end
			
			if debug then
			 rectb(v.x+1,v.y+2,v.w,v.h,12)
			end
		end
		partsUpd()
		treeUpd()
		rockUpd()
		
		elli(30,122-cos((t/32)*2)*2,10,5,11)
		ellib(30,122-cos((t/32)*2)*2,10,5,12)
		circ(30,30-cos((t/32)*2)*2,10,12)
		circb(30,30-cos((t/32)*2)*2,10,11)
		
		if p.die then
		 GameOver()
		end
		
		print(score,10,0,12)
		
		if debug then
		 print("vx: "..p.vx.." vy: "..p.vy,0,0,12)
		 rectb(p.x,p.y,p.w,p.h,12)
		end
	elseif mode=="credits"then
	 cls()
		partsUpd()
		for i=0,10 do
		 if (t)%8==0 then
				to(world.parts,{mode=0,x=24*i,y=126,size=2,vy=-0.5,max=70,c=paleteCredit[((math.ceil(t/80))%#paleteCredit)+1]})
		  to(world.parts,{mode=1,x=24*i,y=0,w=2,h=2,vy=1,max=700,c=math.ceil(t/40)})
			end
		end
		print("Hello. This game is a recreation of\nSuper Chicken Jumper on the TIC-80 engine,\na game created by youtuber 'Gemaplys', I did\nthis 'job' hoping to demonstrate how much I\nlike his work ('v').",0,50,12)
		print("Twitter: @ATS_xp",0,130,12)
	 print("X to back",180,130,12)
		
		if btnp(5)then
		 mode="menu"
		end
	
	end
	t=t+1
end
