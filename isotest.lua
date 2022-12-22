t=0
W=240
H=136

cx=50
cy=50

mapc={}
maph={}

function BOOT()
  for y=1,100 do
    c={}
    h={}
    for x=1,100 do
      c[x]=(math.random()*2) + 5
      h[x]=math.abs(
        (
          math.cos(
            (x+y/2)/(math.pi/1)
          )*2
          +
          math.sin(
            (x/3+y/3)/(math.pi/2)
          )*2
        )
        //1
      )
    end
    mapc[y]=c
    maph[y]=h
  end
end

function tile(x, y, h, c)
  player=x==5 and y==5
  hs=10
  vs=5
  ds=3
  xo=(W/2)+(x*hs)-(y*hs)
  yb=H-(10+(x*vs)+(y*vs))
  yo=yb-(h*ds)
  if h==0 then 
    c=5+c
  end
  if player then
    c=2
  end

  tri(
    xo, yo+vs,
    xo-hs, yo,
    xo+hs, yo,
    c
  ) 
  tri(
    xo, yo-vs,
    xo-hs, yo,
    xo+hs, yo,
    c
  )
  if yo~=yb then
	  tri(
	    xo-hs,yo,
	    xo-hs,yb,
	    xo,yb+vs,
	    13
	  )
			tri(
			  xo-hs,yo,
			  xo,yo+vs,
					xo,yb+vs,
					13
			)
			tri(
			  xo+hs,yo,
					xo+hs,yb,
					xo,yb+vs,
					14
			)
			tri(
			  xo+hs,yo,
			  xo,yo+vs,
					xo,yb+vs,
					14
			)
  end
end

function drawgrid()
  for y=cy+5,cy-5,-1 do
    c=mapc[y]
    h=maph[y]
    if c then 
      for x=cx+5,cx-5,-1 do
        tile(x-cx+5,y-cy+5,h[x],c[x])
      end
    end
  end
end

function TIC()

 if t%10==0 then 
  	if btn(0) then cy=cy+1 end
	  if btn(1) then cy=cy-1 end
	  if btn(2) then cx=cx-1 end
	  if btn(3) then cx=cx+1 end
			if key(5) then
			  h=maph[cy][cx]
					if h > 0 then h=h-1 end
					maph[cy][cx]=h 
			end
			if key(17) then
			  h=maph[cy][cx]
					maph[cy][cx]=h+1 
			end
			if key(18) then
			  cx=50
					cy=50
			end
			if cx<5 then cx=5 end
			if cy<5 then cy=5 end
			if cx>95 then cx=95 end
			if cy>95 then cy=95 end
			
			
  	cls(0)
	  drawgrid()
			print(tostring(cx)..', '..tostring(cy), 10, 10, 11)
 end
 
 t=t+1
end

-- <TILES>
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

