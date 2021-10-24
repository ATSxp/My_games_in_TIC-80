-- title:  Riding a Human Being
-- author: @ATS_xp
-- desc:   Build a female character your way
-- script: lua

t=0
debug=false

mode="menu"
menuState=0

passState=0
confirmPassword=false

word1,word2,word3,word4,word5,word6=3,3,3,3,3,3

cos=math.cos
sin=math.sin
rand=math.random

hairState=1
acessoryState=1
shirtState=1
slotState=0

w={ -- Woman

 genre = "woman",
 x = (240-(64+20))//2,
 y = 10,
 eyesAnim={462,478,494,510,510,494,478,462,462,462,462,462,462,462,462,462,462,462,462,462,462,462,462},
 eyesAnim2={398,414,430,446,446,430,414,398,398,398,398,398,398,398,398,398},
 clothes={
 	isNaked = false,
 },

}

function Menu()
 cls()
 
 for i=0,6 do 
  line(8*i+10,0,32*i+10,136,12+(t/8))
 end
 rectb(10,48+cos(t/8)*2,217,70,12)
 
 local w=print("Riding a Human Being",0,-16,12,false,2)
  
 print("Riding a Human Being",(239-w)//2,((138//2)-16)+cos(t/8)*2,13,false,2)
 print("Riding a Human Being",(240-w)//2,((136//2)-16)+cos(t/8)*2,12,false,2)
 print("Play",14,89+cos(t/8)*2,13,false,1,true)
 print("Play",15,88+cos(t/8)*2,12,false,1,true)
 print("Password",14,99+cos(t/8)*2,13,false,1,true)
 print("Password",15,98+cos(t/8)*2,12,false,1,true)
 print("Exit",14,109+cos(t/8)*2,13,false,1,true)
 print("Exit",15,108+cos(t/8)*2,12,false,1,true)
  
 if menuState==0 then
  print("Play",14,89+cos(t/8)*2,1,false,1,true)
  print("Play",15,88+cos(t/8)*2,2,false,1,true)
  if btnp(1)then
   sfx(4,"A-7",8)
   menuState=1
  elseif btnp(4)then
   sfx(3,"B-6",10)
   mode="game"
  end
 elseif menuState==1 then
  print("Password",14,99+cos(t/8)*2,1,false,1,true)
  print("Password",15,98+cos(t/8)*2,2,false,1,true)
  if btnp(0)then
   sfx(4,"A-7",8)
   menuState=0
  elseif btnp(1)then
   sfx(4,"A-7",8)
   menuState=2
  elseif btnp(4)then
   sfx(3,"B-6",10)
   mode="password"
  end
 elseif menuState==2 then
  print("Exit",14,109+cos(t/8)*2,1,false,1,true)
  print("Exit",15,108+cos(t/8)*2,2,false,1,true)
  if btnp(0)then
   sfx(4,"A-7",8)
   menuState=1
  elseif btnp(4)then
   sfx(3,"B-6",10)
   exit()
   if confirmPassword==false then
    trace("Thank you for playing",12)
   else
    trace("Thank you for playing",12)
    trace("('_')You are naughty")
   end
  end
 end 
end

function Game()
 cls(0)
 
	spr(384,w.x,w.y,11,2,0,0,6,8)
	if confirmPassword==false then
		spr(w.eyesAnim[((t//8)%#w.eyesAnim)+1],110,42,11,2,0,0,2,1)
	else
	 spr(w.eyesAnim2[((t//8)%#w.eyesAnim2)+1],110,42,11,2,0,0,2,1)
	 spr(2,20+(sin(t/8)*2)*4,48+(cos(t/8)*2)*4,11,4)
	 spr(2,200+(sin(t/8)*2)*4,48+(cos(t/8)*2)*4,11,4)
	end
	
	if slotState==0 then
	 spr(1,70,20+cos(t/8)*2,11,2,1)
	 spr(1,(70*2)+23,20+sin(t/8)*2,11,2)
	 if btnp(1)then
		 sfx(4,"A-7",8)
	 	slotState=1
	 elseif btnp(3)and hairState<5 then
   sfx(3,"B-6",10)
	  hairState=hairState+1
	 elseif btnp(2)and hairState>0 then
   sfx(3,"B-6",10)
	  hairState=hairState-1
	 end
	elseif slotState==1 then
	 spr(1,70,60+cos(t/8)*2,11,2,1)
	 spr(1,(70*2)+23,60+sin(t/8)*2,11,2)
	 if btnp(0)then
		 sfx(4,"A-7",8)
	 	slotState=0 
	 elseif btnp(1)then
		 sfx(4,"A-7",8)
	 	slotState=2
	 elseif btnp(3)and acessoryState<5 then
   sfx(3,"B-6",10)
	  acessoryState=acessoryState+1
	 elseif btnp(2)and acessoryState>0 then
   sfx(3,"B-6",10)
	  acessoryState=acessoryState-1
	 end 
	elseif slotState==2 then
	 spr(1,70,100+cos(t/8)*2,11,2,1)
	 spr(1,(70*2)+23,100+sin(t/8)*2,11,2)
	 if btnp(0)then
		 sfx(4,"A-7",8)
	 	slotState=1
	 elseif btnp(3)and shirtState<5 then
   sfx(3,"B-6",10)
	  shirtState=shirtState+1
	 elseif btnp(2)and shirtState>0 then
   sfx(3,"B-6",10)
	  shirtState=shirtState-1
	 end
	end
	
	if shirtState==0 then
	 w.clothes.isNaked=true
		spr(w.eyesAnim2[((t//8)%#w.eyesAnim2)+1],110,42,11,2,0,0,2,1)
	else
	 w.clothes.isNaked=false
	end
	
	if hairState==1 then
	 spr(48,94,10,11,2,0,0,4,4)
	elseif hairState==2 then
	 spr(52,94,10,11,2,0,0,4,4)
	elseif hairState==3 then
	 spr(56,94,10,11,2,0,0,4,4)
	elseif hairState==4 then
	 spr(60,94,10,11,2,0,0,4,4)
	elseif hairState==5 then
	 spr(124,94,10,11,2,0,0,4,4)
	end
	
	if shirtState==1 then
	 spr(112,78,74,11,2,0,0,6,4)
	elseif shirtState==2 then
	 spr(118,78,74,11,2,0,0,6,4)
	elseif shirtState==3 then
	 spr(176,78,74,11,2,0,0,6,4)
	elseif shirtState==4 then
	 spr(182,78,74,11,2,0,0,6,4)
	elseif shirtState==5 then
	 spr(256,78,74,11,2,0,0,6,4)
	end
	
	if acessoryState==1 then
	 spr(16,110,58,11,2,0,0,2,2)
	elseif acessoryState==2 then
	 spr(18,110,58,11,2,0,0,2,2)
	elseif acessoryState==3 then
	 spr(20,110,58,11,2,0,0,2,2)
	elseif acessoryState==4 then
	 spr(22,110,58,11,2,0,0,2,2)
	elseif acessoryState==5 then
	 spr(24,110,58,11,2,0,0,2,2)
	end
	
	if confirmPassword==false then
	 if w.clothes.isNaked then
		 for i=0,1 do
		 	spr(2,(34*i+95)+rand(-2,2),115+rand(-2,2),11,3)
		 end
		end
	end
	
	if time()>1800000 and shirtState==0 then
	 local ws=print("Password: Up, Down, Left, Right, B, A",0,-6,12)
	 print("Password: Up, Down, Left, Right, B, A",(240-ws)//2,0,12)
	end
	
	if btnp(5)then
	 sfx(3,"B-6",10)
	 mode="menu"
	end
	
	print("X to back",0,131,13)
	print("X to back",1,130,12)
	
	if debug then
	 print("Hair: "..hairState,0,0,12)
	 print("Acessory: "..acessoryState,0,10,12)
	 print("Shirt: "..shirtState,0,20,12)
	end
end

function PassWord()
 cls()
	
 local width=print("Enter",0,-16,12,false,2)
 local wi=print("Error",0,-6,2)
 local w6=print("Confirm ?",0,-6,12)
 
	if word1>8 then
	 word1=3
	elseif word2>8 then
	 word2=3
	elseif word3>8 then
	 word3=3
	elseif word4>8 then
	 word4=3
	elseif word5>8 then
	 word5=3
	elseif word6>8 then
	 word6=3
	end
	
	print("X to back",0,131,13)
	print("X to back",1,130,12)
	print("Enter",(239-width)//2,101+sin(t/8)*2,13,false,2)
	print("Enter",(240-width)//2,100+sin(t/8)*2,12,false,2)
	spr(word1,70,68+cos(t/8)*2,0,2)
	spr(word2,(70+16)+1,68+sin(t/8)*2,0,2)
	spr(word3,(70+16*2)+2,68+cos(t/8)*2,0,2)
	spr(word4,(70+16*3)+3,68+sin(t/8)*2,0,2)
	spr(word5,(70+16*4)+4,68+cos(t/8)*2,0,2)
	spr(word6,(70+16*5)+5,68+sin(t/8)*2,0,2)
 
 if passState==0 then
  rectb(70,68+cos(t/8)*2,16,16,12)
  if btnp(3)then
   sfx(4,"A-7",8)
   passState=1
  elseif btnp(4)then
   sfx(3,"B-6",10)
   word1=word1+1
  end
 elseif passState==1 then
  rectb((70+16)+1,68+sin(t/8)*2,16,16,12)
  if btnp(2)then
   sfx(4,"A-7",8)
   passState=0
  elseif btnp(3)then
   sfx(4,"A-7",8)
   passState=2
  elseif btnp(4)then
   sfx(3,"B-6",10)
   word2=word2+1
  end  
 elseif passState==2 then
  rectb((70+16*2)+2,68+cos(t/8)*2,16,16,12)
  if btnp(2)then
   sfx(4,"A-7",8)
   passState=1
  elseif btnp(3)then
   sfx(4,"A-7",8)
   passState=3
  elseif btnp(4)then
   sfx(3,"B-6",10)
   word3=word3+1
  end
 elseif passState==3 then
  rectb((70+16*3)+3,68+sin(t/8)*2,16,16,12)
  if btnp(2)then
   sfx(4,"A-7",8)
   passState=2
  elseif btnp(3)then
   sfx(4,"A-7",8)
   passState=4
  elseif btnp(4)then
   sfx(3,"B-6",10)
   word4=word4+1
  end
 
 elseif passState==4 then
  rectb((70+16*4)+4,68+cos(t/8)*2,16,16,12)
  if btnp(2)then
   sfx(4,"A-7",8)
   passState=3
  elseif btnp(3)then
   sfx(4,"A-7",8)
   passState=5
  elseif btnp(4)then
   sfx(3,"B-6",10)
   word5=word5+1
  end
 
 elseif passState==5 then
  rectb((70+16*5)+5,68+sin(t/8)*2,16,16,12)
  if btnp(2)then
   sfx(4,"A-7",8)
   passState=4
  elseif btnp(4)then
   sfx(3,"B-6",10)
   word6=word6+1
  end
 elseif passState==6 then
  print("Enter",(239-width)//2,101+sin(t/8)*2,1,false,2)
  print("Enter",(240-width)//2,100+sin(t/8)*2,2,false,2)
  if btnp(4)then
   if word1==3 and word2==6 and word3==5 and word4==4 and word5==8 and word6==7 then
    sfx(2,"A-4",22)
    word1,word2,word3,word4,word5,word6=3,3,3,3,3,3
    confirmPassword=true
   else
    sfx(1,"C#1",15)
    word1,word2,word3,word4,word5,word6=3,3,3,3,3,3
   end
  else
   if confirmPassword==false then
    print("Confirm ?",(239-w6)//2,11,13)
    print("Confirm ?",(240-w6)//2,10,12)
   end
  end
 end
 
 if btnp(1)then
  sfx(4,"A-7",8)
  passState=6
 elseif btnp(0)then
  sfx(4,"A-7",8)
  passState=0
 end
 
 if confirmPassword==true then
  local w5=print("Password confirmed",0,-6,12)
  local w6=print("Censorship withdrawn",0,-6,12)
  print("Password confirmed:",(240-w5)//2,10+cos(t/8)*2,12)
  print("Censorship withdrawn",(240-w6)//2,20+cos(t/8)*2,4)
 end
 
 if btnp(5)then
  sfx(3,"B-6",10)
  mode="menu"
 end
end

function TIC()
 if mode=="menu"then
  Menu()
 elseif mode=="game"then
	 Game()
	elseif mode=="password"then
	 PassWord()
 end
	t=t+1
end
