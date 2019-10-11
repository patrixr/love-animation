Love2D Animation library
==============

A utility class to create animated sprites with Love2D.

Every animation is defined by:
* an image file
* an animation file (.lua)

The animation file describes the different frames and states of the animation, as well as the animation properties.

Take a look at [animation.template.lua](animation.template.lua) for an example.

## Quick start

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

**Changing the animation state**
```lua
anim:setState("jump")
```

## Features

### Changing state

Each state represent a row of the spritesheet, and has been defined in the animation file

```lua
anim:setState('jump')
```

Each state contains a `nextState` property which will run when all the frames have been iterated through.
To create a looping animation, a state can simply have itself as the `nextState`

Reading the current state can be done with

```lua
anim:getCurrentState()
```

### Speeding up / Slowing down

A "speed multiplier" can be set to either speed up or slow down the animation

```lua
anim:setSpeedMultiplier(0.5) -- slow down
anim:setSpeedMultiplier(2) -- speed up
```

### Pausing the animation

```lua
anim:pause()
anim:unnpause()
anim:togglePause()
```

### Callbacks

```lua
function doSomething()

end

anim:onStateStart('jumpStart', doSomething)

### Cloning the animation

To create multiple instances of an animation, a clone method exists

```lua
anim:clone()
```

### Scaling

The `draw` method accepts scaling arguments in order to change the size of the image

```lua
anim:draw(scaleX, scaleY)
```

### Position / Geometry / Intersections

```lua
anim:getGeometry()
anim:intersects(x,y,width,height)
anim:setPosition(x, y)
anim:setRotation(r)
anim:setRelativeOrigin(ox, oy)
anim:setHorizontalFlip(true);
anim:getFrameWidth();
anim:getFrameHeight();
anim:getFrameDimension();
```

### Visibility

```lua
anim:setVisibility(false)
```

## Jumping to specific frames

The current frame can be manually selected

```lua
anim:setCurrentFrame(3)
```


