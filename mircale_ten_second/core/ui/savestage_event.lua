local MTS = getClass("Object.MTS")
local field = MTS.field;
local gui_manager = MTS.gui_manager;
local savestage = gui_manager:getGui("savestage");
local editbox = savestage:getView("background.editbox");

OnSaveOK = function (btn)
	local text = editbox:getText();
	if string.len(text) == 0 then
		return;
	end
	
	-- field:save("custom/"..text);
	field:save(text);
	gui_manager:close("savestage");
	gui_manager:enableModalmode(false);
end

OnSaveClose = function (btn)
	gui_manager:close("savestage");
	gui_manager:enableModalmode(false);
end