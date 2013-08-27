-- AI

-- 得到基类
local MTS = getClass("Object.MTS");

local AI = class("AI", MTS,
{
	players = nil,
	robots = nil,
	link = nil,
	ball = nil,
	tic1 = .5,
	tic2 = .2,
});

function AI:initialize()
	self.players = {};
	self.robots = {};
	self.link = {};
end

function AI:addPlayer(player)
	table.insert(self.players, player);
end

function AI:addRobot(robot)
	table.insert(self.robots, robot);
end

function AI:setBall(ball)
	self.ball = ball;
end

function AI:clear()
	self.players={};
	self.robots={};
	self.link={};
	self.tic1=.5;
	self.tic2=.2;
end

function AI:update(dt)
	self.tic1 = self.tic1+dt;
	if self.tic1>.2 then
		self.tic1 = 0;
		self:updateLink();
	end
	self.tic2 = self.tic2+dt;
	if self.tic2>.1 then
		self.tic2 = 0;
		self:actionLink();
	end
end

function AI:updateLink()
	for ri, rv in ipairs(self.robots) do
		local p=0;
		local idx=0;
		
		for pi, pv in ipairs(self.players) do
			local tp=1;
			if pv.ball~=nil then
				tp=tp*(3/PointDist(pv.locx, pv.locy, 15/2, 1.57));
				if pv.role==rv.rolve then
					tp=tp*1.5;
				end
			else
				tp=tp*(1/PointDist(pv.locx, pv.locy, rv.locx, rv.locy));
				if pv.role==rv.rolve then
					tp=tp*2;
				end
			end
			
			if pv.role==rv.rolve then
				tp=tp*1.5;
			end
			
			if tp>p then
				idx = pi;
				p = tp;
			end
		end
		if self.ball.player==nil then
			local tp=2/PointDist(self.ball.locx, self.ball.locy, 
								rv.locx, rv.locy);
			if tp>p then
				idx = 0;
				p = tp;
			end
		end	
		self.link[ri] = idx;
	end
end

function AI:catchball(r)
	r:setTarget(self.ball.locx, self.ball.locy);
end

function AI:action(p, r)
	local basket = {15/2, 1.57};
	local dx=p.locx-basket[1];
	local dy=p.locy-basket[2];
	local dist = math.sqrt(dx*dx+dy*dy);
	local sina = math.sin(dx/dist);
	local sinb = math.sin(dy/dist);
	r:setTarget(p.locx-sina*1,
				p.locy-sinb*1);
end

function AI:actionLink()
	local basket = {15/2, 1.57};
	for i, v in ipairs(self.link) do
		local p = self.players[v];
		local r = self.robots[i];
		if p~=nil then
			self:action(p, r);
		else
			if v==0 then
				self:catchball(r);
			end
		end
	end
end
