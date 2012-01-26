if not graphics then graphics = {} end
graphics.bullets = {}

local function base(width, height, model)
    local b = {
        width = width,
        height = height,
        model = model
    }

    function b:advance()
        self.model:advance()

        if not self.dead and self.model.dead then
            self.dead = true
        elseif self:is_offscreen() then
            self.dead = true
        end
    end

    function b:draw()
        love.graphics.rectangle('fill', self.model.x, self.model.y, width, height)
    end

    function b:box()
        return {
            x = self.model.x - self.width / 2,
            y = self.model.y - self.height / 2,
            width = self.width,
            height = self.height 
        }
    end

    function b:is_offscreen()
        return self.model.x < 0 or self.model.y < 0
            or self.model.y > love.graphics.getHeight()
            or self.model.x > love.graphics.getWidth()
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

