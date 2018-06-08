
MagBehavior = {}
MagBehavior.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------
function MagBehavior:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function MagBehavior:onConnect()
  -- self.state = {}
  -- self.state["idle"] = true
  self.dt = 0
  self.dtAtk = 0
end

function MagBehavior:win()
  self.entity:toIdle()
end
function MagBehavior:die()
  self:toIdle()
end

function MagBehavior:onUpdate(dt)
  if not self.entity:isEnabled() then return end
  self.dt = self.dt + dt

  local ent = self.entity

  if self.dt > 0.1 then
    self.dt = 0
  end
end


------------------------------------------------------
-- Entity events
------------------------------------------------------
function MagBehavior.e:applyAction(act)
  -- if act.class == "spike" then
    if act.effect=="die" then
        self:die()
      return
    end
  -- end

  if act.atk  then
    self.UnitStatus.hp = self.UnitStatus.hp - act.atk
  end

  if act.effect == "slow" then
    self.UnitStatus.spd = self.UnitStatus.spd / 3
    print("slow spd",self.UnitStatus.spd)
  else
    self.UnitStatus.spd = self.UnitStatus.spd_max
    print("normal spd",self.UnitStatus.spd)
  end
end

function MagBehavior.e:toFight(ent)

end

function MagBehavior.e:jump(pressure)
  if self:isState("jump") then return end
  self:stateOn("jump")
  self.Sprite:useAnimation("jump")
  self.Sprite:looping()
  self.Liftup:disable()

  Audio:playSound("09 - Jump")
  self:leaveLadder()
  self.boostJump = 0

  local vx,vy = self.RigidBody:getVelocity()
  self.RigidBody:setVelocity(vx,0)
  self:push(0,-env.fy_useless_jump)
end