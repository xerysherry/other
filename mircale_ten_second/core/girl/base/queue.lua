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

-- 得到基类
local Object = getClass("Object");

local floor = math.floor;

local tinsert = table.insert;
local tremove = table.remove;

local function Leaf(n, l, r)
	return {node=n, l=left, r=right};
end

-- 队列
local Queue = class("Queue", Object, 
{
	qtree = nil,
	sortf = nil,
	qcount = 0,
});

-- 构造时设置队列排序，默认不进行排序插入到尾部
function Queue:initialize(sortf)
	self.sortf = sortf or function (a1, a2) return false; end;
	self.qtree = nil;
	self.qcount = 0;
end

function Queue:push(n)
	if self.qtree==nil then
		self.qtree=Leaf(n); 
		self.qcount = self.qcount+1;
	else
		local leaf = self.qtree;
		while true do
			if self.sortf(n, leaf.node) then
				if leaf.left==nil then
					leaf.left = Leaf(n);
					self.qcount = self.qcount+1;
					return;
				else
					leaf = leaf.left;
				end
			else
				if leaf.right==nil then
					leaf.right = Leaf(n);
					self.qcount = self.qcount+1;
					return;
				else
					leaf = leaf.right;
				end
			end
		end
	end
end

function Queue:pop()
	local leaf = self.qtree;
	if leaf==nil then
		return nil;
	else
		local parent = nil;
		while leaf.left~=nil do
			parent = leaf;
			leaf = leaf.left;
		end
		
		if parent==nil then
			-- 根节点
			self.qtree = leaf.right;
		else
			parent.left = leaf.right;
		end
		
		self.qcount = self.qcount-1;
		leaf.right = nil;
		return leaf.node;
	end
end

function Queue:clear()
	self.qtree = nil;
	self.qcount = 0;
end

function Queue:count()
	return self.qcount;
end

return Queue;
