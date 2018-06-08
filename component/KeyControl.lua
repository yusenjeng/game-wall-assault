
KeyControl = {}
KeyControl.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------
function KeyControl:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function KeyControl:onConnect()
  self.enabled = false
  self.charge = MOAISim.getDeviceTime()
  self.isCharging = false
end

function KeyControl:onKey(key, down)
  -- if not self.entity:isEnabled() then return end
  if not self.enabled then return end

  if Level.noKey then return end

  self:onKeyGame(key, down)
end

function KeyControl:enable()
  self.enabled = true
end
function KeyControl:disable()
  self.enabled = false
end

function KeyControl:onKeyGame(key, down)
  local ent = self.entity

  if down then
    if key==Keyboard.space then
      -- self.charge = MOAISim.getDeviceTime()
      -- self.isCharging = true
      ent:jump()
    elseif key==Keyboard.enter then
      -- ent:toFight()
    elseif key==Keyboard.w then
    elseif key==Keyboard.s then
    elseif key==Keyboard.a then
    elseif key==Keyboard.d then
    elseif key==Keyboard.e then
      -- ent:say("Oops! God bless you and God Press any key to restart level.")
    end
  end

  if not down then
    if key==Keyboard.space and self.isCharging then
      -- local dp = MOAISim.getDeviceTime() - self.charge
      -- ent:jump(dp)
      -- self.charge = MOAISim.getDeviceTime()
      -- self.isCharging = false
      -- trace(dp, "released")
    elseif key==Keyboard.w then
    elseif key==Keyboard.s then
    elseif key==Keyboard.a then
    elseif key==Keyboard.d then
    end
  end
end

function KeyControl:onUpdate(dt)
  local ent = self.entity
  if not ent:isEnabled() then return end
  if ent:isRIP() then return end

  -- if env.press[Keyboard.space] and self.isCharging then
  --   local dp = MOAISim.getDeviceTime() - self.charge
  --   if dp > env.jump_charge_tm then
  --     ent:jump(dp)
  --     self.isCharging = false
  --     trace(dp, "th")
  --   end
  -- end

  local vx,vy = ent.RigidBody:getVelocity()
  -- if env.press[Keyboard.d] and not ent:isState("jump") and ent:isState("right") and ent.Sprite:getAnimation() ~= "right" then
  --   ent.Sprite:flip(false)
  --   ent.Sprite:useAnimation("run")
  -- end
  -- if env.press[Keyboard.a] and not ent:isState("jump") and ent:isState("left") and ent.Sprite:getAnimation() ~= "left" then
  --   ent.Sprite:flip(true)
  --   ent.Sprite:useAnimation("run")
  -- end
  -- if (not env.press[Keyboard.d] and not env.press[Keyboard.a]) and ent:isState("idle") and ent.Sprite:getAnimation() ~= "idle" then
  --   ent.Sprite:useAnimation("idle")
  -- end

end

------------------------------------------------------
-- Entity events
------------------------------------------------------

