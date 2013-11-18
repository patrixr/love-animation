love-animation
==============

Love2D Animation


A utility class to create animated sprites with Love2D.

Every animation is defined by an image file, and an animation file.
The animation file describes the different frames and states of the animation, as well as the animation properties.

Take a look at animation.template.lua for an example.

Quick snippets to start using Love Animation : 

**Loading the animation**
```lua
local anim = LoveAnimation.new('sprites/animation1.lua');
```

**Updating the animation**
```lua
function love.update(dt)

  -- update things ...
  
	anim:update(dt)

end
```

**Drawing the animation**
```lua
function love.draw()

  -- draw things ...

	anim:draw()

end
```
