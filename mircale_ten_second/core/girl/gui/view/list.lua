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

----------------------------------------------------------------
-- write by xerysherry

local tinsert = table.insert;
local tremove = table.remove;

local Object = getClass("Object");
local View = getClass("Object.View");
local Picture = getClass("Object.View.Picture");
local ViewMouseEnum = getClass("Object.ViewMouseEnum");

-- item类型
local ItemEnum = {
	label = 0,
	view = 1,
};

-- item项目
local Item = {
	mode = ItemEnum.label,
	content = nil,
};
Item.__mode = "k";
Item.__index = Item;

local function NewLabel(label, x, y, 
				font_normal_color, bg_normal_color, bg_normal_img,
				font_hover_color, bg_hover_color, bg_hover_img, 
				font_click_color, bg_click_color, bg_click_img,
				font_check_color, bg_check_color, bg_check_img)
	local newlabel =  {
		mode = ItemEnum.label,
		content = {
			label = label,
			x = x or 0, 
			y = y or 0,
			selected = false,
			font_normal_color = font_normal_color or {0,0,0},
			font_hover_color = font_hover_color,
			font_click_color = font_click_color,
			font_check_color = font_check_color,
			bg_normal_color = bg_normal_color,
			bg_normal_img = bg_normal_img,
			bg_hover_color = bg_hover_color,
			bg_hover_img = bg_hover_img,
			bg_click_color = bg_click_color,
			bg_click_img = bg_click_img,
			bg_check_color = bg_check_color,
			bg_check_img = bg_check_img,
		},
	};
	return newlabel;
end

local function NewView(view)
	return {
		mode = ItemEnum.view,
		content = view,
	};
end

-- 新item
local function NewItem(...)
	assert(arg[1]~=nil, "content must be not nil!")

	if type(arg[1])=="string" then
		return NewLabel(unpack(arg))
	elseif type(arg[1])=="table" then
		return NewView(unpack(arg))
	end
	return nil;
end

-- 纵行项
local Column = class("Column", Object, {
	row = nil,
	selected = false,
});

function Column:initialize()
	self.row = {};
end

function Column:addLabel(...)
	tinsert(self.row, NewLabel(...));
	return #self.row;
end

--注意：加入到column的view只能接收到鼠标按下事件！！
function Column:addView(view)
	tinsert(self.row, NewView(view));
	return #self.row;
end

function Column:setItem(idx, item)
	if self.row[idx]==nil then
		return false;
	end
	self.row[idx]=item;
end

function Column:select(idx)
	if self.row[idx]~=nil then
		if self.row[idx].mode == ItemEnum.label then
			self.row[idx].content.selected = true;
		end
	end
end

function Column:unselect(idx)
	if self.row[idx]~=nil then
		if self.row[idx].mode == ItemEnum.label then
			self.row[idx].content.selected = false;
		end
	end
end

function Column:selectAll()
	for _,v in ipairs(self.row) do
		if v.mode == ItemEnum.label then
			v.content.selected = true;
		end
	end
	self.selected = true;
end

function Column:unselectAll()
	for _,v in ipairs(self.row) do
		if v.mode == ItemEnum.label then
			v.content.selected = false;
		end
	end
	self.selected = false;
end

function Column:getSelectState(idx)
	if self.row[idx]~=nil then
		if self.row[idx].mode == ItemEnum.label then
			return self.row[idx].content.selected;
		end
	end
	return false;
end

local List = class("List", View,
{
	-- 鼠标参数
	hover = false,
	click = false,
	
	-- 是否显示头
	show_head = false,
	-- list头部参数
	column_head = nil,
	column_head_height = 20,
	column_head_color = nil,
	column_head_img = nil,
	column_head_hover_color = nil,
	column_head_hover_img = nil,
	column_head_click_color = nil,
	column_head_click_img = nil,

	column_head_bgcolor = nil,
	column_head_bg = nil,
	
	-- list中的项目
	column = nil,
	column_height = 20,
	column_interval = 0,
	
	column_color = nil,
	column_hover_color = nil,
	column_click_color = nil,
	column_check_color = nil,
	-- Column全局图片，当项目没有具体设置图片时使用
	column_img = nil,
	column_hover_img = nil,
	column_click_img = nil,
	column_check_img = nil,
	
	-- 是否绘制border line
	border_h = false,			--水平
	border_h_size = 1,			--宽
	border_v = false,			--垂直
	border_v_size = 1,			--宽
	border_color = nil,
	
	-- 是否显示选择项
	alway_show_selection = true,
	-- 单选模式
	single_selection = true,
	-- 单项模式，关闭则为Column选择模式，单选模式下该值无意义
	item_selection = true,
	-- 单项绘制模式（开始的话，每一项属性独立背景绘制，关闭整个column为一个背景绘制）
	item_draw_mode = true,
	-- 单选索引，多项式无意义
	single_selection_idx = nil;
	
	hover = false,
	click = false,
	mouse_col = 0,				-- 鼠标指向column
	mouse_row = 0,				-- 鼠标指向row
	selection_table = nil,
	
	-- 偏移列,  精致坐标
	offset_row=0, offset_x = 0,
	offset_column=0, offset_y = 0,
	
	font = "_system",
	
	-- 背景
	background = nil;
	
	bg_normal_color = nil;
	bg_disable_color = nil;
	
	picture = nil,
	item_picture = nil,
	
	on_head_click = function (this, row_idx) end,
	on_single_column_select = function (this, sel_idx, last_sel_idx) end,
	on_column_select = function (this, sel_idx) end,
	on_column_unselect = function (this, sel_idx) end,
	on_item_select = function (this, sel_idx, row_idx) end,
	on_item_unselect = function (this, sel_idx, row_idx) end,
});

function List:initialize(w,h)
	View.initialize(self,w,h);
	
	self.column_head = {};
	self.column_head_color = {255,255,255};
	self.column_head_hover_color = {255,255,255};
	self.column_head_click_color = {255,255,255};
	self.column_head_bgcolor = {255,255,255,0};
	
	self.column = {};
	self.column_color = {255,255,255};
	self.column_hover_color = {255,255,255};
	self.column_click_color = {255,255,255};
	self.column_check_color = {200,200,200};
	
	self.border_color = {0,0,0}

	self.bg_normal_color = {255,255,255};
	self.bg_disable_color = {125,125,125};
	
	self.selection_table = {};
	
	
	self.picture = Picture(w,h);
	self.item_picture = Picture(0,0);
end

function List:setBackgroundMode(...)
	self.picture:setMode(...);
end

function List:setBackground(background)
	self.background = background;
end

function List:setBackgroundColor(normal,disable)
	self.bg_normal_color = normal or {255,255,255};
	self.bg_disable_color = disable or {125,125,125};
end

-- 添加 Column头 标签  ...具体参数查看NewLabel
function List:addHeadLabel(label, width, ...)
	tinsert(self.column_head, {
		item = NewLabel(label, ...),
		width = width,
	});
end

-- 添加 Column头 view
function List:addHeadView(view, width)
	tinsert(self.column_head, {
		item = NewView(view),
		width = width,
	});
end

function List:delHead(idx)
	tremove(self.column_head, idx);
end

function List:setHeadItemImage(img)
	self.column_head_img = img;
end

function List:setHeadItemColor(color)
	self.column_head_color = color;
end

function List:setHeadBgImage(img)
	self.column_head_bg = img;
end

function List:setHeadBgColor(color)
	column_head_bgcolor = color or {255,255,255,0};
end

function List:setHeadMode(...)
	self.item_picture:setMode(...);
end

function List:addSelect()

end

-- 添加Column
function List:addColumn(col, loc)
	if col==nil then
		return;
	end
	if type(loc)=="number" then
		tinsert(self.column, loc, col);
	else
		tinsert(self.column, col);
	end
end

function List:setItemPosition(x,y)
	self.item_x = x or 0;
	self.item_y = y or 0;
	self.itemCount = math.floor((self.rect.height - self.item_y)/ self.item_height);
end

function List:setFont(font)
	self.font = font or "_system";
end

function List:_DrawBackground()
	local drawcolor = self.bg_normal_color;
	if not self.enable then
		drawcolor = self.bg_disable_color;
	end
	
	self.picture.gui = self.gui;
	self.item_picture.gui = self.gui;
	
	self.picture.rect = self.rect; 
	self.picture.color = drawcolor;
	self.picture.img = self.background;
	self.picture:drawPic();
end

function List:_PicInit(item, select, check, head)
	local nc, hc, cc = nil, nil, nil;
	local ni, hi, ci = nil, nil, nil;
	if head then
		nc, hc, cc = self.column_head_color,  self.column_head_hover_color,  self.column_head_click_color;
		ni, hi, ci = self.column_head_img,  self.column_head_hover_img,  self.column_head_click_img;
	else
		nc, hc, cc = self.column_color,  self.column_hover_color,  self.column_click_color;
		ni, hi, ci = self.column_img,  self.column_hover_img,  self.column_click_img;
	end
	
	self.item_picture.color = item.bg_normal_color;
	self.item_picture.img = item.bg_normal_img;
	if select then
		if self.click then
			self.item_picture.color = item.bg_click_color;
			self.item_picture.img = item.bg_click_img;
		elseif self.hover then
			self.item_picture.color = item.bg_hover_color;
			self.item_picture.img = item.bg_hover_img;
		end
	elseif check and not head then
		self.item_picture.color = item.bg_check_color;
		self.item_picture.img = item.bg_check_img;
	end
	
	if self.item_picture.color==nil then
		if select then
			if self.click then
				self.item_picture.color = cc;
			elseif self.hover then
				self.item_picture.color = hc;
			end
		elseif check and not head then
			self.item_picture.color = self.column_check_color;
		end
		if self.item_picture.color==nil then
			self.item_picture.color = nc;
		end
	end
	if self.item_picture.img==nil then
		if select then
			if self.click then
				self.item_picture.img = ci;
			elseif self.hover then
				self.item_picture.img = hi;
			end
		elseif check and not head then
			self.item_picture.img = self.column_check_img;
		end
		if self.item_picture.img==nil then
			self.item_picture.img = ni;
		end
	end
end

function List:_LabelInit(item, select, check)
	local font_color = nil;
	if select then
		if self.click then
			font_color = item.font_click_color;
		elseif self.hover then
			font_color = item.font_hover_color;
		end
	elseif check then
		font_color = item.font_check_color;
	else
		font_color = item.font_normal_color;
	end
	if font_color==nil then
		font_color = item.font_normal_color;
	end
	self.gui.graph._setColor(font_color);
end

function List:_DrawItem(item, width, height, select, check, head)
	if item==nil then
		return;
	end
	
	if self.item_draw_mode or head then
		self.item_picture.rect:setRect(0, 0, width, height);
		self:_PicInit(item.content, select, check, head);
		self.item_picture:drawPic();
	end
	
	if item.mode == ItemEnum.label then
		self:_LabelInit(item.content, select, check);
		self.gui.graph._print(item.content.label, item.content.x, item.content.y);
	elseif item.mode == ItemEnum.view then
		item.content:_setGui(self.gui);
		item.content:setSize(width, height);
		item.content:onDraw();
	end
	
	self.gui.graph._setColor(self.border_color);
	if self.border_h then
		self.gui.graph._rectangle("fill", 0, height-self.border_h_size, width, height);
	end
	if self.border_v then
		self.gui.graph._rectangle("fill", width-self.border_v_size, 0, width, height);
	end
end

function List:_DrawHead()
	if not self.show_head then
		return;
	end

	-- 裁剪出头部
	local vl, vt, vw, vh = self.rect:getRect();
	local ml, mt, mw, mh = 0,0,0,0;
	local nl, nt, nw, nh = 0,0,0,0;

	self.item_picture.rect:setRect(0, 0, self.rect.width,self.column_head_height); 
	self.item_picture.img = self.column_head_bg;
	self.item_picture.color = self.column_head_bgcolor;
	self.item_picture:drawPic();
	
	local count = #self.column_head;
	local ox = -self.offset_x;
	local selhead = self.mouse_col==-1;
	for i=self.offset_row+1, count do
		local item = self.column_head[i];
		local selrow = false;
		if selhead then
			selrow = self.mouse_row==i;
		end
		
		ml, mt, mw, mh = ox, 0, item.width, self.column_head_height;
		if i==count and mw < self.rect.width-ox then
			mw = self.rect.width-ox;
		end
		
		nl, nt, nw, nh = MergeRect(0, 0, vw, vh, ml, mt, mw, mh);
		self.gui.graph._setScissor(nl+vl, nt+vt, nw, nh);
		self.gui.graph._push();
		self.gui.graph._translate(ml, mt);
		
		self:_DrawItem(item.item, mw, mh, selrow, false, true)
		
		self.gui.graph._pop();
		ox = ox+item.width;

		if ox>self.rect.width then
			-- 绘制坐标已在区域外
			break;
		end
	end
	
	--恢复裁剪区
	self.gui.graph._setScissor(vl, vt, vw, vh);
end

function List:_DrawColumns()
	local tl, tt = 0, 0;
	local vl, vt, vw, vh = self.rect:getRect();
	local ml, mt, mw, mh = 0, 0, 0, self.column_height;
	local nl, nt, nw, nh = 0,0,0,0;

	local column_count = #self.column;
	local head_count = #self.column_head;
	local ox = -self.offset_x;
	local oy = -self.offset_y;
	
	if self.show_head then
		tl, tt = 0, self.column_head_height;
		vh = vh-self.column_head_height;
	end
	
	for i=self.offset_column+1, column_count do
		local col = self.column[i];
		local selcol = self.mouse_col==i;
		local check = false;

		ox = -self.offset_x;
		mt = oy;
		if self.show_head then
			mt = mt + self.column_head_height;
		end
		
		if not self.item_draw_mode then
			self.item_picture.rect:setRect(0, 0, self.rect.width, self.column_height);
			if selcol then
				if self.click then
					self.item_picture.color = self.column_click_color;
					self.item_picture.img = self.column_click_img;
				elseif self.hover then
					self.item_picture.color = self.column_hover_color;
					self.item_picture.img = self.column_hover_img;
				end
			elseif check then
				self.item_picture.color = self.column_check_color;
				self.item_picture.img = self.column_check_img;
			else
				self.item_picture.color = self.column_color;
				self.item_picture.img = self.column_img;
			end
			if not self.item_picture.color then
				self.item_picture.color = self.column_color;
			end
			if not self.item_picture.img then
				self.item_picture.img = self.column_img;
			end
			
			nl, nt, nw, nh = MergeRect(tl, tt, vw, vh, 0, mt, self.rect.width, self.column_height);
			if nl==nil then
				-- 没有重叠区域
				break;
			end
			self.gui.graph._setScissor(nl+vl, nt+vt, nw, nh);
			self.gui.graph._push();
			self.gui.graph._translate(0, mt);
			self.item_picture:drawPic();
			self.gui.graph._pop();
		end
		
		for j=self.offset_row+1, head_count do
			local head = self.column_head[j];
			local item = col.row[j];
			if item==nil then
				break;
			end
			
			local selrow = selcol;
			if self.item_selection and selcol then
				selrow = self.mouse_row==j;
			end
		
			--裁剪前修正
			ml = ox;
			mw = head.width;
			if j==head_count and mw<self.rect.width-ox then
				mw = self.rect.width-ml;
			end
			
			nl, nt, nw, nh = MergeRect(tl, tt, vw, vh, ml, mt, mw, mh);
			if nl==nil then
				-- 没有重叠区域
				break;
			end
			
			self.gui.graph._setScissor(nl+vl, nt+vt, nw, nh);
			self.gui.graph._push();
			self.gui.graph._translate(ml, mt);
			
			-- 绘制item
			self:_DrawItem(item, mw, mh, selrow, item.content.selected)
			self.gui.graph._pop();
			
			ox = ox+head.width;
			if ox>=self.rect.width then
				-- 绘制坐标已在区域外
				break;
			end
		end
		
		oy = oy+self.column_height+self.column_interval;
		if oy>self.rect.height then
			break;
		end
	end
end

function List:onDraw()
	self:_DrawBackground();
	self:_DrawHead();
	self:_DrawColumns();
end

-- 计算X当前移动距离和最大移动范围
function List:GetMoveXInfo()
	local column_head_width = 0;
	local current_offset = 0;
	
	for i,v in ipairs(self.column_head) do
		column_head_width = column_head_width + v.width;
		if i<self.offset_row+1 then
			current_offset = current_offset + v.width;
		end
	end
	current_offset = current_offset+self.offset_x;
	offset_max = column_head_width-self.rect.width;
	if offset_max<0 then
		offset_max = 0;
	end
	return current_offset, offset_max;
end

-- 计算右边界(内部用)
function List:GetRightBorder()
	local len = #self.column_head;
	local column_head_width = 0;
	local offset_row_max = 0;
	local offset_x_max = 0;
	
	for i=len, 1, -1 do
		column_head_width = column_head_width + self.column_head[i].width;
		if offset_row_max==0 and column_head_width>self.rect.width then
			offset_row_max = i-1;
			offset_x_max = column_head_width-self.rect.width;
		end
	end
	
	return offset_row_max, offset_x_max;
end

-- 计算Y当前移动距离和最大移动范围
function List:GetMoveYInfo()
	local len = #self.column;
	local h = self.rect.height;
	if self.show_head then
		h = h-self.column_head_height;
	end
	local offset_column_max = math.ceil(h/self.column_height);
	
	-- 在self.offset_column最大时,self.offset_y最大值
	local offset_y_max = offset_column_max*self.column_height-h;
	
	-- self.offset_column最大值
	offset_column_max = len-offset_column_max
	
	return self.offset_column*self.column_height+self.offset_y,
		offset_column_max*self.column_height+offset_y_max
end

-- 计算下边界(内部用)
function List:GetBottomBorder()
	local len = #self.column;
	local h = self.rect.height;
	if self.show_head then
		h = h-self.column_head_height;
	end
	local offset_column_max = math.ceil(h/self.column_height);
	
	-- 在self.offset_column最大时,self.offset_y最大值
	local offset_y_max = offset_column_max*self.column_height-h;
	
	-- self.offset_column最大值
	offset_column_max = len-offset_column_max
	return offset_column_max, offset_y_max
end

-- 卷动列表
function List:rollList(dx, dy)
	if dy~=0 then
		self.offset_y = self.offset_y+dy;
		if self.offset_y>self.column_height then
			local od = math.floor(self.offset_y/self.column_height);
			self.offset_y = self.offset_y-od*self.column_height;
			self.offset_column = self.offset_column+od;
		elseif self.offset_y<0 then
			local od = math.ceil(math.abs(self.offset_y)/self.column_height);
			self.offset_y = self.offset_y+od*self.column_height;
			self.offset_column = self.offset_column-od;
		end
		
		if dy>0 then
			local maxc, offset_max = self:GetBottomBorder();
			if self.offset_column > maxc then
				self.offset_column = maxc;
			end
			if self.offset_column == maxc then
				if self.offset_y > offset_max then
					self.offset_y = offset_max;
				end
			end
		else
			if self.offset_column < 0 then
				self.offset_column = 0;
				self.offset_y = 0;
			end
		end
	end
	
	if dx~=0 then
		self.offset_x = self.offset_x+dx;
		-- 计算offset_row和offset_x
		
		if self.offset_x>=0 then
			local row = self.column_head[self.offset_row+1];
			while self.offset_x > row.width do
				self.offset_x = self.offset_x-row.width;
				self.offset_row = self.offset_row+1;
		
				row = self.column_head[self.offset_row+1];
				if row==nil then
					break;
				end
			end
		else
			local row = self.column_head[self.offset_row];
			while self.offset_x < 0 do
				self.offset_x = self.offset_x+row.width;
				self.offset_row = self.offset_row-1;
				
				row = self.column_head[self.offset_row+1];
				if row==nil then
					break;
				end
			end
		end
		
		if dx>0 then
			local maxr, offset_max = self:GetRightBorder();
			if self.offset_row > maxr then
				self.offset_row = maxr;
			end
			if self.offset_row==maxr then
				if self.offset_x > offset_max then
					self.offset_x = offset_max;
				end
			end
		else
			if self.offset_row < 0 then
				self.offset_row = 0;
				self.offset_x = 0;
			end
		end
	end
end

function List:Selection(x, y)
	local col,row = 0,0;
	local ox, oy = 0,0;
	local item = nil;
	local rx, rw = -self.offset_x, 0;
	local count = #self.column_head;
	for i=self.offset_row+1, count do
		item = self.column_head[i];
		rw = item.width;
		if i==count and rw < self.rect.width-rx then
			rw = self.rect.width-rx;
		end
		
		if x<rx+rw then
			row = i;
			ox = x-rx;
			break;
		end
		
		rx = rx+item.width;
		if rx>self.rect.width then
			break;
		end
	end
	
	local ry, rh = -self.offset_y, self.column_height;
	if self.show_head then
		if y < self.column_head_height then
			return -1, row;
		else
			y = y-self.column_head_height;
		end
	end
	
	local column_count = #self.column;
	for i=self.offset_column+1, column_count do
		if y<ry+rh and y>=ry then
			col = i;
			oy = y-ry;
			break;
		end
		
		ry = ry+rh+self.column_interval;
		if ry>self.rect.height or y<ry then
			break;
		end
	end
	
	return col, row, ox, oy;
end

function List:onLeave()
	self.hover = false;
	self.click = false;
end

function List:onMouseMove(x, y)
	self.hover = true;
	self.mouse_col, self.mouse_row = self:Selection(x, y)
end 

function List:onMousePressed(x, y, button)
	if button==ViewMouseEnum.LB then
		self.click = true;
		local ox, oy = 0, 0;
		
		self.mouse_col, self.mouse_row, ox, oy = self:Selection(x, y)
		if self.mouse_col==-1 then
			-- head 点击
			local head = self.column_head[self.mouse_row];
			if head==nil then
				return;
			end
			local hitem = head.item;
			if hitem==nil then
				return;
			end
			
			if hitem.mode == ItemEnum.label then
				self:on_head_click(self.mouse_row);
			elseif hitem.mode == ItemEnum.view then
				hitem.content:mousepressed(ox, oy, button);
				--hitem.content:mousereleased(ox, oy, button);
				self:on_head_click(self.mouse_row);
			else
				return;
			end
		else
			local col = self.column[self.mouse_col];
			if col==nil then
				return;
			end
			
			if self.single_selection then
				local last = self.single_selection_idx;
				if self.single_selection_idx == self.mouse_col then
					-- 检测是否被选中
					col:unselectAll();
					self.single_selection_idx = nil;
				else
					-- 检测设置选中状态
					if self.single_selection_idx~=nil then
						local last_sel = self.column[self.single_selection_idx];
						if last_sel~=nil then
							last_sel:unselectAll();
						end
					end
					col:selectAll();
					self.single_selection_idx = self.mouse_col;
				end
				self:on_column_unselect(last);
				self:on_column_select(self.single_selection_idx);
				self:on_single_column_select(self.single_selection_idx, last);
			else
				if self.item_selection then
					local item = col.row[self.mouse_row];
					if item==nil then
						return;
					end
					
					if item.mode == ItemEnum.label then
						item.content.selected = not item.content.selected;
						if item.content.selected then
							self:on_item_select(self.mouse_col, self.mouse_row);
						else
							self:on_item_unselect(self.mouse_col, self.mouse_row);
						end
					elseif item.mode == ItemEnum.view then
						item.content:mousepressed(ox, oy, button);
						--item.content:mousereleased(ox, oy, button);
						self:on_item_select(self.mouse_col, self.mouse_row);
					else
						return;
					end
				else
					if col.selected then
						col:unselectAll();
						self:on_column_unselect(self.mouse_col);
					else
						col:selectAll();
						self:on_column_select(self.mouse_col);
					end
				end
			end
		end
	end
end

function List:onMouseReleased(x, y, button)
	if button==ViewMouseEnum.LB then
		self.click = false;
	end
end

return List;

