
BiggerFaster = {}
BiggerFaster.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------
function BiggerFaster:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function BiggerFaster:onConnect()
  self.dt = 0

  local ent = self.entity
  ent.Sprite.prop:setScl(2,2)
  ent.Sprite.propIX:setScl(2,2)

  self.sx, self.sy = ent.Sprite.prop:getLoc()
  ent.Sprite.prop:setLoc(self.sx, self.sy-10)
  ent.Sprite.propIX:setLoc(self.sx, self.sy-10)

  if ent.class == "Fungi" then
    self.spd = ent.FungiMove:speed()
    ent.FungiMove:speed(self.spd*2.5)
  end
end

function BiggerFaster:onDisconnect()
  self.dt = 0

  local ent = self.entity
  ent.Sprite.prop:setScl(1,1)
  ent.Sprite.propIX:setScl(1,1)
  ent.Sprite.prop:setLoc(self.sx, self.sy)
  ent.Sprite.propIX:setLoc(self.sx, self.sy)

  ent.FungiMove:speed(self.spd)
end

function BiggerFaster:onUpdate(dt)
  self.dt = self.dt + dt

  if self.dt > 0.2 then
    self.dt = 0
  end

end



------------------------------------------------------
-- Entity events
------------------------------------------------------



