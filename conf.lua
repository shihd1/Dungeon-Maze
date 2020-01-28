--[[
    CSIM 2018
    Lecture 6

    -- Game Conf. --
    Author: Lucas N. Ferreira
    lferreira@ucsc.edu
]]

function love.conf(t)
    t.title = "Lec7"	        	-- The title of the window the game is in (string)
    t.author = "Lucas N. Ferreira"	-- The author of the game (string)
    t.window.width = 1024			-- The window width (number)
    t.window.height = 768			-- The window height (number)
    t.window.fullscreen = false		-- Enable fullscreen (boolean)
    t.window.vsync = 1			    -- Enable vertical sync (boolean)
end
