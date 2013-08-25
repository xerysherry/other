----------------------------------------------------------------
-- write by xerysherry

-- 得到View类
local View = getClass("Object.View");

-- 标签
local Label = class("Label", View, 
{
	font = "_system",
	label = "",
	label_color = nil,
	align = 1,
	
	AlignEnum = 
	{
		left = 1,
		center = 2, 
		right = 3,
	}
});

-- 初始化
function Label:initialize(w, h)
	View.initialize(self, w, h);
	self.label_color = {0,0,0};
end

function Label:setFont(font)
	self.font = font or "_system";
end

function Label:setLabelColor(color)
	self.label_color = color or {0,0,0};
end

function Label:setLabel(label)
	self.label = label or "";
end

function Label:setAlign(align)
	self.align = align or Label.AlignEnum.left;
end

function Label:computeTextSize(text)
	assert(self.gui~=nil, "autoResize:Label must added in a gui.");
	local font = self.gui.graph:getFont(self.font);
	local tmplbl = nil;
	local nextlbl = text;
	local pos = nil;
	local maxw = 0;
	local maxh = 0;
	local line = 1;
	local h = font:getHeight();
	
	-- 计算行数和最大宽度
	while true do
		pos = string.find(nextlbl,"\n")
		if not pos then
			break;
		end
		
		tmplbl = string.sub(nextlbl,1,pos-1);
		nextlbl = string.sub(nextlbl,pos+1);
		
		local w = font:getWidth(tmplbl);
		if w>maxw then
			maxw = w;
		end
		line=line+1;
	end
	
	local w = font:getWidth(nextlbl);
	if w>maxw then
		maxw = w;
	end
	maxh = h+(line-1)*h*font:getLineHeight();
	
	return maxw, maxh;
end

-- 控件已经加入Gui中，才可以进行自动尺寸计算
function Label:autoResize()
	-- 设置控件大小
	self.rect.width, self.rect.height = self:computeTextSize(self.label);
end

function Label:onDraw()
	if self.label=="" then
		return;
	end

	local tx = 0;
	
	self.gui.graph:setFont(self.font);
	self.gui.graph._setColor(self.label_color);
	
	if self.align==Label.AlignEnum.center then
		local tw, th = self:computeTextSize(self.label);
		tx = (self.rect.width - tw) / 2;
	elseif self.align==Label.AlignEnum.right then
		local tw, th = self:computeTextSize(self.label);
		tx = self.rect.width - tw;
	else
		tx = 0;
	end
	self.gui.graph._print(self.label, tx, 0);
end

return Label;
