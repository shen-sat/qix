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
    x_speed = 0.5,
    y_speed = 0.5,
    destination = {
      x = flr(rnd(118)),
      y = flr(rnd(98)),
      width = 10,
      height = 10
    },
    move_history = {},
    update = function(self)
      self:move()
      self:manage_move_history()
    end,
    draw = function(self)
     foreach(self.move_history,self.draw_step)
    end,
    draw_step = function(step)
     spr(step.sprite, step.x - step.width/2, step.y - step.height/2)
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
      local x_distance = self.x - self.destination.x
      local y_distance = self.y - self.destination.y

      if x_distance < 1 then x_distance = x_distance * -1 end
      if y_distance < 1 then y_distance = y_distance * -1 end

      self.x_speed = x_distance/60
      self.y_speed = y_distance/60
    end,
    move = function(self)
      if self:destination_reached() then
        self:generate_destination()
      else
        if self.x >= (self.destination.x + self.destination.width) then self.x -= self.x_speed end
        if self.x <= self.destination.x then self.x += self.x_speed end
        if self.y >= (self.destination.y + self.destination.height) then self.y -= self.y_speed end
        if self.y <= self.destination.y then self.y += self.y_speed end
      end
    end,
    manage_move_history = function(self)
     if frame_counter % 10 == 0 then 
       local step = { x=self.x, y=self.y, width=self.width, height=self.height, sprite=self.sprite }
       add(self.move_history, step)
     end
     if #self.move_history > 5 then del(self.move_history, self.move_history[1]) end
    end
  }

  frame_counter = 0

  game.update = level_update
  game.draw = level_draw
end

function level_update()
  frame_counter += 1
  qix:update()
end

function level_draw()
  cls()
  rect(0,0,127,127,7) --border
  qix:draw()
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
