local timer = {}
local tasks = {}

function timer.update(dt)
    for i = #tasks, 1, -1 do
        local t = tasks[i]
        if not t.paused then
            t.elapsed = t.elapsed + (dt * 1000)
            
            if t.elapsed >= t.delay then
                t.iterations = t.iterations - 1
                t.elapsed = t.elapsed - t.delay
                
                if t.onComplete then
                    t.onComplete({
                        source = t,
                        count = t.totalIterations - t.iterations
                    })
                end
                
                if t.iterations == 0 then
                    table.remove(tasks, i)
                end
            end
        end
    end
end

function timer.performWithDelay(delay, callback, iterations)
    local task = {
        delay = delay or 0,
        onComplete = callback,
        iterations = iterations or 1,
        totalIterations = iterations or 1,
        elapsed = 0,
        paused = false
    }
    
    function task:pause() self.paused = true end
    function task:resume() self.paused = false end
    function task:cancel()
        for i, v in ipairs(tasks) do
            if v == self then
                table.remove(tasks, i)
                break
            end
        end
    end

    table.insert(tasks, task)
    return task
end

function timer.cancelAll()
    tasks = {}
end

return timer