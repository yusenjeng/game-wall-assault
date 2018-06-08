
local Torch = {}

function Torch:onCollision(phase, fix_a, fixb, arbiter)
  if not self.enabled then return end

  if fixb.class == "Terrain" then
  end

  if fixb.class == "Enemy" and phase == MOAIBox2DArbiter.BEGIN then
    fixb.component.entity:die()
    self:die()
  end

  if fixb.class == "hero" then
    local hero = fixb.component.entity
    if hero:isRIP() then return end
    if phase == MOAIBox2DArbiter.BEGIN then
      self:die()
      hero:die()
    end
  end
end

function Torch:die()
  if not self.enabled then return end

  self.Sprite:fadeOut()
  delay(1.3, function()
    System:remove(self)
  end)

  Audio:playSound("13 - Fire")
  self.RigidBody:setSensor(true)
  self.enabled = false
end

function Torch:push(x, y)
  local vx, vy = self.RigidBody:getVelocity()
  vx = vx + x
  vy = vy + y
  self.RigidBody:setVelocity(vx, vy)
end

function Torch:new(ref)
  local u = {}
  u.x = x
  u.y = y
  u.hp = 100
  u.physics = env.physics
  u.enabled = true

  local left = ref.x
  local right = ref.x+ref.width
  local top = ref.y
  local bottom = ref.y+ref.height

  setmetatable(u, self)
  self.__index = self

  System:install(u, RigidBody, {type=MOAIBox2DBody.STATIC})

  local fixture = u.RigidBody:createRectFixture(left, bottom, right, top)
  fixture:setRestitution(0)
  fixture:setFriction(9999)
  fixture.name = "Torch"
  fixture.class = "Torch"
  fixture:setFilter(env.physics.categories.hero+env.physics.categories.critter, env.physics.masks.scenary)
  u.RigidBody:useFixtureAsSensor(fixture)
  fixture:setSensor(false)
  u.RigidBody:setActive(true)

  System:install(u, Sprite)
  u.Sprite:loadSprite(env.layWorld, "Fire.png", 24,24, 2,1, true)

  u.Sprite:setAnimationSequence("idle", 0.08, {1,2})
  u.Sprite:useAnimation("idle")
  u.Sprite:looping(1)
  u.Sprite:setLoc(ref.x,ref.y+10)

  return u
end

return Torch