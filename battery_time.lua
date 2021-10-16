local os = require("os")
local io = require("io")
local wibox = require("wibox")
local gears = require("gears")
local timer = require("gears.timer")

local b_time = {}

-- PATHS && FILENAMES
local path = "/sys/class/power_supply/BAT0/"
local p_pwi = "power_now"
local p_eni = "energy_now"
local p_stt = "status"

-- LOCAL VARS
local energy = 0.0
local power = 0.0
local status = 'PRE_INIT'
local hours = 0
local minutes = 0

function get_string_from_path(filename)
	local stream = io.open(path .. filename, "r")
	io.input(stream)
	local ret = io.read()
	io.close(stream)
	return ret
end

-- time left function !! BATTERY ON DISCHARGE
function etc(charge, rate)
	hours = math.floor(charge / rate)
	minutes = math.floor(((charge / rate)-hours)*60)
	--return hours
end

function b_time:new (reload_t)
	local wdg = wibox.widget.textbox()
	wdg._private.refresh = reload_t or 3
	
	function ugo ()
        
        energy = tonumber(get_string_from_path("energy_now"))
		power = tonumber(get_string_from_path("power_now"))
		etc(energy, power)
		
		awesome.emit_signal("time::battery", hours, minutes)

		--battery.capacity = get_string_from_path()
		--wdg:set_markup(string)
		wdg._timer.timeout = reload_t or 3
		wdg._timer:again()
		return true
	end

	wdg._timer = timer.start_new(refresh, ugo)
	wdg._timer:emit_signal("timeout_b_t", reload_t)
	--wdg._timer:emit_signal("battery::all", capacity, energy, power, status)
	--awesome.emit_signal("battery::all", capacity, energy, power, status)
	return wdg
end

return setmetatable(b_time, nil)
