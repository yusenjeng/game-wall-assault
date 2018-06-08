
local Fireball = {}

function Fireball:onCollision(phase, fixa, fixb, arbiter)
  if not self.enabled then return end

  if fixb.class == "Terrain" then
    if phase == MOAIBox2DArbiter.BEGIN then
      self:die()
    end
  end

  if fixb.class == "Obstacle" then
    if phase == MOAIBox2DArbiter.BEGIN then
      self:die()
    end
  end

  if fixb.class == "hero" then
    local hero = fixb.component.entity
    if not hero:isEnabled() then return end

    if phase == MOAIBox2DArbiter.BEGIN then
      if hero.name ~= "mag" then
        hero:die()
      else
        Audio:playSound("22 - Defence")
      end
      self:die()
    elseif phase == MOAIBox2DArbiter.END then
    end
  end
end

function Fireball:applyAction(act)
end

function Fireball:push(x, y)
  local vx, vy = self.RigidBody:getVelocity()
  vx = vx + x
  vy = vy + y
  self.RigidBody:setVelocity(vx, vy)
end

function Fireball:die()
  self.enabled = false
  System:remove(self)
end
function Fireball:reset(x, y)
  self.RigidBody:setVelocity(0,0)
  self.RigidBody:setLoc(self.origin.x, self.origin.y)
end

function Fireball:new(ref)
  local u   = {}
  u.physics = env.physics
  u.enabled = true

  setmetatable(u, self)
  self.__index   = self
  System:install(u, RigidBody, {type=MOAIBox2DBody.DYNAMIC})

  local fixture  = u.RigidBody:createRectFixture(-20, -6, 20, 6)
  fixture:setRestitution(0)
  fixture:setFriction(0)
  fixture.name   = "Fireball"
  fixture.class  = "DynamicTrap"
  fixture.entity = u
  fixture:setFilter(
    env.physics.categories.hero+env.physics.categories.critter,
    env.physics.masks.critter)
  u.RigidBody:useFixtureAsSensor(fixture)
  u.RigidBody:setActive(true)
  u.RigidBody:setLoc(ref.x, ref.y)
  u.RigidBody:setVelocity(ref.vx, ref.vy)

  System:install(u, Sprite)

  u.Sprite:loadSprite(env.layFG, "Arrow.png", 64, 32, 1,2)
  u.Sprite:setAnimationSequence("idle", 0.1, {1,2})
  u.Sprite:useAnimation("idle")
  u.Sprite:looping()
  u.Sprite.prop:setPriority(900)
  u.Sprite.propIX:setPriority(900)

  local deg = -degree({ref.vx, ref.vy}, {1,0})
  u.Sprite:rotate(deg, 0)

  -- u.Sprite:rotate(0, 0)   -- right
  -- u.Sprite:rotate(90, 0)  -- up
  -- u.Sprite:rotate(180, 0) -- left
  -- u.Sprite:rotate(270, 0) -- down

  System:install(u, MissileBehavior)
  System:install(u, Suicide, {life=ref.life, enabled=true})

  Audio:playSound("13 - Fire")

  return u
end

return Fireball