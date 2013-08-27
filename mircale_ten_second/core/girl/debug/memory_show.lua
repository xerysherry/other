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
local mceil = math.ceil;

-- 显示参数
local _show = true;
local _font = nil;
local _font_color = {255,255,255};
local _font_x = 0;
local _font_y = 12;
local _unit = 0;			-- 0: KB, 1: MB
local _tic = 1.0;
local _limit_tic = 1.0;
local _memory_size = 0;

-- FPS 显示
if type(getDebuger) == "function" then
	getDebuger():setCustomUpdate("_memory_show_update", 
	function (dt)
		if _show then
			_tic = _tic + dt;
			if _tic >= _limit_tic then
				_memory_size = collectgarbage("count");
				if _unit == 1 then
					_memory_size = mceil(_memory_size / 1024) .. "MB";
				else
					_memory_size = mceil(_memory_size) .. "KB";
				end	
				_tic = 0;
				_memory_size = "Memory :" .. _memory_size;
			end
		end
	end);
	getDebuger():setCustomDraw("_memory_show_draw", 
	function ()
		if _show then
			local prev_font = nil;
			if _font then
				prev_font = love.graphics.getFont();
				love.graphics.setFont(_font);
			end
			local font_x = _font_x;
			local font_y = _font_y;
			if font_x < 0 then
				font_x = love.graphics.getWidth() + font_x;
			end
			if font_y < 0 then
				font_y = love.graphics.getHeight() + font_y;
			end
		
			love.graphics.setColor(_font_color);
			love.graphics.print(_memory_size, font_x, font_y);
			
			if prev_font then
				love.graphics.setFont(prev_font);
			end
		end
	end);
end

function memoryShow(value)
	_show = value;
end

function memorySetFont(font)
	_font = font;
end

function memorySetColor(color)
	_font_color = color;
end

function memorySetLoc(x, y)
	_font_x = x or 0;
	_font_y = y or 0;
end
