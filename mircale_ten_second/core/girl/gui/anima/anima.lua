
----------------------------------------------------------------
-- write by xerysherry

-- 得到需要的类
local Object = getClass("Object");

----------------------------------------------------------------
-- GUI动画效果基础类
local AnimaEffect = class("GUIAnimaEffect", Object,
{
	ModeEnum = {
		noanima = 0,
		open = 1,
		close = 2,
	},
	
	_current = 0,
	_maxframe = 0,
	mode = 0,
	
	onSetParam = function (this, ...) end,
	onEffect = function (this, gui) return true end,
});

function AnimaEffect:setMaxframe(mf)
	self._maxframe = mf;
end

function AnimaEffect:setMode(mode)
	if mode==nil then
		self.mode = 0;
	else
		self.mode = mode;
	end
end

function AnimaEffect:setParam(...)
	self:onSetParam(...);
end

function AnimaEffect:getMode(mode)
	return self.mode;
end

function AnimaEffect:restart()
	self._current = 0;
end

function AnimaEffect:effect(gui)
	if self._current>=self._maxframe or mode==0 then
		return false;
	end
	if self:onEffect(gui) then
		self._current = self._current + 1;
		return true;
	end
	return false;
end
