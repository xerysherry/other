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

-- UTF8字符串对象
local Utf8 = class("Utf8", Object,
{
	str = "",		-- 字符串
	chars = {},		-- 字符列表
	len = 0,		-- 字符长（有效UTF8字符）
});

-- 解析UTF8字符串
local function utf8_parse(utf8obj)
	-- 获得字符长
	local length = string.len(utf8obj.str);
	
	-- 清空字符列表
	utf8obj.chars = {};
	utf8obj.len = 0;
	
	-- 处理字符串
	local byte = 0;
	local index = 1;
	while index<=length do
		byte = string.byte(utf8obj.str, index);
		if 0x00 <= byte and byte <= 0x7F then
			table.insert(utf8obj.chars, {index,1});
			index = index + 1;
		elseif 0xC0 <= byte and byte <= 0xDF then
			table.insert(utf8obj.chars, {index,2});
			index = index + 2;
		elseif 0xE0 <= byte and byte <= 0xEF then
			table.insert(utf8obj.chars, {index,3});
			index = index + 3;
		elseif 0xF0 <= byte and byte <= 0xF7 then
			table.insert(utf8obj.chars, {index,4});
			index = index + 4;
		else
			-- 非法的UTF8字符串
			return false;
		end
		utf8obj.len = utf8obj.len + 1;
	end
	return true;
end

-- 新建一个UTF8字符串对象（参数必须为UTF8或者为nil）
function Utf8:new(utf8str)
	local _newinstance = {};
	setmetatable(_newinstance, self);
	setmetatable(_newinstance, {
		__mode = "k",
		__index = self, 
		__tostring = self.getName,
		__concat = self.concat,
		__eq = self.equal,
	});
	_newinstance.name = self.name..".Instance";
	
	if type(utf8str)=="string" then
		_newinstance:set(utf8str);
	end
	return _newinstance;
end

function Utf8:initialize()
	error("please use method 'new'");
end

-- 设置UTF8字符串（参数必须为UTF8或者为nil）
function Utf8:set(utf8str)
	self.str = utf8str;
	return utf8_parse(self);
end

-- 获得UTF8单字符
function Utf8:char(index)
	if index > self.len or index < 1 then
		return "";
	end
	return string.sub(self.str, 
		self.chars[index][1], self.chars[index][1]+self.chars[index][2]-1);
end

-- 获得UTF8子串
function Utf8:sub(start_index, end_index)
	if self.len==0 then
		return "";
	end
	if start_index==nil or start_index < 1 then
		start_index = 1;
	end
	if end_index==nil or end_index > self.len or end_index < 0 then
		end_index = self.len;
	end
	if start_index>end_index then
		return "";
	end
	
	return string.sub(self.str,
		self.chars[start_index][1], self.chars[end_index][1]+self.chars[end_index][2]-1);
end

-- 查找文本
function Utf8:find(str)
	local pos = string.find(self.str, str);
	if not pos then
		return pos;
	end
	
	local utf8sub = Utf8:new(string.sub(self.str, pos));
	return self.len - utf8sub.len + 1;
end

-- 字符连接 ex. utf8_1..utf8_2
function Utf8.concat(utf8obj1, utf8obj2)
	return Utf8:new(utf8obj1.str..utf8obj2.str);
end

-- 字符串相等比较
function Utf8.equal(utf8obj1, utf8obj2)
	return utf8obj1.str == utf8obj2.str;
end

return Utf8;
