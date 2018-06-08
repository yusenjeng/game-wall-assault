
BardBehavior = {}
BardBehavior.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------

function BardBehavior:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function BardBehavior:onConnect()
  self.dt = 0
  self.entity.dashX = 0
  self.entity.dashT = 0
end

function BardBehavior:onUpdate(dt)
  if not self.entity:isEnabled() then return end
  self.dt = self.dt + dt

  local ent = self.entity
  local vx,vy = ent.RigidBody:getVelocity()

  if self.dt > 0.1 then

    self.dt = 0
  end

  if env.press[Keyboard.space] and ent:isState("jump") and self.boostJump < env.jump_booster_th then
    local vx,vy = ent.RigidBody:getVelocity()
    ent:push(0, -15)
    self.boostJump = self.boostJump + 1
  end

  if not ent:isState("jump") then
    self.boostJump = 0
  end

end


------------------------------------------------------
-- Entity events
------------------------------------------------------
function BardBehavior.e:applyAction(act)
  if act.effect=="die" then
    self:die()
    return
  end

  if act.effect == "slow" then
    self.UnitStatus.spd = self.UnitStatus.spd / 3
    print("slow spd",self.UnitStatus.spd)
  else
    self.UnitStatus.spd = self.UnitStatus.spd_max
    print("normal spd",self.UnitStatus.spd)
  end
end

function BardBehavior.e:toFight(ent)
  if self:isRIP() then return end
  if not self:isState("skill") then return end
  if self.dashX ~= 0 then return end
  if self.dashT > 0 then return end

  if self:isState("fight") then return end
  self:stateOn("fight")

  local vx,vy = self.RigidBody:getVelocity()
  local ix,iy = self.Sprite:getFlipDir()

  if math.abs(vx) > 1 then
    if not ix then
      self.dashX = env.force_dash
    else
      self.dashX = -env.force_dash
    end
    Audio:playSound("03 - Dash")
  end


  self.dashT = env.interval_dash

  self:stateOff("idle")
end

function BardBehavior.e:jump(charge)
  if self:isState("jump") then return end
  self:stateOn("jump")
  self.Sprite:useAnimation("jump")
  self.Sprite:looping()
  self.Liftup:disable()

  Audio:playSound("09 - Jump")
  self:leaveLadder()

  local vx,vy = self.RigidBody:getVelocity()
  self.RigidBody:setVelocity(vx,0)

  self:push(0,-env.fy_superjump)
 end
