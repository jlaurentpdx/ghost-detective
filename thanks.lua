local cron = require("libs/cron")
local tween = require("libs/tween")

ssj_logo = love.graphics.newImage("assets/temp/ssj_logo.png")

function thanksload()
  fadeIn = 1

  love.graphics.setFont(font_button)

end

function thanksdraw()
  love.graphics.setBackgroundColor(0, 0, 0)
  love.graphics.setColor(1,1,1)
  love.graphics.printf("To be continued... \n\nThanks for playing!",
    love.graphics.getWidth() / 2 - 100,
    love.graphics.getHeight() / 2 - 90, 200, 'left')

  love.graphics.draw(ssj_logo, 0, 450, 0, 0.4, 0.4)
  love.graphics.setColor(0, 0, 0, fadeIn)
  love.graphics.rectangle("fill", 0, 0, 800, 600)
end

function thanksupdate(dt)

  if bgm:isPlaying() then
    bgm:stop()
  end
  
  if fadeIn > 0 then
    fadeIn = fadeIn - 1 * dt
  end

  if love.keyboard.isDown('space') and fadeIn <= 0 then
    clear_level1 = false
    clear_level2 = false
    love.load()
  end
end
