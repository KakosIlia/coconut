local m = {}
local sounds = {}

m.load = function(name, path, type)
    local s = love.audio.newSource(path, type or "static")
    sounds[name] = s
    return s
end

m.play = function(name, volume, pitch)
    local s = sounds[name]
    if s then
        local instance = s:clone()
        instance:setVolume(volume or 1)
        instance:setPitch(pitch or (0.9 + math.random() * 0.2)) -- бонус: небольшой рандом питча
        instance:play()
    end
end

m.loop = function(name, volume)
    local s = sounds[name]
    if s then
        s:setLooping(true)
        s:setVolume(volume or 1)
        s:play()
    end
end

m.stop = function(name)
    if sounds[name] then
        sounds[name]:stop()
    end
end

m.setVolume = function(name, volume)
    if sounds[name] then
        sounds[name]:setVolume(volume)
    end
end

m.pauseAll = function()
    love.audio.pause()
end

m.resumeAll = function()
    love.audio.resume()
end

m.stopAll = function()
    love.audio.stop()
end

return m