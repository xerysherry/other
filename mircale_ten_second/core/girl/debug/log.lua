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
local tremove = table.remove;
local tinsert = table.insert;
local lf = love.filesystem;
local Utf8 = getClass("Object.Utf8");

-- 显示参数
local _show = true;
local _show_line = 10;
local _show_text_list = {};  -- 1:text 2:color
local _font = nil;
local _font_x = -1;
local _font_y = 0;
local _font_align = "right";
local _font_row_pitch = 0;
local _log_filename = "log.txt";
local _log_writefile = false;
local _log_file = nil;

if type(getDebuger) == "function" then
	getDebuger():setCustomDraw("_log_show_draw", 
	function ()
		if _show then
			local prev_font = love.graphics.getFont();
			if _font then
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
			
			local font_height = prev_font:getHeight();
			local font_h = font_y;
			local cur_font = _font or prev_font;
			local font_cx = font_x;
			local text_length = 0;
			
			for _, v in pairs(_show_text_list) do
				love.graphics.setColor(v[2]);
				font_cx = font_x;
				if _font_align=="right" then
					font_cx = font_cx - cur_font:getWidth(v[1]);
				elseif _font_align=="center" then
					font_cx = font_cx - cur_font:getWidth(v[1])/2;
				end
				love.graphics.print(v[1], font_cx, font_h);
				font_h = font_h + font_height + _font_row_pitch;
			end
			
			if _font then
				love.graphics.setFont(prev_font);
			end
		end
	end);
end

local function ShiftLine(text)
	if text=="" or text=="\n" or text==nil then
		return nil, nil;
	end
	
	local pos = 0
	local shift = false;
	local utf8text = Utf8:new(text);
	
	pos = utf8text:find("\n");
	if pos==1 then
		utf8text = Utf8:new(utf8text:sub(2));
		pos = utf8text:find("\n");
	end
	
	local prev_line = utf8text.str;
	local next_line = nil;
	if pos then
		prev_line = utf8text:sub(1, pos-1);
		next_line = utf8text:sub(pos);
	end
	return prev_line, next_line;
end

local function LogFileWrite(text)
	if _log_file==nil then
		_log_file = assert(lf.newFile(_log_filename));
		_log_file:open("a");
	end
	_log_file:write(text);
	_log_file:write("\n");
end

function logShow(value)
	_show = value;
end

function logSetShowLine(line)
	_show_line = line or _show_line;
end

function logClear()
	_show_text_list = {};
end

function logSetFont(font)
	_font = font;
end

function logSetLoc(x, y)
	_font_x = x or 0;
	_font_y = y or 0;
end

function logSetRowPitch(value)
	_font_row_pitch = value or 0;
end

function logSetAlign(align)
	_font_align = align;
	if _font_align ~= "center" and
		_font_align ~= "left" and
		_font_align ~= "right" 
	then
		_font_align = "left";
	end
end

function logSetLogFile(name)
	if name=="" or text==nil then
		return;
	end
	if _log_file~=nil then
		_log_file:close();
		_log_file = nil;
	end
	_log_file = name;
end

function logResetFile()
	if _log_file~=nil then
		_log_file:close();
		_log_file = nil;
	end
	lf.remove(_log_filename);
end

function logEnableFile(value)
	_log_writefile = value;
end

function logPrint(text, color)
	if text=="" or text==nil or text=="/n" then
		return;
	end
	if _log_writefile then
		LogFileWrite(text);
	end
	if #_show_text_list >= _show_line then
		tremove(_show_text_list, 1);
	end

	color = (color and {color[1] or 0, 
						color[2] or 0,
						color[3] or 0,
						color[4] or 255}) or {255,255,255};
	local p, n = text, nil;
	repeat
		p, n = ShiftLine(p);
		if p~=nil then
			tinsert(_show_text_list, {p, color});
		end
		p = n;
		n = nil;
	until p == nil;
end
