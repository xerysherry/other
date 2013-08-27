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

-- Ui切换器（适用于Object.View和Object.Gui）
local UiSwitch = class("UiSwitch", Object, 
{
	ui_list = nil,
});

function UiSwitch:initialize()
	ui_list = {};
end

-- 添加/删除ui对象
function UiSwitch:add(idx, ui)
	assert(idx~=nil, "idx can't be a nil");
	assert(ui~=nil, "ui can't be a nil");
	self.ui_list[idx]=ui;
end

function UiSwitch:del(idx)
	assert(idx~=nil, "idx can't be a nil");
	self.ui_list[idx]=nil;
end

-- 切换方法,切换对象show设为true,其他对象show设为false
function UiSwitch:switch(idx)
	if self.ui_list[idx]==nil then
		return;
	end
	for i, v in pairs(self.ui_list) do
		if i==idx then
			v.show = true;
		else
			v.show = false;
		end
	end
end

return UiSwitch;
