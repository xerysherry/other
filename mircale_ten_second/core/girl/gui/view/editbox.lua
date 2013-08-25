
----------------------------------------------------------------
-- write by xerysherry

-- 得到View类
local View = getClass("Object.View");
local Rect = getClass("Object.Rect");
local SpecialKeyEnum = getClass("Object.SpecialKeyEnum");
local Picture = getClass("Object.View.Picture");
local Utf8 = getClass("Object.Utf8")

-- 标签
local EditBox = class("EditBox", View, 
{
	maxlen = 64,
	limitmax = false,
	font = "_system",
	text = nil,
	text_color = nil,
	pos = 0,					-- 字符插入位置
	
	_text_x = 0,				-- 文本显示位置
	_text_y = 0,
	_text_rect = nil,
	_chars_width = nil,			-- 字符宽度记录
	
	curosr_color = nil,
	_cursor_fc = 0,				--光标刷新
	_cursor_flash = 8,
	_cursor_show = false,
	_cursor_x = 0,				-- 光标位置
	_cursor_y = 0,
	
	picture = nil,
	
	allow_tab = false,			-- 制表符
	allow_enter = false,		-- 换行符
	allow_mark = true,			-- (,./;'][\-= ...) 即除数字和字母以外字符
	allow_number = true,		-- (0-9)
	allow_letter = true,		-- (A-Z)
	
	onTextChange = function (this) end,
});

function EditBox:initialize(w, h)
	View.initialize(self, w, h);
	self.picture = Picture(w, h);
	self.text_color = {0,0,0};
	self.cursor_color = {0,0,0};
	self._text_rect = Rect(0,0,w,h);
	self._chars_width = {[0]=0};
	self.text = Utf8:new();
end

function EditBox:setLimit(limit, len)
	self.limitmax = limit or false;
	self.maxlen = len or self.maxlen;
end

function EditBox:setFont(font)
	self.font = font or "_system";
end

function EditBox:setCursorColor(color)
	self.curosr_color = color or {0,0,0};
end

function EditBox:setTextColor(color)
	self.text_color = color or {0,0,0};
end

function EditBox:setText(text)
	local text = Utf8:new(tostring(text));
	if text.str~=self.text.str then
		self.text = text;
		self:onTextChange();
	end
	self._chars_width = {};
	self._chars_width[0] = 0;
	self._cursor_x = 0;
	self._text_x = 0;
	self.pos = 0;
	local len = text.len;
	local font = self.gui.graph:getFont(self.font);
	for i=1, len do
		table.insert(self._chars_width, font:getWidth(text:sub(i,i)));
	end
	
	self:CursorNext(len)
	self.pos = len;
end

function EditBox:setTextRect(x, y, w, h)
	local lx, ly, lw, lh = self._text_rect:getRect();
	self._text_rect:setRect(x or lx, y or ly, w or lw, h or lh);
end

function EditBox:getText()
	return self.text.str;
end

function EditBox:setBorder(img)
	self.picture:setImage(img);
end

function EditBox:setBorderColor(color)
	self.picture:setImageColor(color);
end

function EditBox:setMode(...)
	self.picture:setMode(...);
end

function EditBox:onMousePressed(x, y, button)
	local tx = - self._text_x + x - self._text_rect.x;
	for i, v in ipairs(self._chars_width) do
		if tx < v/2 then
			self:SetPos(i-1);
			return;
		end
		tx = tx - v;
	end
	self:SetPos(self.text.len);
end

function EditBox:onKeyPressed(key)
	if key=="left" then
		self:MovePrev();
	elseif key=="right" then
		self:MoveNext();
	elseif key=="home" then
		self:CursorPrev(1);
		self.pos=0;
	elseif key=="end" then
		local len = self.text.len;
		self._cursor_x = 0;
		self._text_x = 0;
		self.pos = 0;
		self:CursorNext(len);
		self.pos=len;
	end
end

function EditBox:Keyin(char)
	if self.limitmax then
		if self.text.len >= self.maxlen then
			return;
		end
	end

	local ps = self.text:sub(0, self.pos);
	local ns = self.text:sub(self.pos+1, -1);
	local text = "";
	if ps then
		text = text..ps;
	end
	text = text..char;
	if ns then
		text = text..ns;
	end
	
	self.pos = self.pos + 1;
	self.text = Utf8:new(text);
	
	-- 插入字符宽度
	local font = self.gui.graph:getFont(self.font);
	table.insert(self._chars_width, self.pos, font:getWidth(char));
	
	-- 向后移动光标
	self:CursorNext(self.pos);
	self:onTextChange();
end

function EditBox:MoveNext()
	if self.pos+1>self.text.len then
		return;
	end
	self.pos = self.pos+1;
	-- 向后移动光标
	self:CursorNext(self.pos);
end

function EditBox:MovePrev()
	if self.pos==0 then
		return;
	end
	-- 向前移动光标
	self:CursorPrev(self.pos);
	self.pos = self.pos-1;
end

function EditBox:Backspace()
	if self.pos==0 then
		return;
	end

	self:CursorPrev(self.pos);
	
	local ps = self.text:sub(0, self.pos-1);
	local ns = self.text:sub(self.pos+1, -1);
	local text = "";
	if ps then
		text = text..ps;
	end
	if ns then
		text = text..ns;
	end
	
	-- 删除宽度记录
	table.remove(self._chars_width, self.pos);
	self.pos = self.pos - 1;
	self.text = Utf8:new(text);
	
	self:onTextChange();
end

function EditBox:SetPos(pos)
	local prev_text_x = self._text_x;
	self._cursor_x = 0;
	self._text_x = 0;
	self.pos = 0;
	self:CursorNext(pos);
	self.pos=pos;
	
	--恢复之前的绘制坐标状态
	self._cursor_x = self._cursor_x+(prev_text_x-self._text_x );
	self._text_x = prev_text_x;
end

function EditBox:CursorNext(pos)
	for i=pos, self.pos, -1 do
		self._cursor_x = self._cursor_x + self._chars_width[i];
	end
	if self._cursor_x > self._text_rect.width then
		self._text_x = self._text_x + self._text_rect.width - self._cursor_x;
		self._cursor_x = self._text_rect.width;
	end
end

function EditBox:CursorPrev(pos)
	for i=pos, self.pos do
		self._cursor_x = self._cursor_x - self._chars_width[i];
	end
	if self._cursor_x < self._chars_width[pos-1] then
		self._text_x = self._text_x - self._cursor_x+self._chars_width[pos-1];
		self._cursor_x = self._chars_width[pos-1];
	end
end

function EditBox:onChar(char)
	-- 检查数字
	local function CheckNum(char)
		local b = string.byte(char);
		return (0x30<=b and b<=0x39);
	end
	--检查大写字母
	local function CheckUppercase(char)
		local b = string.byte(char);
		return (0x41<=b and b<=0x5a);
	end
	--检查小写字母
	local function CheckLowercase(char)
		local b = string.byte(char);
		return (0x61<=b and b<=0x7a);
	end
	
	if SpecialKeyEnum.check(char, SpecialKeyEnum._tab) then
		if self.allow_tab then
			self:Keyin(char);
		end
	elseif SpecialKeyEnum.check(char, SpecialKeyEnum._enter) then
		if self.allow_enter then
			self:Keyin(char);
		end
	elseif SpecialKeyEnum.check(char, SpecialKeyEnum._backspace) then
		self:Backspace();
	elseif SpecialKeyEnum.check(char, SpecialKeyEnum._escape) then
		return;
	else
		if CheckNum(char) then
			if not self.allow_number then
				return;
			end
		elseif CheckUppercase(char) or CheckLowercase(char) then
			if not self.allow_letter  then
				return;
			end
		else
			if not self.allow_mark then
				return;
			end
		end
		self:Keyin(char);
	end
end
 
function EditBox:onUpdate()
	if self:checkFocus() then
		self._cursor_fc = self._cursor_fc+1;
		if self._cursor_fc >= self._cursor_flash*2 then
			self._cursor_fc = 0;
		end
		self._cursor_show = self._cursor_fc<self._cursor_flash;	
	else
		self._cursor_show = false;
	end
end

-- 绘制
function EditBox:DrawText()
	local vl, vt, vw, vh = self.rect:getRect();
	local ml, mt, mw, mh = self._text_rect:getRect();
	local nl, nt, nw, nh = MergeRect(0, 0, vw, vh, 
		-- 偏移View Rect
		ml, mt, mw, mh);
	if nl==nil then
		return;
	end
	
	--设置裁剪区
	self.gui.graph._setScissor(nl+vl, nt+vt, nw, nh);
	
	--转换
	self.gui.graph._push();
	self.gui.graph._translate(ml, mt);
	
	if self.text.str~="" then
		self.gui.graph:setFont(self.font);
		self.gui.graph._setColor(self.text_color);
		self.gui.graph._print(self.text.str, ml+self._text_x, mt);
	end
	self.gui.graph._setScissor(vl, vt, vw, vh);
	self:DrawCursor();
	self.gui.graph._pop();
end

function EditBox:DrawBorder()
	self.picture.gui = self.gui;
	self.picture.rect = self.rect; 
	self.picture:drawPic();
end

function EditBox:DrawCursor()
	if not self._cursor_show then
		return;
	end
	
	local h = self.gui.graph:getFont(self.font):getHeight();
	self.gui.graph._setColor(self.cursor_color);
	self.gui.graph._rectangle("fill",self._cursor_x, self._cursor_y,
		1, h);
end

function EditBox:onDraw()
	self:DrawBorder();
	self:DrawText();
end

return EditBox;
