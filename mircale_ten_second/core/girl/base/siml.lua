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

--[[
简易缩进标记语言
Simple Indented Markup Language
意在设计一种简单的，可读的结构表示语言，规避那些繁琐的程序员式的
结构定义语法。结构通过简单的缩进，及少量标记符号定义。

本文表述
t1
	t2
	t3
s1
	s2
		s3
		s4
	s5
	s6
#u1
	u2
	_u3
	u4
		u5
		u6
		hello
#
	1
	2

	
对应的Lua表述
{
	t1 = {t2, t3}
	s1 = {
		--表
		s2 = {s3, s4},
		--数组
		[1] = s5,
		[2] = s6,
	},
	[1] = {
		name = u2,
		value = {
			u2u3,
			u4 = {u5, u6},
		}
		self = ...,	-- 指向自己
	},
	[2] = {1,2}
}
]]

local sformat = string.format;
local slen = string.len;
local sfind = string.find;
local ssub = string.sub;

local tinsert = table.insert;
local tremove = table.remove;

local Object = getClass("Object");
local SIML = class("SIML", Object, {});

function SIML:initialize()
	error("can't instance")
end

function SIML.encodeFromFile(path)
	local file = assert(io.open(path, "rb")); 
	local data = file:read("*all");
	file:close();
	return SIML.encode(data);
end

function SIML.encode(script)
	local indent_capture_format = "(%s[ \t]*)([#_\\]?)([^\n]*)[\n]?"
	local indent_capture = sformat(indent_capture_format, "");
	local global_table = {};
	
	local length = slen(script);
	local offset = 1;
	local itable = {};
	local ttable = {};
	
	--缩进相关
	local cIndent=function()
		return itable[#itable] or "";
	end
	local cIndentFind=function(indent)
		local fi = nil;
		for i=#itable, 1, -1 do
			if itable[i]==indent then
				fi = i;
				break;
			end
		end
		if fi==nil then
			return nil, nil;
		end
		return fi, #itable-fi;
	end
	local cIndentPush=function(indent)
		tinsert(itable, indent);
		return cIndent();
	end
	local cIndentPop=function()
		tremove(itable);
		return cIndent();
	end
	--当前表
	local cTable=function()
		return ttable[#ttable] or global_table;
	end
	local cTablePush=function(t)
		tinsert(ttable, t);
		return cTable();
	end
	local cTablePop=function()
		tremove(ttable);
		return cTable();
	end
	--缓冲记录
	local cindent = cIndent();
	local ctable = cTable();
	
	local prev_tag = nil;
	local prev_v = nil;
	local parseString = function(v)
		if v=="" then
			return v;
		end
		local out = nil;
		local outf = sformat("return \"%s\"", v);		
		if pcall(function() out = loadstring(outf)() end) then
			return out;
		end
		return v;
	end

	-- #
	local InsertSharpTag = function(v)
		if v~="" then
			-- 有名表 ctable[#ctable]={name=prev_v, value={子表内容}, self=ctable[#ctable]}
			tinsert(ctable, {name=v, value={}});
			ctable[#ctable].self = ctable[#ctable];
			return ctable[#ctable].value;
		else
			-- 无名表
			tinsert(ctable, {});
			return ctable[#ctable];
		end
		-- 无意义
		return nil;
	end
	
	local InsertTable = function()
		if prev_tag=="" and prev_v=="" then
			return;
		end
		if prev_tag=="#" then
			InsertSharpTag(prev_v);
		elseif prev_v~="" then
			-- 链接标记符
			if prev_tag=="_" then
				ctable[#ctable] = ctable[#ctable] .. prev_v;
			else
			-- 列表项
				tinsert(ctable, prev_v);
			end
		end
		prev_v="";
		prev_tag="";
	end
	local SpecialTagInsertTable = function()
		if prev_tag=="" and prev_v=="" then
			--error("Indent is invalid!");
			return;
		end
		-- 检测上级(父)标签
		-- 自增数值表 
		if prev_tag=="#" then
			ctable = cTablePush(InsertSharpTag(prev_v));
		-- 键值表 ctable[prev_v]={子表内容}	
		else
			-- 链接标记符
			if prev_tag=="_" then
				prev_v = ctable[#ctable] .. prev_v;
				tremove(ctable);
			end
			ctable[prev_v] = {};
			ctable = cTablePush(ctable[prev_v]);
		end

		prev_v="";
		prev_tag="";
	end
	
	while offset<length do
		local so,eo,indent,tag,v=sfind(script, indent_capture, offset);
		if offset~=so then
			InsertTable();
			cindent = cIndentPop();
			ctable = cTablePop();
			indent_capture = sformat(indent_capture_format, cindent);
			--print(slen(cindent), indent_capture);
		else
			if v~="" or tag~="" then
				if indent==cindent then
					InsertTable();
				else
					assert(ssub(indent, 1, slen(cindent))==cindent, "Indent is invalid!");
					indent_capture = sformat(indent_capture_format, indent);
					cindent = cIndentPush(indent);
					SpecialTagInsertTable();
				end
				prev_v=parseString(v);
				prev_tag=tag;
			end
			offset=eo+1;
		end
		
	end
	InsertTable();
	return global_table;
end

return SIML;
