local Array = {}

function Array.filter(arr, condition)
    local filtered = {}
    for i, item in ipairs(arr) do
        if condition(item) then
            table.insert(filtered, item)
        end
    end
    return filtered
end

function Array.map(arr, mapFunction)
    local mapped = {}
    for i, item in ipairs(arr) do
        table.insert(mapped, mapFunction(item))
    end
    return mapped
end