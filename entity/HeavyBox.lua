
local HeavyBox = {}

function HeavyBox:onCollision(phase, fixa, fixb, arbiter)
  if fixb.class == "Terrain" then
  end

  if fixb.name == "Punch" then
    self:applyAction({effect="attack", class="war"})
  end

  if fixb.class == "hero" then
    local hero = fixb.component.entity
    if not hero:isEnabled() then return end

    if phase == MOAIBox2DArbiter.BEGIN then
      Audio:playSound("05 - Walk-box")
    end
  end
end

function HeavyBox:push(x, y)
  local vx, vy = self.RigidBody:getVelocity()
  vx = vx + x
  vy = vy + y
  self.RigidBody:setVelocity(vx, vy)
end

function HeavyBox:applyAction(act)
  if not self.enabled then return end
  if act.effect == "attack" and act.class=="war" then
    self.GhostMove:shift(self.shiftX, function()
      self.RigidBody:setFriction(1)
      System:uninstall(self, GhostMove)
    end)
    self.RigidBody:setFriction(0)
    self.enabled = false
  end
end

function HeavyBox:new(ref)
  local u = {}
  u.physics = env.physics
  self.enabled = true
  self.shiftX = ref.properties.shiftX or 200

  setmetatable(u, self)
  self.__index = self

  System:install(u, RigidBody, {type=MOAIBox2DBody.DYNAMIC})

  local fixture = u.RigidBody:createRectFixture(-40, -40, 40, 40)
  fixture:setRestitution(0)
  fixture:setFriction(1000)
  fixture.name = "HeavyBox"
  fixture.class = "DynamicTrap"
  fixture.entity = u
  fixture:setFilter(env.physics.categories.critter+env.physics.categories.hero, env.physics.masks.critter)
  u.RigidBody:useFixtureAsSensor(fixture)
  fixture:setSensor(false)
  u.RigidBody:setActive(true)
  u.RigidBody:setLoc(ref.x, ref.y)

  System:install(u, GhostMove)

  System:install(u, Sprite)
  u.Sprite:loadSprite(env.layWorld, "crate.png", 80, 80, 1,1, true)
  u.Sprite:setAnimationSequence("idle"        , 1 , {1})
  u.Sprite:useAnimation("idle")
  u.Sprite:showFrame(1)

  return u
end

return HeavyBox