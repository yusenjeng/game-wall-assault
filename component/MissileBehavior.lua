
MissileBehavior = {}
MissileBehavior.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------
function MissileBehavior:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function MissileBehavior:onConnect(opt)
  self.dt = 0
end

function MissileBehavior:onDestroy()
  self.carrier:die()
end

function MissileBehavior:onUpdate(dt)
  local ent = self.entity
  local tar = self.carrier

  if not tar then return end

  local x,y = tar.RigidBody:getLoc()
  local vx,vy = tar.RigidBody:getVelocity()
  ent.RigidBody:setLoc(x,y)
  ent.RigidBody:setVelocity(vx,vy)
end

------------------------------------------------------
-- Entity events
------------------------------------------------------

function MissileBehavior.e:attachTo(ent)
  self.MissileBehavior.carrier = ent
end

