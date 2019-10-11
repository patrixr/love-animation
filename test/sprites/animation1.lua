return {
	imageSrc = "sprites/sprite_sheet.png",
	defaultState = "running",
	states = {
		running = {
			frameCount = 3,
			offsetY = 0,
			frameW = 100,
			frameH = 90,
			nextState = "running",
			switchDelay = 0.1
		},
		jumpStart = {
			frameCount = 3,
			offsetY = 100,
			frameW = 100,
			frameH = 90,
			nextState = "jumpEnd",
			switchDelay = 0.16
		},
		jumpEnd = {
			frameCount = 3,
			offsetY = 200,
			frameW = 100,
			frameH = 90,
			nextState = "running",
			switchDelay = 0.1
		}
	}
}
