-- Four legendary heroes were fighting for the land of Vindinium
-- Making their way in the dangerous woods
-- Slashing goblins and stealing gold mines
-- And looking for a tavern where to drink their gold

--[[
TODO:
Always check if a player about to die is in reach and has mines (ATTACK)
--]]

local map = {}

function map.pathCost(state, transition)
	return 1
end

function map.heuristic(from, to)
	local dif = Vector2.subtract(from, to)
	return math.abs(dif.x) + math.abs(dif.y);
end

function map.applyTransition(state, transition)
	return Vector2.add(state, transition)
end

function map.expand(state)
	local transitions = {}

    -- printDebug("expanding: ")
    -- printDebugLn(state)

	for _, transition in ipairs(Vector2.directions) do
        local newState = map.applyTransition(state, transition)
        -- printDebug("new state: ")
        -- printDebug(newState)
        if newState.x >= 0 and
           newState.x < map.size and
           newState.y >= 0 and
           newState.y < map.size and
           not map.obstacles:has(newState)
        then
            table.insert(transitions, transition)
            -- printDebugLn(" is valid")
        else
            -- printDebugLn(" is NOT valid")
        end
	end

	return transitions
end

function map:buildObstacles(taverns, mines, walls, heroes)

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
    
    for _, hero in ipairs(heroes) do
        set:add(hero.pos)
    end

    -- for key, val in pairs(set) do
    --     printDebugLn(val)
    -- end

    self.obstacles = set
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
            hero.unclaimedMines = {}

            if id == myID then

                myHero = hero

                canHeal = myHero.gold >= 2
                canDie = myHero.life <= 20
            end

            table.insert(heroes, hero)
        end

        if entityType == "MINE" then
        
            local mine = Vector2:new(x, y)

            if id == myID then
                table.insert(myHero.mines, mine)
            else
                table.insert(myHero.unclaimedMines, mine)
            end
        end
    end
    
    map:buildObstacles(taverns, mines, walls, heroes)

    healing = ternary(myHero.life > 75, false, healing)
    
    local nearestTavernInfo = getNearest(myHero.pos, taverns)
    local nearestTavern = taverns[nearestTavernInfo.i]

    if (healing or canDie or (nearestTavernInfo.d <= 2 and myHero.life <= 50)) and canHeal then

        healing = true

        io.stderr:write("Seeking tavern @ " .. nearestTavern.x .. ", " .. nearestTavern.y .. "\n")
        local path = findBestPath(map, myHero.pos, nearestTavern, true)

        print(findDirectionForNearestPath(path, myHero.pos, nearestTavern))
        
    elseif #myHero.unclaimedMines > 0 then

        local info = getNearest(myHero.pos, myHero.unclaimedMines)
        local mine = myHero.unclaimedMines[info.i]
        
        io.stderr:write("Seeking mine @ " .. mine.x .. ", " .. mine.y .. "\n")
        local path = findBestPath(map, myHero.pos, mine, true)

        print(findDirectionForNearestPath(path, myHero.pos, mine))
        
    else
        print("WAIT") -- WAIT | NORTH | EAST | SOUTH | WEST
    end

    -- Write an action using print()
    -- To debug: io.stderr:write("Debug message\n")
end