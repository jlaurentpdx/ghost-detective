Player = Object.extend(Object)

function Player.new(self, x, y)
  self.x = x
  self.y = y
  self.size = 40  -- Size of the lens that reveals objects, 40 fits nicely with the current size of finderHandle, will change with art
  self.speed = 200  -- Movement speed
  self.image = love.graphics.newImage("assets/temp/finderHandle.png")
  self.origin_x = self.image:getWidth() / 2
  self.origin_y = self.image:getHeight() / 2
  self.offset_x = 50
  self.offset_y = 48
  self.isMoving = false
  self.visibility = true
  self.allowInvis = true
  self.timeSinceSpawn = 0
end

function Player:update(dt, roomWidth, roomHeight, playableArea)
  self.timeSinceSpawn = self.timeSinceSpawn + 1 * dt

  if love.keyboard.isDown('space') then
    self.visibility = false
  end

  if self.x <= roomWidth + playableArea.x and
    love.keyboard.isDown('right', 'd') then
      self.x = self.x + self.speed * dt
      isMoving = true
  end
  if self.x >= self.size + playableArea.x and
    love.keyboard.isDown('left', 'a') then
      self.x = self.x - self.speed * dt
      isMoving = true
  end
  if self.y <= roomHeight + playableArea.y and
    love.keyboard.isDown('down', 's') then
      self.y = self.y + self.speed * dt
      isMoving = true
  end
  if self.y >= self.size + playableArea.y and
    love.keyboard.isDown('up', 'w') then
      self.y = self.y - self.speed * dt
      isMoving = true
  end
  if not love.keyboard.isDown('up', 'down', 'left', 'right',
    'w', 'a', 's', 'd') then
    isMoving = false
  end

end

function Player:draw()
  if self.visibility == false then
    love.graphics.setColor(1, 1, 1, 0.5) -- Color for finderHandle
  else
    love.graphics.setColor(1, 1, 1, 1) -- Color for finderHandle
  end
  love.graphics.draw(self.image, self.x - self.offset_x, self.y - self.offset_y) -- Offset numbers that will change with new artwork for finderHandle
end
