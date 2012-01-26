require 'bad'
require 'boom'
require 'ship'
require 'wave'

joystick = {
    n = 0,
    axes = {
        lr = 0,
        ud = 1
    },
    sensitivity = 500,
    threshold = 0.25
}

debug = {}

ships = {}
bullets_baddies = {}
bullets_ship = {}
baddies = {}
booms = {}
sounds = {}

all = {ships, bullets_baddies, bullets_ship, baddies, booms}

recent_frame_times = {0.0}

function love.load(arg)
    love.joystick.open(joystick.n)

    sounds.player_shot = love.audio.newSource("resources/playershoot.ogg", "static")
    sounds.player_shot:setLooping(true)

    sounds.bad_boom = love.sound.newSoundData("resources/badboom.ogg")

    sounds.ship_boom = love.audio.newSource("resources/shipboom.ogg", "static")

    ship = Ship:new(400, 300, joystick)
    table.insert(ships, ship)
end

function love.joystickpressed(j, b)
    fire_everything = true
end

function love.joystickreleased(j, b)
    fire_everything = false
end

function fire_baddies()
    for i_bad, bad in ipairs(baddies) do
        for i_s, s in ipairs(bad.shots) do
            table.insert(bullets_baddies, s)
        end

        bad.shots = {}
    end
end

function fire_ship()
    if fire_everything then
        if sounds.player_shot:isStopped() then
            sounds.player_shot:play()
        end
        table.insert(bullets_ship, Bullet:new(ship.x, ship.y, 0, true))
    elseif not sounds.player_shot:isStopped() then
        sounds.player_shot:stop()
    end
end

function is_colliding(a, b)
    local box_a, box_b = a:box(), b:box()

    local ax2, ay2 = box_a.x + box_a.width, box_a.y + box_a.height
    local bx2, by2 = box_b.x + box_b.width, box_b.y + box_b.height
    return box_a.x < bx2 and ax2 > box_b.x and box_a.y < by2 and ay2 > box_b.y
end

function move(dt)
    for i_things, things in ipairs(all) do
        for i_t, t in ipairs(things) do
            t:advance(dt)
            
            if t.dead then
                table.remove(things, i_t)
            end
        end
    end
end

function hit_ship()
    for i_bullet, bullet in ipairs(bullets_baddies) do
        if is_colliding(bullet, ship) then
            bullet:collide(ship)
            ship:collide(bullet)

            if bullet.dead then
                table.remove(bullets_baddies, i_bullet)
            end

            if ship.dead then
                table.insert(booms, Boom:new(ship.x, ship.y))
                sounds.ship_boom:play()
            end
        end
    end
end

function hit_baddies()
    for i_bad, bad in ipairs(baddies) do
        for i_bullet, bullet in ipairs(bullets_ship) do
            if is_colliding(bullet, bad) then
                bullet:collide(bad)
                bad:collide(bullet)

                if bullet.dead then
                    table.remove(bullets_ship, i_bullet)
                end

                if bad.dead then
                    table.remove(baddies, i_bad)
                    table.insert(booms, Boom:new(bad.x, bad.y))

                    local explosion = love.audio.newSource(sounds.bad_boom)
                    explosion:play()
                    break
                end
            end
        end
    end
end

last_spawn = 0

function love.update(dt)
    move(dt)

    hit_ship()
    hit_baddies()

    fire_ship()
    fire_baddies()

    require 'patterns'

    if table.maxn(bullets_baddies) == 0 then
        local b = bullet(0, 3, 
            change_direction(-math.pi / 4, 10, "absolute"),
            wait(30),
            loop(3,
                fire(
                    bullet(0, 6, 
                        change_direction(math.pi / 2, 10, "absolute"),
                        wait(15),
                        change_direction(math.pi / 4, 30, "relative")
                    )
                ),
                wait(20)
            )
        )

        local b2 = bullet(0, 3, 
            change_direction(math.pi / 4, 10, "absolute"),
            wait(100),
            vanish()
        )

        function c(child)
            table.insert(bullets_baddies, drawable(child))
        end

        table.insert(bullets_baddies, drawable(b(300, 100, c)))
        table.insert(bullets_baddies, drawable(b(250, 200, c)))
        table.insert(bullets_baddies, drawable(b(150, 250, c)))
    end

    local d = ""
    if bullets_baddies[1].dead then d = "yup" else d = "nah" end

--     last_spawn = last_spawn - dt
-- 
--     if last_spawn < 0 then
--         last_spawn = 1
-- 
--         local w = Wave:new()
--         for _, b in ipairs(w:spawn()) do
--             table.insert(baddies, b)
--         end
--     end
end

function love.keypressed(k)
    if k == 'escape' or k == 'q' then
        love.event.push('q')
    end
end

function fps()
    local sum = 0.0
    for i, v in ipairs(recent_frame_times) do
        sum = sum + v
    end

    local avg_frame_time= sum / table.maxn(recent_frame_times)
    return math.floor(1 / avg_frame_time)
end

function love.run()
    love.load(arg)

    while true do
        local now = love.timer.getMicroTime()

        love.update(1 / 60)
        love.graphics.clear()
        love.draw()
        love.graphics.present()

        -- Process events.
        for e,a,b,c in love.event.poll() do
            if e == "q" then
                if not love.quit or not love.quit() then
                    if love.audio then
                        love.audio.stop()
                    end
                    return
                end
            end
            love.handlers[e](a,b,c)
        end

        table.insert(recent_frame_times, love.timer.getMicroTime() - now)
        if table.maxn(recent_frame_times) > 100 then
            table.remove(recent_frame_times, 1)
        end
    end
end

function love.draw()
    for i, things in ipairs(all) do
        for i, t in ipairs(things) do
            t:draw()
        end
    end

    -- DEBUG
    for i = 1, #debug do
        love.graphics.print("Line " .. i .. ": " .. debug[i], 50, 50 + (i * 10))
    end

    -- Draw the current FPS.
    print_objects(0, love.graphics.getHeight() - 30, 'All', all)
    love.graphics.print("FPS: " .. fps(), 0, love.graphics.getHeight() - 15)
end

function print_objects(x, y, title, objs)
    local n = 0
    for i, v in ipairs(objs) do
        n = n + table.maxn(v)
    end

    love.graphics.print(title .. ":" .. n, x, y)
end
