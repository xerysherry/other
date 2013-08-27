----------------------------------------------------------------
-- write by xerysherry

-- 得到View类
local View = getClass("Object.View");
local ViewMouseEnum = getClass("Object.ViewMouseEnum");

local lg = love.graphics;

-- 画布背景（背景绘制器）
local Canvas = class("Canvas", View, 
{
	cv = nil,
	color = nil,
	-- 标题栏模式（拖动gui）
	caption = false,
});

-- 初始化
function Canvas:initialize(w, h)
	View.initialize(self, w, h);
	self.color = {255,255,255};
end

function Canvas:setCanvas(cv)
	self.cv = cv or nil;
end

function Canvas:setCanvasColor(color)
	self.color = color or {255,255,255};
end

function Canvas:enableCaption(v)
	if v~=nil then
		self.caption = v;
	else
		self.caption = true;
	end
end

function Canvas:drawCanvas()
	self.gui.graph._setColor(self.color);
	if self.cv==nil then
		self.gui.graph._rectangle("fill", 0, 0,
			self.rect.width, self.rect.height);
		return;
	end
	
	local cv_w, cv_h = self.gui.graph:getCanvasSize(self.cv);
	if cv_w==nil then
		return;
	end
	self.gui.graph:drawCanvas(self.cv, 0, 0, 0, 
		self.rect.width/cv_w, self.rect.height/cv_h);
end

function Canvas:onDraw()
	self:drawCanvas();
end

function Canvas:onMousePressed(x, y, button)
	if self.caption and button==ViewMouseEnum.LB then
		self.gui:drag(true, true);
	end
end

return Canvas;
