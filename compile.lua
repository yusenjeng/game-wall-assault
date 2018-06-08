-- compile all lua files recursively using moai SDK
-- in case you don't have luac or want to be sure lua
-- version is same in moai
-- load compiled files with 'dofile("filename.luac")'
--
-- Author: Alexander Sorokin / http://alexsorokin.ru
-- License:
-- this source is free to use for any purposes

local function print ( ... )
  return io.stdout:write ( string.format ( ... ))
end

function compileFile(path, fname)
  -- print("compile ... "..)
  f = loadfile(path.."/"..fname)
  of = io.open(path.."/"..fname.."c","wb")
  s = string.dump(f)
  of:write(s)
  of:close()

end

function convert(path)
  local files = MOAIFileSystem.listFiles(path)
  local i=0
  if not files then return end
  for i=1,#files do
    if ( string.find(files[i], 'lua$') ) then
      print ("> "..files[i].."\n")

      compileFile(path, files[i])
    end
  end

  local subdirs=MOAIFileSystem.listDirectories(path)
  for i=1,#subdirs do
    print(subdirs[i].."\n")
    if( not(subdirs[i]:sub(-2)=="/." or subdirs[i]:sub(-3)=="/.." )) then
      convert(subdirs[i])
    end
  end
end

convert("./")
