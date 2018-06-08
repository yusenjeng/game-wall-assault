

---------------------------------------------------------------------
--
-- IconLabel
--
---------------------------------------------------------------------

IconLabel = {}

function IconLabel:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function IconLabel:init(camera, w,h,ox,oy, font)
  local deck = MOAIScriptDeck.new ()

  -- deck:setDrawCallback (function(index, xOff, yOff, xScale, yScale)
  --   local x, y = 0,0
  --   local width, height, radius, circlestep = 360, 100, 10, 32
  --   local hw, hh = width/2, height/2

  --   local r,g,b = 0.2, 0.55, 0.9
  --   MOAIGfxDevice.setPenColor(r,g,b, 1)
  --   MOAIDraw.fillRect( x-hw+radius, y-hh,        x+hw-radius, y+hh )
  --   MOAIGfxDevice.setPenColor(r,g,b, 1)
  --   MOAIDraw.fillRect( x-hw,        y-hh+radius, x+hw,        y+hh-radius )

  --   MOAIGfxDevice.setPenColor(r,g,b, 1)
  --   MOAIDraw.fillCircle( x-hw+radius, y-hh+radius, radius, circlestep )
  --   MOAIDraw.fillCircle( x-hw+radius, y+hh-radius, radius, circlestep )
  --   MOAIDraw.fillCircle( x+hw-radius, y-hh+radius, radius, circlestep )
  --   MOAIDraw.fillCircle( x+hw-radius, y+hh-radius, radius, circlestep )
  -- end)

  -- deck:setRect(-w/2+ox, -h/2+oy, w/2+ox, h/2+oy)

  self.prop = MOAIProp2D.new ()
  self.prop:setDeck ( deck )

  font = font or env.font1

  local tw, th = w-80, 40
  self.textbox = MOAITextBox.new()
  self.textbox:setFont(font)
  self.textbox:setRect(-tw/2+ox, -th+oy, tw/2+ox, th+10+oy)
  self.textbox:setAlignment(MOAITextBox.LEFT_JUSTIFY)
  -- self.textbox:setString("oh my god that's a car")
  self.textbox:setAttrLink(MOAIProp.INHERIT_TRANSFORM, self.prop, MOAIProp.TRANSFORM_TRAIT)

  self.prop:setAttrLink(MOAIProp.INHERIT_TRANSFORM, camera, MOAIProp.TRANSFORM_TRAIT)

  self.prop:setBlendMode(MOAIProp2D.BLEND_NORMAL)

  self.x, self.y = 0, 0
  self.dt = 0

  env.layWorld:insertProp(self.prop)
  env.layWorld:insertProp(self.textbox)
end
function IconLabel:destroy()
  env.layWorld:removeProp(self.prop)
  env.layWorld:removeProp(self.textbox)
end
function IconLabel:setColor(r,g,b,a)
  a = a or 1
  self.textbox:seekColor(
    r/255.0, g/255.0, b/255.0, 1,
    0, MOAIEaseType.EASE_IN )
end
function IconLabel:show(x,y, blocked)
  x = x or self.x
  y = y or self.y
  self.prop:setLoc(x,y)
  env.layWorld:insertProp(self.prop)
  env.layWorld:insertProp(self.textbox)
  self.x = x
  self.y = y
  self.enabled = true
end

function IconLabel:hide()
  env.layWorld:removeProp(self.prop)
  env.layWorld:removeProp(self.textbox)
  self.enabled = false
end

function IconLabel:say(s, x, y)
  -- if self.IconLabel.enabled then
  --   self.IconLabel:hide()
  --   return
  -- end
  -- if not x or not y then
  --   x, y = self.prop:getLoc()
  -- end
  -- self.IconLabel:hide()
  self.textbox:setString(s)
  -- self.IconLabel:show()
end



