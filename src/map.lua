Map = { mt = {} }

Map.mt.__index = Map

function Map:new()

	local map = {}

	setmetatable(map, self.mt)

    return map
end

function Map:has(key)

	if self[tostring(key)] then
		return true
  end

	return false
end

function Map:set(key, item)

	self[tostring(key)] = item
end

function Map:get(key)
    return self[tostring(key)]
end

function Map:remove(key)
	self[tostring(key)] = nil
end