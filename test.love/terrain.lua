require "perlin"

terrain = {
    generated = {
        seed = 0.213,
        chunks = {},
        modified = {}
    },
    chunksize = 128,
    perlinscale = 16,
    blocks = {
        grass = {
            id = 0,
            colour = function(h) return {0, (h / 11) + 0.5, 0} end,
            tree = false,
            passable = true,
            height = function(h) return h end
        },
        water = {
            id = 1,
            colour = function(h) return {0, 0, 0.5 + 0.5 / (math.abs(h) + 1)} end,
            tree=false,
            passable=false,
            height = function(h) return 0 end
        },
        forest = {
            id = 2,
            colour = function(h) return {0, (h / 11) + 0.5, 0} end,
            tree=true,
            passable=false,
            height = function(h) return h end
        },
        rock = {
            id = 3,
            colour = function(h) return {(h / 22) + 0.5, (h / 22) + 0.3, (h / 22) + 0.1} end,
            tree=false,
            passable=true,
            height = function(h) return h + 2 end
        },
        mud = {
            id = 4,
            colour = function(h) return {(h / 44) + 0.4, (h / 44) + 0.25, (h / 44) + 0.1} end,
            tree = false,
            passable = true,
            height = function(h) return h end
        }
    }
}

terrain_save_name = "terrain.sav"

function terrain.load()
    if love.filesystem.getInfo(terrain_save_name) then
        terrain.generated = TSerial.unpack(love.filesystem.read(terrain_save_name))
        -- we now need to patch back in the functions that were dropped when we serialised the data
        local table_map = {}
        for _, block in pairs(terrain.blocks) do
            table_map[block.id] = block
        end
        for k, chunk in pairs(terrain.generated.modified) do
            for i = 1,terrain.chunksize do
                local row = chunk[i-1]
                for j = 1,terrain.chunksize do
                    local tile = row[j-1]
                    local id = tile.block.id
                    tile.block = table_map[id]
                end
            end
        end
        for k, v in pairs(terrain.generated.modified) do
            terrain.generated.chunks[k] = v
        end
    end
end

function terrain.save()
    for k, _ in pairs(terrain.generated.chunks) do
        terrain.generated.chunks[k] = {}
    end
    love.filesystem.write(terrain_save_name, TSerial.pack(terrain.generated, true, false))
end

function terrain.chunkToCoords(chunk)
    local xc = math.floor((chunk / 2^16) - 0x7fff)
    local yc = math.floor((chunk % 2^16) - 0x7fff)
    return xc, yc
end

function terrain.coordsToChunk(x, y)
    return ((math.floor(x / terrain.chunksize) + 0x7fff) * 2^16) + (math.floor(y / terrain.chunksize) + 0x7fff)
end

function terrain.getcell(x, y)
    local chunk = terrain.coordsToChunk(x, y)
    local mapc = terrain.generated.chunks[chunk]
    if mapc == nil or mapc[0] == nil then
        local regen = mapc ~= nil
        mapc = terrain.worldgen(chunk)
        terrain.generated.chunks[chunk] = mapc
        if not regen then
            entities.generate(chunk)
            items.generate(chunk)
        end
    end
    return mapc[y % terrain.chunksize][x % terrain.chunksize]
end

function terrain.markCellModified(x, y)
    local chunk = terrain.coordsToChunk(x, y)
    terrain.generated.modified[chunk] = terrain.generated.chunks[chunk]
end

function scaledperlinvalue(mapx, mapy, z, perlinscale)
    local perlinx = math.floor(mapx / perlinscale)
    local perliny = math.floor(mapy / perlinscale)
    local perlinoffsetx = (mapx % perlinscale) / perlinscale
    local perlinoffsety = (mapy % perlinscale) / perlinscale
    return perlin:noise(perlinx + perlinoffsetx, perliny + perlinoffsety, z)
end

function terrain.worldgen(chunk)
    local xc, yc = terrain.chunkToCoords(chunk)
    local m = {}

    for y = 0,(terrain.chunksize - 1) do
        local r = {}
        for x = 0,(terrain.chunksize - 1) do
            local block = terrain.blocks.grass

            local mapx = xc * terrain.chunksize + x
            local mapy = yc * terrain.chunksize + y

            local roughnessscale = (terrain.perlinscale * 2/3) +
                scaledperlinvalue(mapx, mapy, terrain.generated.seed * 2, terrain.perlinscale * 4) * (terrain.perlinscale * 1/3)
            roughnessscale = math.ceil(roughnessscale)
            local h = 2 + math.floor(
                (
                    scaledperlinvalue(mapx, mapy, terrain.generated.seed, roughnessscale) * 4 +   -- small scale gives bumps locally
                    scaledperlinvalue(mapx, mapy, terrain.generated.seed, terrain.perlinscale * 8) * 8 -- grand scale undulations
                )
            * 1)
            local t = scaledperlinvalue(mapx, mapy, terrain.generated.seed + 20, terrain.perlinscale)
            if t < -0.5 then
                block = terrain.blocks.rock
                h = h + math.floor((math.abs(t) - 0.5) * 40)
            else
                if h > 0 then
                    if t > 0.3 then
                        block = terrain.blocks.forest
                    end
                else
                    block = terrain.blocks.water
                end
            end
            r[x] = {height=h, block=block}
        end
        m[y] = r
    end
    return m
end
