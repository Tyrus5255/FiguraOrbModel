--Sphere Base Model
--by Tyrus5255
--Originally based on models by InstantNootles
local sphere = require('Sphere')
local pehkui = require('Pehkui')

vanilla_model.PLAYER:setVisible(false)
vanilla_model.ARMOR:setVisible(false)
vanilla_model.CAPE:setVisible(false)
vanilla_model.ELYTRA:setVisible(false)

--General Variables
local audioState = false
local timerDuration = 200

local timer = timerDuration/2

--Helper Functions
local function randomNudge (offset)
	return 1+(offset-math.random(1,2*offset))/100
end

local function audioToggle(state)
    audioState = state
end

--Footstep Removal
function events.ON_PLAY_SOUND(id, pos, vol, pitch, loop, cat, path)
    if not path or not player:isLoaded() or ((player:getPos() - pos):length() > 0.05) or not models.sphere.World:getVisible() then return end -- dont trigger if the sound was played by figura (prevent potential infinite loop)

    if id:find(".step") then -- if sound contains ".step"
		return true 
	end
end    

-- Action Wheel

local mainPage = action_wheel:newPage()
action_wheel:setPage(mainPage)

--Manual Weight Adjustment
local weightTrigger = mainPage:newAction()
	:title("Cycle Weight")
	:item("minecraft:cake")
	:onScroll(function(dir) sphere.nudgeSphereRadius(0.2*dir) end)
	:onLeftClick(function() sphere.nudgeSphereRadius(0.2) end )	
	:onRightClick(function() sphere.nudgeSphereRadius(-0.2) end )	

--First Person Camera Toggle
local cameraTrigger = mainPage:newAction()
	:title("Toggle First Person On")
	:toggleTitle("Toggle First Person Off")
	:hoverColor(1, 0, 1)
	:item("minecraft:potato")
	:toggleItem("minecraft:poisonous_potato")
	:onToggle(function(var) cameraToggle(var) end)

--Rotation Snap to View
local rollTrigger = mainPage:newAction()
	:title("Set Rotation to View")
	:hoverColor(1, 0, 1)
	:item("minecraft:lightning_rod")
	:onLeftClick(function(var) rotationToggle(var) end)

--Audio Toggle
local audioTrigger = mainPage:newAction()
	:title("Toggle Gurgling On")
	:toggleTitle("Toggle Gurgling Off")
	:item("minecraft:porkchop")
	:toggleItem("minecraft:cooked_porkchop")
	:onToggle(function(var) audioToggle(var) end)
    :setToggled(audioState)



--Visual + Pehkui Scaling    
local oldSphereRadius = nil
function events.tick()

    local scalingRadius = math.floor(math.clamp(sphere.radius, 2, sphere.max)*5+0.1)/5 
    
    if scalingRadius ~= oldSphereRadius and models.sphere.World:getVisible() then
         
        pehkui.setScale("pehkui:hitbox_width", scalingRadius*2/0.8)
        pehkui.setScale("pehkui:hitbox_height", scalingRadius )
        oldSphereRadius = scalingRadius
    end

end

-- Audio 


local function doTimer() 
    if timer > 0 then
        timer = timer - 1
        return false
    else
        timer = timerDuration * randomNudge(10)
        return true
    end
end

--Gurgling
local function playBellyNoise()
    if not player:isLoaded() then return end
    local soundList = {"block.bubble_column.upwards_ambient","block.bubble_column.whirlpool_ambient"}
    
    sounds:playSound(soundList[math.random(1,#soundList)], player:getPos(), 0.5*randomNudge(10), 0.3*randomNudge(5))  
end
pings.playBellyNoise = playBellyNoise

function events.tick()
	if not doTimer() or not models.sphere.World:getVisible() or not player:isLoaded() or not audioState then return end
    pings.playBellyNoise()
end

