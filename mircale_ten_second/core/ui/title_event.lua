local MTS = getClass("Object.MTS")
local field = MTS.field;

local gui_manager = MTS.gui_manager;
local le = love.event;

-- local title_gui = gui_manager:getGui("title");
-- local selectstage_gui = gui_manager:getGui("selectstage");
-- local selectstage_bg = selectstage_gui:getView("background");
-- local stages = {};

OnStartGame = function (btn)
	InitSelectStage();
	gui_manager:close("title");
	gui_manager:close("logo");
	gui_manager:open("selectstage");
	-- field:setEditMode(false);
	-- field:setShow(true);
end

OnEditMode = function (btn)
	gui_manager:close("title");
	gui_manager:close("logo");
	gui_manager:open("editmenu");
	field:setEditMode(true);
	field:setShow(true);
end

OnTutorial = function (btn)
	gui_manager:close("title");
	gui_manager:close("logo");
	--field:setShow(true);
end

OnExit = function (btn)
	le.quit();
end
