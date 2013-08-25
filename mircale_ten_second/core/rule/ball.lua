-- ball

-- 得到基类
local MTS = getClass("Object.MTS");

local Ball = class("Ball", MTS, 
{
	locx = 0, 
	locy = 0,
	
	speed = 14,
	
	last_player = nil,
	player = nil,
	
	tic = 0,
	out = false,
});

function Ball:initialize() end

function Ball:reset()
	self.target = nil;
	self._sx = nil;
	self._sy = nil;
	self.player = nil;
	self.last_player = nil;
	self.out = false;
end

function Ball:update(dt)
	if self.out then
		return;
	end

	self:_move(dt);
	
	if self.player==nil and self.last_player~=nil then
		self.tic = self.tic+dt;
		if self.tic>1 then
			self.last_player=nil;
		end
	end
end

function Ball:_move(dt)
	if self._sx then
		self.locx = self.locx+(self._sx or 0)*dt;
		self.locy = self.locy+(self._sy or 0)*dt;
	end
	
	if self.locx < 0 or self.locx > 15 or 
		self.locy < 0 or self.locy > 28 then
		self.out = true;
		self:catch();
	end
end

function Ball:setDirection(x, y)
	local dx = x-self.locx;
	local dy = y-self.locy;
	local dist = math.sqrt(dx*dx+dy*dy);
	
	local speed = dist*10;
	if speed > self.speed then
		speed = self.speed;
	elseif speed < 5 then
		speed = 5;
	end
	
	self._sx = math.sin(dx/dist)*speed;
	self._sy = math.sin(dy/dist)*speed;
	if self.player~=nil then
		self.last_player = self.player;
	end
	self.player = nil;
	self.tic = 0;
end

function Ball:catch(player)
	self.target = nil;
	self._sx = nil;
	self._sy = nil;
	self.player = player;
	self.last_player = nil;
end