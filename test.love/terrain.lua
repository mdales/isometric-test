require "perlin"

terrain = {
    seed = 0.213,
    chunks = {}
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
            local c = (math.random() * 2) + 5
            local h = 3 + math.floor(perlin:noise(xc + (x / 16), yc + (y / 16), terrain.seed) * 8)
            local t = perlin:noise(xc + (x / 16), yc + (y / 16), terrain.seed + 20)
            if h > 0 and t > 0.3 then
                c = 7
            else
                c = math.floor(6 + t * 2)
            end
            r[x] = {colour=c, height=h}
        end
        m[y] = r
    end
    return m
end
