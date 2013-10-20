--
--
-- TEST LOVE APP
--
--
--

require('animlove')

local anim = nil

function love.load(arg)
	love.graphics.setBackgroundColor({0, 0, 0})
	anim = LoveAnimation.new('sprites/animation1.lua');
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.push('quit')
	elseif key == "up" then
		anim:setState("jumpStart")
	end
end

function love.keyreleased(key)
	-- if key == 'up'
	-- or key == 'w'
	-- or key == 'down'
	-- or key == 's'then
	-- 	Player.speed = 0
	-- end
end

function love.draw()

	anim:draw()
	love.graphics.print(anim.currentState, 300, 300)

end

function love.update(dt)

	anim:update(dt)

end
