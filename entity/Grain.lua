
local Grain = {}

function Grain:onCollision(phase, fix_a, fix_b, arbiter)
  if fix_b.class == "terrain" then
  end
  if fix_b.class == "hero" then
    local hero = fix_b.component.entity
    if not hero:isEnabled() then return end

    if phase == MOAIBox2DArbiter.BEGIN then
      hero:applyAction({effect="die", class="Grain"})
      -- hero:applyAction({effect="slow", atk=30, class="spike"})
    elseif phase == MOAIBox2DArbiter.END then
      -- hero:applyAction({effect="normal"})
    end
  end
end

function Grain:applyAction(act)
  print(act.effect, act.class)
  if act.effect == "attack" and act.class=="war" then
    self.FlyingDeath:die()
    env.shakeCamera = false
  end
end

function Grain:die()
  System:remove(self)
end

function Grain:push(x, y)
  local vx, vy = self.RigidBody:getVelocity()
  vx = vx + x
  vy = vy + y
  self.RigidBody:setVelocity(vx, vy)
end
function Grain:reset(x, y)
  self.RigidBody:setVelocity(0,0)
  self.RigidBody:setLoc(self.origin.x, self.origin.y)
  print("rock reset to", self.origin.x, self.origin.y)
end

function Grain:new(x,y)
  local u = {}
  u.origin = {x=x,y=y}
  u.physics = env.physics

  setmetatable(u, self)
  self.__index = self
  System:install(u, RigidBody, {type=MOAIBox2DBody.DYNAMIC})


  local fixture = u.RigidBody:createRectFixture(-10, 0, 10, 20)
  fixture:setRestitution(0)
  fixture:setFriction(0)
  fixture.name = "Grain"
  fixture.class = "DynamicTrap"
  fixture.entity = u
  fixture:setFilter(env.physics.categories.critter, env.physics.masks.critter)
  u.RigidBody:useFixtureAsSensor(fixture)
  fixture:setSensor(true)
  u.RigidBody:setActive(true)
  u.RigidBody:setLoc(x,y)

  System:install(u, Sprite)
  u.Sprite:loadSprite(env.layWorld, "giant_rock.png", 20, 20, 1,1, true)
  u.Sprite:setAnimationSequence("idle"        , 1 , {1})
  u.Sprite:useAnimation("idle")
  u.Sprite:showFrame(1)

  System:install(u, Liftup)
  System:install(u, Suicide, {life=5})

  return u
end

return Grain