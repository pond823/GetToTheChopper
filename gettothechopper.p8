pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--get to the chopper
--by sasha bilton

-- global variables

game = {}
game.state = 1
game.timer = 1
game.scroll = 1
game.get_up_timer =0
game.score = 0
game.run_time = 1000
game.distance = 800
game.boom =0
sprites = {}
player = {}
bullets = {}
terrain = {}
bad_guys = {}
predators = {}
predator_plasma={}

function _init()
  create_text()
  player.base = 110
end

function _update()
    update_timer()
    foreach(sprites, update_sprite)
  	if (game.state != 2) update_start_screen()
    if (game.state == 2) update_game_screen()
end

function _draw()
	cls(4)
  	if (game.state == 1) draw_start_screen()
    if (game.state == 2) draw_game_screen()
    if (game.state == 3) draw_win_screen()
    if (game.state == 4) draw_lose_screen()
end

--
-- update functions
--
function update_start_screen()
  if (btnp(5)) then 
    game.state = 2
    game.run_time = 1000
    game.distance = 800
    bullets = {}
    terrain = {}
    bad_guys = {}
    predators = {}
    predator_plasma={}
    sprites = {}
    player.sprite = new_sprite(64,player.base,5,{1,2},1,0,0,6,4)
  end
end

function update_game_screen()
  if (game.distance == 0) game.state = 3
  if (game.run_time == 0) game.state = 4
  game.distance -=game.scroll
  game.run_time -=1
  foreach(bullets, update_bullet)
  foreach(terrain, scroll_terrain)
  foreach(bad_guys, scroll_bad_guy)
  foreach(predators, scroll_predator)
  foreach(predator_plasma, scroll_plasma)
  predator_shoot()
  knock_down_check()
  bullets_collide()
  player_collide()
  if (btn(0)) then 
    if (player.sprite.x>1) player.sprite.x-=1
  end
  if (btn(1)) then
    if (player.sprite.x<128) player.sprite.x+=1
  end
  if (btnp(5)) shoot_gun()

  add_random_terrain()
  add_random_bad_guy()
  add_random_predator()
end

function update_bullet(bullet)
  bullet.y-=3
  if (bullet.y <0) del(bullets,bullet)
end


function shoot_gun()
  bullet = new_sprite(player.sprite.x, player.sprite.y,1,{16, 16},1,0,0,1,2)
  add(bullets,bullet)
  log("shoot_gun "..count(bullets).."-"..bullet.x.."/"..bullet.y)
end

function add_random_terrain()
  type = flr(rnd(20)) + 50


  if (type >63 and type <70) then
    t = new_sprite(flr(rnd(128)),0,5,{type},1,0,0)
    add(terrain,t)
  end
end

function scroll_terrain(item)
  item.y+=game.scroll
  if (item.y >128) then 
    del(terrain,item)
    del(sprites,item)
  end
end

function scroll_plasma(item)
  item.y+=game.scroll+3
  if (item.y >128) then 
    del(predator_plasma,item)
    del(sprites,item)
  end
end

function add_random_bad_guy()
  type = flr(rnd(12))
  if (type == 1) then
    b = new_sprite(flr(rnd(128)),0,5,{3,4},1,0,0, 6, 4)
    add(bad_guys,b)
  end
end

function scroll_bad_guy(item)
  item.y+=game.scroll+1
  if (item.y >128) then 
    del(bad_guys,item)
    del(sprites,item)
  end
end

function add_random_predator()
  type = flr(rnd(40))
  if (type == 1) then
    p = new_sprite(flr(rnd(128)),0,5,{32,33},1,0,0, 8, 4)
    add(predators,p)
  end
end

function scroll_predator(item)
  item.y+=game.scroll+2
  if (item.y >128) then 
    del(predators,item)
    del(sprites,item)
  end
end

function bullets_collide()

  for _,bullet in pairs(bullets) do
    for _,bad_guy in pairs(bad_guys) do
       if (bullet != nil and bad_guy != nil) then
        if (collison(bullet, bad_guy)) then
          
          del(bad_guys,bad_guy)
          del(bullet,bullets)
          del(sprites,bad_guy)
          del(sprites,bullets)
          game.score +=10
        end
      end
    end
    for _,predator in pairs(predators) do
       if (bullet != nil and predator != nil) then
        if (collison(bullet, predator)) then
          
          del(predators,predator)
          del(bullet,bullets)
          del(sprites,predator)
          del(sprites,bullets)
          game.score +=100
        end
      end
    end
  end
  
end

function player_collide()
  for _,bad_guy in pairs(bad_guys) do
    if (player.sprite != nil and bad_guy != nil) then
      if (collison(player.sprite, bad_guy)) then          
          del(bad_guys,bad_guy)
          del(sprites,bad_guy)
          game.scroll = 0
          game.get_up_timer = 30
          del(sprites,player.sprite)
          player.sprite = new_sprite(player.sprite.x,player.base,5,{5,6},1,0,0,6,4)
        end
      end
    end
  for _,predator in pairs(predators) do
    if (player.sprite != nil and predator != nil) then
      if (collison(player.sprite, predator)) then          
          game.scroll = 0
          game.get_up_timer = 40
          del(sprites,player.sprite)
          player.sprite = new_sprite(player.sprite.x,player.base,3,{5,6},1,0,0,6,4)
        end
      end
    end

    for _,plasma in pairs(predator_plasma) do
    if (player.sprite != nil and plasma != nil) then
      if (collison(player.sprite, plasma)) then
          del(predator_plasma, plasma)
          del(sprites,plasma)          
          game.scroll = 0
          game.get_up_timer = 40
          del(sprites,player.sprite)
          player.sprite = new_sprite(player.sprite.x,player.base,3,{5,6},1,0,0,6,4)
        end
      end
    end

end

function knock_down_check()
 //is the player knocked down?
  if (game.get_up_timer>0) game.get_up_timer-=1
  if (game.get_up_timer == 1) then 
    game.scroll = 1
    del(sprites,player.sprite)
    player.sprite = new_sprite(player.sprite.x,player.base,5,{1,2},1,0,0,6,4)
  end 
end

function predator_shoot()
  for _,predator in pairs(predators) do
    if (predator != nil) then
      if (player.sprite.x > predator.x-2 and player.sprite.x < predator.x+8) then
        if (game.timer % 10 == 1) then
          p = new_sprite(predator.x+3,predator.y+5,100,{17},1,0,0,1,3)
          add(predator_plasma, p)
        end
      end
    end
  end
end

--
-- draw functions
--

function create_text()
  l1 = "get to the chopper"
  l2 = "press ❎ to start"
  l3 = "you got to the chopper"
  l4 = "booooom, you lose"
end

function draw_start_screen()

    print (l1, hcenter(l1),50,6)
    print (l2, hcenter(l2),60,6)
    draw_chopper(50,30)
end

function draw_game_screen()
  
  if (game.distance < 70) draw_chopper(50, 70-game.distance)

  foreach(sprites, sprite_draw)
  print("score "..game.score.." time "..game.run_time.." distance "..game.distance)
  
end

function draw_win_screen()
  print (l3, hcenter(l3),50,6)
  l5 = "with a score of "..game.score
  print(l5, hcenter(l5),60,6)
  draw_chopper(50,30)
  print (l2, hcenter(l2),70,6)
end

function draw_lose_screen()
  circfill(64,64,game.boom, 10)
  if (game.boom < 250) game.boom +=1
  print(l4, hcenter(l4),50,6) 
  l5 = "with a score of "..game.score
  print(l5, hcenter(l5),60,6)
  print (l2, hcenter(l2),70,6)
end

function draw_chopper(x,y)
  if (game.timer % 2 == 1) then 
    spr(71,x,y,4, 3) 
  else
    spr(75,x,y,4, 3)
  end
end


function hcenter(s)
  return 64-#s*2
end

--
-- sprite code
--
function new_sprite(x1, y1,tick, list, active, oneshot, move, width, height)
 s = {}
 s.x = x1
 s.y = y1
 s.w = width
 s.h = height
 s.list = list
 s.current = 1
 s.tick = tick -- change sprite frame every n refreshes (max 60)
 s.active = active -- is the sprite active?
 s.oneshot = oneshot -- does the sprite die 
 s.first_update = 1 -- marks the sprite as fresh
 s.move = move -- sprite moves
 add (sprites, s)
 return s
end


function sprite_draw(sprite)
  if (sprite.active == 1) then
    spr(sprite.list[sprite.current],sprite.x,sprite.y)

  end
end

function update_sprite(sprite)
  if (sprite.active ==1) then
    if (sprite.first_update !=1 
      and sprite.move == 1 ) then
    sprite.x -= game.dx*8
    sprite.y -= game.dy*8
    sprite.first_update = 0
  else
    sprite.first_update = 0
  end
 -- check to see if we're on a tick
 if (game.timer % sprite.tick == 1) then
  if (sprite.current < #sprite.list) then
    sprite.current+=1
  else
    sprite.current =1
    if (sprite.oneshot == 1) then
      del(sprites,sprite)
    end
  end
 end
end
end

function update_timer()
  game.timer+=1
  if (game.timer>60) then
    game.timer = 1
  end

end

function collison(s1, s2)
  local horizontal_collide = false
  local vertical_collide = false
  
  if (s1.x <s2.x+s2.w and 
      s1.x+s1.w > s2.x and 
      s1.y < s2.y+s2.h and
      s1.y+s1.h > s2.y) then 
        log("hit!")
        return true
    
  end
  return false
end

--
-- end of sprite code
--

function log(msg)
	printh(time()..":"..msg, "log.txt")
end



__gfx__
0000000000990000009900000bb00000000bb0000099000000880000000000000000000000000000000000000000000000000000000000000000000000000000
0000000003993f00f3993000fbbbb0000bbbbf000399300008888000000000000000000000000000000000000000000000000000000000000000000000000000
00700700f333300003333f000b55bf00fb55b000f3333f0088888800000000000000000000000000000000000000000000000000000000000000000000000000
00077000033000000003300000550000005500000033000000880000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dd00000000dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6dddddd00dddddd60dddddd600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dd22dd66dd22dd06dd22dd600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022c0660022c0060022c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000500000000000000000500000000000000000000000000000000000000000000000000000000000000
00000b30000000000300000000000000000003000000000000000000000000005500000000000000000000000000000000000000000000000000000000000000
33b0b30000000000000000b0000b0000050000000000000000000000000000005500000000000000000000000000000000000000000000000000000000000000
00333000003b00000000000000b30b00000000000000000000000000000000005500000000000000000000000050000000000050000000000000000000000000
000353b000030000000000000003b000000000000300000000000000000000005500000000000000000000000055000000000550000000000000000000000000
00b30030000000b300b8000000000000000000000000000000000000000000005500000000000000000000000005500000005500000000000000000000000000
00300030000000300003000000000000000000500000000000000000666669995599966600000005500000006666559999955666000000055000000000000000
0000000000000000000000000000000000000000000500000000000000dd999955999900000066655666000000dd955999559900000055566555000000000000
00000000000000000000000000000000000000000000000000000000555555555599999299999999900000000ddd995595599992999999999000000000000000
00000000000000000000000000000000000000000000000000000000055555555555555555999999999990000cdd999555999999999999999999900000000000
000000000000000000000000000000000000000000000000000000000ccd99995555555555599999900000000ccd999555599929999999999000000000000000
0000000000000000000000000000000000000000000000000000000000cc999955999900000000000000000000cc995599559900000000000000000000000000
00000000000000000000330000000000000000000000000000000000666669995599966600000000000000006666655999955666000000000000000000000000
00000000000000000000330000000000000000000000000000000000000000005500000000000000000000000000550000005500000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000005500000000000000000000000005500000000550000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000005500000000000000000000000055000000000055000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000005500000000000000000000000050000000000005000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000005500000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000005500000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000
__label__
46644664466466646664444466644444666466646664666444446664666466445444664466644664666466646644466466644444644464646664444444444444
64446444646464646444444464644444464446446664644444446464646446444444646446446444464464646464644464444444644464644464444444444444
66646444646466446644444464644444464446446464664544446664646446444444646446446664464466646464644466444444666466646664444444444444
44646444646464646444434464644444464446446464644444b36464646446444444646446444464464464646464644464444444646444636444444444444444
66444664664464646664444466644444464466646464666b4b346664666466644444666466646644464464646464466466644444666444646664bb4444444544
4444444444444444444444444444444444444b34b4444433334444444444b34b44444444b34b4444444444444444444444444444444444444444b3bb44444444
444444444444444444444444444444444444443b43444443353b4444444443b44444444443b4444444444444444444444444444444444444444443b444444444
4444444444444444444444b84444444444444444444b844b34b3444444444444444444444444444444444444444444444444444445444444b83444444b344444
44444444444444444444444344444444444444444444344344334444444444444444444444444444444444444444444444444444444433b4b344444443444444
44444444444444444444444444444444444444444445444444444444444444444444444444444444444444444444444444444444444444333444444444444444
444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444353b4444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444434444444444b34434444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444344434444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444544444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
444444444444444444444444444444444444444444444444444444444444444444444444444444b4444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444b34b44444444444444444444444444444444444444444444444
4444444444444444444444444444444444444444444444444444444444444444444444444444443b444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444443444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
444444444444444444444444444444444444444b4444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444b84444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444434444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444bb44444444444444444444444444444444444
444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444fbbbb444444444444444444444444444444444
4444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444b55bf44444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444554444444444444444444444444444444444
44444444bb4444444444444444444444444444444444444444444444444444444444444444444443444444444444444444444444444444444444444444444444
444444bbbbf4444444444444444444444444444444444444444444444444444444444444444444444444b4444444444444444444444444444444444444444444
44444fb55b44444444444444444444444444444444444444444444b3444444444444444444444444444444444444444444444444444444444444444444444444
444444455444444444444444444444444444444444444444433b4b34444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444433344444444444444444444444444b84444444444444444444444444444444444444444444444
4444444444444444444444444444444444444444444444444444353b444444444444444444444444434444444444444444444444444444444444444444444444
444444444444444444444444444444444444444444444444444b3443444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444434443444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4444444444444444444444444444444444444444444444444444444444444444444444444444444444444bb44444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444bbbbf4444444444444444444444444444444444444444
4444444444444444444444444444444444444444444444444444444444444444444444444444444444fb55b44444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444455444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444443
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4444444444444444b344444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4444444444433b4b3444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444443334444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444353b44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4444444444444b33b344444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444443443344443444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4444444444444444444b3444444b4444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444443444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444b8444444444444444444444444444444444444444444444444444444444443b444444444444444444444444444444444444444444
444443b4444444444444444434444444444444444444444444444444444444444444444444444444444443444444444444444444444444444444444444444444
4444443444444444444444444444444444444444444444444444444444444444444444444444444444444444b344444444444444444444444444444444444444
444444444b3444444444444444444444444444444444444444444444444444444444444444444444444444443444444444444444444444444444444444444444
44444444434444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444bb4444444444444444
444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444bbbbf444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444fb55b4444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444445544444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4444444444444444444bb44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
444444444444444444fbbbb444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4444444444444444444b55bf44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444554444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444b34444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444433b4b34444444444444444444bb44444444444444444444444444444444444444444444
4444444444444444444b344444444444444444444444444444444444444333444444444444444444bbbbf4444444444444444444444444444444444444444444
4444444444444433b4b34444444444444444444444444444444444444444353b444444444444444fb55b44444444444444444444444444444444444444444444
44444444444444443334444444444444444444444444444444444444444b34434444444444444444455444444444444444444444444444444444444444444444
44444444444444444353b44444444444444444444444444444444444444344434444444444444444444444444444444444444444444444444444444444444444
4444444444444444b344344444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444443444344444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444b444444444444444444444444
444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444b34b4444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444443b44444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444344444444444444444444444444444444444444444444444444444
4444444444444444444444444444444444444444444444444444444444444444444444444444444b444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444bb4444444444444444444444444444444444444444444
444444444444444444444444444444444444444444444444444444444444444444444444444444444bbbbf444444444444444444444444444444444444444444
444444444444444444444444444444444444444444444444454444444444444444444444444b8444fb55b4444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444443444445544444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444544444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4444444444444444444444444444444444444444444344444444444444444444444444444444444444444444444444444443b444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444499444444444444444444444444444444443444444444444444444444444444
4444444444444444444444444444444444444444444444444444444444444444f39934444444444444444444444444444444444b344444444444444444444444
443444444444444444444444444444444444444444444544444444444444444443333f4444444444444444444444444444444443444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444443344444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44445444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444443b444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444443444444444444444444444444
4444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444b344444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444443444444444444444444444
444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444bb444
444444444444444444444444444444444444444444444444444444444444444444444444444444444444444b344444444444444444444444444444444bbbbf44
444444444444444444444444444444444444444444444444444444444444444444444444444444444433b4b344444444444444444444444444444444fb55b444
44444444444444444444444444444444444444444444444443444444444444444444444444444444444433344444444444444444444444444444444444554444
444444444444444444444444444444444444444444444444444444b444444444444444444444444444444353b444444444444444444444444444444444444444

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
