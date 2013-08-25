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

local tinsert = table.insert;

-- 得到基类
local Object = getClass("Object");
local Timer = getClass("Object.Timer");

-- 空闲任务调度类
local Idle = class("Idle", Object,
{
	task = nil,
	timer = nil,
});

function Idle:initialize(delay_time)
	self.task = {};
	
	self.timer = Timer();
	self.timer:reset(delay_time);
	self.timer.onTimer = function ()
		for i, func in pairs(self.task) do
			if func() then
				self.task[i]=nil;
			end
		end
	end
	self.timer:start();
end

-- 添加任务函数，返回true表示任务完成，会被移除
function Idle:addTask(idx_or_func, func)
	if func==nil then
		if type(idx_or_func)~="function" then
			return;
		end
		tinsert(self.task, idx_or_func);
	else
		if type(func)~="function" then
			return;
		end
		self.task[idx_or_func] = func;
	end
end

function Idle:clearTask(idx)
	self.task[idx] = nil;
end

function Idle:tic(dt)
	self.timer:tic(dt);
end

return Idle;
