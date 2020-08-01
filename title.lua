font_title = love.graphics.newFont("assets/fonts/Rockwell.TTF", 150)
font_button = love.graphics.newFont("assets/fonts/Rockwell.TTF", 30)
font_speech = love.graphics.newFont("assets/fonts/Rockwell.TTF", 26)
require("classes/button")

local cron = require("libs/cron")
local tween = require("libs/tween")

background = love.graphics.newImage("assets/backgrounds/bg_title.png")

title = {}
title.name = "ghost detective"
title.x = 50
title.y = -200
title.font = font_title

titleTween = tween.new(2, title, {y = 0}, 'outCubic')
--thisTween = tween.new(seconds, tablename, tweenTableItem, 'Tween style')

cursor = {}
cursor.x = 500
cursor.y = 350
cursor.angle = 0
cursor.scale = 1
cursor.image = love.graphics.newImage("assets/temp/finderHandleSmall.png")

posStart = cursor.y
posCredits = posStart + 70
posExit = posCredits + 70

function titleload()

  -- Main Menu audio
  bgm = love.audio.newSource("assets/music/main_theme.ogg", "static")
  bgmVolume = 0.5
  bgm:setLooping(true)
  bgm:setVolume(bgmVolume)
  if not bgm:isPlaying() then
    love.audio.play(bgm)
  end

  sfxNewGame = love.audio.newSource("assets/sfx/sfx_rim_tom.wav", "static")
  sfxNewGame:setVolume(0.4)
  sfxCredits = love.audio.newSource("assets/sfx/sfx_bass_longhigh_1.wav", "static")
  sfxCredits:setVolume(0.4)
  sfxCursorUp0 = love.audio.newSource("assets/sfx/sfx_bass_shorthigh_1.wav", "static")
  sfxCursorUp0:setVolume(0.2)
  sfxCursorUp1 = love.audio.newSource("assets/sfx/sfx_bass_shorthigh_1.wav", "static")
  sfxCursorUp1:setPitch(1.1)
  sfxCursorUp1:setVolume(0.15)
  sfxCursorDown0 = love.audio.newSource("assets/sfx/sfx_bass_shortlow_1.wav", "static")
  sfxCursorDown0:setVolume(0.2)
  sfxCursorDown1 = love.audio.newSource("assets/sfx/sfx_bass_shortlow_1.wav", "static")
  sfxCursorDown1:setPitch(1.1)
  sfxCursorDown1:setVolume(0.15)

  local moveClock
  allowMove = true
  titleFader = 0
  titleFaderState = false

  fadeTween = {5, titleFader, 1.0, 'linear'}

  if clear_level1 and not clear_level2 then
    buttonStart = Button(550, posStart - 10, "Continue", font_button)
  else
    buttonStart = Button(550, posStart - 10, "New Game", font_button)
  end

  buttonCredits = Button(550, posCredits - 10, "Credits", font_button)
  buttonExit = Button(550, posExit - 10, "Exit", font_button)
end

function titledraw()
  love.graphics.setBackgroundColor(0.2, 0.2, 0.2)
  love.graphics.setColor(1,1,1)
  love.graphics.draw(background, 0, 0, 0, 0.25, 0.25)
  love.graphics.setFont(font_title)
  love.graphics.printf(title.name, title.x, title.y, 450)

  buttonStart:draw()
  buttonCredits:draw()
  buttonExit:draw()
  love.graphics.print(version, 700, 550)
  love.graphics.printf("press SPACE to start", 0, 550, 800, "center")

  love.graphics.draw(cursor.image, cursor.x, cursor.y, cursor.angle, cursor.scale, cursor.scale, cursor.origin_x)
  love.graphics.setColor(0,0,0,titleFader)
  love.graphics.rectangle("fill", 0, 0, 800, 600)
end

function titleupdate(dt)

  titleTween:update(dt)

  if moveClock then moveClock:update(dt) end

  if love.keyboard.isDown('down','s') and cursor.y < posExit and allowMove then
    if sfxCursorDown0:isPlaying() then
      sfxCursorDown1:play()
    else sfxCursorDown0:play() end
    cursor.y = cursor.y + 70
    allowMoveTimer()
  end
  if love.keyboard.isDown('up','w') and cursor.y > posStart and allowMove then
    if sfxCursorUp0:isPlaying() then
      sfxCursorUp1:play()
    else sfxCursorUp0:play() end
    cursor.y = cursor.y - 70
    allowMoveTimer()
  end

  if love.keyboard.isDown('space') and cursor.y == posStart then
    love.audio.play(sfxNewGame)
    titleFaderState = true
  elseif love.keyboard.isDown('space') and cursor.y == posCredits then
    love.audio.play(sfxCredits)
    scene="credits"
  elseif love.keyboard.isDown('space') and cursor.y == posExit then
    love.event.quit(0)
  end

  if titleFaderState then
    titleFader = titleFader + 1 * dt
    bgmVolume = bgmVolume - 2 * dt
    bgm:setVolume(bgmVolume)
    if titleFader >= 1 and clear_level1 then
      bgm:stop()
      scene="level-2"
    elseif titleFader >= 1 then
      bgm:stop()
      scene="level-1"
    end
  end
end

function allowMoveTimer()
  if allowMove then
    allowMove = false
  end
  moveClock = cron.after(0.3, function() allowMove = true end)
end
