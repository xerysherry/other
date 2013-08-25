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
local tremove = table.remove;

-- 得到基类
local Object = getClass("Object");

-- 信号量
-- 用于多个代码文件，对象中存储事件
local Signal = class("Signal", Object, 
{
	signals = nil,
	signalEvent = nil,
});

function Signal:initialize()
	self.signals = {};
	self.signalEvent = {};
end

-- 执行
function Signal:emit()
	for i,signal in pairs(self.signals) do
		local signalEvent = self.signalEvent[signal.name];
		if signalEvent then
			local param = signal.param;
			for i, func in pairs(signalEvent) do
				func(unpack(signal.param));
			end
		end
	end
	self.signals={};
end

-- 注册信号事件
function Signal:regSignal(signal, func)
	assert(type(func)=="function", "func must be a function!");
	
	if self.signalEvent[signal]==nil then
		self.signalEvent[signal] = {};
	end
	tinsert(self.signalEvent[signal], func);
end

-- 反注册信号事件
function Signal:unregSignal(signal, func)
	if self.signalEvent[signal]==nil then
		return;
	end
	
	local signalEvent = self.signalEvent[signal];
	for i, f in pairs(signalEvent) do
		if f==func then
			tremove(signalEvent, i);
			break;
		end
	end
end

-- 发送一个信号
function Signal:send(signal, ...)
	tinsert(self.signals, {
		name = signal,
		param = {...},
	});
end

return Signal;
