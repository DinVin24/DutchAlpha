local Card = require "Card"
local Player = require "Player"
local Functions = require "Functions"
local CPUPlayer = require "CPUPlayer"
local Animation = require "Animation"
local Button = require "Button"

local PlayState = {}

local background
local players = {}
---@class GameTable
---@field turn any
---@field g_morePlayers boolean
---@field Deck table
---@field discardPile table
---@field pulled any
---@field over boolean
local GameTable = {}
local gameButtons = {}
local morePlayers = false

function PlayState.load()
    background = love.graphics.newImage("PNG/test3.jpg")

    GameTable = {
        g_morePlayers = morePlayers,
        Deck = {},
        discardPile = { Card:new(nil, nil, 598, 300, true) },
        pulled = nil,
        over = false,
        turn = nil
    }

    players = {}
    gameButtons = {}

    Button.loadButtons("playing", gameButtons)
    Card.loadSpriteSheet("PNG/customtest.png")

    for _, value in ipairs(Card.values) do
        for _, suit in ipairs(Card.suits) do
            table.insert(GameTable.Deck,
                Card:new(value, suit, 800 + (#GameTable.Deck * 0.2), 310 + (#GameTable.Deck * 0.1)))
        end
    end

    shuffle(GameTable.Deck)

    table.insert(players, Player:new("Daniel", 1))
    table.insert(players, CPUPlayer:new(nil, 2))

    if morePlayers == true then
        table.insert(players, CPUPlayer:new(nil, 3))
        table.insert(players, CPUPlayer:new(nil, 4))
    end

    for _, p in ipairs(players) do
        p:deal(GameTable.Deck, 4)
        p:calculateScore()
        if p.isBot then
            p:learnCards()
        end
    end
    GameTable.turn = players[1]
    players[1].turn = true
end

function PlayState.update(dt)
    Button.updateAll(gameButtons, GameTable, players)
    Animation.update(dt)
    if not GameTable.over then
        for _, p in ipairs(players) do
            p:updateCards(dt)
        end
        if GameTable.turn.turn == false then
            GameTable.turn.pulled = false
            if indexOf(players, GameTable.turn) == #players then
                GameTable.turn = players[1]
            else
                GameTable.turn = players[indexOf(players, GameTable.turn) + 1]
            end
            GameTable.turn.turn = true
        end

        players[2]:play(GameTable, players, dt)
        if morePlayers == true then
            players[3]:play(GameTable, players, dt)
            players[4]:play(GameTable, players, dt)
        end

        GameTable.pulled = GameTable.turn.pulledCard
        if GameTable.turn.dutch == 1 or #GameTable.turn.hand == 0 then
            GameTable.over = true
        end
    else
        morePlayers = GameTable.g_morePlayers
        for _, p in ipairs(players) do
            for _, card in ipairs(p.hand) do
                card.faceUp = true
            end
        end
    end
end

function PlayState.draw()
    if background then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(background, 0, 0)
    end
    drawHands(players)
    drawTable(GameTable)
    Button.drawAll(gameButtons)

    GameTable.turn:drawTips(players)
    if GameTable.over then
        love.graphics.print("GAME OVER!", 400, 260)
        if players[1]:calculateScore() < players[2]:calculateScore() then
            love.graphics.print("P1 WON", 400, 280)
        else
            love.graphics.print("CPU WON", 400, 280)
        end
    end
end

function PlayState.mousepressed(x, y, button)
    handleMousePressed(x, y, button, players, GameTable)
    Button.handleMousePressed(x, y, button, gameButtons, players)
end

function PlayState.keypressed(key)
    handleKeyPress(key, players[1], players, GameTable)
end

return PlayState
