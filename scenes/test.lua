display.setBackgroundColor("#d68d2e")
local tableOfSprites = display.identSheet("scenes/spritesheet_default.xml")
local player = display.node()
local playerHitbox = display.imageSheet("scenes/spritesheet_default.png",tableOfSprites["pink_body_square.png"],0,0,100,100,"nearest")
player:insert(playerHitbox)
local playerFace = display.imageSheet("scenes/spritesheet_default.png",tableOfSprites["face_a.png"],0,0,50,30,"nearest")
playerFace:setShader([[
        uniform float time;
        uniform float amplitude; 
        uniform float speed;     

        vec4 position(mat4 transform_projection, vec4 vertex_position) {
            vertex_position.y += sin(time * speed) * amplitude;
            
            return transform_projection * vertex_position;
        }]],{time = 0,amplitude = 20,speed = 5})
loop(function(e)
    playerFace:sendToShader({time = totalTime,speed = 5,amplitude = 5})
end)
player:insert(playerFace)

local playerHand = display.imageSheet("scenes/spritesheet_default.png",tableOfSprites["pink_hand_closed.png"],75,25,30,30)

local title = display.text('Hero creator',0,window.maxY)
title.anchorY = 1
title:setFont('scenes/sans.ttf',30)


local letters = {'a','b','c','d','e','f','g','h','i','j'}
local clicks = 1
playerHitbox:onTouched(function(e)
    if e.phase == 'began' then
        clicks = clicks + 1
        playerFace:retakeSprite(tableOfSprites["face_" .. letters[clicks] .. '.png'])

        if clicks >= #letters then
            clicks = 0
        end
    end
end)

local letters = {'closed','open','peace','point','rock','thumb'}
local clicks = 1
playerHand:onTouched(function(e)
    if e.phase == 'began' then
        clicks = clicks + 1
        playerHand:retakeSprite(tableOfSprites["pink_hand_" .. letters[clicks] .. '.png'])

        if clicks >= #letters then
            clicks = 0
        end
    end
end)