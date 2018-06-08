
FallingDeath = {}
FallingDeath.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------
function FallingDeath:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function FallingDeath:onConnect()
  self.enable = false
  self.dt = 0
  self.dtBoost = 0
  self.xFly = math.random(100)
end

function FallingDeath:onDestroy()

end

function FallingDeath:onUpdate(dt)
  if not self.enable then return end
end

function FallingDeath:die(fx,fy,r)
  self.enable = true
  self.entity.RigidBody:setFixedRotation(true)
  self.entity.RigidBody:setSensor(true)
  self.dt = 0.21

  fx = fx or 0
  fy = fy or -200
  r = r or 100
  self.entity:push(fx, fy)
  self.entity.Sprite:rotate(r+math.random(r), 0.3)
end

------------------------------------------------------
-- Entity events
------------------------------------------------------

-- function FallingDeath.e:push(x, y)
--   local vx, vy = self.RigidBody:getVelocity()
--   vx = vx + x
--   vy = vy + y
--   self.RigidBody:setVelocity(vx, vy)
-- end



