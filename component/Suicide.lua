
Suicide = {}
Suicide.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------
function Suicide:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function Suicide:onConnect(opt)
  self.dt = 0
  self.life = opt.life or 10
  self.enabled = opt.enabled
  if self.enabled == nil then
    self.enabled = true
  end
end

function Suicide:setLife(val)
  self.life = val
end

function Suicide:onDestroy()
  self.enabled = false
end

function Suicide:start()
  self.enabled = true
end

function Suicide:onUpdate(dt)
  if not self.enabled then return end
  self.dt = self.dt + dt

  if self.dt > self.life then
    self.entity:die()
    self.enabled = false
  end

end



------------------------------------------------------
-- Entity events
------------------------------------------------------



