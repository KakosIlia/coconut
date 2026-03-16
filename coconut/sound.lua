local sound = {}


sound.play = function(name)
    local stream = love.audio.newSource(name,'stream')
        love.audio.play(stream)
    return stream 
end

sound.newSoundData = function(name)
    local self = love.sound.newSoundData(name)

    return self
end

return sound