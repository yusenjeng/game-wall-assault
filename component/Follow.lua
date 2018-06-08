
Follow = {}
Follow.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------
function Follow:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function Follow:onConnect(opt)
  self.dt = 0
  self.tar = nil
end

function Follow:enable(tar)
  self.tar = tar
end
function Follow:disable()
  self.tar = nil
end
function Follow:mute(dt)
  self.dt = dt
end

function Follow:onUpdate(dt)
  if not self.tar then return end
  if self.dt > 0 then
    self.dt = self.dt - dt
    return
  end

  local tar = self.tar
  local ent = self.entity
  local ox,oy = ent.RigidBody:getLoc()
  local x,y   = tar.RigidBody:getLoc()
  local vx,vy = tar.RigidBody:getVelocity()

  local log = self.tar.ActionLog:head()
  if log then
      ent.RigidBody:setLoc(log.x, log.y)
  end

end

------------------------------------------------------
-- Entity events
------------------------------------------------------



