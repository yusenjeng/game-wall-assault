
local GiantRock = {}

function GiantRock:onCollision(phase, fixa, fixb, arbiter)
  if fixb.class == "Terrain" then
    self:push(-50, 10)
  end

  if fixb.class == "Skill" and fixb.name=="Punch" then
    self:applyAction({effect="attack", class="war"})
  end

  if fixb.class == "hero" then
    local hero = fixb.component.entity
    if not hero:isEnabled() then return end

    if phase == MOAIBox2DArbiter.BEGIN then
      hero:applyAction({effect="die", class="GiantRock"})
    elseif phase == MOAIBox2DArbiter.END then
    end
  end
end

function GiantRock:applyAction(act)
  if act.effect == "attack" and act.class=="war" then
    self:die()
  end
end

function GiantRock:push(x, y)
  local vx, vy = self.RigidBody:getVelocity()
  vx = vx + x
  vy = vy + y
  self.RigidBody:setVelocity(vx, vy)
end

function GiantRock:die()
  self.FlyingDeath:die()
  env.shakeCamera = false
  Level:stopShakingCam()
  -- System:remove(self)
end
function GiantRock:reset(x, y)
  self.RigidBody:setVelocity(0,0)
  self.RigidBody:setLoc(self.origin.x, self.origin.y)
end

function GiantRock:new(x,y)
  local u = {}
  u.origin = {x=x,y=y}
  u.physics = env.physics

  setmetatable(u, self)
  self.__index = self
  System:install(u, RigidBody, {type=MOAIBox2DBody.DYNAMIC})


  local fixture = u.RigidBody:createRectFixture(-90, -90, 90, 90)
  fixture:setRestitution(0)
  fixture:setFriction(0)
  fixture.name = "GiantRock"
  fixture.class = "DynamicTrap"
  fixture.entity = u
  fixture:setFilter(env.physics.categories.critter, env.physics.masks.critter)
  u.RigidBody:useFixtureAsSensor(fixture)
  fixture:setSensor(false)
  u.RigidBody:setActive(true)
  u.RigidBody:setLoc(x,y)

  System:install(u, Sprite)
  u.Sprite:loadSprite(env.layWorld, "giant_rock.png", 200, 200, 1,1, true)
  u.Sprite:setAnimationSequence("idle"        , 1 , {1})
  u.Sprite:useAnimation("idle")
  u.Sprite:showFrame(1)

  System:install(u, FlyingDeath)
  System:install(u, Suicide, {life=10, enabled=true})


  return u
end

return GiantRock