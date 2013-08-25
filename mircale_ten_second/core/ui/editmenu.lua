-- EVENT FUNCTION
-- OnAddHuman
-- OnAddRobot
-- OnRemove
-- OnSetBall
-- OnSaveStage
-- OnGotoTitle
local function CallEvent(func, ...)
	if func~=nil then
		func(...);
	end
end

return {
	name = "editmenu",
	pos = {530, 270},
	size = {100, 220},
	view = {
		{
			name = "addhuman",
			type = "Button",
			pos = {5, 0},
			size = {90, 30},
			Font = {"font12"},
			Label = {"Add Human", 5, 5},
			ImageColor = {{255,255,255,200}, {255,255,255,255}, {255,255,255,200}},
			onButtonClick = function (btn) CallEvent(OnAddHuman, btn); end,
		},
		{
			name = "addrobot",
			type = "Button",
			pos = {5, 35},
			size = {90, 30},
			Label = {"Add Robot", 5, 5},
			Font = {"font12"},
			ImageColor = {{255,255,255,200}, {255,255,255,255}, {255,255,255,200}},
			onButtonClick = function (btn) CallEvent(OnAddRobot, btn); end,
		},
		{
			name = "remove",
			type = "Button",
			pos = {5, 70},
			size = {90, 30},
			Font = {"font12"},
			Label = {"Remove", 5, 5},
			ImageColor = {{255,255,255,200}, {255,255,255,255}, {255,255,255,200}},
			onButtonClick = function (btn) CallEvent(OnRemove, btn); end,
		},
		{
			name = "setball",
			type = "Button",
			pos = {5, 105},
			size = {90, 30},
			Font = {"font12"},
			Label = {"SetBall", 5, 5},
			ImageColor = {{255,255,255,200}, {255,255,255,255}, {255,255,255,200}},
			onButtonClick = function (btn) CallEvent(OnSetBall, btn); end,
		},
		{
			name = "save",
			type = "Button",
			pos = {5, 140},
			size = {90, 30},
			Font = {"font12"},
			Label = {"Save", 5, 5},
			ImageColor = {{255,255,255,200}, {255,255,255,255}, {255,255,255,200}},
			onButtonClick = function (btn) CallEvent(OnSaveStage, btn); end,
		},
		{
			name = "exit",
			type = "Button",
			pos = {5, 175},
			size = {90, 30},
			Label = {"Exit", 5, 5},
			ImageColor = {{255,255,255,200}, {255,255,255,255}, {255,255,255,200}},
			onButtonClick = function (btn) CallEvent(OnGotoTitle, btn); end,
		},
	}
};
