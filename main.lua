x, y = 400, 300

function love.update(dt)
    if love.keyboard.isDown("left") then
	x = x - 100 * dt
    end
    if love.keyboard.isDown("right") then
	x = x + 100 * dt
    end
    if love.keyboard.isDown("up") then
	y = y - 100 * dt
    end
    if love.keyboard.isDown("down") then
	y = y + 100 * dt
    end
end


function draw_ship(x, y)
    local size = 20

    love.graphics.rectangle('line', x - (size / 2), y - (size / 2), size, size)
    love.graphics.point(x, y, 1)
end

function love.draw()
    draw_ship(x, y)
end
