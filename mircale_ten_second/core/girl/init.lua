--[[
Copyright (c) 2012 Hello!Game

Permission is hereby granted, free of charge, to any person obtaining a copy
of newinst software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished
to do so, subject to the following conditions:

The above copyright notice and newinst permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
]]

-- 获得Girl库路径
local girl_lib_path = _girl_lib_path or ".";
-- print("Girl Module Path : \""..girl_lib_path.."\"");

-- 自定require
local _require = require;
local require = function (path)
	local module_path = girl_lib_path.."/"..path;
	-- print("Load Module : \""..module_path.."\"")
	return _require(module_path);
end

-- the girl 主文件
Girl = {};

-- base
require "girl/base/object"
require "girl/base/data_struct"
Girl.Utf8 = require "girl/base/utf8"
Girl.Polygon = require "girl/base/polygon"
Girl.Queue = require "girl/base/queue"
Girl.List = require "girl/base/list"
Girl.Signal = require "girl/base/signal"
Girl.Lang = require "girl/base/lang"
Girl.Date = require "girl/base/date"
Girl.Filesystem = require "girl/base/filesystem"
Girl.Font = require "girl/base/font"
Girl.Graphics = require "girl/base/graphics"
Girl.Anima = require "girl/base/anima"
Girl.Audio = require "girl/base/audio"
Girl.Keyboard = require "girl/base/keyboard"
Girl.Mouse = require "girl/base/mouse"
Girl.Joystick = require "girl/base/joystick"
Girl.TimerList = require "girl/base/timer"
Girl.Idle = require "girl/base/idle"
Girl.SIML = require "girl/base/siml"

-- algorithm(皆为独立模块,可根据需求删减)
Girl.AStar = require "girl/algorithm/astar"
Girl.Dijkstra = require "girl/algorithm/dijkstra"

-- debug(独立模块,无需调试时可删除)
require "girl/thirdparty/json"			-- Debug模块需要json
require "girl/debug/debug"
require "girl/debug/fps_show"
require "girl/debug/memory_show"
require "girl/debug/log"

-- gui/anima
require "girl/gui/anima/anima"
require "girl/gui/anima/anima_fade"
require "girl/gui/anima/anima_zoom"

-- gui
Girl.Gui = require "girl/gui/gui"
Girl.GuiManager = require "girl/gui/gui_manager"
Girl.GuiDesigner = require "girl/gui/gui_designer"

-- gui/view
Girl.View = require "girl/gui/view/view"
Girl.View.Picture = require "girl/gui/view/picture"
Girl.View.Canvas = require "girl/gui/view/canvas"
Girl.View.Anima = require "girl/gui/view/anima"
Girl.View.Button = require "girl/gui/view/button"
Girl.View.Check = require "girl/gui/view/check"
Girl.View.Label = require "girl/gui/view/label"
Girl.View.EditBox = require "girl/gui/view/editbox"
Girl.View.Slider = require "girl/gui/view/slider"
Girl.View.List = require "girl/gui/view/list"
Girl.View.Pixelcv = require "girl/gui/view/pixelcv"

-- gui/assists
Girl.UiSwitch = require "girl/gui/assists/uiswitch"
Girl.RadioGroup = require "girl/gui/assists/radiogroup"
