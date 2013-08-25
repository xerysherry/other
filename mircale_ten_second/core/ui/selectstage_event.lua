local MTS = getClass("Object.MTS")
local field = MTS.field;

local gui_manager = MTS.gui_manager;
local le = love.event;
local lfs = love.filesystem;

local selectstage_gui = gui_manager:getGui("selectstage");
local selectstage_bg = selectstage_gui:getView("background");

local bw = 170;
local bh = 20;
local row = 15;
local page = 0;
local count = 0;
local stages = {};

function InitSelectStage()
	selectstage_bg:clearView();
	page = 1;
	count = 0;
	stages = {};

	local function AddButton(text, path, locx, locy)
		local b = Girl.View.Button(bw, bh);
		table.insert(stages, b);
		b:setImageColor({255,255,255,200}, {255,255,255,255}, {255,255,255,200});
		b:setLabel(path..":"..text, 5, 5);
		b:setFont("font12");
		b.onButtonClick = function (btn)
			local s = path.."/"..text;
			print (s);
			field:setEditMode(false);
			field:setShow(true);
			field:load(s);
			gui_manager:close("selectstage");
			gui_manager:open("gamemenu");
		end
		b.rect.x = locx;
		b.rect.y = locy;
		--selectstage_bg:add(path..":"..text, b, locx, locy);
	end
	local function InitButton(path)
		local stages=lfs.enumerate(path)
		for i, v in ipairs(stages) do
			if not lfs.isDirectory(path.."/"..v) then
				local rc = math.floor(count/row/2);
				if rc>0 then
					local tcount=count-rc*row*2;
					AddButton(v, path, 
							5+math.floor(tcount/row)*(bw+5), 
							5+((tcount%row)*(bh+5)));
				else
					AddButton(v, path, 
							5+math.floor(count/row)*(bw+5), 
							5+((count%row)*(bh+5)));
				end
				count = count+1;
			end
		end
	end
	
	InitButton("stage");
	InitButton("custom");
	
	for i=(page-1)*row*2+1, page*row*2 do
		if stages[i]==nil then
			return;
		end
		local v=stages[i];
		selectstage_bg:add(v.label, v, v.rect.x, v.rect.y);
	end
end

function OnStagePrev()
	if count <= row*2 then
		return false;
	end	
	
	page=page-1;
	if page<1 then
		page=page+1;
	end

	for i, v in ipairs(stages) do
		--v:showView(false);
		selectstage_bg:del(v.label);
	end
	
	for i=(page-1)*row*2+1, page*row*2 do
		if stages[i]==nil then
			return;
		end
		local v=stages[i];
		selectstage_bg:add(v.label, v, v.rect.x, v.rect.y);
	end
end

function OnStageNext()
	if count <= row*2 then
		return false;
	end	
	
	page=page+1;
	if (page-1)*row*2 > count then
		page=page-1;
	end

	for i, v in ipairs(stages) do
		selectstage_bg:del(v.label);
	end
	
	for i=(page-1)*row*2+1, page*row*2 do
		if stages[i]==nil then
			return;
		end
		local v=stages[i];
		selectstage_bg:add(v.label, v, v.rect.x, v.rect.y);
	end
end
