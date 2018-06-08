
local StrayDog = {}

function StrayDog:onCollision(phase, fixa, fixb, arbiter)
  if not self.enabled then return end

  local flagLand = fixb.class == "Terrain" and fixb.name ~= "Wall"

  if fixa.name == "StrayDog" and flagLand then
    if phase==MOAIBox2DArbiter.BEGIN then
      local x1,y1 = self.RigidBody:getLoc()
      if self:isState("jump") then
        self:land()
      end
    end
  end

  if fixa.name == "StrayDog" and fixb.name == "up" then
    if phase==MOAIBox2DArbiter.BEGIN then
        self:land()
        self.Liftup:enable(env.vy_hero_uphill, env.vy_hero_uphill_th)
    elseif phase==MOAIBox2DArbiter.END then
        self.Liftup:disable()
    end
  end

  if fixa.name == "StrayDog" and fixb.name == "down" then
    if phase==MOAIBox2DArbiter.BEGIN then
        self:land()
        self.Liftup:enable(env.vy_hero_downhill, env.vy_hero_downhill_th)
    elseif phase==MOAIBox2DArbiter.END then
        self.Liftup:disable()
    end
  end

  if fixb.name == "DeathZone" then
    self:die()
  end

  if fixb.class == "Skill" and fixb.name=="Punch" then
    local ent = fixb.component.entity
    local x,y = ent.RigidBody:getLoc()
    Level:incEnemy()
    BubbleWord:new({
      x   = x-10+math.random(20),
      y   = y+10+math.random(20),
      num = Level:numEnemy(),
      name= "Enemy"
    })
    self:die()
  end

  if fixb.class == "hero" and phase == MOAIBox2DArbiter.BEGIN then
    local ent = fixb.entity

    local x1,y1 = ent.RigidBody:getLoc()
    local x2,y2 = self.RigidBody:getLoc()
    -- trace(math.ceil(y1),math.ceil(y2),math.abs(x1-x2+ent.width/2),self.headWidth)
    if y1 < y2-16 and math.abs(x1-x2+ent.width/2) < self.headWidth then
      fixa:setSensor(true)
      self:die()
    else
      fixa:setSensor(true)
      self:die()
      ent:die()
    end

    Level:incEnemy()
    BubbleWord:new({
      x   = x1-10+math.random(20),
      y   = y1+10+math.random(20),
      num = Level:numEnemy(),
      name= "Enemy"
    })
    -- self.enabled = false
  end
end

function StrayDog:push(x, y)
  local vx, vy = self.RigidBody:getVelocity()
  vx = vx + x
  vy = vy + y
  self.RigidBody:setVelocity(vx, vy)
end

function StrayDog:die()
  if not self.enabled then return end

  if self.Pocket then
    self.Pocket:clear()
  end

  local vx,vy = self.RigidBody:getVelocity()
  if vx > 10 then vx = 10 end
  if vx < -10 then vx = -10 end
  self:push(vx, -10)

  Audio:playSound("07 - Death-enemy")

  self.enabled = false
  self.FallingDeath:die()
  local tmr = nil
  tmr = addTimer(2, function()
    Level:removeNPC(self)
    System:remove(self)
    tmr:stop()
    tmr = nil
  end)

end

local function _buildStrayDog(u, ref)
  u.headWidth = 30

  System:install(u, RigidBody, {type=MOAIBox2DBody.DYNAMIC})

  local fixture = u.RigidBody:createRectFixture(-16, -16, 16, 16)
  fixture:setRestitution(0)
  fixture:setFriction(0)
  fixture.name = "StrayDog"
  fixture.class = "Enemy"
  fixture.entity = u
  fixture:setFilter(
    env.physics.categories.critter,
    env.physics.masks.critter)
  u.RigidBody:useFixtureAsSensor(fixture)
  fixture:setSensor(false)
  u.RigidBody:setActive(true)
  u.RigidBody:setLoc(ref.x, ref.y+12)


  local vx = env.vx_dog + math.random(20)
  System:install(u, DogMove, ref)
  u.DogMove:speed(vx)

  local interval = 0.1
  if math.abs(vx) > 200 then
    interval = 0.06
  elseif math.abs(vx) > 100 then
    interval = 0.07
  end

  System:install(u, Sprite)
  u.Sprite:loadSprite(env.layFG, "ene1.png", 48, 48, 5, 1)
  u.Sprite:setAnimationSequence("run", interval, {1,2,3,2})
  u.Sprite:useAnimation("run")
  u.Sprite:looping()
  u.Sprite:flip( (vx<=0) )


  System:install(u, FallingDeath)
  System:install(u, Liftup)
  System:install(u, UnitStatus)

  u.Sprite.prop:setPriority(900)
  u.Sprite.propIX:setPriority(900)

  -- u:toRight()

  return u
end

function StrayDog:new(ref)
  local u = {}
  u.x = x
  u.y = y
  u.physics = env.physics
  u.enabled = true
  u.name = ref.type or "StrayDog"

  setmetatable(u, self)
  self.__index = self

  return _buildStrayDog(u,ref)
end

return StrayDog