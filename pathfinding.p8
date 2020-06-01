pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
  game = {}
  test_one_run()
end

function _update()
  game.update()
end

function _draw()
 game.draw() 

  -- draw sprites
  -- spr()

  --controls (goes from 0-5)
  -- if btn(0) then do_something() end

  --border
  -- rect(0,0,127,127,7) --border
end

function test_one_run()
  counter = 0
  vertices = {}
  game.update = test_one_update
  game.draw = test_one_draw
end

function test_one_update()
 counter += 1
 if counter < 2 then 
  return 
 end
 --work out vertices
end

function test_one_draw()
 cls()
 pset(0,0,4)
 --draw setup
 --pset vertices, an object that will be populated by the alogorithm
 
 if counter < 2 then return end -- allow draw setup and working out of vertices in update
  --assertions
  if pget(0,0) == 4 then 
   test_two_run()
  else
   stop('test failed', 64, 64) -- stop( [message,] [x,] [y,] [col] )
  end

end

function test_two_run()
 game.update = test_two_update
 game.draw = test_two_draw
end

function test_two_update()
end

function test_two_draw()
 cls()
 print('tests passed!')
end



__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
