
----------------------------------------------------------------
-- write by xerysherry

-- 得到基类
local Object = getClass("Object");

local Point = getClass("Object.Point");
local Size = getClass("Object.Size");
local Rect = getClass("Object.Rect");
local Graphics = getClass("Object.Graphics");

local Mouse = getClass("Object.Mouse");
local Keyboard = getClass("Object.Keyboard");
local Joystick = getClass("Object.Joystick");

-- 视图（view）类
local View = class("View", Object,
{
	-- 坐标位置
	rect = nil,
	-- 是否点击之后事件继续传给父view（穿透）
	parent_mouse_event = false,
	-- 显示参数
	show = true,
	-- 激活参数
	enable = true,
	mouse_enable = true,
	keyboard_enable = true,
	joystick_enable = false,
	-- 抓住
	isgrab = false,
	-- 父view
	parent = nil,
	-- 依附的Gui
	gui = nil,
	-- 子view列表
	viewlist = nil,
	
	-- 回调对象
	mouse = nil,
	keyboard = nil,
	joystick = nil,
	timer = nil,
	
	-------------------------------------------------
	-- 回调
	-- 绘制事件
	onDraw = function (this, ox, oy) end,
	-- 更新事件
	onUpdate = function (this) end,
	-- 得失焦点事件
	onSetFocus = function (this, next_view) end,
	onKillFocus = function (this, prev_view) end,
	-- 改变大小事件
	onSize = function (this, w, h) end,
	-- 鼠标事件（相对坐标，ViewMouseEnum）
	onMousePressed = function (this, x, y, button) end,
	onMouseReleased = function (this, x, y, button) end,
	onMouseMove = function (this, x, y) end,
	onLeave = function (this) end,
	onReach = function (this) end,
	-- 键盘事件
	onKeyPressed = function (this, key) end,
	onKeyReleased = function (this, key) end,
	onChar = function (this, char) end,
	-- 手柄事件
	onJoyStickPressed = function (this, joystick, button) end,
	onJoyStickReleased = function (this, joystick, button) end,
});

function View:initialize(w, h)
	self.rect = Rect:new(0, 0, w, h);
	self.viewlist = {};
	
	self.mouse = Mouse:new();
	self.keyboard = Keyboard:new();
	
	-- 鼠标事件
	self.mouse.onMove = function (x, y)
		local rx, ry = x-self.rect.x, y-self.rect.y;
		local mv = nil;
		for i,v in pairs(self.viewlist) do
			-- 检测是否在内部
			if mv==nil and IsPointIn(rx, ry, v.rect) then
				mv = v;
			else
				v:mouseleave();
			end
		end
		
		if mv then
			mv:mousemove(rx, ry);
		end
		self:onMouseMove(x-self.rect.x, y-self.rect.y);
	end
	
	self.mouse.onPressed = function (x, y, button)
		local rx, ry = x-self.rect.x, y-self.rect.y;
		for i,v in pairs(self.viewlist) do
			-- 检测是否在内部
			if IsPointIn(rx, ry, v.rect) then
				if v:mousepressed(rx, ry, button) then
					break;
				else
					return;
				end
			end
		end
		if self.gui then
			self.gui:setFocus(self);
		end
		self:onMousePressed(x-self.rect.x, y-self.rect.y, button);
		
		-- 检查抓住标记
		if self.isgrab then
			-- 如果设置抓住标记，那么就是会记录当前view，和当前坐标
			self.gui:grab(self, x, y);
		end
	end
	
	self.mouse.onReleased = function (x, y, button) 
		local rx, ry = x-self.rect.x, y-self.rect.y;
		for i,v in pairs(self.viewlist) do
			-- 检测是否在内部
			if IsPointIn(rx, ry, v.rect) then
				if v:mousereleased(rx, ry, button) then
					break;
				else
					return;
				end
			end
		end
		self:onMouseReleased(x-self.rect.x, y-self.rect.y, button);
	end
	
	self.mouse.onLeave = function ()
		self:onLeave();
	end
	
	self.mouse.onReach = function ()	
		self:onReach();	
	end
	
	-- 键盘事件
	self.keyboard.onChar = function (char)
		self:onChar(char);
	end
	
	self.keyboard.onPressed = function (key)
		self:onKeyPressed(key);
	end
	
	self.keyboard.onReleased = function (key)
		self:onKeyReleased(key);
	end
	
	-- 手柄事件
	if Joystick~=nil then
		self.joystick = Joystick:new();
		self.joystick.onPressed = function (joystick, button) 
			self:onJoyStickPressed(joystick, button);
		end
		self.joystick.onReleased = function (joystick, button) 
			self:onJoyStickReleased(joystick, button);
		end
	end
end

-- 设置依附Gui
function View:_setGui(gui)
	for i, v in pairs(self.viewlist) do
		v:_setGui(gui);
	end
	self.gui = gui;
end

-- 检查是否获得焦点
function View:checkFocus()
	if self.gui==nil then
		return false;
	end
	
	return self.gui.focus==self;
end

-- 添加View(idx为nil时，将无法知道他的索引)
function View:add(idx, v, x, y)
	assert(v~=nil, "can not add nil!");
	if idx then
		assert(self.viewlist[idx]==nil, "This index is not nil!");
		self.viewlist[idx] = v;
	else
		table.insert(self.viewlist, v);
	end
	v.parent = self;
	v.rect.x, v.rect.y = x, y;
	v:_setGui(self.gui);
end

-- 通过层级关系(viewname1.viewname2)获得子View
function View:getView(name)
	local catch_str = "(.+)%.([^.]+)";
	local _, _,  pstr, sstr = string.find(name, catch_str);
	if sstr~=nil then
		local v = self:get(pstr);
		if v~=nil then
			return v:getView(sstr);
		end
		return nil;
	else
		return self:get(name);
	end	
end

-- 获得子View
function View:get(idx)
	return self.viewlist[idx];
end

-- 删除View
function View:del(idx)
	local v = self.viewlist[idx];
	if v==nil then
		return;
	end
	v:clear();
	self.viewlist[idx] = nil;
end

-- 获得同级对象
function View:brother(idx)
	if self.parent==nil then
		if self.gui~=nil then
			return self.gui:get(idx);
		end
	else
		return self.parent:get(idx);
	end
	return nil;
end

function View:getPoint()
	return self.rect:getPoint();
end

function View:getSize()
	return self.rect:getSize();
end

function View:getRect()
	return self.rect:getRect();
end

function View:setPoint(x, y)
	self.rect:setPoint(x, y);
end

function View:setSize(w, h)
	self.rect:setSize(w, h);
	self:onSize(w, h);
end

function View:showView(s)
	if s~=nil then
		self.show = s;
	else
		self.show = true;
	end
end

-- 获得位置，在窗口中真实的坐标
function View:getLocation()
	local locx, locy = 0, 0 ;
	if self.parent then
		locx, locy = self.parent:getLocation();
	else
		if self.gui then
			locx, locy = self.gui:getPoint();
		end
	end
	return locx+self.rect.x, locy+self.rect.y;
end

-- 抓住(只能在鼠标pressed中调用)
function View:grab()
	self.isgrab = true;
end

-- 抓住(只能在鼠标released中调用)
function View:ungrab()
	self.isgrab = false;
	self.gui:ungrab(self);
end

function View:clearView()
	for i, v in pairs(self.viewlist) do
		v:clear();
	end
	self.viewlist = {};
end

-- 清理关系记录
function View:clear()
	for i, v in pairs(self.viewlist) do
		v:clear();
	end
	
	self.viewlist = {};
	self.parent = nil;
	self.gui = nil;
end

-- 绘制函数（相对坐标）
function View:draw(sx, sy, sw, sh)
	if not self.show then
		return;
	end

	local ml, mt, mw, mh = self.rect:getRect();
	local nl, nt, nw, nh = MergeRect(sx, sy, sw, sh, 
		-- 偏移View Rect
		ml+sx, mt+sy, mw, mh);
	if nl==nil then
		return;
	end
	
	-- 设置裁剪区
	Graphics._setScissor(nl, nt, nw, nh);

	-- 转换
	Graphics._push();
	Graphics._translate(self.rect.x, self.rect.y);

	-- 绘制
	self:onDraw(x, y);
	-- 绘制子view
	for i,v in pairs(self.viewlist) do
		v:draw(nl, nt, nw, nh);-- 裁剪区
	end
	Graphics._pop();
end

-- 更新
function View:update()
	if not self.enable then
		return;
	end

	self:onUpdate();
	for i,v in pairs(self.viewlist) do
		v:update();
	end
end

-- 鼠标点击事件（相对坐标）
function View:mousepressed(x, y, button)
	if not self.show then
		return true;
	end
	if self.enable and self.mouse_enable then
		self.mouse:pressed(x, y, button);
	end
	return self.parent_mouse_event;
end

function View:mousereleased(x, y, button)
	if not self.show then
		return true;
	end
	if self.enable and self.mouse_enable then
		self.mouse:released(x, y, button);
	end
	return self.parent_mouse_event;
end

function View:mousemove(x, y)
	if not self.show then
		return true;
	end
	if self.enable and self.mouse_enable then
		self.mouse:move(x, y);
	end
	return self.parent_mouse_event;
end

function View:mouseleave()
	if not self.show or not self.enable or not self.mouse_enable then
		return;
	end
	for i,v in pairs(self.viewlist) do
		v:mouseleave();
	end
	self.mouse:leave();
end

-- 键盘事件（获得焦点为前提）
function View:keypressed(key, unicode)
	if not self.show then
		return;
	end
	if self.enable and self.keyboard_enable then
		self.keyboard:pressed(key, unicode);
	end
end

function View:keyreleased(key)
	if not self.show then
		return;
	end
	if self.enable and self.keyboard_enable then
		self.keyboard:released(key);
	end
end

-- 手柄事件（获得焦点为前提）
function View:joystickpressed(joystick, button)
	if joystick==nil then
		return;
	end
	if not self.show then
		return;
	end
	if self.enable and self.joystick_enable then
		self.joystick:pressed(joystick, button);
	end
end

function View:joystickreleased(joystick, button)
	if joystick==nil then
		return;
	end
	if not self.show then
		return;
	end
	if self.enable and self.joystick_enable then
		self.joystick:released(joystick, button);
	end
end

return View;
