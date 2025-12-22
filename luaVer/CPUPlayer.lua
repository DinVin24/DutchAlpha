local Card = require "Card"
local Player = require "Player"

local CPUPlayer = setmetatable({}, {__index = Player})
CPUPlayer.__index = CPUPlayer

function CPUPlayer:new(name,index)
    local self = setmetatable(Player:new(name or "CPU", index), CPUPlayer)
    self.isBot = true
    self.thinkingTime = 3
    self.seeCards = 0
    self.knownCards = {"?", "?", "?", "?"}
    self.jumpTimer = 0
    return self
end

function CPUPlayer:learnCards()
    self.knownCards[1],self.knownCards[2] = self.hand[1], self.hand[2]
end

function CPUPlayer:pull(GameTable)
    local discardedCard = nil
    self.pulledCard = table.remove(GameTable.Deck)
    if self.knownCards[3] == "?" then
        discardedCard = self.hand[3]
        self.knownCards[3] = self.pulledCard
        self.hand[3] = self.pulledCard
        
        Animation.moveCard(self.hand[3], {x = self.hand[3].fixedX, y = self.hand[3].fixedY})
        --animation is done automatically by recalculatePositions() idk why but doesn't bother me

    elseif self.knownCards[4] == "?" then
        discardedCard = self.hand[4]
        self.knownCards[4] = self.pulledCard
        self.hand[4] = self.pulledCard

        self.hand[4].x, self.hand[4].y = self.pulledCard.x, self.pulledCard.y
        Animation.moveCard(self.hand[4], {x = self.hand[4].fixedX, y = self.hand[4].fixedY})

    else
        discardedCard = self.pulledCard
        for i, card in ipairs(self.knownCards) do
            if card ~= "?" and (indexOf(Card.values, card.value) > indexOf(Card.values, self.pulledCard.value) 
               or (self.pulledCard.value == "king" and self.pulledCard.suit == "diamond"))
               and not (card.value == "king" and card.suit == "diamond") then

                discardedCard = card
                self.knownCards[i] = self.pulledCard
                self.hand[i] = self.pulledCard

                self.hand[i].x, self.hand[i].y = self.pulledCard.x, self.pulledCard.y
                Animation.moveCard(self.hand[i], {x = self.hand[i].fixedX, y = self.hand[i].fixedY})

                print("CPU pulled", self.pulledCard.value, self.pulledCard.suit, "and discarded", discardedCard.value, discardedCard.suit) --DEBUG
                break
            end
        end
    end
    dCard = GameTable.discardPile[#GameTable.discardPile]:getCard()
    dCard.value, dCard.suit = discardedCard.value, discardedCard.suit

    dCard.x, dCard.y = discardedCard.x, discardedCard.y
    table.insert(GameTable.discardPile, dCard)
    local nr = #GameTable.discardPile
    self:checkSpecialCards(GameTable)
    Animation.moveCard(GameTable.discardPile[nr], {x = GameTable.discardPile[nr].fixedX, y = GameTable.discardPile[nr].fixedY})

    if discardedCard.value == "queen" then
        self:useQueen()
    elseif discardedCard.value == "jack" then
        self:useJack()
    end
end

function CPUPlayer:calculateKnownScore()
    local score = 0
    for i = 1, #self.knownCards do
        if self.knownCards[i] == "?" then -- if it doesn't know all its cards
            score = 99
            break
        end
        
        if not (self.knownCards[i].value == "king" and self.knownCards[i].suit == "diamond") then
           score = score + indexOf(Card.values, self.knownCards[i].value) 
        end
    end
    return score
end

function CPUPlayer:callDutch(players)
    for i, p in ipairs(players) do if p ~= self and p.dutch > - 1 then return end end
    if self.dutch < 1 then
        if self:calculateKnownScore() <= 7 then
            self.dutch = self.dutch + 1
        end
    end
end

function CPUPlayer:jumpIn(GameTable,dt)
    self.jumpTimer = self.jumpTimer + dt
    if self.jumpTimer < 0.7 then return
    else self.jumpTimer = 0 end
    for i = #self.knownCards, 1, -1 do
        if self.knownCards[i] ~= "?" and self.knownCards[i] ~= nil
           and not (self.knownCards[i].value == "king" and self.knownCards[i].suit == "diamond") then
            local card = self.knownCards[i]
            if card.value == GameTable.discardPile[#GameTable.discardPile].value then  --if cards match
                dCard = GameTable.discardPile[#GameTable.discardPile]:getCard()
                dCard.suit = card.suit
                dCard.x, dCard.y = self.hand[i].x, self.hand[i].y
                table.insert(GameTable.discardPile, dCard)
                local nr = #GameTable.discardPile
                self:checkSpecialCards(GameTable)
                Animation.moveCard(GameTable.discardPile[nr],{x = GameTable.discardPile[nr].fixedX, GameTable.discardPile[nr].fixedY})

                print("CPU jumped in with", card.value, card.suit) --DEBUG
                table.remove(self.hand, i)
                table.remove(self.knownCards, i)
                if card.value == "queen" then
                    self:useQueen()
                elseif card.value == "jack" then
                    self:useJack()
                end
                return
            end
        end
    end
end

function CPUPlayer:useQueen()
    for i = 1, #self.knownCards do
        if self.knownCards[i] == "?" then
            self.knownCards[i] = self.hand[i]
            print("CPU used queen to learn", self.hand[i].value, self.hand[i].suit) --DEBUG
            break
        end
    end
    --TODO: upgrade to choose player's card
end

function CPUPlayer:useJack()
    -- if it has a card greater than 7, it will swap with one of the player's cards I guess
    -- if all cards are <= 7, it will just swap 2 random player's cards

    -- later on: what if the player only has 1 card and the CPU has good cards.
    -- counter a player's jack so the known gets recovered.
    -- would work great if he keeps track of the player's cards
    -- or based by the player's confidence. example: player calls dutch, CPU should go for a swap
end

function CPUPlayer:thinking()
    -- i'll work on this later. it's for more complex plays
    -- add logic to how valuable a card is.
end

function CPUPlayer:play(GameTable,players,dt)
    if self.turn then
        if self.thinkingTime == 3 then
            self:pull(GameTable)
            self:callDutch(players)
        end

        self.thinkingTime = self.thinkingTime - dt
        if self.thinkingTime <= 0 then
            self.turn = false
            self.thinkingTime = 3
        end
    end
    
    self:jumpIn(GameTable,dt)

end

return CPUPlayer