require "perlin"

terrain = {
    seed = 0.213,
    chunks = {},
    blocks = {
        grass = {
            colour = function(h) return {0, (h / 11) + 0.5, 0} end,
            tree = false,
            passable = true,
            height = function(h) return h end
        },
        water = {
            colour = function(h) return {0, 0, 0.5 + 0.5 / (math.abs(h) + 1)} end,
            tree=false,
            passable=false,
            height = function(h) return 0 end
        },
        forest = {
            colour = function(h) return {0, (h / 11) + 0.5, 0} end,
            tree=true,
            passable=false,
            height = function(h) return h end
        },
        rock = {
            colour = function(h) return {(h / 22) + 0.5, (h / 22) + 0.3, (h / 22) + 0.1} end,
            tree=false,
            passable=true,
            height = function(h) return h + 2 end
        }
    }
}

function terrain.chunkToCoords(chunk)
    local xc = math.floor((chunk / 2^16) - 0x7fff)
    local yc = math.floor((chunk % 2^16) - 0x7fff)
    return xc, yc
end

function terrain.coordsToChunk(x, y)
    return ((math.floor(x / 16) + 0x7fff) * 2^16) + (math.floor(y / 16) + 0x7fff)
end

function terrain.getcell(x, y)
    local chunk = terrain.coordsToChunk(x, y)
    local mapc = terrain.chunks[chunk]
    if mapc == nil then
        mapc = terrain.worldgen(chunk)
        terrain.chunks[chunk] = mapc
        entities.generate(chunk)
        items.generate(chunk)
    end
    return mapc[y % 16][x % 16]
end

function terrain.worldgen(chunk)
    local xc, yc = terrain.chunkToCoords(chunk)
    local m = {}

    for y = 0,15 do
        local r = {}
        for x = 0,15 do
            local block = terrain.blocks.grass
            local h = 3 + math.floor(perlin:noise(xc + (x / 16), yc + (y / 16), terrain.seed) * 8)
            local t = perlin:noise(xc + (x / 16), yc + (y / 16), terrain.seed + 20)
            if h > 0 then
                if t > 0.3 then
                    block = terrain.blocks.forest
                elseif t < -0.5 then
                    block = terrain.blocks.rock
                end
            else
                block = terrain.blocks.water
            end
            r[x] = {height=h, block=block}
        end
        m[y] = r
    end
    return m
end
