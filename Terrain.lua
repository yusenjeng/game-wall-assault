
Terrain = {}

function Terrain:present(physics, drawLayer)
  if not physics and not drawLayer then
    return nil
  end

  self.physics = physics
  self.drawLayer = drawLayer

  -- Reset the physics representation of the floor
  self:rebuildFloor()

  -- Insert the floor images
  self.props = self:generateProps(self.verts)
  for i,prop in ipairs(self.props) do
    drawLayer:insertProp(prop)
  end
end

function Terrain:rebuildFloor()
  if not self.physics then
    return
  end

  if self.body then
    self.body:destroy()
  end

  self.body = self.physics:addBody( MOAIBox2DBody.STATIC, 0, -60 )
  self.fixtures = {
      self.body:addChain( self.verts )
  }
  self.fixtures[1].name = 'ground'
  self.fixtures[1].class = 'terrain'
  self.fixtures[1]:setFriction( 0.3 )
  self.fixtures[1]:setFilter(self.physics.categories.scenary, self.physics.masks.scenary)
end

function Terrain:generateProps(verts)
  local props = {}

  local blk = nil
  local prevHeight = 0
  local tOffsetY = -60   -- texture heightOffset

  -- Loop through all the vertices,
  --  Figure out which tiles we should be using,
  --  Load the tiles into the props table
  for i=1,#verts,2 do
    local x = verts[i]
    local y = verts[i+1]
    local ty = y + tOffsetY
    local tilename = nil

    -- Which tile should we be using here?
    if y > prevHeight then
      -- tilename = "rampwest"
      tilename = "stoneblock"
      -- ty = ty + 2
    elseif y < prevHeight then
      -- tilename = "rampeast"
      tilename = "stoneblock"
      ty = ty + 16
    else
      tilename = "stoneblock"
    end

    -- Load the prop now
    blk = TextureManager:loadTexture(tilename..".png", 40, 80)
    blk:setLoc(x, ty)
    if blk then
      blk:setPriority(math.floor((tOffsetY+60)/10))
      table.insert(props, blk)
    end
    prevHeight = y
  end

  return props
end

function Terrain:importVerts(verts)
  self.verts = verts
end

-------------------------------------------------------------------------------
-- Generate the terrain polyline
-------------------------------------------------------------------------------
function Terrain:getPlain(len)
  len = len or 100
  local origin = self.origin or {x=0,y=0}

  -- local wPlatform = math.floor(self.tileWidth  * 2)
  -- local hPlatform = math.floor(self.tileHeight + 1)
  local begin = 0
  local x,y, verts = 0,0,{}

  -- begin = begin + 1

  -- place a slot at the beginning
  -- if self.reverse then
  --   table.insert(verts, origin.x-0)
  --   table.insert(verts, origin.y-hPlatform)
  --   table.insert(verts, origin.x+wPlatform)
  --   table.insert(verts, origin.y-hPlatform)
  -- end

  for i=begin,len do
    x = i * self.tileWidth + origin.x
    y = origin.y
    table.insert(verts, x)
    table.insert(verts, y)
  end

  -- place a slot at the end
  -- if not self.reverse then
  --   table.insert(verts, x)
  --   table.insert(verts, y-hPlatform)
  --   table.insert(verts, x+wPlatform)
  --   table.insert(verts, y-hPlatform)
  -- end
  return verts
end


function Terrain:new(origin)
  local u = {}
  u.tileWidth = 40
  u.tileHeight = 20
  u.origin = origin or {x=0,y=0}

  setmetatable(u, self)
  self.__index = self
  return u
end