return {
	imageSrc = "sprite_sheet.png",
	defaultState = "running",
	states = {
		running = {
			framceCount = 3,
			offsetY = 0,
			frameW = 100,
			frameH = 100,
			nextState = "running",
			switchDelay = 0.1
		},
		jump = {
			framceCount = 3,
			offsetY = 100,
			frameW = 100,
			frameH = 100,
			nextState = "running",
			switchDelay = 0.1
		}
	}
}
