Object = require("libs/classic")
tween = require("libs/tween")
cron = require("libs/cron")

require("title")
require("credits")
require("level-1")
require("level-2")
require("thanks")

math.randomseed(os.time())

clear_level1 = false
clear_level2 = false

function love.load()
    if clear_level1 and not clear_level2 then
      level2load()
      titleload()
      scene = "title"
    elseif clear_level2 then
      thanksload()
      titleload()
      scene="thanks"
    else
      level1load()
      titleload()
      scene="title"
    end
end


function love.update(dt)
    if scene=="title" then
        titleupdate(dt)
    elseif scene=="level-1" then
        level1update(dt)
    elseif scene=="level-2" then
        level2update(dt)
    elseif scene=="credits" then
        creditsupdate(dt)
    elseif scene=="thanks" then
        thanksupdate(dt)
    end
end

function love.draw()
    if scene=="title" then
        titledraw()
    elseif scene=="menu" then
        menudraw()
    elseif scene=="level-1" then
        level1draw()
    elseif scene=="level-2" then
        level2draw()
    elseif scene=="credits" then
        creditsdraw()
    elseif scene=="thanks" then
        thanksdraw()
    else
        love.graphics.print("???", 200,200)
    end
end
