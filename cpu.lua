local os = require("os")
local io = require("io")
local wibox = require("wibox")
local timer = require("gears.timer")

--ENVS
local cpu_s = {}

local raw_s = "PRE_INIT"
local cache_info = "cpu_reg.cache"
local t_cpu = {}

--CONTROL VARS
local first = 0
local second = 0
local f_idle = 0
local s_idle = 0
local sleep_t = 1

local raw_s_f = {}
local raw_s_s = {}

function file_to_stream()
    os.execute("grep cpu /proc/stat > " .. cache_info)
    local stream = io.open(cache_info, "r")
    io.input(stream)
    local ret = io.read("*all")
    io.close(stream)
    return ret
end

function stream_to_table(stream)
    local t_ret = {}

    for l in stream:gmatch("[^\n]+") do
        table.insert(t_ret, l)
    end
    
    return t_ret
end

function line_to_table(line)
    local t_ret = {}
    
    for l in line:gmatch("[^ ]+") do
            table.insert(t_ret, l)
    end

    return t_ret
end

function sleep(n)
    os.execute("sleep " .. tonumber(n))
end

function calc_cpu_time(c_line, index)
    c_line[1] = 0

    for k,v in ipairs(c_line) do
        --print(c_line,"->",k,v)
        if index == 1 then
            second = second + tonumber(v)
        else
            first = first + tonumber(v)
        end
    end

    if index == 1 then
        s_idle = c_line[4] + c_line[5];
    else
        f_idle = c_line[4] + c_line[5];
    end
end

function get_load_percent()
    local percent = {}

    --stream to table()
    local t_cpu_f = stream_to_table(raw_s_f)
    local t_cpu_s = stream_to_table(raw_s_s)

    --for each cpus
    for k,v in ipairs(t_cpu_f) do
        second = 0
        first = 0
        s_idle = 0
        f_idle = 0

        local t_line_f = line_to_table(t_cpu_f[k])
        local t_line_s = line_to_table(t_cpu_s[k])

        calc_cpu_time(t_line_f, 0)
        calc_cpu_time(t_line_s, 1)

        local insttotcpu = second - first
        local instidle = s_idle - f_idle

        table.insert(percent,((insttotcpu - instidle)/insttotcpu)*100)
    end

    return percent
end

function cpu_s:new (reload_t)
    local wdg = wibox.widget.textbox()
    wdg._private.refresh = reload_t or 3

    raw_s_f = file_to_stream()    
    sleep(1)

    function ugo ()
        raw_s_s = file_to_stream()
        local p = get_load_percent()

        awesome.emit_signal("stats::cpu", p)
        raw_s_f = raw_s_s

        wdg._timer.timeout = reload_t or 3
		wdg._timer:again()
        return true
    end

    wdg._timer = timer.start_new(refresh, ugo)
	wdg._timer:emit_signal("timeout_c", reload_t)

    return wdg
end

return setmetatable(cpu_s, nil)

--DEBUG F(x)s
--[[
raw_s_f = file_to_stream()
sleep(1)
raw_s_s = file_to_stream()
local ug = get_load_percent()
for k,v in ipairs(ug) do
    print(k,v)
end
]]

--[[
local p = get_load_percent()
for k,v in ipairs(p) do
    print(k,v)
end
]]--




