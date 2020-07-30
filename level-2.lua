require("classes/enemy")
require("classes/clue")
require("classes/player")

local letters = {"F", "A", "C", "E"}
local numOfClues = #letters

local bgColor = {0.15, 0.15, 0.15, 0}
local speechBubble = love.graphics.newImage("assets/temp/speechBubbleTemp.png")

-- Audio and SFX
local levelClear = love.audio.newSource("assets/music/level_clear.wav", "static")
local gameOver = love.audio.newSource("assets/music/game_over.wav", "static")
gameOver:setVolume(0.3)

local letterChime = {}
for i = 1,numOfClues do
  table.insert(letterChime, love.audio.newSource("assets/sfx/letter_clues/marim_"..letters[i]..".wav", "static"))
  letterChime[i]:setVolume(0.3)
  --letterChime[i].played = false
end

local ghostVoice = {}
for i = 0,4 do
  table.insert(ghostVoice, love.audio.newSource("assets/sfx/hmm"..i..".wav", "static"))
end

local bgLevel2 = love.graphics.newImage("assets/backgrounds/bg_level2.png")
-- Condition variables for all prompts
local timeElapsed = 0
local win = false
local busted
local restart = false

---------------------------------
-- Loaded variables on restart
---------------------------------

function level2load()

  busted = false

  -- Playable area container
  playableArea = {}
  playableArea.x = 250
  playableArea.y = 20
  playableArea.border = 20
  playableArea.size_x = love.graphics.getWidth() - playableArea.x - playableArea.border
  playableArea.size_y = love.graphics.getHeight() - playableArea.y - playableArea.border

  -- Start position for player
  local playerStartPosition = {}  -- player is the main controller component that reveals hidden "clues" within the background layer
  playerStartPosition.x = (love.graphics.getWidth() / 2) + (playableArea.x / 2)
  playerStartPosition.y = (love.graphics.getHeight() / 2) + (playableArea.y / 2)

  ghostAnim = newAnimation(love.graphics.newImage("assets/ghost_detective/idleAnim.png"), 250, 250, 4)
  winStamp = newAnimation(love.graphics.newImage("assets/ghost_detective/winStamp.png"), 250, 250, 4)
  loseStamp = newAnimation(love.graphics.newImage("assets/ghost_detective/loseStamp.png"), 250, 250, 4)
  angryAnim = newAnimation(love.graphics.newImage("assets/enemies/angryAnim.png"), 250, 250, 1)

  anims = {ghostAnim, winStamp, loseStamp, angryAnim}

  player = Player(playerStartPosition.x, playerStartPosition.y) -- Instantiate player
  enemy1 = Enemy(false, false, 300, 200, 50)   -- Instantiate enemies for this level
  enemy2 = Enemy(false, false, 600, 100, 50)

  -- Instantiate clues for this level
  clueColor = {}
  for i = 1,#letters do
    table.insert(clueColor, 0.3)
  end
  clue1 = Clue(false, true, 350, 550, letters[1])
  clue2 = Clue(false, false, 600, 100, letters[2])
  clue3 = Clue(false, false, 400, 400, letters[3])
  clue4 = Clue(false, false, 300, 200, letters[4])
  clues = {clue1, clue2, clue3, clue4}

  -- Bounding box for keeping the player in the playable area
  roomWidth = playableArea.size_x - player.size
  roomHeight = playableArea.size_y - player.size

  -- Clocks for each level
  local speakClock
  allowSpeak = true
  levelFader = 0
  local sceneClock
  allowChange = false
  local invisClock
  allowInvis = true
  local duration
  visible = true

  -- Unsorted set conditions
  love.graphics.newFont(35)
  love.graphics.setBackgroundColor(0.2, 0.2, 0.2, 0.4)

  -- NOTE: Clue randomizer for later:
  -- math.random(playableArea.x + player.size, playableArea.size_x)
  -- math.random(playableArea.y + player.size, playableArea.size_y)
end

---------------------------------
-- Early functions (dependencies)
---------------------------------

function playerStencil()
   -- Stencil function that is used to reveal hidden "clue" layer
   love.graphics.setColor(1, 1, 1)
   love.graphics.circle("fill", player.x, player.y, player.size)
end

---------------------------------
-- Update
---------------------------------

function level2update(dt)

  timeElapsed = timeElapsed + 1 * dt

  if not love.graphics.setFont(font_speech) then
    love.graphics.setFont(font_speech)
  end

  if speakClock then speakClock:update(dt) end
  if sceneClock then sceneClock:update(dt) end
  if invisClock then invisClock:update(dt) end
  if duration then duration:update(dt) end

  for i = 1,#anims do
    anims[i].currentTime = anims[i].currentTime + dt
    if anims[i].currentTime >= anims[i].duration then
      anims[i].currentTime = anims[i].currentTime - anims[i].duration
    end
  end

  ------------------

  -- Player controller using arrow keys or WASD
  if busted == false and (timeElapsed > 65 or restart) and player.visibility then
    player:update(dt, roomWidth,roomHeight,playableArea)
  end

  -- Invisibility updater
  if love.keyboard.isDown('space') and allowInvis and timeElapsed > 10 and not busted then
    player.visibility = false
    invisDuration()
    invisibilityTimer()
  elseif visible then
    player.visibility = true
  end

  -- Enemy AI controller
  if ((restart and timeElapsed > 0) or timeElapsed >= 70) and not win then
    enemy1.draw_state = true
    allowInvis = true
    enemy1.update_state = true
    enemy1:update(player, visible, dt)
  end
  if clue3.update_state and not win then
    enemySpeed = 100
    enemy2.draw_state = true
    enemy2.update_state = true
    enemy2:update(player, visible, dt)
  end

  -- Clue handler
  for i = 1,numOfClues do
    if clues[i].update_state and i < #letters then
      clues[i+1]:update(clueColor[i+1], dt)
    end
    if clues[i].draw_state then
      clues[i]:update(clueColor[i], dt)
      if distanceBetween(clues[i].x, clues[i].y, player.x, player.y) < clues[i].size then
        clueColor[i] = clueColor[i] + (0.3 * dt)
        if love.audio.getActiveSourceCount() < 2 and clues[i].update_state == false and allowSpeak and clueColor[i] < 0.9 then
          ghostVoice[math.floor(math.random(1,4))]:play()
          speakTimer()
        end
        if clueColor[i] >= 1 and clues[i].update_state == false then
          love.audio.play(letterChime[i])
          clues[i].update_state = true
        end
      end
    end
  end

  --  Win condition controller
  if clues[numOfClues].update_state then
    win = true
    levelFader = levelFader + 1 * dt
    if levelFader >= 1 then
      bgm:stop()
      levelClear:play()
      clear_level2 = true
      love.timer.sleep(4)
      love.load()
    end
  end

  -- Loss condition controller
  if not bgm:isPlaying() and not busted then
    bgm = love.audio.newSource("assets/music/bgm_level2.ogg", "static")
    bgm:setVolume(0.5)
    bgm:play()
  elseif busted then
    love.audio.play(gameOver)
    while bgmVolume > 0.0 do
      bgmVolume = bgmVolume - 2.0 * dt
      bgm:setVolume(bgmVolume)
    end
    levelFader = levelFader + 1 * dt
    if levelFader >= 1 then
      bgm:stop()
      love.timer.sleep(2.5)
      love.load()
    end
  end

  -- Escape key back to main menu
  if love.keyboard.isDown('escape') then
    bgm:stop()
    love.timer.sleep(1)
    love.load()
  end
end

---------------------------------
-- Draw
---------------------------------

-- Order of drawing: background, invisible clue layer,

function level2draw()
   -- Each pixel touched by the circle will have its stencil value set to 1. The rest will be 0.
   love.graphics.stencil(playerStencil, "replace", 1)

   -- Background layer
   love.graphics.draw(bgLevel2, -400, -250, 0, 0.24, 0.24)
   love.graphics.setColor(0, 0, 0, 0.5) -- Darken background with transparent layer
   love.graphics.rectangle("fill", 0, 0, 800, 600)

   -- Draw playable area rectangle layers
   love.graphics.setColor(0.5, 0.5, 0.5)
   love.graphics.rectangle("line", playableArea.x, playableArea.y,
      playableArea.size_x, playableArea.size_y)
   love.graphics.setColor(0.15, 0.15, 0.15, 0.5)
   love.graphics.rectangle("fill", playableArea.x, playableArea.y,
      playableArea.size_x, playableArea.size_y)

   -- Speech handler for this level
   love.graphics.setColor(1,1,1)
   -- Clue 1:
   if clues[1].update_state == false and (timeElapsed > 70 or restart) then
     drawText("Oh no! More ghosts... rookie! Let's find the clues around here and get a move on!")
   elseif clues[1].update_state == false and timeElapsed > 65 and not restart then
     drawText("It's why I became a detective! \n \nDo you think, maybe...?")
   elseif clues[1].update_state == false and timeElapsed > 60 and not restart then
     drawText("I've been searching for the clues to how I... you know... became a ghost.")
   elseif clues[1].update_state == false and timeElapsed > 55 and not restart then
     drawText("But I've been wondering for some time now... how did I get here?")
   elseif clues[1].update_state == false and timeElapsed > 50 and not restart then
     drawText("That's a very silly note.")
   elseif clues[1].update_state == false and timeElapsed > 49 and not restart then
     drawText("...")
   elseif clues[1].update_state == false and timeElapsed > 45 and not restart then
     drawText("'Ehehe... Ghost Buddy is Done For!' ...? EGBDF...")
   elseif clues[1].update_state == false and timeElapsed > 40 and not restart then
     drawText("Oh? You found a note with one of the clues back there? What does it say?")
   elseif clues[1].update_state == false and timeElapsed > 35 and not restart then
     drawText("...you don't think that's it? Hm... it does seem awfully irrelevant...")
   elseif clues[1].update_state == false and timeElapsed > 30 and not restart then
     drawText("It's a headline I read one time. I can't believe I remembered that one.")
   elseif clues[1].update_state == false and timeElapsed > 25 and not restart then
     drawText("Egg-buh- Aha! \n \nEndearing Gladiator Buys Dog Food! Of course!")
   elseif clues[1].update_state == false and timeElapsed > 20 and not restart then
     drawText("EGBDF... egg-bi-duf. Hmm...")
   elseif clues[1].update_state == false and timeElapsed > 15 and not restart then
     drawText("I hear it's called 'in too witchin.' It's how I find all my clues! Not all ghosts have it. Now...")
   elseif clues[1].update_state == false and timeElapsed > 8 and not restart then
     drawText("This is another spot I'm suspicious of. I'm not sure why, but something tells me there are clues here.")
   elseif clues[1].update_state == false and timeElapsed > 3 and not restart and clueColor[1] <= 0.3 then
     drawText("Nice work, rookie! What a clue... I wonder what it means? And way to escape that unfriendly ghost!")
   -- Clue 2
   elseif clues[2].update_state == false and timeElapsed > 10 and clueColor[2] > 0.3 then
     drawText("Another clue! Let's get a closer look at that.")
   elseif clues[2].update_state == false and timeElapsed > 10 and clueColor[2] <= 0.3 then
     drawText("'F...'' Okay, there must be more.")
   -- Clue 3
   elseif clues[3].update_state == false and timeElapsed > 10 and clueColor[3] > 0.3 then
     drawText("Wait! Another clue! Oh thank goodness.")
   elseif clues[3].update_state == false and timeElapsed > 10 and clueColor[3] <= 0.3 then
     drawText("'FA.' FAulty brakes? FAther? Oh no...'")
   -- Clue 4
   elseif clues[4].update_state == false and timeElapsed > 10 and clueColor[4] > 0.3 then
     drawText("I think that's the last one - let's hurry up and get outta' here!")
   elseif clues[4].update_state == false and timeElapsed > 10 and clueColor[4] <= 0.3 then
     drawText("My FACulties tell me we're onto something good here.")
   end

   -- Draw Ghost
   love.graphics.setColor(1, 1, 1)
   local spriteNum0 = math.floor(ghostAnim.currentTime / ghostAnim.duration * #ghostAnim.quads) + 1
   love.graphics.draw(ghostAnim.spriteSheet, ghostAnim.quads[spriteNum0], 0, 290, 0, 1)

   -- Draw Clues for this level
   for i = 1,#clues do
     if clues[i].draw_state then
       clues[i]:draw(clueColor[i], bgColor, letters[i])
       if clueColor[i] >= 1 and i < (#letters) then
         clues[i+1].draw_state = true
       end
     end
   end

   -- Draws player and sets stencil
   love.graphics.setStencilTest()
   player:draw()

   -- Draw enemies for this level
   love.graphics.setColor(1, 1, 1, 1)
   if ((restart and timeElapsed > 0) or timeElapsed > 70) then
     enemy1:draw(angryAnim)
   end
   if enemy2.draw_state then
     enemy1.speed = 100
     enemy2:draw(angryAnim)
   end

   -- Level fader / black curtain
   love.graphics.setColor(0,0,0,levelFader)
   love.graphics.rectangle("fill", 0, 0, 800, 600)

  -- Win condition controller
  if win then
    love.graphics.setColor(1,1,1)
    local spriteNum1 = math.floor(
      winStamp.currentTime / winStamp.duration *
      #winStamp.quads) + 1
    love.graphics.draw(
      winStamp.spriteSheet, winStamp.quads[spriteNum1],
      love.graphics.getWidth() / 2 - 125,
      love.graphics.getHeight() / 2 - 125, 0, 1)
  end

  -- Loss condition controller
  if player.visibility and distanceBetween(enemy1.x, enemy1.y, player.x, player.y) <
    enemy1.size and enemy1.draw_state and win == false then
      love.graphics.setColor(1,1,1)
      local spriteNum1 = math.floor(
        loseStamp.currentTime / loseStamp.duration *
        #loseStamp.quads) + 1
      love.graphics.draw(
        loseStamp.spriteSheet, loseStamp.quads[spriteNum1],
        love.graphics.getWidth() / 2 - 125,
        love.graphics.getHeight() / 2 - 125, 0, 1)
      busted = true
      restart = true
  end
end

---------------------------------
-- Other functions
---------------------------------

function distanceBetween (x1, y1, x2, y2)
	-- distance formula: d = √(y2 - y1)^2 + (x2 - x1)^2
	return math.sqrt((y2-y1)^2 + (x2-x1)^2)
end

function drawText(text)
  love.graphics.draw(speechBubble, 17, 100)
  love.graphics.setColor(0.3, 0.3, 0.3)
  love.graphics.printf(text, 30, 120, 200, "left")
end

-- Animation controller
function newAnimation(image, width, height, duration)
  local animation = {}
  animation.spriteSheet = image;
  animation.quads = {};

  for y = 0, image:getHeight() - height, height do
    for x = 0, image:getWidth() - width, width do
      table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
    end
  end

  animation.duration = duration or 1
  animation.currentTime = 0

  return animation
end

function speakTimer()
  if allowSpeak then
    allowSpeak = false
  end
  speakClock = cron.after(3, function() allowSpeak = true end)
end

function sceneTimer()
  if allowChange then
    allowChange = false
  end
  sceneClock = cron.after(1, function() allowChange = true end)
end

function invisibilityTimer()
  if allowInvis then
    allowInvis = false
  end
  invisClock = cron.after(10, function() allowInvis = true end)
end

function invisDuration()
  if visible then
    visible = false
  end
  duration = cron.after(2, function() visible = true end)
end
