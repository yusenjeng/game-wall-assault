
CannotMove = {}
CannotMove.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------
function CannotMove:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function CannotMove:onConnect(opt)
  self.enabled = false
  self.dt = 0
end

function CannotMove:enable()
  self.x, self.y = self.entity.RigidBody:getLoc()
  self.enabled = true
end
function CannotMove:disable()
  self.enabled = false
end

function CannotMove:onUpdate(dt)
  if not self.enabled then return end
  self.dt = self.dt + dt

  if self.dt > 0.2 then
    self.entity.RigidBody:setLoc(self.x, self.y)
    self.dt = 0
  end

end

------------------------------------------------------
-- Entity events
------------------------------------------------------



