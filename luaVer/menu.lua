local Button = require "Button"

local MenuState = {}
local menuButtons = {}

function MenuState.load()
    menuButtons = {}
    Button.loadButtons("menu", menuButtons)
end

function MenuState.update(dt)
    Button.updateAll(menuButtons, nil, nil)
end

function MenuState.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("DUTCH", 0, 150, love.graphics.getWidth(), "center")

    Button.drawAll(menuButtons)
end

function MenuState.mousepressed(x, y, button)
    Button.handleMousePressed(x, y, button, menuButtons, nil)
end

return MenuState
