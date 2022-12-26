-- input: gamepad or keyboard
-- saveid: isotest

t=0
W=240
H=136

chunks={}

mapc={}
mapW=16*8
mapH=16*8

-- start in the middle
cx=mapW//2
cy=mapH//2
cd=0 --n,e,s,w

function worldgen(chunk)
  xc=((chunk>>16)-0x7fff)*16
  yc=((chunk&0xFFFF)-0x7fff)*16
  seed=pmem(0)
  math.randomseed(seed+xc*yc)
  m={}
  for y=0,15 do
    r={}
    for x=0,15 do
      ix=xc+x
      iy=yc+y
      c=(math.random()*2)+5
      h=math.abs(
        (
          math.cos(
            (ix+iy/2)/(math.pi/1)
          )*2
          +
          math.sin(
            (ix/3+iy/3)/(math.pi/2)
          )*2
        )
        //1
      )
      if h>0 then
		      if math.random()<0.1 then
		        c=7
		      end
		    end
						r[x]={colour=c,height=h}
    end
    m[y]=r
  end
  return m
end

function BOOT()
  seed=pmem(0)
  cx=pmem(1)-0x7FFF
  cy=pmem(2)-0x7FFF
  cd=pmem(3)
  if seed==0 then
    seed=tstamp()
    cx=(mapW//2)+0x7FFF
    cy=(mapH//2)+0x7FFF
    cd=0
    pmem(0, seed)
  end
end

function tile(x, y, cell)
  c=cell.colour
  h=cell.height
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
  if player then
    if cd==0 or cd==3 then
      spr(1,xo-8,yo-16,14,1)
      spr(2,xo,yo-16,14,1)
      spr(17,xo-8,yo-8,14,1)
      spr(18,xo,yo-8,14,1)
    else
      spr(2,xo-8,yo-16,14,1,1)
      spr(1,xo,yo-16,14,1,1)
      spr(18,xo-8,yo-8,14,1,1)
      spr(17,xo,yo-8,14,1,1)
    end
  end
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
  rect(mx-mapW//2, my-mapH//2, mapW+2, mapH+2, 0)
  rectb(mx-mapW//2, my-mapH//2, mapW+2, mapH+2, 12)
  for c,m in pairs(chunks) do
    xc=((c>>16)-0x7FFF)*16
    yc=((c&0xFFFF)-0x7FFF)*16
    for y=0,15 do
      r=m[y]
      for x=0,15 do
        ax=xc+x
        ay=yc+y
        col=r[x].colour
        h=r[x].height
        if h<1 then col=5+col end
        if ax==cx and ay==cy then col=2 end
        pix(
          ax+(W-mapW)//2,
          (mapH+(H-mapH)//2)-(ay-1),
          col
        )
      end
    end
  end
end

function getcell(x,y)
  chunk=(((x//16)+0x7fff)<<16)+((y//16)+0x7fff)
  mapc=chunks[chunk]
  if mapc == nil then
    mapc=worldgen(chunk)
    chunks[chunk]=mapc
  end
  return mapc[y%16][x%16]
end

function drawgrid()
  for y=cy+5,cy-5,-1 do
    for x=cx+5,cx-5,-1 do
      c=getcell(x,y)
      tile(x-cx+5,y-cy+5,c)
    end
  end
end

function drawcompass(x,y)
  --north
  tri(x+10,y+10,x+20,y+15,x+20,y+13,3)
  tri(x+10,y+10,x+20,y+15,x+18,y+15,3)
  print('N',x+4,y+4,13)
  --east
  tri(x+30,y+10,x+20,y+15,x+20,y+13,14)
  tri(x+30,y+10,x+20,y+15,x+22,y+15,14)
  print('E',x+31,y+4,14)
  --south
  tri(x+30,y+20,x+20,y+15,x+22,y+15,14)
  tri(x+30,y+20,x+20,y+15,x+20,y+17,14)
  print('S',x+31,y+21,14)
  --west
  tri(x+10,y+20,x+20,y+15,x+20,y+17,14)
  tri(x+10,y+20,x+20,y+15,x+18,y+15,14)
  print('W',x+4,y+21,14)
end

function gettarget()
  tx=cx
  ty=cy
  if cd==0 then
    ty=ty+1
  elseif cd==1 then
    tx=tx+1
  elseif cd==2 then
    ty=ty-1
  elseif cd==3 then
    tx=tx-1
  end
  return {tx,ty}
end

function TIC()
 if t%10==0 then
   ox=cx
   oy=cy
  	if btn(0) or key(23) then
     oy=oy+1
     cd=0
   end
	  if btn(1) or key(19) then
			  oy=oy-1
					cd=2
			end
	  if btn(2) or key(01) then
			  ox=ox-1
					cd=3
			end
	  if btn(3) or key(04) then
			  ox=ox+1
					cd=1
			end
			cc=getcell(cx,cy)
			oc=getcell(ox,oy)
			dh=math.abs(cc.height-oc.height)
			if (oc.colour~=7) and (dh<=1) then
			  cx=ox
					cy=oy
					w=0
			else
			  w=1
			end
			if key(15) then
			  cx=50
					cy=50
			end
			if key(5) then
			  local t=gettarget()
					cell=getcell(t[1],t[2])
			  h=cell.height
					if h > 0 then h=h-1 end
					cell.height=h
			end
			if key(17) then
			  local t=gettarget()
					cell=getcell(t[1],t[2])
			  h=cell.height
					cell.height=h+1
			end
			
			-- render
		 cc=0
			if w==1 then cc=8 end
			cls(cc)
			poke(0x3FF8*2,cc,4)
  	drawgrid()
   drawcompass(195,5)
   if key(49) then drawmap() end
			print(tostring(cx)..', '..tostring(cy), 10, 10, 11)
   
   -- save
   pmem(1, cx+0x7FFF)
   pmem(2, cy+0x7FFF)
   pmem(3, cd)
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

