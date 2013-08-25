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

local PolygonType = {
	Concave="concave", 		-- 凹
	Convex="convex"			-- 凸
};
local PolygonDirection = {
	Clockwise="clockwise",			--顺时针
	AntiClockwise="anti-clockwise",	--逆时针
	None="none",
};
local VertexType = {
	Concave="concave", 		-- 凹
	Convex="convex"			-- 凸
};

local function polygonArea(t)
	local dblarea=0;
	local tlen=#t
	for i=1, tlen do
		local j=i%tlen+1;
		dblarea=dblarea+t[i][1]*t[j][2];
		dblarea=dblarea-t[i][2]*t[j][1];
	end
	dblarea=dblarea/2;
	return dblarea;
end

local function pointInLine(pt1, pt2, checkpt)
	local dx=pt1[1]-pt2[1];
	local dy=pt1[2]-pt2[2];
	
	local k=dy/dx;
	local a=pt1[2]-pt1[1]*k;
	
	if math.abs(checkpt[1]*k+a-checkpt[2]) < .0001 then
		return true;
	end
	return false;
end

local function nextIndex(size, idx)
	local nidx=idx+1;
	if nidx>size then
		nidx=1;
	end
	return nidx;
end

local function prevIndex(size, idx)
	local pidx=idx-1;
	if pidx<1 then
		pidx=size;
	end
	return pidx;
end

local Polygon = class("Polygon", Object, 
{
	vertices = nil,
	triangles = nil,
});

function Polygon:initialize()
	self.vertices = {};
	self.triangles = nil;
end

function Polygon:clear()
	self.vertices={};
	self.triangles=nil;
end

function Polygon:add(x_or_table, y)
	local vx, vy;
	if type(x_or_table)=="table" then
		vx = x_or_table[1] or 0;
		vy = x_or_table[2] or 0;
	else
		vx = x_or_table or 0;
		vy = y or 0;
	end
	
	table.insert(self.vertices, vx);
	table.insert(self.vertices, vy);
end

function Polygon:getVertexCount()
	return #self.vertices/2;
end

function Polygon:getVertex(idx)
	return self.vertices[(idx-1)*2+1], self.vertices[(idx-1)*2+2]
end

function Polygon:verticesDirection()
	local vs=self:getVertexCount();
	if vs<3 then
		return PolygonDirection.None;
	end

	local count=0;
	for i=1, vs do
		local j=i%vs+1;
		local k=j%vs+1;
		
		local pt1={self:getVertex(i)};
		local pt2={self:getVertex(j)};
		local pt3={self:getVertex(k)};
		
		local cross_product=(pt2[1]-pt1[1])*(pt3[2]-pt2[2])
							-(pt2[2]-pt1[2])*(pt3[1]-pt2[1]);
		if cross_product>0 then
			count=count+1;
		else
			count=count-1;
		end
	end
	
	if count>0 then
		return PolygonDirection.Clockwise;
	elseif count<0 then
		return PolygonDirection.AntiClockwise;
	else
		return PolygonDirection.None;
	end
end

function Polygon:getVertexType(idx)
	if idx<1 or idx>self:getVertexCount() then
		return nil;
	end

	local ai=idx;
	local bi=prevIndex(self:getVertexCount(), idx);
	local ci=nextIndex(self:getVertexCount(), idx);
	
	local area={{self:getVertex(ai)},
				{self:getVertex(bi)},
				{self:getVertex(ci)}};			
	local dblarea=polygonArea(area);
	if dblarea<0 then
		return VertexType.Convex;
	else
		return VertexType.Concave;
	end
end

local function getVertexType(polygon, idx)
	local size=#polygon.update_vertices;
	if idx<1 or idx>size then
		return nil;
	end

	local ai=idx;
	local bi=prevIndex(size, idx);
	local ci=nextIndex(size, idx);
	
	local area={polygon.update_vertices[ai],
				polygon.update_vertices[bi],
				polygon.update_vertices[ci]};			
	local dblarea=polygonArea(area);
	if dblarea<0 then
		return VertexType.Convex;
	else
		return VertexType.Concave;
	end
end

local function triangleContainsPoint(polygon, ti, pi)
	if #ti~=3 then
		return false;
	end

	for i=1, #ti do
		if ti[i]==pi then
			return true;
		end
	end
	
	local point1=polygon.update_vertices[ti[1]];
	local point2=polygon.update_vertices[ti[2]];
	local point3=polygon.update_vertices[ti[3]];
	local checkpoint=polygon.update_vertices[pi];
	
	if pointInLine(point1, point2, checkpoint) or
		pointInLine(point2, point3, checkpoint) or
		pointInLine(point3, point1, checkpoint) then
		return true;
	end
	
	local result=false;
	local dblarea1=polygonArea({point1, point2, checkpoint});
	local dblarea2=polygonArea({point2, point3, checkpoint});
	local dblarea3=polygonArea({point3, point1, checkpoint});
	
	if dblarea1>0 then
		if dblarea2>0 and dblarea3>0 then
			result=true;
		end
	elseif dblarea1<0 then
		if dblarea2<0 and dblarea3<0 then
			result=true;
		end
	end
	return result;
end

local function isEarOfUpdatedPolygon(polygon, idx)
	if getVertexType(polygon, idx)==VertexType.Convex then
		local ear=true;
		local size=#polygon.update_vertices;
		local ai=idx;
		local bi=prevIndex(size, idx);
		local ci=nextIndex(size, idx);
		
		for i=1, size do
			if i~=ai and i~=bi and i~=ci then
				if triangleContainsPoint(polygon, {ai, bi, ci}, i) then
					ear=false;
				end
			end
		end
		return ear;
	else
		return false;
	end
end

local function updatePolygonVertices(polygon, pi)
	local size=#polygon.update_vertices;
	local ai=pi;
	local bi=prevIndex(size, pi);
	local ci=nextIndex(size, pi);
	
	table.insert(polygon.triangles, {polygon.update_vertices[ai], 
									polygon.update_vertices[bi],
									polygon.update_vertices[ci]});
	table.remove(polygon.update_vertices, pi);
end

local function updatePolygonLastVertices(polygon)
	table.insert(polygon.triangles, {polygon.update_vertices[1], 
									polygon.update_vertices[2],
									polygon.update_vertices[3]});
end

function Polygon:cutEar()
	-- self:save();

	self.triangles={};
	if self:getVertexCount()<3 then
		return;
	end
	
	local vertex_count=self:getVertexCount();
	self.update_vertices={};
	
	if self:verticesDirection()==PolygonDirection.Clockwise then
		for i=1, vertex_count do
			table.insert(self.update_vertices, {self:getVertex(i)});
		end
	else
		for i=1, vertex_count do
			table.insert(self.update_vertices, {self:getVertex(vertex_count-i+1)});
		end
	end
	
	local finish=false;
	while not finish do
		
		local idx=1;
		local found=false;
		while (not found) and idx<=vertex_count do
			if isEarOfUpdatedPolygon(self, idx) then
				found=true;
			else
				idx=idx+1;
			end
		end
		if idx<=vertex_count then
			updatePolygonVertices(self, idx);
		-- else
			-- print("Reserve")
			-- for i=1, vertex_count do
				-- print(i, polygon:getVertexType(i));
			-- end
			-- for i=1, vertex_count do
				-- local t = self.update_vertices[i];
				-- self.update_vertices[i]=self.update_vertices[vertex_count-i+1];
				-- self.update_vertices[vertex_count-i+1]=t;
			-- end
		end
		
		vertex_count=#self.update_vertices;
		if vertex_count==3 then
			finish=true;
		end
	end
	updatePolygonLastVertices(self);
	self.update_vertices=nil;
end

function Polygon:draw(mode, x, y)
	love.graphics.push();
	love.graphics.translate(x, y);
	if #self.vertices > 6 then
		love.graphics.polygon(mode, self.vertices);
	end
	-- if #self.vertices >= 2 then
		-- for i=1, #self.vertices, 2 do
			-- love.graphics.point(self.vertices[i], self.vertices[i+1]);
		-- end
	-- end
	love.graphics.pop();
end

function Polygon:drawTriangle(x, y)
	if self.triangles==nil then
		return;
	end

	love.graphics.push();
	love.graphics.translate(x, y);
		
	for _, v in ipairs(self.triangles) do
		
		love.graphics.setColor(math.random(0,255), math.random(0,255), math.random(0,255));
		love.graphics.triangle("fill", v[1][1], v[1][2],
										v[2][1], v[2][2],		
										v[3][1], v[3][2]);
	end
	
	love.graphics.pop();
end

-- function Polygon:save()
	-- local f=love.filesystem.newFile("polygon.json");
	-- f:open("w");
	-- local j=json.encode(self.vertices);
	-- f:write(j);
	-- f:close();
-- end

-- function Polygon:load()
	-- local f=love.filesystem.newFile("polygon.json");
	-- f:open("r");
	-- local j=f:read();
	-- f:close();
	-- self.vertices=json.decode(j);
-- end

return Polygon;
