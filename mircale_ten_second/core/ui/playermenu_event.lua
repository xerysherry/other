local MTS = getClass("Object.MTS")
local field = MTS.field;
local gui_manager = MTS.gui_manager;
local playermenu = gui_manager:getGui("playermenu");

OnPlayerMove = function (btn)
	-- local text = editbox:getText();
	-- if string.len(text) == 0 then
		-- return;
	-- end
	
	field:setOp(1);
	gui_manager:close("playermenu");
end

OnBallPass = function (btn)
	field:setOp(2);
	gui_manager:close("playermenu");
end

OnShot = function (btn)
	field:setOp(3);
	gui_manager:close("playermenu");
end
