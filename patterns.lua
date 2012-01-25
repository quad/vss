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
    local mt = setmetatable({}, {__index = self})

    local _children = {}
    for i, c in ipairs(children) do
        table.insert(_children, c(self))
    end

    self.children = _children
    self.bullet = bullet

    return mt
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
        elseif done then
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
    local mt = setmetatable({}, {__index = self})

    local _actions = {}
    for i, a in ipairs(actions) do
        table.insert(_actions, a(self))
    end

    self.x = x
    self.y = y
    self.direction = direction
    self.speed = speed
    self.actions = _actions
    
    return mt
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

    self.x = self.x + math.sin(self.direction) * self.speed
    self.y = self.y + math.cos(self.direction) * self.speed

    if self:is_offscreen() then
        self.dead = true
    end
end

function patterns.Bullet:done()
    return table.maxn(self.actions) == 0
end

function patterns.Bullet:draw()
    local r, g, b, a = love.graphics.getColor()

    love.graphics.setColor(174, 0, 68)
    love.graphics.rectangle('fill', self.x, self.y, 5, 5)

    love.graphics.setColor(r, g, b, a)
end

function patterns.Bullet:box()
    return {
        x = self.x - 5,
        y = self.y - 5,
        width = 10,
        height = 10 
    }
end

function patterns.Bullet:is_offscreen()
    return self.x < 0 or self.y < 0
        or self.y > love.graphics.getHeight()
        or self.x > love.graphics.getWidth()
end

function bullet(x, y, direction, speed, ...)
    return patterns.Bullet:new(x, y, direction, speed, arg)
end

function wait(ticks)
    return function(_)
        local wait = {ticks = ticks}

        function wait:blocking()
            return true
        end

        function wait:advance()
            if not self:done() then
                self.ticks = self.ticks - 1
            end

            return {}
        end
        
        function wait:done()
            return self.ticks <= 0
        end

        return wait
    end
end

function change_direction(direction, frames, orient)
    function relative(cd)
        cd.delta_per_step = cd.target / cd.frames

        function cd:_advance()
            self.action.bullet.direction = self.action.bullet.direction + self.delta_per_step 
        end

        return cd
    end

    function absolute(cd)
        function cd:_advance()
            local remaining = self.frames - self.current

            if remaining > 0 then 
                local start = self.action.bullet.direction

                local total_change = (cd.target - start)
                total_change = (total_change + math.pi) % (2 * math.pi) - math.pi

                local delta = total_change / remaining

                self.action.bullet.direction = self.action.bullet.direction + delta
            end
        end

        return cd
    end

    return function(action)
        local cd = {
            action = action,
            target = (direction + math.pi) % (2 * math.pi) - math.pi,
            orient = orient or "relative",
            frames = frames or 0,
            current = 0
        }

        function cd:blocking()
            return false
        end

        function cd:advance()
            if not self:done() then
                self.current = self.current + 1
                self:_advance()
            end

            return {}
        end

        function cd:done()
            return self.current >= self.frames
        end

        if cd.orient == "relative" then
            return relative(cd)
        elseif cd.orient == "absolute" then
            return absolute(cd)
        end
    end
end

function fire(...)
    local bullets = arg
end
