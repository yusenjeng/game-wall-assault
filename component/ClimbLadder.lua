
ClimbLadder = {}
ClimbLadder.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------
function ClimbLadder:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function ClimbLadder:onConnect()
  self.dt = 0
  self.accH = 0
  self.tarH = 0
  self.fix = nil
end
function ClimbLadder:onDestroy()
  self.dt = nil
  self.accH = nil
  self.tarH = nil
  self.fix = nil
end

function ClimbLadder:onUpdate(dt)
  -- print(self.dtBoost)
  self.dt = self.dt + dt
  local ent = self.entity

  if self.dt > 0.02 and ent:isState("nearLadder") then

    if not ent:isState("enterLadder") and (env.press[Keyboard.w] or env.press[Keyboard.s]) then
      ent:enterLadder()
    end

      if ent:isState("enterLadder") then
      local x,y = ent.RigidBody:getLoc()
      local dx,dy = 0, 0

      -- up and down
      if env.press[Keyboard.w]  and math.ceil(y) > self.tarY1-10 then
        dy = -300*dt
      elseif env.press[Keyboard.s] and math.ceil(y) < self.tarY2-20 then
        dy = 300*dt
      end

      -- center alignment
      if x > self.tarX then
        dx = (self.tarX - x)/1.5
      elseif x < self.tarX then
        dx = (self.tarX - x)/1.5
      end

      y = y + dy
      x = math.floor(x + dx)
      ent.RigidBody:setLoc(x, y)

      if y < self.tarY1-10 or y > self.tarY2-20 then
        ent:leaveLadder()
        ent:nearLadder(false)
        ent:toIdle()
      end

    end
    self.dt = 0
  end

end

------------------------------------------------------
-- Entity events
------------------------------------------------------

function ClimbLadder.e:nearLadder(flag, fix)
  if flag then
    self:stateOn("nearLadder")
    self.ClimbLadder.fix = fix
  else
    self:stateOff("nearLadder")
    self.ClimbLadder.fix = nil
  end
end

function ClimbLadder.e:enterLadder()
  if not self.ClimbLadder.fix then return end
  self:stateOn("enterLadder")
  self.RigidBody:setActive(false)
  self:stateOff("jump")
  self.ClimbLadder.tarX  = self.ClimbLadder.fix.x+15
  self.ClimbLadder.tarY1 = self.ClimbLadder.fix.y
  self.ClimbLadder.tarY2 = self.ClimbLadder.fix.y+self.ClimbLadder.fix.height
end
function ClimbLadder.e:leaveLadder()
  if not self:isState("enterLadder") then return end
  self:stateOff("enterLadder")
  self.RigidBody:setActive(true)
end
