
--Sphere Model Driver Script by Tyrus5255 
--V - 1.2

--Heavily Based on scripts by ChloeSpacedOut and InstantNootles

local orientViewToHead = false -- When set to true, pairs the viewpoint of the camera to the position of the head

---@class Sphere
local sphere = {}

sphere.radius = 2 -- Radius of the sphere in blocks --add config???
sphere.max = 2*4 -- Relates to the inflation animation, set to the value set on the second root scale keyframe otherwise, the scale will desync
sphere.resetState = true
sphere.eyeOffsetToggle = true
--


local function scaleSphere(radius)
        
    local animation = animations.sphere.inflate
    animation:play():setSpeed(0):setOffset(animation:getLength() * (radius - 2)/(sphere.max-2))
    
end

function sphere.setSphereRadius(radius)
    
    local radius = radius or sphere.radius or 2
    radius = math.floor(math.clamp(radius, 2, sphere.max)*5+0.1)/5
    
    sphere.radius = radius 
    sphere.rotationRate =  1/radius -- Rate at which the model rotates, 0.5 is equal to a sphere with a radius of 2 blocks so this value should equal 1/radius
    sphere.heightOffsetValue = radius - 1.125
    
    scaleSphere(radius)
end
pings.setSphereRadius = sphere.setSphereRadius

function sphere.nudgeSphereRadius(dir)
    dir = dir or 0
    sphere.radius = sphere.radius + dir
    pings.setSphereRadius(sphere.radius)
end

function events.entity_init()
    
    sphere.setSphereRadius(sphere.radius) --update associated values
end


-- Rotation functions
local lastPos = vec(0,0,0)
local pos = vec(0,0,0)
local mat = matrices.mat4()

local oldVehicleRot = nil
local vehicleRot = nil

local function rotateBall(curPos)
    lastPos = pos
    pos = curPos
    local vel = (lastPos-pos) * sphere.rotationRate
    
    --Reset Rotation
    if player:isOnGround() or player:isInWater() then
        mat:rotate(math.deg(-vel.z),0,math.deg(vel.x))
    end
    
    

    local lookRot = nil
    local yOffset = 1

    
    if player:getVehicle() then
        lookRot = vec(0,-(player:getBodyYaw())%360-180,0)
        if player:getVehicle():getName():find("Airship") then --Easter Egg
            lookRot.x = -60
            yOffset = 3
        end
    end

    if sphere.resetState then
        local lookDir = player:getLookDir()
        lookRot = vec(math.deg(lookDir.y),math.deg(math.atan(-lookDir.x,-lookDir.z)),0)
        sphere.resetState = false
    end

    
    if lookRot then 
    mat = matrices.mat4()
    mat:rotate(lookRot)
    end
    
    --Set Position
    mat.v14 = pos.x*16
    mat.v24 = (pos.y+yOffset)*16
    mat.v34 = pos.z*16
    
    return mat
end


-- Camera Ball View

local oldsphereEyeOffsetToggle=sphere.eyeOffsetToggle
local function changeCameraView(pos)
    
    if sphere.eyeOffsetToggle or  oldsphereEyeOffsetToggle ~= sphere.eyeOffsetToggle then
        renderer:setEyeOffset(pos)    
    end    
    
    renderer:setOffsetCameraPivot(pos)
    
end

local oldSphereVisibility = nil
local sphereVisibility = nil
function events.post_world_render(delta)
    
    oldSphereVisibility = sphereVisibility
    sphereVisibility = models.sphere.World:getVisible()
    
    
      
    if models.sphere.World:getVisible() then
           
        local headPos = vec(0,0,0)
        
        if (orientViewToHead) then
            headPos = models.sphere.World.root.Neck.View:partToWorldMatrix():apply():sub(player:getPos(delta):add(0,1.75,0)) -- Set the camera's position to accurate Head position
        else
            headPos = vec(0,(sphere.radius*1.9),0)  -- Set the camera's position to just above the body so the world is visible from the player's perspective.
        end
        
        changeCameraView(headPos)
    end
    
    if oldSphereVisibility ~= sphereVisibility then
        changeCameraView(headPos)
    end 
end
-- Rotate Ball
function events.post_world_render(delta)
    if not player:isLoaded() then return end --When integrated into adipose, add additional active stage condition
    
    local heightOffset = vec(0,sphere.heightOffsetValue,0)
    ballPos = (player:getPos(delta) + heightOffset)
    ballRotMat = rotateBall(ballPos)
        
    models.sphere.World:setMatrix(ballRotMat)
    models.sphere.World.root.Neck.hHead:setVisible(not (renderer:isFirstPerson() and orientViewToHead))
        
    headRot = (vanilla_model.HEAD:getOriginRot()+180)%360-180
    
    headRot.x = math.clamp(headRot.x, -30,30)
    headRot.y = math.clamp(headRot.y, -50,50)
    
    headRot = headRot * 0.5
    
	models.sphere.World.root.Neck.hHead:setOffsetRot(headRot)
end

function cameraToggle(state)
    orientViewToHead = state
end

function rotationToggle(state)
    sphere.resetState = state
end

return sphere