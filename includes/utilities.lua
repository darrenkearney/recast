-------------------------------
-- utility functions
-------------------------------
--
-- rect and rectfill but using width and height for sanity
--
function rectfill2(x,y,w,h,col)
   rectfill(x,y,x+w,y+h,col)
end

function rect2(x,y,w,h,col)
   rect(x,y,x+w,y+h,col)
end

--
-- transition effects
--
function fade_screen()
   for y=0,127 do
      for x=0,127 do
         local col = pget(x,y)
         pset(x,y,darken[col])
      end
   end
end

--
-- distance formula
-- handling of pico-8 16bit int limits with simple math
--
function get_distance( x1, y1, x2, y2 )

   -- distance calculation overflows the 16-bit integers, so step it down!
   local dx = (x2 - x1) / 100
   local dy = (y2 - y1) / 100
   local d = sqrt( dx^2 + dy^2 )
   return d * 100
end

--
-- simple either function that returns a random element in a table
--
function either( table )

   return table[flr(rnd(#table))+1]
end

--
-- play_sfx(), use in place of sfx()
-- checks the game settings before calling sfx()
function play_sfx(i,ch)

   if (is_sfx_enabled) then
      if (is_music_enabled) then
         sfx(i,ch) -- play in sfx channel
      else
         sfx(i) -- play in any available channel
      end
   end
end

--
-- quick and dirty table copy
--
function table_clone(org)

   local cpy = {}
   for k,v in pairs(org) do
      cpy[k]=v
   end
   return cpy
end

--
-- prints nicer text
--
function print_outline(s, x, y, col, outline_col)
   local s = s or ''
   local x = x or 0
   local y = y or 0
   local col = col or 7
   local outline_col = outline_col or 0

   print(s, x+1, y, outline_col)
   print(s, x-1, y, outline_col)
   print(s, x, y+1, outline_col)
   print(s, x, y-1, outline_col)

   print(s, x+1, y+1, outline_col)
   print(s, x+1, y-1, outline_col)
   print(s, x-1, y+1, outline_col)
   print(s, x-1, y-1, outline_col)

   print(s, x, y, col)
end

function print_shadow(s, x, y, col, shadow)
   local s = s or ''
   local x = x or 0
   local y = y or 0
   local col = col or 7
   local shadow = shadow or 0

   print(s, x+1, y, shadow)
   print(s, x, y+1, shadow)
   print(s, x+1, y+1, shadow)

   print(s, x, y, col)
end

-- draws a filled convex polygon
-- v is an array of vertices
-- {x1, y1, x2, y2} etc
-- https://www.lexaloffle.com/bbs/?tid=28312
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

 -- render scans
 for y=y1,y2 do
  local sx1=flr(max(0,x1[y]))
  local sx2=flr(min(127,x2[y]))

  local c=col*16+col
  local ofs1=flr((sx1+1)/2)
  local ofs2=flr((sx2+1)/2)
  memset(0x6000+(y*64)+ofs1,c,ofs2-ofs1)
  pset(sx1,y,c)
  pset(sx2,y,c)
 end
end
