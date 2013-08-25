-- EVENT FUNCTION
-- OnSaveOK
-- OnSaveClose
local function CallEvent(func, ...)
	if func~=nil then
		func(...);
	end
end

return {
	name = "savestage",
	pos = {(640-200)/2, 270},
	size = {200, 60},
	view = {
	{
		name = "background",
		type = "Picture",
		pos = {0, 0},
		size = {"100%", "100%"},
		set_enable = {"Caption"},
		ImageColor = {{255, 255, 255}},
		view = {
		{
			name = "editbox",
			type = "EditBox",
			pos = {10, 5},
			size = {180, 20},
			TextRect = {2, 2, 174, 16},
			BorderColor = {{150,150,150}},
		},
		{
			name = "addhuman",
			type = "Button",
			pos = {5, 30},
			size = {50, 20},
			Font = {"font12"},
			Label = {"Save", 5, 5},
			ImageColor = {{255,255,255,200}, {255,255,255,255}, {255,255,255,200}},
			onButtonClick = function (btn) CallEvent(OnSaveOK, btn); end,
		},
		{
			name = "cancel",
			type = "Button",
			pos = {60, 30},
			size = {50, 20},
			Font = {"font12"},
			Label = {"Cancel", 5, 5},
			ImageColor = {{255,255,255,200}, {255,255,255,255}, {255,255,255,200}},
			onButtonClick = function (btn) CallEvent(OnSaveClose, btn); end,
		}
		},
	}
	}
};
