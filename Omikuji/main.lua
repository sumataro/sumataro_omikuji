--physics settings
local physics = require("physics")
physics.start()
physics.setGravity( 0, 0 )

--constants
_W = display.contentWidth
_H = display.contentHeight

--forward declartions
counter = 0
num = 0

-- load music
sound = audio.loadSound("sound.mp3")
sound1 = audio.loadSound("sound1.mp3")
sound2 = audio.loadSound("sound2.mp3")
sound3 = audio.loadSound("sound3.mp3")
sound_shout = audio.loadSound("sound_shout.mp3")
sound_shake = audio.loadSound("sound_shake.mp3")
sound_laugh = audio.loadSound("sound_laugh.mp3")

--remove images
function removeImage( img )
	img:removeSelf()
end

--restart omikuji
function restart( event )
	local t = event.target
	removeImage( t )
	--finGroup:removeSelf()
	audio.play(sound)
	start()
end

--finish omikuji
local function fin( event )
	local t = event.target
	removeImage( t )

	--finGroup = display.newGroup()

	local endImg = display.newImage("omikuji-musubi.jpg")
	endImg.x = display.contentCenterX
	endImg.y = display.contentCenterY
	--finGroup:insert(endImg)

	local button = display.newImage("play-again.png")
	button.x = display.contentCenterX
	button.y = display.contentCenterY + 150
	button:addEventListener("touch", restart)

end

--open box
function open()
	local result
	flag = math.random(3)
	if counter > 5 then
		flag = 4
	end
	
	
	Runtime:removeEventListener( "accelerometer", startShake )
	if flag == 1 then
		result = display.newImage("omikuji-daikichi.png")
		result.x = display.contentCenterX
		result.y = display.contentCenterY
		result:addEventListener("touch", fin)
		audio.play(sound3)

	elseif flag == 2 then
		result = display.newImage("omikuji-chuukichi.png")
		result.x = display.contentCenterX
		result.y = display.contentCenterY
		result:addEventListener("touch", fin)
		audio.play(sound2)

	elseif flag == 3 then
		result = display.newImage("omikuji-hei.png")
		result.x = display.contentCenterX
		result.y = display.contentCenterY
		result:addEventListener("touch", fin)
		audio.play(sound_shout)

	elseif flag == 4 then
		result = display.newImage("omikuji-chodaikichi.jpg")
		result.x = display.contentCenterX
		result.y = display.contentCenterY
		result:addEventListener("touch", fin)
		audio.play(sound_laugh)
	end

	function getResult()
		return result
	end

end

--shake box
function startShake( event )
	local t = os.time()
	print( t )
	if event.isShake == true then
		num = 1
		audio.play( sound_shake )
		open()
	end

end

--drag box
function startDrag( event )
	local t = event.target
	local phase = event.phase
	if "began" == phase then
		display.getCurrentStage():setFocus( t )
		t.isFocus = true

		-- Store initial position
		t.x0 = event.x - t.x
		t.y0 = event.y - t.y

		-- Make body type temporarily "kinematic" (to avoid gravitional forces)
		event.target.bodyType = "kinematic"

		-- Stop current motion, if any
		event.target:setLinearVelocity( 0, 0 )
		event.target.angularVelocity = 0

		shakeSound = audio.play( sound_shake, {loops=-1 } )
		initTime = os.time()
		print( initTime )

	elseif t.isFocus then
		if "moved" == phase then
			t.x = event.x - t.x0
			t.y = event.y - t.y0

		elseif "ended" == phase or "cancelled" == phase then
			display.getCurrentStage():setFocus( nil )
			t.isFocus = false

			-- Switch body type back to "dynamic", unless we've marked this sprite as a platform
			if ( not event.target.isPlatform ) then
				event.target.bodyType = "dynamic"

				audio.stop( shakeSound )
				endTime = os.time()
				print( endTime )
				--counter = counter + 1
				if  ( endTime - initTime > 2 ) then
					removeImage( t )
					open()
				end
			end

		end
	end
	-- Stop further propagation of touch event!
	return true
end

--start omikuji
function start()
	counter = counter + 1
	imgGroup = display.newGroup()

	local bg = display.newImage("omikuji-bg.png")
	bg.x = display.contentCenterX
	bg.y = display.contentCenterY
	imgGroup:insert(bg)

	local box = display.newImage("omikuji-box.png")
	box.x = display.contentCenterX
	box.y = display.contentCenterY
	physics.addBody( box, { density=30.0, friction=0.5, bounce=0.8 } )
	box:addEventListener( "touch", startDrag )
	Runtime:addEventListener( "accelerometer", startShake )
	imgGroup:insert(box)

	rect1 = display.newRect(0, 0, _W, 5)
	rect2 = display.newRect(0, 0, 5, _H)
	rect3 = display.newRect(_W-5, 0, 5, _H)
	rect4 = display.newRect(0, _H-5, _W, 5)

	rect1:setFillColor( 0, 0, 0, 0)
	rect2:setFillColor( 0, 0, 0, 0)
	rect3:setFillColor( 0, 0, 0, 0)
	rect4:setFillColor( 0, 0, 0, 0)

	physics.addBody(rect1, "static")
	physics.addBody(rect2, "static")
	physics.addBody(rect3, "static")
	physics.addBody(rect4, "static")

	local function onTimeEvent( event )
		box.x = box.x + 20
	end

	--timer.performWithDelay(100, onTimeEvent, 0 )
end

audio.play(sound1)
start()

-- local function onTimeEvent( event )
--  print( "Call onTimeEvent" )
--end

--timer.performWithDelay(1000, onTimeEvent, 0 )