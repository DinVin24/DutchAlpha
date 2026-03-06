_G.love = require("love")
local MenuState = require("menu")
local PlayState = require("game")

GameState = "menu"

-- Global function to change state from a button
function startGame()
    GameState = "playing"
    PlayState.load() -- Initialize the game
end

function resetGame()
    PlayState.load() -- Reload game variables
end

function love.load()
    -- Initialize the menu state on launch
    MenuState.load()
end

function love.update(dt)
    if GameState == "menu" then
        MenuState.update(dt)
    elseif GameState == "playing" then
        PlayState.update(dt)
    end
end

function love.draw()
    if GameState == "menu" then
        MenuState.draw()
    elseif GameState == "playing" then
        PlayState.draw()
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if GameState == "menu" then
        MenuState.mousepressed(x, y, button)
    elseif GameState == "playing" then
        PlayState.mousepressed(x, y, button)
    end
end

function love.keypressed(key)
    if GameState == "playing" then
        PlayState.keypressed(key)
    end
end
