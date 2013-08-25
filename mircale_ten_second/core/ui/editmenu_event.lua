local MTS = getClass("Object.MTS")
local field = MTS.field;

local Player = getClass("Object.MTS.Player")
local gui_manager = MTS.gui_manager;

OnAddHuman = function (btn)
	local flag = {false, false, false, false, false};
	local count = 0;
	for i, v in ipairs(field.players) do
		if v.tid == 0 then
			count = count+1;
			flag[v.pid]=true;
		end
	end
	
	if count>=5 then
		return;
	end
	
	local p = nil;
	for i=1, 5 do
		if not flag[i] then
			p = Player(0, i, "G");
			break;
		end
	end
	p.locx = 2.5+2*p.pid;
	p.locy = 6;
	field:addPlayer(p);
end

OnAddRobot = function (btn)
	local flag = {false, false, false, false, false};
	local count = 0;
	for i, v in ipairs(field.players) do
		if v.tid == 1 then
			count = count+1;
			flag[v.pid]=true;
		end
	end
	
	if count>=5 then
		return;
	end
	
	local p = nil;
	for i=1, 5 do
		if not flag[i] then
			p = Player(1, i, "G");
			break;
		end
	end
	p.locx = 2.5+2*p.pid;
	p.locy = 3;
	field:addPlayer(p);
end

OnRemove = function (btn)
	field:removePlayer(field.select_player);
end

OnSetBall = function (btn)
	field:setBall();
end

OnSaveStage = function (btn)
	gui_manager:open("savestage");
	gui_manager:topMost("savestage");
	gui_manager:enableModalmode(true);
end
