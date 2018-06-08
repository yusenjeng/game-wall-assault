
ActionLog = {}
ActionLog.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------
function ActionLog:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function ActionLog:onConnect(opt)
  self.enable = true
  self.dt = 0
  self.log = queue:new()
  self.sz = 2
end

function ActionLog:head()
  if self.log:size() >= self.sz then
    return self.log:head()
  end
end
function ActionLog:steps(s)
  self.sz = s
end
function ActionLog:clear()
  self.log = queue:new()
end
function ActionLog:onUpdate(dt)
  if not self.enable then return end
  self.dt = self.dt + dt

  -- if self.dt > 0.1 then
    local ent = self.entity
    local x,y = ent.RigidBody:getLoc()
    local vx,vy = ent.RigidBody:getVelocity()
    self.log:push({
      x=x,y=y,vx=vx,vy=vy,
      jump=ent:isState("jump"),
      idle=ent:isState("idle"),
      fly =ent.RigidBody:isFlying()
    })
    if self.log:size() > self.sz then self.log:pop() end
  --   self.dt = 0
  -- end

end

------------------------------------------------------
-- Entity events
------------------------------------------------------



