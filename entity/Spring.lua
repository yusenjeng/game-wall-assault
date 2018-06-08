
local Spring = {}

function Spring:onCollision(phase, fixa, fixb, arbiter)
  if fixb.class == "Terrain" then
    self:die()
  end

  if fixb.class == "hero" and phase==MOAIBox2DArbiter.BEGIN then
    local hero = fixb.component.entity
    if not hero:isEnabled() then return end
    if Level:isLeader(hero) then
      local vx,vy = hero.RigidBody:getVelocity()
      hero.RigidBody:setVelocity(vx,0)
      hero:push(0, self.pushY*1.1)
      hero:stateOn("jump")
      -- trace(self.pushX, self.pushY)
      Audio:playSound("11 - Jump-s")
    end
  end
end

function Spring:new(ref)
  local u = {}
  u.physics = env.physics
  u.pushX = ref.properties.vx or 0
  u.pushY = ref.properties.vy or -300

  setmetatable(u, self)
  self.__index = self

  System:install(u, RigidBody, {type=MOAIBox2DBody.STATIC})

  local fixture = u.RigidBody:createRectFixture(2, 10, 30, 22)
  fixture:setRestitution(0)
  fixture:setFriction(9999)
  fixture.name = "Spring"
  fixture.class = "StaticTrap"
  fixture.entity = u
  fixture:setFilter(env.physics.categories.critter, env.physics.masks.critter)
  u.RigidBody:useFixtureAsSensor(fixture)
  fixture:setSensor(true)
  u.RigidBody:setActive(true)
  u.RigidBody:setLoc(ref.x, ref.y)

  -- System:install(u, Sprite)
  -- u.Sprite:loadSprite(env.layWorld, "giant_rock.png", 200, 200, 1,1, true)
  -- u.Sprite:setAnimationSequence("idle"        , 1 , {1})
  -- u.Sprite:useAnimation("idle")
  -- u.Sprite:showFrame(1)

  return u
end

return Spring