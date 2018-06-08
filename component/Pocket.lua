
Pocket = {}
Pocket.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------
function Pocket:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function Pocket:onConnect()
  self.dt = 0
  self.items = {}
end

function Pocket:onDestroy()
  self.items = nil
end

function Pocket:add(key)
  self.items[key] = true
  Level:disableKey(key)
end

function Pocket:has(code)
  for k,v in pairs(self.items) do
    local ent = System:getEntity(k)
    if ent.code == code then
      return true
    end
  end
  return false
end

function Pocket:clear(key)
  if not key then
    for k,v in pairs(self.items) do
      Level:enableKey(k)
    end
    self.items = {}
  else
    Level:enableKey(key)
    self.items[key] = nil
  end
end

function Pocket:onUpdate(dt)
  self.dt = self.dt + dt

  if self.dt > 0.02 then
    local x,y = self.entity.RigidBody:getLoc()
    local vx,vy = self.entity.RigidBody:getVelocity()
    for k,v in pairs(self.items) do
      local ent = System:getEntity(k)
      if vx > 1 then
        x = x + 20
        ent.Sprite:flip(false)
      elseif vx < -1 then
        x = x - 20
        ent.Sprite:flip(true)
      end
      ent.RigidBody:setLoc(x,y)
    end
    self.dt = 0
  end

end



------------------------------------------------------
-- Entity events
------------------------------------------------------



