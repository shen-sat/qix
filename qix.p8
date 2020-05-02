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
      x = flr(rnd(108) + 10),
      y = flr(rnd(108) + 10)
    },
    update = function(self)
      self:move()
    end,
    destination_reached = function(self)
      return (self.x == self.destination.x and self.y == self.destination.y)
    end,
    generate_destination = function(self)
      self.destination.x = flr(rnd(108) + 10)
      self.destination.y = flr(rnd(108) + 10)
    end,
    move = function(self)
      if self:destination_reached() then
        self:generate_destination()
      else
        if self.x > self.destination.x then self.x -= 1 end
        if self.x < self.destination.x then self.x += 1 end
        if self.y > self.destination.y then self.y -= 1 end
        if self.y < self.destination.y then self.y += 1 end
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
  print(qix:destination_reached())
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
