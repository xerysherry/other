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

-- 文件系统，对love.filesystem（的补充和扩展

local lf = love.filesystem;

-- 得到基类
local Object = getClass("Object");

-- 临时文件对象
local TempFile = class("TempFile", Object,
{
	path = nil,		-- 临时文件路径（相对于love.filesystem的savedir）
});

-- 文件系统对象（无需实例，可直接使用）
local Filesystem = class("Filesystem", Object,
{
	-- 变量
	tempdir = "temp",
	-- 列表
	tempfilelist = nil,	-- 临时文件列表
});

-- 初始化
function Filesystem:initialize(dir)
	if dir then
		tempdir = dir;
	end
	self.tempfilelist = {};
end

----------------------------------------------------------------
-- 直接获取love.filesystem的方法
Filesystem.getSaveDirectory = lf.getSaveDirectory;
Filesystem.getUserDirectory = lf.getUserDirectory;

----------------------------------------------------------------
-- 临时文件相关
-- 变量临时文件名
function Filesystem:getTempFile(path)
	if path==nil then
		return nil;
	end

	for i,v in pairs(self.tempfilelist) do
		if v.path==path then
			return v;
		end
	end
	return nil;
end

-- 创建临时文件
function Filesystem:createTempFromPath(name, path)
	lf.mkdir(self.tempdir);
	-- 拼接临时文件名
	local tempname = self.tempdir.."/"..name;
	-- 检查临时文件是否存在
	if lf.exists(tempname) then
		return nil;
	end

	local file = io.open(path,"rb");
	if file==nil then
		return nil;
	end
	local head = file:seek();
	local size = file:seek("end");
	file:seek("set",head);
	
	-- 创建临时文件
	local tempfile = lf.newFile(tempname);
	tempfile:open("w");
	
	-- 拷贝
	local block = 4*1024*1024;
	local copysize = 0;
	local succ = true;
	while copysize < size and succ do
		if copysize+block >= size then
			succ = tempfile:write(file:read(size-copysize));
			copysize = size;
		else
			succ = tempfile:write(file:read(block));
			copysize = copysize+block;
		end
	end
	
	file:close();
	tempfile:close();

	-- 检查是否拷贝成功
	if not succ then
		lf.remove(tempname);
		return nil;
	end
	
	-- 设置临时文件表
	local existtempfile = self:getTempFile(path)
	if existtempfile==nil then
		local tempfile = TempFile:new();
		tempfile.path = tempname;
		table.insert(self.tempfilelist, tempfile);
	end
	
	return tempname;
end

-- 创建临时文件(成功是返回路径，失败返回nil)
function Filesystem:createTempFromData(name, content)
	lf.mkdir(self.tempdir);
	-- 拼接临时文件名
	local tempname = self.tempdir.."/"..name;
	-- 检查临时文件是否存在
	if lf.exists(tempname) then
		return nil;
	end
	-- 创建临时文件
	local f = lf.newFile(tempname);
	f:open("w");
	f:write(content);
	f:close();
	
	-- 设置临时文件表
	local existtempfile = self:getTempFile(path)
	if existtempfile==nil then
		local tempfile = TempFile:new();
		tempfile.path = tempname;
		table.insert(self.tempfilelist, tempfile);
	end
	
	return tempname;
end

-- 清理临时文件(尝试删除文件)
function Filesystem:clearTemp()
	local clearlist = {};
	-- 尝试删除列表中的临时文件
	for i, v in pairs(self.tempfilelist) do
		if lf.remove(v.path) then
			table.insert(clearlist, 1, i);
		end
	end
	-- 尝试删除列表中没有的文件
	local others = lf.enumerate(self.tempdir);
	for i, v in pairs(others) do
		lf.remove(self.tempdir.."/"..v);
	end
	lf.remove(self.tempdir);
	-- 清理临时文件列表
	local count = table.maxn(clearlist);
	for i,v in pairs(clearlist) do
		table.remove(self.tempfilelist, v);
	end
end

-- 打印临时文件信息
function Filesystem:printTemp()
	for i,v in pairs(self.tempfilelist) do
		print(v.path.." exist:"..tostring(lf.exists(v.path)));
	end
end

return Filesystem;
