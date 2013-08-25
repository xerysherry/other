-- AI
local lg = love.graphics;

-- 得到基类
local MTS = getClass("Object.MTS");
local Graphics = MTS.graphics;

local Shot = class("Shot", MTS,
{
	border = 5,
	difficult_1 = 2,
	difficult_2 = 2,
	
	hfactor = 1,
	vfactor = 1,
	
	hor = .0,
	ver = .0,
	
	step = 0,
	
	font_switch_tic = 0,
	font_select = 0,
});

function Shot:initialize() 

end

function Shot:setDifficult(v1, v2)
	self.difficult_1 = v1;
	self.difficult_2 = v2;
end

function Shot:reset()
	self.hor = .0;
	self.ver = .0;
	self.step = 0;
	self.hfactor = 1;
	self.vfactor = 1;
end

function Shot:drawControl()
	lg.setColor({255, 255, 255});
	Graphics:drawImage("ball2", 100, 120, 0, .7, .7);
	Graphics:drawImage("panel", 220, 20, 0, .7, .7);

	--if self.step==0 then
		lg.setColor({255, 255, 255});
		lg.rectangle("fill", 117, 170, 206, 15);
		
		lg.setColor({0, 0, 0});
		lg.rectangle("fill", 120, 173, 200, 9);
		
		lg.setColor({50, 255, 50});
		local w1 = 200/(self.difficult_1+2);
		lg.rectangle("fill", 120+(200-w1)/2, 173, w1, 9);
		
		lg.setColor({255, 0, 0});
		lg.rectangle("fill", 118+self.hor*100, 173, 4, 9);
		
	if self.step>=1 then
		lg.setColor({255, 255, 255});
		lg.rectangle("fill", 360, 27, 15, 106);
		
		lg.setColor({0, 0, 0});
		lg.rectangle("fill", 363, 30, 9, 100);
		
		lg.setColor({50, 255, 50});
		local h2 = 100/(self.difficult_1+2);
		lg.rectangle("fill", 363, 30+(100-h2)/2, 9, h2);
		
		lg.setColor({255, 0, 0});
		lg.rectangle("fill", 363, 28+self.ver*50, 9, 4);
	end

	if self.step<=1 then
		lg.setColor({255, 255, 255});
		if self.font_select==0 then
			Graphics:setFont("font12");
			lg.print("Press anywhere", 15, 170);
		else
			Graphics:setFont("font10");
			lg.print("Press anywhere", 19, 170);
		end
	end
end

function Shot:draw()
	lg.push();
	lg.translate(60, 100);
	
	lg.setColor({100, 100, 200});
	lg.rectangle("fill", 0, 0, 400, 200);
	
	lg.setColor({0, 0, 0});
	lg.rectangle("fill", self.border, self.border, 
				400-self.border*2, 200-self.border*2);

	self:drawControl();
				
	lg.pop();
end

function Shot:update(dt)
	local d = self.difficult_2+1;
	
	if self.step==0 then
		self.hor = self.hor+d*dt*self.hfactor;
		if self.hor>2.0 then
			self.hor=2.0;
			self.hfactor=-1;
		elseif self.hor<.0 then
			self.hor=.0;
			self.hfactor=1;
		end
	elseif self.step==1 then
		self.ver = self.ver+d*dt*self.vfactor;
		if self.ver>2.0 then
			self.ver=2.0;
			self.vfactor=-1;
		elseif self.ver<.0 then
			self.ver=.0;
			self.vfactor=1;
		end
	end
	
	self.font_switch_tic = self.font_switch_tic+dt;
	if self.font_switch_tic>.5 then
		if self.font_select==0 then
			self.font_select=1;
		else
			self.font_select=0;
		end
		self.font_switch_tic=0;
	end
end

function Shot:nextStep()
	self.step = self.step+1;
	if self.step > 2 then
		self.step = 2;
	end
	-- if self.step > 1 then
		-- print(self:getHorResult()*self:getVerResult())
	-- end
end

function Shot:getHorResult()
	local res = self.hor;
	if res>1 then
		res = 2-res;
	end
	
	local succ = 1-1/(self.difficult_1+2);
	if res >= succ then
		return 1
	else
		return res/succ;
	end
end

function Shot:getVerResult()
	local res = self.ver;
	if res>1 then
		res = 2-res;
	end
	
	local succ = 1-1/(self.difficult_1+2);
	if res >= succ then
		return 1
	else
		return res/succ;
	end
end
