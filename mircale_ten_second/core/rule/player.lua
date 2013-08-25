-- Player

local lg = love.graphics;

-- 得到基类
local MTS = getClass("Object.MTS");

local eRole = {
	F = "F",		-- 前锋 移动一般，命中率低于后卫，但是抗中锋能力强
	G = "G",		-- 后卫 移动最快，中圈及3分线外命中率高，中锋面前容易被盖帽
	C = "C",		-- 中锋 移动最慢，篮下命中率高，灌篮是100%命中
};

-- 声明
local Player = class("Player", MTS,
{
	-- 标识
	tid = 0,
	pid = 0,
	
	r = 12,
	
	role = eRole.G,
	speed = 7,
	defend = .8,
	shota = 3,
	
	locx = 0,
	locy = 0,
	
	tic = 0,
	
	-- 移动目标
	target = nil,
	
	ball = nil,
});

function Player:initialize(tid, pid, role) 
	self.tid = tid or 0;
	self.pid = pid or 0;
	self:setRole(role);
end

function Player:setRole(role)
	self.role = role or eRole.G;
	if self.role==eRole.G then
		self.speed = 7;
		self.defend = .8;
		self.shota = 3;
	elseif self.role==eRole.F then
		self.speed = 6;
		self.defend = 1;
		self.shota = 2.5;
	elseif self.role==eRole.C then
		self.speed = 5;
		self.defend = 1.2;
		self.shota = 2;
	end
end

function Player:catch(ball)
	self.ball = ball;
	if self.ball==nil then
		return;
	end
	self.ball:catch(self);
	self.ball.locx = self.locx;
	self.ball.locy = self.locy;
end

function Player:pass(x, y)
	self.ball = nil;
end

function Player:update(dt)
	self.tic = self.tic+dt;
	if self.target~=nil then
		self:_move(dt);
	else
		self.tic = 0;
	end
end

function Player:_move(dt)
	local tx = self.target[1];
	local ty = self.target[2];
	dist = self.speed*dt;
	if dist < self.dist then
		self.locx = self.locx+self._sina*dist;
		self.locy = self.locy+self._sinb*dist;
		self:_updatespeed();
	else
		self.locx = tx;
		self.locy = ty;
		self.target = nil;
		self.dist = 0;
	end
	if self.locx < 0 then
		self.locx = 0;
	elseif self.locx > 15 then
		self.locx = 15;
	end
	if self.locy < 0 then
		self.locy = 0;
	elseif self.locy > 28 then
		self.locy = 28;
	end
	if self.ball~=nil then
		self.ball.locx = self.locx;
		self.ball.locy = self.locy;
	end
end

function Player:_updatespeed()
	local dx = self.target[1]-self.locx;
	local dy = self.target[2]-self.locy;
	self.dist = math.sqrt(dx*dx+dy*dy);
	self._sina = math.sin(dx/self.dist);
	self._sinb = math.sin(dy/self.dist);
end

function Player:setTarget(x, y)
	if x==nil then
		self.target = nil;
	end
	
	self.target = {x, y or 0};
	self:_updatespeed();
end


