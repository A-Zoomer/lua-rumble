local os = require("os")
local io = require("io")
local wibox = require("wibox")
local timer = require("gears.timer")

local network_n = {}

-- VARS
local net_info = {}
local ip
local ip_gtw
local ints = {}

local command = [[
    ip r
]]

function network_n:new (reload_t)
    local wdg = wibox.widget.textbox()
    wdg._private.refresh = reload_t or 3

    function ugo()
        net_info = {}
        ints = {}
        int = ""

        local handle = io.popen("ip r", "r")
        local state_raw = handle:read("*all")
        handle:close()

        --divide lines
        for l in state_raw:gmatch("[^\n]+") do
            table.insert(net_info, l)
        end

        for k,v in pairs(net_info) do
            -- table of words of a single line
            local tmp = {}
            for vals in v:gmatch("[^\n ]+") do
                table.insert(tmp, vals)
            end

            for ki,vi in pairs(tmp) do
                if vi == "default" then
                    -- default via 192.168.xxx.xxx dev xxxxx
                    -- skipping 'via'
                    ip_gtw = tmp[ki+2]
                elseif vi == "dev" then
                    --print(vi)
                    -- dev NET_INT proto ...
                    -- skipping 'dev'
                    table.insert(ints, tmp[ki+1])
                end
            end
        end
        --if int == nil then int = "no_network" end

        awesome.emit_signal("network::int", ints)
        
        wdg._timer.timeout = reload_t or 3
		wdg._timer:again()

        return wdg
    end

    wdg._timer = timer.start_new(refresh, ugo)
	wdg._timer:emit_signal("timeout_n", reload_t)

    return wdg
end

return setmetatable(network_n, nil)