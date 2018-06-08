
-- require("helper")
-- require("Component")
-- require("Keyboard")
-- require("TextureManager")
-- require("Terrain")
-- require("Audio")
-- require("Launcher")
-- require("component/RigidBody")
-- require("component/Sprite")
-- require("component/WarBehavior")
-- require("component/BardBehavior")
-- require("component/MagBehavior")
-- require("component/CommonBehavior")
-- require("component/UnitStatus")
-- require("component/FlyingDeath")
-- require("component/FallingDeath")
-- require("component/FungiMove")
-- require("component/Liftup")
-- require("component/Suicide")
-- require("component/KeyControl")
-- require("component/SlidingBehavior")
-- require("component/Pocket")
-- require("component/ClimbLadder")
-- require("component/BiggerFaster")
-- require("component/MsgBox")
-- require("component/GhostMove")
-- require("component/CannotMove")
-- require("component/Camp")
-- require("component/CannonBehavior")
-- require("component/MissileBehavior")
-- require("component/ActionLog")
-- require("component/Follow")
-- require("component/DogMove")
-- require("component/SlowJump")

-- require("env")

-- Hero        = require("entity/Hero")
-- Enemy       = require("entity/Enemy")
-- Spike       = require("entity/Spike")
-- GiantRock   = require("entity/GiantRock")
-- Grain       = require("entity/Grain")
-- TrapTrigger = require("entity/TrapTrigger")
-- MageShield  = require("entity/MageShield")
-- ArrowTrap   = require("entity/ArrowTrap")
-- Conveyer    = require("entity/Conveyer")
-- Fx          = require("entity/Fx")
-- Key         = require("entity/Key")
-- Spring      = require("entity/Spring")
-- HeavyBox    = require("entity/HeavyBox")
-- Punch       = require("entity/Punch")
-- Epic        = require("entity/Epic")
-- Fireball    = require("entity/Fireball")
-- Carrier     = require("entity/Carrier")
-- Obstacle    = require("entity/Obstacle")
-- StrayDog    = require("entity/StrayDog")
-- Torch       = require("entity/Torch")
-- BubbleWord  = require("entity/BubbleWord")

-- require("Level")
-- require("OP")
-- require("CutScene")
-- require("UI")

-------------------------------------------------------------------------------
-- Initialize Environment
-------------------------------------------------------------------------------
MOAISim.setStep( 1 / 60 )

local W = MOAIEnvironment.verticalResolution or 960
local H = MOAIEnvironment.horizontalResolution or 640
env.W = W
env.H = H

trace(W,H)
MOAISim.openWindow("Assault on the Wall", W, H)

local viewport = MOAIViewport.new()
viewport:setSize(W, H)
-- viewport:setScale(W*10, -H*10)
-- viewport:setScale(W/1.5, -H/1.5)
viewport:setScale(W, -H)

local camera = MOAICamera2D.new()
camera:setLoc(0, 0)
env.camera = camera

-- Setup major game layer
local layWorld = MOAILayer2D.new()
layWorld:setViewport(viewport)
layWorld:setCamera(camera)
MOAIRenderMgr.pushRenderPass(layWorld)
env.layWorld = layWorld


-- Setup major game layer
local layBG = MOAILayer2D.new()
layBG:setViewport(viewport)
layBG:setCamera(camera)
MOAIRenderMgr.pushRenderPass(layBG)
env.layBG = layBG

-- Setup major game layer
local layFG = MOAILayer2D.new()
layFG:setViewport(viewport)
layFG:setCamera(camera)
MOAIRenderMgr.pushRenderPass(layFG)
env.layFG = layFG


-- Setup a GUI layer attached to the camera
local layGUI   = MOAILayer2D.new()
layGUI:setViewport(viewport)
layGUI:setCamera(camera)
MOAIRenderMgr.pushRenderPass(layGUI)
env.layGUI = layGUI


-- Setup the box2d
local physics  = MOAIBox2DWorld.new()
physics:setGravity(0, 70)
physics:setUnitsToMeters(1 / 10)

physics:setDebugDrawEnabled(false)
-- if env.debug_box2d then
--   physics:setDebugDrawFlags(
--       MOAIBox2DWorld.DEBUG_DRAW_JOINTS
--     + MOAIBox2DWorld.DEBUG_DRAW_SHAPES
--     + MOAIBox2DWorld.DEBUG_DRAW_PAIRS
--     + MOAIBox2DWorld.DEBUG_DRAW_CENTERS)
-- end

physics:start()
layWorld:setBox2DWorld(physics)
layWorld.physics = physics

env.physics = physics

local categories = {
  hero        = 1,
  critter     = 2,
  interactiveObj  = 4,
  scenary     = 8,
}
physics.categories = categories

physics.masks = {
  hero      = categories.critter + categories.scenary,
  critter     = categories.hero + categories.scenary,
  interactiveObj  = categories.scenary,
  scenary     = 0xffff
}


-- audio
Audio:init()


function addTimer ( spanTime, callbackFunction, fireRightAway )
  local timer = MOAITimer.new ()
  timer:setSpan ( spanTime )
  timer:setMode ( MOAITimer.LOOP )
  timer:setListener ( MOAITimer.EVENT_TIMER_LOOP, callbackFunction )
  timer:start ()
  if ( fireRightAway ) then
    callbackFunction ()
  end
  return timer
end

-- init TTF Fonts
charcodes = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,.?!:()&/-~ +"
env.font1 = MOAIFont.new()
env.font1:loadFromTTF( 'assets/Charybdis.ttf', charcodes, 12, 163 )

env.font2 = MOAIFont.new()
env.font2:loadFromTTF( 'assets/Charybdis.ttf', charcodes, 24, 163 )

env.font3 = MOAIFont.new()
env.font3:loadFromTTF( 'assets/Charybdis.ttf', charcodes, 16, 163 )

function drawRoundedRect(index, xOff, yOff, xScale, yScale)
  local width, height, radius, circlestep = 100, 50, 5, 32
  local x,y = camera:getLoc()
  local hw, hh = width/2, height/2

  MOAIGfxDevice.setPenColor(1, 1, 1, 0.75)
  MOAIDraw.fillRect( x-hw+radius, y-hh,        x+hw-radius, y+hh )
  MOAIDraw.fillRect( x-hw,        y-hh+radius, x+hw,        y+hh-radius )

  MOAIGfxDevice.setPenColor(0, 0, 1, 0.75)
  MOAIDraw.fillCircle( x-hw+radius, y-hh+radius, radius, circlestep )
  MOAIDraw.fillCircle( x-hw+radius, y+hh-radius, radius, circlestep )
  MOAIDraw.fillCircle( x+hw-radius, y-hh+radius, radius, circlestep )
  MOAIDraw.fillCircle( x+hw-radius, y+hh-radius, radius, circlestep )
end

-- MOAISim.setBoostThreshold ( 0 )
-- MOAISim.setCpuBudget(30)
-- MOAISim.setHistogramEnabled(true)
-- MOAISim.setLongDelayThreshold(1)
MOAISim.setLoopFlags(MOAISim.SIM_LOOP_ALLOW_BOOST)

-------------------------------------------------------------------------------
-- Initialize input handling
-------------------------------------------------------------------------------
local mouseX, mouseY, currentlyTouchedProp
local function pointerCallback ( x, y )
  -- this function is called when the touch is registered (before clickCallback)
  -- or when the mouse cursor is moved
  if env.layWorld then
    mouseX, mouseY = env.layWorld:wndToWorld ( x, y )
  end
  -- if currentlyTouchedProp and currentlyTouchedProp.isDragable then
  --   dragObject(currentlyTouchedProp, mouseX, mouseY)
  -- end
end

function clickCallback ( down )
  -- this function is called when touch/click
  -- is registered
  local pick = partition:propForPoint ( mouseX, mouseY )
  local phase
  if down then
    phase =  "down"
  else
    phase = "up"
  end

  if currentlyTouchedProp then
    pick = currentlyTouchedProp
  end

  local event = {
    target = pick,
    x = mouseX,
    y = mouseY,
    phase = phase,
  }
  trace ( phase, mouseX, mouseY )
  if down then
    if pick then
      currentlyTouchedProp = pick
      local x, y = currentlyTouchedProp:getLoc ()
      -- we store the position of initial touch inside the object
      -- so when it's dragged, it follows the finger/cursor smoothly
      currentlyTouchedProp.holdX = x - mouseX
      currentlyTouchedProp.holdY = y - mouseY
    end
    if pick and pick.onTouchDown then
      pick.onTouchDown ( event )
      return
    end
  else
    currentlyTouchedProp = nil
    if pick and pick.onTouchUp then
      pick.onTouchUp ( event )
      return
    end
  end
end

if MOAIInputMgr.device.touch then
  MOAIInputMgr.device.touch:setCallback (
    function ( eventType, idx, x, y, tapCount )
      pointerCallback ( x, y )
      if eventType == MOAITouchSensor.TOUCH_DOWN then
        clickCallback ( true )
      elseif eventType == MOAITouchSensor.TOUCH_UP then
        clickCallback ( false )
      end
    end
  )
else
  Keyboard:setCallback(function(key, down)
    if down and key==Keyboard.esc then os.exit() end

    env.press[key] = down

    System:onKey(key, down)

    if Level then Level:onKey(key, down) end
    if OP    then OP:onKey(key, down) end
    if CutScene then CutScene:onKey(key, down) end
  end)
end

-------------------------------------------------------------------------------
-- Main Loop
-------------------------------------------------------------------------------
sysThread = MOAICoroutine.new ()
sysThread:run(function ()
  while true do
    if env.focus == "game" then
      local dt = MOAISim.getStep()
      System:onUpdate(dt)
      if Level then Level:onUpdate(dt) end
      if OP    then OP:onUpdate(dt) end
      if CutScene then CutScene:onUpdate(dt) end
    end
    coroutine.yield()
  end
end)


OP:init()
OP:show("~ Press Enter to Start ~")

CutScene:init()

-- Dismiss all the texture messages
MOAILogMgr.setLogLevel(MOAILogMgr.LOG_NONE)
