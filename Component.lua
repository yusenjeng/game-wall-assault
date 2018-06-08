
System = {
  entities = {},
  pendingRemoval = {}
}

function System:getName(component)
  for k,v in pairs(_G) do
    if v == component then
      return k
    end
  end
end

function System:onKey(key, down)
  for k, e in pairs(self.entities) do
    for k2, c in pairs(e.components) do
      if type(c["onKey"]) == "function" then
        c:onKey(key, down)
      end
    end
  end
end

function System:onUpdate(dt)
  if not dt then return end

  -- update entities
  for k, e in pairs(self.entities) do
    for k2, c in pairs(e.components) do
      c:onUpdate(dt)
    end
  end

  self:recycle()
end

function System:recycle()
  -- remove entities
  for k,v in pairs(self.pendingRemoval) do
    self:removeNow(k)
  end
  self.pendingRemoval = {}
end

function System:remove(entity)
  self.pendingRemoval[entity.key] = true
end

function System:removeNow(key)
  local entity = self.entities[key]
  if not entity then return end

  for k,v in pairs(entity.components) do
    if v.__index["onDestroy"] then
      v:onDestroy()
    end

    entity.components[k] = nil
  end
  self.entities[key] = nil
end

function System:getEntity(key)
  return self.entities[key]
end

function System:uninstall(entity, component, opt)
  local oldMt = getmetatable(entity)

  local name = self:getName(component)

  local _comp = entity[name]
  _comp:onDisconnect(opt)
  entity.components[_comp.key] = nil
  entity[name] = nil

  setmetatable(entity, oldMt)
end

function System:install(entity, component, opt)
  local oldMt = getmetatable(entity)

  local name = self:getName(component)
  component = component:new()
  component.entity = entity

  if not entity.key then entity.key = randstr(5,5) end
  if not component.key then component.key = randstr(5,5) end
  if not entity.components then entity.components = {} end

  entity[name] = component
  entity.components[component.key] = component

  self.entities[entity.key] = entity

  for k,v in pairs(component.e) do
    if not entity[k] and not entity.__index[k] then
      entity[k] = v
    end
  end

  setmetatable(entity, oldMt)
  component:onConnect(opt)
  -- trace( "Component "..name.." installed" )
end

-----------------------------------------------------------


