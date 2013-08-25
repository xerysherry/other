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

--AStar Algorithm
-- 支持任意维度，支持查询维度表和自定查询回调是搜索路径
-- 默认设置不保证能够找到最优解

-- example :
--[[
map = {
--	 1 2 3 4 5 6 7
--	 \ \ \ \ \ \ \
	{0,0,0,0,0,0,0},	-- 1
	{0,0,0,1,0,0,0},	-- 2
	{0,0,0,1,0,0,0},	-- 3
	{0,0,0,1,0,0,0},	-- 4
	{0,0,0,0,0,0,0},	-- 5
}

astar = AStar();
path = astar:getPath(map, {1,3}, {7, 3});

-- other 
function MapFunc(pt)
	local m = map[ pt[1] ];
	if m==nil then
		return 1;
	end
	return m[ pt[2] ];
end
path = astar:getPath(MapFunc, {1,3}, {7, 3});

]]

local abs = math.abs;
local tinsert = table.insert;
local tgetn = table.getn;

local Object = getClass("Object");
local Queue = getClass("Object.Queue");

local _inf = 1/0;

local default_state = 0;
local open_state = 1;
local closed_state = 2;

local QueueCompare = function (a1, a2)
	-- f升序
	if a1.f < a2.f then
		return true;
	elseif a1.f==a2.f then
		-- f相等时 h 降序
		return a1.h > a2.h;
	end
	return false;
end

local AStar = class("AStar", Object, {});

-- customedH : 自定义最优距离估算函数
--		function customedH(n) end;		其中n为坐标点
-- customedOpt : 自定义最优路径比较函数
--		function customedOpt(minfN, surN) end;	其中minfN是open表中最小f节点, surN是在open表中minfN周围点
--		节点结构:
--				{
--					n,		--坐标点
--					g,		--初始点到本节点实际距离值
--					h,		--本节点到目标点最优估计值
--					f,		--本节点(g+h)
--					parent,	--父节点
--				}
function AStar:emit(mapdata_or_func, start_pt, end_pt, customedH, customedOpt)
	local open_list = Queue(QueueCompare);
	local point_info = {}
	local dimension = {}
	local depth = 0;
	
	-- 默认节点通路性查询函数（返回0通路， 非0为障碍）
	local function defaultM(pt)
		local m = mapdata_or_func;
		for i, v in ipairs(pt) do
			m = m[v];
		end
		return m;
	end
	-- 默认当前点到目标点最优估计距离
	local function defaultH(n)
		local d = 0;
		for i, v in ipairs(end_pt) do
			d = d+abs(n[i]-v)+1;
		end
		return d;
	end
	-- 默认最优路径估计比较函数（true表示surN路径优）
	local function defaultOptimalPath(minfN, surN)
		return minfN.f>surN.f;
	end
	
	local M = defaultM;
	if type(mapdata_or_func)=="function" then
		M = mapdata_or_func;
	end
	local H = customedH or defaultH;
	local OptPath = customedOpt or defaultOptimalPath;
	
	-- open列表排序比较函数
	local function OpenListCompare(n1, n2)
		return n1.f<n2.f;
	end
	
	-- 建立搜索节点
	local function Node(n, parentN)
		local hn = H(n);
		local gn = 0;
		if parentN then
			gn = parentN.g+1;
		end
		return {
			-- 设置打开状态
			state = default_state,
			-- 节点信息
			n = n,
			-- f(n) = g(n) + h(n)
			g = gn,
			h = hn,
			f = gn+hn,
			parent = parentN,
		};
	end
	
	-- 获得N(表查询方式)
	local function getNtable(n)
		local N = point_info;
		for d=1, depth do
			N = N[n[d]];
		end
		return N
	end
	
	-- 获得N(函数查询方式)
	local function getNfunc(n)
		local N = point_info;
		for d=1, depth do
			if N[n[d]]==nil then
				return nil;
			end
			N = N[n[d]];
		end
		return N;
	end
	local getN = getNtable;
	
	-- 打开节点
	local function OpenNode(n, parentN)
		local pit = point_info;
		local N = Node(n, parentN);
		
		for d=1, depth-1 do
			if pit[n[d]]==nil then
				pit[n[d]]={}
			end
			pit = pit[n[d]];
		end
		pit[n[depth]] = N;
		
		N.state = open_state;
		open_list:push(N);
	end
	
	-- 关闭节点(搜索open列表中最小f节点，关闭搜索到的节点并返回之)
	local function CloseNode()
		local N = open_list:pop();
		if N~=nil then
			N.state = closed_state;
		end
		return N;
	end
	
	-- 是否为同一节点
	local function CheckEqual(n, N)
		for i, v in ipairs(N.n) do
			if v~=n[i] then
				return false;
			end
		end
		return true;
	end
	
	-- 返回该节点有效周围点
	local function surroundN(N)
		local n = N.n;
		local surlist = {};
		for d=1, depth do
			local coor1 = {};
			local coor2 = {};
			for di=1, depth do
				local c1 = n[di];
				local c2 = n[di];
				
				if di==d then
					c1 = c1+1;
					c2 = c2-1;
					if dimension[di] then
						if c1>dimension[di] then
							coor1 = nil;
						end
						if c2<1 then
							coor2 = nil;
						end
					end
				end
			
				if coor1 then
					tinsert(coor1, c1);
				end
				if coor2 then
					tinsert(coor2, c2);
				end
			end
			
			if coor1 then
				if M(coor1)==0 then
					local sN = getN(coor1);
					if sN~=nil then
						tinsert(surlist, sN);
					else
						OpenNode(coor1, N);
					end
				end
			end
			if coor2 then
				if M(coor2)==0 then
					local sN = getN(coor2);
					if sN~=nil then
						tinsert(surlist, sN);
					else
						OpenNode(coor2, N);
					end
				end
			end
		end
		return surlist;
	end
	
	-- 搜索初始化
	local function init()
		if type(mapdata_or_func)=="table" then
			-- 检查维度
			local tmap = mapdata_or_func;
			while type(tmap)=="table" do
				depth = depth+1;
				dimension[depth] = #tmap;
				if dimension[depth]==0 then
					dimension[depth]=nil;
					depth = depth-1;
					return;
				end
				tmap = tmap[1];
			end
			-- 初始化搜索表
			local pit = point_info;
			for d=1, depth do
				for i=1, dimension[depth] do
					pit[i]={}
				end
				pit = pit[1];
			end
		else
			-- 不做维度有效性检查
			getN = getNfunc;		--使用函数查询版本的getN
			depth = tgetn(start_pt);
			getN(start_pt);
		end
		
		OpenNode(start_pt);
	end
	init();
	
	if dimension==0 then
		return;
	end
	
	while open_list:count() > 0 do
		local N = CloseNode();
		if N==nil then
			break;
		end

		if CheckEqual(end_pt, N) then
			return N;
		end
		
		local sur = surroundN(N);
		for i, sN in pairs(sur) do
			if sN.state==open_state then
				if OptPath(N, sN) then
					N.f = sN.f;
					sN.parent = N;
				end
			end

		end
	end
	return nil;
end

function AStar:path(N)
	if N==nil then
		return nil;
    end
	
	local road = {};
	while N~=nil do
		tinsert(road, 1, N.n);
		N = N.parent;
	end
	return road;
end

function AStar:getPath(...)
	local N = self:emit(...);
	return self:path(N);
end

return AStar;
