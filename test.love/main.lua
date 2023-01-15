require "draw"
require "entities"
require "items"
require "terrain"
require "TSerial"

last_update = 0
tick = 0
alert = false
show_map = false

function love.load()
    items.load()
    entities.load()
    draw.load()
end

function love.quit()
    entities.save()
end

function love.update(dt)
    local time = love.timer.getTime()
    if time - last_update < 0.1 then return end
    last_update = time
    tick = tick + 1

    local dx = 0
    local dy = 0
    local dd = entities.player.cd
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        if dd == 0 then
            dy = 1
        else
            dd = 0
        end
    end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        if dd == 2 then
            dy = -1
        else
            dd = 2
        end
    end
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        if dd == 3 then
            dx = -1
        else
            dd = 3
        end
    end
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        if dd == 1 then
            dx = 1
        else
            dd = 1
        end
    end
    show_map = love.keyboard.isDown("tab")

    if entities.canmove(
        entities.player.cx,
        entities.player.cy,
        entities.player.cx + dx,
        entities.player.cy + dy
    ) then
        entities.player.cx = entities.player.cx + dx
        entities.player.cy = entities.player.cy + dy
        if dx ~= 0 or dy ~= 0 then
            entities.player.mode = (entities.player.mode + 1) % 4
        else
            entities.player.mode = 0
        end
        alert = false
    else
        entities.player.mode = 0
        alert = true
    end
    entities.player.cd = dd

    if love.keyboard.isDown("e") then
        if entities.player.target == nil then
            local t = entities.gettarget(entities.player)
            for i = 1, #entities.npcs do
                local e = entities.npcs[i]
                if t[1] == e.cx and t[2] == e.cy then
                    entities.player.target = e
                    break
                end
            end

            if entities.player.target == nil then
                if ci == nil then
                    local cell = terrain.getcell(t[1], t[2])
                    local h = cell.height
                    if h > 0 then h = h - 1 end
                    cell.height = h
                end
            end
        else
            -- we were in an interaction
            entities.player.target = nil
        end
    end
    if love.keyboard.isDown("escape") then
        entities.player.target = nil
    end
    if love.keyboard.isDown("q") then
        local t = entities.gettarget(entities.player)
        local cell = terrain.getcell(t[1], t[2])
        local h = cell.height
        cell.height = h + 1
    end

    entities.update()
end

function love.draw()
    if not alert then
        love.graphics.setBackgroundColor(0, 0, 0)
    else
        love.graphics.setBackgroundColor(0.3, 0.3, 0.5)
    end
    -- love.graphics.setColor(1, 1, 1)
    -- love.graphics.print(tostring(entities.player.cx)..", "..tostring(entities.player.cy), 10, 10)
    if entities.player.target == nil then
        draw.grid(tick)
        draw.compass()
        if show_map then draw.map() end
    else
        draw.busy()
    end
end