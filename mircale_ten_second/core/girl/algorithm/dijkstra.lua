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

--Dijkstra Algorithm
-- 支持任意类型点，支持查询graph和自定查询回调是搜索路径

-- example :
--[[
djt = Dijkstra();
djt:add("a");
djt:add("b");
djt:add("c");
djt:add("d");
djt:add("e");
djt:add("f");

djt:dist("a", "b", 7);
djt:dist("a", "c", 9);
djt:dist("a", "f", 14);
djt:dist("b", "d", 15);
djt:dist("b", "c", 10);
djt:dist("c", "d", 11);
djt:dist("c", "f", 2);
djt:dist("d", "e", 6);
djt:dist("e", "f", 9);

print( table.concat( djt:getPath("a","e"), "->") );
]]


local tinsert = table.insert;

local Object = getClass("Object");

local _inf = 1/0;

local Dijkstra = class("Dijkstra", Object, 
{
	points = nil,
	graph = nil,
});

function Dijkstra:initialize()
	self.points = {};
	self.graph = {};
end

function Dijkstra:add(p)
	tinsert(self.points, p);
	self.graph[p] = {};
end

function Dijkstra:clear()
	self.points = {};
	self.graph = {};
end

function Dijkstra:dist(sp, ep, dist)
	assert(self.graph[sp]~=nil);
	assert(ep~=nil);
	self.graph[sp][ep] = dist;
end

function Dijkstra:emit(start, distfunc)
	local point_count = #self.points;
	local dist = {};
	local queue = {};
	local road = {};
	
	distfunc = distfunc or function (pv, v)
		return self.graph[pv][v] or 0;
	end
	
	-- 初始化距离
	for i, v in pairs(self.points) do
		dist[v]=_inf;
	end
	dist[start]=0;
	
	-- 初始化队列
	for i, v in pairs(self.points) do
		queue[i] = v;
	end
	
	local queue_count = point_count;
	local function find_min_dist()
		local min = _inf;
		local idx = nil;
		for i, v in pairs(queue) do
			if dist[v] < min then
				min = dist[v];
				idx = i;
			end
		end
		return idx;
	end
	
	while queue_count > 0 do
		local pi = find_min_dist();
		if pi==nil then
			-- 只剩下孤立点
			break;
		end
		local pv = queue[pi];
		
		queue[pi] = nil;
		queue_count = queue_count - 1;
	
		for i, v in pairs(self.points) do
			local rv = distfunc(pv,v);
			if rv>0 and dist[v]>dist[pv]+rv then
				dist[v] = dist[pv]+rv;
				road[v] = pv;
			end
		end
	end
	
	return dist, road;
end

function Dijkstra:path(p, goal)
	local i = goal
	local t = { i }
	while p[i] do
		tinsert(t, 1, p[i])
		i = p[i]
	end
	return t
end

function Dijkstra:getPath(sp, ep, distfunc)
	local _, t = self:emit(sp, distfunc);
	return self:path(t, ep);
end

return Dijkstra;
