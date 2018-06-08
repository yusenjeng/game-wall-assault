TextureManager = {
  imgPool={},
  texPool={}
}

function TextureManager:loadSprite(fn, w, h, dimX, dimY)
  local fullFilePath = "assets/image/" .. fn

  if not MOAIFileSystem.checkFileExists(fullFilePath) then
    return nil
  end

  local image = self.imgPool[fullFilePath]
  if not image then
    image = MOAIImage.new()
    image:load(fullFilePath)
    self.imgPool[fullFilePath] = image
    local w, h = image:getSize()
    print("IMAGE: loading",  "[" .. w .. "x" .. h .. "] " .. fn)
  end
  if not width or not height then
    width, height = image:getSize()
  end

  local texture = self.texPool[fullFilePath]
  if not texture then
    texture = MOAITexture.new()
    texture:load(image)
    self.texPool[fullFilePath] = texture
  end

  sheet = MOAITileDeck2D.new ()
  sheet:setTexture ( texture )
  sheet:setSize ( dimX, dimY )     -- subdivide the texture into dimX*dimY frames
  sheet:setRect ( -w/2, h/2, w/2, -h/2 )  -- set the world space dimensions of the sprites

  -- create a sprite and initialize it
  sprite = MOAIProp2D.new ()
  sprite:setDeck ( sheet )
  sprite:setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)
  sprite:setIndex(1)
  sprite.sheet = sheet

  return sprite
end

function TextureManager:loadTile(fn, w, h, dimX, dimY)
  local fullFilePath = "assets/image/" .. fn

  if not MOAIFileSystem.checkFileExists(fullFilePath) then
    return nil
  end

  local image = self.imgPool[fullFilePath]
  if not image then
    image = MOAIImage.new()
    image:load(fullFilePath)
    self.imgPool[fullFilePath] = image
    local w, h = image:getSize()
    print("IMAGE: loading",  "[" .. w .. "x" .. h .. "] " .. fn)
  end
  if not width or not height then
    width, height = image:getSize()
  end

  local texture = self.texPool[fullFilePath]
  if not texture then
    texture = MOAITexture.new()
    texture:load(image)
    self.texPool[fullFilePath] = texture
  end

  sheet = MOAITileDeck2D.new ()
  sheet:setTexture ( texture )
  sheet:setSize ( dimX, dimY )     -- subdivide the texture into dimX*dimY frames
  sheet:setRect ( -w, 0, 0,-h )  -- set the world space dimensions of the sprites

  -- create a sprite and initialize it
  sprite = MOAIProp2D.new ()
  sprite:setDeck ( sheet )
  sprite:setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)
  sprite:setIndex(1)
  sprite.sheet = sheet

  return sprite
end


function TextureManager:loadPureTexture(fn, width, height)
  local fullFilePath = "assets/image/" .. fn

  if not MOAIFileSystem.checkFileExists(fullFilePath) then
    return nil
  end

  local image = self.imgPool[fullFilePath]
  if not image then
    image = MOAIImage.new()
    image:load(fullFilePath)
    self.imgPool[fullFilePath] = image
    local w, h = image:getSize()
    print("IMAGE: loading",  "[" .. w .. "x" .. h .. "] " .. fn)
  end

  if not width or not height then
    width, height = image:getSize()
  end

  local texture = self.texPool[fullFilePath]
  if not texture then
    texture = MOAITexture.new()
    texture:load(image)
    self.texPool[fullFilePath] = texture
  end


  local quad = MOAIGfxQuad2D.new()
  quad:setTexture(texture)
  quad:setRect(-width/2, height, width/2, 0)

  return quad
end

function TextureManager:loadTexture(fn, width, height)
  local fullFilePath = "assets/image/" .. fn

  if not MOAIFileSystem.checkFileExists(fullFilePath) then
    return nil
  end

  local image = self.imgPool[fullFilePath]
  if not image then
    image = MOAIImage.new()
    image:load(fullFilePath)
    self.imgPool[fullFilePath] = image
    local w, h = image:getSize()
    print("IMAGE: loading",  "[" .. w .. "x" .. h .. "] " .. fn)
  end

  if not width or not height then
    width, height = image:getSize()
  end

  local texture = self.texPool[fullFilePath]
  if not texture then
    texture = MOAITexture.new()
    texture:load(image)
    self.texPool[fullFilePath] = texture
  end

  local quad = MOAIGfxQuad2D.new()
  quad:setTexture(texture)
  quad:setRect(-width/2, height, width/2, 0)

  local image = MOAIProp2D.new()
  image:setDeck(quad)
  image:setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)

  return image
end

