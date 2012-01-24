-- fallerLeft = fire(
--     bullet(
--         direction = 180,
--         speed = 1,
--         action(
--             wait(10), 
--             change_direction(5, 45)
--         )
--     )
-- )
-- 
-- local pattern = action(repeat(100, action(fallerLeft, wait(8))))
-- local all = {pattern}
-- ...

patterns = {}

patterns.Action = {}

function patterns.Action:new(bullet, children) 
    local _children = {}
    for i, c in ipairs(children) do
        table.insert(_children, c(self))
    end

    return setmetatable({
            bullet = bullet, 
            children = _children
        },
        {__index = self}
    )
end

function patterns.Action:advance()
    local created = {}

    for i, child in ipairs(self.children) do
        local done = child:done()

        if not done then
            for i, new in ipairs(child:advance()) do 
                table.insert(created, new) 
            end

            done = child:done()
        end

        if child:blocking() and not done then
            break
        else
            table.remove(self.children, i)
        end
    end

    for i, new in ipairs(created) do
        table.insert(self.children, new)
    end

    return {} 
end

function patterns.Action:done()
    return table.maxn(self.children) == 0
end

function action(...)
    local items = arg

    return function(bullet)
        return patterns.Action:new(bullet, items) 
    end
end

patterns.Bullet = {}

function patterns.Bullet:new(x, y, direction, speed, actions)
    local _actions = {}
    for i, a in ipairs(actions) do
        table.insert(_actions, a(self))
    end

    return setmetatable({
            x = x,
            y = y,
            direction = direction,
            speed = speed,
            actions = _actions
        },
        {__index = self}
    )
end

function patterns.Bullet:advance()
    for i, action in ipairs(self.actions) do
        local done = action:done()

        if not done then
            action:advance()
            done = action:done()
        end

        if done then
            table.remove(self.actions, i)
        end
    end
end

function patterns.Bullet:done()
    return table.maxn(self.actions) == 0
end

function bullet(x, y, direction, speed, ...)
    return patterns.Bullet:new(x, y, direction, speed, arg)
end

patterns.Wait = {}

function patterns.Wait:new(ticks)
    return setmetatable(
        {ticks = ticks}, 
        {__index = self}
    )
end

function patterns.Wait:blocking()
    return true
end

function patterns.Wait:advance()
    if not self:done() then
        self.ticks = self.ticks - 1
    end

    return {}
end

function patterns.Wait:done()
    return self.ticks <= 0
end

function wait(ticks)
    return function(_)
        return patterns.Wait:new(ticks)
    end
end

function fire(...)
    local bullets = arg
end
