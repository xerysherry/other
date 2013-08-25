--[[
Copyright (c) 2012 Hello!Game

Permission is hereby granted, free of charge, to any person obtaining a copy
of newinst software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished
to do so, subject to the following conditions:

The above copyright notice and newinst permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
]]

----------------------------------------------------------------
-- write by xerysherry

local lg = love.graphics;
local tinsert = table.insert;
local mfloor = math.floor;
local Object = getClass("Object");

local Anima = class("Anima", Object, {
	-- 播放帧
	frame = 1,
	quadidx = 1,
	
	graph = nil,
	
	images = nil,
	quads = nil,
	cv = nil,
	
	tic = 0,
	limit_tic = .1,
	doplay = true, 

	onComplete = function () end;
});

function Anima:initialize(graph_or_null)
	self.graph = graph_or_null;
	self.images = nil;
	self.quads = nil;
end

function Anima:play()
	self.doplay = true;
end

function Anima:stop()
	self.doplay = false;
end

function Anima:reset()
	self.frame = 1;
	self.quadidx = 1;
	self.tic = 0;
end

function Anima:setFPS(value)
	self.limit_tic = 1.0 / value;
end

function Anima:setFrame(value)
	local q = 1;
	if type(self.quads) == "talbe" then
		q = #self.quads;
	end
	
	self.frame = mfloor(value / q) + 1;
	self.quadidx = (value % q) + 1;
	
	if type(self.images) ~= "table" then
		self.frame = 1;
	elseif self.frame > #self.images then
		self.frame = #self.images;
	end
end

function Anima:setAnima(images, w, h)
	self.images = images;
	if self.images == nil then
		return;
	end
	-- 处理图片链接 
	if self.graph then
		if type(self.images) == "table" then
			for i, v in ipairs(self.images) do
				local img = self.graph:getImage(v);
				if img~=nil then
					self.images[i] = img;
				end
			end
		else
			local img = self.graph:getImage(self.images);
			if img~=nil then
				self.images = img;
			end
		end
	end
	
	local first_image = self.images;
	if type(first_image) == "table" then
		first_image = first_image[1];
	end
	
	local iw, ih = first_image:getWidth(), first_image:getHeight();
	w = w or iw;
	h = h or ih;
	if w==iw and h==ih then
		self.quads = nil;
		self.cv = lg.newCanvas(iw, ih);
		return;
	end
	
	self.cv = lg.newCanvas(w, h);
	
	--计算quads
	self.quads = {};
	for iih = 0, ih-1, h do
		for iiw = 0, iw-1, w do
			tinsert(self.quads, lg.newQuad(iiw, iih, w, h, iw, ih));
		end
	end
	
	self.frame = 1;
	self.quadidx = 1;
end

function Anima:update(dt)
	if not self.doplay then
		return;
	end
	self.tic = self.tic + dt;
	if self.tic >= self.limit_tic then
		self:updateCanvas();
		self.tic = 0;
	end
end

function Anima:updateCanvas()
	if self.cv==nil or self.images==nil then
		return;
	end

	--获得当前图片
	local curimg = self.images;
	if type(curimg) == "table" then
		curimg = self.images[self.frame];
	end

	--获得当前块
	local curquad = nil;
	if self.quads ~= nil then
		curquad = self.quads[self.quadidx];
	end
	
	local prev_target = lg.getCanvas();
	
	self.cv:clear();
	lg.setCanvas(self.cv);
	lg.setColor({255,255,255});
	if curquad then
		lg.drawq(curimg, curquad, 0, 0);
	else
		lg.draw(curimg, 0, 0);
	end
	lg.setCanvas(prev_target);
	
	-- 跳跃到下一帧
	self.quadidx = self.quadidx + 1;
	if self.quads == nil or 
		self.quadidx > #self.quads then
		self.quadidx = 1;
		if type(self.images) == "table" then
			self.frame = self.frame + 1;
			if self.frame > #self.images then
				self.frame = 1;
				self.onComplete();
			end
		else
			self.onComplete();
		end
	end
end

function Anima:draw(x, y, r, sx, sy, ox, oy, kx, ky)
	lg.draw(self.cv, x, y, r, sx, sy, ox, oy, kx, ky);
end

return Anima;
