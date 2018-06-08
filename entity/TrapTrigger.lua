
local TrapTrigger = {}

function TrapTrigger:onCollision(phase, fixa, fixb, arbiter)
  -- if not self.enable then return end

  if fixb.class == "hero" and not self.used then
    if self.class == "GiantRock" and phase == MOAIBox2DArbiter.BEGIN then
      self.trap()
      self.used = true
    elseif self.class == "ArrowTrap" and phase == MOAIBox2DArbiter.BEGIN then
      self.trap()
      self.used = true
    elseif self.class == "DogCamp" and phase == MOAIBox2DArbiter.BEGIN then
      self.used = true
      Audio:playSound("21 - Scare")
      local dt =tonumber(self.ppt.delay)
      delay(dt, function()
        self.Sprite:hide()
        self.trap()
      end)
    elseif self.class == "Exit" and phase == MOAIBox2DArbiter.BEGIN then
      -- print("touch exit", self.ppt.code)
      if self.ppt.code and fixb.entity.Pocket:has(self.ppt.code) then
        self.trap()
        self.used = true
        -- fixb.entity:toIdle()
      elseif not self.ppt or not self.ppt.code then
        self.trap()
        self.used = true
        -- fixb.entity:toIdle()
      end
    end

  end
end

function TrapTrigger:reset()
  self.used = false
end

function TrapTrigger:new(class, ref, trap)
  local u = {}
  u.x = x
  u.y = y
  u.class = class
  u.used = false
  u.physics = env.physics
  u.trap = trap
  u.ppt = ref.properties

  setmetatable(u, self)
  self.__index = self

  System:install(u, RigidBody, {type=MOAIBox2DBody.STATIC})

  local left = ref.x
  local right = ref.x+ref.width
  local top = ref.y
  local bottom = ref.y+ref.height

  local fixture = u.RigidBody:createRectFixture(left, bottom, right, top)
  fixture:setRestitution(0)
  fixture:setFriction(9999)
  fixture.name = "TrapTrigger"
  fixture.class = "StaticTrap"
  fixture.entity = u
  fixture:setFilter(env.physics.categories.critter, env.physics.masks.critter)
  u.RigidBody:useFixtureAsSensor(fixture)
  fixture:setSensor(true)
  u.RigidBody:setActive(true)
  u.RigidBody:setLoc(x,y)

  System:install(u, Sprite)

  if class=="DogCamp" then
    -- trace(class)
    u.Sprite:loadSprite(env.layFG, "ene1.png", 48, 48, 5, 1)
    u.Sprite:setAnimationSequence("idle", 0.5, {4,5})
    u.Sprite:useAnimation("idle")
    u.Sprite:looping()
    u.Sprite.prop:setPriority(900)
    u.Sprite.propIX:setPriority(900)
    u.Sprite:setLoc(ref.x+10, ref.y+10)
  end

  return u
end

return TrapTrigger