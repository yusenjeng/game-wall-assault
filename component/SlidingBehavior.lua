
SlidingBehavior = {}
SlidingBehavior.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------
function SlidingBehavior:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function SlidingBehavior:onConnect(opt)
  self.dt    = 0
  self.speed = opt.speed
  self.tars  = {}
end

function SlidingBehavior:enter(tar)
  self.tars[tar.key] = tar
  tar:set("spd_alt", self.speed)
end

function SlidingBehavior:leave(tar)
  self.tars[tar.key] = nil
  tar:set("spd_alt", 0)
end

function SlidingBehavior:onUpdate(dt)
  self.dt = self.dt + dt

  if self.dt > 0.1 then
    -- for _, v in pairs(self.tars) do
      -- local vx,vy = v.RigidBody:getVelocity()
      -- if vx > self.speed*10 then
        -- v:push(-200, 0)
        -- v:push(self.speed, 0)
      -- end
      -- v.RigidBody:setVelocity(self.speed, 0)
    -- end
    self.dt = 0
  end

end



------------------------------------------------------
-- Entity events
------------------------------------------------------



