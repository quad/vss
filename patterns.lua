patterns = {}

local function action(...)
    local children = arg

    return function(bullet)
        local a = {
            bullet = bullet
        }

        local _children = {}
        for i, c in ipairs(children) do
            table.insert(_children, c(a))
        end

        a.children = _children

        function a:advance()
            self.blocking = false

            local finished = {}

            for i, child in ipairs(self.children) do
                local done = child:done()

                if not done then
                    child:advance()
                    done = child:done()
                end

                if child.blocking and not done then
                    self.blocking = true
                    break
                elseif done then
                    table.insert(finished, i)
                end
            end

            for i = #finished,1,-1 do
                table.remove(self.children, i)
            end
        end

        function a:done()
            return table.maxn(self.children) == 0
        end

        return a
    end
end

local function mob(direction, speed, ...)
    local body = action(...)

    return function(x, y, child_created, target)
        local _direction = direction
        if type(direction) == "table" then
            local dir, orient = unpack(direction)

            if orient == "sequence" then
                _direction = patterns.last_fire_direction + dir
            elseif orient == "aim" then
                local opposite = x - target.x
                local adjacent = y - target.y
                _direction = math.atan(opposite / adjacent) + dir
            else
                _direction = dir
            end
        end

        local b = {
            x = x,
            y = y,
            direction = _direction,
            speed = speed,
            mx = 0,
            my = 0,
            child_created = child_created,
            target = target
        }

        b.body = body(b)

        function b:advance()
            local done = self.body:done()

            if not done then
                self.body:advance()
                done = self.body:done()
            end
            self.x = self.mx + self.x + math.sin(self.direction) * self.speed
            self.y = self.my + self.y + math.cos(self.direction) * self.speed
        end

        function b:done()
            return self.body:done()
        end

        return b
    end
end

function patterns.bullet(direction, speed, ...)
    return mob(direction, speed, ...)
end

function patterns.bad(direction, speed, ...)
    return mob(direction, speed, ...)
end

function patterns.wait(ticks)
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

function patterns.accelerate(vertical, horizontal, frames)
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

function patterns.vanish()
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

function patterns.change_speed(speed, frames)
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

function patterns.change_direction(direction, frames, orient)
    function aim(cd)
        function cd:_advance()
            local remaining = self.frames - self.current

            local opposite = self.action.bullet.x - self.action.bullet.target.x
            local adjacent = self.action.bullet.y - self.action.bullet.target.y
            local theta = math.atan(opposite / adjacent)

            if remaining > 0 then 
                local start = self.action.bullet.direction

                local total_change = (theta - start)
                total_change = (total_change + math.pi) % (2 * math.pi) - math.pi

                local delta = total_change / remaining

                self.action.bullet.direction = self.action.bullet.direction + delta
            end
        end

        return cd
    end

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
        elseif cd.orient == "aim" then
            return aim(cd)
        end
    end
end

-- Ick ... this is way too thread unsafe for my liking. Unfortunately, I can't
-- think of a cleaner place to story this that's accessible to bullets.
patterns.last_fire_direction = 0
function patterns.fire(...)
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
                    local new_bullet = b(
                        self.action.bullet.x, 
                        self.action.bullet.y, 
                        self.action.bullet.child_created,
                        self.action.bullet.target
                    )

                    patterns.last_fire_direction = new_bullet.direction
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

function patterns.loop(count, ...)
    local generator = action(...)

    return function(action)
        local l = {
            action = action,
            count = count
        }

        l.children = {}
        for i=1,count do
            table.insert(l.children, generator(l.action.bullet))
        end

        function l:advance()
            local dead = {}
            for i, c in ipairs(self.children) do
                if not c:done() then
                    c:advance()

                    if c:done() then
                        table.insert(dead, i)
                    elseif c.blocking then
                        break
                    end
                end
            end

            for i_dead=#dead,1,-1 do
                table.remove(self.children, dead[i_dead])
            end
        end

        function l:done()
            return table.maxn(self.children) <= 0
        end

        return l
    end
end
