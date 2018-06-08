ED = {}

function ED:onKey(key, down)
  if not self.enabled then return end
  if down then
    if key==Keyboard.enter then
      self.dx = 0
      self.h1:toRight()
      self.h2:toRight()
      self.h3:toRight()
      self.moon:seekColor ( 0,0,0, 0, 5, MOAIEaseType.EASE_IN )
      self.textbox:seekColor ( 0,0,0, 0, 5, MOAIEaseType.EASE_IN )
      self.title:seekColor ( 0,0,0, 0, 5, MOAIEaseType.EASE_IN )

      self.h1.Sprite:fadeOutDark(5)
      self.h2.Sprite:fadeOutDark(5)
      self.h3.Sprite:fadeOutDark(5)

      for i=1,32 do
        local b = self.boxes[i]
        b:seekColor ( 0,0,0, 0, 10, MOAIEaseType.EASE_IN )
      end

      self.enabled=false
      delay(2, function()
        -- Audio:stEDMusic("Never StED Running (8-Bit)")
        self:hide()
        self.enabled = false
        Level:init()
        Level:team({"war", "bard", "mag"})
        Level:load(1, true)
      end)

    end
  end
end

function ED:onUpdate(dt)
  if not self.dt then return end
  if not self.enabled then return end

  self.dt = self.dt + 1
  if self.dt > 0.1 then



    self.dt = 0
  end
end

function ED:show()
  self:hide()

  self.dx = 2

  -- self:addTerrain()
  -- self:addHero()

  -- for i=1,32 do
  --   env.layWorld:insertPrED(self.boxes[i])
  -- end

  env.layWorld:insertPrED(self.moon)
  env.layWorld:insertPrED(self.title)
  env.layWorld:insertPrED(self.textbox)
  self.dt = 0
end

function ED:hide()
  -- env.layWorld:removePrED(self.img1)
  -- self:delTerrain()
  -- self:delHero()

  -- for i=1,30 do
  --   env.layWorld:removePrED(self.boxes[i])
  -- end

  env.layWorld:removePrED(self.moon)
  env.layWorld:removePrED(self.title)
  env.layWorld:removePrED(self.textbox)
  self.dt = nil
end

function ED:addPlatform(name, ref)
  local x,y = ref.x, ref.y
  local w,h = ref.width, ref.height
  if name == "Ladder" then
    h = h+10
    y = y - 10
  end
  local left   = x
  local right  = x + w
  local tED    = y
  local bottom = y + h

  local fix = self.ground:addRect(left, bottom, right, tED)
  fix:setRestitution(0)
  fix:setFriction(0.3)
  fix.x = x
  fix.y = y
  fix:setSensor(false)
  fix:setFilter(env.physics.categories.scenary, env.physics.masks.scenary)
  fix.name = name
  fix.class = "Terrain"

  if name == "Ladder" or name == "LeaveLadder" then
    fix:setSensor(true)
    fix.width = w
    fix.height = h
  elseif name == "DeathZone" then
    fix:setSensor(true)
  end
  return fix
end

function ED:addTerrain()
  self.ground = env.physics:addBody(MOAIBox2DBody.STATIC)
  self.ground:setTransform(0,0)
  self.ground:setFixedRotation(true)

  self.fix = self:addPlatform("ground", {x=-960/2,y=200,width=1000,height=10})
end
function ED:addHero()
  self.h1 = Hero:newWar (self.pos.x+50, self.pos.y)
  self.h2 = Hero:newBard(self.pos.x   , self.pos.y)
  self.h3 = Hero:newMag (self.pos.x-50, self.pos.y)
  self.h1:cancelRight()
  self.h2:cancelRight()
  self.h3:cancelRight()
end

function ED:delTerrain()
  if self.fix then
    self.fix:destroy()
    self.ground:destroy()
  end
end
function ED:delHero()
  if self.h1 then
  System:remove(self.h1)
  System:remove(self.h2)
  System:remove(self.h3)
end
end


function ED:init()
  Audio:playMusic("Grey Sector v0_86")
  env.layWorld:setClearColor (0,0,0, 0.7)
  self.dt = 0

  self.pos = {x=-280, y=180}

  -- self.moon = TextureManager:loadTexture("Night.png")
  -- self.moon:setPriority(0)
  -- self.moon:setLoc(0,-320)

  self.title = TextureManager:loadTexture("title.png")
  self.title:setPriority(999)
  self.title:setLoc(-110,-200)

 --  self.boxes = {}
 --  for i=1,32 do
 --   local b = TextureManager:loadTexture("box.png", 32, 32)
 --   b:setLoc(-500 + i*32, self.pos.y+20)
 --   table.insert(self.boxes, b)
 -- end


  -- self.img1:setBlendMode (MOAIPrED2D.BLEND_ADD)
  self.dx = 2
  self.enabled = true

  self.textbox = MOAITextBox.new()
  self.textbox:setFont(env.font3)
  self.textbox:setRect(-400, -40, 400, 50)
  self.textbox:setAlignment(MOAITextBox.LEFT_JUSTIFY)
  self.textbox:setString("~ Press Enter to Start~")
  self.textbox:seekColor ( 1, 1, 0.3, 1, 3, MOAIEaseType.EASE_IN )
  delay(3, function()
    self.textbox:seekColor ( 1, 1, 0.3, 0, 3, MOAIEaseType.EASE_OUT )
  end)
  delay(6, function()
    self.textbox:seekColor ( 1, 1, 0.3, 1, 5, MOAIEaseType.EASE_IN )
  end)
  self.textbox:setLoc(400,190)

  self:show()

end
