----------------------------------------------------------------
-- write by xerysherry

local lm = love.mouse;

-- 得到基类
local Object = getClass("Object");
local Gui = getClass("Object.Gui");

-- Gui管理器（比较简单）
local GuiManager = class("GuiManager", Object,
{
	focus = nil,			-- 焦点，最后一次点击的GUI
	guilist = nil,
	grab = false,			-- 抓住状态，鼠标按下抬起之间为true
	modalmode = false,		-- 模态模式，只能响应定制的窗口
	autotop = false,		-- 自动提前
});

function GuiManager:initialize()
	self.guilist = {};
end

function GuiManager:getGui(name)
	if name==nil then
		return nil;
	end
	for i, v in pairs(self.guilist) do
		if v.name==name then
			return v.gui;
		end
	end
	return nil;
end

function GuiManager:add(name, gui)
	assert(name~=nil, "The name can't be nil.");
	assert(gui~=nil, "The gui can't be nil.");
	assert(tostring(gui)=="Object.Gui.Instance", "this isn't Object.Gui");
	assert(self:getGui(name)==nil, "this name is used.");
	table.insert(self.guilist, 
		{["name"]=name, ["gui"]=gui});
end

function GuiManager:del(g)
	local index = self:find(g);
	if index~=nil then
		local gui = self.guilist[index];
		table.remove(self.guilist, index);
	end
end

function GuiManager:find(g)
	if tostring(g)==Gui:getName()..".Instance" then
		for i, v in pairs(self.guilist) do
			if v.gui==g then
				return i;
			end
		end
	else
		for i, v in pairs(self.guilist) do
			if v.name==g then
				return i;
			end
		end
	end
	return nil;
end

function GuiManager:enableModalmode(e)
	if e~=nil then
		self.modalmode = e;
	else
		self.modalmode = true;
	end
end

function GuiManager:open(name, ...)
	local gui = self:getGui(name);
	assert(gui~=nil, "\""..name.."\" , this gui not exist");
	gui:open(...);
end

function GuiManager:close(name, ...)
	local gui = self:getGui(name);
	assert(gui~=nil, "\""..name.."\" , this gui not exist");
	gui:close(...);
	if self.focus==gui then
		self.focus=nil;
	end
end

-- 顶置GUI
function GuiManager:topMost(g)
	local index = self:find(g);
	if index~=nil then
		local gui = self.guilist[index];
		table.remove(self.guilist, index);
		table.insert(self.guilist, gui);
	end
end

-- 交换GUI位置
function GuiManager:switch(g1, g2)
	local index1 = self:find(g1);
	local index2 = self:find(g2);
	
	if index1~=nil and index2~=nil then
		local tmp = self.guilist[index1];
		self.guilist[index1] = self.guilist[index2];
		self.guilist[index2] = tmp;
	end
end

function GuiManager:clear()
	self.guilist = {};
end

-- 设置多窗口焦点
function GuiManager:setFocus(name)
	if name==nil then
		self.focus = nil;
	else
		self.focus = self:getGui(name);
	end
end

function GuiManager:tic(dt)
	for i, v in pairs(self.guilist) do
		v.gui:tic(dt);
	end
end

function GuiManager:mousemove(x,y)
	if self.modalmode then
		local gs = self.guilist[table.maxn(self.guilist)];
		if gs then
			return gs.gui:mousemove(x, y);
		end
	else
		if self.grab then
			if self.focus then
				return self.focus:mousemove(x, y);
			end
		else
			local len = table.maxn(self.guilist);
			for i=len, 1, -1 do
				if self.guilist[i].gui:mousemove(x, y) then
					return true;
				end
			end
		end
	end
	return false;
end

-- Gui对应的方法
function GuiManager:mousepressed(x, y, button)
	local lastfocus = self.focus;
	local result = false;
	
	self.focus = nil;
	if self.modalmode then
		local gs = self.guilist[table.maxn(self.guilist)];
		if gs then
			if gs.gui:mousepressed(x, y, button) then
				result = true;
				self.focus = gs.gui;
				self.grab = true;
			end
		end
	else
		local len = table.maxn(self.guilist);
		for i=len, 1, -1 do
			local gui = self.guilist[i].gui;
			-- 显示和点击检测
			if gui.show and IsPointIn(x, y, gui.rect) then
				if gui:mousepressed(x, y, button) then
					result = true;
					self.focus = gui;
					self.grab = true;
					if self.autotop then
						if self.guilist[#self.guilist]~=gui then
							self:topMost(gui);
						end
					end
				end
				break;
			end
		end
	end
	
	if self.focus~=lastfocus then
		-- 没焦点GUI，也去掉GUI内部的VIEW焦点
		for i, v in pairs(self.guilist) do
			if v.gui~=self.focus then
				v.gui:setFocus(nil);
			end
		end
	end
	return result;
end

function GuiManager:mousereleased(x, y, button)
	self.grab = false;
	if self.focus then
		return self.focus:mousereleased(x, y, button)
	end
	return false;
end

function GuiManager:keypressed(key, unicode)
	if self.focus~=nil then
		self.focus:keypressed(key, unicode);
	end
end

function GuiManager:keyreleased(key)
	if self.focus~=nil then
		self.focus:keyreleased(key, unicode);
	end
end

function GuiManager:joystickpressed(joystick, button)
	if self.focus~=nil then
		self.focus:joystickpressed(joystick, button);
	end
end

function GuiManager:joystickreleased(joystick, button)
	if self.focus~=nil then
		self.focus:joystickreleased(joystick, button);
	end
end

function GuiManager:update(dt)
	local x, y = lm.getX(), lm.getY();
	self:mousemove(x,y);
	self:tic(dt);
end

function GuiManager:draw()
	for i, v in pairs(self.guilist) do
		v.gui:draw();
	end
end

return GuiManager;
