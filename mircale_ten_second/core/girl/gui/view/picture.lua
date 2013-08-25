----------------------------------------------------------------
-- write by xerysherry

-- 得到View类
local View = getClass("Object.View");
local ViewMouseEnum = getClass("Object.ViewMouseEnum");

local lg = love.graphics;

-- 图片背景（背景绘制器）
local Picture = class("Picture", View, 
{
	img = nil,
	color = nil,
	mode = 1,
	squared_quad = nil,
	-- 标题栏模式（拖动gui）
	caption = false,
	
	DrawModeEnum = 
	{
		normal = 1,
		squared = 2,
		tile = 3,
	},
});

-- 初始化
function Picture:initialize(w, h)
	View.initialize(self, w, h);
	self.color = {255,255,255};
	self.squared_quad = {};
end

function Picture:setMode(mode, rect, img_w, img_h)
	self.mode = mode or Picture.DrawModeEnum.normal;
	if rect then
		local iw = img_w or self.rect.width;
		local ih = img_h or self.rect.height;
		
		self.squared_quad[0] = rect;
		self.squared_quad[1] = lg.newQuad(0, 0, 
			rect.x, rect.y, iw, ih);
		self.squared_quad[2] = lg.newQuad(rect.x, 0, 
			rect.width, rect.y, iw, ih);
		self.squared_quad[3] = lg.newQuad(rect.x+rect.width, 0, 
			iw-rect.width-rect.x, rect.y, iw, ih);
		
		self.squared_quad[4] = lg.newQuad(0, rect.y, 
			rect.x, rect.height, iw, ih);
		self.squared_quad[5] = lg.newQuad(rect.x, rect.y, 
			rect.width, rect.height, iw, ih);
		self.squared_quad[6] = lg.newQuad(rect.x+rect.width, rect.y, 
			iw-rect.width-rect.x, rect.height, iw, ih);
			
		self.squared_quad[7] = lg.newQuad(0, rect.y+rect.height, 
			rect.x, ih-rect.height-rect.y, iw, ih);
		self.squared_quad[8] = lg.newQuad(rect.x, rect.y+rect.height, 
			rect.width, ih-rect.height-rect.y, iw, ih);
		self.squared_quad[9] = lg.newQuad(rect.x+rect.width, rect.y+rect.height, 
			iw-rect.width-rect.x, ih-rect.height-rect.y, iw, ih);
	else
		self.squared_quad = {};
	end
end

function Picture:setImage(img)
	self.img = img or nil;
end

function Picture:setImageColor(color)
	self.color = color or {255,255,255};
end

function Picture:enableCaption(v)
	if v~=nil then
		self.caption = v;
	else
		self.caption = true;
	end
end

function Picture:drawPic()
	self.gui.graph._setColor(self.color);
	if self.img==nil then
		self.gui.graph._rectangle("fill", 0, 0,
			self.rect.width, self.rect.height);
		return;
	end
	
	local img_w, img_h = self.gui.graph:getImageSize(self.img);
	if self.mode == Picture.DrawModeEnum.normal then
		self.gui.graph:drawImage(self.img, 0, 0, 0, 
			self.rect.width/img_w, self.rect.height/img_h);
	elseif self.mode == Picture.DrawModeEnum.squared then
		if self.squared_quad[0]==nil then
			return;
		end
		local img = self.gui.graph:getImage(self.img);
		local r = self.squared_quad[0];
		local tx, ty = self.rect.width-(img_w-r.x-r.width), self.rect.height-(img_h-r.y-r.height);
		local sw, sh = (tx-r.x)/r.width, (ty-r.y)/r.height;
		
		lg.drawq(img, self.squared_quad[1], 0, 0, 0, 1.0, 1.0);
		lg.drawq(img, self.squared_quad[2], r.x, 0, 0, sw, 1.0);
		lg.drawq(img, self.squared_quad[3], tx, 0, 0, 1.0, 1.0);
		
		lg.drawq(img, self.squared_quad[4], 0, r.y, 0, 1.0, sh);
		lg.drawq(img, self.squared_quad[5], r.x, r.y, 0, sw, sh);
		lg.drawq(img, self.squared_quad[6], tx, r.y, 0, 1.0, sh);
		
		lg.drawq(img, self.squared_quad[7], 0, ty, 0, 1.0, 1.0);
		lg.drawq(img, self.squared_quad[8], r.x, ty, 0, sw, 1.0);
		lg.drawq(img, self.squared_quad[9], tx, ty, 0, 1.0, 1.0);
	elseif self.mode == Picture.DrawModeEnum.tile then
		local cx, cy = 0, 0;
		while cy<self.rect.height do
			while cx<self.rect.width do
				self.gui.graph:drawImage(self.img, cx, cy);
				cx=cx+img_w;
			end
			cx=0;
			cy=cy+img_h;
		end
	end
end

function Picture:onDraw()
	self:drawPic();
end

function Picture:onMousePressed(x, y, button)
	if self.caption and button==ViewMouseEnum.LB then
		self.gui:drag(true, true);
	end
end

return Picture;
