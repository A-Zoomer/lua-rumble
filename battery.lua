local os = require("os")
local io = require("io")
local wibox = require("wibox")
local gears = require("gears")
local timer = require("gears.timer")

local textbattery = {}

-- PATHS && FILENAMES
local path = "/sys/class/power_supply/BAT0/"
local p_cap = "capacity"
local p_stt = "status"

-- LOCAL VARS
local status = 'PRE_INIT'
local capacity = 0.0

function get_string_from_path(filename)
	local stream = io.open(path .. filename, "r")
	io.input(stream)
	local ret = io.read()
	io.close(stream)
	return ret
end


function batt_icon(batt_cp, batt_st)
	local val = tonumber(batt_cp)
	local st = batt_st
	local ret = ''

	if st == 'Charging' then
		ret = ''
		return ret
	end

	if val <= 35 then
		ret = ''
	elseif val <= 60 then
		ret = ''
	elseif val <= 75 then
		ret = ''
	elseif val <= 85 then
		ret = ''
	else	
		ret = ''
	end
	
	return ret	
end

function textbattery:new (reload_t)
	local wdg = wibox.widget.textbox()
	wdg._private.refresh = reload_t or 3
	
	function ugo ()

		capacity = tonumber(get_string_from_path("capacity"))
		status  = get_string_from_path("status")

		--wdg:emit_signal("battery::general", capacity, status)
		awesome.emit_signal("battery::general", capacity, status)
		--timer.delayed_call(wdg.emit_signal, wdg, "battery::general", capacity, status)
		
		--wdg:set_markup(string)
		wdg._timer.timeout = reload_t or 3
		wdg._timer:again()
		return true
	end

	wdg._timer = timer.start_new(refresh, ugo)
	wdg._timer:emit_signal("timeout_b", reload_t)
	--awesome.emit_signal("battery::all", capacity, energy, power, status)
	return wdg
end

return setmetatable(textbattery, nil)

--return setmetatable(textbattery, nil)

