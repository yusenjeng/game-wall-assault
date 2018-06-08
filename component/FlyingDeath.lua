
FlyingDeath = {}
FlyingDeath.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------
function FlyingDeath:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function FlyingDeath:onConnect()
  self.enable = false
  self.dt = 0
  self.dtBoost = 0
  self.xFly = math.random(300)+100
end

function FlyingDeath:onUpdate(dt)
  if not self.enable then return end
  self.dt = self.dt + dt
  self.dtBoost = self.dtBoost + dt

  if self.dt > 0.2 then
    local vx,vy = self.entity.RigidBody:getVelocity()

    if self.dtBoost < 0.30 then
      self.entity.RigidBody:setVelocity(vx + 1000+self.xFly, vy + 100)
    else
      local vx,vy = self.entity.RigidBody:getVelocity()
      self.entity.RigidBody:setVelocity(vx+10*self.factor, vy)
    end

    self.dt = 0
  end

end

function FlyingDeath:die(factor)
  self.factor = factor or 1
  self.enable = true
  self.entity.RigidBody:setSensor(true)
  self.dt = 0.21
  -- self.Sprite:rotate(2400*self.factor, 2)
end

------------------------------------------------------
-- Entity events
------------------------------------------------------



