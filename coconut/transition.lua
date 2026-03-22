local transition = {}
local tweens = {}

local easing = {}
easing.linear = function(t) return t end
easing.inQuad = function(t) return t * t end
easing.outQuad = function(t) return t * (2 - t) end
easing.inOutQuad = function(t) return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t end
easing.inCubic = function(t) return t * t * t end
easing.outCubic = function(t) return 1 - (1 - t)^3 end
easing.inOutCubic = function(t) return t < 0.5 and 4 * t * t * t or 1 - (-2 * t + 2)^3 / 2 end
easing.inQuart = function(t) return t * t * t * t end
easing.outQuart = function(t) return 1 - (1 - t)^4 end
easing.inOutQuart = function(t) return t < 0.5 and 8 * t^4 or 1 - (-2 * t + 2)^4 / 2 end
easing.inQuint = function(t) return t^5 end
easing.outQuint = function(t) return 1 - (1 - t)^5 end
easing.inOutQuint = function(t) return t < 0.5 and 16 * t^5 or 1 - (-2 * t + 2)^5 / 2 end
easing.inSine = function(t) return 1 - math.cos((t * math.pi) / 2) end
easing.outSine = function(t) return math.sin((t * math.pi) / 2) end
easing.inOutSine = function(t) return -(math.cos(math.pi * t) - 1) / 2 end
easing.inExpo = function(t) return t == 0 and 0 or 2^(10 * t - 10) end
easing.outExpo = function(t) return t == 1 and 1 or 1 - 2^(-10 * t) end
easing.inOutExpo = function(t)
    if t == 0 or t == 1 then return t end
    return t < 0.5 and 2^(20 * t - 10) / 2 or (2 - 2^(-20 * t + 10)) / 2
end
easing.inCirc = function(t) return 1 - math.sqrt(1 - t^2) end
easing.outCirc = function(t) return math.sqrt(1 - (t - 1)^2) end
easing.inOutCirc = function(t)
    return t < 0.5 and (1 - math.sqrt(1 - (2 * t)^2)) / 2 or (math.sqrt(1 - (-2 * t + 2)^2) + 1) / 2
end
easing.inBack = function(t)
    local s = 1.70158
    return t * t * ((s + 1) * t - s)
end
easing.outBack = function(t)
    local s = 1.70158
    return 1 + (t - 1)^2 * ((s + 1) * (t - 1) + s)
end
easing.inOutBack = function(t)
    local s = 1.70158 * 1.525
    return t < 0.5 and (t * 2)^2 * ((s + 1) * t * 2 - s) / 2 or ((t * 2 - 2)^2 * ((s + 1) * (t * 2 - 2) + s) + 2) / 2
end
easing.outBounce = function(t)
    if t < (1 / 2.75) then return 7.5625 * t * t
    elseif t < (2 / 2.75) then t = t - (1.5 / 2.75) return 7.5625 * t * t + 0.75
    elseif t < (2.5 / 2.75) then t = t - (2.25 / 2.75) return 7.5625 * t * t + 0.9375
    else t = t - (2.625 / 2.75) return 7.5625 * t * t + 0.984375 end
end
easing.inBounce = function(t) return 1 - easing.outBounce(1 - t) end
easing.inOutBounce = function(t)
    return t < 0.5 and (1 - easing.outBounce(1 - 2 * t)) / 2 or (1 + easing.outBounce(2 * t - 1)) / 2
end

transition.easing = easing

local function lerp(a, b, t) return a + (b - a) * t end

local function set_value(obj, key, value)
    if obj._proxy and obj._proxy[key] ~= nil then
        if key == "x" then obj:setX(value)
        elseif key == "y" then obj:setY(value)
        elseif key == "angle" then obj:setAngle(value)
        elseif key == "width" or key == "height" then
            local w = (key == "width") and value or obj:getWidth()
            local h = (key == "height") and value or obj:getHeight()
            obj:setSize(w, h)
        end
    else
        obj[key] = value
    end
end

local function get_value(obj, key)
    if obj._proxy and obj._proxy[key] ~= nil then return obj._proxy[key] end
    return obj[key]
end

function transition.update(dt)
    for i = #tweens, 1, -1 do
        local t = tweens[i]
        t.elapsed = t.elapsed + (dt * 1000)
        local rawProgress = math.min(t.elapsed / t.time, 1)
        
        -- Применяем функцию сглаживания
        local progress = t.easingFunc(rawProgress)

        for key, target_val in pairs(t.params) do
            local start_val = t.start_values[key]
            if type(target_val) == "table" then
                local current_table = {}
                for j = 1, #target_val do
                    current_table[j] = lerp(start_val[j], target_val[j], progress)
                end
                set_value(t.target, key, current_table)
            else
                set_value(t.target, key, lerp(start_val, target_val, progress))
            end
        end

        if rawProgress >= 1 then
            if t.onComplete then t.onComplete(t.target) end
            table.remove(tweens, i)
        end
    end
end

function transition.to(obj, params)
    local t_params = {}
    local start_values = {}
    local easingFunc = params.transition or easing.linear
    
    for k, v in pairs(params) do
        if k ~= "time" and k ~= "onComplete" and k ~= "transition" then
            t_params[k] = v
            start_values[k] = get_value(obj, k)
        end
    end

    local new_tween = {
        target = obj,
        params = t_params,
        start_values = start_values,
        time = params.time or 500,
        elapsed = 0,
        onComplete = params.onComplete,
        easingFunc = easingFunc
    }

    table.insert(tweens, new_tween)
    return new_tween
end

return transition