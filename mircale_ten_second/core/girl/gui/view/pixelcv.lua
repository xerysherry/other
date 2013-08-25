----------------------------------------------------------------
-- write by xerysherry

-- 得到View类
local View = getClass("Object.View");
local Rect = getClass("Object.Rect");
local ViewMouseEnum = getClass("Object.ViewMouseEnum");
local Graphics = getClass("Object.Graphics");

local lg = love.graphics;
local tinsert = table.insert;
local mfloor = math.floor;
local mabs = math.abs;
local msqrt = math.sqrt;

local DrawTool = {
	Point=0, 			-- 点
	Line=1, 			-- 线,不支持擦除
	Rectangle=2, 		-- 矩形
	Circle=3			-- 圆,不支持擦除
	};

-- 像素画布(左键绘制，右键擦除)
local Pixelcv = class("Pixelcv", View, 
{
	click = false,

	-- 画布参数
	cv_w = 32,
	cv_h = 32,
	cv = nil,
	
	-- 擦除
	rb_eraser_mode = true,
	
	-- 缩放参数
	zoom = 8,			-- 1.0表示 实际1pixel=绘制1pixel
	
	-- 偏移
	offset_x = 0,
	offset_y = 0,
	
	-- 绘制信息
	bg_color = nil,		-- 背景颜色
	cvbg_color = nil,	-- 画布背景
	line_color = nil,	-- 像素点分割线
	cvclear_color = nil,-- 画布clear颜色
	
	-- 绘制颜色
	draw_color = nil,
	points_list = nil,
	
	draw_tool = DrawTool.Point,
	eraser = false,
	fill = false,
	draw_quality = "rough",
	draw_size = 1,
	
	-- 开始点/结束点
	start_pt = nil,
	end_pt = nil,
});

function Pixelcv:initialize(w, h)
	View.initialize(self, w, h);
	self.bg_color = {128, 128, 128};
	self.cvbg_color = {255, 255, 255, 255};
	self.line_color = {0, 0, 0, 255};
	self.draw_color = {0, 0, 0, 255};
	self.cvclear_color = {255, 255, 255, 0};
end

function Pixelcv:setNewCanvas(w, h)
	self.cv_w = w;
	self.cv_h = h;
	self.cv = lg.newCanvas(self.cv_w, self.cv_h);
	self.cv:setFilter("nearest", "nearest");
	self:clearCv();
end

function Pixelcv:setDrawQuality(quality)
	self.draw_quality = quality;
end

function Pixelcv:setDrawSize(size)
	self.draw_size = size;
end

function Pixelcv:setCanvas(cv)
	self.cv_w = cv:getWidth();
	self.cv_h = cv:getHeight();
	self.cv = cv;
	self.cv:setFilter("nearest", "nearest");
end

function Pixelcv:setCanvasFilter(min, mag)
	self.cv:setFilter(min, mag);
end

function Pixelcv:getDrawQuality()
	return self.draw_quality;
end

function Pixelcv:getDrawSize()
	return self.draw_size;
end

function Pixelcv:getCanvas(cv)
	return self.cv;
end

function Pixelcv:getCanvasFilter(min, mag)
	return self.cv:getFilter();
end

function Pixelcv:setBgColor(color)
	self.bg_color = color or {128, 128, 128};
end

function Pixelcv:setCvColor(color)
	self.cvbg_color = color or {255, 255, 255, 255};
end

function Pixelcv:setLineColor(color)
	self.line_color = color or {0, 0, 0, 255};
end

function Pixelcv:setDrawColor(color)
	self.draw_color = color or {0, 0, 0, 255};
end

function Pixelcv:setEraseColor(color)
	self.cvclear_color = color or {255, 255, 255, 0};
end

function Pixelcv:setDrawTool(tool)
	assert(DrawTool[tool]~=nil, "the tool's name of \""..tool.."\" is not exist");
	self.draw_tool = DrawTool[tool];
end

function Pixelcv:setEraser(v)
	self.eraser = v or false;
end

function Pixelcv:setFill(v)
	self.fill = v or false;
end

function Pixelcv:setZoom(zoom)
	self.zoom = zoom;
end

function Pixelcv:setOffsetX(offset)
	self.offset_x = offset;
	if self.offset_x>0 then
		self.offset_x = -self.offset_x;
	end
end

function Pixelcv:setOffsetY(offset)
	self.offset_y = offset;
	if self.offset_y>0 then
		self.offset_y = -self.offset_y;
	end
end

function Pixelcv:getZoomWidth()
	return self.zoom*self.cv_w;
end

function Pixelcv:getZoomHeight()
	return self.zoom*self.cv_h;
end

function Pixelcv:clearCv()
	self.cv:clear(unpack(self.cvclear_color));
end

function Pixelcv:getCanvasLocAndSize()
	local fx = self.offset_x;
	local fy = self.offset_y;
	local fw = self.cv_w * self.zoom;
	local fh = self.cv_h * self.zoom;
	
	if fw<self.rect.width then
		fx = (self.rect.width - fw)/2;
	end
	if fh<self.rect.height then
		fy = (self.rect.height - fh)/2;
	end
	return fx, fy, fw, fh;
end

function Pixelcv:getLinePoints(ex, ey)
	self.points_list = {};
	local dx = ex-self.start_pt[1];
	local dy = ey-self.start_pt[2];
	if mabs(dx)>mabs(dy) then
		local k = (ey-self.start_pt[2])/(ex-self.start_pt[1]);
		local ax = 1;
		if dx<0 then
			ax=-1;
		end
		for i=0, dx, ax do
			local ix = self.start_pt[1]+i;
			local iy = self.start_pt[2]+mfloor(k*i);
			table.insert(self.points_list, {ix*self.zoom, iy*self.zoom});
		end
	else
		local k = (ex-self.start_pt[1])/(ey-self.start_pt[2]);
		local ay = 1;
		if dy<0 then
			ay=-1;
		end
		for i=0, dy, ay do
			local ix = self.start_pt[1]+mfloor(k*i);
			local iy = self.start_pt[2]+i;
			table.insert(self.points_list, {ix*self.zoom, iy*self.zoom});
		end
	end
end

function Pixelcv:saveCanvas(...)
	Graphics.encodeCanvas(self.cv, ...);
end

function Pixelcv:drawCvPoint(x, y)
	lg.setCanvas(self.cv);
	
	local p1, p2 = lg.getLineWidth(), lg.getLineStyle();
	lg.setLine(self.draw_size, self.draw_quality)
	lg.setColor(self.draw_color);
	
	lg.line(x, y, x+1, y+1);
	lg.setLine(p1, p2);
	
	lg.setCanvas();
end

function Pixelcv:drawCvLine(x, y)
	lg.setCanvas(self.cv);
	lg.setColor(self.draw_color);
	
	local sx=self.start_pt[1];
	if x<self.start_pt[1] then
		dx=x;
	end
	local dy=self.start_pt[2];
	if y<self.start_pt[2] then
		dy=y;
	end
	
	local p1, p2 = lg.getLineWidth(), lg.getLineStyle();
	lg.setLine(self.draw_size, self.draw_quality)
	lg.line(self.start_pt[1], self.start_pt[2], x, y);
	lg.setLine(p1, p2);
		
	lg.setCanvas();
end

function Pixelcv:drawCvRectangle(x, y)
	lg.setCanvas(self.cv);
	lg.setColor(self.draw_color);
	
	local dx=self.start_pt[1];
	if x<self.start_pt[1] then
		dx=x;
	end
	local dy=self.start_pt[2];
	if y<self.start_pt[2] then
		dy=y;
	end
	if self.fill then
		lg.rectangle("fill", dx, dy,
			mabs(self.start_pt[1]-x)+1, mabs(self.start_pt[2]-y)+1);
	else
		local p1, p2 = lg.getLineWidth(), lg.getLineStyle();
		lg.setLine(self.draw_size, self.draw_quality)
		lg.rectangle("line", dx+1, dy+1,
			mabs(self.start_pt[1]-x), mabs(self.start_pt[2]-y));
		lg.setLine(p1, p2);
	end
	lg.setCanvas();
end

function Pixelcv:drawCvCircle(x, y)
	lg.setCanvas(self.cv);
	lg.setColor(self.draw_color);
	
	local dx=self.start_pt[1];
	local dy=self.start_pt[2];
	local da=dx-x;
	local db=dy-y;
	local r=msqrt(da*da+db*db)
	
	if self.fill then
		lg.circle("fill", dx, dy, r);
	else
		local p1, p2 = lg.getLineWidth(), lg.getLineStyle();
		lg.setLine(self.draw_size, self.draw_quality)
		lg.circle("line", dx, dy, r);
		lg.setLine(p1, p2);
	end
	lg.setCanvas();
end

function Pixelcv:eraseCvPoint(x, y)
	lg.setCanvas(self.cv);
	local ds2rd = mfloor(self.draw_size/2);
	if ds2rd==self.draw_size/2 then
		y=y+1;
	end
	lg.setScissor(x-ds2rd, y-ds2rd, self.draw_size, self.draw_size);
	self.cv:clear(unpack(self.cvclear_color));
	lg.setScissor();
	lg.setCanvas();
end

function Pixelcv:eraseCvRectangle(x, y)
	local dx=self.start_pt[1];
	if x<self.start_pt[1] then
		dx=x;
	end
	local dy=self.start_pt[2];
	if y<self.start_pt[2] then
		dy=y;
	end
	lg.setCanvas(self.cv);
	lg.setScissor(dx, dy,
		mabs(self.start_pt[1]-x)+1, mabs(self.start_pt[2]-y)+1);
	self.cv:clear(unpack(self.cvclear_color));
	lg.setScissor();
	lg.setCanvas();
end

function Pixelcv:drawFakePoint(color)
	if self.start_pt==nil then
		return;
	end

	local vl, vt, vw, vh = self.rect:getRect();
	local cx, cy, cw, ch = self:getCanvasLocAndSize();
	local sx, sy, sw, sh = MergeRect(0, 0, vw, vh, cx, cy, cw, ch);
	if sx==nil then
		return;
	end
	
	--设置裁剪区
	self.gui.graph._setScissor(sx+vl, sy+vt, sw, sh);
	--转换
	self.gui.graph._push();
	self.gui.graph._translate(cx, cy);
	
	lg.setColor(color);
	lg.rectangle("fill", self.start_pt[1]*self.zoom, 
		self.start_pt[2]*self.zoom, self.zoom, self.zoom);

	self.gui.graph._setScissor(vl, vt, vw, vh);
	self.gui.graph._pop();
end

function Pixelcv:drawFakeLine(color)
	if self.start_pt==nil then
		return;
	end

	local vl, vt, vw, vh = self.rect:getRect();
	local cx, cy, cw, ch = self:getCanvasLocAndSize();
	local sx, sy, sw, sh = MergeRect(0, 0, vw, vh, cx, cy, cw, ch);
	if sx==nil then
		return;
	end
	
	--设置裁剪区
	self.gui.graph._setScissor(sx+vl, sy+vt, sw, sh);
	--转换
	self.gui.graph._push();
	self.gui.graph._translate(cx, cy);
	
	local dx=self.start_pt[1];
	if self.end_pt[1]<self.start_pt[1] then
		dx=self.end_pt[1];
	end
	local dy=self.start_pt[2];
	if self.end_pt[2]<self.start_pt[2] then
		dy=self.end_pt[2];
	end
	local p1, p2 = lg.getLineWidth(), lg.getLineStyle();
	lg.setColor(color);
	lg.line(self.start_pt[1]*self.zoom,
		self.start_pt[2]*self.zoom,
		self.end_pt[1]*self.zoom, 
		self.end_pt[2]*self.zoom);
	lg.setLine(p1, p2);
	
	self.gui.graph._setScissor(vl, vt, vw, vh);
	self.gui.graph._pop();
end

function Pixelcv:drawFakeRectangle(color)
	if self.start_pt==nil then
		return;
	end

	local vl, vt, vw, vh = self.rect:getRect();
	local cx, cy, cw, ch = self:getCanvasLocAndSize();
	local sx, sy, sw, sh = MergeRect(0, 0, vw, vh, cx, cy, cw, ch);
	if sx==nil then
		return;
	end
	
	--设置裁剪区
	self.gui.graph._setScissor(sx+vl, sy+vt, sw, sh);
	--转换
	self.gui.graph._push();
	self.gui.graph._translate(cx, cy);
	
	local dx=self.start_pt[1];
	if self.end_pt[1]<self.start_pt[1] then
		dx=self.end_pt[1];
	end
	local dy=self.start_pt[2];
	if self.end_pt[2]<self.start_pt[2] then
		dy=self.end_pt[2];
	end
	lg.setColor(color);
	lg.rectangle("line", dx*self.zoom, dy*self.zoom, 
		mabs(self.start_pt[1]-self.end_pt[1])*self.zoom+self.zoom, 
		mabs(self.start_pt[2]-self.end_pt[2])*self.zoom+self.zoom);
	self.gui.graph._setScissor(vl, vt, vw, vh);
	self.gui.graph._pop();
end

function Pixelcv:drawFakeCircle(color)
	if self.start_pt==nil then
		return;
	end

	local vl, vt, vw, vh = self.rect:getRect();
	local cx, cy, cw, ch = self:getCanvasLocAndSize();
	local sx, sy, sw, sh = MergeRect(0, 0, vw, vh, cx, cy, cw, ch);
	if sx==nil then
		return;
	end
	
	--设置裁剪区
	self.gui.graph._setScissor(sx+vl, sy+vt, sw, sh);
	--转换
	self.gui.graph._push();
	self.gui.graph._translate(cx, cy);
	
	local dx=self.start_pt[1];
	local dy=self.start_pt[2];
	local da=self.end_pt[1]-dx;
	local db=self.end_pt[2]-dy;
	local r=msqrt(da*da+db*db)
	lg.setColor(color);
	lg.circle("line", dx*self.zoom, dy*self.zoom, r*self.zoom)
	
	self.gui.graph._setScissor(vl, vt, vw, vh);
	self.gui.graph._pop();
end

function Pixelcv:drawBackground()
	self.gui.graph._setColor(self.bg_color);
	self.gui.graph._rectangle("fill", 0, 0, self.rect.width, self.rect.height);
end

function Pixelcv:drawCanvasBackground(x, y, w, h)
	self.gui.graph._setColor(self.cvbg_color);
	self.gui.graph._rectangle("fill", x, y, w, h);
end

function Pixelcv:drawLine(x, y, w, h)
	if self.zoom < 8 then
		return;
	end
	
	self.gui.graph._setColor(self.line_color);
	for ox=0, w, self.zoom do
		local ix = ox + x;
		if ox>=0 then
			self.gui.graph._rectangle("fill", ix-1, y, 1, h);
		elseif ix>self.rect.width then
			break;
		end
	end
	for oy=0, h, self.zoom do
		local iy = oy + y;
		if oy>=0 then
			self.gui.graph._rectangle("fill", x-1, iy-1, w, 1);
		elseif iy>self.rect.height then
			break;
		end
	end
end

function Pixelcv:drawCanvas(x, y, w, h)
	self.gui.graph._setColor({255,255,255});
	self.gui.graph._draw(self.cv, x, y, 0, w/self.cv_w, h/self.cv_h);
end

function Pixelcv:onDraw()
	local fx, fy, fw, fh = self:getCanvasLocAndSize();
	self:drawBackground();
	self:drawCanvasBackground(fx, fy, fw, fh);
	self:drawCanvas(fx, fy, fw, fh);

	if not self.eraser then
		if self.draw_tool==DrawTool.Point and self.click then
			self:drawFakePoint(self.draw_color);
		elseif self.draw_tool==DrawTool.Line and self.click then
			self:drawFakeLine(self.draw_color);
		elseif self.draw_tool==DrawTool.Rectangle and self.click then
			self:drawFakeRectangle(self.draw_color);
		elseif self.draw_tool==DrawTool.Circle and self.click then
			self:drawFakeCircle(self.draw_color);
		else
			self:drawFakePoint(self.draw_color);
		end
	else
		if self.draw_tool==DrawTool.Point and self.click then
			self:drawFakePoint(self.cvclear_color);
		elseif self.draw_tool==DrawTool.Rectangle and self.click then
			self:drawFakeRectangle({128,128,128});
		else
			self:drawFakePoint(self.cvclear_color);
		end
	end
	self:drawLine(fx, fy, fw, fh);
end

function Pixelcv:onMousePressed(x, y, button)
	local fx, fy, fw, fh = self:getCanvasLocAndSize();
	if x<fx or y<fy then
		return;
	end
	local dx = mfloor((x-fx)/self.zoom);
	local dy = mfloor((y-fy)/self.zoom);
	
	if button==ViewMouseEnum.LB then
		self.start_pt = {dx, dy};
		if self.draw_tool==DrawTool.Point then
			self:drawCvPoint(dx, dy);
		elseif self.draw_tool==DrawTool.Line or
			self.draw_tool==DrawTool.Rectangle or 
			self.draw_tool==DrawTool.Circle then
			self.end_pt = {dx, dy};
		else
			return;
		end
		self.click = true;
		self:grab();
	elseif button==ViewMouseEnum.RB then
		if not self.rb_eraser_mode then
			return;
		end
		self.start_pt = {dx, dy};
		if self.draw_tool==DrawTool.Point then
			self:eraseCvPoint(dx, dy);
		elseif self.draw_tool==DrawTool.Rectangle then
			self.end_pt = {dx, dy};
		else
			return;
		end
		self.click = true;
		self.eraser = true;
		self:grab();
	end
end

function Pixelcv:onMouseMove(x, y)
	local fx, fy, fw, fh = self:getCanvasLocAndSize();
	if self.click then
		if x<fx or y<fy then
			return;
		end
		local dx = mfloor((x-fx)/self.zoom);
		local dy = mfloor((y-fy)/self.zoom);
		
		if self.draw_tool==DrawTool.Point then
			if not self.eraser then
				self:drawCvPoint(dx, dy);
			else
				self:eraseCvPoint(dx, dy);
			end
		elseif self.draw_tool==DrawTool.Line or 
			self.draw_tool==DrawTool.Rectangle or 
			self.draw_tool==DrawTool.Circle then
			self.end_pt = {dx, dy};
		end
	else
		if x<fx or y<fy then
			self.start_pt = nil;
			return;
		else
			local dx = mfloor((x-fx)/self.zoom);
			local dy = mfloor((y-fy)/self.zoom);
			self.start_pt = {dx, dy};
		end
	end
end

function Pixelcv:onMouseReleased(x, y, button)
	if not self.click then
		return;
	end
	
	local fx, fy, fw, fh = self:getCanvasLocAndSize();
	if x<fx or y<fy then
		return;
	end
	local dx = mfloor((x-fx)/self.zoom);
	local dy = mfloor((y-fy)/self.zoom);
	
	if self.draw_tool==DrawTool.Line then
		if not self.eraser then
			-- 绘制直线
			self:drawCvLine(dx, dy);
		end
	elseif self.draw_tool==DrawTool.Rectangle then
		if not self.eraser then
			-- 绘制矩形
			self:drawCvRectangle(dx, dy);
		else
			-- 擦除矩形
			self:eraseCvRectangle(dx, dy);
		end
	elseif self.draw_tool==DrawTool.Circle then
		if not self.eraser then
			-- 绘制矩形
			self:drawCvCircle(dx, dy);
		end
	end
	self.click = false;
	self.start_pt = nil;
	self.eraser = false;
	self:ungrab();
end

function Pixelcv:onLeave()
	self.start_pt = nil;
end

return Pixelcv;
