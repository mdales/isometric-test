require "terrain"

entities={
	player = {
		cx=50,
		cy=50,
		cd=2,
		mode=0, -- 0= standing, 1&2=walking
		hue={1,1,1},
		target=nil
	},
	npcs = {}
}

player_save_name = "player.sav"
npcs_save_name = "npcs.sav"

function entities.load()
	if love.filesystem.getInfo(player_save_name) then
		entities.player = TSerial.unpack(love.filesystem.read(player_save_name))
	end
	if love.filesystem.getInfo(npcs_save_name) then
		entities.npcs = TSerial.unpack(love.filesystem.read(npcs_save_name))
	end
	-- after we load the npcs, simulate them briefly so they're not just
	-- where we left them last time. we need to force the chunks near the player
	-- in for this to work
	for y = -1, 1 do
		for x = -1, 1 do
			_ = terrain.getcell(entities.player.cx + (x * 6), entities.player.cy + (y * 6))
		end
	end
	for i=1,100 do
		entities.update()
	end
end

function entities.save()
	entities.player.target = nil
	love.filesystem.write(player_save_name, TSerial.pack(entities.player))
	love.filesystem.write(npcs_save_name, TSerial.pack(entities.npcs))
end

function entities.generate(chunk)
	-- called when there's a new chunk
	local xc, yc = terrain.chunkToCoords(chunk)
	local count = 0
	local chance = math.random()
	if chance < 0.01 then count = 3 end
	if chance < 0.05 then count = 2 end
	if chance < 0.10 then count = 1 end
	local prevcount = #entities.npcs
	for i = 1, count do
		local cx = math.floor(math.random() * 16) + (xc * 16)
		local cy = math.floor(math.random() * 16) + (yc * 16)
		local t = terrain.getcell(cx, cy)
		if t.block.passable then
			table.insert(entities.npcs, {
				name = "npc "..tostring(i+prevcount),
				cx = cx,
				cy = cy,
				cd = math.floor(math.random() * 4),
				hue = {math.random()*0.5 + 0.5, math.random()*0.5+0.5, math.random()*0.5+0.5},
				mode = 0,
				busy = false
			})
		end
	end
end

function entities.update()
	for i = 1, #entities.npcs do
		local e = entities.npcs[i]
		-- if the chunk the entity is in
		-- is not loaded, skip
		-- if the entity is being interacted
		-- with, skip
		local c = ((math.floor(e.cx / 16) + 0x7fff) * 2^16) + (math.floor(e.cy / 16) + 0x7fff)
		if terrain.generated.chunks[c] ~= nil and entities.player.target ~= e then
			if math.random() < 0.1 then
				local tx = e.cx
				local ty = e.cy
				local td = e.cd
				if math.random() < 0.5 then
					td = math.floor(math.random() * 4)
				end
				if td == 0 then
					ty = ty + 1
				elseif td == 1 then
					tx = tx + 1
				elseif td == 2 then
					ty = ty - 1
				elseif td == 3 then
					tx = tx - 1
				end

				if entities.canmove(e.cx, e.cy, tx, ty) then
					e.cx=tx
					e.cy=ty
					e.cd=td
					e.mode = (e.mode + 1) % 4
				else
					e.mode = 0
				end
			else
				e.mode = 0
			end
		end
	end
end

function entities.canmove(ox, oy, dx, dy)
	local o = terrain.getcell(ox, oy)
	local d = terrain.getcell(dx, dy)

	-- sometimes people spawn in illegal locations, so
	-- force them to move if so
	if not o.block.passable then return true end

	-- step height check
	local dh = math.abs(o.block.height(o.height) - d.block.height(d.height))
	if dh > 1 then return false end

	-- can we enter block
	if not d.block.passable then return false end

	-- entity bump check
	for i = 1, #entities.npcs do
		local e = entities.npcs[i]
		if dx == e.cx and dy == e.cy then
			return false
		end
	end

	-- player bump check (for entities)
	if ((dx ~= ox) or (dy ~= oy)) and ((dx == entities.player.cx) and (dy == entities.player.cy)) then
		return false
	end

	return true
end

function entities.gettarget(entity)
	local tx = entity.cx
	local ty = entity.cy
	if entity.cd == 0 then
		ty = ty + 1
	elseif entity.cd == 1 then
		tx = tx + 1
	elseif entity.cd == 2 then
		ty = ty - 1
	elseif entity.cd == 3 then
		tx = tx - 1
	end
	return {tx, ty}
end
