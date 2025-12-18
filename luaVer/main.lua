_G.love = require("love")
Card = require "Card"
Player = require "Player"
Functions = require "Functions"
CPUPlayer = require "CPUPlayer"
Animation = require "Animation"
Button = require "Button"

local background = love.graphics.newImage("PNG/test3.jpg")
local players = {}
local GameTable = {}
local buttons = {}
local morePlayers = 0 -- change to 1 for 4 players

--TODO 
-- i don't think the bot's cards turn into "?" when i swap 'em
--make it wait a bit after the last card is discarded
--also show on screen when someone calls dutch
--cant use queen/jack if i jump in

function love.mousepressed(x, y, button) -- button referes to mouse button
    handleMousePressed(x, y, button, players, GameTable)
    Button.handleMousePressed(x,y,button,buttons,players) --buttons refers to the table
end

function love.keypressed(key)
    handleKeyPress(key, players[1], players)
end

function love.load()
    GameTable = {
    Deck = {},
    discard = Card:new(nil, nil, 598, 300, true),
    pulled = nil,
    over = false,
    turn = nil}
    players = {}
    buttons = {}

    Button.loadButtons(buttons)
    love.graphics.setBackgroundColor( 0.5, 0, 0.52 )
    Card.loadSpriteSheet("PNG/customtest.png")

    for _, value in ipairs(Card.values) do
        for _, suit in ipairs(Card.suits) do
            table.insert(GameTable.Deck, Card:new(value, suit,800 + (#GameTable.Deck * 0.2), 310 + (#GameTable.Deck * 0.1)))
        end
    end

    shuffle(GameTable.Deck)

    table.insert(players, Player:new("Emi",1))
    table.insert(players, CPUPlayer:new(nil,2))

    if morePlayers == 1 then
        table.insert(players, CPUPlayer:new(nil,3))
        table.insert(players, CPUPlayer:new(nil,4))
    end
    
    for _, p in ipairs(players) do
        p:deal(GameTable.Deck, 4)
        p:calculateScore()
        if p.isBot then
            p:learnCards()
        end
        p:showHand()--DEBUG
    end
    GameTable.turn = players[1]
    players[1].turn = true
end

function love.update(dt)
    Button.updateAll(buttons, GameTable, players)
    Animation.update(dt)   -- ANIMATION TEST
    if not GameTable.over then
        for _, p in ipairs(players) do
            p:updateCards(dt) -- ANIMATION TEST
        end
        if GameTable.turn.turn == false then
            GameTable.turn.pulled = false
            if indexOf(players, GameTable.turn) == #players then
                GameTable.turn = players[1]
            else
                GameTable.turn = players[indexOf(players, GameTable.turn)+1]
            end
            GameTable.turn.turn = true
        end
        --if GameTable.turn.isBot then
        --    GameTable.turn:playTurn(GameTable,dt)
        --end

        players[2]:play(GameTable,players,dt)
        if morePlayers == 1 then
            players[3]:play(GameTable,players,dt)
            players[4]:play(GameTable,players,dt)
        end

        GameTable.turn:checkSpecialCards(GameTable.discard)
        GameTable.discard.used = true -- should be updated in the above function...
        GameTable.pulled = GameTable.turn.pulledCard
        if GameTable.turn.dutch==1 or #GameTable.turn.hand == 0 then
            GameTable.over = true
        end
    else
        for _, p in ipairs(players) do
            for _, card in ipairs(p.hand) do
                card.faceUp = true
            end
        end
    end
end

function love.draw()
    love.graphics.draw(background, 0, 0)
    drawHands(players)
    drawTable(GameTable)
    Button.drawAll(buttons)

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

--draw all cards:
--   for i, card in ipairs(Deck) do
--        local x = (i-1) % 13
--        local y = math.floor((i-1) / 13)
--        print(x, y)
--        drawCard(Deck[i], 50 * x, 100 * y)
--   end