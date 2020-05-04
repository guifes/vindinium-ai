dofile("./vindinium-ai/src/array.lua")
dofile("./vindinium-ai/src/vector2.lua")
dofile("./vindinium-ai/src/set.lua")
dofile("./vindinium-ai/src/map.lua")
dofile("./vindinium-ai/src/priority-queue.lua")
dofile("./vindinium-ai/src/pathfinding.lua")
dofile("./vindinium-ai/src/misc.lua")
dofile("./vindinium-ai/vindinium/misc.lua")
dofile("./vindinium-ai/vindinium/game_state.lua")

local luaPrint = print

-- Reading map info

io.input("./vindinium-ai/vindinium/map/map01.txt")

local output = {}

local mapSize = io.read()

table.insert(output, mapSize)

for i = 1, tonumber(mapSize) do
    table.insert(output, io.read())
end

local game_state = GameState:new(output)

table.insert(output, "0")

local dump = game_state:getDump()

for i = 1, #dump do
    table.insert(output, dump[i])
end

local outputIndex = 1

io.read = function()
    local value = output[outputIndex]
    outputIndex = outputIndex + 1
    if game_state.over then
        return "Game over"
    else
        return value
    end
end

local vindiniumPrint = function(param)
    
    game_state:runTurn(param)
    game_state:runTurn("WAIT")
    game_state:runTurn("WAIT")
    game_state:runTurn("WAIT")

    local dump = game_state:getDump()

    for i = 1, #dump do
        table.insert(output, dump[i])
    end
end

print = vindiniumPrint

dofile("./vindinium-ai/src/main.lua")