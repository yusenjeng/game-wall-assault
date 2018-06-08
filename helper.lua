function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
math.randomseed(os.time())
math.random()        --bug in first use

function D(v1, v2)
  return math.abs(v1-v2)
end
function D2(x1,y1, x2,y2)
  d = math.sqrt(math.pow(x2-x1,2)+math.pow(y2-y1,2))
  return d
end
function D2v(dx, dy)
  d = math.sqrt(math.pow(dx,2)+math.pow(dy,2))
  return d
end
function dot(x1,y1, x2,y2)
  return x1*x2+y1*y2
end
function dice(n)
  return math.ceil(math.random(n*100000)/100000)
end
function dice0(n)
  return math.ceil(math.random(n*100000)/100000) -1
end

function degree(a,b)
  return math.deg(math.atan2 (a[1]*b[2]-a[2]*b[1],a[1]*b[1]+a[2]*b[2]))
end

char = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z","0","1","2","3","4","5","6","7","8","9", "@", "#", "$", "%", "&", "?"}
function randstr(s, l) -- args: smallest and largest possible password lengths, inclusive
  pass = {}
  size = math.random(s,l) -- random password length

  for z = 1,size do
    case = math.random(1,2) -- randomly choose case (caps or lower)
    a = math.random(1,#char) -- randomly choose a character from the "char" array
    if case == 1 then
            x=string.upper(char[a]) -- uppercase if case = 1
    elseif case == 2 then
            x=string.lower(char[a]) -- lowercase if case = 2
    end
    table.insert(pass, x) -- add new index into array.
  end
  return(table.concat(pass)) -- concatenate all indicies of the "pass" array, then print out concatenation.
end

function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

local locationFormat = "%s(%s):"
function trace (...)
  local info = debug.getinfo( 2, "Sl" )
  return print(locationFormat:format( info.source, info.currentline), ... )
end

local collect = collectgarbage
local lastCheck = {sysMem = 0}
function checkMem (say)
  collect()
  local sysMem = collect("count") * .001
  if say == true or lastCheck.sysMem ~= sysMem then
    lastCheck.sysMem = sysMem
    print( "Mem: " .. math.floor(sysMem*1000)*.001 .. "MB \t" )
  end
end

-- function delay (during, func, repeats, ...)
--  local t = MOAITimer.new()
--  t:setSpan( during/1000 )
--  t:setListener( MOAITimer.EVENT_TIMER_LOOP,
--   function ()
--     t:stop()
--     t = nil
--     func( unpack( arg ) )
--       if repeats then
--         if repeats > 1 then
--           performWithDelay( during, func, repeats-1, unpack( arg ) )
--         elseif repeats == 0 then
--           performWithDelay( during, func, 0, unpack( arg ) )
--         end
--       end
--   end
--  )
--  t:start()
--  end
function delay(t, f)
  local tmr
  tmr = addTimer(t, function()
    f()
    tmr:stop()
    tmr = nil
  end)
end


queue = {}

function queue:push(v)
  local last = self.last + 1
  self.last = last
  self[last] = v
end
function queue:pop()
  local first = self.first
  if first > self.last then
    error("queue is empty")
    return nil
  end
  local v = self[first]
  self[first] = nil        -- to allow garbage collection
  self.first = first + 1
  return v
end
function queue:head()
  return self[self.first]
end
function queue:size()
  return self.last - self.first + 1
end
function queue:new()
  local q = {first=0, last=-1}

  setmetatable(q, self)
  self.__index = self
  return q
end

