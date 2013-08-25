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

--基类

--类列表, weak table
local _classes = setmetatable({}, {__mode = "k"});

--初始化元数据
local function init_metatable(class, parent)
	class = class or {};
	setmetatable(class, {
		__mode = "k",
		__index = parent or Object, 
		__tostring = class.getName,
		__call = class.new
	});
	class.__index = class;
	return class;
end

--声明Object成员
local Object = {
	--成员属性
	name = "Object",
	--父类
	super = nil,
	
	--成员方法
	_new = function (this, o) 
		local _newinstance = o or {};
		setmetatable(_newinstance, this);
		init_metatable(_newinstance, this);
		--实例名：Instance
		_newinstance.name = this.name..".Instance";
		_newinstance.super = this;
		return _newinstance;
	end,
	
	-- 新实例
	new = function (this, ...)
		local _newinstance = this:_new();
		_newinstance:initialize(...);
		return _newinstance;
	end,
	-- 初始化
	initialize = function (this, ...)
	end,
	-- 获得对象名
	getName = function (this)
		return this.name;
	end,
	-- 获得子类
	getClass = function (this, name)
		local classname = this.name.."."..name;
		return getClass(classname);
	end
};

-- 设置Object元数据
init_metatable(Object);
-- object类添加到类列表中
_classes[Object] = Object;

-- 通过类全名找到类
function getClass(name)
	for i, v in pairs(_classes) do
		if tostring(v)==name then
			return v;
		end
	end
	return nil;
end

--新类的声明方法
-- o:新类的基础数据表
function class(name, parent, o)
	--assert(parent~=nil,"Who are your parent?")
	-- if parent==nil then
		-- parent = Object;
	-- end
	if type(name)~="string" then
		name = "Unnamed";
	end

	local _instance = parent:_new(o);
	_instance.name = parent.name.."."..name;
	_classes[_instance] = _instance;
	return _instance;
end

-- 另一种类声明方式，适用于跨文件local类继承
-- 主要内部使用
function _class(name, o)
	-- 检查类是否已经存在
	assert(getClass(name)==nil, name.." is exist");

	local _, _, pstr = string.find(name, "(.+)%.[^.]+");
	local parent = getClass(pstr);
	-- 检查父类是否存在
	assert(parent~=nil, name.." can't find parent");

	local _instance = parent:_new(o);
	_instance.name = name;
	_classes[_instance] = _instance;
	return _instance;
end

-- 打印声明的类（调试用）
function printAllClass()
	for i, v in pairs(_classes) do
		print(i);
	end
end

return Object;
