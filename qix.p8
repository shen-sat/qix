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
        if self.x >= (self.destination.x + self.destination.width) then self.x -= 1 end
        if self.x <= self.destination.x then self.x += 1 end
        if self.y >= (self.destination.y + self.destination.height) then self.y -= 1 end
        if self.y <= self.destination.y then self.y += 1 end
      end
    end
  } 

  game.update = level_update
  game.draw = level_draw
end

function level_update()
  qix:update()
end

function level_draw()
  cls()
  rect(0,0,127,127,7) --border
  spr(qix.sprite, qix.x - qix.width/2, qix.y - qix.height/2)
  -- destination hitbox
  rect(qix.destination.x,qix.destination.y,qix.destination.x + qix.destination.width,qix.destination.y + qix.destination.height,7)
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
