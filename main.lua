require 'bad'
require 'ship'
require 'bullet'

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
bullets = {}
baddies = {}

function love.load(arg)
    love.joystick.open(joystick.n)
    ship = Ship:new(400, 300, joystick)
    for i=1,1000,1 do
        table.insert(baddies, Bad:new(math.random() * 500, math.random() * 50))
    end
end

function add_bad()
end

function love.joystickpressed(j, b)
    fire_everything = true
end

function love.joystickreleased(j, b)
    fire_everything = false
end

function delete_offscreen_bullets()
    local trash = {}

    for i, v in ipairs(bullets) do
        if v:is_offscreen() then
            table.insert(trash, i, 1)
        end
    end

    for i, v in ipairs(trash) do
        table.remove(bullets, v)
    end
end

function update_fire_state(dt)
    if fire_everything then
        table.insert(bullets, Bullet:new(ship.x, ship.y, "player"))
    end
end

function destroy_baddies()
    for i,bad in ipairs(baddies) do 
        for i,bullet in ipairs(bullets) do
            if bullet:hits(bad) then
                bad:hit(bullet)
            end
        end
    end
end

function advance(dt)
    for i, things in ipairs({{ship}, bullets, baddies}) do
        for i, t in ipairs(things) do
            t:advance(dt)
        end
    end
end

function update(dt)
    update_fire_state(dt)
    delete_offscreen_bullets()

    destroy_baddies()
end

function love.update(dt)
    update(dt)
    advance(dt)
end

function love.keypressed(k)
    if k == 'escape' or k == 'q' then
        love.event.push('q')
    end
end

function love.draw()
    for i, things in ipairs({{ship}, bullets, baddies}) do
        for i, t in ipairs(things) do
            t:draw()
        end
    end

    -- DEBUG
    for i = 1, #debug do
        love.graphics.print("Line " .. i .. ": " .. debug[i], 50, 50 + (i * 10))
    end
end
