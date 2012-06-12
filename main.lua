-- Project: Ant project.

-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
---------------------------------------------------------------------------------------

local sprite = require( "sprite" )
local physics = require( "physics" )
require 'middleclass'
local BoidBase = require( "BoidBase" )
local Boid = require('Boid')

-------------------------------------
--Initialization
display.setStatusBar(display.HiddenStatusBar)
local background = display.newImage("background.png") 
background:setReferencePoint(display.TopLeftReferencePoint)
physics.start()
-- No gravity
physics.setGravity( 0, 0 )


------------------------------------
-- Local/Global For Ant  moving around the screen
local touch2down = false
local radius = 10
local xdirection = 1
local ydirection = 1
local xspeed = 1.5
local yspeed = 1.4
local xpos = display.contentWidth * 0.5
local ypos = display.contentHeight * 0.5


-- Get current edges of visible screen (accounting for the areas cropped by "zoomEven" scaling mode in config.lua)
local screenTop = display.screenOriginY
local screenBottom = display.viewableContentHeight + display.screenOriginY
local screenLeft = display.screenOriginX
local screenRight = display.viewableContentWidth + display.screenOriginX

-- Background screens initialization
local moon = display.newImage("moon.png", 22, 19) 
local mountain_big = display.newImage("mountain_big.png", 132-240, 92) 
local mountain_big2 = display.newImage("mountain_big.png", 132-720, 92) 
local mountain_sma = display.newImage("mountain_small.png", 84, 111)
local mountain_sma2 = display.newImage("mountain_small.png", 84 - 480, 111)
local tree_s = display.newImage("tree_s.png", 129-30, 151) 
local tree_s2 = display.newImage("tree_s.png", 270 + 10,151)
local tree_l = display.newImage("tree_l.png", 145, 131) 
local tree_s3 = display.newImage("tree_s.png", 129-30 - 320, 151) 
local tree_s4 = display.newImage("tree_s.png", 270 + 10 - 320,151)
local tree_l2 = display.newImage("tree_l.png", 145 - 320, 131) 
local tree_s5 = display.newImage("tree_s.png", 129 - 30 - 640, 151) 
local tree_s6 = display.newImage("tree_s.png", 270 + 10 - 640,151)
local tree_l3 = display.newImage("tree_l.png", 145 - 640, 131) 
local fog = display.newImage("Fog.png", 0, 214) 
local fog2 = display.newImage("Fog.png",-480,214)
background.x = 0
background.y = 0
local tree_l_sugi = display.newImage("tree_l_sugi.png", 23, 0) 
local tree_l_take = display.newImage("tree_l_take.png", 151, 0) 
-- local rakkan = display.newImage("rakkan.png", 19, 217) 
-- local rakkann = display.newImage("rakkann.png", 450, 11) 
local wallOutSide = display.newRect(480,0,200,320)
wallOutSide:setFillColor(0,0,0)
local wallOutSide2 = display.newRect(-200,0,200,320)
wallOutSide2:setFillColor(0,0,0)
local tPrevious = system.getTimer()


------ Test Boid constants
-- Define some limiting constants
MAX_FORCE = 3.5
MAX_SPEED =2.0


-- Start our wanderer in the center
local wanderers = {}

-- Test Ant sprite - texturepacker
local texturepacker = sprite.newSpriteSheetFromData( "texturepacker.png", require("texturepacker").getSpriteSheetData() )
local spriteSet = sprite.newSpriteSet(texturepacker,1,6)
sprite.add(spriteSet,"texturepacker",1,6,1000,0)
local spriteInstance = sprite.newSprite(spriteSet)
spriteInstance:setReferencePoint(display.BottomRightReferencePoint)
spriteInstance.x = 480
spriteInstance.y = 320
spriteInstance:scale(.5,.5)


-- Create spriteInstance2 - Walking Ant
local spriteInstance2 = sprite.newSprite(spriteSet)
spriteInstance2:setReferencePoint(display.BottomRightReferencePoint)
spriteInstance2.x = 200
spriteInstance2.y = 200
spriteInstance2:scale(.5,.5)

-- Create spriteInstance3 - Stationary Ant that can be dragged.
local spriteInstance3 = sprite.newSprite(spriteSet)
spriteInstance3:scale(.5,.5)
-- spriteInstance3:setReferencePoint(display.BottomRightReferencePoint)
-- spriteInstance3.x = 100
--  spriteInstance3.y = 100


-- Add Ants to physics model
--spriteInstance.myName="Ant-1"
--physics.addBody( spriteInstance, "static", { friction=0.5} )

--spriteInstance2.myName="Ant-2"
--physics.addBody( spriteInstance2, { density=1.0, friction=0.1, bounce=.5 } )

spriteInstance3.myName="Ant-3"
physics.addBody(spriteInstance3, "kinematic", 
   { friction=0.0, bounce=0.0, density=0.0, radius=spriteInstance3.contentWidth/2.0 } 
 )



-- Angle functions
function angleBetween ( srcObj, dstObj )
    local xDist = dstObj.x-srcObj.x ; local yDist = dstObj.y-srcObj.y
    local angleBetween = math.deg( math.atan( yDist/xDist ) )
    if ( srcObj.x < dstObj.x ) then angleBetween = angleBetween+90 else angleBetween = angleBetween-90 end
    return angleBetween - 90
end

function angleBetweenPoints ( srcObjx, srcObjy, dstObjx, dstObjy)
    local xDist = dstObjx-srcObjx ; local yDist = dstObjy-srcObjy
    local angleBetweenPoints = math.deg( math.atan( yDist/xDist ) )
    if ( srcObjx < dstObjx ) then angleBetweenPoints = angleBetweenPoints + 90 else angleBetweenPoints = angleBetweenPoints - 90 end
    return angleBetweenPoints - 90
end

------------------------

--Events

------------------------


local function move(event)
	
	local tDelta = event.time - tPrevious
	tPrevious = event.time

	local xOffset = ( 0.2 * tDelta )
	
	moon.x = moon.x + xOffset*0.05
	
	fog.x = fog.x + xOffset
	fog2.x = fog2.x + xOffset
	
	mountain_big.x = mountain_big.x + xOffset*0.5
	mountain_big2.x = mountain_big2.x + xOffset*0.5
	mountain_sma.x = mountain_sma.x + xOffset*0.5
	mountain_sma2.x = mountain_sma2.x + xOffset*0.5

	
	tree_s.x = tree_s.x + xOffset
	tree_s2.x = tree_s2.x + xOffset
	tree_l.x = tree_l.x + xOffset
	
	tree_s3.x = tree_s3.x + xOffset
	tree_s4.x = tree_s4.x + xOffset
	tree_l2.x = tree_l2.x + xOffset
	
	tree_s5.x = tree_s5.x + xOffset
	tree_s6.x = tree_s6.x + xOffset
	tree_l3.x = tree_l3.x + xOffset
	
	
	tree_l_sugi.x = tree_l_sugi.x + xOffset * 1.5
	tree_l_take.x = tree_l_take.x + xOffset * 1.5
	
	if moon.x > 480 + moon.width / 2 then
		moon:translate ( -480*2 , 0)
	end
	if fog.x > 480 + fog.width / 2 then
		fog:translate( -480 * 2, 0)
	end
	
	if fog2.x > 480 + fog2.width / 2 then
		fog2:translate( -480 * 2, 0)
	end
	
	
	if mountain_big.x > 480 + mountain_big.width / 2 then
		mountain_big:translate(-480*2 , 0)
	end
	if mountain_big2.x > 480 + mountain_big2.width / 2 then
		mountain_big2:translate(-480*2 , 0)
	end
	if mountain_sma.x > 480 + mountain_sma.width / 2 then
		mountain_sma:translate(-480*2,0)
	end
	if mountain_sma2.x > 480 + mountain_sma2.width / 2 then
		mountain_sma2:translate(-480*2,0)
	end
	
	if tree_s.x > 480 + tree_s.width / 2 then
		tree_s:translate(-480*2 , 0)
	end
	if tree_s2.x > 480 + tree_s2.width / 2 then
		tree_s2:translate(-480*2 , 0)
	end
	if tree_l.x > 480 + tree_l.width / 2 then
		tree_l:translate(-480*2 , 0)
	end
	
	if tree_s3.x > 480 + tree_s3.width / 2 then
		tree_s3:translate(-480*2 , 0)
	end
	if tree_s4.x > 480 + tree_s4.width / 2 then
		tree_s4:translate(-480*2 , 0)
	end
	if tree_l2.x > 480 + tree_l2.width / 2 then
		tree_l2:translate(-480*2 , 0)
	end
	
	if tree_s5.x > 480 + tree_s5.width / 2 then
		tree_s5:translate(-480*2 , 0)
	end
	if tree_s6.x > 480 + tree_s6.width / 2 then
		tree_s6:translate(-480*2 , 0)
	end
	if tree_l3.x > 480 + tree_l3.width / 2 then
		tree_l3:translate(-480*2 , 0)
	end
	
	if tree_l_sugi.x > 480 + tree_l_sugi.width / 2 then
		tree_l_sugi:translate(-480*4,0)
	end
	
	if tree_l_take.x > 480 + tree_l_take.width / 2 then
		tree_l_take:translate(-480*5,0)
	end

	
	local SPEED = 0.3
-- constantly adjust velocity to track touch instance
    spriteInstance3:setLinearVelocity(
        SPEED * (spriteInstance.x - spriteInstance3.x),
        SPEED * (spriteInstance.y - spriteInstance3.y))


-- add rotation tracking for Touch Ant.
    spriteInstance3.rotation = angleBetween(spriteInstance3,spriteInstance) + 90
	
end 


local function printTouch( event )
 	if event.target then 
 		local bounds = event.target.contentBounds
	--	print( "event(" .. event.phase .. ") ("..event.x..","..event.y..") bounds: "..bounds.xMin..","..bounds.yMin..","..bounds.xMax..","..bounds.yMax )
	end 
end


local function onTouch( event )
	local t = event.target

	-- Print info about the event. For actual production code, you should
	-- not call this function because it wastes CPU resources.
--   printTouch(event)

	local phase = event.phase
	if "began" == phase then
		-- Make target the top-most object
		local parent = t.parent
		parent:insert( t )
		display.getCurrentStage():setFocus( t )

		-- Spurious events can be sent to the target, e.g. the user presses 
		-- elsewhere on the screen and then moves the finger over the target.
		-- To prevent this, we add this flag. Only when it's true will "move"
		-- events be sent to the target.
		t.isFocus = true

		-- Store initial position
		t.x0 = event.x - t.x
		t.y0 = event.y - t.y
	elseif t.isFocus then
		if "moved" == phase then
			-- Make object move (we subtract t.x0,t.y0 so that moves are
			-- relative to initial grab point, rather than object "snapping").
			t.x = event.x - t.x0
			t.y = event.y - t.y0
		elseif "ended" == phase or "cancelled" == phase then
			display.getCurrentStage():setFocus( nil )
			t.isFocus = false
		end
	end


	-- Important to return true. This tells the system that the event
	-- should not be propagated to listeners of any objects underneath.
	return true
end



-- Touch event for the Bouncing sprite (if it is touched, stop moving
local function onTouch2( event )
	local t = event.target

	-- Print info about the event. For actual production code, you should
	-- not call this function because it wastes CPU resources.
--   printTouch(event)

	local phase = event.phase
	if "began" == phase then
		-- Make target the top-most object
		local parent = t.parent
		parent:insert( t )
		display.getCurrentStage():setFocus( t )
		
		-- Spurious events can be sent to the target, e.g. the user presses 
		-- elsewhere on the screen and then moves the finger over the target.
		-- To prevent this, we add this flag. Only when it's true will "move"
		-- events be sent to the target.
		t.isFocus = true

		-- Store initial position
		t.x0 = event.x - t.x
		t.y0 = event.y - t.y
		touch2down = true
		spriteInstance2.timeScale=6
	elseif t.isFocus then
		if "moved" == phase then
			-- Make object move (we subtract t.x0,t.y0 so that moves are
			-- relative to initial grab point, rather than object "snapping").
--			t.x = event.x - t.x0
--			t.y = event.y - t.y0
		elseif "ended" == phase or "cancelled" == phase then
			display.getCurrentStage():setFocus( nil )
			t.isFocus = false
			touch2down = false
			spriteInstance2.timeScale=1
		end
	end


	-- Important to return true. This tells the system that the event
	-- should not be propagated to listeners of any objects underneath.
	return true
end

-- Boid moving event
function animateboid(event)
    for i=1,#wanderers do
        local wanderer = wanderers[i]
        local prevx = wanderer.displayObject.x
        local prevy = wanderer.displayObject.y
        wanderer:wander()
        wanderer:run()
        -- add rotation sprite towards direction walking
        wanderer.displayObject.rotation = angleBetweenPoints(wanderer.displayObject.x,wanderer.displayObject.y,prevx, prevy)+270

    end
end

-- Event to keep the ant moving.
local function animate(event)
if touch2down == true then
	return
end
	
	xpos = xpos + ( xspeed * xdirection );
	ypos = ypos + ( yspeed * ydirection );
        
	if ( xpos > screenRight - radius or xpos < screenLeft + radius ) then
		xdirection = xdirection * -1;
	end
	if ( ypos > screenBottom - radius or ypos < screenTop + radius ) then
		ydirection = ydirection * -1;
	end


	local prevx = spriteInstance2.x
	local prevy = spriteInstance2.y
	
	spriteInstance2:translate( xpos - spriteInstance2.x, ypos - spriteInstance2.y)

 	local curx = spriteInstance2.x
	local cury = spriteInstance2.y
	
 
-- add rotation tracking for bouncing Ant. - rotate towards walking direction
 spriteInstance2.rotation = angleBetweenPoints(curx,cury,prevx, prevy)+270
  
end


-- Collision detection for Ant 1 hitting Ant 2
local function onLocalCollision( self, event )
	if ( event.phase == "began" ) then

		print( self.myName .. ": collision began with " .. event.other.myName )

	elseif ( event.phase == "ended" ) then

		print( self.myName .. ": collision ended with " .. event.other.myName )

	end
end



--------------------
-- Instantiation


-- Ant #2 - No touch event Bouncer
spriteInstance2:prepare("texturepacker")
spriteInstance2:play()
spriteInstance2:addEventListener("touch",onTouch2)

-- Collision Event
--spriteInstance2.collision = onLocalCollision
--spriteInstance2:addEventListener( "collision", spriteInstance2 )

-- Ant #1 - w/ touch event
spriteInstance:prepare("texturepacker")
spriteInstance:play()
--Add to accept touch
--Add to accept touch
spriteInstance:addEventListener("touch",onTouch)
-- Add Collision listener
-- spriteInstance.collision = onLocalCollision
--spriteInstance:addEventListener( "collision", spriteInstance )

-- Ant #3 - Hunter
spriteInstance3:prepare("texturepacker")
spriteInstance3:play()


-- Set up Boids
math.randomseed( os.time() )
for i=1,20 do

    local loc = Vector2D:new(display.contentWidth / 2,display.contentWidth / 2)
    local spriteInstanceBoid = sprite.newSprite(spriteSet)
    spriteInstanceBoid:scale(.5,.5)
    spriteInstanceBoid:prepare("texturepacker")
    spriteInstanceBoid:play()
--   local wanderer = Boid:new(loc,MAX_FORCE,MAX_SPEED,spriteInstanceBoid)
 local wanderer = BoidBase:new(loc,MAX_FORCE,MAX_SPEED,spriteInstanceBoid,4)
    table.insert(wanderers,wanderer)
end


Runtime:addEventListener( "enterFrame", animateboid )
Runtime:addEventListener( "enterFrame", animate )
Runtime:addEventListener("enterFrame",move)
