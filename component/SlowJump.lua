
SlowJump = {}
SlowJump.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------
function SlowJump:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function SlowJump:onConnect()
  self.dt = 0
  self.enabled = false
  self.vx = 0
  self.vy = 0
  self.t = 0
end

function SlowJump:enable(vx, vy, t)
  self.enabled = true
  self.vx = vx
  self.vy = vy
  self.t = t
end
function SlowJump:disable()
  self.enabled = false
  self.vy = 0
  self.vx = 0
  self.t = 0
end

function SlowJump:onUpdate(dt)
  if not self.enabled then return end
  self.dt = self.dt + dt

  if self.t > 0 then
    self.t = self.t - dt

    local vx,vy = self.entity.RigidBody:getVelocity()

    if vy > 0 then
      self.entity.RigidBody:setVelocity(vx+self.vx , vy-self.vy)
      -- trace("slowjump", vy, self.t, self.vy)
    end

    self.dt = 0
  end

end



------------------------------------------------------
-- Entity events
------------------------------------------------------



