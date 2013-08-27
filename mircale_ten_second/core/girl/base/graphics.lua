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

-- 图片和画布管理

local lf = love.filesystem;
local li = love.image;
local lg = love.graphics;

-- 得到基类
local Object = getClass("Object");
local Size = getClass("Object.Size");
local Font = getClass("Object.FontManager");

-- 图片对象
local Image = class("Image", Object,
{
	path = nil,			--路径
	img = nil,			--图片
});

-- 画布对象
local Canvas = class("Canvas", Object,
{
	size = nil,
	canvas = nil,
	-- 成员方法
	initialize = function(this, w, h)
		if type(w) == "Canvas" then
			this.canvas = w;
			this.size = Size:new(this.canvas:getWidth(), this.canvas:getHeight());
		else
			this.size = Size:new(w, h);
			this.canvas = lg.newCanvas(w, h);
		end
	end,
	getSize = function (this)
		return this.size:getSize();
	end,
})

local PixelEffect = class("PixelEffect", Object, {
	shader = nil,
	effect = nil,
	-- 成员方法
	initialize = function (this, sl)
		this.shader = sl;
		this.effect = lg.newPixelEffect(this.shader);
	end,
	recreate = function (this)
		this.effect = lg.newPixelEffect(this.shader);
	end,
});


-- 绘制管理器
local Graphics = class("Graphics", Object, 
{
	--列表
	images = nil,
	canvas = nil,
	pixeleffect = nil,
	sprites = nil,
	particleSystems = nil,
	quads = nil,
	fonts = Font:new("font"),
	--枚举
	drawtype = {
		image = 0,
		canvas = 1,
		sprite = 2,
		particleSystem = 3,
	},
});

function Graphics:initialize(...)
	self.images = {};
	self.canvas = {};
	self.pixeleffect = {};
	self.sprites = {};
	self.particleSystems = {};
	self.quads = {};
end

function Graphics:createRes(res)
	local pixeleffect = res.pixeleffect or {};
	self:createPixelEffectsFromPath(pixeleffect);
	
	local pixeleffect_plus = res.pixeleffect_plus or {};
	self:createPixelEffectsFromPathPlus(pixeleffect_plus);

	local image = res.image or {};
	self:createImagesFromPath(image);
	
	local image_plus = res.image_plus or {};
	self:createImagesFromPathPlus(image_plus);
	
	local canvas = res.canvas or {};
	self:createCanvases(canvas);
	
	local font = res.font or {};
	self:createFonts(font);
end

----------------------------------------------------------------
-- 创建区域
function Graphics:createQuad(idx, x, y, width, height, sw, sh)
	if self.quads[idx]==nil then
		self.quads[idx] = lg.newQuad(x, y, width, height, sw, sh);
	end
end

function Graphics:getQuad(idx)
	return self.quads[idx];
end

function Graphics:deleteQuad(idx)
	self.quads[idx] = nil;
end

----------------------------------------------------------------
-- 获取相同路径的图片（可以用来确认图片是否已经加载成功）
function Graphics:getSamePathImage(path)
	if path==nil then				--path为nil是没有意义的
		return nil;
	end
	
	for i,v in pairs(self.images) do
		if path==v.path then
			return v;
		end
	end
	return nil;
end

-- 读取一张图片
function Graphics:createImageFromPath(idx, path)
	self.images[idx] = self:getSamePathImage(path);	--确保同一个文件内存中只有一份
	if self.images[idx]==nil then
		self.images[idx] = Image:new();
		self.images[idx].path = path;
		self.images[idx].img = lg.newImage(path);
	end
	
	if self.images[idx].img==nil then
		self.images[idx] = nil;
		return false;
	end
	return true;
end

-- 通过数据流(binary or base64)创建一张图片
function Graphics:createImageFromStream(idx, data, decoder)
	if decoder==nil then
		decoder = "file";
	end
	local fd = lf.newFileData(data, idx, decoder);
	local id = li.newImageData(fd);
	
	self.images[idx] = Image:new();
	self.images[idx].img = lg.newImage(id);
	
	if self.images[idx].img==nil then
		self.images[idx] = nil;
		return false;
	end
	return true;
end

-- 读取一张图片（使用lua的filesystem读取，
-- 支持相对路径和全路径，在需要包外资源时使用之）
function Graphics:createImageFromPathPlus(idx, path)
	local imgfile = assert(io.open(path, "rb")); 
	local data = imgfile:read("*all");
	imgfile:close();
	
	self:createImageFromStream(idx, data, "file");
	data = nil;
	
	return self.images[idx]~=nil;
end

-- 通过画布创建一张图片
function Graphics:createImageFromCanvas(idx, canvas)
	self.images[idx] = Image:new();
	self.images[idx].img = lg.newImage(canvas:getImageData());
end

-- 通过画布索引（同处于一个Graphics实例中）创建一张图片
function Graphics:createImageFromCanvas(idx, canvas_idx)
	self.images[idx] = Image:new();
	self.images[idx].img = lg.newImage(self.canvas[canvas_idx]:getImageData());
end

-- 获得图片尺寸
function Graphics:getImageSize(idx)
	if self.images[idx]==nil then
		return nil, nil;
	end
	return self.images[idx].img:getWidth(), self.images[idx].img:getHeight();
end

-- 返回图片
function Graphics:getImage(idx)
	local image = self.images[idx];
	if image==nil then
		return nil;
	end
	return image.img;
end

-- 图片转换为画布(画布没有纳入Graphics管理)
function Graphics:image2Canvas(idx)
	local image = self:getImage(idx);
	if image==nil then
		return nil;
	end
	local iw, ih = image:getWidth(), image:getHeight();
	local cv = lg.newCanvas(iw, ih);
	local prev_target = lg.getCanvas();
	
	cv:clear({0,0,0,0});
	lg.setCanvas(cv);
	lg.draw(image,0,0);
	lg.setCanvas(prev_target);
	return cv;
end

-- 删除图片
function Graphics:deleteImage(idx)
	self.images[idx] = nil;
end

-- 裁剪图片
function Graphics:clipImage(idx, sx, sy, width, height)
	return Graphics.clipDrawable(self:getImage(idx), sx, sy, width, height);
end

-- 读取图片资源表
function Graphics:createImagesFromPath(res)
	for i, v in pairs(res) do
		self:createImageFromPath(i, v);
	end
end

-- 读取图片资源表plus
function Graphics:createImagesFromPathPlus(res)
	for i, v in pairs(res) do
		self:createImageFromPathPlus(i, v);
	end
end

----------------------------------------------------------------
-- 创建画布
function Graphics:createCanvas(idx, width, height)
	self.canvas[idx] = Canvas:new(width, height);
	return true;
end

-- 创建画布
function Graphics:createCanvas(idx, cv)
	self.canvas[idx] = Canvas:new(cv);
	return true;
end

-- 返回画布
function Graphics:getCanvas(idx)
	local cv = self.canvas[idx];
	if cv==nil then
		return nil;
	end
	return cv.canvas;
end

-- 删除画布
function Graphics:deleteCanvas(idx)
	self.canvas[idx] = nil;
end

-- 获得画布尺寸
function Graphics:getCanvasSize(idx)
	if self.canvas[idx]==nil then
		return nil, nil;
	end
	return self.canvas[idx]:getSize();
end

-- 保存图片
function Graphics:saveCanvas(idx, out_file, ...)
	assert(type(out_file)=="string", "out_file must be a string");
	local cv = self:getCanvas(idx);
	assert(cv~=nil, "\""..idx.."\" this canvas is not exist");
	self.encodeCanvas(cv, out_file, ...);
end

-- 裁剪图片
function Graphics:clipCanvas(idx, sx, sy, width, height)
	return Graphics.clipDrawable(self:getCanvas(idx), sx, sy, width, height);
end

-- 编码画布
function Graphics.encodeCanvas(cv, ...)
	assert(cv~=nil, "cv must not be nil");
	local imagedata = cv:getImageData();
	imagedata:encode(...);
end

function Graphics.clipDrawable(drawable, sx, sy, width, height)
	if drawable==nil then
		return nil;
	end

	local cv = lg.newCanvas(width, height);
	local quad = lg.newQuad(sx, sy, width, height, 
							drawable:getWidth(), 
							drawable:getHeight())
	local prev_target = lg.getCanvas();
	
	cv:clear();
	lg.setCanvas(cv);
	lg.setColor({255,255,255});
	lg.drawq(drawable, quad, 0, 0);
	lg.setCanvas(prev_target);
	
	return cv;
end

-- 创建canvas
function Graphics:createCanvases(res)
	for i, v in pairs(res) do
		self:createCanvas(i, unpack(v));
	end
end

----------------------------------------------------------------
-- 创建PixelEffect
function Graphics:createPixelEffect(idx, sl)
	self.pixeleffect[idx] = PixelEffect:new(sl);
	return true;
end

-- 从文件打开
function Graphics:createPixelEffectFromPath(idx, path)
	local slfile = assert(lf.newFile(path));
	
	slfile:open("r");
	local data = slfile:read();
	slfile:close();
	
	self:createPixelEffect(idx, data);
	data = nil;
	
	return self.pixeleffect[idx]~=nil;
end

-- 从文件打开
function Graphics:createPixelEffectFromPathPlus(idx, path)
	local slfile = assert(io.open(path, "rb")); 
	local data = slfile:read("*all");
	slfile:close();
	
	self:createPixelEffect(idx, data);
	data = nil;
	
	return self.pixeleffect[idx]~=nil;
end

-- 返回PixeEffect
function Graphics:getPixelEffect(idx)
	local pe = self.pixeleffect[idx];
	if pe==nil then
		return nil;
	end
	return pe.effect;
end

-- 读取PixeEffect资源表
function Graphics:createPixelEffectsFromPath(res)
	for i, v in pairs(res) do
		self:createPixelEffectFromPath(i, v);
	end
end

-- 读取PixeEffect资源表plus
function Graphics:createPixelEffectsFromPathPlus(res)
	for i, v in pairs(res) do
		self:createPixelEffectFromPathPlus(i, v);
	end
end

----------------------------------------------------------------
-- 截图工具
function Graphics.saveScreenshot(out_file, ...)
	assert(type(out_file)=="string", "out_file must be a string");
	local imagedata = lg.newScreenshot();
	imagedata:encode(out_file, ...);
end

----------------------------------------------------------------
-- 创建精灵(图片必须已经创建，并且在同一个对象内)
function Graphics:createSprite(idx, image_idx, count)
	assert(self.images[image_idx]~=nil, image_idx.." is not image");
	self.sprites[idx] = lg.newSpriteBatch(self.images[image_idx], count);
end

-- 添加精灵
function Graphics:spriteAdd(idx, x, y, r, sx, sy, ox, oy)
	assert(self.sprites[idx]~=nil, idx.." is not sprite");
	self.sprites[idx]:add(x, y, r, sx, sy, ox, oy);
end

function Graphics:spriteAddq(idx, quad_idx, x, y, r, sx, sy, ox, oy)
	assert(self.sprites[idx]~=nil, idx.." is not sprite");
	assert(self.quads[quad_idx]~=nil, quad_idx.." is not quad");
	self.sprites[idx]:addq(self.quads[quad_idx], x, y, r, sx, sy, ox, oy);
end

-- 清理精灵
function Graphics:spriteClear(idx)
	assert(self.sprites[idx]~=nil, idx.." is not sprite");
	self.sprites[idx]:clear();
end

-- 改变图片
function Graphics:spriteChangeImage(idx, image_idx)
	assert(self.images[image_idx]~=nil, image_idx.." is not image");
	assert(self.sprites[idx]~=nil, idx.." is not sprite");
	self.sprites[idx]:setImage(self.images[image_idx]);
end

-- 返回精灵
function Graphics:getSprite(idx)
	return self.sprites[idx];
end

-- 删除精灵
function Graphics:deleteSprite(idx)
	self.sprites[idx] = nil;
end

----------------------------------------------------------------
-- 创建粒子系统
function Graphics:createParticleSystem(idx, image_idx, count)
	assert(self.images[image_idx]~=nil, image_idx.." is not image");
	self.particleSystems[idx] = lg.newParticleSystem(self.images[image_idx].img, count);
end

-- 返回粒子系统
function Graphics:getParticleSystem(idx)
	return self.particleSystems[idx];	
end

-- 删除粒子系统
function Graphics:deleteParticleSystem(idx)
	self.particleSystems[idx] = nil;
end

----------------------------------------------------------------
-- 创建字体
function Graphics:createFontFromPath(idx, path, size)
	self.fonts:createFontFromPath(idx, path, size);
end

function Graphics:createFontFromSize(idx, size)
	self.fonts:createFontFromSize(idx, size);
end

function Graphics:createFontFromPathPlus(idx, path, size)
	self.fonts:createFontFromPathPlus(idx, path, size);
end

-- 返回字体
function Graphics:getFont(idx)
	return self.fonts:getFont(idx);
end

-- 设置字体
function Graphics:setFont(idx)
	self.fonts:setFont(idx);
end

-- 创建字体表
function Graphics:createFonts(res)
	for i, v in pairs(res) do
		self:createFontFromPath(i, unpack(v));
	end
end

----------------------------------------------------------------
-- 直接获取love.graphics的方法
-- (同名后缀加"_")

-- 绘制方法
Graphics._clear = lg.clear;
Graphics._circle = lg.circle;
Graphics._line = lg.line;
Graphics._point = lg.point;
Graphics._polygon = lg.polygon;
Graphics._print = lg.print;
Graphics._printf = lg.printf;
Graphics._quad = lg.quad;
Graphics._rectangle = lg.rectangle;
Graphics._triangle = lg.triangle;
Graphics._draw = lg.draw;
Graphics._drawq = lg.drawq;
-- 绘制目标
Graphics._getRenderTarget = lg.getRenderTarget;
Graphics._setRenderTarget = lg.setRenderTarget;
-- 混合模式
Graphics._getBlendMode = lg.getBlendMode;
Graphics._setBlendMode = lg.setBlendMode;
-- 颜色和颜色模式
Graphics._getColorMode = lg.getColorMode;
Graphics._setColorMode = lg.setColorMode;
Graphics._getColor = lg.getColor;
Graphics._setColor = lg.setColor;
-- 视口大小
Graphics._getWidth = lg.getWidth;
Graphics._getHeight = lg.getHeight;
-- 背景颜色相关
Graphics._getBackgroundColor = lg.getBackgroundColor;
Graphics._setBackgroundColor = lg.setBackgroundColor;
-- 裁剪区相关
Graphics._getScissor = lg.getScissor;
Graphics._setScissor = lg.setScissor;
-- 保存和读取当前转换
Graphics._push = lg.push;
Graphics._pop = lg.pop;
-- 转换
Graphics._rotate = lg.rotate;
Graphics._scale = lg.scale;
Graphics._translate = lg.translate;
Graphics._reset = lg.reset;

----------------------------------------------------------------

function Graphics.rectangle(mode, rect)
	lg.rectangle(mode, rect.x, rect.y, rect.width, rect.height);
end

-- 切合渲染目标
function Graphics:setCanvas(canvas_idx)
	if canvas_idx==nil then
		lg.setCanvas();
	else
		local canvas = self:getCanvas(canvas_idx);
		assert(canvas~=nil, "the canvas of \""..canvas_idx.."\" is not exist");
		lg.setCanvas(canvas);
	end
end

-- 设置pixeleffect
function Graphics:setPixelEffect(pixeleffect_idx)
	if pixeleffect_idx==nil then
		lg.setPixelEffect();
	else
		local pixeleffect = self:getPixelEffect(pixeleffect_idx);
		assert(pixeleffect~=nil, "the pixeleffect of \""..pixeleffect_idx.."\" is not exist");
		lg.setPixelEffect(pixeleffect);
	end
end

-- 应用效果
function Graphics:EffectDrawer(draw_object, effect_idx)
	local iw, ih = draw_object:getWidth(), draw_object:getHeight();
	local cv = lg.newCanvas(iw, ih);
	local prev_target = lg.getCanvas();
	
	cv:clear({0,0,0,0});
	lg.setCanvas(cv);
	self:setPixelEffect(effect_idx);
	lg.draw(draw_object,0,0);
	self:setPixelEffect();
	lg.setCanvas(prev_target);
	return cv;
end

-- 绘制
function Graphics:drawImage(idx, x, y, r, sx, sy, ox, oy, kx, ky)
	local img = self:getImage(idx);
	assert(img~=nil, idx.." is not image");
	lg.draw(img, x, y, r, sx, sy, ox, oy, kx, ky);
end

function Graphics:drawCanvas(idx, x, y, r, sx, sy, ox, oy, kx, ky)
	local canvas = self:getCanvas(idx);
	assert(canvas~=nil, idx.." is not canvas");
	lg.draw(canvas, x, y, r, sx, sy, ox, oy, kx, ky);
end

function Graphics:drawSprite(idx, x, y, r, sx, sy, ox, oy, kx, ky)
	local sprite = self:getSprite(idx);
	assert(sprite~=nil, idx.." is not sprite");
	lg.draw(sprite, x, y, r, sx, sy, ox, oy, kx, ky);
end

function Graphics:drawParticleSystem(idx, x, y, r, sx, sy, ox, oy, kx, ky)
	local ps = self:getParticleSystem(idx);
	assert(ps~=nil, idx.." is not particleSystems");
	lg.draw(ps, x, y, r, sx, sy, ox, oy, kx, ky);
end

-- 绘制 t为Graphics.drawtype
function Graphics:draw(t, idx, x, y, r, sx, sy, ox, oy, kx, ky)
	if t==self.drawtype.image then
		self:drawImage(idx, x, y, r, sx, sy, ox, oy, kx, ky);
	elseif t==self.drawtype.canvas then
		self:drawCanvas(idx, x, y, r, sx, sy, ox, oy, kx, ky);
	elseif t==self.drawtype.sprite then
		self:drawSprite(idx, x, y, r, sx, sy, ox, oy, kx, ky);
	elseif t==self.drawtype.particleSystem then
		self:drawParticleSystem(idx, x, y, r, sx, sy, ox, oy, kx, ky);
	else
		error("unknown type");
	end
end

function Graphics:drawqImage(idx, quad_idx, x, y, r, sx, sy, ox, oy, kx, ky)
	local img = self:getImage(idx);
	assert(img~=nil, idx.." is not image");
	local quad = self:getQuad(quad_idx);
	assert(quad~=nil, quad_idx.." is not quad");
	lg.drawq(img, quad, 
		x, y, r, sx, sy, ox, oy, kx, ky);
end

function Graphics:drawqCanvas(idx, quad_idx, x, y, r, sx, sy, ox, oy, kx, ky)
	local canvas = self:getCanvas(idx);
	assert(canvas~=nil, idx.." is not image");
	local quad = self:getQuad(quad_idx);
	assert(quad~=nil, quad_idx.." is not quad");
	lg.drawq(canvas, quad, 
		x, y, r, sx, sy, ox, oy, kx, ky);
end

function Graphics:drawqSprite(idx, quad_idx, x, y, r, sx, sy, ox, oy, kx, ky)
	local sprite = self:getSprite(idx);
	assert(sprite~=nil, idx.." is not image");
	local quad = self:getQuad(quad_idx);
	assert(quad~=nil, quad_idx.." is not quad");
	lg.drawq(sprite, quad, 
		x, y, r, sx, sy, ox, oy, kx, ky);
end

function Graphics:drawqParticleSystem(idx, quad_idx, x, y, r, sx, sy, ox, oy, kx, ky)
	local ps = self:getParticleSystem(idx);
	assert(ps~=nil, idx.." is not image");
	local quad = self:getQuad(quad_idx);
	assert(quad~=nil, quad_idx.." is not quad");
	lg.drawq(ps, quad, 
		x, y, r, sx, sy, ox, oy, kx, ky);
end

-- 绘制 t为Graphics.drawtype
function Graphics:drawq(t, idx, quad_idx, x, y, r, sx, sy, ox, oy, kx, ky)
	if t==self.drawtype.image then
		self:drawqImage(idx, quad_idx, x, y, r, sx, sy, ox, oy, kx, ky);
	elseif t==self.drawtype.canvas then
		self:drawqCanvas(idx, quad_idx, x, y, r, sx, sy, ox, oy, kx, ky);
	elseif t==self.drawtype.sprite then
		self:drawqSprite(idx, quad_idx, x, y, r, sx, sy, ox, oy, kx, ky);
	elseif t==self.drawtype.particleSystem then
		self:drawqParticleSystem(idx, quad_idx, x, y, r, sx, sy, ox, oy, kx, ky);
	else
		error("unknown type");
	end
end

return Graphics;
