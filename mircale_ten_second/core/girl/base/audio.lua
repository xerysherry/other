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

local lf = love.filesystem;
local la = love.audio;
local ls = love.sound;
if la==nil then
	return nil;
end

-- 得到基类
local Object = getClass("Object");
-- 得到文件系统类
local Filesystem = getClass("Object.Filesystem");

-- 声音对象
local Sound = class("Sound", Object,
{
	path = nil,			--路径
	src = nil,			--声音源
});

-- 音频管理器
local Audio = class("Audio", Object,
{
	-- 音频文件系统
	filesystem = nil,
	--列表
	sounds = nil,
});

----------------------------------------------------------------
-- 初始化一个音频管理器
function Audio:initialize(tempdir)
	-- 初始内部文件系统类
	self.filesystem = Filesystem:new(tempdir);
	self.sounds = {};
end

----------------------------------------------------------------
-- 查找相同路径的声音
function Audio:getSamePathSound(path)
	if path==nil then
		return nil;
	end
	
	for i,v in pairs(self.sounds) do
		if path==v.path then
			return v;
		end
	end
	return nil;
end

-- 创建声音
function Audio:createSoundFromPath(idx, path, mode)
	self.sounds[idx] = self:getSamePathSound(path);
	if self.sounds[idx]==nil then
		self.sounds[idx] = Sound:new();
		self.sounds[idx].path = path;
		self.sounds[idx].src = la.newSource(path, mode);
	end
end

-- 通过数据流(binary)创建声音
-- 注：在存档文件夹下产生一个临时文件，然后交由la
function Audio:createSoundFromStream(idx, data, mode)
	local path = self.filesystem:createTempFromData(idx, data);
	self:createSoundFromPath(idx, path, mode);
end

-- 读取一个声音文件（使用lua的filesystem读取，
-- 支持相对路径和全路径，在需要包外资源时使用之）
function Audio:createSoundFromPathPlus(idx, path, mode)
	local path = self.filesystem:createTempFromPath(idx, path);
	Audio:createSoundFromPath(idx, path, mode);
end

-- 返回源
function Audio:getSound(idx)
	local snd = self.sounds[idx];
	if snd==nil then
		return nil;
	end
	return snd.src;
end

----------------------------------------------------------------
-- 直接复制love.audio的方法
Audio.getNumSources = la.getNumSources;
Audio.getOrientation = la.getOrientation;
Audio.getPosition = la.getPosition;
Audio.getVelocity = la.getVelocity;
Audio.getVolume = la.getVolume;
Audio.setOrientation = la.setOrientation;
Audio.setPosition = la.setPosition;
Audio.setVelocity = la.setVelocity;
Audio.setVolume = la.setVolume;

Audio.pause = la.pause;
Audio.play = la.play;
Audio.resume = la.resume;
Audio.rewind = la.rewind;
Audio.stop = la.stop;

return Audio;
