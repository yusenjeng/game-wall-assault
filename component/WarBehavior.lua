
WarBehavior = {}
WarBehavior.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------

function WarBehavior:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function WarBehavior:onConnect()
  self.dt = 0
  self.dtAtk = 0
  self.boostJump = 0
end

function WarBehavior:onUpdate(dt)
  if not self.entity:isEnabled() then return end
  self.dt = self.dt + dt

  local ent = self.entity

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

  -- if self.dtAtk > ent:get("aspd") then
  --   if self.state == "fight" and self.atkTarget then
  --     self.atkTarget:applyAction(self, {atk=10})
  --     self.entity.Sprite:play(true)
  --   end
  --   self.dtAtk = 0
  -- end
end


------------------------------------------------------
-- Entity events
------------------------------------------------------
function WarBehavior.e:applyAction(act)
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

function WarBehavior.e:toFight(ent)
  if not self:isState("skill") then return end
  if self:isRIP() then return end

  if self:isState("fight") then return end
  self:stateOn("fight")

  Audio:playSound("01 - Hit")

  local x ,y  = self.RigidBody:getLoc()
  local ix,iy = self.Sprite:getFlipDir()
  local vx,vy = self.RigidBody:getVelocity()
  Launcher:castPunch(x,y, not ix, vx, vy)

  self.Sprite:useAnimation("melee_attack")
  self.Sprite:play(true, function()
    self:toRight(true)
    -- self:toIdle()
  end)
  self:stateOff("idle")
end

function WarBehavior.e:jump(charge)
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
  self:push(0,-env.fy_jump)
end

