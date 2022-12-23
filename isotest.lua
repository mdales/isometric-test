t=0
W=240
H=136

mapc={}
maph={}
mapW=100
mapH=100

-- start in the middle
cx=mapW//2
cy=mapH//2

function BOOT()
  for y=1,mapH do
    c={}
    h={}
    for x=1,mapW do
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
      if h[x] > 0 then
		      if math.random() < 0.1 then
		        c[x]=7
		      end
		    end
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
  tree=c==7
  if tree then c=5 end
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
			if tree then
			  tri(
					  xo,yo,
							xo-3,yo-1,
							xo,yo-10,
							7
					)
			  tri(
					  xo,yo,
							xo+3,yo-1,
							xo,yo-10,
							7
					)
			end
  end
end

function drawmap()
  mx=W//2
  my=H//2
  rectb(mx-mapW//2, my-mapH//2, mapW+2, mapH+2, 12)
  for y=1,mapH do
    row=mapc[y]
    rowh=maph[y]
    for x=1,mapW do
      c=row[x]
      if rowh[x] < 1 then c=5+c end
      if x==cx and y==cy then c=2 end
      pix(
        x+(W-mapW)//2,
        (mapH+(H-mapH)//2)-(y-1),
        c
      )
    end
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
   ox=cx
   oy=cy
  	if btn(0) or key(23) then oy=oy+1 end
	  if btn(1) or key(19) then oy=oy-1 end
	  if btn(2) or key(01) then ox=ox-1 end
	  if btn(3) or key(04) then ox=ox+1 end
			dh = math.abs(maph[cy][cx]-maph[oy][ox])
			if (mapc[oy][ox] ~= 7) and 
			   (dh <= 1) then
						cx=ox
						cy=oy
						w=0
			else
			  w=1
			end
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
			  cx=mapW//2
					cy=mapH//2
			end
			if cx<6 then
			  cx=6
					w=1
			end
			if cy<6 then
			  cy=6
			  w=1
			end
			if cx>95 then
			  cx=95
					w=1
		 end
			if cy>95 then
			  cy=95
					w=1
			end
			
			if w==1 then cls(8) else cls(0) end
  	drawgrid()
   if key(49) then drawmap() end
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

