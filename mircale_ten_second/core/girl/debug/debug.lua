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
local sfind = string.find;
local ssub = string.sub;
local slen = string.len;
local sbyte = string.byte;
local srep = string.rep;
local lg = love.graphics;
local lk = love.keyboard;
local lf = love.filesystem;

-- 得到基类
local Object = getClass("Object");
local Keyboard = getClass("Object.Keyboard");
local Mouse = getClass("Object.Mouse");
local Timer = getClass("Object.Timer");
local Date = getClass("Object.Date");
local Utf8 = getClass("Object.Utf8");

local debug_fn = "debug.json";
local debug_conf = lf.newFile(debug_fn);

local isbreakpoint = false;
local label = "Debug>";

local lua_print = print;
local _gdc_print = nil;

local DebugConsoleVersion = "0.32";

----------------------------------------------------------------
-- 断点列表
local BPL =
{
	list = {},
};

function BPL:load()
	if not json then
		return;
	end

	if not lf.exists(debug_fn) then
		return;
	end
	if debug_conf and debug_conf:open('r') then
		local jb = debug_conf:read();
		self.list = json.decode(jb);
		debug_conf:close();
	end
end

function BPL:save()
	if not json then
		return;
	end

	if debug_conf and debug_conf:open('w') then
		local jb = json.encode(self.list);
		debug_conf:write(jb);
		debug_conf:close();
	end
end

function BPL:checkBp(n)
	local name = n;
	if not name then
		local info=debug.getinfo(3,"Sl")
		name=info.source.."("..info.currentline..")"
	end
	
	local trigger=self.list[name];
	if trigger==nil then
		return false;
	end
	return trigger;
end

function BPL:bp(n)
	local name = n;
	if not name then
		local info=debug.getinfo(3,"Sl")
		name=info.source.."("..info.currentline..")"
	end
	
	local trigger=self.list[name];
	if trigger==nil then
		self.list[name]=true;
		trigger=true;
		self:save();
	end
	
	if trigger then
		isbreakpoint = true;
		error("Break Point named '"..name.."' is triggered");
	end
end

function BPL:trigger(n, on)
	if not n then
		return;
	end
	
	if on==nil then
		self.list[n] = true;
	else
		self.list[n] = on;
	end
	self:save();
end

function BPL:del(n)
	self.list[n] = nil;
	self:save();
end

function BPL:clear()
	self.list = {};
	self:save();
end

function BPL:printBPInfo()
	local count = 0;
	for i, v in pairs(self.list) do
		print(" ["..i.."] : "..((v and "on") or "off"));
		count = count + 1;
	end
	
	if count==0 then
		print("Break Point List is empty.")
	else
		print("---- Break Point Number : "..count.." ----");
	end
end

-- 动态断点 格式:("line:@luafile.lua(line)", ep. "line:@debug/debug.lua(50)")
function BPL.traceLine (event, line)
    local info=debug.getinfo(2,"Sl")
	local name="line:"..info.source.."("..info.currentline..")"
    if BPL:checkBp(name) then
		isbreakpoint = true;
		local err = function ()
			error("Break Point named '"..name.."' is triggered");
		end
		err();
	end
end

-- 格式:("call:@func", ep. "call:@draw")
function BPL.traceCall (event)
    local n = debug.getinfo(2, "n").name
	if not n then
		return;
	end
    local name = "call:@"..n;
	if BPL:checkBp(name) then
		isbreakpoint = true;
		local err = function ()
			error("Break Point named '"..name.."' is triggered");
		end
		err();
	end
end

-- 格式:("return:@func", ep. "return:@draw")
function BPL.traceReturn (event)
    local n = debug.getinfo(2, "n").name
	if not n then
		return;
	end
    local name = "return:@"..n;
	if BPL:checkBp(name) then
		isbreakpoint = true;
		local err = function ()
			error("Break Point named '"..name.."' is triggered");
		end
		err();
	end
end

BPL:load();

-- 
-- debug_font
-- debug_font_color
-- debug_bg_color
-- debug_cursor_color

-- 字符串切断判定(是否全字串, 截断串, 下一个串)
local function StringCutoffUTF8(text, font, width)
	if text=="" or text=="\n" then
		return true, "", "";
	end
	
	local pos = 0
	local shift = false;
	local utf8text = Utf8:new(text);
	
	pos = utf8text:find("\n");
	if pos==1 then
		utf8text = Utf8:new(utf8text:sub(2));
		pos = utf8text:find("\n");
	end
	
	local line = utf8text.str;
	if pos then
		line = utf8text:sub(1, pos-1);
		shift = true;
	end

	local utf8line = Utf8:new(line);
	local cut = utf8line.len;
	local tmpstr = "";
	repeat
		tmpstr = utf8line:sub(1, cut);
		cut = cut - 1;
	until font:getWidth(tmpstr)<width;
	
	local len = cut+1+(((shift and pos==cut+1) and 1) or 0);
	return len==utf8text.len, tmpstr, utf8text:sub(len+1);
end

local function StringCutoffANSI(text, font, width)
	if text=="" or text=="\n" then
		return true, "", "";
	end

	local pos = 0
	local shift = false;

	pos = sfind(text, "\n");
	if pos==1 then
		text = ssub(text,2);
		pos = sfind(text, "\n");
	end
	
	local line = text;
	if pos then
		line = ssub(text, 1, pos-1);
		shift = true;
	end

	local cut = slen(line);
	repeat
		tmpstr = ssub(line, 1, cut);
		cut = cut - 1;
	until font:getWidth(tmpstr)<width;
	
	local len = cut+1+(((shift and pos==cut+1) and 1) or 0);
	return len==slen(text), tmpstr, ssub(text, len+1);
end

local function StringCutoff(text, font, width)
	local r1, r2, r3;

	if pcall(function() r1,r2,r3 = StringCutoffANSI(text, font, width) end) then
		return r1, r2, r3;
	else
		if not pcall(function() r1,r2,r3 = StringCutoffUTF8(text, font, width) end) then
			debug.debug();
		end
	end
	return r1, r2, r3;
end

----------------------------------------------------------------
-- Debug Console
local Debug = class("Debug", Object,
{
	-- 呼出快捷键
	_shortcut_key = {"d", "lctrl"},
	-- screenshot 快捷键
	_screenshot_shortcut_key = {"t", "lctrl"},
	-- 是否处于呼出状态
	_callout = false,
	
	-- 输入文本（键盘输入的文本）
	_text_in = "",
	_text_width= nil,
	-- 输出文本(内部记录用)
	_text_out = nil,
	_text_out_maxn = 500,
	
	-- 打印文本（屏幕打印用）
	_print_out = nil,
	_print_out_maxn = 500,
	_print_pos = 1,
	
	page_step = 35,
	
	-- 指令错误显示方式
	simple_error = true;
	
	-- 指令历史
	_cmdhistory = nil,
	_cmdhistory_maxn = 10,
	_cmdhistory_pos = 0,
	
	-- Debug界面显示位置
	_loc_x = 0, 
	_loc_y = 0,
	
	-- Debug界面大小
	_size_w = lg.getWidth(),
	_size_h = lg.getHeight(),
	
	cursor_color = nil,
	_cursor_fc = 0,				--光标刷新
	_cursor_flash = 8,
	_cursor_show = false,
	_cursor_x = 0,				-- 光标位置
	_cursor_y = 0,
	_pos = 0,
	
	-- 回调处理类
	keyboard = nil,
	mouse = nil,
	timer = nil,
	
	enable_custom_func = true,
	-- 自定义函数列表(绘制Debug自身的update和draw后执行)
	_custom_update_func_list = nil,
	_custom_draw_func_list = nil,
	
	-- 背景
	bg_color = nil,

	-- Debug画布
	cv = nil,
	
	-- 字体
	font_color = nil,
	font = nil,
	
	alpha = 255,
});

function Debug:initialize()
	self._text_width = {};
	self._text_out = {};
	self._print_out = {};
	self._cmdhistory = {};
	self.keyboard = Keyboard();
	self.mouse = Mouse();
	self.timer = Timer();
	
	self.cursor_color = {255,255,255};
	self.bg_color = {0,0,0,230};
	self.cv = lg.newCanvas(self._size_w, self._size_h);
	
	self.font_color = {255,255,255};
	self.font = lg.newFont(12);
	self.font:setLineHeight(0);
	
	self.keyboard.onChar = function (char)
		-- 检查ctrl按下状态，禁止输入特殊码
		if lk.isDown("lctrl") or lk.isDown("rctrl") then
			return;
		end
		-- TAB
		if sbyte(char)==9 then
			self:Keyin(" ");
			self:Keyin(" ");
			self:Keyin(" ");
			self:Keyin(" ");
		-- Backspace
		elseif sbyte(char)==8 then
			self:Backspace();
		-- Enter
		elseif sbyte(char)==13 then
			self:textIn(self._text_in);
			self:textInClear();
		-- Escape
		elseif sbyte(char)==27 then
			self._callout = false;
		else
			self:Keyin(char);
		end
		self:computeCursorLoc();
	end
	self.keyboard.onPressed = function (key) 
		if self.checkShortcutKey() then
			e = NothingToDo;
			self._callout = not self._callout;
			return;
		elseif self.checkScreenshotShortcutKey() then
			self.saveScreenshot();
		elseif key=="left" then
			self:MovePrev();
		elseif key=="right" then
			self:MoveNext();
		elseif key=="up" then
			self:upcmdhistory();
		elseif key=="down" then
			self:downcmdhistory();
		elseif key=="pageup" then
			self:pageupline();
			return;
		elseif key=="pagedown" then
			self:pagedownline();
			return;
		elseif key=="home" then
			self._pos=0;
		elseif key=="end" then
			local len = slen(self._text_in);
			self._pos=len;
		end
		self:computeCursorLoc();
	end
	self.keyboard.onReleased = function (key)
	
	end
	
	self.mouse.onPressed = function (x, y, button) 
		if button=="wd" then
			self:downline();
		elseif button=="wu" then
			self:upline();
		end
	end
	
	self.timer.onTimer = function()
		self._cursor_fc = self._cursor_fc+1;
		if self._cursor_fc >= self._cursor_flash*2 then
			self._cursor_fc = 0;
		end
		self._cursor_show = self._cursor_fc<self._cursor_flash;	
	
		self.mouse:move();
		self:updateCanvas();
	end
	self.timer:reset(1/25);
	self.timer:start();
	
	self._custom_update_func_list = {};
	self._custom_draw_func_list = {};
	
	self:computeCursorLoc();
end

-- 检查呼出调试命令行快捷键
function Debug.checkShortcutKey()
	local shortcutkeydown = true;
	for i, v in pairs(Debug._shortcut_key) do
		shortcutkeydown = shortcutkeydown and lk.isDown(v);
		if not shortcutkeydown then
			break;
		end
	end
	return shortcutkeydown;
end

-- 检查截图快捷键
function Debug.checkScreenshotShortcutKey()
	local shortcutkeydown = true;
	for i, v in pairs(Debug._screenshot_shortcut_key) do
		shortcutkeydown = shortcutkeydown and lk.isDown(v);
		if not shortcutkeydown then
			break;
		end
	end
	return shortcutkeydown;
end

-- 截图(保存为screenshot/debug_[date].png)
function Debug.saveScreenshot()
	local folder = "screenshot";
	local date = Date.getDate();
	local file = folder.."/debug_"..date:getTic()..".png";
	
	print("Screenshot : ["..file.."] saving...");
	
	local imagedata = lg.newScreenshot();
	lf.mkdir(folder);
	imagedata:encode(file);
end

function Debug:Keyin(char)
	local ps = ssub(self._text_in, 0, self._pos);
	local ns = ssub(self._text_in, self._pos+1, -1);
	local text = "";
	if ps then
		text = text..ps;
	end
	text = text..char;
	if ns then
		text = text..ns;
	end
	
	self._pos = self._pos + 1;
	self._text_in = text;
	
	-- 插入字符宽度
	table.insert(self._text_width, self._pos, self.font:getWidth(char));
end

function Debug:Backspace()
	if self._pos==0 then
		return;
	end

	local ps = ssub(self._text_in, 0, self._pos-1);
	local ns = ssub(self._text_in,self._pos+1, -1);
	local text = "";
	if ps then
		text = text..ps;
	end
	if ns then
		text = text..ns;
	end
	
	-- 删除宽度记录
	table.remove(self._text_width, self._pos);
	self._pos = self._pos - 1;
	self._text_in = text;
end

function Debug:MoveNext()
	if self._pos+1>slen(self._text_in) then
		return;
	end
	self._pos = self._pos+1;
end

function Debug:MovePrev()
	if self._pos==0 then
		return;
	end
	self._pos = self._pos-1;
end

function Debug:textOut(str)
	table.insert(self._text_out, str);
	if #self._text_out > self._text_out_maxn then
		table.remove(self._text_out, 1);
	end
	self:computePrintOut(#self._text_out);
end

function Debug:textIn(str)
	table.insert(self._cmdhistory, str);
	if #self._cmdhistory > self._cmdhistory_maxn then
		table.remove(self._cmdhistory, 1);
	end
	print(label..str)
	if not self:resolveCmd(str) then
		-- 如果没有特殊处理，直接以lua方式调用
		xpcall(function() loadstring(str)() end, 
			((self.simple_error and Debug.SimpleError) or Debug.HandlerError))
	end
	self._cmdhistory_pos = #self._cmdhistory+1;
end

function Debug:setTextIn(text)
	if text==nil then
		return;
	end
	
	self._text_in = text;
	self._pos = slen(self._text_in);
	self._text_width = {};
	
	local len = slen(text);
	for i=1, len do
		table.insert(self._text_width, self.font:getWidth(ssub(text,i,i)));
	end
end

function Debug:textInClear()
	self._text_in = "";
	self._pos = 0;
end

function Debug:upline()
	self._print_pos = self._print_pos - 1;
	if self._print_pos < 1 then
		self._print_pos = 1;
	end
end

function Debug:pageupline()
	self._print_pos = self._print_pos - self.page_step;
	if self._print_pos < 1 then
		self._print_pos = 1;
	end
end

function Debug:downline()
	self._print_pos = self._print_pos + 1;
	if self._print_pos > #self._print_out then
		self._print_pos = #self._print_out
	end
end

function Debug:pagedownline()
	self._print_pos = self._print_pos + self.page_step;
	if self._print_pos > #self._print_out then
		self._print_pos = #self._print_out;
	end
end

function Debug:upcmdhistory()
	if #self._cmdhistory==0 then
		return;
	end

	self._cmdhistory_pos = self._cmdhistory_pos - 1;
	if self._cmdhistory_pos < 1 then
		self._cmdhistory_pos = #self._cmdhistory;
	end
	self:setTextIn(self._cmdhistory[self._cmdhistory_pos]);
end

function Debug:downcmdhistory()
	if #self._cmdhistory==0 then
		return;
	end

	self._cmdhistory_pos = self._cmdhistory_pos + 1;
	if self._cmdhistory_pos > #self._cmdhistory then
		self._cmdhistory_pos = 1;
	end
	self:setTextIn(self._cmdhistory[self._cmdhistory_pos]);
end

function Debug:computePrintOut(start_index)
	if start_index==nil then
		self._print_out = {};
		self._print_pos = 1;
		start_index = 1;
	end

	local ti = #self._text_out;
	if start_index>ti then
		return;
	end
	
	-- 计数输出信息
	local res, out, text;
	for i=start_index, ti do
		text = self._text_out[i];
		repeat
			res, out, text = StringCutoff(text, self.font, self._size_w);
			table.insert(self._print_out, out);
			if #self._print_out > self._print_out_maxn then
				table.remove(self._print_out, 1);
			end
		until res;
	end
end

function Debug:computeCursorLoc()
	local fh=self.font:getHeight();
	local flh=self.font:getLineHeight();
	local cx=self.font:getWidth(label);
	local cy=0;
	for i=1, self._pos do
		if not self._text_width[i] then
			break;
		end
		if cx + self._text_width[i] >= self._size_w then
			cy = cy + fh;
			cx = 0;
		end
		cx = cx + self._text_width[i];
	end

	self._cursor_x = cx;
	self._cursor_y = cy;

	while (#self._print_out-self._print_pos)*(fh+flh)+fh+cy > self._size_h-fh-flh do
		self._print_pos=self._print_pos+1;
	end
end

function Debug:resolveCmd(str)
	if str=="?" then
		gdc_Help();
		return true;
	elseif str=="about" then
		gdc_About();
		return true;
	elseif str=="cls" then
		gdc_Clear();
		return true;
	elseif str=="exit" then
		gdc_Exit();
		return true;
	elseif str=="quit" then
		gdc_Quit();
		return true;
	elseif str=="rr" then
		gdc_Recover();
		return true;
	elseif str=="bl" then
		gdc_BPList();
		return true;
	elseif str=="bc" then
		gdc_BPClear();
		return true;
	else
		local cmd = ssub(str, 1, 3);
		local param = ssub(str, 4);
		local lua_cmd = "";

		if cmd=="pt " then
			lua_cmd = "gdc_PrintTable("..param..")";
		elseif cmd=="bp " or cmd=="tg " then
			local _,_,param1,param2 = sfind(param, "([^ ]+) ([^ ]+)");
			if param1==nil then
				param1 = param;
				param2 = "true";
			end
			if param2~="true" and param2~="false" then
				return false;
			end
			lua_cmd = "gdc_Trigger(\""..param1.."\","..param2..")";
		elseif cmd=="lb " then
			local _,_,param1,param2,param3 = 
				sfind(param, "([^ ]+) ([^ ]+) (.+)");
			if param1==nil then
				_,_,param1,param2 = sfind(param, "([^ ]+) ([^ ]+)");
				if param1==nil then
					return false;
				end
				param3 = "true";
			end
			if param3~="true" and param2~="false" then
				return false;
			end
			lua_cmd = "gdc_LineBreak(\""..param1.."\","..param2..","..param3..")";
		elseif cmd=="cb " then
			local _,_,param1,param2 = sfind(param, "([^ ]+) ([^ ]+)");
			if param1==nil then
				param1 = param;
				param2 = "true";
			end
			if param2~="true" and param2~="false" then
				return false;
			end
			lua_cmd = "gdc_CallBreak(\""..param1.."\","..param2..")";
		elseif cmd=="rb " then
			local _,_,param1,param2 = sfind(param, "([^ ]+) ([^ ]+)");
			if param1==nil then
				param1 = param;
				param2 = "true";
			end
			if param2~="true" and param2~="false" then
				return false;
			end
			lua_cmd = "gdc_ReturnBreak(\""..param1.."\","..param2..")";
		elseif cmd=="tl " then
			if param~="true" and param~="false" then
				return false;
			end
			lua_cmd = "gdc_TraceLine("..param..")";
		elseif cmd=="tc " then
			if param~="true" and param~="false" then
				return false;
			end
			lua_cmd = "gdc_TraceCall("..param..")";
		elseif cmd=="tr " then
			if param~="true" and param~="false" then
				return false;
			end
			lua_cmd = "gdc_TraceReturn("..param..")";
		elseif cmd=="db " then
			if param == nil then
				return;
			end
			lua_cmd = "gdc_DelBP(\""..param.."\")";
		elseif cmd=="se " then
			if param~="true" and param~="false" then
				return false;
			end
			lua_cmd = "gdc_SimpleError("..param..")";
		elseif cmd=="ce " then
			if param~="true" and param~="false" then
				return false;
			end
			lua_cmd = "gdc_EnableCustomFunc("..param..")";
		else
			return false;
		end
		
		-- 如果没有特殊处理，直接以lua方式调用
		xpcall(function() loadstring(lua_cmd)() end, 
			((self.simple_error and Debug.SimpleError) or Debug.HandlerError));
		return true;
	end
	return false;
end

function Debug:drawBackground()
	lg.setColor(self.bg_color);
	lg.rectangle("fill", 0, 0,self._size_w, self._size_h);
end

function Debug:drawText()
	lg.setColor(self.font_color);
	lg.setFont(self.font);
	
	local ch = self.font:getHeight();
	local fh = ch+self.font:getLineHeight();
	local height_off = 0;

	local pol = #self._print_out;
	if pol~=0 then
		for i=self._print_pos, pol do
			lg.print(self._print_out[i], 0, height_off);
			height_off = height_off + fh;
			
			if height_off > self._size_h then
				return;
			end
		end
	end
	
	-- 绘制光标
	if self._cursor_show then
		lg.setColor(self.cursor_color);
		lg.rectangle("fill", self._cursor_x, 
			self._cursor_y+height_off, 1, ch);
	end
	
	-- 绘制输入信息
	lg.setColor(self.font_color);
	text = label..self._text_in;
	repeat
		res, out, text = StringCutoff(text, self.font, self._size_w);
		lg.print(out, 0, height_off);
		height_off = height_off + fh;
	until res;
end

function Debug:updateCanvas()
	self.cv:clear();
	self.cv:renderTo(function ()
		-- 设置裁剪区
		lg.setScissor(0, 0, self._size_w, self._size_h);
		lg.setBlendMode("alpha")
		
		self:drawBackground();
		self:drawText();
		
		-- 取消裁剪区
		lg.setScissor();
	end);
end

function Debug:update(dt)
	if not self._callout then
		return;
	end
	
	self.timer:tic(dt);
end

function Debug:draw()
	if not self._callout then
		return;
	end
	
	lg.setColor({255,255,255,self.alpha});
	lg.draw(self.cv, self._loc_x, self._loc_y);
end

function Debug:custom_update(dt)
	if not self.enable_custom_func then
		return;
	end
	for _, v in pairs(self._custom_update_func_list) do
		v(dt);
	end
end

function Debug:custom_draw()
	if not self.enable_custom_func then
		return;
	end
	for _, v in pairs(self._custom_draw_func_list) do
		v();
	end
end

function Debug:setCustomUpdate(idx_or_name, func)
	local t = type(func);
	assert(t=="nil" or t=="function", "Please give me a functino or a nil");
	self._custom_update_func_list[idx_or_name] = func;
end

function Debug:setCustomDraw(idx_or_name, func)
	local t = type(func);
	assert(t=="nil" or t=="function", "Please give me a functino or a nil");
	self._custom_draw_func_list[idx_or_name] = func;
end

local _debug = Debug();

function Debug.SimpleError(err)
	print("Invalid instruction");
end

local function traceback (lv)
	local level = lv+1
	while true do
	   local info = debug.getinfo(level)
	   if not info then break end
	   if info.what == "C" then    -- is a C function?
		   print(level, "    C function")
	   else   -- a Lua function
		   print(string.format("    [%s] : %d %s",
				  info.short_src,info.currentline, 
				  (info.name and "in function '"..info.name.."'") or "" ))
	   end
	   level = level + 1
	end
end

function Debug.HandlerError(err)
	_debug._callout = true;
	print("================================================");
	print(err);
	print("stack traceback:");
	
	local lv = 3;
	if isbreakpoint then lv=lv+2 end;
	traceback (lv);
	gdc_Context(lv);
	isbreakpoint = false;
	_debug:computeCursorLoc();
end

function Debug.FatalError(err)
	local old_state = _debug._callout;

	-- 内部方法（打开命令行）
	love._openConsole();
	_debug._callout = false;		--关闭调试工具
	-- 恢复到原来的print
	print = lua_print;
	print([[
================================================
!! Debug Console Internal Error !!
!! Program will enter lua debug console !!
================================================
]]..err..[[
stack traceback:
]]);
	traceback (2);
	gdc_Context(2);
	-- 进入lua debug
	debug.debug();
	-- 恢复原来的状态
	_debug._callout = old_state;
	-- 恢复到调试工具的print
	print = _gdc_print;
end

function getDebuger()
	return _debug;
end

local function traversal_r(tbl,num)
	num = num or 64
	local ret={}
	local function insert(v)
		table.insert(ret,v)
		if #ret>num then
			error()
		end
	end
	local function traversal(e)
		if e==nil_value or e==nil then
			insert("nil,")
		elseif type(e)=="table" then
			insert("{")
			local maxn=0
			for i,v in ipairs(e) do 
				traversal(v)
				maxn=i
			end
			for k,v in pairs(e) do
				if not (type(k)=="number" and k>0 and k<=maxn) then
					if type(k)=="number" then
						insert("["..k.."]=")
					else
						insert(tostring(k).."=")
					end
					traversal(v)
				end
			end
			insert("}")
		elseif type(e)=="string" then
			insert('"'..e..'",')
		else
			insert(tostring(e))
			insert(",")
		end
	end
 
	local err=xpcall(
		function() traversal(tbl) end,
		function() end
	)
	if not err then
		table.insert(ret,"...")
	end
 
	return table.concat(ret)
end
 
local function init_local(tbl,level)
	local n=1
	local index={}
	while true do
		local name,value=debug.getlocal(level,n)
		if not name then
			break
		end
 
		if name~="(*temporary)" then
			if value==nil then
				value=nil_value
			end
			
			tbl[name]=value
			index["."..name]=n
		end
 
		n=n+1
	end
	setmetatable(tbl,{__index=index})
	return tbl
end
 
local function init_upvalue(tbl,func)
	local n=1
	local index={}
	while true do
		local name,value=debug.getupvalue(func,n)
		if not name then
			break
		end
 
		if value==nil then
			value=nil_value
		end
		
		tbl[name]=value
		index["."..name]=n
 
		n=n+1
	end
	setmetatable(tbl,{__index=index})
	return tbl
end

-------------------------------------------------------
-- 帮助
function gdc_Help()
	print([[
cls      gdc_Clear()            --clear console  
?        gdc_Help()              --help
about    gdc_About()            -- about girl's debug console
exit     gdc_Exit()             -- exit debug console
pt       gdc_PrintTable(t)
bp       gdc_Break(name)        -- set break Point
tg       gdc_Trigger(name, on)     -- change break point trigger
lb       gdc_LineBreak(file, line, on)  -- Dynamic Break Point Line (Trace Line Must be Enable)
cb       gdc_CallBreak(funcname, on)    -- Dynamic Break Point Call (Trace Call Must be Enable)
rb       gdc_ReturnBreak(funcname, on)  -- Dynamic Break Point Return (Trace Return Must be Enable)
tl       gdc_TraceLine(active)    -- Trace Line
tc       gdc_TraceCall(active)    -- Trace Call func
tr       gdc_TraceReturn(active)    -- Trace Return func
bl       gdc_BPList()           -- print break point list
db       gdc_DelBP(name)         --  Delete Break Point
bc       gdc_BPClear()            -- Delete All Break Point
rr       gdc_Recover()            -- recover
se       gdc_SimpleError(active)      -- Simple Error 
ce       gdc_EnableCustomFunc(active)       -- Enable Custom Func
quit     gdc_Quit()               -- quit to ]]..love._os);
end

function gdc_About()
	print("Welcome to Girl's Debug Console ! Version "..DebugConsoleVersion.."\n"..
"    love version : "..love._version.."\n"..
"    operation system : ".. ((love._os~=nil and love._os) or "unknown").."\n"..
"    WorkingDirectory : "..lf.getWorkingDirectory().."\n"..
"    UserDirectory : "..lf.getUserDirectory().."\n"..
"    SaveDirectory : "..lf.getSaveDirectory().."\n"..
"    AppdataDirectory : "..lf.getAppdataDirectory())
end

-- 清理console
function gdc_Clear()
	_debug._text_out = {};
	_debug:computePrintOut();
end

function gdc_Exit()
	_debug._callout = false;
end

function gdc_Debuginfo(n)
	local info = debug.getinfo(n);
	for i,v in pairs(info) do
		print(i, v);
	end
end

function gdc_PrintTable(root)
	local cache = {[root] = "." }
	local function _dump(t, space, name)
		local temp = {}
		for k,v in pairs(t) do
			local key = tostring(k)
			if cache[v] then
				table.insert(temp,"+" .. key .. " {" .. cache[v].."}")
			elseif type(v) == "table" then
				local new_key = name .. "." .. key
				cache[v] = new_key
				table.insert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. srep(" ",#key),new_key))
			else
				table.insert(temp,"+" .. key .. " [" .. tostring(v).."]")
			end
		end
		return table.concat(temp,"\n"..space)
	end
	
	print(_dump(root, "",""))
end

function gdc_Context(level)
	level=level and level+2 or 2
 
	local lv=init_local({},level+1)
	local func=debug.getinfo(level,"f").func
	local uv=init_upvalue({},func)
	local _L={}
	setmetatable(_L,{
		__index=function(_,k) 
			local ret=lv[k]
			return ret~=nil_value and ret or nil
		end,
		__newindex=function(_,k,v)
			if lv[k] then
				lv[k]= v~= nil and nil_value or v
				debug.setlocal(level+3,lv["."..k],v)
			else
				print("error:invalid local name:",k)
			end
		end,
		__tostring=function(_)
			return traversal_r(lv)
		end
	})
	print("_L=", traversal_r(lv))
	local _U={}
	setmetatable(_U,{
		__index=function(_,k) 
			local ret=uv[k]
			return ret~=nil_value and ret or nil
		end,
		__newindex=function(_,k,v)
			if uv[k] then
				uv[k]= v~= nil and nil_value or v
				debug.setupvalue(func,uv["."..k],v)
			else
				print("error:invalid upvalue name",k)
			end
		end,
		__tostring=function(_)
			return traversal_r(uv)
		end
	})
	print("_U=", traversal_r(uv))
 
	local _G=getfenv(level)
	_G._L,_G._U=_L,_U
end

-- 断点(在程序中调用)
function gdc_Break(name)
	BPL:bp(name);
end

-- 开关断点
function gdc_Trigger(name, on)
	BPL:trigger(name, on);
end

-- 删除断点
function gdc_DelBP(name)
	BPL:del(name);
end

-- 动态断点激活
-- 行跟踪
function gdc_TraceLine(active)
	if active then
		debug.sethook(BPL.traceLine, "l");
	else
		debug.sethook(nil,"l");
	end
end

function gdc_LineBreak(file, line, on)
	if file==nil or type(line)~="number" then
		print("LineBreak is error");
		return;
	end
	local name="line:@"..file.."("..line..")"
	BPL:trigger(name, on);
end

-- 函数调用跟踪
function gdc_TraceCall(active)
	if active then
		debug.sethook(BPL.traceCall, "c");
	else
		debug.sethook(nil,"c");
	end
end

function gdc_CallBreak(ca, on)
	if ca==nil then
		print("CallBreak is error");
		return;
	end
	local name="call:@"..ca;
	BPL:trigger(name, on);
end

-- 函数返回跟踪
function gdc_TraceReturn(active)
	if active then
		debug.sethook(BPL.traceReturn, "r");
	else
		debug.sethook(nil, "r");
	end
end

function gdc_ReturnBreak(ca, on)
	if ca==nil then
		print("ReturnBreak is error");
		return;
	end
	local name="return:@"..ca;
	BPL:trigger(name, on);
end

-- 打印断点列表
function gdc_BPList()
	BPL:printBPInfo();
end

-- 清空断点列表
function gdc_BPClear()
	BPL:clear();
end

-- 从断点或者错误恢复
function gdc_Recover()
	love._draw_stop = false;
	love._update_stop = false;
	_G._L,_G._U=nil,nil
end

function gdc_SimpleError(active)
	_debug.simple_error = active;
end

function gdc_EnableCustomFunc(active)
	_debug.enable_custom_func = active;
end

-- 退出程序
function gdc_Quit()
	love.event.push("quit");
end

_gdc_print = function (...)
	lua_print(...);
	local str = "";
	local args = {...};
	local argl = #args;
	for i=1, argl do
		str = str .. tostring(args[i])
		if i < #args then
			str = str .. "    "
		end
	end
	_debug:textOut(str);
end;

_G["print"] = _gdc_print;

gdc_About();

-- 无关事件
local NothingToDo = "NothingToDo";
-- 添加love事件函数（用于事件循环跳过已经处理过的函数）
_G["love"].handlers[NothingToDo] = function() end;

-- 循环事件停止标记
_G["love"]._draw_stop = false;
_G["love"]._update_stop = false;

_G["love"].run = function()
    math.randomseed(os.time())
    math.random() math.random()
	lk.setKeyRepeat(.2,.05);
	
    if love.load then 
		xpcall(function () love.load(arg) end, 
			function (err)
				love._update_stop = true;
				love._draw_stop = true;
				Debug.HandlerError(err);
			end);
	end

    local dt = 0

    -- Main loop time.
    while true do
        -- Process events.
        if love.event then
            love.event.pump()
            for e,a,b,c,d in love.event.poll() do
                if e == "quit" then
                    if not love.quit or not love.quit() then
                        if love.audio then
                            love.audio.stop()
                        end
                        return
                    end
                elseif e == "keypressed" then
					if _debug._callout then
						e = NothingToDo;
						xpcall(function() _debug.keyboard:pressed(a, b); end,
							Debug.FatalError);
					else
						-- 检查快捷键
						if _debug.checkShortcutKey() then
							e = NothingToDo;
							_debug._callout = not _debug._callout;
						elseif _debug.checkScreenshotShortcutKey() then
							_debug.saveScreenshot();
						end
					end
				elseif e == "keyreleased" then
					if _debug._callout then
						e = NothingToDo;
						xpcall(function() _debug.keyboard:released(a); end,
							Debug.FatalError);
					end
				elseif e == "mousepressed" then
					if _debug._callout then
						e = NothingToDo;
						xpcall(function() _debug.mouse:pressed(a,b,c); end,
							Debug.FatalError);
					end
				elseif e == "mousereleased" then
					if _debug._callout then
						e = NothingToDo;
						xpcall(function() _debug.mouse:released(a,b,c); end,
							Debug.FatalError);
					end
				end
				xpcall(function () love.handlers[e](a,b,c,d) end, Debug.HandlerError)
            end
        end

        -- Update dt, as we'll be passing it to update
        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        -- Call update and draw
        if love.update and not love._update_stop then 
			xpcall(function () love.update(dt) end, 
				function (err)
					love._update_stop = true;
					Debug.HandlerError(err);
				end) -- will pass 0 if love.timer is disabled
		end
        if love.graphics then
            love.graphics.clear()
            if love.draw and not love._draw_stop  then
				xpcall(function () love.draw() end, 
				function (err)
					love._draw_stop = true;
					Debug.HandlerError(err);
				end)
			end
        end
		
		-- 更新绘制debug界面
		xpcall(function () 
			_debug:update(dt);
			_debug:draw(); 
			_debug:custom_update(dt);
			_debug:custom_draw();
		end, Debug.FatalError);
		
        if love.timer then love.timer.sleep(0.001) end
        if love.graphics then love.graphics.present() end

    end

end
