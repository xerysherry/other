----------------------------------------------------------------
-- write by xerysherry

local lg = love.graphics;

-- 得到基类
local Object = getClass("Object");

local Point = getClass("Object.Point");
local Rect = getClass("Object.Rect");
local Graphics = getClass("Object.Graphics");

local Mouse = getClass("Object.Mouse");
local Keyboard = getClass("Object.Keyboard");
local Joystick = getClass("Object.Joystick");

local TimerList = getClass("Object.TimerList");

local UpdateTimer = "_updater"

-----------------------------------------------------------
-- View鼠标按钮枚举
local ViewMouseEnum = class("ViewMouseEnum", Object,
{
	LB = 0, MB = 1, RB = 2,			--左，中，右键-
	WHEEL_UP = 3, WHEEL_DOWN = 4,	--滚轮，上下-
	X1 = 5, X2 = 6,					--button 4, button 5
});

-- 鼠标事件转换表（字符串值转换为数值）
local LoveMouse2ViewMouse = 
{
	--左，中，右键
	['l'] = ViewMouseEnum.LB,
	['m'] = ViewMouseEnum.MB,
	['r'] = ViewMouseEnum.RB,
	
	--滚轮，上下
	['wu'] = ViewMouseEnum.WHEEL_UP,
	['wd'] = ViewMouseEnum.WHEEL_DOWN,
	
	--button 4, button 5
	['x1'] = ViewMouseEnum.X1,
	['x2'] = ViewMouseEnum.X1,
};

-- GUI动画效果类
local AE_ModeEnum = getClass("Object.GUIAnimaEffect").ModeEnum;
local AE_Enum =
{
	random = 0,
	-- 1. 淡入淡出
	fade = 1,
	-- 2. 缩放
	zoom = 2,
};
local AE_List = 
{
	-- 1. 淡入淡出
	[AE_Enum.fade] = getClass("Object.GUIAnimaEffect.Fade")(),
	[AE_Enum.zoom] = getClass("Object.GUIAnimaEffect.Zoom")(),
};

-----------------------------------------------------------
-- Gui管理类
local Gui = class("Gui", Object,
{
	-- 显示
	show = true,
	-- 激活
	enable = true,

	-- 坐标位置
	rect = nil,
	-- 焦点
	focus = nil,
	-- 前一个焦点
	prev_focus = nil,
	-- 绘图工具和画布索引
	graph = nil,
	cv = nil,
	-- 刷新率
	fps = 25,
	-- Alpha
	alpha = 255,
	-- 抓住的view
	grab_view = nil,
	-- 抓住的view的坐标偏移
	grab_x = 0,
	grab_y = 0,
	-- 拖动模式
	dragmode = false,
	dragmode_autorelease = false, 	-- 是否自动释放（最近一次鼠标抬起事件）
	
	-- 开关动画效果
	AnimaEffect = AE_Enum,
	AnimaList = AE_List,
	-- 使用动画效果
	anima_effect = 1,
	anima = false,
	
	-- 回调对象
	mouse = nil,
	keyboard = nil,
	joystick = nil,
	timerlist = nil,
	
	-- 惯性移动模式
	inertia_mode = false,
	inertia_acceleration = nil,
	
	-- 移动区域
	move_rect_limit = false,
	move_rect = nil,
	
	-- view列表
	viewlist = nil,
	
	-- 鼠标事件
	onLeave = function (this) end,
	onReach = function (this) end,
	onMousePressed = function (this, x, y, button) end,
	onMouseReleased = function (this, x, y, button) end,
	-- 大小改变事件
	onSize = function (this, w, h) end,
});

-- 坐标，大小，绘图工具，画布索引
function Gui:initialize(x, y, w, h, graph, cv)
	self.rect = Rect:new(x, y, w, h);
	self.viewlist = {};
	if graph then
		self.graph = graph;
	else
		self.graph = Graphics:new();
	end
	
	if cv then
		self.cv = cv;
	else
		self.cv = "default";
	end
	
	if self.graph:getCanvas(self.cv)==nil then
		self.graph:createCanvas(self.cv, w, h);
	end
	
	self.mouse = Mouse:new();
	self.keyboard = Keyboard:new();
	
	
	self.timerlist = TimerList:new();
	
	local timer = self:newTimer(UpdateTimer, 1/self.fps);
	timer:start();
	
	-- 鼠标事件
	self.mouse.onMove = function (x, y)
		local rx, ry = x-self.rect.x, y-self.rect.y;
		local mv = nil;
		for i,v in pairs(self.viewlist) do
			-- 检测是否在内部
			if mv==nil and v.show and IsPointIn(rx, ry, v.rect) then
				mv = v;
			else
				v:mouseleave();
			end
		end
		if mv then
			mv:mousemove(rx, ry);
		end
	end
	
	self.mouse.onPressed = function (x, y, button)
		-- 是否抓住
		if self.grab_view then
			return true;
		end
		
		local rx, ry = x-self.rect.x, y-self.rect.y;
		for i,v in pairs(self.viewlist) do
			if v.show and IsPointIn(rx, ry, v.rect) then
				v:mousepressed(rx, ry, button);
				break;
			end
		end
		self:onMousePressed(rx, ry, button);
	end
	
	self.mouse.onReleased = function (x, y, button) 
		local rx, ry = x-self.rect.x, y-self.rect.y;
		for i,v in pairs(self.viewlist) do
			if v.show and IsPointIn(rx, ry, v.rect) then
				v:mousereleased(rx, ry, button);
				break;
			end
		end
		self:onMouseReleased(rx, ry, button);
	end
	
	self.mouse.onLeave = function ()
		for i,v in pairs(self.viewlist) do
			v:mouseleave();
		end
		self:onLeave();
	end
	
	self.mouse.onReach = function ()
		self:onReach();
	end
	
	-- 键盘事件
	self.keyboard.onChar = function (char) end;
	self.keyboard.onPressed = function (key) end;
	self.keyboard.onReleased = function (key) end;
	
	-- 手柄事件
	if joystick~=nil then
		self.joystick = Joystick:new();
		self.joystick.onPressed = function (joystick, button) end;
		self.joystick.onReleased = function (joystick, button) end;
	end
	
	-- 定时器
	timer.onTimer = function ()
		for i,v in pairs(self.viewlist) do
			v:update();
			break;
		end
		self.updateCanvas(self);
	end
	
	self.inertia_mode = false;
	self.inertia_acceleration = Point(0,0);
	
	self.move_rect_limit = false;
	self.move_rect = Rect(0, 0, lg.getWidth()-w, lg.getHeight()-h);
end

-- 添加View(idx为nil时，将无法知道他的索引)
function Gui:add(idx, v, x, y)
	assert(v~=nil, "can not add nil!");
	if idx then
		assert(self.viewlist[idx]==nil, "This index is not nil!");
		self.viewlist[idx] = v;
	else
		table.insert(self.viewlist, v);
	end
	-- 根view，无父
	v.parent = nil;
	v.rect.x, v.rect.y = x, y;
	v:_setGui(self);
end

-- 获得子View
function Gui:get(idx)
	return self.viewlist[idx];
end

-- 通过层级关系(viewname1.viewname2)获得子View
function Gui:getView(name)
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

-- 删除View
function Gui:del(idx)
	local v = self.viewlist[idx];
	if v==nil then
		return;
	end
	v:clear();
	self.viewlist[idx] = nil;
end

-- 清理
function Gui:clear()
	for i, v in pairs(self.viewlist) do
		v:clear();
		self.viewlist[i] = nil;
	end
	self.viewlist = {};
end

function Gui:newTimer(idx, second)
	return self.timerlist:createTimer(idx, second);
end

function Gui:getTimer(idx)
	return self.timerlist:getTimer(idx);
end

function Gui:delTimer(idx)
	self.timerlist:delTimer(idx);
end

-- 设置刷新率
function Gui:setFPS(fps)
	self.fps = fps;
	self:getTimer(UpdateTimer):reset(1/self.fps);
end

function Gui:getPoint()
	return self.rect:getPoint();
end

function Gui:getSize()
	return self.rect:getSize();
end

function Gui:setPoint(x, y)
	self.rect:setPoint(x, y);
end

function Gui:setSize(w, h)
	self.rect:setSize(w, h);
	self:onSize(w, h);
end

function Gui:getRect()
	return self.rect:getRect();
end

-- 抓住
function Gui:grab(view, x, y)
	assert(self.grab_view==nil, "someview is grabed!");
	self.grab_view = view;
	self.grab_x = x;
	self.grab_y = y;
end

function Gui:ungrab(view)
	if self.grab_view==view then
		self.grab_view = nil;
	end
end

-- 拖动
function Gui:drag(v, auto)
	if v~=nil then
		self.dragmode = v;
	else
		self.dragmode = true;
	end
	self.dragmode_autorelease = auto or false;
end

function Gui:showGui(s)
	if s~=nil then
		self.show = s;
	else
		self.show = true;
	end
end

function Gui:showState()
	return self.show;
end

function Gui:enableGui(e)
	if e~=nil then
		self.enable = e;
	else
		self.enable = true;
	end
end

function Gui:enableState()
	return self.enable;
end

-- 动画打开（播放前showGui，播放完enableGui）(ae==nil为随机动画)
function Gui:open(ae, ...)
	if ae==nil then
		self:enableGui(true);
		self:showGui(true);
		return;
	elseif ae==0 then
		self.anima_effect = math.random(1, table.maxn(self.AnimaList));
	else
		self.anima_effect = ae;
	end
	local ae = self.AnimaList[self.anima_effect];
	ae:setMode(AE_ModeEnum.open);
	ae:setParam(...);
	if not self.anima then 
		ae:restart(); 
	end
	self:showGui();
	self.anima = true;
end

-- 动画关闭（打开动作顺序相反）(ae==0为随机动画, nil为无动画)
function Gui:close(ae, ...)
	self:enableGui(false);
	if ae==nil then
		self:showGui(false);
		return;
	elseif ae==0 then
		self.anima_effect = math.random(1, table.maxn(self.AnimaList));
	else
		self.anima_effect = ae;
	end
	local ae = self.AnimaList[self.anima_effect];
	ae:setMode(AE_ModeEnum.close);
	ae:setParam(...);
	if not self.anima then 
		ae:restart(); 
	end
	self.anima = true;
end

-- 设置焦点
function Gui:setFocus(view)
	self.pre_focus = self.focus;
	self.focus = view;
	
	if self.focus then
		self.focus:onSetFocus(self.pre_focus);
	end
	if self.pre_focus then
		self.pre_focus:onKillFocus(self.focus);
	end
end

function Gui:updateCanvas()
	if not self.show then
		return;
	end

	self.graph:getCanvas(self.cv):clear();
	
	-- 设置绘制目标
	self.graph:setCanvas(self.cv);

	-- 设置裁剪区
	Graphics._setScissor(0, 0, self.rect.width, self.rect.height);
	
	Graphics._setBlendMode("alpha")
	Graphics._setColorMode("modulate");
	
	-- 测试用边框
	-- Graphics._setColor({255,0,0});
	-- Graphics._rectangle("line", 0,0,
		-- self.rect.width, self.rect.height);
	
	for i,v in pairs(self.viewlist) do
		v:draw(0, 0, self.rect.width, self.rect.height);
	end
	-- 取消裁剪区
	Graphics._setScissor();
	
	-- 恢复绘制到屏幕
	self.graph:setCanvas();
	
	-- 惯性模式
	if self.inertia_mode then
		if not self.dragmode then
			local ax, ay = self.inertia_acceleration:getPoint();
			if ax~=0 or ay~=0 then
				self:moveGui(ax, ay);
				if ax>0 then
					ax = math.floor(ax/1.05)
				else
					ax = math.ceil(ax/1.05)
				end
				if ay>0 then
					ay = math.floor(ay/1.05)
				else
					ay = math.ceil(ay/1.05)
				end
				self.inertia_acceleration:setPoint(ax, ay);
			end
		end
	end	
end

function Gui:moveGui(dx, dy)
	local nx, ny = self:getPoint();
	local fx, fy = nx+dx, ny+dy;
	
	if self.move_rect_limit then
		if fx<self.move_rect.x then
			fx = self.move_rect.x;
		elseif fx>self.move_rect.x+self.move_rect.width then
			fx = self.move_rect.x+self.move_rect.width;
		end
		
		if fy<self.move_rect.y then
			fy = self.move_rect.y;
		elseif fy>self.move_rect.y+self.move_rect.height then
			fy = self.move_rect.y+self.move_rect.height;
		end
	end
	
	self:setPoint(fx, fy);
	if self.inertia_mode then
		self.inertia_acceleration:setPoint(dx, dy);
	end
end

function Gui:mousemove(x, y)
	local ismousein = false;
	if self.enable then
		if self.dragmode then
			local dx, dy = x - self.mouse:getLastX(), y-self.mouse:getLastY();
			self:moveGui(dx, dy);
		end

		-- 是否抓住
		if self.grab_view then
			self.grab_view:mousemove(self.grab_x + x - self.mouse:getLastX(),
				self.grab_y + y - self.mouse:getLastY());
			ismousein = true;
		else
			if IsPointIn(x, y, self.rect) then
				self.mouse:move(x, y);
				ismousein = true;
			else
				self.mouse:leave();
			end
		end
	end
	return ismousein;
end

function Gui:tic(dt)
	self.timerlist:tic(dt);
end

----------------------------------------------------------------
-- 对应于love各个回调
function Gui:mousepressed(x, y, button)
	if not self.enable or not self.show then
		return false;
	end

	if IsPointIn(x, y, self.rect) then
		self.mouse:pressed(x, y, LoveMouse2ViewMouse[button]);
		return true;
	end
	return false;
end

function Gui:mousereleased(x, y, button)
	if not self.enable or not self.show then
		return false;
	end

	if self.dragmode_autorelease then
		-- 自动解除拖动模式
		self.dragmode = false;
	end
	
	-- 是否抓住
	if self.grab_view then
		self.grab_view:mousereleased(self.grab_x + x - self.mouse:getLastX(),
			self.grab_y + y - self.mouse:getLastY(), LoveMouse2ViewMouse[button]);
		return;
	end
	
	if IsPointIn(x, y, self.rect) then
		self.mouse:released(x, y, LoveMouse2ViewMouse[button]);
		return true;
	end
	return false;
end

function Gui:keypressed(key, unicode)
	if not self.enable then
		return;
	end

	self.keyboard:pressed(key, unicode);
	if self.focus then
		self.focus:keypressed(key, unicode);
	end
end

function Gui:keyreleased(key)
	if not self.enable then
		return;
	end
	
	self.keyboard:released(key);
	if self.focus then
		self.focus:keyreleased(key);
	end
end

function Gui:joystickpressed(joystick, button)
	if joystick==nil then
		return;
	end
	if not self.enable then
		return;
	end
	
	self.joystick:pressed(joystick, button);
end

function Gui:joystickreleased(joystick, button)
	if joystick==nil then
		return;
	end
	if not self.enable then
		return;
	end
	
	self.joystick:released(joystick, button);
end

function Gui:update(dt)
	self:mousemove(self.mouse._getX(), self.mouse._getY());
	self:tic(dt);
end

function Gui:draw()
	if not self.show then
		return;
	end
	
	-- 绘制
	if self.anima then
		-- 开关动画
		local ae = self.AnimaList[self.anima_effect];
		self.anima = ae:effect(self);
		if not self.anima then
			if ae:getMode() == AE_ModeEnum.close then
				self:showGui(false);
			else
				self:enableGui();
				Graphics._setColor({255,255,255,self.alpha});
				self.graph:drawCanvas(self.cv, self.rect.x, self.rect.y);
			end
		end
	else
		Graphics._setColor({255,255,255,self.alpha});
		self.graph:drawCanvas(self.cv, self.rect.x, self.rect.y);
	end
end

return Gui;
