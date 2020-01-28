--[[
    CSIM 2018
    Lecture 8

    -- Player Program --
    Author: Lucas N. Ferreira
    lferreira@ucsc.edu
]]

local csim_enemy = require "scripts.objects.csim_object"
local csim_vector = require "scripts.csim_vector"

-- FUNCTION OF THE IDLE STATE
function csim_enemy.enter_idle_state(state, enemy)
    enemy:getComponent("rigidbody").vel.x = 0
end

function csim_enemy.exit_idle_state(state, enemy)
end

function csim_enemy.update_idle_state(dt, state, enemy)
    -- csim_debug.text("I am idle!")
    state.timer = state.timer + dt
    if(state.timer > 1) then
        enemy:getComponent("fsm"):changeState("move")
        enemy.direction_x = enemy.direction_x * -1
        state.timer = 0
    end
    if(csim_math.distance(player.pos, enemy.pos)<50) then
        enemy:getComponent("fsm"):changeState("chase")
    end
end

-- FUNCTION OF THE MOVE STATE
function csim_enemy.enter_move_state(state, enemy)
    -- csim_debug.text("go brazil! 2 x 1")
    if(enemy.direction_x == nil) then
        enemy.direction_x = 1
    end
end

function csim_enemy.exit_move_state(state, enemy)
end
function csim_enemy.update_move_state(dt, state, enemy)
    -- TODO: Move enemy to its current direction and flip it after 1 second
    -- csim_debug.text("bla bla bla")
    enemy:getComponent("rigidbody"):applyForce(csim_vector:new(0.1 * enemy.direction_x ,0))
    state.timer = state.timer + dt
    print("timer= "..state.timer)
    if(state.timer > 0.5) then
        enemy:getComponent("fsm"):changeState("idle")
        state.timer = 0
    end
    if(csim_math.distance(player.pos, enemy.pos)<50) then
        enemy:getComponent("fsm"):changeState("chase")
    end
end

-- FUNCTION OF THE CHASE STATE
function csim_enemy.enter_chase_state(state, enemy)
  csim_debug.text("enterchase")
end

function csim_enemy.exit_chase_state(state, enemy)
end
function csim_enemy.update_chase_state(dt, state, enemy)
    if (player.pos.x > enemy.pos.x)then
      enemy:getComponent("rigidbody"):applyForce(csim_vector:new(0.1,0))
    end
    if (player.pos.x < enemy.pos.x)then
      enemy:getComponent("rigidbody"):applyForce(csim_vector:new(-0.1,0))
    end
    if (player.pos.y > enemy.pos.y)then
      enemy:getComponent("rigidbody"):applyForce(csim_vector:new(0,0.1))
    end
    if (player.pos.y < enemy.pos.y)then
      enemy:getComponent("rigidbody"):applyForce(csim_vector:new(0,-0.1))
    end
end

-- FUNCTION OF THE FREEZE STATE
function csim_enemy.enter_freeze_state(state, enemy)
end
function csim_enemy.exit_freeze_state(state, enemy)
end
function csim_enemy.update_freeze_state(dt, state, enemy)
    csim_debug.text("updatefreeze")
    if(csim_math.distance(player.pos, enemy.pos)<1000) then
      enemy:getComponent("rigidbody").vel.x = 0
      enemy:getComponent("rigidbody").vel.y = 0
      csim_debug.text("withindistance")
    end
end

return csim_enemy
