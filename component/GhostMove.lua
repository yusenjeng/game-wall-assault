
GhostMove = {}
GhostMove.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------
function GhostMove:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function GhostMove:onConnect(opt)
  self.enabled = true
  self.dt = 0
  self.shiftX = 0
end
function GhostMove:onDisconnect(opt)
  self.cbDone = nil
end

function GhostMove:shift(x, done)
  self.shiftX = math.ceil(x)
  self.cbDone = done
end

function GhostMove:onUpdate(dt)
  if not self.enabled or self.shiftX == 0 then return end
  self.dt = self.dt + dt

  if self.dt > 0.02 then
    local dx = 0
    if self.shiftX > 0 then
      dx = 5
    else
      dx = -5
    end

    local x,y = self.entity.RigidBody:getLoc()
    self.entity.RigidBody:setLoc(x+dx,y)
    self.shiftX = self.shiftX - dx
    -- trace(dx, os.time())

    self.entity:push(0,10)

    if self.shiftX < 6 and self.shiftX > -6 then
      self.enabled = false
      if self.cbDone then
        self.cbDone()
      end
    end
    self.dt = 0
  end

end

------------------------------------------------------
-- Entity events
------------------------------------------------------



