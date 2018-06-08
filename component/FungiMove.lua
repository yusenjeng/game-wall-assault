
FungiMove = {}
FungiMove.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------
function FungiMove:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function FungiMove:onConnect(opt)
  self.enable = true
  self.dt = 0
  self.spdX = 50
  if opt and opt.spdX then
    self.optX = opt.spd
  end
end

function FungiMove:speed(v)
  if not v then return self.spdX end
  v = v or 50
  self.spdX = v
end

function FungiMove:turnAround()
  self.spdX = - self.spdX
end

function FungiMove:onUpdate(dt)
  if not self.enable or self.spdX == 0 then return end
  self.dt = self.dt + dt

  if self.dt > 0.2 then
    local vx,vy = self.entity.RigidBody:getVelocity()
    self.entity.RigidBody:setVelocity(self.spdX, vy)
    self.dt = 0
  end

end

------------------------------------------------------
-- Entity events
------------------------------------------------------



