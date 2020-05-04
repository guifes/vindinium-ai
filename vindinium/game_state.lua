GameState = { mt = {} }

GameState.mt.__index = GameState

function GameState:new(output)

	local state = {}

    setmetatable(state, self.mt)

    local size = tonumber(output[1])

    state.mapSize = size
    state.mines = {}
    state.mineMap = Map:new()
    state.players = {}
    state.map = {}
    state.spawns = {}
    state.turn = 0
    state.turnCount = 0
    state.over = false

    for i = 0, size - 1 do

        local line = output[i + 2]

        state.map[i] = {}

        local charCount = 0
        line:gsub(".", function(c)

            state.map[i][charCount] = c
            
            if c == '0' or c == '1' or c == '2' or c == '3' then

                state.spawns[tonumber(c) + 1] = Vector2:new(charCount, i)

                state.players[tonumber(c)] = {
                    pos = Vector2:new(charCount, i),
                    entityType = "HERO",
                    life = 100,
                    gold = 0,
                    id = tonumber(c),
                    alive = true
                }
            end

            if c == 'M' then

                local mine = {
                    pos = Vector2:new(charCount, i),
                    entityType = "MINE",
                    id = -1
                }

                table.insert(state.mines, mine)
                state.mineMap:set(mine.pos, mine)
            end

            charCount = charCount + 1
        end)
    end

    return state
end

function GameState:runTurn(param)

    if string.find(param, "MOVE") then

        local elements = string.split(param, " ")

        -- Pathfind to location
        -- Check if movement in direction is possible
            -- If so, update position
        -- Check if moving towards mine
            -- If so, if mine is not from player attack mine
            -- If dies, process death recursively
        -- Check if moving towards tavern
            -- If health is below 100 and player gold >= 2 heals
        -- Check nearby players, deal 20 damage to all of them
            -- If dies, process death recursively
        -- Lose 1 health of thirst if life > 1
        -- Update all players gold
        -- next turn

    elseif param == "WAIT" then

    elseif param == "NORTH" then

        self:move(param)

    elseif param == "EAST" then

        self:move(param)

    elseif param == "SOUTH" then

        self:move(param)

    elseif param == "WEST" then

        self:move(param)

    end

    self:combat()

    while(self:getDeadCount() > 0) do
        self:respawn()
    end
    
    self:thirst()
    self:profit()
    self:nextTurn()
end

function GameState:combat()

    local turnPlayer = self.players[self.turn]

    for i = 0, 3 do
        if i ~= self.turn then
            local otherPlayer = self.players[i]
            if Vector2.adjacent(turnPlayer.pos, otherPlayer.pos) then
                self.attack(turnPlayer, otherPlayer)
            end
        end
    end
end

function GameState:attack(playerA, playerB)

    playerB.life = math.max(0, playerB.life - 20)
    playerB.alive = playerB.life > 0

    if not playerB.alive then
        self:kill(playerA, playerB)
    end
end

function GameState:respawn()

    for i = 0, 3 do
        local player = self.players[i]
        if not player.alive then
            player.pos = self.spawns[i]
            player.alive = true
            player.life = 100
        end
        for k = 0, 3 do
            if i ~= j then
                local otherPlayer = self.players[j]
                if otherPlayer.alive and player.pos:equals(otherPlayer.pos) then
                    otherPlayer.life = 0
                    self:kill(player, otherPlayer)
                    break
                end
            end
        end
    end
end

function GameState:getDeadCount()
    local count = 0
    for i = 0, 3 do
        if not self.players[i].alive then
            count = count + 1
        end
    end
    return count
end

function GameState:kill(playerA, playerB)
    for i, mine in ipairs (self.mines) do
        if mine.id == playerB.id then
            if playerA then
                mine.id = playerA.id
            else
                mine.id = -1
            end
        end
    end
end

function GameState:profit()
    local player = self.players[self.turn]
    for i, mine in ipairs (self.mines) do
        if mine.id == player.id then
            player.gold = player.gold + 1
        end
    end
end

function GameState:nextTurn()
    self.turn = (self.turn + 1) % 4
    self.turnCount = self.turnCount + 1

    if self.turnCount >= 600 then
        self.over = true
    end
end

function GameState:getDump()
    local dump = {}

    table.insert(dump, tostring(4 + #self.mines))

    for i = 0, 3 do
        local player = self.players[i]
        local info = {}

        table.insert(info, player.entityType)
        table.insert(info, tostring(player.id))
        table.insert(info, tostring(player.pos.x))
        table.insert(info, tostring(player.pos.y))
        table.insert(info, tostring(player.life))
        table.insert(info, tostring(player.gold))
        
        table.insert(dump, table.concat( info, " "))
    end

    for i, mine in ipairs (self.mines) do

        local info = {}

        table.insert(info, mine.entityType)
        table.insert(info, tostring(mine.id))
        table.insert(info, tostring(mine.pos.x))
        table.insert(info, tostring(mine.pos.y))
        table.insert(info, "-1")
        table.insert(info, "-1")
        
        table.insert(dump, table.concat( info, " "))
    end

    return dump
end

function GameState:move(direction)

    local player = self.players[self.turn]
    local offset = commandDirections[direction]
    local newPos = Vector2.add(player.pos, offset)

    local newPosTile = self.map[newPos.y][newPos.x]

    if
        newPosTile == '.' or
        newPosTile == '0' or
        newPosTile == '1' or
        newPosTile == '2' or
        newPosTile == '3'
    then
        local playerCollision = false

        for i = 0, 3 do
            if i ~= self.turn then
                local otherPlayer = self.players[i]
                if player.pos:equals(otherPlayer.pos) then
                    playerCollision = true
                    break
                end
            end
        end

        if not playerCollision then
            player.pos = newPos
        end
    end

    if newPosTile == 'M' then

        local mine = self.mineMap:get(newPos)

        if mine.id ~= player.id then
            self:attack(nil, player)
        end

        if player.alive then
            mine.id = player.id
        end

    elseif newPosTile == 'T' then

        if player.life < 100 and player.gold >= 2 then
            player.gold = player.gold - 2
            player.life = math.min(100, player.life + 50)
        end
    end
end

function GameState:thirst()
    
    local player = self.players[self.turn]

    player.life = math.max(1, player.life - 1)
end