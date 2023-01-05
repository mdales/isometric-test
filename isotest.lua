-- input: gamepad or keyboard
-- saveid: isotest

t=0
W=240
H=136

chunks={}
entities={}

mapc={}
mapW=16*8
mapH=16*8

-- start in the middle
cx=mapW//2
cy=mapH//2
cd=0 --n,e,s,w
ci=nil --current interaction target

function worldgen(chunk)
  xc=((chunk>>16)-0x7fff)
  yc=((chunk&0xFFFF)-0x7fff)
  seed=pmem(0)
  math.randomseed(seed+xc*yc) -- for tree gen
  m={}
  for y=0,15 do
    r={}
    for x=0,15 do
      c=(math.random()*2)+5
      h=3+((perlin:noise(xc+(x/16),yc+(y/16),seed)*8)//1)
      local t=perlin:noise(xc+(x/16),yc+(y/16),seed+20)
      if h>0 and t>0.3 then
          c=7
      else
        c=(6+t*2)//1
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
  -- generate entities before seed
  -- so they're not deterministic
  math.randomseed(seed)
  for i=1,10 do
    entities[i]={
      name="npc "..tostring(i),
      cx=(math.random()*mapW)//1,
      cy=(math.random()*mapH)//1,
      cd=(math.random()*4)//1,
      busy=false
    }
  end
end

function tile(x, y, cell)
  c=cell.colour
  h=cell.height
  if h<=0 then
    c=10+math.max(h,-2)
    h=0
  end
  player=x==5 and y==5
  hs=10
  vs=5
  ds=3
  xo=(W/2)+(x*hs)-(y*hs)
  yb=H-(10+(x*vs)+(y*vs))
  yo=yb-(h*ds)
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
  for i=1,#entities do
    e=entities[i]
    if e.cx==cx+x-5 and e.cy==cy+y-5 then
      if (t%100)==0 then m=2 else m=0 end
      if e.cd==0 or e.cd==3 then
        spr(1+m,xo-8,yo-16,14,1)
        spr(2+m,xo,yo-16,14,1)
        spr(17+m,xo-8,yo-8,14,1)
        spr(18+m,xo,yo-8,14,1)
      else
        spr(2+m,xo-8,yo-16,14,1,1)
        spr(1+m,xo,yo-16,14,1,1)
        spr(18+m,xo-8,yo-8,14,1,1)
        spr(17+m,xo,yo-8,14,1,1)
      end
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
        if h<1 then col=10+math.max(-2,h) end
        pix(
          ax+(W-mapW)//2,
          (mapH+(H-mapH)//2)-(ay-1),
          col
        )
      end
    end
  end
  -- add entites
  for i=1,#entities do
    local e=entities[i]
    -- if the entity is not in a
    -- loaded chunk, skip
    local v=pix(
      e.cx+(W-mapW)//2,
      (mapH+(H-mapH)//2)-(e.cy-1)
    )
    if v~=0 then
		    circ(
		      e.cx+(W-mapW)//2,
		      (mapH+(H-mapH)//2)-(e.cy-1),
		      2,
		      12
		    )
				end
  end
  -- add players
  circ(
    cx+(W-mapW)//2,
    (mapH+(H-mapH)//2)-(cy-1),
    2,
    2
  )
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
  if cd==0 then pc=3;tc=13 else pc=14;tc=14 end
  tri(x+10,y+10,x+20,y+15,x+20,y+13,pc)
  tri(x+10,y+10,x+20,y+15,x+18,y+15,pc)
  print('N',x+4,y+4,tc)
  --east
  if cd==1 then pc=3;tc=13 else pc=14;tc=14 end
  tri(x+30,y+10,x+20,y+15,x+20,y+13,pc)
  tri(x+30,y+10,x+20,y+15,x+22,y+15,pc)
  print('E',x+31,y+4,tc)
  --south
  if cd==2 then pc=3;tc=13 else pc=14;tc=14 end
  tri(x+30,y+20,x+20,y+15,x+22,y+15,pc)
  tri(x+30,y+20,x+20,y+15,x+20,y+17,pc)
  print('S',x+31,y+21,tc)
  --west
  if cd==3 then pc=3;tc=13 else pc=14;tc=14 end
  tri(x+10,y+20,x+20,y+15,x+20,y+17,pc)
  tri(x+10,y+20,x+20,y+15,x+18,y+15,pc)
  print('W',x+4,y+21,tc)
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

function canmove(ox,oy,dx,dy)
  local o=getcell(ox,oy)
  local d=getcell(dx,dy)

  -- step height check
  dh=math.abs(o.height-d.height)
  if dh>1 then return false end

  -- entity bump check
		ec=false
		local i
		for i=1,#entities do
		  e=entities[i]
				if dx==e.cx and dy==e.cy then
				  return false
				end
		end
		
		-- player bump check (for entites)
		if ((dx~=ox) or (dy~=oy)) and 
		  ((dx==cx) and (dy==cy)) then
				return false
		end

		-- tree bump
		if d.colour==7 then return false end

  return true
end

function drawbusy()

  cls(9)
  local c=getcell(cx,cy)
  rect(0,H//2,W,H//2,c.colour)
  
  local m=0
  if (t%100)==0 then m=2 end
     
  --player
  xo=(W//2)-((8*4*2)+20)
  yo=(H//2)-(8*4)
  print("player",55,yo-12,12)
  spr(2+m,xo,yo,14,4,1)
  spr(1+m,xo+(8*4),yo,14,4,1)
  spr(18+m,xo,yo+(8*4),14,4,1)
  spr(17+m,xo+(8*4),yo+(8*4),14,4,1)
  --entity
  m=0
  if (t%90)==0 then m=2 end
  xo=(W//2)+20
  print(ci.name,(W//2)+30,yo-12,12)
  spr(1+m,xo,yo,14,4)
  spr(2+m,xo+(8*4),yo,14,4)
  spr(17+m,xo,yo+(8*4),14,4)
  spr(18+m,xo+(8*4),yo+(8*4),14,4)
end

function TIC()
 if t%10==0 then
   ox=cx
   oy=cy
  	if btn(0) or key(23) then
     if cd==0 then 
       oy=oy+1
     else
       cd=0
     end
   end
	  if btn(1) or key(19) then
			  if cd==2 then
  					oy=oy-1
		   else
  					cd=2
     end
			end
	  if btn(2) or key(01) then
			  if cd==3 then
  					ox=ox-1
		   else
							cd=3
					end
			end
	  if btn(3) or key(04) then
			  if cd==1 then
  					ox=ox+1
		   else
							cd=1
					end
			end
			if canmove(cx,cy,ox,oy) then
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
			  if ci==nil then
					  local t=gettarget()
							for i=1,#entities do
							  local e=entities[i]
									if t[1]==e.cx and t[2]==e.cy then
									  ci=e
											break
									end
							end
									
							if ci==nil then 
		  					local cell=getcell(t[1],t[2])
				  	  local h=cell.height
						  	if h > 0 then h=h-1 end
							  cell.height=h
							end
					else
					  -- we were in an interaction
					  ci=nil
					end
					
			end
			if key(17) then
			  local t=gettarget()
					cell=getcell(t[1],t[2])
			  h=cell.height
					cell.height=h+1
			end

			-- move entities
			for i=1,#entities do
					local e=entities[i]
					-- if the chunk the entity is in
					-- is not loaded, skip
					-- if the entity is being interacted
					-- with, skip
					local c=(((e.cx//16)+0x7fff)<<16)+((e.cy//16)+0x7fff)
     if chunks[c]~=nil and ci~=e then
					  if math.random()<0.1 then
									tx=e.cx
									ty=e.cy
									td=(math.random()*4)//1
									if td==0 then
									  ty=ty+1
									elseif td==1 then
									  tx=tx+1
									elseif td==2 then
									  ty=ty-1
									elseif td==3 then
									  tx=tx-1
									end
		
									if canmove(e.cx,e.cy,tx,ty) then
									  e.cx=tx
									  e.cy=ty
											e.cd=td
									end
							end
	    end
			end

			-- render
		 cc=0
			if w==1 then cc=8 end
			cls(cc)
			poke(0x3FF8*2,cc,4)
			if ci==nil then 
    	drawgrid()
     drawcompass(195,5)
     if key(49) then drawmap() end
			  print(tostring(cx)..', '..tostring(cy), 10, 10, 11)
   else
     drawbusy()
   end 

   -- save
   pmem(1, cx+0x7FFF)
   pmem(2, cy+0x7FFF)
   pmem(3, cd)
 end

 t=t+1
end


-- begin perlin lib code
perlin = {}
perlin.ken = {151,160,137,91,90,15,
  131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
  190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
  88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
  77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
  102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
  135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
  5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
  223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
  129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
  251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
  49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
  138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
}

function perlin:permutation(x)
  -- Hash lookup table as defined by Ken Perlin
  -- This is a randomly arranged array of all numbers from 0-255 inclusive
  return perlin.ken[(x%0xFF)+1]
end

-- Return range: [-1, 1]
function perlin:noise(x, y, z)
    y = y or 0
    z = z or 0

    -- Calculate the "unit cube" that the point asked will be located in
    local xi = math.floor(x)&255
    local yi = math.floor(y)&255
    local zi = math.floor(z)&255

    -- Next we calculate the location (from 0 to 1) in that cube
    x = x - math.floor(x)
    y = y - math.floor(y)
    z = z - math.floor(z)

    -- We also fade the location to smooth the result
    local u = self.fade(x)
    local v = self.fade(y)
    local w = self.fade(z)

    -- Hash all 8 unit cube coordinates surrounding input coordinate
    local A, AA, AB, AAA, ABA, AAB, ABB, B, BA, BB, BAA, BBA, BAB, BBB
    A   = perlin:permutation(xi) + yi
    AA  = perlin:permutation(A) + zi
    AB  = perlin:permutation(A+1) + zi
    AAA = perlin:permutation(AA)
    ABA = perlin:permutation(AB)
    AAB = perlin:permutation(AA+1)
    ABB = perlin:permutation(AB+1)

    B   = perlin:permutation(xi+1) + yi
    BA  = perlin:permutation(B) + zi
    BB  = perlin:permutation(B+1) + zi
    BAA = perlin:permutation(BA)
    BBA = perlin:permutation(BB)
    BAB = perlin:permutation(BA+1)
    BBB = perlin:permutation(BB+1)

    -- Take the weighted average between all 8 unit cube coordinates
    return self.lerp(w,
        self.lerp(v,
            self.lerp(u,
                self:grad(AAA,x,y,z),
                self:grad(BAA,x-1,y,z)
            ),
            self.lerp(u,
                self:grad(ABA,x,y-1,z),
                self:grad(BBA,x-1,y-1,z)
            )
        ),
        self.lerp(v,
            self.lerp(u,
                self:grad(AAB,x,y,z-1), self:grad(BAB,x-1,y,z-1)
            ),
            self.lerp(u,
                self:grad(ABB,x,y-1,z-1), self:grad(BBB,x-1,y-1,z-1)
            )
        )
    )
end

-- Gradient function finds dot product between pseudorandom gradient vector
-- and the vector from input coordinate to a unit cube vertex
perlin.dot_product = {
    [0x0]=function(x,y,z) return  x + y end,
    [0x1]=function(x,y,z) return -x + y end,
    [0x2]=function(x,y,z) return  x - y end,
    [0x3]=function(x,y,z) return -x - y end,
    [0x4]=function(x,y,z) return  x + z end,
    [0x5]=function(x,y,z) return -x + z end,
    [0x6]=function(x,y,z) return  x - z end,
    [0x7]=function(x,y,z) return -x - z end,
    [0x8]=function(x,y,z) return  y + z end,
    [0x9]=function(x,y,z) return -y + z end,
    [0xA]=function(x,y,z) return  y - z end,
    [0xB]=function(x,y,z) return -y - z end,
    [0xC]=function(x,y,z) return  y + x end,
    [0xD]=function(x,y,z) return -y + z end,
    [0xE]=function(x,y,z) return  y - x end,
    [0xF]=function(x,y,z) return -y - z end
}
function perlin:grad(hash, x, y, z)
    return self.dot_product[hash&0xF](x,y,z)
end

-- Fade function is used to smooth final output
function perlin.fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

function perlin.lerp(t, a, b)
    return a + t * (b - a)
end
-- end perlin lib code

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

