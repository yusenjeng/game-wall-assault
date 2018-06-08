
local BubbleWord = {}


function BubbleWord:die()
  env.layWorld:removeProp(self.txt)
  System:remove(self)
end


function BubbleWord:new(ref)
  local u   = {}
  u.physics = env.physics

  setmetatable(u, self)
  self.__index   = self
  -- System:install(u, RigidBody, {type=MOAIBox2DBody.KINEMATIC})

  local txt = MOAITextBox.new()
  txt:setFont(env.font1)
  txt:setRect(-200, -50, 200, 50)
  txt:setAlignment(MOAITextBox.CENTER_JUSTIFY)
  txt:setString("+"..tostring(ref.num))
  txt:setLoc(ref.x, ref.y)
  env.layWorld:insertProp(txt)

  self.txt = txt

  -- local r = 0.7 + (math.random()/2)
  if ref.name == "Spike" then
    txt:setColor (0.9, 0.9, 0, 1)
  elseif ref.name == "WallA" then
    txt:setColor (254/255, 112/255, 56/255, 1)
  elseif ref.name == "Enemy" then
    txt:setColor (200/255, 50/255, 50/255, 1)
  end
  txt:seekScl ( 2,2, 0.05, MOAIEaseType.EASE_OUT )
  delay(0.5, function()
    txt:seekColor (1,1,1,0, 1, MOAIEaseType.EASE_IN )
    txt:seekScl ( 0,0, 0.1, MOAIEaseType.EASE_OUT )
  end)

  -- System:install(u, Sprite)
  -- u.Sprite:loadSprite(env.layFG, "BubbleWord.png", 96, 96, 8,8, true)
  -- u.Sprite:setAnimationSequence("idle", 0.08, {1,2,3,4,5,6,7,8})
  -- u.Sprite:useAnimation("idle")
  -- u.Sprite:looping()

  -- local deg = degree({ref.vx, ref.vy}, {1,0})
  -- u.Sprite:rotate(deg, 0)
  -- trace(deg, "BubbleWord")

  -- u.Sprite:rotate(0, 0)   -- right
  -- u.Sprite:rotate(90, 0)  -- up
  -- u.Sprite:rotate(180, 0) -- left
  -- u.Sprite:rotate(270, 0) -- down

  System:install(u, Suicide, {life=3, enabled=true})
  -- System:install(u, GhostMove, {})
  -- Audio:playSound("BubbleWord")

  return u
end

return BubbleWord