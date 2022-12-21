t=0
w=240
h=136

x=5
y=5

map={}

function BOOT()
  for y=1,10 do
    r={}
    for x=1,10 do
      r[x]=(math.random()*2) + 5
    end
    map[y]=r
  end
end

function tile(x, y, c)
  hs=10
  vs=5
  xo=(w/2)+(x*hs)-(y*hs)
  yo=h-(10+(x*vs)+(y*vs))

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
end

function drawgrid(x,y)
  for y=1,#map do
    r = map[y]
    for x=1,#r do
      tile(x,y,r[x])
    end
  end
  tile(x,y,11)
end

function TIC()

 if t%10==0 then 
  	if btn(0) then y=y+1 end
	  if btn(1) then y=y-1 end
	  if btn(2) then x=x-1 end
	  if btn(3) then x=x+1 end
			
  	cls(0)
	  drawgrid(x,y)
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

