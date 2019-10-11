--
--
-- TEST LOVE APP
--
--
--

package.path = package.path .. ";../?.lua"
require('../animation')

local anim = nil
local states = nil
local buttonWidth = 200
local buttonHeight = 50

function love.load(arg)
	love.graphics.setBackgroundColor({0, 0, 0})

	local file = 'sprites/animation1.lua'
	for i, param in ipairs(arg) do
		if string.find(param, ".lua") then
			file = param
			break
		end
	end

	print("Loading animation file : " ..  file)
	anim = LoveAnimation.new(file)
	anim:setSpeedMultiplier(1)
	states = anim:getAllStates()
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.push('quit')
	end
end

function love.draw()

	love.graphics.setColor({255,255,255})
	
	local textX = love.graphics.getWidth() - buttonWidth
	for i,state in ipairs(states) do 
		love.graphics.rectangle("line", textX, (i - 1) * buttonHeight, buttonWidth, buttonHeight)
		love.graphics.print(state, textX + 30, (i - 1) * buttonHeight + 20)
	end
	
	
	anim:draw()
	love.graphics.print("Current state: " .. anim:getCurrentState(), 0, 300)
	
	-- draw hitbox
	love.graphics.setColor({255,0,0})
	love.graphics.rectangle("line", 0, 0, anim:getFrameWidth(), anim:getFrameHeight() )
	
end

function love.mousepressed()
	local x, y = love.mouse.getX(), love.mouse.getY()
	if x > (love.graphics.getWidth() - buttonWidth) then 
		local idx = math.ceil(y / buttonHeight) 
		if idx <= #states then
			anim:setState(states[idx])
		end
	end
end

function love.update(dt)

	anim:update(dt)

end
