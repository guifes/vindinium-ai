function findBestPath(map, from, to, collision)

    Node = {}

    function Node:new(parent, cost, h, state, transition)

        local node = {}

        node.parent = parent
        node.state = state
        node.transition = transition

        if parent then
            node.g = parent.g + cost
        else
            node.g = 0
        end

        node.h = h
        node.f = node.g + h
        node.priority = node.f

        return node
    end

	function createSearchNode(parent, transition, state, to)
		if parent then
			local cost = map.pathCost(parent.state, transition)
			local h = map.heuristic(state, to)
			return Node:new(parent, cost, h, state, transition)
		else
			local h = map.heuristic(state, to)
			return Node:new(nil, 0, h, state, transition)
		end
	end

	function buildSolution(node)
		local list = {}

		while node do
			if node.transition then
				table.insert(list, node.transition)
			end

			node = node.parent
		end

		return list
	end
    
    local best = nil
    local openList = PriorityQueue:new()
    local openMap = Map:new()
    local closedSet = Set:new()
	
    local start = createSearchNode(nil, nil, from, to)

    openList:enqueue(start)
	openMap:set(from, start)

	while openList:isEmpty() do

		local node = openList:dequeue()

		openMap:remove(node.state)

		if best == nil or best.h > node.h then
			best = node
		end

		if node.state:equals(to) then
			return buildSolution(node)
		end

		closedSet:add(node.state)

		for _, transition in ipairs(map.expand(node.state)) do

			local child = map.applyTransition(node.state, transition)
			local isNodeInFrontier = openMap:has(child)

			if not closedSet:has(child)and not isNodeInFrontier then
				local searchNode = createSearchNode(node, transition, child, to)

				openList:enqueue(searchNode)
				openMap:set(searchNode.state, searchNode)

			elseif isNodeInFrontiner then
				
				local openListNode = openMap:get(child)
				local searchNode = createSearchNode(node, transition, child, to)

				if openListNode.f > searchNode.f then
					openList:remove(openListNode)
					openListNode.f = searchNode.f
					openList:enqueue(openListNode)
				end
			end
		end
	end
	
	if collision then
		return buildSolution(best)
	end
end