
CommonBehavior = {}
CommonBehavior.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------
function CommonBehavior:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function CommonBehavior:onConnect()
  self.dt = 0
  self.dtFoot = 0
  self.ox, self.oy = 0, 0
end

function CommonBehavior:onDestroy()
end

function CommonBehavior:onUpdate(dt)
  if not self.entity:isEnabled() then return end

  self.dt = self.dt + dt
  self.dtFoot = self.dtFoot + dt
  local ent = self.entity

  if self.dtFoot > 0.3 then
    local vx,vy = ent.RigidBody:getVelocity()
    if math.abs(vx) > 3 and not ent.RigidBody:isFlying() then
      Audio:playSound("04 - Walk")
    end

    self.dtFoot = 0
  end

  if self.dt > 0.1 then
    local vx,vy = ent.RigidBody:getVelocity()
    local x, y  = ent.RigidBody:getLoc()

    self.ox, self.oy = x, y

    if ent.dashX < 5 and ent:isState("right") then
      vx = vx + env.ax_hero

      if vx > env.vx_hero then vx = env.vx_hero end
      if vx < -env.vx_hero then vx = -env.vx_hero end

      ent.RigidBody:setVelocity(vx, vy)
    end


    if ent:isState("jump") then
      if vy > 1 then            -- falls quickly
        vy = vy + env.force_fall
        ent.RigidBody:setVelocity(vx, vy)
      end
    end

    if ent.dashT and ent.dashT > 0 then
      ent.dashT = ent.dashT - self.dt
    end

    if math.abs(ent.dashX) > 30 then
      ent.RigidBody:setVelocity(0,0)
      ent:push(vx+ent.dashX, vy-10)
      ent.dashX = ent.dashX * env.decay_dash
    elseif ent.dashX ~= 0 then
      ent.dashX = 0
      ent:toIdle()
      trace("to idle in dashX")
    end

    if (math.abs(ent.dashX) < 30) and (not ent:isState("fight")) and (not ent:isState("right")) and (not ent:isState("left")) then
      if math.abs(vx) < 20 and vx ~= 0 then
        vx = 0
        ent:toIdle()
        -- trace("to idle in common behavior")
      else
        vx = vx/3
      end
      ent.RigidBody:setVelocity(vx, vy)
    end

    if ent:isState("touchObstacle") and ent:isState("skill") then
      if ent.name=="war" then
        ent:toFight()
      end
    end

    self.dt = 0
  end

end

------------------------------------------------------
-- Entity events
------------------------------------------------------

function CommonBehavior.e:land()
  if self:isRIP() then return end

  if self:isState("jump") then
    self.Liftup:disable()
    self:stateOff("jump")
  end
  self:stateOff("fight")
  local vx, vy = self.RigidBody:getVelocity()
  if math.abs(vx) > 10 then
    self.Sprite:useAnimation("run")
  else
    self.Sprite:useAnimation("idle")
  end
  self:leaveLadder()
  self.Sprite:looping()
end

function CommonBehavior.e:enableSkill()
  self:stateOn("skill")
end
function CommonBehavior.e:disableSkill()
  self:stateOff("skill")
end

function CommonBehavior.e:toRight(force)
  if self:isState("right") and not force then return end
  self:stateOn("right")
  self.Sprite:flip(false, false)
  if not self:isState("jump") and not self:isRIP() then
    self.Sprite:useAnimation("run")
    self.Sprite:looping()
  end
  self:leaveLadder()
  self:stateOff("idle")
end

function CommonBehavior.e:toLeft()

end

function CommonBehavior.e:cancelRight()
  self:stateOff("right")
end

function CommonBehavior.e:cancelLeft()
  self:stateOff("left")
end

function CommonBehavior.e:touchObstacle()
  self:stateOn("touchObstacle")
end

function CommonBehavior.e:leaveObstacle()
  self:stateOff("touchObstacle")
end


function CommonBehavior.e:toIdle()
  if self:isState("idle") then return end
  self:stateOn("idle")
  self:stateOff("fight")
  self.Sprite:useAnimation("idle")
  self.Sprite:looping()
end

function CommonBehavior.e:preventJumping()
  self:stateOn("jump")
end


