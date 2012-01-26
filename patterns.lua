patterns = {}

patterns.Action = {}

function patterns.Action:new(bullet, children) 
    local t = {
        bullet = bullet
    }

    local _children = {}
    for i, c in ipairs(children) do
        table.insert(_children, c(t))
    end

    t.children = _children

    return setmetatable(t, {__index = self})
end

function patterns.Action:advance()
    local finished = {}

    for i, child in ipairs(self.children) do
        local done = child:done()

        if not done then
            child:advance()
            done = child:done()
        end

        if child.blocking and not done then
            break
        elseif done then
            table.insert(finished, i)
        end
    end

    for i = #finished,1,-1 do
        table.remove(self.children, i)
    end
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

function patterns.Bullet:new(x, y, direction, speed, body, child_created)
    local t = {
        x = x,
        y = y,
        direction = direction,
        speed = speed,
        mx = 0,
        my = 0,
        child_created = child_created
    }

    t.body = body(t)

    return setmetatable(t, {__index = self})
end

function patterns.Bullet:advance()
    local done = self.body:done()

    if not done then
        self.body:advance()
        done = self.body:done()
    end

    self.x = self.mx + self.x + math.sin(self.direction) * self.speed
    self.y = self.my + self.y + math.cos(self.direction) * self.speed
end

function patterns.Bullet:done()
    return self.body:done()
end

-- TODO: Move this somewhere else. This bullet should only be a model, not a display
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
-- TODO: END

function bullet(direction, speed, ...)
    local body = action(...)

    return function(x, y, child_created)
        return patterns.Bullet:new(x, y, direction, speed, body, child_created)
    end
end

function wait(ticks)
    return function(_)
        local w = {ticks = ticks, blocking = true}

        function w:advance()
            if not self:done() then
                self.ticks = self.ticks - 1
            end
        end
        
        function w:done()
            return self.ticks <= 0
        end

        return w
    end
end

function accelerate(vertical, horizontal, frames)
    return function(action)
        local acc = {
            action = action,
            frames = frames or 0,
            current = 0
        }

        acc.vertical = vertical / frames
        acc.horizontal = horizontal / frames
        
        function acc:advance()
            if not self:done() then
                self.current = self.current + 1

                self.action.bullet.my = self.action.bullet.my + self.vertical
                self.action.bullet.mx = self.action.bullet.mx + self.horizontal
            end
        end

        function acc:done()
            return self.current >= self.frames
        end

        return acc
    end
end

function vanish()
    return function(action)
        local v = {
            action = action, 
            vanished = false
        }

        function v:advance()
            self.action.bullet.dead = true
            self.vanished = true
        end

        function v:done()
            return self.vanished
        end

        return v
    end
end

function change_speed(speed, frames)
    return function(action)
        local spd = {
            action = action,
            frames = frames or 0,
            speed = speed,
            current = 0
        }

        function spd:advance()
            if not self:done() then
                self.current = self.current + 1

                local remaining = self.frames - self.current
                
                if remaining > 0 then
                    local start = self.action.bullet.speed
                    local total_change = (self.speed - start)
                    local delta = total_change / remaining

                    self.action.bullet.speed = self.action.bullet.speed + delta
                end
            end
        end

        function spd:done()
            return self.current >= self.frames
        end

        return spd
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

        function cd:advance()
            if not self:done() then
                self.current = self.current + 1
                self:_advance()
            end
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
    return function(action)
        local f = {
            action = action,
            bullets = bullets,
            fired = false
        }

        function f:advance()
            if not self:done() then
                self.fired = true

                for i, b in ipairs(self.bullets) do
                    local new_bullet = b(self.action.bullet.x, self.action.bullet.y)

                    self.action.bullet.child_created(new_bullet)
                end
            end
        end

        function f:done()
            return self.fired
        end

        return f
    end
end

function loop(count, ...)
    local generator = action(...)

    return function(action)
        local l = {
            action = action,
            count = count,
            generator = generator,
            childe = nil,
            current = 0
        }

        function l:advance()
            if not self:done() then
                if not self.child then
                    self.child = generator(self.action.bullet)
                end

                self.child:advance()

                if self.child:done() then
                    self.child = nil
                    self.current = self.current + 1
                end
            end
        end

        function l:done()
            return self.current >= self.count
        end

        return l
    end
end
