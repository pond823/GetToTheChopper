pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--get to the chopper
--by sasha bilton

-- global variables

game = {}
game.state = 1
game.timer = 1
sprites = {}

function _init()

end

function _update()
    update_timer()
    foreach(sprites, update_sprite)
  	if (game.state == 1) update_start_screen()
    if (game.state == 2) update_game_screen()
end

function _draw()
	cls()
  	if (game.state == 1) draw_start_screen()
    if (game.state == 2) draw_game_screen()
end

--
-- update functions
--
function update_start_screen()
if (btnp(5)) game.state = 2
end

function update_game_screen()
end

--
-- draw functions
--
function draw_start_screen()
    print ("get to the chopper", 0,10)
    print ("press ❎ to start", 0,20)
end
function draw_game_screen()
print ("get ready", 0,10)
end

--
-- sprite code
--
function new_sprite(x1, y1,tick, list, active, oneshot, move)
 s = {}
 s.x = x1
 s.y = y1
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

--
-- end of sprite code
--
