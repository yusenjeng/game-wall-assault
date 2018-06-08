

Audio = {}

function Audio:loadMusic(fn, vol)
  local fullFilePath = "assets/audio/" .. fn

  if not MOAIFileSystem.checkFileExists(fullFilePath) then
    return nil
  end
  vol = vol or 0.5

  local snd = MOAIUntzSound.new()
  snd:load(fullFilePath)
  snd:setVolume(vol)
  snd:setLooping(true)

  local tok = fn:split(".")[1]
  self.bgm[tok] = snd
  -- trace("load "..tok)
end

function Audio:loadSound(fn, looping, vol)
  local fullFilePath = "assets/audio/" .. fn

  if not MOAIFileSystem.checkFileExists(fullFilePath) then
    return nil
  end

  if looping==nil then looping=false end
  vol = vol or 0.5

  local snd = MOAIUntzSound.new()
  snd:load(fullFilePath)
  snd:setVolume(0.5)
  snd:setLooping(looping)

  local tok = fn:split( ".")[1]

  self.snd[tok] = snd
  -- trace("load "..tok)
end

function Audio:playSound(name)
  self.snd[name]:play()
end
function Audio:stopSound(name)
  self.snd[name]:stop()
end

function Audio:playMusic(name)
  if self.busyMusic then return end
  self.bgm[name]:play()
  self.curr_bgm = name
  self.busyMusic = true
end

function Audio:isBGM(name)
  return (self.curr_bgm == name)
end

function Audio:stopMusic()
  for _,v in pairs(self.bgm) do
    v:stop()
  end
  self.busyMusic = false
end

function Audio:setVolume(val)
  for _,v in pairs(self.snd) do
    v:setVolume(val)
  end
end

function Audio:init()
  -- MOAIUntzSystem.initialize (96000, 8192)
  MOAIUntzSystem.initialize(44100, 4096)
  -- MOAIUntzSystem.initialize(22050, 8192)
  -- MOAIUntzSystem.initialize()
  self.snd = {}
  self.bgm = {}
  self.busyMusic = false
  self:loadSound("06 - Change.ogg")
  self:loadSound("03 - Dash.ogg")
  self:loadSound("05 - Walk-box.ogg")
  self:loadSound("12 - Spawn.ogg")
  self:loadSound("07 - Death-enemy.ogg")
  self:loadSound("08 - Death.ogg")
  self:loadSound("04 - Walk.ogg")
  self:loadSound("10 - Landing.ogg")
  self:loadSound("09 - Jump.ogg")
  self:loadSound("11 - Jump-s.ogg")
  self:loadSound("14 - Earthquake.ogg")
  self:loadSound("15 - Arrow.ogg")
  self:loadSound("01 - Hit.ogg")
  self:loadSound("16 - Coin.ogg")
  self:loadSound("13 - Fire.ogg")
  self:loadSound("17 - Break.ogg")
  self:loadSound("20 - Potion.ogg")
  self:loadSound("21 - Scare.ogg")
  self:loadSound("22 - Defence.ogg")
  self:loadSound("19 - Error.ogg")
  self:loadSound("18 - Click.ogg")

  self:loadMusic("BGM.ogg")
end