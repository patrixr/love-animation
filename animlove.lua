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
-- @todo the path in the animation file should be relative to the file's location
-- @todo more flexible events ?
-- @todo load an animation with an already loaded image
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
	flipX = 1,

	_stateEndCallbacks = {},
	_stateStartCallbacks = {},

}
LoveAnimation.__index = LoveAnimation


-- Static
local __loadedDescriptors = {}


-- Local function
local check_descriptor_integrity = function(desc)
	-- @TODO
end

--
-- @brief Creates a new animation
-- @param filepath the file describing the animation
-- @param imagePath [optional] an alternative image
-- @return the animation object
--
function LoveAnimation.new(filepath, imagePath)

	local desc = nil
	if __loadedDescriptors[filepath] then
		desc = __loadedDescriptors[filepath]
	else
		local chunk = love.filesystem.load(filepath)
		desc = chunk()
		check_descriptor_integrity(desc);
		__loadedDescriptors[filepath] = desc;
	end

	local new_anim = {}
	setmetatable(new_anim, LoveAnimation)
	new_anim.filepath = filepath
	new_anim.descriptor = desc
	new_anim.texture = imagePath and love.graphics.newImage(imagePath) or love.graphics.newImage(desc.imageSrc)
	new_anim:resetAnimation()

	return new_anim
end

--
-- @brief Clones the animation (avoids reloading)
-- @return the new animation object
--
function LoveAnimation:clone()
	local new_anim = {}
	setmetatable(new_anim, LoveAnimation)

	new_anim.filepath = self.filepath
	new_anim.descriptor = self.descriptor
	new_anim.texture = self.texture
	new_anim:resetAnimation()
	return new_anim
end

--
-- @brief Updates the animation state and frame. Called in the update loop
-- @param dt the elapsed time in seconds (floating point)
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

			if not state_descriptor.nextState then
				self.currentFrame = state_descriptor.frameCount - 1
				self.tick = 0
				return
			end

			self.currentFrame = 0
			--callbacks
			if self._stateEndCallbacks[self.currentState] then
				self._stateEndCallbacks[self.currentState](self)
			end
			
			if state_descriptor.nextState ~= self.currentState and
				self._stateStartCallbacks[state_descriptor.nextState] then
				self._stateStartCallbacks[state_descriptor.nextState](self)
			end

			self.currentState = state_descriptor.nextState
		end
		-- reset tick
		self.tick = 0

	end


end

--
-- @brief Draws the sprite on the screen. Called in the drawing loop
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
		self.flipX, -- negative scale to flip
		1, -- scale
		self.relativeOriginX * state_descriptor.frameW,
		self.relativeOriginY * state_descriptor.frameH,
		0,0)

end

--
-- @brief Sets the state of the animation
-- @param state (string) a state specified in the animation file that we want to switch to
-- e.g anim:setState("jump")
--
function LoveAnimation:setState(state)

	if self.descriptor.states[state] then
		self.currentState = state
		self.tick = 0
		self.currentFrame = 0

		if state ~= self.currentState and self._stateStartCallbacks[state] then
			self._stateStartCallbacks[state]()
		end

	end

end

--
-- @brief Gets the state the animation is currently in
-- @return (string) the current state
--
function LoveAnimation:getCurrentState()
	return self.currentState;
end

--
-- @brief Sets the frame of the animation state
-- @param f (integer) the frame number
--
function LoveAnimation:setCurrentFrame(f)

	local state_descriptor = self.descriptor.states[self.currentState]
	if f < state_descriptor.frameCount then
		self.currentFrame = f
	else
		self.currentFrame = state_descriptor.frameCount - 1 -- Is that wise ?
	end

end

--
-- @brief Allows to speed up the animation with a multiplier
-- @param sm (positive floating point) the multiplier
--
function LoveAnimation:setSpeedMultiplier(sm)
	-- negative multiplier support ? backwards animations ? to think abt it
	self.speedMultiplier = math.abs(sm)
end

--
-- @brief Returns the animation to it's inital state,frame,speed,rotation
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


local _CheckCollision = function(ax1,ay1,aw,ah, bx1,by1,bw,bh)
  local ax2,ay2,bx2,by2 = ax1 + aw, ay1 + ah, bx1 + bw, by1 + bh
  return ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1
end

--
-- @brief Checks for a collision between the sprite quad and the specified rectangle
-- @return true if the two quads intersect, false otherwise
--
function LoveAnimation:intersects(x,y,width,height)
	local h = height or 1
	local w = width or 1
	local state_descriptor = self.descriptor.states[self.currentState]

	return _CheckCollision(
		self.x - (self.relativeOriginX * state_descriptor.frameW),
		self.y - (self.relativeOriginY * state_descriptor.frameH),
		state_descriptor.frameW,
		state_descriptor.frameH,
		x,y,w,h
	)
end

--
-- @brief Switches the pause 
--
--
function LoveAnimation:togglePause()
	self.active = not self.active
end

--
-- @brief Pauses the animation
--
--
function LoveAnimation:pause()
	self.active = false
end

--
-- @brief Unpauses the animation
--
--
function LoveAnimation:unpause()
	self.active = true
end

--
-- @brief Sets the sprite's current position
-- @param x the x coordinate of the sprite
-- @param y the y coordinate of the sprite
--
function  LoveAnimation:setPosition(x, y)
	self.x = x
	self.y = y
end

--
-- @brief Rotates the sprite to the specified angle
-- @param r rotation angle (according to the love drawing functions)
--
function  LoveAnimation:setRotation(r)
	self.rotation = r
end

--
-- @brief Sets the sprite as visible or invisible
-- @param v (bool) true if visible, false if invisible
--
function  LoveAnimation:setVisibility(v)
	self.visible = v
end

--
-- @brief Sets the origin of the sprite (default is top left corner)
-- @param ox the x coordinate
-- @param oy the y coordinate
--
-- The coordinates are a percentage relative to the sprite.
-- e.g : setRelativeOrigin(0,0) is the top left corner
-- e.g : setRelativeOrigin(0.5,0.5) is the center of the sprite
--
function LoveAnimation:setRelativeOrigin(ox, oy)
	-- rename to setAnchorPoint (perhaps clearer)
	self.relativeOriginX = ox
	self.relativeOriginY = oy
end

--
-- @brief Flips the sprite horizontally
--
-- attention : the flips is dependant on the origin
--
function LoveAnimation:toggleHorizontalFlip()
	self.flipX = -1 * self.flipX
end

--
-- @brief Flips the sprite horizontally according to bool
-- @param bool (bool) true if the sprite should be flipped horizontally
--
-- attention : the flips is dependant on the origin
--
function LoveAnimation:setHorizontalFlip(bool)
        self.flipX = bool and -1 or 1
end

--
-- @brief Gets the width of the current frame
-- @return the current width
--
function LoveAnimation:getFrameWidth()
	local state_descriptor = self.descriptor.states[self.currentState]
	return state_descriptor.frameW
end

--
-- @brief Gets the height of the current frame
-- @return the current height
--
function LoveAnimation:getFrameHeight()
	local state_descriptor = self.descriptor.states[self.currentState]
	return state_descriptor.frameH
end


--
-- EVENTS
--

--
-- @brief Adds a listener to the animation. Called when the last frame of a state is reached
-- @param state (string) The name of the state
-- @param callback (function) The callback function, recieves the LoveAnimation object as param
-- Set the callback to nil to stop receiving events
-- 
function LoveAnimation:onStateEnd(state, callback)

	self._stateEndCallbacks[state] = callback

end

--
-- @brief Adds a listener to the animation. Called when the state starts
-- @param state (string) The name of the state
-- @param callback (function) The callback function, recieves the LoveAnimation object as param
-- Set the callback to nil to stop receiving events
--
function LoveAnimation:onStateStart(state, callback)

	self._stateStartCallbacks[state] = callback

end


