
local Hero = {}

function Hero:onCollision(phase, fixa, fixb, arbiter)
  if not self:isEnabled() then return end

  local flagLand = fixb.class == "Terrain" and fixb.name ~= "Wall"
  flagLand = flagLand or fixb.name == "HeavyBox"
  flagLand = flagLand or fixb.name == "MageShield"

  if fixa.class == "hero" and flagLand then
    if phase==MOAIBox2DArbiter.BEGIN then
      local x1,y1 = self.RigidBody:getLoc()
      local dy = 20
      if fixb.y then
        dy = math.floor(fixb.y - y1)
      end
      if self:isState("jump") and self.RigidBody:isFlying() and dy>20 and dy<24 then
        self:land()
        Audio:playSound("10 - Landing")
      end

    end
  end

  if fixa.class=="hero" and fixb.name == "up" then
    if phase==MOAIBox2DArbiter.BEGIN then
        self:land()
        self.Liftup:enable(env.vy_hero_uphill, env.vy_hero_uphill_th)
    elseif phase==MOAIBox2DArbiter.END then
        self.Liftup:disable()
        self:push(0,20)
    end
  end

  if fixa.class=="hero" and fixb.name == "down" then
    if phase==MOAIBox2DArbiter.BEGIN then
        self:land()
        self.Liftup:enable(env.vy_hero_downhill, env.vy_hero_downhill_th)
    elseif phase==MOAIBox2DArbiter.END then
        self.Liftup:disable()
        self:push(0,100)
    end
  end


  if fixa.class == "hero" and fixb.name == "DeathZone" then
    if Level:isLeader(fixa.entity) then
      Level:lockCamera()
    end
    self:die()
  end

  if fixa.class == "hero" and fixb.class=="Item" and phase == MOAIBox2DArbiter.BEGIN then
    self.Pocket:add(fixb.entity.key)
  end

  -- if fixa.class == "onSight" and fixa.name == "ladder" and fixb.name=="Ladder" then
  --   if phase == MOAIBox2DArbiter.BEGIN then
  --     self:nearLadder(true, fixb)
  --   elseif phase == MOAIBox2DArbiter.END and not self:isState("enterLadder") then
  --     self:nearLadder(false)
  --   end
  -- end

  if fixa.class == "onSight" and fixb.class == "Obstacle" then
    if phase == MOAIBox2DArbiter.BEGIN then
      -- self:setNearbyTarget(fixb.entity.key, true)
      -- self:toFight()
      local x1,y1 = self.RigidBody:getLoc()
      local x2,y2 = fixb.entity.RigidBody:getLoc()
      local dy = math.floor(y2 - y1)
      -- trace(dy)
      if dy >= 30 then
        self:land()
      end

      self:touchObstacle()
    elseif phase == MOAIBox2DArbiter.END then
      self:leaveObstacle()
    end
  end

  -- if fixa.class == "Shield" and fixb.class == "DynamicTrap" then
  --   if phase == MOAIBox2DArbiter.BEGIN then
  --     local vx, vy = fixb.entity.RigidBody:getVelocity()
  --     fixb.entity:push(-vx+1000, vy+600)
  --   end
  -- end

end

function Hero:push(x, y)
  local vx, vy = self.RigidBody:getVelocity()
  vx = vx + x
  vy = vy + y
  self.RigidBody:setVelocity(vx, vy)
end

function Hero:isRIP()
  return self.rip
end

function Hero:revive()
  if not self.rip then return end
  self.rip = false

  self.Sprite:useAnimation("run")
  self.Sprite:looping()
  self:toRight(true)
end

function Hero:die()
  if not self:isEnabled() then return end
  if self.rip then return end

  local x,y = self.RigidBody:getLoc()
  self.Sprite:stop()
  self.Sprite:showFrame(4)
  self.rip = true
  self.RigidBody:setVelocity(0,0)

  Audio:playSound("08 - Death")

  if Level:isLeader(self) then

    local ret = Level:nextHero()

    if not ret then
      ret = Level:nextHero()
    end

    if not ret then
      ret = Level:nextHero()
    end

    if not ret then
      ret = Level:nextHero()
    end

    if not ret then
      ret = Level:nextHero()
    end

    if not ret then
      ret = Level:nextHero()
    end
  end

  local fx = Fx:getExplosion()
  fx.Sprite:setLoc(x,y)
  fx.Sprite:show()
  fx.Sprite:play(true, function()
    self.Sprite:showFrame(4)
    System:remove(fx)
  end)

  if Level:allDead() then
    Level:waitForReset()
    return
  end
end

function Hero:newMag(x,y)
  local u = {}
  u.x = x
  u.y = y
  u.dashX = 0
  u.physics = env.physics
  u.name = "mag"
  u.rip  = false
  u.width = 20

  setmetatable(u, self)
  self.__index = self

  System:install(u, RigidBody)

  local fixture = u.RigidBody:createRectFixture(-10, -12, 10, 22)
  fixture:setRestitution(0)
  fixture:setFriction(env.friction_hero)
  fixture.name = "mag"
  fixture.class = "hero"
  fixture.entity = u
  fixture:setFilter(env.physics.categories.hero, env.physics.masks.hero)
  u.RigidBody:useFixtureAsSensor(fixture)
  fixture:setSensor(false)
  u.RigidBody:setActive(true)
  u.RigidBody:setLoc(x,y)

  local fixOnSight = u.RigidBody:createRectFixture(-50, -20, 50, 15)
  fixOnSight:setRestitution(0)
  fixOnSight:setFriction(0)
  fixOnSight.name = "attack"
  fixOnSight.class = "onSight"
  u.RigidBody:useFixtureAsSensor(fixOnSight)

  local fixOnLadder = u.RigidBody:createRectFixture(-1, -10, 1, 10)
  fixOnLadder:setRestitution(0)
  fixOnLadder:setFriction(0)
  fixOnLadder.name = "ladder"
  fixOnLadder.class = "onSight"
  u.RigidBody:useFixtureAsSensor(fixOnLadder)

  System:install(u, Sprite)
  u.Sprite:loadSprite(env.layWorld, "char3.png", 48,48, 4, 1)
  u.Sprite:setAnimationSequence("idle"        , env.sprite_interval_run, {1,2,3,2})
  u.Sprite:setAnimationSequence("run"         , env.sprite_interval_run, {1,2,3,2})
  u.Sprite:setAnimationSequence("jump"        , env.sprite_interval_run, {1,2,3,2})
  u.Sprite:setAnimationSequence("die"         , 0.2, {4})  -- u.Sprite:loadSprite(env.layWorld, "mm3.png", 48,48, 6, 2)
  -- u.Sprite:setAnimationSequence("idle"        , 0.1 , {5})
  -- u.Sprite:setAnimationSequence("melee_attack", 0.15, {1,2,3,1})
  -- u.Sprite:setAnimationSequence("run"         , env.sprite_interval_run, {6,7,8})
  -- u.Sprite:setAnimationSequence("jump"        , 0.1, {4})
  -- u.Sprite:setAnimationSequence("die"         , 0.1, {12})

  u.Sprite:useAnimation("run")
  u.Sprite:looping()

  System:install(u, UnitStatus)
  System:install(u, Pocket)
  System:install(u, CommonBehavior)
  System:install(u, MagBehavior)
  System:install(u, ClimbLadder)
  System:install(u, MsgBox)
  System:install(u, Liftup)
  System:install(u, ActionLog)

  System:install(u, Follow)
  System:install(u, KeyControl)

  u:toRight()

  return u
end

function Hero:newBard(x,y)
  local u = {}
  u.x = x
  u.y = y
  u.dashX = 0
  u.physics = env.physics
  u.name = "bard"
  u.rip  = false
  u.width = 20

  setmetatable(u, self)
  self.__index = self

  System:install(u, RigidBody)

  local fixture = u.RigidBody:createRectFixture(-10, -12, 10, 22)
  fixture:setRestitution(0)
  fixture:setFriction(env.friction_hero)
  fixture.name = "bard"
  fixture.class = "hero"
  fixture.entity = u
  fixture:setFilter(env.physics.categories.hero, env.physics.masks.hero)
  u.RigidBody:useFixtureAsSensor(fixture)
  fixture:setSensor(false)
  u.RigidBody:setActive(true)
  u.RigidBody:setLoc(x,y)

  local fixOnSight = u.RigidBody:createRectFixture(-50, -20, 50, 15)
  fixOnSight:setRestitution(0)
  fixOnSight:setFriction(0)
  fixOnSight.name = "attack"
  fixOnSight.class = "onSight"
  u.RigidBody:useFixtureAsSensor(fixOnSight)

  local fixOnLadder = u.RigidBody:createRectFixture(-1, -10, 1, 10)
  fixOnLadder:setRestitution(0)
  fixOnLadder:setFriction(0)
  fixOnLadder.name = "ladder"
  fixOnLadder.class = "onSight"
  u.RigidBody:useFixtureAsSensor(fixOnLadder)

  System:install(u, Sprite)
  -- u.Sprite:loadSprite(env.layWorld, "mm2.png", 48,48, 6, 2)
  -- u.Sprite:setAnimationSequence("idle"        , 0.1 , {5})
  -- u.Sprite:setAnimationSequence("melee_attack", 0.05, {1,2,3,1})
  -- u.Sprite:setAnimationSequence("run"         , env.sprite_interval_run, {6,7,8})
  -- u.Sprite:setAnimationSequence("jump"        , 0.1, {4})
  -- u.Sprite:setAnimationSequence("die"         , 0.1, {12})
  u.Sprite:loadSprite(env.layWorld, "char2.png", 48,48, 4, 1)
  u.Sprite:setAnimationSequence("idle"        , env.sprite_interval_run, {1,2,3,2})
  u.Sprite:setAnimationSequence("run"         , env.sprite_interval_run, {1,2,3,2})
  u.Sprite:setAnimationSequence("jump"        , env.sprite_interval_run, {1,2,3,2})
  u.Sprite:setAnimationSequence("die"         , 0.2, {4})  -- u.Sprite:loadSprite(env.layWorld, "mm3.png", 48,48, 6, 2)

  u.Sprite:useAnimation("run")
  u.Sprite:looping()

  System:install(u, UnitStatus)
  System:install(u, Pocket)
  System:install(u, CommonBehavior)
  System:install(u, BardBehavior)
  System:install(u, ClimbLadder)
  System:install(u, MsgBox)
  System:install(u, Liftup)
  System:install(u, ActionLog)
  -- System:install(u, SlowJump)

  System:install(u, Follow)
  System:install(u, KeyControl)

  u:toRight()
  return u
end

function Hero:newWar(x,y)
  local u = {}
  u.x = x
  u.y = y
  u.dashX = 0
  u.physics = env.physics
  u.name = "war"
  u.rip  = false
  u.width = 20

  setmetatable(u, self)
  self.__index = self

  System:install(u, RigidBody)

  local fixture = u.RigidBody:createRectFixture(-10, -12, 10, 22)
  fixture:setRestitution(0)
  fixture:setFriction(env.friction_hero)
  fixture.name = "war"
  fixture.class = "hero"
  fixture.entity = u
  fixture:setFilter(
    env.physics.categories.hero,
    env.physics.masks.hero)
  u.RigidBody:useFixtureAsSensor(fixture)
  u.RigidBody:setActive(true)
  u.RigidBody:setLoc(x,y)
  fixture:setSensor(false)

  local fixOnSight = u.RigidBody:createRectFixture(-80, -40, 80, 30)
  fixOnSight:setRestitution(0)
  fixOnSight:setFriction(0)
  fixOnSight.name = "attack"
  fixOnSight.class = "onSight"
  u.RigidBody:useFixtureAsSensor(fixOnSight)

  local fixOnLadder = u.RigidBody:createRectFixture(-1, -10, 1, 10)
  fixOnLadder:setRestitution(0)
  fixOnLadder:setFriction(0)
  fixOnLadder.name = "ladder"
  fixOnLadder.class = "onSight"
  u.RigidBody:useFixtureAsSensor(fixOnLadder)

  System:install(u, Sprite)

  u.Sprite:loadSprite(env.layWorld, "char1.png", 48,48, 4, 1)
  u.Sprite:setAnimationSequence("idle"        , env.sprite_interval_run, {1,2,3,2})
  u.Sprite:setAnimationSequence("run"         , env.sprite_interval_run, {1,2,3,2})
  u.Sprite:setAnimationSequence("jump"        , env.sprite_interval_run, {1,2,3,2})
  u.Sprite:setAnimationSequence("die"         , 0.2, {4})  -- u.Sprite:loadSprite(env.layWorld, "mm3.png", 48,48, 6, 2)
  u.Sprite:setAnimationSequence("melee_attack", env.sprite_interval_run, {1,2,3,2})  -- u.Sprite:loadSprite(env.layWorld, "mm3.png", 48,48, 6, 2)

  -- u.Sprite:loadSprite(env.layWorld, "mm1.png", 48, 48, 6, 2)
  -- u.Sprite:setAnimationSequence("idle"         ,0.1  , {5})
  -- u.Sprite:setAnimationSequence("melee_attack" ,0.09 , {1,2,3,1})
  -- u.Sprite:setAnimationSequence("run"          ,env.sprite_interval_run, {6,7,8,7})
  -- u.Sprite:setAnimationSequence("jump"         ,0.1  , {4})
  -- u.Sprite:setAnimationSequence("die"          ,0.1  , {12})
  -- u.Sprite:useAnimation("idle")
  -- u.Sprite:looping()

  System:install(u, UnitStatus)
  System:install(u, CommonBehavior)
  System:install(u, WarBehavior)
  System:install(u, Pocket)
  System:install(u, ClimbLadder)
  System:install(u, MsgBox)
  System:install(u, Liftup)
  System:install(u, ActionLog)

  System:install(u, Follow)
  System:install(u, KeyControl)

  u:toRight()

  return u
end



return Hero