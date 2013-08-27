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

----------------------------------------------------------------
-- 定时器类
local Timer = class("Timer", Object,
{
	-- 停止标记
	paused = true,
	-- 计数参数
	current_seconds = 0,
	internal_seconds = 1,
	-- 定时器回调
	onTimer = function () end;
});

function Timer:pause()
	self.paused = true;
end

function Timer:start()
	self.paused = false;
end

function Timer:reset(seconds)
	self.internal_seconds = seconds or self.internal_seconds;
end

function Timer:tic(dt)
	if self.paused then
		return;
	end
	self.current_seconds = self.current_seconds+dt;
	if self.current_seconds >= self.internal_seconds then
		self.onTimer();
		self.current_seconds = self.current_seconds-self.internal_seconds;
	end
end

----------------------------------------------------------------
-- 定时器列表类
local TimerList = class("TimerList", Object,
{
	timerlist = nil,
});

function TimerList:initialize(...)
	self.timerlist = {};
end

function TimerList:createTimer(idx, seconds)
	assert(self.timerlist[idx]==nil,"this "..idx.." is not nil");
	local _newtimer = Timer:new();
	_newtimer:reset(seconds);
	self.timerlist[idx] = _newtimer;
	return self.timerlist[idx];
end

function TimerList:pause()
	for i,timer in pairs(self.timerlist) do
		timer:pause();
	end
end

function TimerList:start()
	for i,timer in pairs(self.timerlist) do
		timer:start();
	end
end

function TimerList:tic(dt)
	for i,timer in pairs(self.timerlist) do
		timer:tic(dt);
	end
end

function TimerList:getTimer(idx)
	return self.timerlist[idx];
end

function TimerList:delTimer(idx)
	self.timerlist[idx] = nil;
end

return TimerList;
