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

-- 单选组(会设置所有的onCheckChange)
local RadioGroup = class("RadioGroup", Object, 
{
	checks = nil,
	-- 组成员状态改变回调
	onRadioChange = function (this) end,
});

function RadioGroup:initialize()
	self.checks = {};
end

function RadioGroup:add(idx, check, changecallback)
	assert(idx~=nil, "idx can't be a nil");
	assert(check~=nil, "check can't be a nil");
	local function onCheckChange(this)
		if not this.check then
			this.check = true;
			return;
		else
			for i, v in pairs(self.checks) do
				if v[1]~=this then
					v[1].check=false;
				end
				if type(v[2])=="function" then
					v[2](v[1], i);
				end
			end
			self:onRadioChange();
		end
	end
	check.onCheckChange = onCheckChange;
	self.checks[idx]={check, changecallback};
end

function RadioGroup:del(idx)
	assert(idx~=nil, "idx can't be a nil");
	self.ui_list[idx]=nil;
end

function RadioGroup:getCheck()
	for i, v in pairs(self.checks) do
		if v[1].check then
			return i;
		end
	end
	return nil;
end

return RadioGroup;
