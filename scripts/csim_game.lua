--[[
     
     

    -- Game Program --
    Author: Darren Shih
     
]]

-- Loading external libraries
local sti = require "lib.sti"

-- Loading game objects
local csim_object = require "scripts.objects.csim_object"
local csim_player = require "scripts.objects.csim_player"
local csim_enemy = require "scripts.objects.csim_enemy"

-- Loading internal libraries
local csim_math = require "scripts.csim_math"
local csim_vector = require "scripts.csim_vector"

-- Loading components
local csim_rigidbody = require "scripts.components.csim_rigidbody"
local csim_collider = require "scripts.components.csim_collider"
local csim_fsm = require "scripts.components.csim_fsm"

local csim_game = {}

function csim_game.load()
	-- Load map
	map = sti("map/MAP4.lua")

	-- Load characters
	player, enemies = csim_game.loadCharacters()

	for i=1,#enemies do
		-- Adding collider to enemies
		local enemy_collider = csim_collider:new(map, enemies[i].rect)
		enemies[i]:addComponent(enemy_collider)

		-- Adding rigidbody to enemies
		local enemy_rigid_body = csim_rigidbody:new(1, 1, 12)
		enemies[i]:addComponent(enemy_rigid_body)

		-- Adding fsms to enemies
		local states = {}
		states["move"] = csim_fsm:newState("move", enemies[i].update_move_state, enemies[i].enter_move_state, enemies[i].exit_move_state)
		states["idle"] = csim_fsm:newState("idle", enemies[i].update_idle_state, enemies[i].enter_idle_state, enemies[i].exit_idle_state)
		states["chase"] = csim_fsm:newState("chase", enemies[i].update_chase_state, enemies[i].enter_chase_state, enemies[i].exit_chase_state)
		states["freeze"] = csim_fsm:newState("freeze", enemies[i].update_freeze_state, enemies[i].enter_freeze_state, enemies[i].exit_freeze_state)

		local enemy_fsm = csim_fsm:new(states, "move", csim_enemy)
		enemies[i]:addComponent(enemy_fsm)
	end

	-- Load items
	items = {}
	items = csim_game.loadItems()

	-- Create rigid body
	local player_rigid_body = csim_rigidbody:new(1, 0.1, 0.1)
	player:addComponent(player_rigid_body)

	-- Create collider
	local player_collider = csim_collider:new(map, player.rect)
	player:addComponent(player_collider)

	-- Load step sound
	sounds = {}
	sounds["step"]=love.audio.newSource("sounds/lec2-step.wav", "static")
	sounds["coin"]=love.audio.newSource("sounds/lec2-coin.wav", "static")
	sounds['track1']=love.audio.newSource('sounds/gamemusic.wav', 'static')

	-- Play soundtrack in loop
	sounds['track1']:setLooping(true)
	sounds['track1']:play()

	timeleft = 121

end

function csim_game.loadCharacters()
	local player = nil
	local enemies = {}

	local width = map.layers["Characters"].width
	local height = map.layers["Characters"].height
	local map_data = map.layers["Characters"].data

	for x=1,width do
		for y=1,height do
			if map_data[y] and map_data[y][x] then
				local spr = love.graphics.newImage(map_data[y][x].properties["sprite"])
				screen_x, screen_y = map:convertTileToPixel(y - 1, x - 1)

				if(map_data[y][x].properties["isPlayer"]) then
					player = csim_player:new(screen_y, screen_x, 0, spr)
					player.rect = {}
					player.rect.x = 2
					player.rect.y = 2
					player.rect.w = 12
					player.rect.h = 12
				else
					enemy = csim_object:new(screen_y, screen_x, 0, spr)

					enemy.rect = {}
					enemy.rect.x = map_data[y][x].properties["x"]
					enemy.rect.y = map_data[y][x].properties["y"]
					enemy.rect.w = map_data[y][x].properties["w"]
					enemy.rect.h = map_data[y][x].properties["h"]

					table.insert(enemies, enemy)
				end
			end
		end
	end

	map:removeLayer("Characters")
	return player, enemies
end

function csim_game.loadItems()
	local items = {}

	if(not map.layers["Items"]) then return items end

	local width = map.layers["Items"].width
	local height = map.layers["Items"].height
	local map_data = map.layers["Items"].data

	for x=1,width do
		for y=1,height do
			if map_data[y] and map_data[y][x] then
				local spr = love.graphics.newImage(map_data[y][x].properties["sprite"])
				screen_x, screen_y = map:convertTileToPixel(y - 1, x - 1)

				local item = csim_object:new(screen_y, screen_x, 0, spr)

				table.insert(items, item)
			end
		end
	end

	return items
end

function csim_game.detectDynamicCollision(dynamic_objs, obj_type)
	-- TODO: Check AABB collision against all dynamic objs
	-- Hint: Use a for loop and create boxes for the player and the items.
	-- csim_math.checkBoxCollision(min_a, max_a, min_b, max_b)
	local player_collider = player:getComponent("collider")
	if (not player_collider) then return end

	min_a, max_a = player_collider:createAABB()

	csim_debug.rect(min_a.x, min_a.y, player_collider.rect.w, player_collider.rect.h)

	for i=1,#dynamic_objs do
		local dynamic_collider = dynamic_objs[i]:getComponent("collider")
		if (dynamic_collider) then
			if(dynamic_objs[i] ~= nil) then
				min_b, max_b = dynamic_collider:createAABB()

				csim_debug.rect(min_b.x, min_b.y, dynamic_collider.rect.w, dynamic_collider.rect.h)

				if(csim_math.checkBoxCollision(min_a, max_a, min_b, max_b)) then
					if(obj_type == "enemies") then
							love.load()
					end
					if(obj_type == "items") then

					end
				end
			end
		end
	end
	for i=1,#items do
    --local frag_collider = items[i]:getComponent("collider")
  	local min_b2 = csim_vector:new(items[i].pos.x, items[i].pos.y)
    local max_b2 = csim_vector:new(items[i].pos.x + 16, items[i].pos.y + 16)
    csim_debug.rect(min_b2.x, min_b2.y, 16, 16)
    if(csim_math.checkBoxCollision(min_a, max_a, min_b2, max_b2)) then
      csim_debug.text("collisionwithitem")
			enemy:getComponent("fsm"):changeState("freeze")
		end
	end
end

function csim_game.update(dt)
		-- Move on x axis
		if (love.keyboard.isDown('left')) then
			player:move_x(-2)
			player.spr = love.graphics.newImage("sprites/GreenLeftBoy.png")
			love.audio.play(sounds["step"])
		elseif(love.keyboard.isDown('right')) then
			player:move_x(2)
			player.spr = love.graphics.newImage("sprites/GreenRightBoy.png")
			love.audio.play(sounds["step"])
		end

		-- Move on y axis
		if (love.keyboard.isDown('up')) then
			player:move_y(-2)
			player.spr = love.graphics.newImage("sprites/GreenBackBoy.png")
			love.audio.play(sounds["step"])
		elseif(love.keyboard.isDown('down')) then
			player:move_y(2)
			player.spr = love.graphics.newImage("sprites/GreenFrontBoy.png")
			love.audio.play(sounds["step"])
		end
	player:update(dt)

	local player_rigid_body = player:getComponent("rigidbody")

	-- TODO: Apply friction
	player_rigid_body:applyFriction(0.09)

	-- TODO: Clamp acceleration
	player_rigid_body.vel.x = csim_math.clamp(player_rigid_body.vel.x, -5, 5)
	player_rigid_body.vel.y = csim_math.clamp(player_rigid_body.vel.y, -5, 5)

	if (player.pos.y < 112 and player.pos.x < 112) then
		love.window.showMessageBox("Congragulations", "You Won!", "info", true)
		love.load()
	end

	for i=1,#enemies do
		if(enemies[i] ~= nil) then
			enemies[i]:update(dt)
			local enemy_colllider = enemies[i]:getComponent("collider")
			local enemy_pos = csim_vector:new(enemies[i].pos.x + enemy_colllider.rect.w/2, enemies[i].pos.y + enemy_colllider.rect.h/2)
			local x,y = csim_collider:worldToMapPos(enemy_pos)
			print("x="..x.." y="..y)
			if(enemies[i]:getComponent("collider"):detectTrap(x, y)) then
				table.remove(enemies, i)
			end
		end
	end

	-- Detect collision against dynamic objects
	csim_game.detectDynamicCollision(items, "item")
	csim_game.detectDynamicCollision(enemies, "enemies")

	csim_camera.setPosition(player.pos.x - csim_game.game_width/2, player.pos.y - csim_game.game_height/2)
	-- Camera is following the player
	-- for y_room=0,7 do
	-- 	for x_room=0,10 do
	-- 			if ((player.pos.x > x_room * 208 and player.pos.x < (x_room + 1) * 208) and (player.pos.y > y_room * 208 and player.pos.y < (y_room + 1) * 208)) then
	-- 				csim_camera.setPosition(x_room * 208, y_room * 208)
	-- 			end
	-- 	end
	-- end

	-- Set background color
	love.graphics.setBackgroundColor(map.backgroundcolor[1]/255,
		map.backgroundcolor[2]/255, map.backgroundcolor[3]/255)
end

function csim_game.text(text, textx, texty)
	local dt = love.timer.getDelta()
 	timeleft = timeleft - (dt)

	if (timeleft<0) then
		love.window.showMessageBox("Time's Up", "You Lose", "info", true)
		csim_game.load()
	end

	text = math.floor(timeleft)
	textx = player.pos.x - csim_game.game_width/2
	texty = player.pos.y - csim_game.game_height/2
	if (texty<0) then
	  texty = 0
	end
	if (texty>1024) then
	  texty = 1024
	end
	if (textx<0) then
	  textx = 0
	end
	if (textx>1774) then
	  textx = 1774
	end
	love.graphics.print(text, textx, texty)
end

function csim_game.draw()
	-- Draw map
	map:draw(-csim_camera.x, -csim_camera.y)
	csim_game.text()
	-- Draw items
	for i=1,#items do
		love.graphics.draw(items[i].spr, items[i].pos.x, items[i].pos.y)
	end

	-- Draw enemies
	for i=1,#enemies do
		love.graphics.draw(enemies[i].spr, enemies[i].pos.x, enemies[i].pos.y)
	end

	-- Draw the player sprite
		love.graphics.draw(player.spr, player.pos.x, player.pos.y)
end

return csim_game
