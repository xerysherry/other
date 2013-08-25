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

local odate = os.date;
local otime = os.time;
local odifftime = os.difftime;

local Object = getClass("Object");

local DateInfo = class("DateInfo", Object, {
	date = nil,
});

local weekday = {"Sunday", "Monday", "Tuesday", "Wednesday", 
	"Thursday", "Friday", "Saturday"};
local month = {"January", "February", "March", "April",
	"May", "June", "July", "August",
	"September", "October", "Novemeber", "December",};
	
-- nil时创建当前时间(重写new方法是为了实现运算符重载)
function DateInfo:new(t)
	local _newinstance = {};
	setmetatable(_newinstance, self);
	setmetatable(_newinstance, {
		__mode = "k",
		__index = self, 
		__tostring = self.getName,
		__sub = self.sub,
		__eq = self.equal,
	});
	_newinstance.name = self.name..".Instance";
	
	if type(t)=="table" then
		_newinstance.date = t;
	elseif type(t)=="number" then
		_newinstance.date = odate("!*t", t);
	else
		_newinstance.date = odate("*t");
	end
	return _newinstance;
end

function DateInfo:initialize()
	error("please use method 'new'");
end

function DateInfo:getTic()
	return otime(self.date);
end

function DateInfo:getHour()
	return self.date.hour;
end

function DateInfo:getMin()
	return self.date.min;
end

function DateInfo:getSec()
	return self.date.sec;
end

function DateInfo:getYear()
	return self.date.year;
end

function DateInfo:getMonth()
	return self.date.month;
end

function DateInfo:getDay()
	return self.date.day;
end

function DateInfo:getWeekDay()
	return self.date.wday;
end

function DateInfo:getMonthStr()
	return month[self.date.month];
end

function DateInfo:getWeekDayStr()
	return weekday[self.date.wday];
end

function DateInfo.sub(di1, di2)
	return odifftime(otime(di1.date), otime(di2.date));
end

function DateInfo.equal(di1, di2)
	return otime(di1.date) == otime(di2.date);
end

local Date = class("Date", Object, {});

function Date:initialize()end

function Date.getDate(t)
	return DateInfo:new(t);
end

return Date;
