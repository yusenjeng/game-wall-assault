
local Conveyer = {}

function Conveyer:onCollision(phase, fix_a, fixb, arbiter)
  if fixb.class == "Terrain" then
  end

  if fixb.class == "Enemy" and phase == MOAIBox2DArbiter.BEGIN then
  end

  if fixb.class == "hero" then
    local ent = fixb.component.entity
    if not ent:isEnabled() then return end

    if phase == MOAIBox2DArbiter.BEGIN then
      self.SlidingBehavior:enter(ent)
    elseif phase == MOAIBox2DArbiter.END then
      self.SlidingBehavior:leave(ent)
    end

  end
end

function Conveyer:new(ref)
  local u = {}
  u.physics = env.physics

  local left = ref.x
  local right = ref.x+ref.width
  local top = ref.y
  local bottom = ref.y+ref.height

  setmetatable(u, self)
  self.__index = self

  System:install(u, RigidBody, {type=MOAIBox2DBody.STATIC})

  local fixture = u.RigidBody:createRectFixture(left, bottom, right, top)
  fixture.x = ref.x
  fixture.y = ref.y
  fixture:setRestitution(0)
  fixture:setFriction(0)
  fixture.name = "Conveyer"
  fixture.class = "Terrain"
  fixture:setFilter(env.physics.categories.hero+env.physics.categories.critter, env.physics.masks.scenary)
  u.RigidBody:useFixtureAsSensor(fixture)
  fixture:setSensor(false)
  u.RigidBody:setActive(true)

  local ppt = ref.properties
  System:install(u, SlidingBehavior, {speed=tonumber(ppt.speed)})

  -- System:install(u, Sprite)
  -- u.Sprite:loadSprite(env.layWorld, "Conveyer.png", pos.width, pos.height, 1,1, true)
  -- u.Sprite:setAnimationSequence("idle"        , 1 , {1})
  -- u.Sprite:useAnimation("idle")
  -- u.Sprite:showFrame(1)
  -- u.Sprite:setLoc(pos.x+pos.width/2, pos.y+pos.height/2)

  return u
end

return Conveyer