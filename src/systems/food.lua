local Food = {}

local function pick_cell(level, snake, occupied)
    for _ = 1, 200 do
        local x = love.math.random(0, level.grid_width - 1)
        local y = love.math.random(0, level.grid_height - 1)
        local key = x .. ":" .. y
        if not snake:occupies(x, y) and not occupied[key] then
            return x, y
        end
    end

    for y = 0, level.grid_height - 1 do
        for x = 0, level.grid_width - 1 do
            local key = x .. ":" .. y
            if not snake:occupies(x, y) and not occupied[key] then
                return x, y
            end
        end
    end

    return 0, 0
end

function Food.spawn_set(level, snake)
    local foods = {}
    local occupied = {}

    for _ = 1, level.good_count do
        local x, y = pick_cell(level, snake, occupied)
        occupied[x .. ":" .. y] = true
        foods[#foods + 1] = { x = x, y = y, kind = "good" }
    end

    for _ = 1, level.bad_count do
        local x, y = pick_cell(level, snake, occupied)
        occupied[x .. ":" .. y] = true
        foods[#foods + 1] = { x = x, y = y, kind = "bad" }
    end

    return foods
end

function Food.consume_at(foods, x, y)
    for index, food in ipairs(foods) do
        if food.x == x and food.y == y then
            table.remove(foods, index)
            return food
        end
    end
    return nil
end

return Food
