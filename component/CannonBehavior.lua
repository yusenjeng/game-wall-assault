
CannonBehavior = {}
CannonBehavior.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------

function CannonBehavior:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function CannonBehavior:onConnect(opt)
  self.dt = 0
  self.enabled = false
  self.fire_interval = 1
  if opt then
    self.fire_interval = tonumber(opt.fire_interval) or 1
    self.fire_vx = tonumber(opt.fire_vx) or 100
    self.fire_vy = tonumber(opt.fire_vy) or 0
  end
end

function CannonBehavior:onUpdate(dt)
  self.dt = self.dt + dt

  if self.dt > self.fire_interval and self.enabled then
    local ent = self.entity
    local x ,y  = ent.RigidBody:getLoc()

    local vx,vy
    vx = self.fire_vx
    vy = self.fire_vy

    ent.Sprite:useAnimation("shoot")
    ent.Sprite:play(false, function()
      Launcher:addFireball(x-10,y+3, vx,vy)
    end)

    self.dt = 0
  end

end

------------------------------------------------------
-- Entity events
------------------------------------------------------

function CannonBehavior.e:startShooting()
  self.CannonBehavior.enabled = true
end

function CannonBehavior.e:stopShooting()
  self.CannonBehavior.enabled = false
  self.Sprite:useAnimation("idle")
  self.Sprite:looping()
end
