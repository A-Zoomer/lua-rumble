local os = require("os")
local io = require("io")
local wibox = require("wibox")
local timer = require("gears.timer")

local volume_v = {}

local cardid = 0
local channel = "Master"
local status_raw

function get_channel_info()
    local fd = io.popen("amixer -c " .. cardid .. " -- sget " .. channel)
    status_raw = fd:read("*all")
    fd:close()
end

function volume_v:new (reload_t)
    local wdg = wibox.widget.textbox()
    wdg._private.refresh = reload_t or 3

    function ugo()
        get_channel_info()
        local volume = string.match(status_raw, "(%d?%d?%d)%%")
        volume = string.format("% 3d", volume)
         
        status = string.match(status_raw, "%[(o[^%]]*)%]")
        if string.find(status, "on", 1, true) then
            volume = tonumber(volume)
            status = "A" --active
        else
            volume = tonumber(volume)
            status = "M" --muted
        end

        awesome.emit_signal("stats::volume", status, volume)

        wdg._timer.timeout = reload_t or 3
	    wdg._timer:again()
        return true
    end

    wdg._timer = timer.start_new(refresh, ugo)
	wdg._timer:emit_signal("timeout_c", reload_t)

    return wdg
end

return setmetatable(volume_v, nil)