----------------------------------------------------------------
-- write by xerysherry

local mfloor = math.floor;

-- 得到相关类
local Object = getClass("Object");
local Size = getClass("Object.Size");
local Rect = getClass("Object.Rect");
local View = getClass("Object.View");
local ViewMouseEnum = getClass("Object.ViewMouseEnum");
local Picture = getClass("Object.View.Picture");

-- 滑动条
local Slider = class("Slider", View, 
{
	hover = false,
	click = false,
	
	value = 0.0,
	maxvalue = 1.0,
	minvalue = 0.0,
	wheel_step = .1,		--滚轮步长(0:表示禁用滚轮)
	
	smooth = true,			--平滑方式
	typemode = 1,
	drawmode = 1,
	
	-- 滑块
	normal_slider = nil,
	hover_slider = nil,
	click_slider = nil,
	disable_slider = nil,
	slider_normal_color = nil,
	slider_hover_color = nil,
	slider_click_color = nil,
	slider_disable_color = nil,
	
	background = nil,
	slider = nil,
	
	-- 滑块移动区域
	slider_rect = nil,
	-- 滑块大小
	slider_size = nil,
	
	-- 回调函数
	onValueChange = function (this, prev_value) end;
	
	-- 枚举
	TypeModeEnum = 
	{
		horizontal = 1,
		vertical = 2,
	},
	DrawModeEnum = 
	{
		normal = 1,
		scroll = 2,
	},
});

function Slider:initialize(w, h)
	View.initialize(self, w, h);
	self.slider_normal_color = {255,255,255};
	self.slider_hover_color = {255,255,255};
	self.slider_click_color = {255,255,255};
	self.slider_disable_color = {255,255,255};
	
	self.background = Picture(w,h);
	self.slider = Picture(10,10);
	
	self.slider_rect = Rect(0, 0, w, h);
	self.slider_size = Size(10, h);
end

-- 控件模式
function Slider:setMode(typemode, drawmode)
	self.typemode = Slider.TypeModeEnum[typemode] or Slider.TypeModeEnum.horizontal;
	self.drawmode = Slider.TypeModeEnum[drawmode] or Slider.DrawModeEnum.normal;
end

function Slider:setSliderImage(normal, hover, click, disable)
	self.normal_slider = normal;
	self.hover_slider = hover;
	self.click_slider = click;
	self.disable_slider = disable;
end

function Slider:setSliderColor(normal, hover, click, disable)
	self.slider_normal_color = normal or {255,255,255};
	self.slider_hover_color = hover or {255,255,255};
	self.slider_click_color = click or {255,255,255};
	self.slider_disable_color = disable or {255,255,255};
end

function Slider:setValue(v)
	local prev_value = self.value;
	if self.smooth then
		self.value = v or 0.0;
	else
		self.value = mfloor(v/self.wheel_step+.5)*self.wheel_step or 0.0;
	end
	if self.value > self.maxvalue then
		self.value = self.maxvalue;
	elseif self.value < self.minvalue then
		self.value = self.minvalue;
	end
	if prev_value~=self.value then
		self:onValueChange(prev_value);
	end
end

function Slider:getValue()
	return self.value;
end

function Slider:setLimitValue(min, max)
	self.minvalue = min or 0.0;
	self.maxvalue = max or 1.0;
	if self.minvalue < 0 then
		self.minvalue = 0.0;
	end
	if self.maxvalue > 1.0 then
		self.minvalue = 1.0;
	end
end

function Slider:setWheelStep(ws)
	self.wheel_step = ws;
end

-- 只有在Silder为绘制模式scroll是才有意义
function Slider:setSliderSize(w, h)
	self.slider_size:setSize(w, h);
end

function Slider:setSliderMode(...)
	self.slider:setMode(...);
end

function Slider:setBackground(img)
	self.background:setImage(img);
end

function Slider:setBackgroundColor(color)
	self.background:setImageColor(color);
end

function Slider:setBackgroundMode(...)
	self.background:setMode(...);
end

function Slider:setSliderRect(x, y, w, h)
	self.slider_rect:setRect(x, y, w, h);
end

function Slider:drawBackground()
	self.background.gui = self.gui;
	self.background.rect = self.rect;
	self.background:drawPic();
end

function Slider:drawSlider()
	local img_idx = nil;
	local drawcolor = {255,255,255};
	
	if not self.enable then
		img_idx = self.disable_slider;
		drawcolor = self.slider_disable_color;
	elseif self.click then
		img_idx = self.click_slider;
		drawcolor = self.slider_click_color;
	elseif self.hover then
		img_idx = self.hover_slider;
		drawcolor = self.slider_hover_color;
	else
		drawcolor = self.slider_normal_color;
	end
	
	if img_idx==nil then
		img_idx = self.normal_slider;
	end

	-- 计算滑块绘制区域
	local slider_rect = self.slider_rect;
	local slider_size = self.slider_size;
	if self.typemode==Slider.TypeModeEnum.horizontal then
		local sw = slider_rect.width * self.value;
		if self.drawmode==Slider.DrawModeEnum.mode1 then
			self.slider.rect:setRect(slider_rect.x, slider_rect.y,
				sw, slider_rect.height);
		else
			self.slider.rect:setRect(sw-slider_size.width/2+slider_rect.x, slider_rect.y,
				slider_size.width, slider_size.height);
		end
	else
		local sh = self.slider_rect.height * self.value;
		if self.drawmode==Slider.DrawModeEnum.mode1 then
			self.slider.rect:setRect(slider_rect.x, slider_rect.y,
				slider_rect.width, sh);
		else
			self.slider.rect:setRect(slider_rect.x, sh-slider_size.height/2+slider_rect.y,
				slider_size.width, slider_size.height);
		end
	end
	
	self.slider.gui = self.gui;
	self.slider.color = drawcolor;
	self.slider.img = img_idx;
	
	self.gui.graph._push();
	self.gui.graph._translate(self.slider.rect.x, self.slider.rect.y);
	self.slider:drawPic();
	self.gui.graph._pop();
end

-- 根据鼠标位置改变进度值
function Slider:ValueChange(x, y)
	local value = self.value;
	local slider_rect = self.slider_rect;
	if self.typemode==Slider.TypeModeEnum.horizontal then
		if x<slider_rect.x then
			value = 0.0;
		elseif x>slider_rect.x+slider_rect.width then
			value = 1.0;
		else
			value = (x - slider_rect.x)/slider_rect.width;
		end
	else
		if y<slider_rect.y then
			value = 0.0;
		elseif y>slider_rect.y+slider_rect.height then
			value = 1.0;
		else
			value = (y - slider_rect.y)/slider_rect.height;
		end
	end
	self:setValue(value);
end

-- 事件
function Slider:onMousePressed(x, y, button)
	if button==ViewMouseEnum.LB then
		self:ValueChange(x, y);
		self.click = true;
		self:grab();
	elseif button==ViewMouseEnum.WHEEL_UP then
		self:setValue(self.value+self.wheel_step);
	elseif button==ViewMouseEnum.WHEEL_DOWN then
		self:setValue(self.value-self.wheel_step);
	end
end

function Slider:onMouseReleased(x, y, button)
	if button==ViewMouseEnum.LB then
		self.click = false;
		self:ungrab();
	end
end

function Slider:onMouseMove(x, y)
	self.hover = true;
	if self.click then
		self:ValueChange(x, y);
	end
end

function Slider:onLeave()
	self.hover = false;
	self.click = false;
end

function Slider:onDraw()
	self:drawBackground();
	self:drawSlider();
end

return Slider;
