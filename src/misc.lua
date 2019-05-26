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
       printDebugLn(t)
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

    if transition.x > 0 then
        return "EAST"
    elseif transition.x < 0 then
        return "WEST"
    elseif transition.y > 0 then
        return "SOUTH"
    elseif transition.y < 0 then
        return "NORTH"
    end
end