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
    hitboxes = function(self)
     local gap = 3
     return {
       top_hitbox = { x = self.x + gap, y = self.y, width = self.width - (2*gap), height = self.height/2 },
       bottom_hitbox = { x = self.x + gap, y = self.y + self.height/2, width = self.width - (2*gap), height = self.height/2 },
       right_hitbox = { x = self.x + self.width/2, y = self.y + gap, width = self.width/2, height = self.height - (2*gap) },
       left_hitbox = { x = self.x, y = self.y + gap, width = self.width/2, height = self.height - (2*gap) }
      }
    end,
    update = function(self)
      self:move()
      self:manage_move_history()
    end,
    draw = function(self)
     foreach(self.move_history,self.draw_step)
    end,
    check_block_collision = function(self)
     local collision_hitbox
     for block in all(blocks) do
      if check_overlap(self:hitboxes().top_hitbox, block) then
       collision_hitbox = self:hitboxes().top_hitbox
      elseif check_overlap(self:hitboxes().bottom_hitbox, block) then
       collision_hitbox = self:hitboxes().bottom_hitbox
      elseif check_overlap(self:hitboxes().right_hitbox, block) then
       collision_hitbox = self:hitboxes().right_hitbox
      elseif check_overlap(self:hitboxes().left_hitbox, block) then
       collision_hitbox = self:hitboxes().left_hitbox
      end
     end
     return collision_hitbox
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
     if center_of(self).x >= center_of(self.destination).x then self.x -= self.x_speed end
     if center_of(self).x <= center_of(self.destination).x then self.x += self.x_speed end
     if center_of(self).y >= center_of(self.destination).y then self.y -= self.y_speed end
     if center_of(self).y <= center_of(self.destination).y then self.y += self.y_speed end

     if self:check_block_collision() then
      self:generate_destination()
      local hitbox_that_collided = self:check_block_collision()
      if hitbox_that_collided == self:hitboxes().top_hitbox then 
       self.y += self.y_speed
      elseif hitbox_that_collided == self:hitboxes().bottom_hitbox then
       self.y -= self.y_speed
      elseif hitbox_that_collided == self:hitboxes().left_hitbox then
       self.x += self.x_speed
      elseif hitbox_that_collided == self:hitboxes().right_hitbox then
       self.x -= self.x_speed
      end
     end

     if self:destination_reached() then self:generate_destination() end
    end,
    manage_move_history = function(self)
     if frame_counter % 10 == 0 then 
       local step = { sprite = self.sprite, x = self.x, y = self.y }
       add(self.move_history, step)
     end
     if #self.move_history > 5 then del(self.move_history, self.move_history[1]) end
    end
  }

  player = {
   x = 0,
   y = 126,
   prev_x = 0,
   prev_y = 127, 
   sprite = 1,
   speed = 2
  }

  frame_counter = 0

  draw_color = 10
  path_color = 4
  background_color = 0
  fill_color = 2

  lines = {}
  player_is_drawing = false

  game.update = level_update
  game.draw = level_draw
end

function level_update()
  frame_counter += 1
  qix:update()

  if btn(2) then
   local next_x, next_y = player.x, player.y - player.speed
   player_move(next_x, next_y, 'up', false)
  elseif btn(3) then
   local next_x, next_y = player.x, player.y + player.speed
   player_move(next_x, next_y, 'down', false)
  elseif btn(0) then
   local next_x, next_y = player.x - player.speed, player.y
   player_move(next_x, next_y, 'left', false)
  elseif btn(1) then
   local next_x, next_y = player.x + player.speed, player.y
   player_move(next_x, next_y, 'right', false)
  end


  player.prev_x = player.x
  player.prev_y = player.y

end

function level_draw()
  -- higher something is here, the further in the background it is
  cls()

  for l in all(lines) do
   line(l.x0,l.y0,l.x1,l.y1,l.col)
  end

  rect(0,0,126,126,4) --border
  -- qix:draw()
  
  spr(player.sprite,player.x - 3,player.y - 3)


end

function create_line()
 local line_part = { x0 = player.x, y0 = player.y, x1 = player.prev_x, y1 = player.prev_y, col = draw_color }
 add(lines,line_part)
end

function player_move(next_x, next_y, direction, player_move_called_already)
 local compass_points = get_compass_points(next_x, next_y)

 if pget(next_x, next_y) == path_color and compass_points_contain_color(compass_points, background_color) then
  player.x, player.y = next_x, next_y
 elseif pixel_is_drawable(next_x, next_y) then
  player.x, player.y = next_x, next_y
  create_line()
 else
  if player_move_called_already then return end
  if direction == 'up' then 
   next_y += 1
  elseif direction == 'down' then
   next_y -= 1
  elseif direction == 'left' then
   next_x += 1
  elseif direction == 'right' then
   next_x -= 1
  end
  player_move(next_x, next_y, direction, true)
 end
end

function pixel_is_drawable(x,y)
 local compass_points = get_compass_points(x,y)
 return pget(x,y) == background_color and not pixel_outside_screen(x,y)
end

function check_overlap(rect_a, rect_b)
 local rect_a_right = rect_a.x + rect_a.width
 local rect_a_left = rect_a.x
 local rect_b_right = rect_b.x + rect_b.width
 local rect_b_left = rect_b.x

 local rect_a_top = rect_a.y
 local rect_a_bottom = rect_a.y + rect_a.height
 local rect_b_top = rect_b.y
 local rect_b_bottom = rect_b.y + rect_b.height
 
 return (rect_a_right > rect_b_left and rect_b_right > rect_a_left) and (rect_a_bottom > rect_b_top and rect_b_bottom > rect_a_top)
end

function center_of(obj)
 return { x = obj.x + (obj.width/2), y = obj.y + (obj.height/2) }
end

function point_in_rect(point_obj, rect_obj)
  local x = point_obj.x + (point_obj.width/2)
  local y = point_obj.y + (point_obj.height/2)
  local left = rect_obj.x
  local top = rect_obj.y
  local width = rect_obj.width
  local height = rect_obj.height
  return x > left and x < (left + width) and y > top and y < (top + height)
end

function get_compass_points(point_x,point_y)
 return {
  { x = point_x, y = point_y - 1 }, --north
  { x = point_x + 1, y = point_y }, --east
  { x = point_x, y = point_y + 1 }, --south
  { x = point_x - 1, y = point_y } --west
 }
end

function compass_points_contain_color(compass_points, col)
 local contains_color = false
 for cp in all(compass_points) do
  if pget(cp.x, cp.y) == col then contains_color = true end
 end
 return contains_color
end

function no_of_colored_compass_points(compass_points, col)
 local colored_points = 0
 for cp in all(compass_points) do
  if pget(cp.x, cp.y) == col then colored_points +=1 end
 end
 return colored_points
end

function pixel_in_border(x,y)
 if x < 1 or x > 126 or y < 1 or y > 126 then return true end
end

function pixel_outside_screen(x,y)
 if x < 0 or x > 127 or y < 0 or y > 127 then return true end
end

--------------------------------------------------------------------------------
-- draw paths and rects for player to move along
-- rectfill(1,1,126 -1,60 - 1,2)
-- line(1,60,127 - 1,60,4)
-- line(64, 1, 64, 60, 4)

-- create line
-- create_line = function(self)
--  line_part = { x0 = self.x, y0 = self.y, x1 = self.prev_x, y1 = self.prev_y, col = draw_color }
--  add(lines,line_part)
-- end

-- draw paths and rects for player to move along
-- rectfill(1,1,127 -1,60 - 1,2)
-- line(1,60,127 - 1,60,4)
-- line(64, 1, 64, 60, 4)

-- control qix manually
 -- if btn(0) then qix.x -= 1 end
 -- if btn(1) then qix.x += 1 end
 -- if btn(2) then qix.y -= 1 end
 -- if btn(3) then qix.y += 1 end

-- blocks, if you need em
 -- top_block = {
 --  x = 0,
 --  y = 0,
 --  width = 128,
 --  height = 128/4
 -- }
 -- bottom_block = {
 --  x = 0,
 --  y = 96,
 --  width = 128,
 --  height = 128/4
 -- }
 -- left_block = {
 --  x = 0,
 --  y = 0,
 --  width = 128/4,
 --  height = 128
 -- }
 -- right_block = {
 --  x = 96,
 --  y = 0,
 --  width = 128/4,
 --  height = 128
 -- }
 -- add(blocks, top_block)
 -- add(blocks, bottom_block)
 -- add(blocks, left_block)
 -- add(blocks, right_block)

 -- draw blocks
  -- for block in all(blocks) do
  --  rectfill(block.x,block.y,block.x + block.width - 1,block.y + block.height - 1,3)
  -- end

  -- destination hitbox
  -- rect(qix.destination.x,qix.destination.y,qix.destination.x + qix.destination.width - 1,qix.destination.y + qix.destination.height - 1,7)

__gfx__
aaaaaaaa00bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaa0b000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaab00000b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaab00b00b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaab00000b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaa0b000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaa00bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
