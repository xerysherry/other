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
local Filesystem = getClass("Object.Filesystem");

local lg = love.graphics;

-- 字体
local Font = class("Font", Object, 
{
	path = nil,				-- 路径
	size = 0,
	font = nil,				-- love字体
});

-- 字体管理器
local FontManager = class("FontManager", Object, 
{
	-- 音频文件系统
	filesystem = nil,
	fontlist = nil,
});

----------------------------------------------------------------
-- 初始化一个字体管理器
function FontManager:initialize(tempdir)
	-- 初始内部文件系统类
	self.filesystem = Filesystem:new(tempdir);
	self.fontlist = {};
	self:createFontFromSize("_system",12);
end

function FontManager:getSamePathFont(path, size)
	if path==nil then
		return nil;
	end
	
	for i,v in pairs(self.fontlist) do
		if path==v.path and size==v.size then
			return v;
		end
	end
	return nil;
end

function FontManager:createFontFromPath(idx, path, size)
	self.fontlist[idx] = self:getSamePathFont(path, size);
	if self.fontlist[idx]==nil then
		self.fontlist[idx] = Font:new();
		self.fontlist[idx].path = path;
		self.fontlist[idx].font = lg.newFont(path, size);
	end
end

function FontManager:createFontFromSize(idx, size)
	self.fontlist[idx] = self:getSamePathFont("_default", size);
	if self.fontlist[idx]==nil then
		self.fontlist[idx] = Font:new();
		self.fontlist[idx].path = "_default";
		self.fontlist[idx].font = lg.newFont(size);
	end
end

function FontManager:createFontFromPathPlus(idx, path, size)
	local path = self.filesystem:createTempFromPath(idx, path);
	self:createFontFromPath(idx, path, size);
end

-- 返回字体
function FontManager:getFont(idx)
	local f = self.fontlist[idx];
	if f==nil then
		return nil;
	end
	return f.font;
end

-- 设置字体
function FontManager:setFont(idx)
	local f = self.fontlist[idx];
	if f then
		lg.setFont(f.font);
	else
		lg.setFont(self.fontlist["_system"].font);
	end
end

FontManager._print = lg.print;
FontManager._printf = lg.printf;

return FontManager;
