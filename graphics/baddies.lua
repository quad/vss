require 'graphics/base'

graphics.baddies = {}

local function base(width, height, model)
    local b = graphics.base(width, height, model)

    function b:draw()
        love.graphics.rectangle('fill', self.model.x, self.model.y, width, height)
    end

    function b:collide(other)
        self.dead = true
    end

    return b
end

function graphics.baddies.drawable(model)
    return base(10, 10, model)
end
