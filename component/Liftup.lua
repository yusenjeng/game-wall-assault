
Liftup = {}
Liftup.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------
function Liftup:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function Liftup:onConnect()
  self.dt = 0
  self.enabled = false
end

function Liftup:enable(vy, vymax)
  self.enabled = true
  self.vy = vy
  self.vy_max = vymax
end
function Liftup:disable()
  self.enabled = false
  self.vy = nil
  self.vy_max = nil
end

function Liftup:onUpdate(dt)
  if not self.enabled then return end
  self.dt = self.dt + dt

  if self.dt > 0.02 then

    local vx,vy = self.entity.RigidBody:getVelocity()

    if self.vy and self.vy_max and vy > -self.vy_max then
      self.entity.RigidBody:setVelocity(vx , vy-self.vy)
      -- trace("enable", vy, self.vy, self.vy_max)
    end

    if vy > -env.vy_hero_uphill_th then
      self.entity.RigidBody:setVelocity(vx+10 , vy-env.vy_hero_uphill)
    end

    self.dt = 0
  end

end



------------------------------------------------------
-- Entity events
------------------------------------------------------



