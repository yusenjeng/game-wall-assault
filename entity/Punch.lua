
local Punch = {}

function Punch:onCollision(phase, fixa, fixb, arbiter)
  if fixb.class == "Enemy" then
    local ent = fixb.entity
    if phase == MOAIBox2DArbiter.BEGIN then
    elseif phase == MOAIBox2DArbiter.END then
    end
  end
end

function Punch:die()
  System:remove(self)
end

function Punch:new(x,y, ix)
  local u = {}
  u.physics = env.physics

  setmetatable(u, self)
  self.__index = self
  System:install(u, RigidBody, {type=MOAIBox2DBody.DYNAMIC})

  local fixture

  fixture = u.RigidBody:createRectFixture(-30, -50, 100, 20)

  fixture:setRestitution(0)
  fixture:setFriction(0)
  fixture.name = "Punch"
  fixture.class = "Skill"
  fixture.entity = u
  local category = env.physics.categories.hero+env.physics.categories.critter
  local mask = env.physics.masks.hero
  fixture:setFilter(category, mask)
  u.RigidBody:useFixtureAsSensor(fixture)
  fixture:setSensor(true)
  u.RigidBody:setActive(true)

  if ix then
    x = x + 50
  else
    x = x - 50
  end

  u.RigidBody:setLoc(x,y)

  System:install(u, Sprite)
  u.Sprite:loadSprite(env.layWorld, "slash2.png", 100, 100, 1,3, true)
  u.Sprite:setAnimationSequence("idle"        , 0.05, {1,2,3})
  u.Sprite:useAnimation("idle")
  u.Sprite:flip(ix)
  -- u.Sprite:setLoc(x-10,y)
  u.Sprite:play()

  -- System:install(u, FlyingDeath)
  System:install(u, Suicide, {life=0.2, enabled=true})


  return u
end

return Punch