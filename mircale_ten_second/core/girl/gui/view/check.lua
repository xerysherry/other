----------------------------------------------------------------
-- write by xerysherry

-- 得到相关类
local View = getClass("Object.View");
local Graphics = getClass("Object.Graphics");
local ViewMouseEnum = getClass("Object.ViewMouseEnum");
local Picture = getClass("Object.View.Picture");

-- 点选按钮类
local Check = class("Check", View, 
{
	-- 按钮属性
	hover = false,
	click = false,
	check = false,
	
	-- 标签相关
	font = "_system",
	label = "",
	label_x = 0,
	label_y = 0,
	-- 未选中状态标签颜色
	label_uncheck_normal_color = nil,
	label_uncheck_hover_color = nil,
	label_uncheck_click_color = nil,
	label_uncheck_disable_color = nil,
	-- 选中状态标签颜色
	label_check_normal_color = nil,
	label_check_hover_color = nil,
	label_check_click_color = nil,
	label_check_disable_color = nil,
	
	-- 未选中状态背景相关
	uncheck_normal_bg = nil,
	uncheck_hover_bg = nil,
	uncheck_click_bg = nil,
	uncheck_disable_bg = nil,
	bg_uncheck_normal_color = nil,
	bg_uncheck_hover_color = nil,
	bg_uncheck_click_color = nil,
	bg_uncheck_disable_color = nil,
	
	-- 选中状态背景相关
	check_normal_bg = nil,
	check_hover_bg = nil,
	check_click_bg = nil,
	check_disable_bg = nil,
	bg_check_normal_color = nil,
	bg_check_hover_color = nil,
	bg_check_click_color = nil,
	bg_check_disable_color = nil,
	
	-- 背景绘制器
	pic_tran_x = 0,
	pic_tran_y = 0,
	pic_w = 16,
	pic_h = 16,
	picture = nil,
	
	-- 单选点击事件(状态改变前，返回nil或者true表示运行改变check)
	onCheckClick = function (this) end,
	-- 状态改变回调(状态改变后)
	onCheckChange = function (this) end,
});

function Check:initialize(w, h)
	View.initialize(self, w, h);
	
	self.label_uncheck_normal_color = {0,0,0};
	self.label_uncheck_hover_color = {50,50,50};
	self.label_uncheck_click_color = {0,0,0};
	self.label_uncheck_disable_color = {125,125,125};
	
	self.label_check_normal_color = {0,0,0};
	self.label_check_hover_color = {50,50,50};
	self.label_check_click_color = {0,0,0};
	self.label_check_disable_color = {125,125,125};
	
	self.bg_uncheck_normal_color = {255,255,255};
	self.bg_uncheck_hover_color = {255,255,255};
	self.bg_uncheck_click_color = {255,255,255};
	self.bg_uncheck_disable_color = {125,125,125};
	
	self.bg_check_normal_color = {255,255,255};
	self.bg_check_hover_color = {255,255,255};
	self.bg_check_click_color = {255,255,255};
	self.bg_check_disable_color = {125,125,125};
	
	self.picture = Picture(w, h);
	self:setCheckRect(0,0,w,h);
end

function Check:setFont(font)
	self.font = font or "_system";
end

function Check:setLabel(label, x, y, font)
	self.label = label or "";
	self.label_x = x or self.label_x;
	self.label_y = y or self.label_y;
	self.font = font or self.font;
end

function Check:setImage(check_normal, check_hover, check_click, check_disable,
						uncheck_normal, uncheck_hover, uncheck_click, uncheck_disable)
	self.check_normal_bg = check_normal;
	self.check_hover_bg = check_hover;
	self.check_click_bg = check_click;
	self.check_disable_bg = check_disable;
	
	self.uncheck_normal_bg = uncheck_normal;
	self.uncheck_hover_bg = uncheck_hover;
	self.uncheck_click_bg = uncheck_click;
	self.uncheck_disable_bg = uncheck_disable;
end

function Check:setImageColor(check_normal, check_hover, check_click, check_disable,
						uncheck_normal, uncheck_hover, uncheck_click, uncheck_disable)
	self.bg_check_normal_color = check_normal or {255,255,255};
	self.bg_check_hover_color = check_hover or {255,255,255};
	self.bg_check_click_color = check_click or {255,255,255};
	self.bg_check_disable_color = check_disable or {125,125,125};
	
	self.bg_uncheck_normal_color = uncheck_normal or {255,255,255};
	self.bg_uncheck_hover_color = uncheck_hover or {255,255,255};
	self.bg_uncheck_click_color = uncheck_click or {255,255,255};
	self.bg_uncheck_disable_color = uncheck_disable or {125,125,125};
end

function Check:setLabelColor(check_normal, check_hover, check_click, check_disable,
						uncheck_normal, uncheck_hover, uncheck_click, uncheck_disable)
	self.label_check_normal_color = check_normal or {0,0,0};
	self.label_check_hover_color = check_hover or {50,50,50};
	self.label_check_click_color = check_click or {0,0,0};
	self.label_check_disable_color = check_disable or {125,125,125};
	
	self.label_uncheck_normal_color = uncheck_normal or {0,0,0};
	self.label_uncheck_hover_color = uncheck_hover or {50,50,50};
	self.label_uncheck_click_color = uncheck_click or {0,0,0};
	self.label_uncheck_disable_color = uncheck_disable or {125,125,125};
end

function Check:setMode(...)
	self.picture:setMode(...);
end

function Check:setCheckRect(x, y, w, h)
	self.pic_tran_x = x;
	self.pic_tran_y = y;
	self.pic_w = w;
	self.pic_h = h;
end

function Check:setCheck(v)
	local prev = self.check;
	self.check = v;
	if prev~=v then
		self:onCheckChange();
	end
end

-- 绘制
function Check:DrawText()
	if self.label=="" then
		return;
	end
	
	if self.check then
		if not self.enable then
			drawcolor = self.label_check_disable_color;
		elseif self.click then
			drawcolor = self.label_check_click_color;
		elseif self.hover then
			drawcolor = self.label_check_hover_color;
		else
			drawcolor = self.label_check_normal_color;
		end
	else
		if not self.enable then
			drawcolor = self.label_uncheck_disable_color;
		elseif self.click then
			drawcolor = self.label_uncheck_click_color;
		elseif self.hover then
			drawcolor = self.label_uncheck_hover_color;
		else
			drawcolor = self.label_uncheck_normal_color;
		end
	end
	
	self.gui.graph:setFont(self.font);
	self.gui.graph._setColor(drawcolor);
	self.gui.graph._print(self.label, self.label_x, self.label_y);
end

function Check:DrawImage()
	local img_idx = nil;
	local drawcolor = {255,255,255};
	
	if self.check then
		if not self.enable then
			img_idx = self.check_disable_bg;
			drawcolor = self.bg_check_disable_color;
		elseif self.click then
			img_idx = self.check_click_bg;
			drawcolor = self.bg_check_click_color;
		elseif self.hover then
			img_idx = self.check_hover_bg;
			drawcolor = self.bg_check_hover_color;
		else
			drawcolor = self.bg_check_normal_color;
		end
		if img_idx==nil then
			img_idx = self.check_normal_bg;
			if img_idx==nil then
				return;
			end
		end
	else
		if not self.enable then
			img_idx = self.uncheck_disable_bg;
			drawcolor = self.bg_uncheck_disable_color;
		elseif self.click then
			img_idx = self.uncheck_click_bg;
			drawcolor = self.bg_uncheck_click_color;
		elseif self.hover then
			img_idx = self.uncheck_hover_bg;
			drawcolor = self.bg_uncheck_hover_color;
		else
			drawcolor = self.bg_uncheck_normal_color;
		end
		if img_idx==nil then
			img_idx = self.uncheck_normal_bg;
			if img_idx==nil then
				return;
			end
		end
	end
	
	Graphics._push();
	Graphics._translate(self.pic_tran_x, self.pic_tran_y);
	
	self.picture.gui = self.gui;
	self.picture.rect:setRect(0, 0, self.pic_w, self.pic_h); 
	self.picture.color = drawcolor;
	self.picture.img = img_idx;
	self.picture:drawPic();
	
	Graphics._pop();
end

function Check:onDraw()
	self:DrawImage();
	self:DrawText();
end

-- 事件
function Check:onMousePressed(x, y, button)
	self.click = true;
end

function Check:onMouseReleased(x, y, button)
	if button==ViewMouseEnum.LB and self.click then
		local can_change = self:onCheckClick();
		if can_change==nil or can_change then
			self.check = not self.check;
			self:onCheckChange();
		end
	end
	self.click = false;
end

function Check:onMouseMove(x, y)
	self.hover = true;
end

function Check:onLeave()
	self.hover = false;
	self.click = false;
end

return Check;
