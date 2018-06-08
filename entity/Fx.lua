local Fx = {}


function Fx:getExplosion()
  local u = {}
  System:install(u, Sprite)
  u.Sprite:loadSprite(env.layWorld, "explosion_2.png", 100,100, 8, 4)
  -- u.Sprite:loadSprite(env.layWorld, "die.png", 100, 100, 5, 3)
  u.Sprite:setAnimationSequence("idle", 1 , {1})
  u.Sprite:setAnimationSequence("boom" , 0.01,
    {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24})

  u.Sprite:useAnimation("boom")
  u.Sprite:hide()
  return u
end

return Fx