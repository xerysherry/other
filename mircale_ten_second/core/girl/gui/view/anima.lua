----------------------------------------------------------------
-- write by xerysherry
local tinsert = table.insert;

-- 得到View类
local Ani = getClass("Object.Anima");
local View = getClass("Object.View");
local ViewMouseEnum = getClass("Object.ViewMouseEnum");

local lg = love.graphics;

-- 图片背景（背景绘制器）
local Anima = class("Anima", View, 
{
	anima = nil,
	color = nil,
});

-- 初始化
function Anima:initialize(w, h)
	View.initialize(self, w, h);
	self.color = {255,255,255};
end

function Anima:setAnima(images, w, h)
	self.anima = Ani(self.gui.graph);
	self.anima:setAnima(images, w, h)
	self.anima:setFPS(self.gui.fps);
end

function Anima:setColor(color)
	self.color = color or {255,255,255};
end

function Anima:onUpdate()
	self.anima:update(1 / self.gui.fps);
end

function Anima:onDraw()
	lg.setColor(self.color);
	self.anima:draw(0, 0);
end

return Anima;
