local ffi = require("ffi")

ffi.cdef[[
    typedef enum {
        SDL_POWERSTATE_UNKNOWN,
        SDL_POWERSTATE_ON_BATTERY,
        SDL_POWERSTATE_NO_BATTERY,
        SDL_POWERSTATE_CHARGING,
        SDL_POWERSTATE_CHARGED
    } SDL_PowerState;
    SDL_PowerState SDL_GetPowerInfo(int* seconds, int* percent);

    char* SDL_GetPrefPath(const char* org, const char* app);
    char* SDL_GetBasePath(void);
    void SDL_free(void* mem);

    int SDL_ShowCursor(int toggle);

    int SDL_NumHaptics(void);
    
    int SDL_GetCPUCount(void);
    int SDL_GetSystemRAM(void);
]]

local sdl = ffi.os == "Windows" and ffi.load("SDL2") or ffi.C

coconut = {}

coconut.getBatteryPercent = function()
    local percent = ffi.new("int[1]")
    local state = sdl.SDL_GetPowerInfo(nil, percent)
    return percent[0], state
end

coconut.getExecutablePath = function()
    local raw_path = sdl.SDL_GetBasePath()
    if raw_path == nil then return nil end
    local path = ffi.string(raw_path)
    sdl.SDL_free(raw_path)
    return path
end

coconut.getSystemStats = function()
    return {
        cores = sdl.SDL_GetCPUCount(),
        ram_mb = sdl.SDL_GetSystemRAM()
    }
end

coconut.toggleCursor = function(show)
    sdl.SDL_ShowCursor(show and 1 or 0)
end