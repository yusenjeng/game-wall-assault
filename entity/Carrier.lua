
local Carrier = {}

function Carrier:onCollision(phase, fixa, fixb, arbiter)
end

function Carrier:die()
  System:remove(self)
end


function Carrier:new(ref)
  local u   = {}
  u.physics = env.physics

  setmetatable(u, self)
  self.__index   = self
  System:install(u, RigidBody, {type=MOAIBox2DBody.KINEMATIC})

  local fixture  = u.RigidBody:createRectFixture(-10, -6, 10, 6)
  fixture:setRestitution(0)
  fixture:setFriction(0)
  fixture.name   = "Carrier"
  fixture.class  = "DynamicTrap"
  fixture.entity = u
  fixture:setFilter(
    env.physics.categories.critter,
    env.physics.masks.critter)
  u.RigidBody:useFixtureAsSensor(fixture)
  u.RigidBody:setActive(true)
  u.RigidBody:setLoc(ref.x, ref.y)
  u.RigidBody:setVelocity(ref.vx, ref.vy)

  -- System:install(u, Sprite)
  -- u.Sprite:loadSprite(env.layFG, "Carrier.png", 96, 96, 8,8, true)
  -- u.Sprite:setAnimationSequence("idle", 0.08, {1,2,3,4,5,6,7,8})
  -- u.Sprite:useAnimation("idle")
  -- u.Sprite:looping()

  -- local deg = degree({ref.vx, ref.vy}, {1,0})
  -- u.Sprite:rotate(deg, 0)
  -- trace(deg, "Carrier")

  -- u.Sprite:rotate(0, 0)   -- right
  -- u.Sprite:rotate(90, 0)  -- up
  -- u.Sprite:rotate(180, 0) -- left
  -- u.Sprite:rotate(270, 0) -- down

  System:install(u, Suicide, {life=ref.life, enabled=true})
  -- System:install(u, GhostMove, {})
  -- Audio:playSound("Carrier")

  return u
end

return Carrier