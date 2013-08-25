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

-- 使用说明
-- 字典表格式
-- {
-- 		["str1"] = "Text1",
--		["str2"] = "Text2",
-- }
-- lang:getString("str1")						-> return "Text1"
-- lang:getStringPlus("This is a |str2|!")		-> return "This is a Text2!"

local sfind = string.find;

-- 获得Object
local Object = getClass("Object");

-- Lang类（格式文本替换）
local Lang = class("Lang", Object {
	dict = nil,
});

function Lang:initialize()
	self.dict = {};
end

-- 设置字典表
function Lang:setDict(dict)
	if type(dict)~="table" then
		return false;
	end
	self.dict = dict;
end

function Lang:getString(word)
	local str = self.dict[word];
	if str~=nil then
		return str;
	else
		return word;
	end
end

function Lang:getStringPlus(word)
	local out = "";
	local fir = "";
	local nxt = word;
	local _ = nil;
	while nxt~=nil and nxt~="" do
		_, _, fir, nxt = sfind(nxt, "|?([^|]+)|?(.*)");
		out = out..self:getString(fir);
	end
	return out;
end

function Lang:print(...)
	for _, v in ipairs({...}) do
		print(self:getStringPlus(v));
	end
end

return Lang;
