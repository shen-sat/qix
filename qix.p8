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
     spr(step.sprite, step.x, step.y)
    end,
    destination_reached = function(self)
      return point_in_rect(self,self.destination)
    end,
    generate_destination = function(self)
      self.destination.x = flr(rnd(108) + 10)
      self.destination.y = flr(rnd(108) + 10)
      local x_distance = center_of(self).x - center_of(self.destination).x
      local y_distance = center_of(self).y - center_of(self.destination).y

      if x_distance < 1 then x_distance = x_distance * -1 end
      if y_distance < 1 then y_distance = y_distance * -1 end

      self.x_speed = x_distance/60
      self.y_speed = y_distance/60
    end,
    move = function(self)
      if self:destination_reached() then
        self:generate_destination()
      else
        if center_of(self).x >= center_of(self.destination).x then self.x -= self.x_speed end
        if center_of(self).x <= center_of(self.destination).x then self.x += self.x_speed end
        if center_of(self).y >= center_of(self.destination).y then self.y -= self.y_speed end
        if center_of(self).y <= center_of(self.destination).y then self.y += self.y_speed end
      end
    end,
    manage_move_history = function(self)
     if frame_counter % 10 == 0 then 
       local step = self
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
  -- higher something is here, the further in the background it is
  cls()
  rect(0,0,127,127,7) --border
  qix:draw()
  -- destination hitbox
  rect(qix.destination.x,qix.destination.y,qix.destination.x + qix.destination.width - 1,qix.destination.y + qix.destination.height - 1,7)
  
end

function center_of(obj)
 return { x = obj.x + (obj.width/2), y = obj.y + (obj.height/2) }
end

function point_in_rect(point_obj, rect_obj)
  -- x,y,left,top,width,height
  local x = point_obj.x + (point_obj.width/2)
  local y = point_obj.y + (point_obj.height/2)
  local left = rect_obj.x
  local top = rect_obj.y
  local width = rect_obj.width
  local height = rect_obj.height
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
