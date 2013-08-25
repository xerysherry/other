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
local sqrt = math.sqrt;

-- 得到基类
local Object = getClass("Object");

-- 一些简单的数据结构
local Size = class("Size", Object,
{
	-- 变量
	width = 0, height = 0,
	-- 方法
	initialize = function (this, w, h)
		this:setSize(w, h)
	end,
	getSize = function (this) 
		return this.width, this.height; 
	end,
	setSize = function (this, w, h)
		this.width, this.height = w, h;
	end,
});

local Point = class("Point", Object,
{
	-- 变量
	x = 0, y = 0,
	-- 方法
	initialize = function (this, x, y)
		this:setPoint(x, y, w, h)
	end,
	getPoint = function (this) 
		return this.x, this.y; 
	end,
	setPoint = function (this, x, y)
		this.x, this.y = x, y;
	end,
})

local Rect = class("Rect", Object,
{
	-- 变量
	x = 0, y = 0,
	width = 0, height = 0,
	-- 方法
	initialize = function (this, x, y, w, h)
		this:setRect(x, y, w, h)
	end,
	getPoint = function (this) 
		return this.x, this.y; 
	end,
	getSize = function (this) 
		return this.width, this.height; 
	end,
	getRect = function (this) 
		return this.x, this.y, this.width, this.height; 
	end,
	setPoint = function (this, x, y)
		this.x, this.y = x, y;
	end,
	setSize = function (this, w, h)
		this.width, this.height = w, h;
	end,
	setRect = function (this, x, y, w, h)
		this.x, this.y, this.width, this.height = x, y, w, h;
	end,
});

function MergeRect(l, t, w, h, 
				ml, mt, mw, mh)
	local r, b = w, h;
	r = r+l;
	b = b+t;
	local mr, mb = mw, mh;
	mr = mr+ml;
	mb = mb+mt;
	local nl, nt, nr, nb = 0, 0, 0, 0;
	
	if ml <= l then
		nl = l;
	elseif ml < r then
		nl = ml;
	else
		return nil;
	end
	
	if mt <= t then
		nt = t;
	elseif mt < b then
		nt = mt;
	else
		return nil;
	end
	
	if mr < l then
		return nil;
	elseif mr < r then
		nr = mr;
	else
		nr = r;
	end
	
	if mb < t then
		return nil;
	elseif mb < b then
		nb = mb;
	else
		nb = b;
	end
	
	return nl, nt, nr-nl, nb-nt;
end

function IsPointIn(arg1, arg2, arg3)
	if arg3==nil then
		local point, rect = arg1, arg2;
		if rect.x <= point.x and point.x < rect.x+rect.width and
			rect.y <= point.y and point.y < rect.y+rect.height then
			return true;
		else
			return false;
		end
	else
		local x, y, rect = arg1, arg2, arg3;
		if rect.x <= x and x < rect.x+rect.width and
			rect.y <= y and y < rect.y+rect.height then
			return true;
		else
			return false;
		end
	end
end

function PointDist(x1, y1, x2, y2)
	local dx=x1-x2;
	local dy=y1-y2;
	return sqrt(dx*dx+dy*dy);
end
