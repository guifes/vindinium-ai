Vector2 = {
	mt = {},
	directions = {},
	commandVectors = {}
}

Vector2.mt.__index = Vector2
Vector2.mt.__tostring = function(self)
	return self.x .. "," .. self.y
end

function Vector2:new(x, y)

    local node = { x = x, y = y }

    setmetatable(node, self.mt)

    return node
end

function Vector2.subtract(a, b)
	return Vector2:new(a.x - b.x, a.y - b.y)
end

function Vector2.add(a, b)
	return Vector2:new(a.x + b.x, a.y + b.y)
end

function Vector2:equals(vec)
	return self.x == vec.x and self.y == vec.y
end

function Vector2.scale(vec, a)
	return Vector2:new(vec.x * a, vec.y * a)
end

function Vector2:magnitude()
	return math.abs(self.x) + math.abs(self.y)
end

Vector2.zero = Vector2:new(0, 0)

table.insert(Vector2.directions, Vector2:new(1, 0))
table.insert(Vector2.directions, Vector2:new(0, 1))
table.insert(Vector2.directions, Vector2:new(-1, 0))
table.insert(Vector2.directions, Vector2:new(0, -1))