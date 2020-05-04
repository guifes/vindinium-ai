PriorityQueue = { mt = {} }

PriorityQueue.mt.__index = PriorityQueue

function PriorityQueue:new()

	local queue = {}

	setmetatable(queue, self.mt)

    return queue
end

function PriorityQueue:enqueue(item)

	local newNode = { next = nil, item = item }
	local last = nil
	local node = self.head

	while node do
		if node.item.priority <= item.priority then
			last = node
			node = node.next
		else
			if node == self.head then
				self.head = newNode
			else
				last.next = newNode
			end

			newNode.next = node
			return
		end
	end

    if last then
        last.next = newNode
    else
        self.head = newNode
    end
end

function PriorityQueue:dequeue()

	local node = self.head

	if self.head then
		self.head = self.head.next
	end
    
	return node and node.item
end

function PriorityQueue:isEmpty()
	return not (self.head and true)
end

function PriorityQueue:remove(val)
    local node = self.head
    local last = nil
    
    while node do
        if node.item == val then
            if last then
                last.next = node.next
            else
                self.head = nil
            end
        end

        last = node
    end
end