local Button = {}
Button.__index = Button

function Button:new(x, y, w, h, color, text, onClick)
    local self = setmetatable({}, Button)
    self.x = x or 0
    self.y = y or 0
    self.h = h or 0
    self.w = w or 0
    self.color = color or { 0.4, 0.4, 0.4 }
    self.text = text or "unnamed"
    self.onClick = onClick or function() end
    self.hover = false
    self.visible = true
    self.image = nil
    return self
end

function Button:isHovered(mx, my)
    return mx > self.x and mx < self.x + self.w and
        my > self.y and my < self.y + self.h
end

function Button:setImage(imagePath)
    self.image = love.graphics.newImage(imagePath)
    self.w = self.image:getWidth()
    self.h = self.image:getHeight()
end

function Button:draw()
    if not self.visible then return end
    if self.image then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(self.image, self.x, self.y)
    else
        local c = self.color
        if self.hover then
            love.graphics.setColor(c[1] * 1.2, c[2] * 1.2, c[3] * 1.2)
        else
            love.graphics.setColor(c)
        end
        love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 8, 8)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(self.text, self.x, self.y + self.h / 3, self.w, "center")
    end
end

function Button.drawAll(buttons)
    for _, b in ipairs(buttons) do
        b:draw()
    end
end

function Button:mousePressed(mx, my, button, players)
    if not self.visible then return end
    if button == 1 and self:isHovered(mx, my) then
        self.onClick(players)
    end
end

function Button.loadButtons(state, buttons)
    if state == "playing" then
        table.insert(buttons, Button:new(300, 600, 120, 40, { 0.388, 0.125, 0.125 }, "End Turn",
            function(players) --onClick
                if players[1].pulled then players[1].turn = false end
            end
        ))
        table.insert(buttons, Button:new(300, 660, 120, 40, { 0.125, 0.388, 0.125 }, "Dutch",
            function(players)
                players[1]:checkDutch(players)
            end
        ))
        table.insert(buttons, Button:new(400, 340, 100, 60, { 0.388, 0.125, 0.388 }, "Reset",
            function()
                -- We'll just call the playstate load again when this happens, using a global function
                if resetGame then resetGame() end
            end))
    elseif state == "menu" then
        table.insert(buttons, Button:new(540, 350, 200, 50, { 0.125, 0.388, 0.125 }, "Start Game",
            function()
                if startGame then startGame() end
            end))
        table.insert(buttons, Button:new(540, 450, 200, 50, { 0.388, 0.125, 0.125 }, "Exit",
            function()
                love.event.quit()
            end))
    end
end

function Button.handleMousePressed(x, y, button, buttons, players)
    for _, b in ipairs(buttons) do
        b:mousePressed(x, y, button, players)
    end
end

function Button:update(GameTable, players)
    -- dynamically handle visibility based on the type of button
    if self.text == "End Turn" or self.text == "Dutch" then
        if players and players[1] and players[1].turn then
            self.visible = true
        else
            self.visible = false
        end
    end

    if self.text == "Reset" then
        if GameTable and GameTable.over then
            self.visible = true
        else
            self.visible = false
        end
    end

    if not self.visible then return end
    local mx, my = love.mouse.getPosition()
    self.hover = self:isHovered(mx, my)
end

function Button.updateAll(buttons, GameTable, players)
    for _, b in ipairs(buttons) do
        b:update(GameTable, players)
    end
end

return Button
