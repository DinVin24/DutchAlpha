---@diagnostic disable: lowercase-global
local Animation = require("Animation")
local Card = require("Card")
function shuffle(deck)
    for i = #deck, 2, -1 do
        local j = love.math.random(1, i)
        deck[i], deck[j] = deck[j], deck[i]
    end
end

function indexOf(lista, element)
    for i, v in ipairs(lista) do
        if v == element then
            return i
        end
    end
    return nil
end

function drawDeck(Deck)
    for i, card in ipairs(Deck) do
        Deck[i].fixedX = 800 - i * 0.2 -- MAKE THESE PIXELS SCALABLE
        Deck[i].fixedY = 310 + i * 0.1
        Deck[i]:draw()
    end
end

function clickedOwnCard(x, y, Players, GameTable)
    local player = Players[1] -- always the user
    local clickedCard = player:getCardAt(x, y)
    if clickedCard then
        player:swapCards(clickedCard, Players) --SPECIAL CARDS HAVE TO BE BEFORE JUMPING IN AND REPLACE
        player:learnCards(clickedCard)         --SO YOU DON'T ACCIDENTALY USE IT
        player:jumpIn(clickedCard, GameTable)
        player:replaceCard(clickedCard, GameTable)
        return clickedCard
    end
    return nil
end

function clickedOtherCard(x, y, players, GameTable)
    local clickedCard = nil
    local p = nil
    for i, player in ipairs(players) do
        if i ~= 1 then -- if the player is not the user
            if player:getCardAt(x, y) then
                clickedCard = player:getCardAt(x, y)
                p = player
            end
        end
    end

    if clickedCard then
        GameTable.turn:revealCards(p, clickedCard)
        GameTable.turn:swapCards(clickedCard, players)
    end
end

function clickedDeck(x, y, player, deck)
    local deckX, deckY, deckW, deckH = deck[1].fixedX, deck[1].fixedY, Card.WIDTH, Card.HEIGHT
    if player.isBot == false and player.turn and player.pulled == false and player.pulledCard == nil and
        x > deckX and x < deckX + deckW and y > deckY and y < deckY + deckH and player.turn then
        player.pulledCard = table.remove(deck)
        Animation.flipCard(player.pulledCard)
    end
    return nil
end

function clickedPile(x, y, player, GameTable)
    local discard = GameTable.discardPile[#GameTable.discardPile]
    if x > discard.fixedX and x < discard.fixedX + Card.WIDTH and y > discard.fixedY and y < discard.fixedY + Card.HEIGHT then
        return player:discardCard(GameTable)
    end
    return nil
end

function handleMousePressed(x, y, button, Players, GameTable)
    if button == 1 then
        clickedOwnCard(x, y, Players, GameTable)

        clickedOtherCard(x, y, Players, GameTable)

        clickedDeck(x, y, GameTable.turn, GameTable.Deck)

        clickedPile(x, y, GameTable.turn, GameTable)
    end
    return nil
end

function handleKeyPress(key, player, players, GameTable)
    if key == "space" then
        player.jumpingIn = true
    end
    if key == "d" then
        player:checkDutch(players)
    end
    if key == "c" and player.pulled then
        player.turn = false
    end
    if key == "l" then -- show all cards
        for _, player in ipairs(players) do
            for i = 1, #player.hand do
                Animation.flipCard(player.hand[i])
            end
            player.cardTimer = 0
        end
    end
    if key == "p" then -- hide all cards
        for i = 1, #player.hand do
            player.hand[i].faceUp = false
        end
    end
    if key == "q" then -- restart + add more players
        GameTable.over = true
        GameTable.g_morePlayers = not GameTable.g_morePlayers
        print(GameTable.g_morePlayers)
    end
end

function drawHands(Players)
    for i = 1, 4 do
        if Players[i] then
            for j, card in ipairs(Players[i].hand) do
                card:draw()
            end
        end
    end
end

function drawTable(GameTable)
    drawDeck(GameTable.Deck)
    for i = #GameTable.discardPile - 3, #GameTable.discardPile do
        if GameTable.discardPile[i] and GameTable.discardPile[i].value then
            GameTable.discardPile[i].faceUp = true
            GameTable.discardPile[i]:draw()
        end
    end
    if GameTable.pulled then
        GameTable.pulled:draw()
    end
end
