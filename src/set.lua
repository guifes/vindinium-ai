Set = { mt = {} }

Set.mt.__index = Set

function Set:new()

	local set = {}

	setmetatable(set, self.mt)

    return set
end

function Set:has(item)

	if self[tostring(item)] then
		return true
    end

	return false
end

function Set:add(item)
	self[tostring(item)] = item
end