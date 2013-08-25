-- EVENT FUNCTION
-- OnPlayerMove
-- OnBallPass
-- OnShot
local function CallEvent(func, ...)
	if func~=nil then
		func(...);
	end
end

return {
	name = "playermenu",
	pos = {530, 370},
	size = {50, 45},
	view = {
		{
			name = "move",
			type = "Button",
			pos = {5, 0},
			size = {"100%", 15},
			Font = {"font10"},
			Label = {"MOVE", 7, 2},
			ImageColor = {{255,255,255,200}, {255,255,255,255}, {255,255,255,200}},
			onButtonClick = function (btn) CallEvent(OnPlayerMove, btn); end,
		},
		{
			name = "pass",
			type = "Button",
			pos = {5, 15},
			size = {"100%", 15},
			Label = {"PASS", 7, 2},
			Font = {"font10"},
			ImageColor = {{255,255,255,200}, {255,255,255,255}, {255,255,255,200}},
			onButtonClick = function (btn) CallEvent(OnBallPass, btn); end,
		},
		{
			name = "shot",
			type = "Button",
			pos = {5, 30},
			size = {"100%", 15},
			Font = {"font10"},
			Label = {"SHOT", 7, 2},
			ImageColor = {{255,255,255,200}, {255,255,255,255}, {255,255,255,200}},
			onButtonClick = function (btn) CallEvent(OnShot, btn); end,
		},
	}
};
