--[[
Copyright (c) 2012 Hello!Game

Permission is hereby granted, free of charge, to any person obtaining a copy
of newinst software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished
to do so, subject to the following conditions:

The above copyright notice and newinst permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
]]

----------------------------------------------------------------
-- write by xerysherry
-- Ë«ÏòÁ´±í

local Object = getClass("Object");

local function newIterator(list, node)
	-- private;
	local _list = list;
	local _node = node;
	local iter = {};
	-- public;
	iter.value = function()
		return _node.value;
	end
	iter.setValue = function(v)
		_node.value = v;
	end
	iter.next = function ()
		local _next = _node._next;
		if _next==nil then
			return nil;
		end
		_node = _next;
		return iter.value();
	end
	iter.prev = function ()
		local _prev = _node._prev
		if _prev==nil then
			return nil;
		end
		_node = _prev;
		return iter.value();
	end
	iter.isend = function ()
		return _node==_list.tail;
	end
	iter.isbegin = function ()
		return _node==_list.header;
	end
	iter.list = function ()
		return _list;
	end
	iter.remove = function ()
		if _list==nil then
			return;
		end
		
		local _next = _node._next;
		local _prev = _node._prev;
		if _next~=_prev then
			if _next~=nil then
				_next._prev = _prev;
			end
			if _prev~=nil then
				_prev._next = _next;
			end
		else
			_list.header = nil;
			_list.tail = nil;
		end
		_list.n_count = _list.n_count-1;
		_list=nil;
		_node._next = nil;
		_node._prev = nil;
	end
	return iter;
end

local function newNode(v, prev_node, next_node)
	local new_node = {value=v};
	if prev_node~=nil then
		prev_node._next = new_node;
		new_node._prev = prev_node;
	end
	if next_node~=nil then
		next_node._prev = new_node;
		new_node._next = next_node;
	end
	return new_node;
end

local function delNode(node)
	if node==nil then
		return nil, nil;
	end
	if node._prev~=nil then
		node._prev._next = node._next;
	end
	if node._next~=nil then
		node._next._prev = node._prev;
	end
	return node._prev, node._next;
end

local List = class("List", Object, {
	n_count = 0,
	header = nil,
	tail = nil,
	ring = false,
});

function List:initialize() end

function List:setRing(value)
	self.ring = value or self.ring;
	if self.header then
		if self.ring then
			self.header._prev = self.tail;
			self.tail._next = self.header;
		else
			self.header._prev = nil;
			self.tail._next = nil;
		end
	end
end

function List:pushBack(v)
	if self.header==nil then
		self.header = newNode(v);
		self.tail = self.header;
	else
		self.tail = newNode(v, self.tail);
	end
	self:setRing();
	self.n_count = self.n_count+1;
end

function List:pushFront(v)
	if self.header==nil then
		self.header = newNode(v);
		self.tail = self.header;
	else
		self.header = newNode(v, nil, self.header);
	end
	self:setRing();
	self.n_count = self.n_count+1;
end

function List:popBack()
	if self.header==nil then
		return nil;
	end
	local p, n = delNode(self.tail);
	self.tail = p;
	
	if self.tail==nil then
		self.header=nil;
	end
	
	self.n_count = self.n_count-1;
end	

function List:popFront()
	if self.header==nil then
		return nil;
	end
	local p, n = delNode(self.header);
	self.header = n;
	
	if self.header==nil then
		self.tail=nil;
	end
	
	self.n_count = self.n_count-1;
end

function List:getBegin()
	return newIterator(self, self.header);
end

function List:getEnd()
	return newIterator(self, self.tail);
end

function List:clear()
	self.header = nil;
	self.tail = nil;
	self.n_count = 0;
end

function List:count()
	return self.n_count;
end

function List.erase(iter)
	iter.remove();
end

return List;
