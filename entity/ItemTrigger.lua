
local ItemTrigger = {}

function ItemTrigger:onCollision(phase, fixa, fixb, arbiter)
  -- if not self.enable then return end

  if fixb.class == "hero" and not self.used then
    if self.class == "Key" and phase == MOAIBox2DArbiter.BEGIN then
      self.trap()
      self.used = true
    elseif self.class == "MovableBox" and phase == MOAIBox2DArbiter.BEGIN then
      self.trap()
      self.used = true
    end

  end
end

function ItemTrigger:reset()
  self.used = false
end

function ItemTrigger:new(class, pos, trap)
  local u = {}
  u.x = x
  u.y = y
  u.class = class
  u.used = false
  u.physics = env.physics
  u.trap = trap

  setmetatable(u, self)
  self.__index = self
  System:install(u, RigidBody, {type=MOAIBox2DBody.DYNAMIC})

  local left = pos.x
  local right = pos.x+pos.width
  local top = pos.y
  local bottom = pos.y+pos.height

  local fixture = u.RigidBody:createRectFixture(left, bottom, right, top)
  fixture:setRestitution(0)
  fixture:setFriction(9999)
  fixture.name = "ItemTrigger"
  fixture.class = "DynamicTrap"
  fixture.entity = u
  fixture:setFilter(env.physics.categories.critter, env.physics.masks.critter)
  u.RigidBody:useFixtureAsSensor(fixture)
  fixture:setSensor(true)
  u.RigidBody:setActive(true)
  u.RigidBody:setLoc(x,y)

  return u
end

return ItemTrigger