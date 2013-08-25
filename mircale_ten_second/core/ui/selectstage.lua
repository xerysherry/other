-- EVENT FUNCTION
-- OnGotoTitle
local function CallEvent(func, ...)
	if func~=nil then
		func(...);
	end
end

return {
	name = "selectstage",
	pos = {(640-360)/2, 40},
	size = {360, 400},
	view = {
	{
		name = "background",
		type = "Picture",
		pos = {0, 0},
		size = {"100%", 380},
		ImageColor = {{0, 0, 0, 0}},
	},
	{
		name = "prev",
		type = "Button",
		pos = {200, 380},
		size = {30, 20},
		Font = {"font12"},
		Label = {"<<", 5, 5},
		ImageColor = {{255,255,255,200}, {255,255,255,255}, {255,255,255,200}},
		onButtonClick = function (btn) CallEvent(OnStagePrev, btn); end,
	},
	{
		name = "next",
		type = "Button",
		pos = {240, 380},
		size = {30, 20},
		Font = {"font12"},
		Label = {">>", 5, 5},
		ImageColor = {{255,255,255,200}, {255,255,255,255}, {255,255,255,200}},
		onButtonClick = function (btn) CallEvent(OnStageNext, btn); end,
	},
	{
		name = "back",
		type = "Button",
		pos = {300, 380},
		size = {50, 20},
		Font = {"font12"},
		Label = {"Back", 5, 5},
		ImageColor = {{255,255,255,200}, {255,255,255,255}, {255,255,255,200}},
		onButtonClick = function (btn) CallEvent(OnGotoTitle, btn); end,
	},
	}
};
