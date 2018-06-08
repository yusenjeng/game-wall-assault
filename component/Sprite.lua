
Sprite = {}
Sprite.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------
function Sprite:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function Sprite:onDestroy()
  if self.lay then
    self.lay:removeProp(self.prop)
    self.lay:removeProp(self.propIX)
  end
end

function Sprite:onConnect()
  self:init()
end

function Sprite:onUpdate(dt)
  if self.seq_idx < 1 then return end

  self.dt = self.dt + dt


  if self.dt > self.tm_interval then
    self.seq_idx = self.seq_idx + 1
    -- print(self.dt, self.tm_interval, self.seq_name)

    if self.seq_idx > #self.seq then
      if self.isLooping then
        self.seq_idx = 1
      else
        self:stop()
      end
    end

    self.dt = 0
    self:showFrame()
  end
end

function Sprite:play(noInterrupt, cb)
  if self.noInterrupt then return end
  self:showFrame(self.seq[1])
  self.isLooping = false
  self.dt = 0
  self.seq_idx = 1

  self.noInterrupt = noInterrupt
  self.cb[self.seq_name] = cb
end

function Sprite:looping()
  if self.noInterrupt then return end
  if self.isLooping == true then return end
  self:showFrame(self.seq[1])
  self.isLooping = true
  self.dt = 0
  self.seq_idx = 1
  -- trace("looping")
end

function Sprite:stop()
  self.noInterrupt = false
  self.seq_idx = -1
  self.isLooping = false


  if self.cb[self.seq_name] then
    self.cb[self.seq_name]()
  end

end

function Sprite:showFrame(idx)
  idx = idx or self.seq[self.seq_idx]
  self.prop:setIndex(idx)
  self.propIX:setIndex(idx)
end

function Sprite:fadeOut(t)
   t = t or 1
  self.prop:seekColor ( 1,1,1, 0, 1.2*t, MOAIEaseType.EASE_IN )
  self.prop:seekScl ( 2.5,2.5, 0.5*t, MOAIEaseType.EASE_OUT )
end


function Sprite:fadeOutLarge(t)
  t = t or 1
  self.prop:seekScl ( 2,2, 0.2*t, MOAIEaseType.EASE_OUT )
  delay(0.2, function()
    self.prop:seekColor ( 1,1,1, 0, 2*t, MOAIEaseType.EASE_IN )
  end)
  delay(1, function()
    self.prop:seekScl ( 0.1, 0.1, 0.1*t, MOAIEaseType.EASE_OUT )
  end)
end

function Sprite:fadeOutDark(t)
   t = t or 1
  self.prop:seekColor ( 0,0,0, 1, 1.2*t, MOAIEaseType.EASE_IN )
end
function Sprite:beat(f,t)
  f = f or 5
  t = t or 1
  t1 = 0.1
  t2 = 0.3
  self.prop:seekScl ( f,f, t1, MOAIEaseType.EASE_IN )
  delay(t1, function()
    self.prop:seekScl ( t,t, t2, MOAIEaseType.EASE_OUT )
  end)
end

function Sprite:init()
  self.isLooping = false
  self.dt = 0
  self.seq = {}
  self.seq_all = {}
  self.seq_idx = 1
  self.tm_all = {}
  self.tm_interval = 200
  self.cb = {}
end

function Sprite:flip(ix, iy)
  self.lay:removeProp(self.prop)
  self.lay:removeProp(self.propIX)
  if ix then
    self.lay:insertProp(self.propIX)
  else
    self.lay:insertProp(self.prop)
  end
  self.ix = ix
  self.iy = iy
end

function Sprite:getFlipDir()
  return self.ix, self.iy
end

function Sprite:loadSprite(layWorld, fn, w,h, dimX,dimY)
  local prop = TextureManager:loadSprite(fn,w,h,dimX,dimY)
  prop:setAttrLink(MOAIProp.INHERIT_TRANSFORM, self.entity.body, MOAIProp.TRANSFORM_TRAIT)
  layWorld:insertProp(prop)
  self.prop = prop

  local propIX = TextureManager:loadSprite(fn,-w,h,dimX,dimY)
  propIX:setAttrLink(MOAIProp.INHERIT_TRANSFORM, self.entity.body, MOAIProp.TRANSFORM_TRAIT)
  layWorld:insertProp(propIX)
  self.propIX = propIX

  self.lay = layWorld

  self:init()
  self:flip(false)
end

function Sprite:show()
  -- self.lay:insertProp(self.prop)
  -- self.lay:insertProp(self.propIX)
  self:flip(self.ix)

end

function Sprite:hide()
  self.lay:removeProp(self.prop)
  self.lay:removeProp(self.propIX)
end

function Sprite:setLoc(x,y)
  self.prop:setLoc(x,y)
  self.propIX:setLoc(x,y)
end

function Sprite:setAnimationSequence(name, tm_interval, sequence)
  self.seq_all[name] = sequence
  self.tm_all[name] = tm_interval
end

function Sprite:getAnimation()
  return self.seq_name
end

function Sprite:turnAround()
  self:flip(not self.ix)
end

function Sprite:useAnimation(name)
  if self.noInterrupt then return end

  if self.seq_name ~= name then
    self.tm_interval = self.tm_all[name]
    self.seq_name = name
    self.seq      = self.seq_all[name]
  end
end

function Sprite:rotate(degree, tm)
  self.prop:moveRot (degree, tm)
  self.propIX:moveRot (degree, tm)
end

------------------------------------------------------
-- Entity events
------------------------------------------------------



