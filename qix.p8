pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
  game = {}
  run_level()
end

function _update()
  game.update()
end

function _draw()
  game.draw() 
end

function run_level()
  qix = {
    sprite = 0,
    x = 64,
    y = 64,
    width = 8,
    height = 8,
    speed = 0.5,
    destination = {
      x = flr(rnd(118)),
      y = flr(rnd(98)),
      width = 10,
      height = 10
    },
    update = function(self)
      self:move()
    end,
    destination_reached = function(self)
      local left = self.destination.x
      local top = self.destination.y
      local width = self.destination.width
      local height = self.destination.height
      return point_in_rect(self.x,self.y,left,top,width,height)
    end,
    generate_destination = function(self)
      self.destination.x = flr(rnd(108) + 10)
      self.destination.y = flr(rnd(108) + 10)
    end,
    move = function(self)
      if self:destination_reached() then
        self:generate_destination()
      else
        if self.x >= (self.destination.x + self.destination.width) then self.x -= self.speed end
        if self.x <= self.destination.x then self.x += self.speed end
        if self.y >= (self.destination.y + self.destination.height) then self.y -= self.speed end
        if self.y <= self.destination.y then self.y += self.speed end
      end
    end
  }
  counter = 0
  move_history = {}

  game.update = level_update
  game.draw = level_draw
end

function level_update()
  qix:update()

  counter += 1
  
  if counter % 10 == 0 then 
    step = {qix.x, qix.y}
    add(move_history, step)
  end

  if #move_history > 5 then del(move_history, move_history[1]) end

end

function level_draw()
  cls()
  rect(0,0,127,127,7) --border

  foreach(move_history,draw_block) 

  -- destination hitbox
  rect(qix.destination.x,qix.destination.y,qix.destination.x + qix.destination.width,qix.destination.y + qix.destination.height,7)
end

function draw_block(step)
 spr(qix.sprite, step[1] - qix.width/2, step[2] - qix.height/2)
end

function point_in_rect(x,y,left,top,width,height)
  return x > left and x < (left + width) and y > top and y < (top + height)
end

__gfx__
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
