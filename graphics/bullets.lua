require 'graphics/base'

graphics.bullets = {}

local function base(width, height, model)
    local b = graphics.base(width, height, model)

    function b:draw()
        love.graphics.rectangle('fill', self.model.x, self.model.y, width, height)
    end

    return b
end

function graphics.bullets.aimed_triangles(width, height, model)
    local b = base(width, height, model)

    function b:draw()
        love.graphics.push()
        love.graphics.translate(self.model.x, self.model.y)
        love.graphics.rotate(self.model.direction)
        love.graphics.triangle('fill', 
            0, height / 2, 
            -width / 2, -height / 2,
            width / 2, -height / 2
        )
        love.graphics.pop()
    end

    return b
end

function graphics.bullets.drawable(model)
    --return graphics.bullets.aimed_triangles(5, 5, model)
    return base(5, 5, model)
end

