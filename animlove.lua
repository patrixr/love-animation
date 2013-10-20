--[[

The MIT License (MIT)

Copyright (c) 2013 Patrick Rabier

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

]]

--
-- LOVE2D ANIMATION
--
-- @todo document
-- @todo error management
--

--
-- The animation class
-- Loads an animation file (containing a path to the image)
-- Check the animation file template for the format
-- 
-- @member filepath the path of the animation file
-- @member descriptor the object loaded from the file (describes the animation frames)
-- @member currentState the state the animation is in. Each state is a line in the image
-- @member currentFrame the frame (of the current state) the animation is displaying
-- @member tick the amount of time the current frame has been displayed
-- @member speedMultiplier a multiplier used to control the animation speed programatically
-- @member active whether the animation is running (or is paused)
-- @member texture the image loaded
-- @member x horizontal coordinate
-- @member y vertical coordinate
-- @member rotation rotation angle in radians
-- @member relativeOriginX the x origin as a multiplier of the sprite's width
--	(ex : 1 for right, 0 for left)
-- @member relativeOriginY the y origin as a multiplier of the sprite's height
-- @member visible boolean, whether the sprite is visible
--
LoveAnimation = {
	-- Members
	filepath = nil,
	descriptor = nil,
	currentState = nil,
	currentFrame = 0,
	tick = 0,
	speedMultiplier = 1,
	active = true,
	texture = nil,
	x = 0,
	y = 0,
	rotation = 0,
	relativeOriginX = 0,
	relativeOriginY = 0,
	visible = true,

	-- Static
	__loadedDescriptors = {}
}
LoveAnimation.__index = LoveAnimation

-- Local function
local check_descriptor_integrity = function(desc)
	-- @TODO
end

--
-- @brief Creates a new animation
-- @param filepath the file describing the animation
-- @return the animation object
--
function LoveAnimation.new(filepath)

	local desc = nil
	if LoveAnimation.__loadedDescriptors[filepath] then
		desc = LoveAnimation.__loadedDescriptors[filepath]
	else
		local chunk = love.filesystem.load(filepath)
		desc = chunk()
		check_descriptor_integrity(desc);
		LoveAnimation.__loadedDescriptors[filepath] = desc;
	end

	local new_anim = {}
	setmetatable(new_anim, LoveAnimation)
	new_anim.filepath = filepath
	new_anim.descriptor = desc
	new_anim.texture = love.graphics.newImage(desc.imageSrc)
	new_anim:resetAnimation()

	return new_anim
end

--
--
--
--
function LoveAnimation:update(dt)

	if self.active == false then
		return -- paused
	end

	self.tick = self.tick + dt * self.speedMultiplier
	local state_descriptor = self.descriptor.states[self.currentState]

	if self.tick > state_descriptor.switchDelay then
		-- switch to the next frame
		self.currentFrame = self.currentFrame + 1
		if self.currentFrame >= state_descriptor.frameCount then
			-- last frame reached, set next state	
			self.currentFrame = 0
			self.currentState = state_descriptor.nextState
		end
		-- reset tick
		self.tick = 0

	end


end

--
--
--
--
function LoveAnimation:draw()

	if not self.visible then
		return
	end

	local state_descriptor = self.descriptor.states[self.currentState]
	local quad = nil

	-- we save the quads for each frame to avoid recreating them everytime
	if not state_descriptor.quads then
		state_descriptor.quads = {}
	end
	if not state_descriptor.quads[self.currentFrame] then
		-- the quad for the current frame has not been created
		quad = love.graphics.newQuad(
				self.currentFrame * state_descriptor.frameW,
				state_descriptor.offsetY,
				state_descriptor.frameW,
				state_descriptor.frameH,
				self.texture:getWidth(),
				self.texture:getHeight())
		-- we save it
		state_descriptor.quads[self.currentFrame] = quad
	else
		quad = state_descriptor.quads[self.currentFrame]
	end

	love.graphics.drawq(self.texture,
		quad,
		self.x,
		self.y,
		self.rotation,
		1, 1, -- scale
		self.relativeOriginX * state_descriptor.frameW,
		self.relativeOriginY * state_descriptor.frameH,
		0,0)

end

--
--
--
--
function LoveAnimation:setState(state)

	if self.descriptor.states[state] then
		self.currentState = state
		self.tick = 0
		self.currentFrame = 0
	end

end

--
--
--
--
function LoveAnimation:setSpeedMultiplier(sm)
	self.speedMultiplier = sm
end

--
--
--
--
function LoveAnimation:resetAnimation()

	self.currentState = self.descriptor.defaultState
	self.tick = 0
	self.speedMultiplier = 1
	self.active = true
	self.currentFrame = 0
	self.rotation = 0

end

--
--
--
--
function LoveAnimation:togglePause()
	self.active = not self.active
end

--
--
--
--
function LoveAnimation:pause()
	self.active = false
end

--
--
--
--
function LoveAnimation:unpause()
	self.active = true
end

--
--
--
--
function  LoveAnimation:setPosition(x, y)
	self.x = x
	self.y = y
end

--
--
--
--
function  LoveAnimation:setRotation(r)
	self.rotation = r
end

--
--
--
--
function  LoveAnimation:setVisibility(v)
	self.visible = v
end

--
--
--
--
function LoveAnimation:setRelativeOrigin(ox, oy)
	self.relativeOriginX = ox
	self.relativeOriginY = oy
end

--
-- EVENTS
--

--
--
--
--
function LoveAnimation:onStateEnd(state, callback)

end

--
--
--
--
function LoveAnimation:onStateStart(state, callback)

end


