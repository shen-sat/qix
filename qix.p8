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

  temp_qix = {
   x = 20,
   y = 20
  }

  frame_counter = 0

  draw_color = 10
  path_color = 4
  background_color = 0
  fill_color = 2
  pathfinding_color = 12

  draw_lines = {}
  path_lines = {}
  
  started_drawing = false
  finished_drawing = false

  vertices = {}

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

  if started_drawing then
   if finished_drawing then
    local two_starting_points = get_compass_points_with_color(get_compass_points(player.x, player.y), path_color)

    for point in all(two_starting_points) do
     local vertix_x, vertix_y = player.x, player.y

     local temp_vertices = {}

     add(temp_vertices,vertix_x)
     add(temp_vertices,vertix_y)

     local current_point = point

     while true do
      --assign the current point
      local current_x, current_y = current_point.x, current_point.y
      --work out the direction of pathfinding
      local x_counter = current_x - vertix_x
      local y_counter = current_y - vertix_y
      --check if current point is the final vertix (probbaly it won't be, but let's check anyway)
      compass_points = get_compass_points(current_x, current_y)
      last_vertix_reached = compass_points_contain_color(compass_points, draw_color)
      --check if current point is an l-junction or a final vertix. if not, move along to next pixel
      while pget(current_x + x_counter,current_y + y_counter) != background_color and not last_vertix_reached do
       pset(current_x,current_y,pathfinding_color)
       current_y += y_counter
       current_x += x_counter
       compass_points = get_compass_points(current_x, current_y)
       last_vertix_reached = compass_points_contain_color(compass_points, draw_color)
      end   
      --record the current point as a vertix
      vertix_x, vertix_y = current_x, current_y
      add(temp_vertices,vertix_x)
      add(temp_vertices,vertix_y)
      --if we reached the final vertix, break...
      if last_vertix_reached then break end
      --...otherwise, reset current_point
      compass_points = get_compass_points(vertix_x, vertix_y)
      current_point = get_compass_points_with_color(compass_points, path_color)[1] -- only works with l-junctions
     end
     if poly_contains_qix(temp_vertices) == false then
      for v in all(temp_vertices) do
       add(vertices,v)
      end
     end
    end

    -- -- calculate area
    started_drawing = false
    finished_drawing = false

    for l in all(draw_lines) do
     add(path_lines,l)
    end
    draw_lines = {}
    
   end
  end

  player.prev_x = player.x
  player.prev_y = player.y

end

function level_draw()
  -- higher something is here, the further in the background it is
  cls()
  pal()
  -- qix:draw()
  pset(temp_qix.x,temp_qix.y,7)
  render_poly(vertices, fill_color)

  -- if not started_drawing then pal(draw_color,path_color) end
  for dl in all(draw_lines) do
   line(dl.x0,dl.y0,dl.x1,dl.y1,dl.col)
  end
  for pl in all(path_lines) do
   line(pl.x0,pl.y0,pl.x1,pl.y1,path_color)
  end
  

  rect(0,0,126,126,4) --border
  
  spr(player.sprite,player.x - 3,player.y - 3)
end

function create_line()
 local line_part = { x0 = player.x, y0 = player.y, x1 = player.prev_x, y1 = player.prev_y, col = draw_color }
 add(draw_lines,line_part)
end

function player_move(next_x, next_y, direction, player_move_called_already)
 local compass_points = get_compass_points(next_x, next_y)

 if pget(next_x, next_y) == path_color and compass_points_contain_color(compass_points, background_color) then
  if started_drawing then finished_drawing = true end
  player.x, player.y = next_x, next_y
  if btn(5) then create_line() end -- when moving from drawing a line to a path, we need to continue drawing a line 
 elseif pixel_is_drawable(next_x, next_y) and btn(5) then
  started_drawing = true
  player.x, player.y = next_x, next_y
  create_line()
 else
  -- if player_move_called_already then return end
  -- if direction == 'up' then 
  --  next_y += 1
  -- elseif direction == 'down' then
  --  next_y -= 1
  -- elseif direction == 'left' then
  --  next_x += 1
  -- elseif direction == 'right' then
  --  next_x -= 1
  -- end
  -- player_move(next_x, next_y, direction, true)
 end
end

function pixel_is_drawable(x,y)
 local compass_points = get_compass_points(x,y)
 return pget(x,y) == background_color and not pixel_outside_border(x,y)
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

function get_compass_points_with_color(compass_points, col)
 local points = {}
 for cp in all(compass_points) do
  if pget(cp.x, cp.y) == col then 
   local point = { x=cp.x, y=cp.y }
   add(points,point)
  end
 end
 return points
end

function no_of_colored_compass_points(compass_points, col)
 local colored_points = 0
 for cp in all(compass_points) do
  if pget(cp.x, cp.y) == col then colored_points +=1 end
 end
 return colored_points
end

function pixel_in_border(x,y)
 if x < 1 or x > 125 or y < 1 or y > 125 then return true end
end

function pixel_outside_border(x,y)
 if x < 0 or x > 126 or y < 0 or y > 126 then return true end
end

--------------------------------------------------------------------------------
-- draw paths and rects for player to move along
-- rectfill(1,1,126 -1,60 - 1,2)
-- line(1,60,127 - 1,60,4)
-- line(64, 1, 64, 60, 4)

-- create line
-- create_line = function(self)
--  line_part = { x0 = self.x, y0 = self.y, x1 = self.prev_x, y1 = self.prev_y, col = draw_color }
--  add(draw_lines,line_part)
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

  -- from forum
  -- draws a filled convex polygon
  -- v is an array of vertices
  -- {x1, y1, x2, y2} etc
function render_poly(v,col)
 col=col or 5

 -- initialize scan extents
 -- with ludicrous values
 local x1,x2={},{}
 for y=0,127 do
  x1[y],x2[y]=128,-1
 end
 local y1,y2=128,-1

 -- scan convert each pair
 -- of vertices
 for i=1, #v/2 do
  local next=i+1
  if (next>#v/2) next=1

  -- alias verts from array
  local vx1=flr(v[i*2-1])
  local vy1=flr(v[i*2])
  local vx2=flr(v[next*2-1])
  local vy2=flr(v[next*2])

  if vy1>vy2 then
   -- swap verts
   local tempx,tempy=vx1,vy1
   vx1,vy1=vx2,vy2
   vx2,vy2=tempx,tempy
  end 

  -- skip horizontal edges and
  -- offscreen polys
  if vy1~=vy2 and vy1<128 and
   vy2>=0 then

   -- clip edge to screen bounds
   if vy1<0 then
    vx1=(0-vy1)*(vx2-vx1)/(vy2-vy1)+vx1
    vy1=0
   end
   if vy2>127 then
    vx2=(127-vy1)*(vx2-vx1)/(vy2-vy1)+vx1
    vy2=127
   end

   -- iterate horizontal scans
   for y=vy1,vy2 do
    if (y<y1) y1=y
    if (y>y2) y2=y

    -- calculate the x coord for
    -- this y coord using math!
    x=(y-vy1)*(vx2-vx1)/(vy2-vy1)+vx1

    if (x<x1[y]) x1[y]=x
    if (x>x2[y]) x2[y]=x
   end 
  end
 end
 
 -- local contains_qix = false
 -- for y_point=0,127 do
 --  local first_point_x = x1[y_point] 
 --  local second_point_x = x2[y_point]

 --  while first_point_x <= second_point_x do
 --   if pget(first_point_x,y_point) == 7 then
 --    contains_qix = true
 --   end
 --   first_point_x +=1
 --  end
 -- end

 -- render scans
 
  for y=y1,y2 do
   local sx1=flr(max(0,x1[y]))
   local sx2=flr(min(127,x2[y]))

   local c=col*16+col
   local ofs1=flr((sx1+1)/2)
   local ofs2=flr((sx2+1)/2)
   memset(0x6000+(y*64)+ofs1,c,ofs2-ofs1)
   pset(sx1,y,7)
   pset(sx2,y,7)
  end
 -- end
end

function poly_contains_qix(v)
 col=col or 5

 -- initialize scan extents
 -- with ludicrous values
 local x1,x2={},{}
 for y=0,127 do
  x1[y],x2[y]=128,-1
 end
 local y1,y2=128,-1

 -- scan convert each pair
 -- of vertices
 for i=1, #v/2 do
  local next=i+1
  if (next>#v/2) next=1

  -- alias verts from array
  local vx1=flr(v[i*2-1])
  local vy1=flr(v[i*2])
  local vx2=flr(v[next*2-1])
  local vy2=flr(v[next*2])

  if vy1>vy2 then
   -- swap verts
   local tempx,tempy=vx1,vy1
   vx1,vy1=vx2,vy2
   vx2,vy2=tempx,tempy
  end 

  -- skip horizontal edges and
  -- offscreen polys
  if vy1~=vy2 and vy1<128 and
   vy2>=0 then

   -- clip edge to screen bounds
   if vy1<0 then
    vx1=(0-vy1)*(vx2-vx1)/(vy2-vy1)+vx1
    vy1=0
   end
   if vy2>127 then
    vx2=(127-vy1)*(vx2-vx1)/(vy2-vy1)+vx1
    vy2=127
   end

   -- iterate horizontal scans
   for y=vy1,vy2 do
    if (y<y1) y1=y
    if (y>y2) y2=y

    -- calculate the x coord for
    -- this y coord using math!
    x=(y-vy1)*(vx2-vx1)/(vy2-vy1)+vx1

    if (x<x1[y]) x1[y]=x
    if (x>x2[y]) x2[y]=x
   end 
  end
 end
 
 local contains_qix = false
 for y_point=0,127 do
  local first_point_x = x1[y_point] 
  local second_point_x = x2[y_point]

  while first_point_x <= second_point_x do
   if first_point_x == temp_qix.x and y_point == temp_qix.y then
    contains_qix = true
   end
   first_point_x +=1
  end
 end
 return contains_qix
end

__gfx__
aaaaaaaa00bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaa0b000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaab00000b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaab00b00b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaab00000b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaa0b000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaa00bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
