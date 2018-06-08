
local ArrowTrap = {}

function ArrowTrap:onCollision(phase, fixa, fixb, arbiter)
  if fixb.class == "Terrain" then
    local tmr = nil
    self.RigidBody:setActive(false)
    self.RigidBody:setSensor(false)
    Audio:playSound("15 - Arrow")
    tmr = addTimer(2, function()
      -- Level:removeNPC(self)
      self:die()
      tmr:stop()
      tmr = nil
    end)
  end

  if fixb.class == "hero" then
    local hero = fixb.component.entity
    if not hero:isEnabled() then return end

    if phase == MOAIBox2DArbiter.BEGIN then
      hero:applyAction({effect="die", class="ArrowTrap"})
    elseif phase == MOAIBox2DArbiter.END then
    end
  end
end

function ArrowTrap:applyAction(act)

end

function ArrowTrap:push(x, y)
  local vx, vy = self.RigidBody:getVelocity()
  vx = vx + x
  vy = vy + y
  self.RigidBody:setVelocity(vx, vy)
end

function ArrowTrap:die()
  System:remove(self)
end
function ArrowTrap:new(x,y)
  local u = {}
  u.origin = {x=x,y=y}
  u.physics = env.physics

  setmetatable(u, self)
  self.__index = self
  System:install(u, RigidBody, {type=MOAIBox2DBody.DYNAMIC})


  local fixture = u.RigidBody:createRectFixture(-10, -8, 10, 2)
  fixture:setRestitution(0)
  fixture:setFriction(0)
  fixture.name = "ArrowTrap"
  fixture.class = "DynamicTrap"
  fixture.entity = u
  fixture:setFilter(env.physics.categories.critter, env.physics.masks.critter)
  u.RigidBody:useFixtureAsSensor(fixture)
  fixture:setSensor(false)
  u.RigidBody:setActive(true)
  u.RigidBody:setLoc(x,y)
  u.RigidBody:setFixedRotation(false)

  System:install(u, Sprite)
  u.Sprite:loadSprite(env.layWorld, "ninjastar.png", 30, 30, 1,1, true)
  u.Sprite:setAnimationSequence("idle"        , 1 , {1})
  u.Sprite:useAnimation("idle")
  u.Sprite:showFrame(1)
  u.Sprite:rotate(-3600, 1.0)

  System:install(u, FlyingDeath)
  System:install(u, Suicide, {life=3, enabled=true})


  return u
end

return ArrowTrap