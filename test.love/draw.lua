require "entities"
require "items"
require "terrain"

hs = 30
vs = 15
ds = 9

draw = {}

function draw.load()
	local characters = love.image.newImageData("Small-8-Direction-Characters_by_AxulArt/Small-8-Direction-Characters_by_AxulArt.png")

	local standing = {}
	for i = 0, 7 do
		local frame = love.image.newImageData(16, 17)
		frame:paste(characters, 0, 0, (i * 16), 45, 16, 17)
		standing[i] = love.graphics.newImage(frame)
		standing[i]:setFilter("nearest")
	end
	local stepleft = {}
	for i = 0, 7 do
		local frame = love.image.newImageData(16, 17)
		frame:paste(characters, 0, 0, (i * 16), 22, 16, 17)
		stepleft[i] = love.graphics.newImage(frame)
		stepleft[i]:setFilter("nearest")
	end
	local stepright = {}
	for i = 0, 7 do
		local frame = love.image.newImageData(16, 17)
		frame:paste(characters, 0, 0, (i * 16), 70, 16, 17)
		stepright[i] = love.graphics.newImage(frame)
		stepright[i]:setFilter("nearest")
	end
	draw.frames={
		standing, stepleft, standing, stepright
	}

	occludes_shader = love.graphics.newShader [[
		extern number time;
		vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
		{
			return vec4(color[0], color[1], color[2], 0.25);
		}
	]]
end

function drawtile(x, y, cell, tick)
	local W, H = love.graphics.getDimensions()

	local block = cell.block
	local h = block.height(cell.height)
	local tree = block.tree

	local player = x==6 and y==6
	local xo = (W / 2) + (x * hs) - (y * hs)
	local yb = (H / 2) - ((x * vs) + (y * vs)) + (13*vs)
	local yo = yb - (h * ds)


	local occludes = false
	if math.abs(x-y)<2 and ((x < 6) or (y < 6)) then

		local c = terrain.getcell(entities.player.cx, entities.player.cy)
		local ch = c.block.height(c.height)
		local cyb = (H / 2) - ((6 * vs) + (6 * vs)) + (13 * vs)
		local cyo = cyb - (ch * ds)

		local xd = ds
		if x ~= y then xd = ds / 2 end

		if yo-xd < cyo then
			occludes = true
		end
	end

	if occludes then
		love.graphics.setShader(occludes_shader)
	end

	--sides
	if yo~=yb then
		love.graphics.setColor(0.6, 0.6, 0.5)
		love.graphics.polygon(
			"fill",
			xo - hs, yo,
			xo - hs, yb,
			xo, yb + vs,
			xo, yo + vs
		)
		love.graphics.setColor(0.4, 0.4, 0.4)
		love.graphics.polygon(
			"fill",
			xo + hs, yo,
			xo + hs, yb,
			xo, yb + vs,
			xo, yo + vs
		)
	end

	-- top
	local c = block.colour(cell.height)
	love.graphics.setColor(c)
	love.graphics.polygon(
		"fill",
		xo, yo + vs,
		xo - hs, yo,
		xo, yo - vs,
		xo + hs, yo
	)

	if tree then
		love.graphics.setColor(0, 0.5, 0)
		love.graphics.polygon(
			"fill",
			xo, yo,
			xo - 9, yo - 3,
			xo, yo - 30
		)
		love.graphics.setColor(0, 0.3, 0)
		love.graphics.polygon(
			"fill",
			xo, yo,
			xo + 9, yo - 3,
			xo, yo - 30
		)
	end

	if occludes then
		love.graphics.setShader()
	end

	if player then
		love.graphics.setColor(entities.player.hue)
		love.graphics.draw(draw.frames[entities.player.mode+1][(((entities.player.cd - 1) * 2) + 1) % 8], xo - 16, yo-32, 0, 2)
	end


	for i=1,#entities.npcs do
	  local e=entities.npcs[i]
	  if e.cx==entities.player.cx+x-6 and e.cy==entities.player.cy+y-6 then
		love.graphics.setColor(e.hue)
		love.graphics.draw(draw.frames[e.mode+1][(((e.cd - 1) * 2) + 1) % 8], xo - 16, yo-32, 0, 2)
	  end
	end

	for i=1,#items.instances do
		local item = items.instances[i]
		if item.cx==entities.player.cx+x-6 and item.cy==entities.player.cy+y-6 then
			love.graphics.setColor(0,0,0,0.3)
			love.graphics.ellipse(
				"fill",
				xo, yo,
				8 - math.cos(tick/2)*2,
				4 - math.cos(tick/2)*1,
				16
			)
			love.graphics.setColor(1,1,1)
			love.graphics.draw(item.t.frames[1+(tick % #item.t.frames)], xo - 16, yo - (36 + math.cos(tick/2)*4), 0, 2)
		end
	end
end

function draw.grid(tick)
	for y = entities.player.cy + 6, entities.player.cy - 6, -1 do
		for x = entities.player.cx + 6, entities.player.cx - 6, -1 do
			local c = terrain.getcell(x, y)
			drawtile(x - entities.player.cx + 6, y - entities.player.cy + 6, c, tick)
		end
	end
end

function draw.compass()
	local W, H = love.graphics.getDimensions()
	local x = W - 100
	local y = 50

	local cd = entities.player.cd

	love.graphics.setColor(0.4, 0.4, 0.4)
	love.graphics.polygon(
		"fill",
		x - math.floor(hs / 3), y + 0,
		x - hs,       y - vs,
		x + 0,        y - math.floor(vs / 3),
		x + hs,       y - vs,
		x + math.floor(hs / 3), y + 0
	)
	love.graphics.polygon(
		"fill",
		x + math.floor(hs / 3), y + 0,
		x + hs,       y + vs,
		x + 0,        y + math.floor(vs / 3),
		x - hs,       y + vs,
		x - math.floor(hs / 3), y + 0
	)
	love.graphics.setColor(0.5, 0.5, 0.5)
	love.graphics.print("N", x - hs - 10, y - vs - 15)
	love.graphics.print("E", x + hs + 2, y - vs - 15)
	love.graphics.print("S", x + hs + 2, y + vs + 0)
	love.graphics.print("W", x - hs - 10, y + vs +0)

	if cd == 0 then
		love.graphics.setColor(1, 0, 0)
		love.graphics.polygon(
			"fill",
			x - hs,       y - vs,
			x + 0,        y - math.floor(vs / 3),
			x + 0, y + 0,
			x - math.floor(hs / 3), y + 0
		)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("N", x - hs - 10, y - vs - 15)
	end
	if cd == 1 then
		love.graphics.setColor(1, 0, 0)
		love.graphics.polygon(
			"fill",
			x + hs,       y - vs,
			x + 0,        y - math.floor(vs / 3),
			x + 0, y + 0,
			x + math.floor(hs / 3), y + 0
		)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("E", x + hs + 2, y - vs - 15)
	end
	if cd == 2 then
		love.graphics.setColor(1, 0, 0)
		love.graphics.polygon(
			"fill",
			x + hs,       y + vs,
			x + 0,        y + math.floor(vs / 3),
			x + 0, y + 0,
			x + math.floor(hs / 3), y + 0
		)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("S", x + hs + 2, y + vs + 0)
	end
	if cd == 3 then
		love.graphics.setColor(1, 0, 0)
		love.graphics.polygon(
			"fill",
			x - hs,       y + vs,
			x + 0,        y + math.floor(vs / 3),
			x + 0, y + 0,
			x - math.floor(hs / 3), y + 0
		)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("W", x - hs - 10, y + vs +0)
	end
end

function draw:map()
	local W, H = love.graphics.getDimensions()
	local mx = math.floor(W / 2)
	local my = math.floor(H / 2)

	local mapW = 512
	local mapH = 512

	love.graphics.setColor(0, 0, 0)
	love.graphics.polygon(
		"fill",
		mx-mapW/2, my-mapH/2,
		mx+mapW/2, my-mapH/2,
		mx+mapW/2, my+mapH/2,
		mx-mapW/2, my+mapH/2
	)
	love.graphics.setColor(1,1,1)
	love.graphics.polygon(
		"line",
		mx-mapW/2, my-mapH/2,
		mx+mapW/2, my-mapH/2,
		mx+mapW/2, my+mapH/2,
		mx-mapW/2, my+mapH/2
	)

	local cx = entities.player.cx
	local cy = entities.player.cy

	for chunk, m in pairs(terrain.generated.chunks) do
		local xc, yc = terrain.chunkToCoords(chunk)
		yc = yc * 16
		xc = xc * 16

		for y = 0, 15 do
			local r = m[y]
			for x = 0, 15 do
				local ax = mx + ((xc + x) - cx)
				local ay = my - ((yc + y) - cy)
				local b = r[x].block
				local h = r[x].height

				local c = b.colour(h)
				if b.tree then c = {0, 0.4, 0} end

				love.graphics.setColor(c)
				love.graphics.points(ax, ay)
			end
		end
	end
	-- add entites
	for i = 1, #entities.npcs do
		local e = entities.npcs[i]
		love.graphics.setColor(e.hue)

		-- if the entity is not in a loaded chunk, skip
		local c = ((math.floor(e.cx / 16) + 0x7fff) * 2^16) + (math.floor(e.cy / 16) + 0x7fff)
		if terrain.generated.chunks[c] ~= nil then
			local ax = mx + (e.cx - cx)
			local ay = my - (e.cy - cy)
			love.graphics.circle("fill", ax, ay, 9)
		end
	end

	-- add players
	love.graphics.setColor(1, 0, 0)
	love.graphics.circle("fill", mx, my, 9)
end

function draw.busy()
	local W, H = love.graphics.getDimensions()
	love.graphics.setBackgroundColor(0.5, 0.5, 1)

	local c = terrain.getcell(entities.player.cx, entities.player.cy)
	love.graphics.setColor(0, c.height/11+0.5, 0)
	love.graphics.polygon(
		"fill",
		0, H / 2,
		W, H / 2,
		W, H,
		0, H
	)

	love.graphics.setColor(1, 1, 1)
	love.graphics.print("player", W/4, 50)
	love.graphics.print(entities.player.target.name, W*3/4, 50)

	-- player
	love.graphics.setColor(entities.player.hue)
	love.graphics.draw(draw.frames[1][(((2 - 1) * 2) + 1) % 8], W/4-(16*8), H/2-(16*8), 0, 16)

	-- entity
	love.graphics.setColor(entities.player.target.hue)
	love.graphics.draw(draw.frames[1][(((3 - 1) * 2) + 1) % 8], W*3/4-(16*8), H/2-(16*8), 0, 16)
end