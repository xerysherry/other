----------------------------------------------------------------
-- write by xerysherry
--{
--	-- Gui列表
--	gui = {
--		-- Gui
--		{
--			-- Gui参数
--			name="", pos={}, size={},
--			-- View列表
--			view={
--				{
--					-- View参数
--					name="", type="", pos={}, size={},
--					-- View列表
--					view={
--						...
--					}
--				},
--				...
--			}
--		},
--	},
--	...
--}

local sfind = string.find;
local sbyte = string.byte;
local schar = string.char;
local lg = love.graphics;

-- 得到基类
local Object = getClass("Object");
local Gui = getClass("Object.Gui");
local GuiManager = getClass("Object.GuiManager");

-- 控件基类
local View = getClass("Object.View");

-- Gui设计器
local GuiDesigner = class("GuiDesigner", Object, 
{});

function GuiDesigner:initialize()
	error("GuiManager can't be instantiated");
end

-- 表内容数值化
local function TableQuantize(t)
	for i, v in pairs(t) do
		local tp = type(v);
		if tp=="string" then
			local _, _, pstr = sfind(v, "([0-9]+)%%");
			if pstr~=nil then
				t[i]=tonumber(pstr)/100.0;
			else
				t[i]=tonumber(v);
				if t[i]==nil then
					t[i]=0;
				end
			end
		elseif tp=="number" then
			t[i]=v;
		else
			t[i]=0;
		end
	end
end

-- 表内容字符串化
local function TableStringified(t)
	for i, v in pairs(t) do
		local tp = type(v);
		if tp=="string" then
			t[i]=v;
		else
			t[i]=tostring(v);
		end
	end
end

local function GetNumericalStandardization(t)
	local w, h = lg.getWidth(), lg.getHeight();
	if type(t[1])=="string" then
		local _, _, pstr = sfind(t[1], "([0-9]+)%%");
		if pstr~=nil then
			t[1]=tonumber(pstr)/100.0*w;
		else
			t[1]=tonumber(t[1]);
			if t[1]==nil then
				t[1]=0;
			end
		end
	end
	if type(t[2])=="string" then
		local _, _, pstr = sfind(t[2], "([0-9]+)%%");
		if pstr~=nil then
			t[2]=tonumber(pstr)/100.0*h;
		else
			t[2]=tonumber(t[2]);
			if t[2]==nil then
				t[2]=0;
			end
		end
	end
	return t[1], t[2];
end

local function GetPosAndSize(dsp_gui)
	-- 获取size
	local temptable = dsp_gui["size"];
	if temptable==nil then
		temptable={lgw, lgh};
	end
	local gw, gh = GetNumericalStandardization(temptable);

	-- 获取pos
	local temptable = dsp_gui["pos"];
	if temptable==nil then
		temptable={0, 0};
	end
	local x, y = GetNumericalStandardization(temptable);
	return x, y, gw, gh;
end

-- 特殊参数设置
local function GuiSpecialParameter(gui, dsp_gui)
	-- 暂无
end

-- 普通参数
local function GuiNormalParameter(gui, dsp_gui)
	local function on_event(x, v)
		local _, _, pstr = sfind(x, "(on[A-Za-z0-9]+)");
		if pstr==nil then
			return false;
		end
		local t=type(v);
		if t=="function" then
			gui[x]=v;
		elseif t=="string" then
			local _, _, m, f = sfind(x, "(.+):([^:]+)");
			if m~=nil then
				require(m);
			end
			gui[x]=_G[v];
		end
		return true;
	end
	local spt = {"name", "pos", "size"};
	local function isSp(str) 
		for _, v in ipairs(spt) do
			if str==v then
				return true;
			end
		end
		return false;
	end
	local function xxx_is_v(x, v)
		if isSp(x) then
			return;
		end
		if gui[x]~=nil then
			if not on_event(x, v) then
				gui[x]=v;
			end
		end
	end
	local function setXXX(x, v)
		local setf="set"..x;
		if gui[setf]~=nil then
			gui[setf](gui, unpack(v));
		end
	end

	if dsp_gui==nil then
		return;
	end
	for i, v in pairs(dsp_gui) do
		if type(i)=="string" then
			local c = sbyte(i,1);
			if c>=sbyte("A") and c<=sbyte("Z") then
				setXXX(i, v);
			else
				xxx_is_v(i, v);
			end
		end
	end
end

-- 产生GUI
function GuiDesigner.produceGui(graph, dsp_gui)
	assert(graph~=nil, "graph can't be nil");
	assert(type(dsp_gui)=="table", "dsp_gui must be a table");
	
	local lgw, lgh = lg.getWidth(), lg.getHeight();
	local gx, gy, gw, gh = GetPosAndSize(dsp_gui);
	local name = dsp_gui["name"];
	
	graph:deleteCanvas(name);
	graph:createCanvas(name, gw, gh);
	
	local gui = Gui(gx, gy, gw, gh, graph, name);
	-- 设置参数
	GuiSpecialParameter(gui, dsp_gui);
	GuiNormalParameter(gui, dsp_gui);
	
	local view_table = dsp_gui["view"] or {};
	for _, v in ipairs(view_table) do
		GuiDesigner.produceView(v, gui);
	end
	return gui;
end

local function GetViewNumericalStandardization(t, parent_width, parent_height)
	local w, h = parent_width, parent_height;
	if type(t[1])=="string" then
		local _, _, pstr = sfind(t[1], "([0-9]+)%%");
		if pstr~=nil then
			t[1]=tonumber(pstr)/100.0*w;
		else
			t[1]=tonumber(t[1]);
			if t[1]==nil then
				t[1]=0;
			end
		end
	end
	if type(t[2])=="string" then
		local _, _, pstr = sfind(t[2], "([0-9]+)%%");
		if pstr~=nil then
			t[2]=tonumber(pstr)/100.0*h;
		else
			t[2]=tonumber(t[2]);
			if t[2]==nil then
				t[2]=0;
			end
		end
	end
	return t[1], t[2];
end

local function GetViewPosAndSize(dsp_view, parent_width, parent_height)
	-- 获取size
	local temptable = dsp_view["size"];
	if temptable==nil then
		temptable={parent_width, parent_height};
	end
	local vw, vh = GetViewNumericalStandardization(temptable, parent_width, parent_height);

	-- 获取pos
	local temptable = dsp_view["pos"];
	if temptable==nil then
		temptable={0, 0};
	end
	local x, y = GetViewNumericalStandardization(temptable, parent_width, parent_height);
	return x, y, vw, vh;
end

-- 特殊参数设置
local function ViewSpecialParameter(view, dsp_view)
	-- 设置disable属性
	local disable_table = dsp_view["set_disable"];
	if disable_table~=nil then
		for i, v in ipairs(disable_table) do
			local ef = "enable"..v;
			if view[ef]~=nil then
				view[ef](view, false);
			end
		end
	end
	-- 设置enable属性
	local enable_table = dsp_view["set_enable"];
	if enable_table~=nil then
		for i, v in ipairs(enable_table) do
			local ef = "enable"..v;
			if view[ef]~=nil then
				view[ef](view, true);
			end
		end
	end
end

-- 普通参数
local function ViewNormalParameter(view, dsp_view)
	local function on_event(x, v)
		local _, _, pstr = sfind(x, "(on[A-Za-z0-9]+)");
		if pstr==nil then
			return false;
		end
		local t = type(v);
		if t=="function" then
			view[x]=v;
		elseif t=="string" then
			local _, _, m, f = sfind(x, "(.+):([^:]+)");
			if m~=nil then
				require(m);
			end
			gui[x]=_G[v];
		end
		return true;
	end
	local spt = {"type", "name", "pos", "size", "set_enable", "set_disable"};
	local function isSp(str) 
		for _, v in ipairs(spt) do
			if str==v then
				return true;
			end
		end
		return false;
	end
	local function xxx_is_v(x, v)
		if isSp(x) then
			return;
		end
		if view[x]~=nil then
			if not on_event(x, v) then
				view[x]=v;
			end
		end
	end
	local function setXXX(x, v)
		local setf="set"..x;
		if view[setf]~=nil then
			view[setf](view, unpack(v));
		end
	end

	if dsp_view==nil then
		return;
	end
	for i, v in pairs(dsp_view) do
		if type(i)=="string" then
			local c = sbyte(i,1);
			if c>=sbyte("A") and c<=sbyte("Z") then
				setXXX(i, v);
			else
				xxx_is_v(i, v);
			end
		end
	end
end

-- 产生View
function GuiDesigner.produceView(dsp_view, parent)
	assert(type(dsp_view)=="table", "dsp_view must be a table");
	assert(parent~=nil, "parent can't be a nil");
	
	local name = dsp_view["name"];
	local parent_width, parent_height = parent:getSize();
	local vx, vy, vw, vh = GetViewPosAndSize(dsp_view, parent_width, parent_height);
	local son_view = dsp_view["type"];
	assert(son_view~=nil, "dsp_view's type can't be nil");
	
	local sv = getClass("Object.View"):getClass(son_view);
	assert(sv~=nil, "The view of \""..son_view.."\" is not exist.");
	-- 创建View
	local view = sv(vw, vh);
	parent:add(name, view, vx, vy);
	
	-- 设置参数
	ViewSpecialParameter(view, dsp_view);
	ViewNormalParameter(view, dsp_view);
	
	local view_table = dsp_view["view"] or {};
	for _, v in ipairs(view_table) do
		GuiDesigner.produceView(v, view);
	end
end

-- 小写字母开头，view.XXX = param
local function GuiManagerParameter(gm, dsp)
	local spt = {"gui"};
	local function isSp(str) 
		for _, v in ipairs(spt) do
			if str==v then
				return true;
			end
		end
		return false;
	end
	for i, v in pairs(dsp) do
		if not isSp(i) then
			if gm[i]~=nil then
				gm[i] = v;
			end
		end
	end
end

-- 产生GuiManager
function GuiDesigner.produceGuiManager(graph, dsp)
	assert(graph~=nil, "graph can't be nil");
	assert(type(dsp)=="table", "dsp_gui must be a table");
	local gm = GuiManager();
	local guis = dsp["gui"];
	
	GuiManagerParameter(gm, dsp);
	for _, v in ipairs(guis) do
		gm:add(v["name"], GuiDesigner.produceGui(graph, v));
	end
	return gm;
end

return GuiDesigner;
