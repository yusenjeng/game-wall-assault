
MsgBox = {}
MsgBox.e = {}

------------------------------------------------------
-- System events
------------------------------------------------------
function MsgBox:new()
  local u = {}
  setmetatable(u, self)
  self.__index = self
  return u
end

function MsgBox:onConnect()
  local deck = MOAIScriptDeck.new ()
  deck:setDrawCallback (function(index, xOff, yOff, xScale, yScale)
    local x, y = 0,0
    local width, height, radius, circlestep = 360, 100, 10, 32
    local hw, hh = width/2, height/2

    local r,g,b = 0.2, 0.55, 0.9
    MOAIGfxDevice.setPenColor(r,g,b, 1)
    MOAIDraw.fillRect( x-hw+radius, y-hh,        x+hw-radius, y+hh )
    MOAIGfxDevice.setPenColor(r,g,b, 1)
    MOAIDraw.fillRect( x-hw,        y-hh+radius, x+hw,        y+hh-radius )

    MOAIGfxDevice.setPenColor(r,g,b, 1)
    MOAIDraw.fillCircle( x-hw+radius, y-hh+radius, radius, circlestep )
    MOAIDraw.fillCircle( x-hw+radius, y+hh-radius, radius, circlestep )
    MOAIDraw.fillCircle( x+hw-radius, y-hh+radius, radius, circlestep )
    MOAIDraw.fillCircle( x+hw-radius, y+hh-radius, radius, circlestep )
  end)

  deck:setRect(-200, -220, 200, 220)

  self.prop = MOAIProp2D.new ()
  self.prop:setDeck ( deck )

  self.textbox = MOAITextBox.new()
  self.textbox:setFont(env.font1)
  self.textbox:setRect(-160, -40, 160, 50)
  self.textbox:setAlignment(MOAITextBox.LEFT_JUSTIFY)
  -- self.textbox:setString("oh my god that's a car")
  self.textbox:setAttrLink(MOAIProp.INHERIT_TRANSFORM, self.prop, MOAIProp.TRANSFORM_TRAIT)

  -- prop:setAttrLink(MOAIProp.INHERIT_TRANSFORM, camera, MOAIProp.TRANSFORM_TRAIT)

  self.prop:setBlendMode(MOAIProp2D.BLEND_NORMAL)

  self.x, self.y = 0, 0
  self.dt = 0
end

function MsgBox:show(x,y, blocked)
  x = x or self.x
  y = y or self.y
  self.prop:setLoc(x,y)
  env.layWorld:insertProp(self.prop)
  env.layWorld:insertProp(self.textbox)
  self.x = x
  self.y = y
  self.enabled = true
end

function MsgBox:hide()
  env.layWorld:removeProp(self.prop)
  env.layWorld:removeProp(self.textbox)
  self.enabled = false
end

function MsgBox:onUpdate(dt)
  self.dt = self.dt + dt

  if self.dt > 0.02 then
    local x,y = self.entity.RigidBody:getLoc()
    self.prop:setLoc(x+80,y-100)

    self.dt = 0
  end

end

------------------------------------------------------
-- Entity events
------------------------------------------------------

function MsgBox.e:say(s, x, y)
  if self.MsgBox.enabled then
    self.MsgBox:hide()
    return
  end
  if not x or not y then
    x, y = self.RigidBody:getLoc()
  end
  self.MsgBox:hide()
  self.MsgBox.textbox:setString(s)
  self.MsgBox:show()
end



