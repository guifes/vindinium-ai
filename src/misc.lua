local moveCommands = {
    "WAIT", "EAST", "SOUTH", "WEST", "NORTH"
}

local commandDirections = {
	WAIT = Vector2.zero,
	EAST = Vector2.directions[1],
	SOUTH = Vector2.directions[2],
	WEST = Vector2.directions[3],
	NORTH = Vector2.directions[4]
}

local dangerZoneOffsets = {}

table.insert(dangerZoneOffsets, Vector2:new(1, 0))
table.insert(dangerZoneOffsets, Vector2:new(0, 1))
table.insert(dangerZoneOffsets, Vector2:new(-1, 0))
table.insert(dangerZoneOffsets, Vector2:new(0, -1))
table.insert(dangerZoneOffsets, Vector2:new(1, 1))
table.insert(dangerZoneOffsets, Vector2:new(1, -1))
table.insert(dangerZoneOffsets, Vector2:new(-1, 1))
table.insert(dangerZoneOffsets, Vector2:new(-1, -1))
table.insert(dangerZoneOffsets, Vector2:new(2, 0))
table.insert(dangerZoneOffsets, Vector2:new(0, 2))
table.insert(dangerZoneOffsets, Vector2:new(-2, 0))
table.insert(dangerZoneOffsets, Vector2:new(0, -2))

function ternary(cond , T, F)
    if cond then return T else return F end
end

function printDebug(value)
    io.stderr:write(tostring(value))
end

function printDebugLn(value)
    io.stderr:write(tostring(value)..'\n')
end

function printPath(path)
    for _, t in ipairs(path) do
       printDebug(tostring(t) .. ", ")
    end
    printDebugLn("")
end

function commandForDirection(dir)
    if dir.x > 0 then
        return "EAST"
    elseif dir.x < 0 then
        return "WEST"
    elseif dir.y > 0 then
        return "SOUTH"
    elseif dir.y < 0 then
        return "NORTH"
    end
end

function findDirectionForNearestPath(path, from, to)
    -- printPath(path)
    local transition
    if #path > 0 then
        transition = path[#path]
    else
        transition = Vector2.subtract(to, from)
    end

    return commandForDirection(transition)
end

function isPositionInRange(map, from, to)
    local diff = Vector2.subtract(to, from)
    local distance = diff:magnitude()
    if distance <= 3 then
        local path = findBestPath(map, from, to)
        return #path <= 3
    end
    return false
end

function getNearest(map, heroPos, destinations)

    local minDistance = 999
    local nearest = { i = 1, d = 0 }
    
    for i = 1, #destinations do

        local destination = destinations[i]

        local diff = Vector2.subtract(destination, heroPos)
        local directDistance = diff:magnitude()

        if minDistance > directDistance then
            local path, reachable = findBestPath(map, heroPos, destination)

            -- printDebug(">>> ")
            -- printDebugLn(destination)
            -- printPath(path)
            -- printDebugLn(reachable)

            local distance

            if reachable then
                distance = #path
            else
                distance = directDistance
            end

            if minDistance > distance then
                minDistance = distance
                nearest = { i = i, d = distance }
            end
        end
    end

    return nearest
end

function getDangerZoneForPos(pos)
    local zone = {}
    for i, offset in ipairs(dangerZoneOffsets) do
        local zonePos = Vector2.add(pos, offset)
        table.insert(zone, zonePos)
    end
    return zone
end

function positionHasKillableEnemy(pos, myHero, enemies)
    for i, enemy in ipairs(enemies) do
        if pos:equals(enemy.pos) and myHero.life >= enemy.life then
            return true
        end
    end
    return false
end

function findEnemiesInKillingRange(map, hero, enemies)
    local bestScore = 0
    local finalCommand = nil
    for i, command in ipairs(moveCommands) do
        local dir = commandDirections[command]
        local newPos = Vector2.add(hero.pos, dir)
        local score = 0
        for j, newDir in ipairs(Vector2.directions) do
            local posToCheck = Vector2.add(newPos, newDir)
            if
                not dir:equals(Vector2.scale(newDir, -1)) and
                not map.obstacles:has(posToCheck)
            then
                if positionHasKillableEnemy(posToCheck, hero, enemies) then
                    score = score + 1
                end
            end
        end
        if score > bestScore then
            bestScore = score
            finalCommand = command
        end
    end

    return finalCommand
end