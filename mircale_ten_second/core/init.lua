-- MTS Core Init

-- reset Girl Lib Path
_girl_lib_path = "core";

require "core/girl/init"

local MTS = class("MTS", getClass("Object"), 
{
	graphics = Girl.Graphics(),
	gui_manager = Girl.GuiManager();
});

require "core/rule/player"
require "core/rule/ai"
require "core/rule/shot"
require "core/rule/ball"
MTS.field = (require "core/rule/field")();

MTS.field :setTeamColor(0, {255, 0, 0}, {125, 210, 150}, {0, 0, 0});
MTS.field :setTeamColor(1, {0, 0, 255}, {225, 10, 250}, {0, 0, 0});

MTS.gui_manager:add("title", 
	Girl.GuiDesigner.produceGui(MTS.graphics, require "core/ui/title"));
MTS.gui_manager:add("logo", 
	Girl.GuiDesigner.produceGui(MTS.graphics, require "core/ui/logo"));
MTS.gui_manager:add("editmenu", 
	Girl.GuiDesigner.produceGui(MTS.graphics, require "core/ui/editmenu"));
MTS.gui_manager:add("savestage", 
	Girl.GuiDesigner.produceGui(MTS.graphics, require "core/ui/savestage"));
MTS.gui_manager:add("selectstage", 
	Girl.GuiDesigner.produceGui(MTS.graphics, require "core/ui/selectstage"));
MTS.gui_manager:add("gamemenu", 
	Girl.GuiDesigner.produceGui(MTS.graphics, require "core/ui/gamemenu"));
MTS.gui_manager:add("playermenu", 
	Girl.GuiDesigner.produceGui(MTS.graphics, require "core/ui/playermenu"));
	
OnGotoTitle = function ()	
	MTS.gui_manager:open("title");
	MTS.gui_manager:open("logo");
	MTS.gui_manager:close("editmenu");
	MTS.gui_manager:close("savestage");
	MTS.gui_manager:close("selectstage");
	MTS.gui_manager:close("gamemenu");
	MTS.gui_manager:close("playermenu");
	MTS.field:setShow(false);
end
OnGotoTitle();

local playermenu = MTS.gui_manager:getGui("playermenu");
OpenPlayerMenu = function(x, y, ball)
	playermenu:setPoint(x, y);
	if ball then
		playermenu:setSize(playermenu.rect.width, 45);
	else
		playermenu:setSize(playermenu.rect.width, 15);
	end
	
	MTS.gui_manager:setFocus("playermenu");
	MTS.gui_manager:open("playermenu");
end
ClosePlayerMenu = function()
	MTS.gui_manager:close("playermenu");
end
	
require "core/ui/title_event";
require "core/ui/editmenu_event";
require "core/ui/savestage_event";
require "core/ui/selectstage_event";
require "core/ui/gamemenu_event";
require "core/ui/playermenu_event";
	
return MTS;
