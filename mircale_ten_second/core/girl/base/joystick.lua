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

local lj = love.joystick;
if lj==nil then
	return nil;
end

-- 得到基类
local Object = getClass("Object");

-- 手柄回调处理类
local Joystick = class("Joystick", Object,
{
	-- 按下回调
	onPressed = function (joystick, button) end,
	-- 抬起回调
	onReleased = function (joystick, button) end,
});

function Joystick:pressed(joystick, button)
	self.onPressed(joystick, button);
end

function Joystick:released(joystick, button)
	self.onReleased(joystick, button);
end

----------------------------------------------------------------
-- 直接获取love.joystick的方法
Joystick._close = lj.close;
Joystick._getAxes = lj.getAxes;
Joystick._getAxis = lj.getAxis;
Joystick._getBall = lj.getBall;
Joystick._getHat = lj.getHat;
Joystick._getName = lj.getName;
Joystick._getNumAxes = lj.getNumAxes;
Joystick._getNumBalls = lj.getNumBalls;
Joystick._getNumButtons = lj.getNumButtons;
Joystick._getNumHats = lj.getNumHats;
Joystick._getNumJoysticks = lj.getNumJoysticks;
Joystick._isDown = lj.isDown;
Joystick._isOpen = lj.isOpen;
Joystick._open = lj.open;

return Joystick;
