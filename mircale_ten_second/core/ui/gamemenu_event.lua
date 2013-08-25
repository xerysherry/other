local MTS = getClass("Object.MTS")
local field = MTS.field;
local gui_manager = MTS.gui_manager;

OnPause = function(btn)
	if field.pause then
		field:setPause(false);
		btn:setLabel("Pause");
	else
		field:setPause(true);
		btn:setLabel("Continue");
	end
	gui_manager:close("playermenu");
end

OnRestart = function ()
	field:restart();
	gui_manager:close("playermenu");
end