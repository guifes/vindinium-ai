-- Four legendary heroes were fighting for the land of Vindinium
-- Making their way in the dangerous woods
-- Slashing goblins and stealing gold mines
-- And looking for a tavern where to drink their gold

--[[
TODO:
- Calculate how many steps to get to next mine and deduce from current health to see if it's
possible to dominate the tavern without having to heal first
- Check for players near buy that can kill us and steal our mines and run away from them
- Always check if a player about to die is in reach and has mines (ATTACK)

--]]

local map = {}

function map.pathCost(state, transition)
	return 1
end

function map.heuristic(from, to)
	local diff = Vector2.subtract(from, to)
	return diff:magnitude()
end

function map.applyTransition(state, transition)
	return Vector2.add(state, transition)
end

function map.expand(startState, endState, state)
	local transitions = {}

    -- printDebug("expanding: ")
    -- printDebug(state)
    -- printDebug(" , startState: ")
    -- printDebug(startState)
    -- printDebug(" , endState: ")
    -- printDebugLn(endState)

	for _, transition in ipairs(Vector2.directions) do
        local newState = map.applyTransition(state, transition)

        local validPos = (
            newState.x >= 0 and
            newState.x < map.size and
            newState.y >= 0 and
            newState.y < map.size
        )

        local isObstacle = map.obstacles:has(newState)
        
        local isDynamicObstacle = (
            startState:equals(state) and
            map.dynamicObstacles:has(newState)
        )

        local isDestination = endState:equals(newState)
        
        -- printDebug("newState: ")
        -- printDebug(newState)
        -- printDebug(" (")
        -- printDebug(validPos)
        -- printDebug(", ")
        -- printDebug(isObstacle)
        -- printDebug(", ")
        -- printDebug(isDynamicObstacle)
        -- printDebug(", ")
        -- printDebug(isDestination)
        -- printDebug(") - ")
        -- printDebugLn(validPos and ((not isObstacle and not isDynamicObstacle) or isDestination))
        if validPos and ((not isObstacle and not isDynamicObstacle) or isDestination) then
            table.insert(transitions, transition)
            -- printDebugLn(" is valid")
        else
            -- printDebugLn(" is NOT valid")
        end
	end

	return transitions
end

function map:buildObstacles(taverns, mines, walls, enemies)

    local set = Set:new()

    for _, tavern in ipairs(taverns) do
        set:add(tavern)
    end
    
    for _, mine in ipairs(mines) do
        set:add(mine)
    end
    
    for _, wall in ipairs(walls) do
        set:add(wall)
    end

    self.obstacles = set
end

function map:addDynamicObstacles(obstacles)
    for _, obstacle in pairs(obstacles) do
        self.dynamicObstacles:add(obstacle)
    end
end

function map:clearObstacles()
    self.obstacles = Set:new()
    self.dynamicObstacles = Set:new()
end

-- Global entities
local taverns = {}
local mines = {}
local walls = {}

-- Circunstance flags
local canHeal = false
local canDie = false

-- Action flags
local healing = false

local size = tonumber(io.read())

map.size = size

for i = 0, size - 1 do

    line = io.read()

    local charCount = 0
    line:gsub(".", function(c)

        if c == 'T' then
            table.insert(taverns, Vector2:new(charCount, i))
        end

        if c == '#' then
            table.insert(walls, Vector2:new(charCount, i))
        end

        if c == 'M' then
            table.insert(mines, Vector2:new(charCount, i))
        end

        charCount = charCount + 1
    end)
end

local myID = tonumber(io.read()) -- ID of your hero

-- game loop
while true do

    local myHero
    local heroes = {}

    local entityCount = tonumber(io.read()) -- the number of entities

    for i = 0, entityCount - 1 do
        next_token = string.gmatch(io.read(), "[^%s]+")

        entityType = next_token() -- entityType: HERO or MINE
        id = tonumber(next_token()) -- id: the ID of a hero or the owner of a mine
        x = tonumber(next_token()) -- x: the x position of the entity
        y = tonumber(next_token()) -- y: the y position of the entity
        life = tonumber(next_token()) -- life: the life of a hero (-1 for mines)
        gold = tonumber(next_token()) -- gold: the gold of a hero (-1 for mines)

        if entityType == "HERO" then
            
            local hero = {}

            hero.id = id
            hero.life = life
            hero.gold = gold
            hero.pos = Vector2:new(x, y)
            hero.mines = {}

            if id == myID then

                hero.unclaimedMines = {}

                myHero = hero
                
                canHeal = myHero.gold >= 2
                canDie = myHero.life <= 20
            end

            heroes[id] = hero
        end

        if entityType == "MINE" then
        
            local mine = Vector2:new(x, y)

            if id == myID then
                table.insert(myHero.mines, mine)
            else
                if id >= 0 then
                    table.insert(heroes[id].mines, mine)
                end

                table.insert(myHero.unclaimedMines, mine)
            end
        end
    end

    local enemies = Array.filter(heroes, function(item) return item ~= myHero end)
    
    map:clearObstacles()

    map:buildObstacles(taverns, mines, walls)

    -- Is player in the process of healing
    healing = ternary(myHero.life > 75, false, healing)

    local nearestTavernInfo = getNearest(map, myHero.pos, taverns)
    local nearestTavern = taverns[nearestTavernInfo.i]

    local nearestMineInfo = getNearest(map, myHero.pos, myHero.unclaimedMines)
    local nearestMine = myHero.unclaimedMines[nearestMineInfo.i]

    local diff = Vector2.subtract(nearestTavern, myHero.pos)
    local nearestTavernDistance = diff:magnitude()

    diff = Vector2.subtract(nearestMine, myHero.pos)
    local nearestMineDistance = diff:magnitude()

    -- Checking if there are enemies nearby that can kill us

    local enemiesInRange = Array.filter(enemies, function(item) return isPositionInRange(map, myHero.pos, item.pos) end)
    local enemiesInRangePositions = Array.map(enemiesInRange, function(item) return item.pos end)

    map:addDynamicObstacles(Array.map(enemies, function(item) return item.pos end))

    if #myHero.mines > 0 and canDie and #enemiesInRange > 0 then
        printDebugLn("there are enemies in range " .. tostring(enemiesInRange[1].pos))

        for i, pos in ipairs(enemiesInRangePositions) do
            local dangerZone = getDangerZoneForPos(pos)
            map:addDynamicObstacles(dangerZone)
        end
    end

    -------------------------------------------
    -- Checkinf if should try and kill enemy --
    -------------------------------------------

    local command = findEnemiesInKillingRange(map, myHero, enemies)

    if command then
        printDebug("Moving to kill: ")
        printDebugLn(command)
        print(command)

    -----------------------------
    -- Checking if should heal --
    -----------------------------
    elseif
        (
            healing or canDie or
            (nearestTavernInfo.d <= 2 and myHero.life <= 50) or
            (myHero.life - nearestMineDistance) <= 20
        ) and canHeal
    then

        printDebug("healing: ")
        printDebugLn(healing)
        printDebug("canHeal: ")
        printDebugLn(canHeal)
        printDebug("canDie: ")
        printDebugLn(canDie)
        printDebug("nearestTavern distance: ")
        printDebugLn(nearestTavernInfo.d)
        printDebug("myHero.life: ")
        printDebugLn(myHero.life)
        
        healing = true

        printDebugLn("Seeking tavern @ " .. nearestTavern.x .. ", " .. nearestTavern.y)
        local path = findBestPath(map, myHero.pos, nearestTavern)

        print(findDirectionForNearestPath(path, myHero.pos, nearestTavern))
    
    -----------------------------------------------------
    -- Checking if should try and conquer nearest mine --
    -----------------------------------------------------
    elseif #myHero.unclaimedMines > 0 then

        printDebugLn("Seeking mine @ " .. nearestMine.x .. ", " .. nearestMine.y)
        local path = findBestPath(map, myHero.pos, nearestMine)

        print(findDirectionForNearestPath(path, myHero.pos, nearestMine))
        
    else
        print("WAIT") -- WAIT | NORTH | EAST | SOUTH | WEST
    end
end