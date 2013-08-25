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

local lk = love.keyboard
if lk==nil then
	return nil;
end

-- 得到基类
local Object = getClass("Object");

-----------------------------------------------------------
-- 键盘特殊按钮枚举
local SpecialKeyEnum = class("SpecialKeyEnum", Object,
{
	_escape = 27,	-- Esc键
	_backspace = 8,	-- 退格键
	_enter = 13,	-- 回车键
	_tab = 9,		-- 制表符
	_space = 32,	-- 空格符
});

-- 检查
function SpecialKeyEnum.check(char, unicode)
	return string.byte(char) == unicode;
end

-----------------------------------------------------------
-- 键盘回调处理类
local Keyboard = class("Keyboard", Object,
{
	-- 输入字符回调事件函数
	onChar = function (char) end,
	-- 按下键盘回调事件函数
	onPressed = function (key) end,
	-- 释放键盘回调事件函数
	onReleased = function (key) end,
});

function Keyboard:pressed(key, unicode)
	self.onPressed(key);
	if unicode~=0 then
		--非0清空下表示为可记录字符
		--注意：退格符，回车符，制表符是可以记录字符，请在onChar回调中处理之
		self.onChar(string.char(unicode));
	end
end

function Keyboard:released(key)
	self.onReleased(key);
end

----------------------------------------------------------------
-- 直接获取love.keyboard的方法
Keyboard._getKeyRepeat = lk.getKeyRepeat;
Keyboard._setKeyRepeat = lk.setKeyRepeat;
Keyboard._isDown = lk.isDown;

return Keyboard;
