
local Obstacle = {}

function Obstacle:onCollision(phase, fixa, fixb, arbiter)
  if not self.enabled then return end

  if phase == MOAIBox2DArbiter.BEGIN then
    if fixb.class == "Skill" and fixb.name=="Punch" then

      local ent = fixb.component.entity
      local x,y = ent.RigidBody:getLoc()

      if fixa.name == "WallA" then

        Level:incBox()
        BubbleWord:new({
          x   = x-10+math.random(20),
          y   = y+10+math.random(20),
          num = Level:numBox(),
          name= fixa.name
        })
      end

      self:die()

    end
  end

end

function Obstacle:particles(x,y)

      CONST = MOAIParticleScript.packConst

      local PARTICLE_X1 = MOAIParticleScript.packReg ( 1 )
      local PARTICLE_Y1 = MOAIParticleScript.packReg ( 2 )
      local PARTICLE_R0 = MOAIParticleScript.packReg ( 3 )
      local PARTICLE_R1 = MOAIParticleScript.packReg ( 4 )
      local PARTICLE_S0 = MOAIParticleScript.packReg ( 5 )
      local PARTICLE_S1 = MOAIParticleScript.packReg ( 6 )

      local system = MOAIParticleSystem.new ()
      system:reserveParticles ( 32, 2 )
      system:reserveSprites ( 32 )
      system:reserveStates ( 1 )
      system:setDeck ( self.texture )
      system:start ()

      local emitter = MOAIParticleDistanceEmitter.new ()
      emitter:setLoc ( 0, 0 )
      emitter:setSystem ( system )
      emitter:setMagnitude ( 0.125 )
      -- emitter:setAngle ( 260, 280 )
      emitter:setDistance ( 2 )
      emitter:start ()

      local state1 = MOAIParticleState.new ()
      state1:setTerm ( 0, 2.25 )
      env.layWorld:insertProp ( system )

      local init = MOAIParticleScript.new ()
      init:rand   ( PARTICLE_X1, CONST ( x+300 ), CONST ( x+300))
      init:rand   ( PARTICLE_Y1, CONST ( y-100), CONST ( y+100))
      local render = MOAIParticleScript.new ()
      render:ease   ( MOAIParticleScript.PARTICLE_X, MOAIParticleScript.PARTICLE_X, PARTICLE_X1, MOAIEaseType.LINEAR )
      render:ease   ( MOAIParticleScript.PARTICLE_Y, MOAIParticleScript.PARTICLE_Y, PARTICLE_Y1, MOAIEaseType.LINEAR )

      render:sprite()
      -- render:ease( MOAIParticleScript.SPRITE_X_SCL, CONST ( 0.8 ), CONST ( 0.1),MOAIEaseType.EASE_IN)
      -- render:ease( MOAIParticleScript.SPRITE_Y_SCL, CONST ( 0.8), CONST ( 0.1),MOAIEaseType.EASE_IN)
      render:ease( MOAIParticleScript.SPRITE_OPACITY, CONST ( 0.6), CONST ( 0.0),MOAIEaseType.SOFT_EASE_IN)
      render:rand( MOAIParticleScript.SPRITE_ROT, CONST (0), CONST (15))

      state1:setInitScript ( init )
      state1:setRenderScript ( render )
      system:setState ( 1, state1 )

      system:surge ( 8,x,y,x,y)

      delay(0.5, function()
        system:stop() -- without this line the FPS drops every level!!
        system:setDeck(nil)
        env.layWorld:removeProp(system)
        system = nil
      end)
end

function Obstacle:push(x, y)
  local vx, vy = self.RigidBody:getVelocity()
  vx = vx + x
  vy = vy + y
  self.RigidBody:setVelocity(vx, vy)
end

function Obstacle:die()
  if not self.enabled then return end

  Audio:playSound("07 - Death-enemy")

  self.enabled = false

  local x,y = self.RigidBody:getLoc()
  y = y + self.height
  self:particles(x,y-120)
  self:particles(x,y-90)
  self:particles(x,y-60)
  self:particles(x,y-30)
  self:particles(x,y)

  self.FallingDeath:die(100,-300, 50)

  delay(0.2, function()
    Level:removeNPC(self)
    System:remove(self)
  end)

  Audio:playSound("17 - Break")

end


local function _buildWallA(u, ref)
  local ppt = ref.properties

  u.headWidth = 60

  u.texture = TextureManager:loadPureTexture('ninjastar.png', 20, 20)

  System:install(u, RigidBody, {type=MOAIBox2DBody.DYNAMIC})

  local fixture = u.RigidBody:createRectFixture(-16, -16, 16, 16)
  fixture:setRestitution(0.1)
  fixture:setFriction(9999)
  fixture.name = "WallA"
  fixture.class = "Obstacle"
  fixture.entity = u
  fixture:setFilter(
    env.physics.categories.critter+env.physics.categories.scenary,
    env.physics.masks.scenary)
  u.RigidBody:useFixtureAsSensor(fixture)
  fixture:setSensor(false)
  u.RigidBody:setActive(true)
  u.RigidBody:setLoc(ref.x, ref.y)

  System:install(u, Sprite)
  u.Sprite:loadSprite(env.layFG, "box.png", 32, 32, 1,1)
  u.Sprite:showFrame(1)


  System:install(u, FallingDeath)
  -- u.Sprite.prop:setPriority(900)
  -- u.Sprite.propIX:setPriority(900)

  return u
end


function Obstacle:new(ref)
  local u = {}
  u.x = x
  u.y = y
  u.height = ref.height
  u.class = ref.type
  u.physics = env.physics
  u.enabled = true
  u.name = ref.type

  setmetatable(u, self)
  self.__index = self

  if ref.type == "WallA" then
    return _buildWallA(u,ref)
  end


end

return Obstacle