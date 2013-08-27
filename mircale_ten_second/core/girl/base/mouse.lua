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

local lm = love.mouse;
if lm==nil then
	return nil;
end

-- 得到基类
local Object = getClass("Object");

-- 鼠标回调处理类
local Mouse = class("Mouse", Object,
{
	-- 记录之前的鼠标位置
	_last_loc_x = 0,
	_last_loc_y = 0,
	_leave = true,
	-- 移动回调
	onMove = function (x, y) end,
	-- 点击回调（滚轮移动）
	onPressed = function (x, y, button) end,
	-- 抬起回调
	onReleased = function (x, y, button) end,
	-- 鼠标离开
	onLeave = function () end,
	-- 鼠标进入
	onReach = function () end,
})

function Mouse:pressed(x, y, button)
	self.onPressed(x, y, button);
end

function Mouse:released(x, y, button)
	self.onReleased(x, y, button);
end

-- move(nil,nil)时自动计算鼠标位置(不存在leave)，move给以位置时手动计算鼠标位置
function Mouse:move(mx, my)
	local x, y = mx or Mouse._getX(), my or Mouse._getY();
	
	if self._leave then
		self.onReach();
	end
	self._leave = false;
	
	if x==self._last_loc_x and y==self._last_loc_y then
		return;
	else
		self.onMove(x, y);
		self._last_loc_x = x;
		self._last_loc_y = y;
	end
end

function Mouse:leave()
	if not self._leave then
		self.onLeave();
	end
	self._leave = true;
end

--返回之前move后的坐标（使得一个实例在不更新move()时，记录下最后一次鼠标出现的位置）
function Mouse:getLastX()
	return self._last_loc_x;
end

function Mouse:getLastY()
	return self._last_loc_y;
end

----------------------------------------------------------------
-- 直接获取love.mouse的方法
Mouse._getPosition = lm.getPosition;
Mouse._getX = lm.getX;
Mouse._getY = lm.getY;
Mouse._isDown = lm.isDown;
Mouse._isGrabbed = lm.isGrabbed;
Mouse._isVisible = lm.isVisible;
Mouse._setGrab = lm.setGrab;
Mouse._setPosition = lm.setPosition;
Mouse._setVisible = lm.setVisible;

return Mouse;
