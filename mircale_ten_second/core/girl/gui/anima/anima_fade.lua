
----------------------------------------------------------------
-- write by xerysherry

-- 得到需要的类
local AE = getClass("Object.GUIAnimaEffect");
local ModeEnum = AE.ModeEnum;

----------------------------------------------------------------
-- 淡入淡出动画效果
local Fade = class("Fade", AE,
{
	_maxframe = 10,
});

-- 参数: 总帧数(10)
function Fade:onSetParam(mf)
	if type(mf)=="number" then
		self._maxframe = mf;
	else
		self._maxframe = 10;
	end
end

function Fade:onEffect(gui)
	if gui==nil or gui.graph==nil then
		return false;
	end
	
	local alpha = gui.alpha;
	if self.mode==ModeEnum.close then
		alpha = (alpha/self._maxframe)*(self._maxframe-self._current-1);
	else
		alpha = (alpha/self._maxframe)*(self._current+1);
	end
	gui.graph._setColor({255,255,255,alpha});
	gui.graph:drawCanvas(gui.cv, gui.rect.x, gui.rect.y);
	return true;
end
