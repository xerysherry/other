
----------------------------------------------------------------
-- write by xerysherry

-- 得到需要的类
local AE = getClass("Object.GUIAnimaEffect");
local ModeEnum = AE.ModeEnum;

local Rect = getClass("Object.Rect");
local graph = getClass("Object.Graphics");

----------------------------------------------------------------
-- 缩放动画效果
local Zoom = class("Zoom", AE,
{
	_maxframe = 15,
	
	-- 是存在淡入淡出效果
	_fade = false,
	-- 缩放的位置
	_rect = nil,
});

function Zoom:initialize()
	self._rect = Rect();
end

-- 参数: 缩放目标(左下角), 是否伴随着淡入淡出(false), 总帧数(15)
function Zoom:onSetParam(rect, fade, mf)
	if rect==nil then
		local wh = graph._getHeight();
		self._rect:setRect(0,wh-20,20,20);
	else
		self._rect:setRect(rect.x, rect.y, rect.width, rect.height);
	end

	if fade==nil then
		self._fade = false;
	else
		self._fade = fade;
	end
	
	if type(mf)=="number" then
		self._maxframe = mf;
	else
		self._maxframe = 15;
	end
end

function Zoom:onEffect(gui)
	if gui==nil or gui.graph==nil then
		return false;
	end
	
	local gx, gy, gw, gh = gui.rect:getRect();
	local zx, zy, zw, zh = self._rect:getRect();
	local alpha = gui.alpha;
	
	local asp = 0;
	if self.mode==ModeEnum.close then
		asp = (self._maxframe-self._current-1)/self._maxframe;
	else
		asp = (self._current+1)/self._maxframe;
	end
	
	if self._fade then
		alpha = alpha*asp;
	end
	local ax, ay, aw, ah = 
		(gx-zx)*asp+zx,
		(gy-zy)*asp+zy,
		(gw-zw)*asp+zw,
		(gh-zh)*asp+zh;

	gui.graph._setColor({255,255,255,alpha});
	gui.graph:drawCanvas(gui.cv, ax, ay, 0, aw/gw, ah/gh);
	return true;
end
