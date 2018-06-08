
RigidBody     = {}
RigidBody.e = {}

function RigidBody:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function RigidBody:onUpdate(dt)
end

-- function RigidBody:setPosition(x,y)
--   return self.entity.body:setTransform(x,y)
-- end
-- function RigidBody:getPosition()
--   return self.entity.body:getPosition()
-- end

function RigidBody:createPolygonFixture(verts)
  local fixture = self.entity.body:addPolygon(verts)
  fixture.component = self
  table.insert(self.entity.fixtures, fixture)
  return fixture
end

function RigidBody:createRectFixture(x,y,w,h)
  local fixture = self.entity.body:addRect(x,y,w,h)
  fixture.component = self
  table.insert(self.entity.fixtures, fixture)
  return fixture
end

function RigidBody:getVelocity()
  return self.entity.body:getLinearVelocity()
end

function RigidBody:setVelocity(x,y)
  if not x or not y then
    return
  end
  self.entity.body:setLinearVelocity(x,y)
end


function RigidBody:isFlying()
  local vx,vy = self:getVelocity()
  return (vy ~= 0)
end
-------------------------------------------------------------------------------
-- Create a fixture so we can be notified of collisions
-------------------------------------------------------------------------------
function RigidBody:useFixtureAsSensor(fixture, phaseMask, categoryMask)
  if not phaseMask then
    phaseMask = MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END
  end

  fixture:setSensor(true)
  fixture:setCollisionHandler(
    function(phase, fix_a, fix_b, arbiter)
      local function dispatchCollisionEvent(fixture)
        if fixture.component then
          fixture.component.entity:onCollision(phase, fix_a, fix_b, arbiter)
        end
      end

      -- Only inform components on this entity for now
      dispatchCollisionEvent(fix_a)
      --dispatchCollisionEvent(fix_b)
    end,
  phaseMask, categoryMask)
end

function RigidBody:onConnect(opt)
  local physics = self.entity.physics
  local entity = self.entity

  local bodyType = MOAIBox2DBody.DYNAMIC
  if opt then bodyType = opt.type end

  entity.body = physics:addBody(bodyType)

  entity.body:setFixedRotation(true)
  entity.body:setMassData(10)
  entity.body:setTransform(0,0)

  entity.fixtures = {}
  -- entity.obj:setParent(entity.body)
  -- entity.body:setAttrLink(MOAIProp.INHERIT_TRANSFORM, entity.obj, MOAIProp.TRANSFORM_TRAIT)
end

function RigidBody:onDestroy()
  for _, fixture in pairs(self.entity.fixtures) do
    fixture:destroy()
  end

  self.entity.body:destroy()
end


function RigidBody:setLoc(x,y)
  return self.entity.body:setTransform(x,y)
end
function RigidBody:getLoc()
  return self.entity.body:getPosition()
end

function RigidBody:setFixedRotation(flag)
  self.entity.body:setFixedRotation(flag)
end
function RigidBody:setSensor(flag)
  for k,v in pairs(self.entity.fixtures) do
    v:setSensor(flag)
  end
end

function RigidBody:setFilter(category, mask)
  for k,v in pairs(self.entity.fixtures) do
    v:setFilter(category,mask)
  end
end


function RigidBody:setFriction(flag)
  for k,v in pairs(self.entity.fixtures) do
    v:setFriction(flag)
  end
end

function RigidBody:setAwake(flag)
  self.entity.body:setAwake(flag)
end
function RigidBody:setActive(flag)
  self.entity.body:setActive(flag)
  self.entity.body:setAwake(flag)
end

