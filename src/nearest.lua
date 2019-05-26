function getNearest(heroPos, destinations)

    local minDistance = 99
    local nearest = { i = 1, d = 0 }
    
    for i = 1, #destinations do

        local destination = destinations[i]

        local diff = Vector2:new(destination.x - heroPos.x, destination.y - heroPos.y)
        local distance = math.abs(diff.x) + math.abs(diff.y)

        if minDistance > distance then
            minDistance = distance
            nearest = { i = i, d = distance }
        end
    end

    return nearest
end