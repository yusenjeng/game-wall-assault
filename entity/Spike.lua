
local Spike = {}

function Spike:onCollision(phase, fixa, fixb, arbiter)
  if not self.enabled then return end

  if fixb.class == "Terrain" then
  end

  if fixb.class == "Enemy" and phase == MOAIBox2DArbiter.BEGIN then
    fixb.component.entity:die()
  end

  if fixb.class == "hero" then
    local hero = fixb.component.entity
    if hero:isRIP() then return end

    if hero.name == "mag" then
      if phase == MOAIBox2DArbiter.BEGIN then
        self:die()

        local x,y = hero.RigidBody:getLoc()
        Level:incBarricade()
        BubbleWord:new({
          x   = x-10+math.random(20),
          y   = y+10+math.random(20),
          num = Level:numBarricade(),
          name= fixa.name
        })
      end
    else
      if phase == MOAIBox2DArbiter.BEGIN then
        hero:die()
      end
    end

  end
end

function Spike:die()
  if not self.enabled then return end

  Audio:playSound("17 - Break")

  local fx = env.fx_spike_die + math.random(env.fx_spike_die/3)
  local fy = math.random(env.fy_spike_die) - env.fy_spike_die/2
  self:push(fx, fy)
  self.FallingDeath:die()

  self.enabled = false
  delay(2, function()
    System:remove(self)
  end)
end

function Spike:push(x, y)
  local vx, vy = self.RigidBody:getVelocity()
  vx = vx + x
  vy = vy + y
  self.RigidBody:setVelocity(vx, vy)
end

function Spike:new(ref)
  local u = {}
  u.x = x
  u.y = y
  u.hp = 100
  u.physics = env.physics
  u.enabled = true

  local left = ref.x
  local right = ref.x+ref.width
  local top = ref.y+  10
  local bottom = ref.y+ref.height

  setmetatable(u, self)
  self.__index = self

  System:install(u, RigidBody, {type=MOAIBox2DBody.DYNAMIC})

  local fixture = u.RigidBody:createRectFixture(left, bottom, right, top)
  fixture:setRestitution(0)
  fixture:setFriction(9999)
  fixture.name = "Spike"
  fixture.class = "Spike"
  fixture:setFilter(env.physics.categories.hero+env.physics.categories.critter, env.physics.masks.scenary)
  u.RigidBody:useFixtureAsSensor(fixture)
  fixture:setSensor(false)
  u.RigidBody:setActive(true)

  System:install(u, Sprite)
  -- if ref.type == "inv" then
  --   u.Sprite:loadSprite(env.layWorld, "spikes_inv.png", ref.width, ref.height, 1,1, true)
  -- elseif ref.type == "right" then
  --   u.Sprite:loadSprite(env.layWorld, "spikes_right.png", ref.width, ref.height, 1,1, true)
  -- elseif ref.type == "left" then
  --   u.Sprite:loadSprite(env.layWorld, "spikes_left.png", ref.width, ref.height, 1,1, true)
  -- else
  --   u.Sprite:loadSprite(env.layWorld, "spikes.png", ref.width, ref.height, 1,1, true)
  -- end
  u.Sprite:loadSprite(env.layWorld, "Cheval de frise.png", ref.width, ref.height, 1,1, true)

  u.Sprite:setAnimationSequence("idle"        , 1 , {1})
  u.Sprite:useAnimation("idle")
  u.Sprite:showFrame(1)
  u.Sprite:setLoc(ref.x+ref.width/2, ref.y+ref.height/2)


  System:install(u, FallingDeath)
  -- u.SpikeBehavior:toRight()

  return u
end

return Spike