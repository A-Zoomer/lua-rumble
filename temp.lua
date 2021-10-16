local os = require("os")
local io = require("io")
local wibox = require("wibox")
local timer = require("gears.timer")

local temp_t = {}

-- PATHS && FILENAMES
local path = "/sys/class/thermal/"
local cache_t = "thermal_dirs.cache"
local cache_ss = "cpu_reg.cache"
local t_zone = "thermal_zone"
local t_target = "temp"
local y_target = "type"
local t_zones = {}

local temps = {}
local types = {}

function init_tzones(root_p)
    os.execute("find " .. root_p .. " -name '" .. t_zone .. "*' | awk -F / '{print $5}' > " .. cache_t )
end

function get_temps_from_path(path, filter)
    local ret

    local stream = io.open(path, "r")
    io.input(stream)
    if filter then
        ret = io.read("*all")
    else
        ret = io.read()
    end
    io.close(stream)
    return ret
end

function stream_to_table_t(stream)
    local t_ret = {}

    for l in stream:gmatch("[^\n]+") do
        table.insert(t_ret, l)
    end
    
    return t_ret
end

function get_temp(p, dirs)
    local ret = {}

    for k,v in ipairs(dirs) do
        ret[k] = tonumber(get_temps_from_path(path .. v .. "/" .. t_target, false))
    end

    return ret
end

function get_type(p, dirs)
    local ret = {}

    for k,v in ipairs(dirs) do
        ret[k] = get_temps_from_path(path .. v .. "/" .. y_target, false)
    end

    return ret
end

function temp_t:new (reload_t)
    local wdg = wibox.widget.textbox()
    wdg._private.refresh = reload_t or 3

    --init_tzones(path)
    function ugo()
        init_tzones(path)
        --get available thermal dirs
        local temps_raw = get_temps_from_path(cache_t, true)
	    t_zones = stream_to_table_t(temps_raw)
        
        --parse name and temp of sensor
        temps = get_temp(path, t_zones)
        types = get_type(path, t_zones)

        awesome.emit_signal("stats::temps", temps)
        awesome.emit_signal("stats::types", types)

        wdg._timer.timeout = reload_t or 3
		wdg._timer:again()
        return true
    end

    wdg._timer = timer.start_new(refresh, ugo)
	wdg._timer:emit_signal("timeout_t", reload_t)

    return wdg
end

return setmetatable(temp_t, nil)

--[[
init_tzones(path)
local t_zones_raw = get_temps_from_path(cache_t, "*all")
t_zones = stream_to_table(t_zones_raw)
temps = get_temp(path, t_zones)
types = get_type(path, t_zones)

for k,v in ipairs(types) do
    print(k,v .. "\t -> " .. temps[k])
end
]]

