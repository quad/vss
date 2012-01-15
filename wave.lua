Wave = {}

function Wave:new()
    return setmetatable({
    }, {__index = self})
end

function Wave:spawn()
    local baddies = {}

    for i=1, 5 do
        local r = SamRail:new(20 + 25 * i, 0)
        local b = Bad:new(r)

        table.insert(baddies, b)
    end

    for i=1, 5 do
        local r = SamRail:new(love.graphics.getWidth() - (20 + 25 * i), 0, 100, 1.25 * math.pi)
        local b = Bad:new(r)

        table.insert(baddies, b)
    end

    return baddies
end
