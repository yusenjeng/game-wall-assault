
Camp = {}
Camp.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------
function Camp:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function Camp:onConnect(opt)
  self.dt = 0
  self.dtTurn = 0
  self.range = opt.range
  self.x, self.y = self.entity.RigidBody:getLoc()
  trace(self.x, self.range)
end

function Camp:enable(y)
end

function Camp:disable()
end

function Camp:onUpdate(dt)
  self.dt = self.dt + dt
  self.dtTurn = self.dtTurn + dt

  if self.dt > 0.5 and self.dtTurn > 3 then
    local ent = self.entity
    local x,y = ent.RigidBody:getLoc()

    -- trace(x, self.x + self.range/2, self.x - self.range/2)
    if x > self.x + self.range/2 then
      ent.FungiMove:turnAround()
      ent.Sprite:turnAround()
    elseif x < self.x - self.range/2 then
      ent.FungiMove:turnAround()
      ent.Sprite:turnAround()
    end

    self.dtTurn = 0
    self.dt = 0
  end

end



------------------------------------------------------
-- Entity events
------------------------------------------------------



