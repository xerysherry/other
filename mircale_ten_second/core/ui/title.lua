-- EVENT FUNCTION
-- OnStartGame
-- OnEditMode
-- OnTutorial
-- OnExit
local function CallEvent(func, ...)
	if func~=nil then
		func(...);
	end
end

return {
	name = "title",
	pos = {(640-150)/2, 250},
	size = {150, 220},
	view = {
		{
			name = "start",
			type = "Button",
			pos = {0, 0},
			size = {"100%", 40},
			Font = {"font12"},
			Label = {"Start Game", 5, 5},
			ImageColor = {{255,255,255,200}, {255,255,255,255}, {255,255,255,200}},
			onButtonClick = function (btn) CallEvent(OnStartGame, btn); end,
		},
		{
			name = "edit",
			type = "Button",
			pos = {0, 50},
			size = {"100%", 40},
			Label = {"Edit Mode", 5, 5},
			Font = {"font12"},
			ImageColor = {{255,255,255,200}, {255,255,255,255}, {255,255,255,200}},
			onButtonClick = function (btn) CallEvent(OnEditMode,btn); end,
		},
		-- {
			-- name = "tutorial",
			-- type = "Button",
			-- pos = {0, 100},
			-- size = {"100%", 40},
			-- Font = {"font12"},
			-- Label = {"Tutorial", 5, 5},
			-- ImageColor = {{255,255,255,200}, {255,255,255,255}, {255,255,255,200}},
			-- onButtonClick = function (btn) CallEvent(OnTutorial,btn); end,
		-- },
		{
			name = "exit",
			type = "Button",
			pos = {0, 100},
			size = {"100%", 40},
			Label = {"Exit", 5, 5},
			ImageColor = {{255,255,255,200}, {255,255,255,255}, {255,255,255,200}},
			onButtonClick = function (btn) CallEvent(OnExit,btn); end,
		},
		-- {
			-- name = "copyright",
			-- type = "Label",
			-- pos = {0, 190},
			-- size = {"100%", 20},
			-- Font = {"font12"},
			-- Label = {"Create by Xerysherry"},
			-- LabelColor = {{255,255,255}},
		-- }
	}
};
