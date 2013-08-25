-- EVENT FUNCTION
-- OnPause
-- OnRestart
-- OnGotoTitle
local function CallEvent(func, ...)
	if func~=nil then
		func(...);
	end
end

return {
	name = "gamemenu",
	pos = {530, 370},
	size = {100, 220},
	view = {
		{
			name = "pause",
			type = "Button",
			pos = {5, 0},
			size = {90, 30},
			Font = {"font12"},
			Label = {"Continue", 5, 5},
			ImageColor = {{255,255,255,200}, {255,255,255,255}, {255,255,255,200}},
			onButtonClick = function (btn) CallEvent(OnPause, btn); end,
		},
		{
			name = "restart",
			type = "Button",
			pos = {5, 35},
			size = {90, 30},
			Label = {"Restart", 5, 5},
			Font = {"font12"},
			ImageColor = {{255,255,255,200}, {255,255,255,255}, {255,255,255,200}},
			onButtonClick = function (btn) CallEvent(OnRestart, btn); end,
		},
		{
			name = "exit",
			type = "Button",
			pos = {5, 70},
			size = {90, 30},
			Label = {"Exit", 5, 5},
			ImageColor = {{255,255,255,200}, {255,255,255,255}, {255,255,255,200}},
			onButtonClick = function (btn) CallEvent(OnGotoTitle, btn); end,
		},
	}
};
