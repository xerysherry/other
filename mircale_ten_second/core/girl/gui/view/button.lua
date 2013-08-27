----------------------------------------------------------------
-- write by xerysherry

-- 得到相关类
local View = getClass("Object.View");
local Rect = getClass("Object.Rect");
local ViewMouseEnum = getClass("Object.ViewMouseEnum");
local Picture = getClass("Object.View.Picture");

-- 按钮类
local Button = class("Button", View,
{
	-- 按钮属性
	hover = false,
	click = false,
	
	-- 标签相关
	font = "_system",
	label = "",
	label_x = 0,
	label_y = 0,
	label_normal_color = nil,
	label_hover_color = nil,
	label_click_color = nil,
	label_disable_color = nil,
	
	-- 背景相关
	normal_bg = nil,
	hover_bg = nil,
	click_bg = nil,
	disable_bg = nil,
	bg_normal_color = nil,
	bg_hover_color = nil,
	bg_click_color = nil,
	bg_disable_color = nil,
	
	-- 背景绘制器
	picture = nil,
	
	-- 按钮点击事件
	onButtonClick = function (this) end,
});

-- 初始化
function Button:initialize(w, h)
	View.initialize(self, w, h);
	self.label_normal_color = {0,0,0};
	self.label_hover_color = {50,50,50};
	self.label_click_color = {0,0,0};
	self.label_disable_color = {125,125,125};
	
	self.bg_normal_color = {255,255,255};
	self.bg_hover_color = {255,255,255};
	self.bg_click_color = {255,255,255};
	self.bg_disable_color = {125,125,125};
	
	self.picture = Picture(w,h);
end

function Button:setImage(normal, hover, click, disable)
	self.normal_bg = normal;
	self.hover_bg = hover;
	self.click_bg = click;
	self.disable_bg = disable;
end

function Button:setImageColor(normal, hover, click, disable)
	self.bg_normal_color = normal or {255,255,255};
	self.bg_hover_color = hover or {255,255,255};
	self.bg_click_color = click or {255,255,255};
	self.bg_disable_color = disable or {255,255,255};
end

function Button:setFont(font)
	self.font = font or "_system";
end

function Button:setLabel(label, x, y, font)
	self.label = label or "";
	self.label_x = x or self.label_x;
	self.label_y = y or self.label_y;
	self.font = font or self.font;
end

function Button:setLabelColor(normal, hover, click, disable)
	self.label_normal_color = normal or {0,0,0};
	self.label_hover_color = hover or {50,50,50};
	self.label_click_color = click or {0,0,0};
	self.label_disable_color = disable or {125,125,125};
end

function Button:setMode(...)
	self.picture:setMode(...);
end

-- 绘制
function Button:DrawText()
	if self.label=="" then
		return;
	end
	
	if not self.enable then
		drawcolor = self.label_disable_color;
	elseif self.click then
		drawcolor = self.label_click_color;
	elseif self.hover then
		drawcolor = self.label_hover_color;
	else
		drawcolor = self.label_normal_color;
	end

	self.gui.graph:setFont(self.font);
	self.gui.graph._setColor(drawcolor);
	self.gui.graph._print(self.label, self.label_x, self.label_y);
end

function Button:DrawImage()
	local img_idx = nil;
	local drawcolor = {255,255,255};
	
	if not self.enable then
		img_idx = self.disable_bg;
		drawcolor = self.bg_disable_color;
	elseif self.click then
		img_idx = self.click_bg;
		drawcolor = self.bg_click_color;
	elseif self.hover then
		img_idx = self.hover_bg;
		drawcolor = self.bg_hover_color;
	else
		drawcolor = self.bg_normal_color;
	end
	
	if img_idx==nil then
		img_idx = self.normal_bg;
	end

	self.picture.gui = self.gui;
	self.picture.rect = self.rect; 
	self.picture.color = drawcolor;
	self.picture.img = img_idx;
	self.picture:drawPic();
end

function Button:onDraw()
	self:DrawImage();
	self:DrawText();
end

-- 事件
function Button:onMousePressed(x, y, button)
	self.click = true;
end

function Button:onMouseReleased(x, y, button)
	if button==ViewMouseEnum.LB and self.click then
		self:onButtonClick();
	end
	self.click = false;
end

function Button:onMouseMove(x, y)
	self.hover = true;
end

function Button:onLeave()
	self.hover = false;
	self.click = false;
end

return Button;
