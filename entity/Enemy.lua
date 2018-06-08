
local Enemy = {}

function Enemy:onCollision(phase, fixa, fixb, arbiter)
  if not self.enabled then return end

  if fixb.name == "DeathZone" then
    self:die()
  end

  if fixb.class == "Skill" and fixb.name=="Punch" then
    self:die()
  end



  if fixa.class == "Enemy" and fixb.class == "hero" and phase == MOAIBox2DArbiter.BEGIN then
    local ent = fixb.entity
    local x1,y1 = ent.RigidBody:getLoc()
    local x2,y2 = self.RigidBody:getLoc()

    if y1 < y2-16 and math.abs(x1-x2+ent.width/2) < self.headWidth then
      self:die()

      if self.name=="Fungi" or self.name=="FixedFungi" then
        local vx,vy = ent.RigidBody:getVelocity()
        ent.RigidBody:setVelocity(vx,0)
        ent:push(10, -250)
      end
      Level:incEnemy()
      BubbleWord:new({
        x   = x1-10+math.random(20),
        y   = y1+10+math.random(20),
        num = Level:numEnemy(),
        name= "Enemy"
      })

    else
      if ent.name ~= "mag" then
        ent:die()
      end
      fixa:setSensor(true)
      self:die()

      Level:incEnemy()
      BubbleWord:new({
        x   = x1-10+math.random(20),
        y   = y1+10+math.random(20),
        num = Level:numEnemy(),
        name= "Enemy"
      })
    end
    self.enabled = false
  end

  if fixa.class == "onSight" and fixb.class == "hero" then
    if phase == MOAIBox2DArbiter.BEGIN then
      self:startShooting()
    elseif phase == MOAIBox2DArbiter.END then
      delay(5, function()
        self:stopShooting()
      end)
    end
  end

end

function Enemy:push(x, y)
  local vx, vy = self.RigidBody:getVelocity()
  vx = vx + x
  vy = vy + y
  self.RigidBody:setVelocity(vx, vy)
end

function Enemy:die()
  if not self.enabled then return end

  local vx,vy = self.RigidBody:getVelocity()
  if vx > 10 then vx = 10 end
  if vx < -10 then vx = -10 end
  self:push(vx, -10)

  Audio:playSound("07 - Death-enemy")
  self.RigidBody:setSensor(true)

  self.enabled = false
  if self.FallingDeath then
    self.FallingDeath:die(100, -100, 45)
  end

  if self.name == "Archer" then
    self:stopShooting()
  end

  delay(2, function()
    Level:removeNPC(self)
    System:remove(self)
  end)

end

local function _buildFungi(u, ref)
  local ppt = ref.properties

  u.headWidth = 32

  System:install(u, RigidBody, {type=MOAIBox2DBody.DYNAMIC})

  local fixture = u.RigidBody:createRectFixture(-15, -8, 15, 22)
  fixture:setRestitution(0)
  fixture:setFriction(0)
  fixture.name = "normal"
  fixture.class = "Enemy"
  fixture.entity = u
  fixture:setFilter(env.physics.categories.critter, env.physics.masks.critter)
  u.RigidBody:useFixtureAsSensor(fixture)
  fixture:setSensor(false)

  System:install(u, Sprite)
  u.Sprite:loadSprite(env.layFG, "ene1.png", 48, 48, 5, 1)
  u.Sprite:setAnimationSequence("run", 0.1, {1,2,3,2})
  u.Sprite:flip(true)
  u.Sprite:useAnimation("run")
  u.Sprite:looping()

  System:install(u, FallingDeath)
  -- System:install(u, Pocket)
  System:install(u, FungiMove)

  u.FungiMove:speed( tonumber(ppt.speed) )
  u.Sprite.prop:setPriority(900)
  u.Sprite.propIX:setPriority(900)
  u.RigidBody:setActive(true)
  u.RigidBody:setLoc(ref.x, ref.y)

  return u
end

local function _buildFixedFungi(u, ref)
  local ppt = ref.properties

  u.headWidth = 40

  System:install(u, RigidBody, {type=MOAIBox2DBody.STATIC})

  local fixture = u.RigidBody:createRectFixture(-15, -15, 15, 15)
  fixture:setRestitution(0)
  fixture:setFriction(0)
  fixture.name = "normal"
  fixture.class = "Enemy"
  fixture.entity = u
  fixture:setFilter(env.physics.categories.critter, env.physics.masks.critter)
  u.RigidBody:useFixtureAsSensor(fixture)
  fixture:setSensor(false)

  System:install(u, Sprite)
  u.Sprite:loadSprite(env.layFG, "ene1.png", 48, 48, 5, 1)
  u.Sprite:showFrame(4)
  u.Sprite:flip(true)

  -- System:install(u, FallingDeath)
  -- System:install(u, Pocket)
  -- System:install(u, FungiMove)

  -- u.FungiMove:speed( tonumber(ppt.speed) )
  u.Sprite.prop:setPriority(900)
  u.Sprite.propIX:setPriority(900)
  u.RigidBody:setActive(true)
  u.RigidBody:setLoc(ref.x, ref.y)

  return u
end

local function _buildWallA(u, ref)
  local ppt = ref.properties

  u.headWidth = 30

  System:install(u, RigidBody, {type=MOAIBox2DBody.DYNAMIC})

  local fixture = u.RigidBody:createRectFixture(-25, -20, 25, 20)
  fixture:setRestitution(0)
  fixture:setFriction(0)
  fixture.name = "WallA"
  fixture.class = "Enemy"
  fixture.entity = u
  fixture:setFilter(env.physics.categories.critter, env.physics.masks.critter)
  u.RigidBody:useFixtureAsSensor(fixture)
  fixture:setSensor(false)
  u.RigidBody:setActive(true)
  u.RigidBody:setLoc(ref.x, ref.y)

  System:install(u, Sprite)
  u.Sprite:loadSprite(env.layFG, "Cheval de frise.png", 64, 64, 1,1)
  u.Sprite:showFrame(1)
  -- u.Sprite:flip(true)

  -- System:install(u, FallingDeath)
  -- System:install(u, Pocket)
  -- System:install(u, FungiMove)
  -- System:install(u, Camp, ppt)
  -- System:install(u, CannonBehavior, ppt)

  -- u.FungiMove:speed( tonumber(ppt.speed) )
  u.Sprite.prop:setPriority(900)
  u.Sprite.propIX:setPriority(900)

  return u
end

local function _buildArcher(u, ref)
  local ppt = ref.properties

  u.headWidth = 60

  System:install(u, RigidBody, {type=MOAIBox2DBody.STATIC})

  local fixture = u.RigidBody:createRectFixture(-16, -16, 16, 16)
  fixture:setRestitution(0)
  fixture:setFriction(0)
  fixture.name = "normal"
  fixture.class = "Enemy"
  fixture.entity = u
  fixture:setFilter(env.physics.categories.critter, env.physics.masks.critter)
  u.RigidBody:useFixtureAsSensor(fixture)
  fixture:setSensor(false)
  u.RigidBody:setActive(true)
  u.RigidBody:setLoc(ref.x, ref.y+13)


  local fixOnSight = u.RigidBody:createRectFixture(-600, -600, 600, 600)
  fixOnSight:setRestitution(0)
  fixOnSight:setFriction(0)
  fixOnSight.name = "attack"
  fixOnSight.class = "onSight"
  fixOnSight:setFilter(
    env.physics.categories.critter,
    env.physics.masks.scenary)
  u.RigidBody:useFixtureAsSensor(fixOnSight)

  System:install(u, Sprite)
  u.Sprite:loadSprite(env.layFG, "ene2.png", 48, 48, 3, 1)
  u.Sprite:setAnimationSequence("idle", 0.5, {1})
  u.Sprite:setAnimationSequence("shoot", 0.09, {2,3,1})
  u.Sprite:useAnimation("idle")
  u.Sprite:looping()
  u.Sprite:flip(tonumber(ppt.fire_vx) < 0)

  System:install(u, FallingDeath)
  -- System:install(u, Pocket)
  -- System:install(u, FungiMove)
  -- System:install(u, Camp, ppt)
  System:install(u, CannonBehavior, ppt)

  -- u.FungiMove:speed( tonumber(ppt.speed) )
  u.Sprite.prop:setPriority(900)
  u.Sprite.propIX:setPriority(900)

  return u
end

function Enemy:new(ref)
  local u = {}
  u.x = x
  u.y = y
  u.class = ref.type
  u.physics = env.physics
  u.enabled = true
  u.name = ref.type

  setmetatable(u, self)
  self.__index = self

  if ref.type == "Fungi" then
    return _buildFungi(u, ref)
  elseif ref.type == "FixedFungi" then
    return _buildFixedFungi(u, ref)
  elseif ref.type == "Archer" then
    return _buildArcher(u,ref)
  elseif ref.type == "WallA" then
    return _buildWallA(u,ref)
  end

  -- local fixFrenzy = u.RigidBody:createRectFixture(-30, -30, 30, 30)
  -- fixFrenzy:setRestitution(0)
  -- fixFrenzy:setFriction(0)
  -- fixFrenzy.name = "frenzy"
  -- fixFrenzy.class = "Enemy"
  -- u.RigidBody:useFixtureAsSensor(fixFrenzy)



  -- foreground

end

return Enemy