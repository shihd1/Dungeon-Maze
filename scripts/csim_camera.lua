--[[
     
     

    -- Camera Program --
    Author: Darren Shih
     
]]

csim_camera = {}
csim_camera.x = 0
csim_camera.y = 0
csim_camera.scale_x = 1
csim_camera.scale_y = 1
csim_camera.rotation = 0

function csim_camera.setPosition(x, y)
  csim_camera.x = x or csim_camera.x
  csim_camera.y = y or csim_camera.y
  if (csim_camera.y<0) then
      csim_camera.y = 0
  end
  if (csim_camera.y>1024) then
      csim_camera.y = 1024
  end
  if (csim_camera.x<0) then
      csim_camera.x = 0
  end
  if (csim_camera.x>1774) then
      csim_camera.x = 1774
  end
end

function csim_camera.setRotation(r)
  csim_camera.rotation = r or csim_camera.rotation
end

function csim_camera.setScale(sx, sy)
  csim_camera.scale_x = sx or csim_camera.scale_x
  csim_camera.scale_y = sy or csim_camera.scale_y
end

function csim_camera.start()
    love.graphics.push()
    love.graphics.rotate(-csim_camera.rotation)
    love.graphics.scale(1 / csim_camera.scale_x, 1 / csim_camera.scale_y)
    love.graphics.translate(-csim_camera.x, -csim_camera.y)
end

function csim_camera.finish()
    love.graphics.pop()
end

return csim_camera
