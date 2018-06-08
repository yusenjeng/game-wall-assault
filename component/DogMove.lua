
DogMove = {}
DogMove.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------
function DogMove:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function DogMove:onConnect(opt)
  self.enable = true
  self.dt = 0
  self.spdX = 120
  self.chance_jump = opt.chance_jump or env.chance_jump
  if opt and opt.spdX then
    self.optX = opt.spd
  end
end

function DogMove:speed(v)
  if not v then return self.spdX end
  v = v or 50
  self.spdX = v
end

function DogMove:turnAround()
  self.spdX = - self.spdX
end

function DogMove:onUpdate(dt)
  if not self.enable or self.spdX == 0 then return end
  if self.entity:isState("sleep") then return end

  self.dt = self.dt + dt

  if self.dt > 0.2 then
    local vx,vy = self.entity.RigidBody:getVelocity()
    self.entity.RigidBody:setVelocity(self.spdX, vy)

    if math.random(100) < self.chance_jump then
      self.entity:jump()
    -- elseif math.random(100) < env.chance_fwjump then
    --   self.entity:jumpForward()
    end

    self.dt = 0
  end

end

------------------------------------------------------
-- Entity events
------------------------------------------------------
function DogMove.e:land()
  self:stateOff("jump")
  self:stateOff("fight")
  local vx, vy = self.RigidBody:getVelocity()
end

function DogMove.e:jump()
  if self:isState("jump") then return end
  self:stateOn("jump")
  -- self.Sprite:useAnimation("jump")
  -- self.Sprite:looping()
  self.Liftup:disable()

  Audio:playSound("09 - Jump")

  local vx,vy = self.RigidBody:getVelocity()
  self.RigidBody:setVelocity(vx+env.vx_jump_dog, vy-env.vy_jump_dog)
end


function DogMove.e:jumpForward()
  if self:isState("jump") then return end
  self:stateOn("jump")
  -- self.Sprite:useAnimation("jump")
  -- self.Sprite:looping()
  self.Liftup:disable()

  Audio:playSound("09 - Jump")

  local vx,vy = self.RigidBody:getVelocity()
  self.RigidBody:setVelocity(vx+env.vx_fwjump_dog, vy-env.vy_fwjump_dog/2)
end

