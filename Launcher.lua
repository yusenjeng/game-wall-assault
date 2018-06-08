
Launcher = {}


function Launcher:fire()
  if #self.pendingFireball > 0 then
    for _,v in pairs(self.pendingFireball) do
      local fb = Fireball:new(v)
      local ca = Carrier:new(v)
      fb:attachTo(ca)
    end
    self.pendingFireball = {}
  end

  if #self.pendingShield > 0 then
    for _,v in pairs(self.pendingShield) do
      local fb = MageShield:new(v)
      local ca = Carrier:new(v)
      fb:attachTo(ca)
    end
    self.pendingShield = {}
  end

  if #self.pendingPunch > 0 then
    for _,v in pairs(self.pendingPunch) do
      local ent = Punch:new(v.x, v.y, v.right)
      ent.RigidBody:setVelocity(v.vx, v.vy)
    end
    self.pendingPunch = {}
  end

  if #self.pendingDogs > 0 then
    for _,v in pairs(self.pendingDogs) do
      local ent = StrayDog:new(v)
      Level:addNPC(ent)
      -- ent.RigidBody:setVelocity(v.vx, v.vy)
    end
    self.pendingDogs = {}
  end

end

function Launcher:addFireball(x,y,vx,vy, fire_interval)
  table.insert(self.pendingFireball, {x=x,y=y,vx=vx,vy=vy,life=10})
end

function Launcher:addMagicShield(x,y,vx)
  table.insert(self.pendingShield, {x=x,y=y,vx=vx,vy=0,life=10})
end

function Launcher:castPunch(x,y, right, vx,vy)
  table.insert(self.pendingPunch, {x=x,y=y,vx=vx,vy=0,right=right})
end

function Launcher:setStrayDog(x,y, right, vx, chance_jump)
  table.insert(self.pendingDogs, {x=x,y=y,vx=vx,vy=0,right=right,chance_jump=chance_jump})
end


function Launcher:init()
  self.pendingFireball = {}
  self.pendingShield   = {}
  self.pendingPunch    = {}
  self.pendingDogs     = {}
end