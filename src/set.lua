Set = { mt = {} }

Set.mt.__index = Set

Set.mt.__len = function(set)
	return set.length
end

function Set:new()

	local set = {}

	setmetatable(set, self.mt)

	set.length = 0

    return set
end

function Set:has(item)

	if self[tostring(item)] then
		return true
    end

	return false
end

function Set:add(item)

	local key = tostring(item)

	if not self[key] then
		self.length = self.length + 1
	end

	self[key] = item
end