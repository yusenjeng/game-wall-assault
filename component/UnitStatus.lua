
UnitStatus = {}
UnitStatus.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------
function UnitStatus:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function UnitStatus:onConnect()
  self.aspd = 1.20
  self.spd = 100
  self.spd_max = 100
  self.hp = 100
  self.state = {}
  self.state["idle"] = true
  self.enabled = true
  self.nearbyTarget = {}
end

function UnitStatus:onUpdate(dt)
end

------------------------------------------------------
-- Entity events
------------------------------------------------------
function UnitStatus.e:setNearbyTarget(name, flag)
  if flag == true then
    self.UnitStatus.nearbyTarget[name] = flag
  else
    self.UnitStatus.nearbyTarget[name] = nil
  end
end

function UnitStatus.e:getNearbyTarget(name, flag)
    return self.UnitStatus.nearbyTarget
end

function UnitStatus.e:getState()
  return self.UnitStatus.state
end
function UnitStatus.e:setState(st)
  for k,v in pairs(st) do
    self.UnitStatus.state[k] = v
  end
end
function UnitStatus.e:isState(s)
  return self.UnitStatus.state[s]
end
function UnitStatus.e:stateOn(s)
  self.UnitStatus.state[s] = true
  -- trace(s.." on")
end
function UnitStatus.e:stateOff(s)
  self.UnitStatus.state[s] = false
  -- trace(s.." off")
end

function UnitStatus.e:isEnabled()
  return self.UnitStatus.enabled
end

function UnitStatus.e:enable(fromHero)
  self.UnitStatus.enabled = true
  if self.UnitStatus.state["idle"] then
    self.Sprite:useAnimation("idle")
    self.Sprite:looping()
  end
  -- self.Sprite:flip(fromHero.Sprite.ix, fromHero.Sprite.iy)
  self.Sprite:show()
end
function UnitStatus.e:disable(s)
  self.UnitStatus.enabled = false
  self:setState({})
  self.Sprite:hide()
end

function UnitStatus.e:get(key)
  if key and type(self.UnitStatus[key]) == "number" then
    return self.UnitStatus[key]
  end
end

function UnitStatus.e:set(key, val)
  if key and type(self.UnitStatus[key]) == "number" then
    self.UnitStatus[key] = val
  end
end

