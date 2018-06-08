
local Epic = {}

function Epic:onCollision(phase, fixa, fixb, arbiter)
  if not self.enabled then return end

  if fixb.class == "hero" then
    local ent = fixb.entity
    if phase == MOAIBox2DArbiter.BEGIN and not ent:isRIP() then
      if fixa.class == "RevivePotion" then
        self.enabled = false

        Audio:playSound("20 - Potion")
        Audio:playSound("11 - Jump-s")
        Level:reviveHero()
        self.Sprite:fadeOut()
        delay(1.3, function()
          self:die()
        end)
      elseif Level:isLeader(ent) then
        Audio:playSound("16 - Coin")

        if self.name == "Scroll" then
          Level:incScroll()
          self.Sprite:fadeOutLarge()
        else
          Level:incGems()
          self.Sprite:fadeOut()
        end

        delay(1.3, function()
          self:die()
        end)

      end
    end
  end
end

function Epic:die()
  System:remove(self)
end

function Epic:new(ref)
  local u = {}
  u.physics = env.physics
  u.enabled = true
  u.name = ref.type

  setmetatable(u, self)
  self.__index = self
  System:install(u, RigidBody, {type=MOAIBox2DBody.STATIC})

  local fixture

  fixture = u.RigidBody:createRectFixture(-16, -16, 16, 16)

  fixture:setRestitution(0)
  fixture:setFriction(0)
  fixture.name = "Epic"
  fixture.class = ref.type
  fixture.entity = u
  local category = env.physics.categories.critter
  local mask = env.physics.masks.scenary
  fixture:setFilter(category, mask)
  u.RigidBody:useFixtureAsSensor(fixture)
  -- fixture:setSensor(true)
  u.RigidBody:setActive(true)
  u.RigidBody:setLoc(ref.x, ref.y)

  System:install(u, Sprite)
  if ref.type == "RevivePotion" then
    u.Sprite:loadSprite(env.layWorld, "taichi.png", 32, 32, 4,1)
    u.Sprite:setAnimationSequence("idle"        , 0.05, {1,2,3,4})
    u.Sprite:useAnimation("idle")
    u.Sprite:looping()
  elseif ref.type == "Scroll" then
    u.Sprite:loadSprite(env.layWorld, "scroll.png", 32, 32, 4,1)
    u.Sprite:setAnimationSequence("idle"        , 0.05, {1,2,3,4})
    u.Sprite:useAnimation("idle")
    u.Sprite:looping()
  else
    u.Sprite:loadSprite(env.layWorld, "coin.png", 32,32, 3,1)
    u.Sprite:setAnimationSequence("idle"        , 0.1, {1,2,3})
    u.Sprite:useAnimation("idle")
    u.Sprite:looping()
  end

  return u
end

return Epic