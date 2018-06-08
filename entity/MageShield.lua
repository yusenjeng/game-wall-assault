
local MageShield = {}

function MageShield:onCollision(phase, fixa, fixb, arbiter)
  if fixb.class == "Enemy" then
    local ent = fixb.entity
    if phase == MOAIBox2DArbiter.BEGIN then
    elseif phase == MOAIBox2DArbiter.END then
    end
  end

  if fixb.class == "DynamicTrap" and phase == MOAIBox2DArbiter.BEGIN then
    local ent = fixb.entity
    if fixb.name == "ArrowTrap" then
      local vx = math.random(500)-250
      fixb.entity:push(vx*2, -800)
      fixb.entity.Suicide:setLife(1.5)
      -- fixb.entity.Sprite:rotate(3600, 1)
    end

    if fixb.name == "Fireball" then
      Audio:playSound("05 - Walk-box")
      self:die()
      ent:die()
    end
  end
end

function MageShield:die()
  System:remove(self)
end

function MageShield:new(ref)
  local u = {}
  u.physics = env.physics
  u.enable = true

  setmetatable(u, self)
  self.__index = self
  System:install(u, RigidBody, {type=MOAIBox2DBody.DYNAMIC})

  local fixture
  -- fixture = u.RigidBody:createRectFixture(-40, -80, 40, 50)
  fixture = u.RigidBody:createRectFixture(-55, -5, 55, 20)
  fixture:setRestitution(0)
  fixture:setFriction(0)
  fixture.name = "MageShield"
  fixture.class = "Skill"
  fixture.entity = u
  local category = env.physics.categories.hero+env.physics.categories.critter
  local mask = env.physics.masks.scenary
  fixture:setFilter(category, mask)
  fixture.category = category

  u.RigidBody:useFixtureAsSensor(fixture)
  -- fixture:setSensor(false)
  u.RigidBody:setActive(true)
  u.RigidBody:setLoc(ref.x, ref.y)
  u.RigidBody:setVelocity(ref.vx, ref.vy)

  System:install(u, Sprite)
  u.Sprite:loadSprite(env.layWorld, "cloud.png", 140, 50, 1,1, true)
  u.Sprite:setAnimationSequence("idle"        ,1 , {1})
  -- u.Sprite:loadSprite(env.layWorld, "magic_shield.png", 200, 200, 4,1, true)
  -- u.Sprite:setAnimationSequence("idle"        , 0.08 , {1,2,3,4})
  u.Sprite:useAnimation("idle")
  u.Sprite:looping()

  System:install(u, MissileBehavior)
  System:install(u, Suicide, {life=ref.life, enabled=true})


  return u
end

return MageShield