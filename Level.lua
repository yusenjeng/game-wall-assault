Level = {}

function Level:onKey(key, down)
  if not self.dt then return end
  if self.noKey then return end
  if not self.enabled then return end

  if self.flag_waitForReset then
    env.physics:start()
    for _,v in pairs(self.heroes) do
      v.MsgBox:hide()
    end
    self:reset()
    self.flag_waitForReset = false
    self.dt = 0
    self.dtCmd = 0
    return
  end

  if down then
    if key==Keyboard.enter then
      -- checkMem(false)
    elseif key==Keyboard["1"] then
      Level:assignHero(1)
    elseif key==Keyboard["2"] then
      Level:assignHero(2)
    elseif key==Keyboard["3"] then
      Level:assignHero(3)
    elseif key==Keyboard.bracketsR then
      self:nextLevel(true)
    elseif key==Keyboard.bracketsL then
      self:prevLevel(true)
    end
  end
end

function Level:waitForReset()
  if self.flag_waitForReset then return end
  self.flag_waitForReset = true

  local x,y = env.camera:getLoc()
  self.prop_waitForReset = TextureManager:loadTexture("wait_for_reset.png", 500, 320)
  self.prop_waitForReset:setLoc(x,y-180)
  env.layFG:insertProp(self.prop_waitForReset)
  table.insert(self.props, self.prop_waitForReset)
  self.prop_waitForReset:setPriority(900)
  env.physics:stop()

  for _,v in pairs(self.heroes) do
    System:remove(v)
  end

end

function Level:allDead()
  if not self.heroes then return end
  return ( self.heroes[1]:isRIP() and self.heroes[2]:isRIP() and self.heroes[3]:isRIP())
end


-------------------------------------------------------------------------------
-- Terrain
-------------------------------------------------------------------------------

function Level:addPlatform(name, ref)
  local x,y = ref.x, ref.y
  local w,h = ref.width, ref.height
  if name == "Ladder" then
    h = h+10
    y = y - 10
  end
  local left   = x
  local right  = x + w
  local top    = y
  local bottom = y + h

  local fix = self.ground:addRect(left, bottom, right, top)
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
  table.insert(self.fixtures, fix)
end

function Level:addPolyPlatform(name, x,y,polyline)
  local verts = {}
  for i = 1,#polyline do
    table.insert(verts, polyline[i].x + x)
    table.insert(verts, polyline[i].y + y)
  end
  local fix = self.ground:addPolygon(verts)
  fix:setRestitution(0)
  fix:setFriction(0.3)
  fix:setSensor(false)
  fix:setFilter(env.physics.categories.scenary, env.physics.masks.scenary)
  fix.name = name
  fix.class = "Terrain"
  table.insert(self.fixtures, fix)
end

function Level:addConveyer(ref)
  table.insert(self.traps, Conveyer:new(ref))
end

function Level:addExit(pos)
  table.insert(self.traps, TrapTrigger:new("Exit", pos, function()
    delay(1, function()
      self.stopScrollingBG = true
      self:nextLevel()
    end)
  end) )
end

function Level:addImageProp(fn, x,y,w,h)
  local prop = TextureManager:loadTexture(fn, w,h)
  prop:setLoc(x,y)
  env.layWorld:insertProp(prop)
  table.insert(self.props, prop)
end

-------------------------------------------------------------------------------
-- Hero
-------------------------------------------------------------------------------

function Level:packHero(x,y, isJump)
  local leader = self:getLeader()

  if x and y then
    leader.RigidBody:setLoc(x,y)
  end


  local idx = self.heroIdx
  for i=1, #self.heroes do

    local nextIdx = idx + 1
    if nextIdx > #self.heroes then nextIdx = 1 end

    local tar = self.heroes[idx]
    local v = self.heroes[nextIdx]
    v.KeyControl:disable()
    v.Follow:enable(tar)
    v.Follow:mute(1)
    v.ActionLog:clear()
    v:disableSkill()
    local tx, ty = tar.RigidBody:getLoc()
    v.RigidBody:setLoc(tx-40, ty)

    idx = nextIdx
    if idx > #self.heroes then idx = 1 end
  end


  leader:enableSkill()
  leader.KeyControl:enable()
  leader.Follow:disable()
  leader.RigidBody:setLoc(x,y)
  if isJump then
    leader:stateOn("jump")
  end
end

function Level:spawnHero(pos)
  local name = self.heroNames[self.heroIdx]

  local tmr = nil
  local tmr2 = nil

  self.heroes = {}
  table.insert(self.heroes, Hero:newWar(pos.x,pos.y))
  table.insert(self.heroes, Hero:newBard(pos.x,pos.y))
  table.insert(self.heroes, Hero:newMag(pos.x,pos.y))
  self.heroIdx = 1

  for _, v in pairs(self.heroes) do
    v:enable()
    v.ActionLog:steps(10)
    v:toRight(true)
  end

  self:packHero(self.heroes[1].RigidBody:getLoc())
end

function Level:assignHero(idx)
  if self.heroes[idx]:isRIP() then
    return
  end

  local prev_leader = self:getLeader()
  local vx,vy = prev_leader.RigidBody:getVelocity()

  if vy<-200 and prev_leader.RigidBody:isFlying() then return end


  if self.heroIdx == idx then return end

  local leader = self:getLeader()

  self.heroIdx = idx

  Audio:playSound("06 - Change")

  local x,y = leader.RigidBody:getLoc()
  self:packHero(x,y, prev_leader:isState("jump"))

  leader.RigidBody:setVelocity(vx,vy)
end

function Level:nextHero()
  local idx = self.heroIdx+1
  if idx > #self.heroes then
    idx = 1
  end

  if self.heroes[idx]:isRIP() then
    return false
  end

  Level:assignHero(idx)
  return true
end

-------------------------------------------------------------------------------
-- workflow
-------------------------------------------------------------------------------

function Level:reset()
    self.flag_reset = true
    self.flag_next  = false
    self.flag_prev  = false
    self.flag_force_lv = true
end
function Level:nextLevel(force)
    self.flag_reset = false
    self.flag_next  = true
    self.flag_prev  = false
    self.flag_force_lv = force
end
function Level:prevLevel(force)
    self.flag_reset = false
    self.flag_next  = false
    self.flag_prev  = true
    self.flag_force_lv = force
end
function Level:destroy(done)
  self:destroyTerrain()
  self:destroyTraps()
  self:destroyNPCs()
  self:destroyHero()
  self:destroyProps()
  self:destroyTimers()
  self:destroyKeys()
  self.flag_fire_arrow = nil
  self:stopShakingCam()
  System:recycle()
  self.flag_reset = false
  self.flag_next = false
  collectgarbage("collect")
  checkMem(false)
  done()
end

function Level:getLeader()
  if #self.heroes < 1 then return end
  return self.heroes[self.heroIdx]
end

function Level:isLeader(ent)
  return (self:getLeader().name==ent.name)
end

function Level:lockCamera()
  self.flag_lock_camera = true
end

function Level:onUpdate(dt)
  if not self.dt then return end
  if not self.enabled then return end

  if self.flag_waitForReset then return end

  self.dt = self.dt + dt
  self.dtCmd = self.dtCmd + dt
  self.dtTotal = self.dtTotal + dt

  local t1 = os.time()

  if self.dt < 0.01 then return end
  self.dt = 0

  --
  -- reset
  --
  local bReset = self.flag_reset or self.flag_next or self.flag_prev
  if bReset then
    local ref = {}
    for _,v in pairs(self.heroes) do
      ref[v.name] = not v:isRIP()
    end
    ref.dt = self.dtTotal
    ref.gems = self.gems
    ref.scroll = self.scroll
    ref.stage = self.idx
    ref.barricades = self.barricades
    ref.nBox = self.nBox
    ref.nEnemy = self.nEnemy

    if env.useScrollableBG then
      self:destroyScrollableBG1()
    end
    self:destroyTerrain()
    self:destroyTraps()
    self:destroyNPCs()
    self:destroyHero()
    self:destroyProps()
    self:destroyTimers()
    self:destroyKeys()
    self.flag_fire_arrow = nil
    self:stopShakingCam()
    self:destroyUI()
    System:recycle()

    -- Audio:stopMusic()

    if not self.flag_force_lv then
      CutScene:show(ref, function(cmd)
        if cmd.next and self.next <= #self.pool then
          self:load(self.next)
        else
          -- self:load(self.idx)
          OP:show("Thank you for playing the Demo !")
        end
        self.enabled = true
        collectgarbage("collect")
      end)
    else
        if self.flag_next and self.next <= #self.pool then
          self:load(self.next)
        elseif self.flag_prev and self.prev > 0 then
          self:load(self.prev)
        else
          self:load(self.idx)
        end
        self.enabled = true
        collectgarbage("collect")
    end

    self.flag_reset = false
    self.flag_next = false
    self.flag_prev = false
    self.flag_force_lv = true
  end

  local hero = self:getLeader()

  if hero and not self.mtxHero then
    local x,y = hero.RigidBody:getLoc()
    local cx,cy = env.camera:getLoc()

    if x and y and not self.flag_lock_camera then
      if self.flag_shake_cam == true then
        cx = cx + math.random(3)-2
        cy = cy + math.random(3)-2
      end

      --left side
      -- trace(y, self.yMax, self.yMin)
      if y > self.yMax-100 then y = self.yMax-100 end
      if y < self.yMin then y = self.yMin end

      local new_cx = cx+env.vx_camera*dt
      if new_cx < x+200 then
        new_cx = new_cx + (x+200-new_cx)/100
      end

      if new_cx < self.xMin+200 then new_cx = self.xMin+200 end
      if new_cx > self.xMax-300 then new_cx = self.xMax-300 end

      env.camera:setLoc(new_cx, y-env.camera_offset_y)

      if env.moon then
        env.moon:setLoc(new_cx+env.dx_moon, y-env.dy_moon)
      end

      -- death condition
      local det = new_cx - x
      if det > 500 then
        for _,v in pairs(self.heroes) do
          v:die()
        end
      end
    end
  end

  -- update scrollable backgrounds
  if env.useScrollableBG and not self.stopScrollingBG and env.camera then
    local cx,cy = env.camera:getLoc()

    local dcy = (cy-self.avg_cy)/500
    -- trace(dcy)
    if dcy > 0.4 then dcy = 0.4 end
    self.avg_cy = self.avg_cy + dcy

    for _,v in pairs(env.bg1) do
      local bx, by = v:getLoc()
      bx = bx + env.bg1_dx
      if bx < cx - env.bg1_w then
        bx = cx + (env.bg1_w)
      end

      -- trace(self.avg_cy+env.bg1_offset_y, self.avg_cy)

      -- v:setLoc(bx, self.avg_cy+env.bg1_offset_y)
      v:setLoc(bx, cy+env.bg1_offset_y)
    end

    for _,v in pairs(env.bg2) do
      local bx, by = v:getLoc()
      bx = bx + env.bg2_dx
      if bx < cx - env.bg2_w then
        bx = cx + (env.bg2_w)
      end
      -- v:setLoc(bx, self.avg_cy+env.bg2_offset_y)
      v:setLoc(bx, cy+env.bg1_offset_y)
    end
  end

  self.lbTime:say("Time: "..tostring(math.floor(self.dtTotal*100)/100))

  if self.dtCmd < 0.1 then return end
  self.dtCmd = 0

  Launcher:fire()

  if self.flag_fire_arrow and self.flag_fire_arrow.num > 0 then
    local px = self.flag_fire_arrow.pos.x
    local py = self.flag_fire_arrow.pos.y
    local vx = self.flag_fire_arrow.vx
    local vy = self.flag_fire_arrow.vy
    self.flag_fire_arrow.num = self.flag_fire_arrow.num-1

    local arrow = ArrowTrap:new(px+math.random(150), py-300)
    arrow:push(vx,vy)
  end

  if self.flag_enable_key then
    self.keys[self.flag_enable_key].RigidBody:setActive(true)
    self.flag_enable_key = nil
  end
  if self.flag_disable_key then
    self.keys[self.flag_disable_key].RigidBody:setActive(false)
    self.flag_disable_key = nil
  end

  local t2 = os.time()
  -- trace(t2-t1)
end

-------------------------------------------------------------------------------
-- destructors
-------------------------------------------------------------------------------
function Level:destroyTerrain()
  for _, fix in pairs(self.fixtures) do
    fix:destroy()
  end

  -- self.ground:destroy()
  -- self.ground = nil
  self.fixtures = {}
end

function Level:addNPC(ent)
  table.insert(self.npcs, ent)
end

function Level:destroyNPCs()
  for _, npc in pairs(self.npcs) do
    System:remove(npc)
  end
  self.npcs = {}
end

function Level:destroyTraps()
  for _, trap in pairs(self.traps) do
    System:remove(trap)
  end
  self.traps = {}
end
function Level:destroyProps()
  for _,v in pairs(self.props) do
    env.layWorld:removeProp(v)
    env.layFG:removeProp(v)
  end
  self.props = {}
end

function Level:destroyHero()
  for _,v in pairs(self.heroes) do
    System:remove(v)
  end
  self.heroes = {}
  self.heroIdx = 1
end
function Level:destroyTimers()
  for _,v in pairs(self.timers) do
    v:stop()
  end
  self.timers = {}
end
function Level:stopShakingCam()
  self.flag_shake_cam = false
  Audio:stopSound("14 - Earthquake")
end
function Level:startShakingCam()
  self.flag_shake_cam = true
  Audio:playSound("14 - Earthquake")
end

function Level:destroyKeys()
  for _,v in pairs(self.keys) do
    System:remove(v)
  end
  self.keys = {}
end
function Level:destroyUI()
  for _,v in pairs(self.ui) do
    v:destroy()
  end
  self.ui = {}
end
function Level:reviveHero(who)
  if who == nil then
    for _,v in pairs(self.heroes) do
      v:revive()
    end
  end
end

-------------------------------------------------------------------------------
-- traps
-------------------------------------------------------------------------------

function Level:setTorchTrap(pos)
  table.insert(self.traps, Torch:new(pos))
end
function Level:setSpikeTrap(pos)
  table.insert(self.traps, Spike:new(pos))
end

function Level:setRock(pos)
  local rock = GiantRock:new(pos.x+600, pos.y-400)
  rock:push(-30, 50)
  table.insert(self.traps, rock)
end

function Level:setGiantRockTrap(pos)
  table.insert(self.traps, TrapTrigger:new("GiantRock", pos, function()
    self.flag_set_rock = pos
    -- self.flag_shake_cam = true
    self:startShakingCam()
  end))
end

function Level:setArrowTrap(pos, vx,vy, num)
  table.insert(self.traps, TrapTrigger:new("ArrowTrap", pos, function()
    self.flag_fire_arrow = {pos=pos, vx=vx,vy=vy,num=num}
  end))
end

function Level:spawn(ref)
  local interval = tonumber(ref.properties.interval)
  if interval == 0 or interval == nil then
    local npc = Enemy:new(ref)
    self:addNPC(npc)
  elseif interval > 0 then
    local tmr = addTimer(interval, function()
      local npc = Enemy:new(ref)
      Audio:playSound("12 - Spawn")
      table.insert(self.npcs, npc)
    end)
    table.insert(self.timers, tmr)
  end
end

function Level:removeNPC(ent)
  local k = nil
  for _,v in pairs(self.npcs) do
    if v.key == ent.key then
      k = _
      break
    end
  end

  if k then
    self.npcs[k] = nil
    table.remove(self.npcs, k)
  end
end

function Level:setKey(ref)
  local item = Key:new(ref)
  self.keys[item.key] = item
end

function Level:enableKey(key)
  self.flag_enable_key = key
end
function Level:disableKey(key)
  self.flag_disable_key = key
end

function Level:setSpring(ref)
  table.insert(self.traps, Spring:new(ref))
end

function Level:setHeavyBox(ref)
  table.insert(self.traps, HeavyBox:new(ref))
end

-------------------------------------------------------------------------------
-- others
-------------------------------------------------------------------------------
function Level:loadTerrain(obj)
  if obj.name == "Entrance" then
    self:spawnHero(obj)
  elseif obj.name == "Exit" then
    self:addExit(obj)
  elseif obj.name == "Conveyer" then
    self:addConveyer(obj)
  elseif obj.name == "Ladder" or obj.name == "LeaveLadder" then
    self:addPlatform(obj.name, obj)
  elseif obj.name == "Gate" then
    self:addPlatform(obj.name, obj)
  elseif obj.name == "Wall" then
    self:addPlatform(obj.name, obj)
  elseif obj.name == "DeathZone" then
    self:addPlatform(obj.name, obj)
  elseif obj.name == "Image" then
    self:addImageProp(obj.type, obj.x, obj.y, obj.width, obj.height)
  elseif obj.shape == "rectangle" then
    self:addPlatform("Terrain", obj)
  elseif obj.shape == "polyline" then
    self:addPolyPlatform(obj.type, obj.x, obj.y, obj.polyline)
  elseif obj.shape == "polygon" then
    self:addPolyPlatform(obj.type, obj.x, obj.y, obj.polygon)
  end
end

function Level:loadTrap(obj)
  if obj.name == "Spike" then
    self:setSpikeTrap(obj)
  elseif obj.name == "Torch" then
    self:setTorchTrap(obj)
  elseif obj.name == "GiantRock" then
    self:setGiantRockTrap(obj)
  elseif obj.name == "ArrowTrap" and obj.type == "Fall" then
    self:setArrowTrap(obj, 0, 10, 30)
  elseif obj.name == "Key" then
    self:setKey(obj)
  elseif obj.name == "Spring" then
    self:setSpring(obj)
  elseif obj.name == "HeavyBox" then
    self:setHeavyBox(obj)
  elseif obj.name == "Obstacle" then
    table.insert(self.traps, Obstacle:new(obj))
  elseif obj.name == "DogCamp" then
    table.insert(self.traps, TrapTrigger:new("DogCamp", obj, function()
      Launcher:setStrayDog(obj.x, obj.y, right, tonumber(obj.properties.vx), tonumber(obj.properties.chance_jump))
    end))
  elseif obj.name == "EPIC" then
    -- trace("epic at",obj.x, obj.y)
    table.insert(self.traps, Epic:new(obj))
  end
end

function Level:loadScrollableBG()
  env.moon = TextureManager:loadTexture("Night.png")
  env.moon:setPriority(0)
  env.layWorld:insertProp(env.moon)

  env.bg1 = {}
  local num = math.floor(self.xMax/env.bg1_w ) + 1
  for i = 1,2 do
    local bg = TextureManager:loadTexture("Mountain.png",env.bg1_w+2,env.bg1_h)
    bg:setLoc(env.bg1_w *(i-1), env.bg1_h)
    bg:setPriority(0)
    bg:seekColor(1,1,1,env.bg1_alpha, 0,MOAIEaseType.LINEAR)
    table.insert(env.bg1, bg)
    env.layWorld:insertProp(bg)
  end


  env.bg2 = {}
  for i = 1,2 do
    local bg = TextureManager:loadTexture("MountainF.png",
      env.bg2_w+10, env.bg2_h)
    bg:setLoc(env.bg2_w *(i-1), env.bg2_h)
    bg:setPriority(0)
    bg:seekColor(0.5,0.5,0.5,env.bg2_alpha, 0, MOAIEaseType.LINEAR)
    table.insert(env.bg2, bg)
    env.layWorld:insertProp(bg)
  end

end

function Level:destroyScrollableBG1()
  if not env.useScrollableBG then return end

  env.layWorld:removeProp(env.moon)
  env.moon = nil

  -- local num = math.floor(self.xMax/env.bg1_w ) + 1
  for i = 1,2 do
    env.layWorld:removeProp(env.bg1[i])
  end
  env.bg1 = {}

  -- local num = math.floor(self.xMax/env.bg1_w ) + 1
  for i = 1,2 do
    env.layWorld:removeProp(env.bg2[i])
  end
  env.bg2 = {}

end

function Level:load(idx)
  self.dt = 0
  self.dtCmd = 0
  self.dtTotal = 0

  self.gems = 0
  self.barricades = 0
  self.scroll = 0
  self.nBox = 0
  self.nEnemy = 0

  self.stopScrollingBG = false

  self.avg_cy = 300

  self.idx = idx or 1
  self.flag_lock_camera = false
  self.next = self.idx + 1
  self.prev = self.idx - 1
  self.xMin, self.xMax = 9999999,-9999999
  self.yMin, self.yMax = 9999999,-9999999

  local lv = self.pool[self.idx]
  for i = 1, #lv.layers do
    if lv.layers[i].type == "tilelayer" then
      self:loadTiles(1, i)
    elseif lv.layers[i].type=="imagelayer" then
      self:loadBG(lv.layers[i], lv.properties)
    end
  end

  local entrance

  -- load terrain
  for _,v in pairs(lv.layers) do

    if v.name=="Terrain" then
      for k2, obj in pairs(v.objects) do
        self:loadTerrain(obj)
      end
    end

    if v.name=="Trap" then
      for k2, obj in pairs(v.objects) do
        self:loadTrap(obj)
      end
    end

    if v.name=="NPC" then
      for k2, obj in pairs(v.objects) do
        if obj.name == "Spawn" then
          self:spawn(obj)
        elseif obj.name == "StrayDog" then
          Launcher:setStrayDog(obj.x, obj.y, true, env.vx_dog, 0)
        end
      end
    end
  end

  -- reset camera position
  local hero = self:getLeader()
  if hero then
    local x,y = hero.RigidBody:getLoc()
    env.camera:setLoc(x+env.camera_offset_x, y-env.camera_offset_y)
  end

  if env.useScrollableBG then
    self:loadScrollableBG()
  end


  local lbTime = IconLabel:new()
  lbTime:init(env.camera, 300, 100, 50, -275)
  lbTime:setColor(163,217,121)
  self.lbTime = lbTime
  table.insert(self.ui, lbTime)


  local lbCoins = IconLabel:new()
  lbCoins:init(env.camera, 300, 100, -300, -275)
  lbCoins:say("0 Coins")
  lbCoins:setColor(218,119,254)
  self.lbCoins = lbCoins
  self.gems = 0
  table.insert(self.ui, lbCoins)

  self.scroll = 0
  self.nBox = 0
  self.nEnemy = 0

  Audio:playMusic("BGM")
  -- env.physics:start()
end

function Level:incGems()
  self.gems = self.gems + 1
  self.lbCoins:say(tostring(self.gems).." Coins")
end
function Level:incEnemy()
  self.nEnemy = self.nEnemy + 1
end
function Level:numEnemy()
  return self.nEnemy
end
function Level:incBox()
  self.nBox = self.nBox + 1
end
function Level:numBox()
  return self.nBox
end
function Level:incBarricade()
  self.barricades = self.barricades + 1
end
function Level:numBarricade()
  return self.barricades
end

function Level:incScroll()
  self.scroll = self.scroll + 1
  -- self.lbCoins:say(tostring(self.gems).." Gems")
end


function Level:loadTiles(iSet, iMap)
  local lv = self.pool[self.idx]
  local tileset = lv.tilesets[iSet]
  local tilemap = lv.layers[iMap]
  if not tilemap.width then return end
  local w, h = tileset.tilewidth, tileset.tileheight
  local dimx = tileset.imagewidth / w
  local dimy = tileset.imageheight / h
  local fn   = tileset.name..".png"

  for x=1,tilemap.width do
    for y=1,tilemap.height do
      local val = tilemap.data[ tilemap.width*(y-1) + x ]
      if val ~= 0 then
        local pp = TextureManager:loadTile(fn, w,h,dimx, dimy)
        local px = x * w
        local py = y * h
        pp:setLoc(px,py)
        pp:setIndex(val)
        env.layWorld:insertProp(pp)
        table.insert(self.props, pp)

        if px > self.xMax then self.xMax = px end
        if px < self.xMin then self.xMin = px end
        if py > self.yMax then self.yMax = py end
        if py < self.yMin then self.yMin = py end
      end
    end
  end
end

function Level:team(heroes)
  self.heroNames = heroes
  self.heroIdx = 1
end

function Level:init()
  self.idx = 0
  self.pool = {}
  self.pool = {}
  self.gems = 0
  self.scroll = 0
  self.barricades = 0
  self.nBox = 0
  self.nEnemy = 0

  self.enabled = true

  self.ground = env.physics:addBody(MOAIBox2DBody.STATIC)
  self.ground:setTransform(0,0)
  self.ground:setFixedRotation(true)

  self.fixtures = {}
  self.traps = {}
  self.props = {}
  self.npcs = {}
  self.timers = {}
  self.keys = {}
  self.ui = {}

  -- self.pocket = {}

  table.insert( self.pool, require("level/pk1") )
  table.insert( self.pool, require("level/pk2") )
  table.insert( self.pool, require("level/pk3") )


  env.layWorld:setClearColor (0,0,0, 1)
  Launcher:init()
end
