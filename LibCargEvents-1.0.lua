--[[
Name: LibCargEvents-1.0
Author: Cargor (xconstruct@gmail.com)
Dependencies: LibStub
License: GPL 2
Description: Library to handle events
]]

local lib = LibStub:NewLibrary("LibCargEvents-1.0", 3)
if(not lib) then return end

local lazyCounter = 0
local events = {}
local metahandlers = {}
local frame = CreateFrame("Frame")
function lib.RegisterEvent(self, event, func)
	if(not func and type(event) == "function") then
		lazyCounter = lazyCounter + 1
		func, event, self = event, self, lazyCounter
	elseif(self == lib) then
		lazyCounter = lazyCounter + 1
		self = lazyCounter
	end
	events[event] = events[event] or {}
	local thisEvent = events[event]
	thisEvent[self] = func
	if(thisEvent.__count) then
		thisEvent.__count = thisEvent.__count+1
	else
		thisEvent.__count = 1
		frame:RegisterEvent(event)
	end
	return self
end

function lib.UnregisterEvent(self, event)
	if(not lib.IsEventRegistered(self, event)) then return end
	local thisEvent = events[event]
	thisEvent[self] = nil
	thisEvent.__count = thisEvent.__count-1
	if(thisEvent.__count == 0) then
		frame:UnregisterEvent(event)
		thisEvent.__count = nil
	end
end

function lib.IsEventRegistered(self, event)
	return events and events[event] and events[event][self] and true
end

function lib.SetMetaHandler(self, func)
	metahandlers[self] = func
end

function lib:Embed(target)
	for k,v in pairs(self) do
		target[k] = v
	end
end
gEvents = events
frame:SetScript("OnEvent", function(self, event, ...)
	for frame, func in pairs(events[event]) do
		if(frame ~= "__count" and (not metahandlers[self] or metahandlers[self](self, event, ...))) then
			func(frame, event, ...)
		end
	end
end)

setmetatable(lib, {__call = lib.RegisterEvent})
