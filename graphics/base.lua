graphics = {}

function graphics.base(width, height, model)
    local b = {
        width = width,
        height = height,
        model = model
    }

    function b:advance()
        self.model:advance()

        self.x = self.model.x
        self.y = self.model.y

        if not self.dead and self.model.dead then
            self.dead = true
        elseif self:is_offscreen() then
            self.dead = true
        end
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

    function b:collide(other)
    end

    return b
end
