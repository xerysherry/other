-- Field

local lg = love.graphics;
local lfs = love.filesystem;

-- 得到基类
local MTS = getClass("Object.MTS");
local Graphics = MTS.graphics;

local Mouse = getClass("Object.Mouse");
local Player = getClass("Object.MTS.Player");
local Shot = getClass("Object.MTS.Shot");
local Ball = getClass("Object.MTS.Ball");
local AI = getClass("Object.MTS.AI");

local PI = 3.1415927

local ePlayer = {
	Human = 0,
	Robot = 1,
};

local eOp = {
	None = 0,
	Move = 1,
	Pass = 2,
	Shot = 3,
};

-- 声明
local Field = class("Field", MTS,
{
	line_color = {255, 255, 255},
	ground_color = {255, 150, 0},
	target_color = {150, 150, 150},
	timer_color = {200, 0, 0},

	locx = 0,
	locy = 0,
	scale = 35,
	show = false,
	editmode = false,
	
	select_player = nil,
	select_ball = false,
	opmode = 0,
	shot_flag = false,
	stage = "",
	
	failure = false,
	success = false;
	
	--抓住状态
	grab = false,
	
	-- 外场
	width = 15,
	height = 28,

	-- 3分线
	three_point_r = 6.25,
	
	-- 罚球圈
	penalty_circle_r = 1.8,
	penalty_circle_dist = 5.8,
	
	-- 三秒区
	three_second_area_width = 6,
	
	-- 中心圆
	center_circle_r = 1.8,
	
	-- 篮筐
	-- 距离底线距离
	basket_dist = 1.57,
	basket_r = .45/2,
	
	-- 队伍颜色
	team_color = nil,
	
	-- 球员
	players = nil,
	
	-- 球
	ball = nil,
	
	-- AI
	ai = nil,
	
	-- 倒计时
	timer = 10,
	
	-- 暂停
	pause = true,
});

function Field:initialize()
	self.team_color = {
		-- 边框           填充色         标示
		{{255, 100, 50}, {134, 255, 0}, {255, 255,255}}
	};
	self.ai = AI();
	self.players = {};
	self.ball = Ball();
	self.ball.locx = self.width/2;
	self.ball.locy = self.height/2-5;
	
	local function MouseTest(x, y)
		if self.grab then
			return true;
		elseif x>=self.locx and x<self.locx+self.width*self.scale and
			y>=self.locy and y<self.locy+self.height*self.scale then
			return true;
		end
		return false;
	end
	
	self._mouse = Mouse();
	self._mouse.onMove = function (x, y)
		if MouseTest(x, y) then
			self:onMouseMove(x, y);
		end
	end
	self._mouse.onPressed = function(x, y, button)
		if MouseTest(x, y) then
			self:onMousePressed(x, y, button);
		end
	end 
	self._mouse.onReleased = function(x, y, button)
		if MouseTest(x, y) then
			self:onMouseReleased(x, y, button);
		end
	end 
	
	self._shot = Shot();
end

function Field:reset()
	self.ai:clear();
	self.players = {};
	self.shot_flag = false;
	self._shot:reset();
	self.timer = 10;
	self.ball:reset();
	self:setPause(true);
	self.failure = false;
	self.success = false;
end

function Field:restart()
	self:reset();
	self:setStage(self.stage);
end

function Field:shot()
	local player = nil;
	for _, v in ipairs(self.players) do
		if v.tid == ePlayer.Human and v.ball~=nil then
			player = v;
		end
	end
	if player==nil then
		return false;
	end
	
	self.shot_flag = true;
	self.pause = true;
end

function Field:setTeamColor(idx, border, fill, label)
	self.team_color[idx] = 
	{
		border or {255, 255, 255},
		fill or {0, 0, 0},
		label or {255, 255, 255},
	}
end

function Field:addPlayer(player)
	if player==nil then
		return;
	end
	table.insert(self.players, player);
end

function Field:removePlayer(player)
	if player==nil then
		return;
	end
	
	for i, v in ipairs(self.players) do
		if v==player then
			table.remove(self.players, i);
			break;
		end
	end
end

function Field:setBall()
	self.select_ball = true;
	
	for i, v in ipairs(self.players) do
		if v.ball then
			v:catch();
			return;
		end
	end
end

function Field:setPause(v)
	if v then
		self.pause = true;
	else
		self.pause = false;
	end
end

function Field:setShow(v)
	self.show = v;
end

function Field:setOp(v)
	self.opmode = v;
	if self.opmode~=eOp.Shot then
		return;
	end
	
	local difficult1 = 5-self.select_player.shota;
	local difficult2 = PointDist(self.select_player.locx, self.select_player.locy,
							self.width/2, self.basket_dist)*1.5 / self.select_player.shota;
	for i, v in ipairs(self.players) do
		if v.tid==1 then
			local dist=PointDist(v.locx, v.locy, 
				self.select_player.locx, self.select_player.locy);
			if dist<5 then
				difficult1=difficult1+(1.5-dist/4)*(v.defend/self.select_player.defend)*2;
			end
		end
	end
	
	--print(difficult1, difficult2);
	self._shot:setDifficult(difficult1, difficult2);
	self:shot();
	
end

function Field:setEditMode(v)
	self.editmode = v;
	if self.editmode then
		self:reset();
	end
end

function Field:setFailure()
	self.failure=true;
end

function Field:setSuccess()
	self.success=true;
end

function Field:save(name)
	local stage = {humans = {}, robots={}, ball={}};
	
	stage.ball[1]=nil;
	stage.ball[2]=nil;
	for i, v in ipairs(self.players) do
		local p = {};
		p[1]=v.role;
		p[2]=v.locx;
		p[3]=v.locy;

		if v.tid == 0 then
			table.insert(stage.humans, p);
			if v.ball~=nil then
				stage.ball[1]="human";
				stage.ball[2]=#stage.humans;
			end
		else
			table.insert(stage.robots, p);
			if v.ball~=nil then
				stage.ball[1]="robot";
				stage.ball[2]=#stage.humans;
			end
		end
	end
	
	if stage.ball[1]==nil then
		stage.ball[1] = self.ball.locx;
		stage.ball[2] = self.ball.locy;
	end
	
	local j=json.encode(stage);
	local f=lfs.newFile(name);
	f:open("w");
	f:write(j);
	f:close();
end

function Field:load(name)
	local f=love.filesystem.newFile(name);
	f:open("r");
	local j=f:read();
	f:close();
	
	local stage=json.decode(j);
	self:setStage(stage);
end

--[[
stage = {
	humans = {
		{"G", 10, 10},
		{"F", 10, 10},
		{"C", 10, 10},
	},
	robots = {
		{"G", 10, 10},
		{"F", 10, 10},
		{"C", 10, 10},
	},
	ball = {"human", 1, x, y}
}
]]
function Field:setStage(stage)
	local humans = stage.humans;
	local robots = stage.robots;
	local ball = stage.ball;
	self.stage = stage;
	
	if humans==nil or robots==nil or ball==nil then
		return false;
	end
	
	self:reset()
	
	for i, v in ipairs(humans) do
		local p = Player(ePlayer.Human, i, v[1]);
		p.locx = v[2];
		p.locy = v[3];
		self:addPlayer(p);
		self.ai:addPlayer(p);
	end
	
	for i, v in ipairs(robots) do
		local p = Player(ePlayer.Robot, i, v[1]);
		p.locx = v[2];
		p.locy = v[3];
		self:addPlayer(p);
		self.ai:addRobot(p);
	end
	
	if ball[1]=="human" then
		self.ai.players[ball[2]]:catch(self.ball);
	elseif ball[1]=="robot" then
		self.ai.robots[ball[2]]:catch(self.ball);
	else
		self.ball.locx = ball[1] or 0;
		self.ball.locy = ball[2] or 0;
	end
	self.ai:setBall(self.ball);
end

function Field:drawField()
	local width = self.width*self.scale;
	local height = self.height*self.scale;
	local center_circle_r = self.center_circle_r*self.scale;
	local penalty_circle_r = self.penalty_circle_r*self.scale;
	local penalty_circle_dist = self.penalty_circle_dist*self.scale;
	local three_second_area_width = self.three_second_area_width*self.scale;
	local basket_dist = self.basket_dist*self.scale;
	local basket_r = self.basket_r*self.scale;
	local three_point_r = self.three_point_r*self.scale;
	
	lg.setColor(self.ground_color);
	lg.rectangle("fill", 0, 0, width, height);
	
	lg.setColor(self.line_color);
	lg.rectangle("line", 0, 0, width, height);
	
	local w2rd = width/2;
	local h2rd = height/2;
	
		-- 三分线(暂时有问题)
	local w2rd_dtp = w2rd-three_point_r;
	local w2rd_atp = w2rd+three_point_r;
	local w2rd_dr = w2rd-penalty_circle_r;
	local w2rd_ar = w2rd+penalty_circle_r;
	local h2rd_dd = height-penalty_circle_dist;
	local h_db = height-basket_dist;
	lg.arc("fill", w2rd, basket_dist, three_point_r, 0, PI, 10*self.scale);
	lg.line(w2rd_dtp, 0, w2rd_dtp, basket_dist);
	lg.line(w2rd_atp, 0, w2rd_atp, basket_dist);
	
	lg.arc("fill", w2rd, h_db, three_point_r, 0, -PI, 10*self.scale);
	lg.line(w2rd_dtp, height, w2rd_dtp, h_db);
	lg.line(w2rd_atp, height, w2rd_atp, h_db);
	
	lg.setColor(self.ground_color);
	lg.arc("fill", w2rd, basket_dist, three_point_r-1, 0, PI, 10*self.scale);
	lg.arc("fill", w2rd, h_db, three_point_r-1, 0, -PI, 10*self.scale);
	
	lg.setColor(self.line_color);
	-- 中线
	lg.line(0, h2rd, width, h2rd);

	-- 中心圆
	lg.circle("line", w2rd, h2rd, center_circle_r, 10*self.scale);
	
	-- 罚球圈
	lg.circle("line", w2rd, penalty_circle_dist, penalty_circle_r, 10*self.scale);
	lg.line(w2rd_dr, penalty_circle_dist, 
			w2rd_ar, penalty_circle_dist);
	lg.circle("line", w2rd, h2rd_dd, penalty_circle_r, 10*self.scale);
	lg.line(w2rd_dr, h2rd_dd, w2rd_ar, h2rd_dd);
			
	-- 三秒区
	local w2rd_dts = w2rd-three_second_area_width/2;
	local w2rd_ats = w2rd+three_second_area_width/2;
	lg.line(w2rd_dts, 0, w2rd_dr, penalty_circle_dist);
	lg.line(w2rd_ats, 0, w2rd_ar, penalty_circle_dist);
	lg.line(w2rd_dts, 0, w2rd_dr, penalty_circle_dist);
	lg.line(w2rd_ats, 0, w2rd_ar, penalty_circle_dist);
	
	lg.line(w2rd_dts, height, w2rd_dr, h2rd_dd);
	lg.line(w2rd_ats, height, w2rd_ar, h2rd_dd);
	lg.line(w2rd_dts, height, w2rd_dr, h2rd_dd);
	lg.line(w2rd_ats, height, w2rd_ar, h2rd_dd);
	
	-- 篮筐
	
	lg.circle("line", w2rd, basket_dist, basket_r, 10*self.scale);
	lg.circle("line", w2rd, h_db, basket_r, 10*self.scale);
end

function Field:drawPlayers()
	Graphics:setFont("font10");
	for i, v in ipairs(self.players) do
		local locx = v.locx*self.scale;
		local locy = v.locy*self.scale;
		
		local target = v.target;
		if target~=nil then
			local tx = target[1]*self.scale;
			local ty = target[2]*self.scale;
			
			lg.setColor(self.target_color);
			lg.line(locx, locy, tx, ty);
			
			lg.print(math.ceil(v.dist/v.speed*10)/10 .."sec", tx, ty-12);
		end
		
		local teamc = self.team_color[v.tid];
		if teamc==nil then
			teamc = {{255, 255, 255}, {0, 0, 0}, {255, 255, 255}};
		end
		
		local border = 2;
		if v==self.select_player then
			border = 4;
		end
		
		lg.setColor(teamc[1]);
		lg.circle("fill", locx, locy, v.r, 20);
		lg.setColor(teamc[2]);
		lg.circle("fill", locx, locy, v.r-border, 20);
		lg.setColor(teamc[3]);
		lg.print(v.role, locx-v.r+7, locy-v.r+5);
	end
end

function Field:drawBall()
	local locx = self.ball.locx*self.scale;
	local locy = self.ball.locy*self.scale;
	
	lg.setColor(255, 255, 255);
	local ix, iy = Graphics:getImageSize("ball");
	Graphics:drawImage("ball", locx-ix/2, locy-ix/2);
	
	if self.ball._sx then
		lg.setColor(255, 0, 0);
		lg.line(locx, locy, 
			locx+self.ball._sx*5, locy+self.ball._sy*5);
	end
end

function Field:drawMap()
	local mapscale = 4;
	local width = self.width*mapscale;
	local height = self.height*mapscale;

	lg.push();
	lg.translate(550, 100);

	lg.setColor(self.ground_color);
	lg.rectangle("fill", 0, 0, width, height);
	
	lg.setColor(self.line_color);
	lg.rectangle("line", 0, 0, width, height);
	
	for i, v in ipairs(self.players) do
		local locx = v.locx*mapscale;
		local locy = v.locy*mapscale;
		local teamc = self.team_color[v.tid];
		if teamc==nil then
			teamc = {{255, 255, 255}, {0, 0, 0}, {255, 255, 255}};
		end
		
		lg.setColor(teamc[1]);
		lg.circle("fill", locx, locy, 5, 10);
		lg.setColor(teamc[2]);
		lg.circle("fill", locx, locy, 5-1, 10);
	end
	
	lg.pop();
end

function Field:drawTime()
	Graphics:setFont("font48");
	
	local sec = math.floor(self.timer);
	local msec = math.floor(self.timer*10) - sec*10;
	
	lg.setColor({255,255,255});
	lg.print(sec.."."..msec, 536, 1);
	lg.setColor(self.timer_color);
	lg.print(sec.."."..msec, 535, 0);
end

function Field:draw()
	if not self.show then
		return;
	end

	-- 变换
	lg.push();
	
	lg.translate(self.locx, self.locy);
	lg.setScissor(self.locx, self.locy, 
		self.width*self.scale, self.height*self.scale);
	
	--lg.scale(s, s);
	self:drawField();
	self:drawPlayers();
	
	lg.setScissor();
	self:drawBall();
	-- 变换
	lg.pop();
	
	self:drawTime();
	self:drawMap();
	
	if self.shot_flag then
		self._shot:draw();
	end
	
	if self.failure then
		Graphics:setFont("font48");
		lg.setColor(255, 255, 255);
		lg.print("CHALLENGE FAIL !", 51, 151);
		lg.setColor(255, 0, 0);
		lg.print("CHALLENGE FAIL !", 50, 150);
	elseif self.success then
		Graphics:setFont("font48");
		lg.setColor(255, 255, 255);
		lg.print("IT IS MIRCALE !!", 71, 151);
		lg.setColor(255, 0, 0);
		lg.print("IT IS MIRCALE !!", 70, 150);
	end
end

function Field:update(dt)
	if not self.show then
		return;
	end
	
	if self.failure or self.success then
		return;
	end

	if self.shot_flag then
		self._shot:update(dt);
		return;
	end

	self._mouse:move();
	if self.pause or self.editmode then
		return;
	end
	
	local tdt = dt;
	self.timer = self.timer-tdt;
	self.ai:update(tdt);
	for _, v in ipairs(self.players) do
		v:update(tdt);
	end
	
	self.ball:update(tdt);
	if self.ball.player==nil and not self.ball.out then
		for _, v in ipairs(self.players) do
			if self.ball.last_player ~= v and
				PointDist(self.ball.locx, self.ball.locy,
							v.locx, v.locy) < .3 then
				v:catch(self.ball);
				if v.tid == 1 then
					self:setFailure();
				end
			end
		end
	elseif self.ball.out then
		self:setFailure();
	end
	
end

function Field:mousepressed(x, y, button)
	if not self.show then
		return;
	end
	self._mouse:pressed(x, y, button);
end

function Field:mousereleased(x, y, button)
	if not self.show then
		return;
	end
	self._mouse:released(x, y, button);
end

function Field:hitPlayerTest(x, y, tid)
	for i, v in ipairs(self.players) do
		local locx = v.locx*self.scale+self.locx;
		local locy = v.locy*self.scale+self.locy;
		
		local dx = locx-x;
		local dy = locy-y;
		local dst = dx*dx+dy*dy;
		if dst<v.r*v.r then
			if tid==nil then
				return v;
			elseif tid==v.tid then
				return v;
			end
		end
	end
end

function Field:onMouseMove(x, y)
	--logPrint("onMouseMove("..x..","..y..")", {0, 0, 255});
	if self.editmode and self.select_ball then
		self.ball.locx = (x-self.locx)/self.scale;
		self.ball.locy = (y-self.locy)/self.scale;
		return;
	end
	
	if self.select_player==nil and self.grab then
		self.locy = self.locy + (y-self._mouse._last_loc_y);
		if self.locy>0 then
			self.locy=0;
		elseif self.locy<480-self.height*self.scale then
			self.locy=480-self.height*self.scale;
		end
		return;
	end
		
	if self.editmode then
		if not self.grab then
			return;
		end
	
		self.select_player.locx = (x-self.locx)/self.scale;
		self.select_player.locy = (y-self.locy)/self.scale;
		if self.select_player.ball~=nil then
			self.select_player:catch(self.select_player.ball);
		else
			if PointDist(self.ball.locx, self.ball.locy,
						self.select_player.locx, self.select_player.locy) < .3 then
				self.select_player:catch(self.ball);
			end
		end
	else
		if self.opmode==eOp.Pass then
			self.ball:setDirection((x-self.locx)/self.scale, 
									(y-self.locy)/self.scale);
			self.select_player:pass();
		elseif self.opmode==eOp.Move then
			self.select_player:setTarget((x-self.locx)/self.scale, 
										(y-self.locy)/self.scale);
		end
	end
	-- self.ball:setDirection((x-self.locx)/self.scale, 
							-- (y-self.locy)/self.scale);
end

function Field:onMousePressed(x, y, button)
	ClosePlayerMenu();

	if self.shot_flag then
		self._shot:nextStep();
		if self._shot.step > 1 then
			if self._shot:getHorResult()*self._shot:getVerResult() > .95 then
				self:setSuccess();
			else
				self:setFailure();
			end
		end
	end
	
	if self.opmode~=0 then
		return;
	end
	
	if not self.pause then
		self:setPause(true);
		return;
	end
	
	if self.editmode then
		self.select_player = self:hitPlayerTest(x, y);
	else
		self.select_player = self:hitPlayerTest(x, y, ePlayer.Human);
	end
	self.grab = true;
	if self.select_player==nil then
		return;
	end
	
	if self.editmode then
		if button=="r" then
			local r=self.select_player.role;
			if r=="G" then
				r="F";
			elseif r=="F" then
				r="C";
			elseif r=="C" then
				r="G";
			end
			self.select_player:setRole(r);
			self.grab=false;
		end
		if self.select_ball then
			self.select_player:catch(self.ball);
		end
	else
		OpenPlayerMenu(x, y, self.select_player.ball~=nil);
	end
	--print(self.select_player)
	--self.players[1]:setTarget(x/self.scale, y/self.scale);
	--logPrint("onMousePressed("..x..","..y..","..button..")", {100, 0, 255});
end

function Field:onMouseReleased(x, y, button)	
	--self.select_player = nil;
	self.select_ball = false;
	self.grab = false;
	self.opmode = 0;
	--logPrint("onMouseReleased("..x..","..y..","..button..")", {200, 100, 0});
end

return Field;