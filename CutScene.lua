CutScene = {}

function CutScene:onKey(key, down)
  if not self.enabled then return end
  if down then
    if key==Keyboard.enter and self.canEnter then
      Audio:stopMusic()
      self:hide()
      self.done({next=true})
    end
  end
end

function CutScene:onUpdate(dt)
  if not self.dt then return end
  if not self.enabled then return end

  self.dt = self.dt + 1
  if self.dt > 0.1 then

    self.dt = 0
  end
end

function CutScene:show(ref, done)
  self:hide()
  -- Audio:playMusic("DST-GameOn")
  Audio:stopMusic()
  self.enabled = true
  env.camera:setLoc(0,0)
  self.canEnter = false

  self.dx = 2
  self.done = done

  self:addTerrain()
  self:addHero()

  delay(1, function()
    if ref.war then
      Audio:playSound("06 - Change")
      self.h1.Sprite:beat(5,2)
    else
      Audio:playSound("19 - Error")
      self.h1.Sprite:useAnimation("die")
      self.h1.Sprite:looping()
      self.h1.Sprite:beat(5,2)
    end
  end)
  delay(1.8, function()
    if ref.bard then
      Audio:playSound("06 - Change")
      self.h2.Sprite:beat(5,2)
    else
      Audio:playSound("19 - Error")
      self.h2.Sprite:useAnimation("die")
      self.h2.Sprite:looping()
      self.h2.Sprite:beat(5,2)
    end
  end)
  delay(2.6, function()
    if ref.mag then
      Audio:playSound("06 - Change")
      self.h3.Sprite:beat(5,2)
    else
      Audio:playSound("19 - Error")
      self.h3.Sprite:useAnimation("die")
      self.h3.Sprite:looping()
      self.h3.Sprite:beat(5,2)
    end
  end)

  ref.dt = ref.dt or 10
  ref.gems = ref.gems or 22
  ref.level = ref.level or 3

  self.lbStage:say("Stage "..ref.stage)
  self.lbTime:say("Time: "..tostring(math.floor(ref.dt*100)/100))
  self.lbCoins:say("Coins: -")
  self.lbScroll:say("Scroll: -")
  self.lbBarricade:say("Barricades obliterated: -")
  self.lbBox:say("Boxes wrecked: -")
  self.lbEnemies:say("Enemies wiped: -")

  -- self.lbScroll:say("Scroll: "..tostring(ref.scroll))
  -- Barricades obliterated

  delay(3.5, function()
    for i=1, ref.gems do
      delay(i*0.08, function()
        Audio:playSound("18 - Click")
        self.lbCoins:say("Coins: "..tostring(i))
      end)
    end

    delay(0.3+0.08*ref.gems, function()

      for i=1, ref.scroll do
        delay(i*0.08, function()
          Audio:playSound("18 - Click")
          self.lbScroll:say("Scrolls: "..tostring(i))
        end)
      end

      delay(0.3+0.08*ref.scroll, function()
        for i=1, ref.barricades do
          delay(i*0.08, function()
            Audio:playSound("17 - Break")
            self.lbBarricade:say("Barricades obliterated: "..tostring(i))
          end)
        end

        delay(0.3+0.08*ref.barricades, function()

          for i=1, ref.nBox do
            delay(i*0.08, function()
              Audio:playSound("17 - Break")
              self.lbBox:say("Boxes wrecked: "..tostring(i))
            end)
          end

          delay(0.3+0.08*ref.nBox, function()

            for i=1, ref.nEnemy do
              delay(i*0.08, function()
                Audio:playSound("07 - Death-enemy")
                self.lbEnemies:say("Enemies wiped: "..tostring(i))
              end)
            end

            delay(0.3+0.08*ref.nEnemy, function()
              self.canEnter = true
              self.lbKey:say("Press Enter to continue...")
              self.lbKey:show(350, 580)
            end)
          end)
        end)
      end)
    end)
  end)

  self.lbStage:show(15, 60)
  self.lbTime:show(50, 170)
  self.lbCoins:show(50, 210)
  self.lbScroll:show(50, 250)
  self.lbBarricade:show(50, 290)
  self.lbBox:show(50, 330)
  self.lbEnemies:show(50, 370)
  self.dt = 0

end

function CutScene:hide()
  self:delTerrain()
  self:delHero()

  self.lbTime:hide()
  self.lbCoins:hide()
  self.lbStage:hide()
  self.lbKey:hide()
  self.lbScroll:hide()
  self.lbBarricade:hide()
  self.lbBox:hide()
  self.lbEnemies:hide()
  self.dt = nil
  self.enabled = false
end

function CutScene:addPlatform(name, ref)
  local x,y = ref.x, ref.y
  local w,h = ref.width, ref.height
  if name == "Ladder" then
    h = h+10
    y = y - 10
  end
  local left   = x
  local right  = x + w
  local tCutScene    = y
  local bottom = y + h

  local fix = self.ground:addRect(left, bottom, right, tCutScene)
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

function CutScene:addTerrain()
  self.ground = env.physics:addBody(MOAIBox2DBody.STATIC)
  self.ground:setTransform(0,0)
  self.ground:setFixedRotation(true)

  self.fix = self:addPlatform("ground", {x=-960/2,y=self.pos.y,width=1000,height=10})
end
function CutScene:addHero()
  self.h1 = Hero:newWar (self.pos.x+150, self.pos.y-50)
  self.h2 = Hero:newBard(self.pos.x    , self.pos.y-50)
  self.h3 = Hero:newMag (self.pos.x-150, self.pos.y-50)
  self.h1:cancelRight()
  self.h2:cancelRight()
  self.h3:cancelRight()
  self.h1.Sprite:stop()
  self.h2.Sprite:stop()
  self.h3.Sprite:stop()
end

function CutScene:delTerrain()
  if self.fix then
    self.fix:destroy()
    self.ground:destroy()
  end
end
function CutScene:delHero()
  if self.h1 then
    System:remove(self.h1)
    System:remove(self.h2)
    System:remove(self.h3)
  end
end


function CutScene:init()
  env.layWorld:setClearColor (0,0,0, 0.7)
  self.dt = 0

  self.pos = {x=0, y=200}

  local lbTime = IconLabel:new()
  lbTime:init(env.camera, 300, 100, 0, -275)
  lbTime:setColor(163,217,121)
  self.lbTime = lbTime
  self.lbTime:hide()

  local lbBox = IconLabel:new()
  lbBox:init(env.camera, 400, 100, 0, -275)
  lbBox:setColor(254,112,56)
  lbBox:say("Boxes wrecked: -")
  self.lbBox = lbBox
  self.lbBox:hide()

  local lbEnemies = IconLabel:new()
  lbEnemies:init(env.camera, 400, 100, 0, -275)
  lbEnemies:setColor(200,50,50)
  lbEnemies:say("Enemies wiped: -")
  self.lbEnemies = lbEnemies
  self.lbEnemies:hide()

  local lbScroll = IconLabel:new()
  lbScroll:init(env.camera, 300, 100, 0, -275)
  lbScroll:setColor(222,222,222)
  lbScroll:say("Scrolls: -")
  self.lbScroll = lbScroll
  self.lbScroll:hide()

  local lbCoins = IconLabel:new()
  lbCoins:init(env.camera, 300, 100, 0, -275)
  lbCoins:setColor(218,119,254)
  lbCoins:say("Coins: -")
  self.lbCoins = lbCoins
  self.lbCoins:hide()

  local lbBarricade = IconLabel:new()
  lbBarricade:init(env.camera, 500, 100, 0, -275)
  lbBarricade:setColor(222,222,121)
  lbBarricade:say("Barricades obliterated: -")
  self.lbBarricade = lbBarricade
  self.lbBarricade:hide()

  local lbStage = IconLabel:new()
  lbStage:init(env.camera, 300, 100, 0, -275, env.font2)
  lbStage:setColor(200,200,200)
  lbStage:say("Stage: ")
  self.lbStage = lbStage
  self.lbStage:hide()

  local lbKey = IconLabel:new()
  lbKey:init(env.camera, 500, 100, 0, -275, env.font1)
  lbKey:setColor(200,200,200)
  lbKey:say(" ")
  self.lbKey = lbKey
  self.lbKey:hide()


  -- self.img1:setBlendMode (MOAIPrCutScene2D.BLEND_ADD)
  self.dx = 2
  self.enabled = false


end
