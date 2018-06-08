
local Key = {}

function Key:onCollision(phase, fixa, fixb, arbiter)

end

function Key:die()
  System:remove(self)
end

function Key:new(ref)
  local u = {}
  u.physics = env.physics
  u.code = ref.properties.code

  setmetatable(u, self)
  self.__index = self

  System:install(u, RigidBody, {type=MOAIBox2DBody.DYNAMIC})

  local fixture
  fixture = u.RigidBody:createRectFixture(-16, -10, 16, 10)
  fixture:setRestitution(0)
  fixture:setFriction(0)
  fixture.name   = "Key"
  fixture.class  = "Item"
  fixture.entity = u
  local category = env.physics.categories.hero+env.physics.categories.critter
  local mask     = env.physics.masks.scenary
  fixture:setFilter(category, mask)
  u.RigidBody:useFixtureAsSensor(fixture)
  fixture:setSensor(false)
  u.RigidBody:setActive(true)
  u.RigidBody:setLoc(ref.x, ref.y)

  System:install(u, Sprite)
  u.Sprite:loadSprite(env.layWorld, "key.png", 32,32, 1,1, true)
  u.Sprite:setAnimationSequence("idle"       ,  1, {1})
  u.Sprite:useAnimation("idle")
  u.Sprite:looping()
  return u
end

return Key