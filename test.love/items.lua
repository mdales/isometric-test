require "terrain"

items = {
	types = {},
	instances = {}
}

items_save_name = "items.sav"

function items.load()
	table.insert(items.types, items.init_item("Collectables/SpriteSheets/Items_BlueGem.png", 4))
	table.insert(items.types, items.init_item("Collectables/SpriteSheets/Items_Book.png"))
	table.insert(items.types, items.init_item("Collectables/SpriteSheets/Items_Coin.png"))
	table.insert(items.types, items.init_item("Collectables/SpriteSheets/Items_Coin.png"))
	table.insert(items.types, items.init_item("Collectables/SpriteSheets/Items_Egg.png", 4))
	table.insert(items.types, items.init_item("Collectables/SpriteSheets/Items_GreenGem.png", 4))
	table.insert(items.types, items.init_item("Collectables/SpriteSheets/Items_Hpot.png"))
	table.insert(items.types, items.init_item("Collectables/SpriteSheets/Items_Key.png"))
	table.insert(items.types, items.init_item("Collectables/SpriteSheets/Items_Mpot.png"))
	table.insert(items.types, items.init_item("Collectables/SpriteSheets/Items_RedGem.png", 4))
	table.insert(items.types, items.init_item("Collectables/SpriteSheets/Items_Ring.png", 4))
	table.insert(items.types, items.init_item("Collectables/SpriteSheets/Items_Scroll.png"))
	table.insert(items.types, items.init_item("Collectables/SpriteSheets/Items_Star.png"))

	if love.filesystem.getInfo(items_save_name) then
		items.instances = TSerial.unpack(love.filesystem.read(items_save_name))
	end
end

function items.save()
	love.filesystem.write(items_save_name, TSerial.pack(items.instances))
end

function items.generate(chunk)
	-- called when there's a new chunk
	local xc, yc = terrain.chunkToCoords(chunk)
	local count = 0
	local chance = math.random()
	if chance < 0.05 then count = 3 end
	if chance < 0.10 then count = 2 end
	if chance < 0.20 then count = 1 end
	for i = 1, count do
		local cx = math.floor(math.random() * terrain.chunksize) + (xc * terrain.chunksize)
		local cy = math.floor(math.random() * terrain.chunksize) + (yc * terrain.chunksize)
		local t = terrain.getcell(cx, cy)
		if t.block.passable then
			table.insert(items.instances, {
				t = math.floor(math.random() * #items.types) + 1,
				cx = cx,
				cy = cy,
				mode = 0
			})
		end
	end
end

function items.init_item(imagename, frames_override)
	local sprite_sheet = love.image.newImageData(imagename)
	assert(sprite_sheet ~= nil)
	local this_item = {
		frames = {}
	}
	local w, h = sprite_sheet:getDimensions()
	assert (w % h == 0)
	local frames = w / h
	if frames_override ~= nil then
		frames = frames_override
	end
	for i = 1, frames do
		local frame = love.image.newImageData(h, h)
		frame:paste(sprite_sheet, 0, 0, ((i-1) * h), 0, h, h)
		local img = love.graphics.newImage(frame)
		img:setFilter("nearest")
		table.insert(this_item.frames, img)
	end
	return this_item
end