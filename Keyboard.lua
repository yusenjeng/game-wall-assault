Keyboard = {}

local keyStates = {}

-------------------------------------------------------------------------------
-- Build key name map
--  The key name map allows us to access ascii values by name, making
--  key processing much more readable.
--
--  Ex:
--    if key == Keyboard.esc then
--      os.exit()
--    end
-------------------------------------------------------------------------------

local function addKeyToMap(name, asciiValue)
  Keyboard[name] = asciiValue
end

addKeyToMap("enter", 13)
addKeyToMap("esc", 27)
addKeyToMap("space", 32)
addKeyToMap("del", 127)
addKeyToMap("d", 100)
addKeyToMap("a", 97)
addKeyToMap("w", 119)
addKeyToMap("s", 115)
addKeyToMap("slash", 47)
addKeyToMap("bracketsL", 91)
addKeyToMap("bracketsR", 93)
addKeyToMap("e", 101)
addKeyToMap("1", 49)
addKeyToMap("2", 50)
addKeyToMap("3", 51)

for asciiValue=33,255 do
-- for asciiValue=33,126 do
  local name = string.char(asciiValue)
  addKeyToMap(name, asciiValue)
end

if MOAIInputMgr.device.keyboard then
  MOAIInputMgr.device.keyboard:setCallback(function(key, down)
    -- trace(key, down)
    -- skip shift-key anomalies
    if key == 256 then
      return
    end

    -- Remove capitalization info
    if 65 <= key and key <= 90 then
      key = key + 32
    end

    -- Maintain the key state now
    keyStates[key] = down
    -- print(key)

    if Keyboard.keyboardCallback then
      Keyboard.keyboardCallback(key, down)
    end
  end)
end

function Keyboard:keyState(keyName)
  return keyStates[keyName]
end

function Keyboard:setCallback(keyboardCallback)
  if keyboardCallback and type(keyboardCallback) == "function" then
    self.keyboardCallback = keyboardCallback
  end
end
