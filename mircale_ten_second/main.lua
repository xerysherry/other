local MTS = require "core/init";
local graph = MTS.graphics;
local gui_manager = MTS.gui_manager;
local field = MTS.field;

local lg = love.graphics;
local lfs = love.filesystem;

function love.load()
	lfs.setIdentity("mircale_ten_second");
	lfs.setIdentity("mircale_ten_second/custom");
	
	graph:createFontFromPath("font48", 48);
	graph:createFontFromPath("font12", 12);
	graph:createFontFromPath("font10", 10);
	graph:createImageFromPath("ball", "asset/ball.png");
	graph:createImageFromPath("ball2", "asset/ball2.png");
	graph:createImageFromPath("panel", "asset/panel.png");
	
	memoryShow(false);
	fpsShow(false);
	fpsSetFont(graph:getFont("font12"));
	logSetShowLine(20);
	logShow(false);
	
	lg.setLineWidth(1);
	--lg.setLineStyle("rough");
	
	lg.setPointSize(5);
	lg.setPointStyle("rough");
	lg.setBackgroundColor({50, 50, 50})
end

function love.update(dt)
	field:update(dt);
	gui_manager:update(dt);
end

function love.draw()
	field:draw();
	gui_manager:draw();
end

function love.keypressed(key, unicode)
	gui_manager:keypressed(key, unicode);
	if key==" " and field.show then
		local gui = gui_manager:getGui("gamemenu");
		local btn = gui:getView("pause");
		if field.pause then
			field:setPause(false);
			btn:setLabel("Pause");
		else
			field:setPause(true);
			btn:setLabel("Continue");
		end
	end
end

function love.keyreleased(key, unicode)
	gui_manager:keyreleased(key, unicode);
end

function love.mousepressed(x, y, button)
	if gui_manager:mousepressed(x, y, button) then
		return;
	end
	field:mousepressed(x, y, button);
end

function love.mousereleased(x, y, button)
	if gui_manager:mousereleased(x, y, button) then
		return;
	end
	field:mousereleased(x, y, button);
end
