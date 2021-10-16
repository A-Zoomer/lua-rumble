local wibox = require("wibox")
local os = require("os")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local xres = require("beautiful.xresources")
local awestore = require("awestore")
local dpi = xres.apply_dpi
local gfs = gears.filesystem

require("modules.battery"):new(1)
require("modules.battery_time"):new(60)
require("modules.temp"):new(2)
require("modules.cpu"):new(1)
require("modules.network"):new(1)
require("modules.volume"):new(1)

local font_label_cpu = "Iosevka Nerd Font bold "
local temp_unit_letter = "C"
local font_icon = "Iosevka Nerd Font 14"
local font_clock = "Iosevka Nerd Font Bold 15"

local dot_sel = gears.surface.load_uncached(gfs.get_configuration_dir() .. "assets/dot.png")
dot_sel = gears.color.recolor_image(dot_sel, beautiful.xcolor3)

local dot_usel = gears.surface.load_uncached(gfs.get_configuration_dir() .. "assets/dot.png")
dot_usel = gears.color.recolor_image(dot_usel, beautiful.xcolor7)

function rounded_rect(cr, w, h, r)
	return gears.shape.rounded_rect(cr, w, h, r)
end

rrect = function(radius)
	return function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, radius)
	end
end

function spacer(width)
	return wibox.widget {
		forced_width = width,
		layout = wibox.layout.fixed.horizontal
	}
end

local wrapper = function(w, b)
	local wrap = wibox.widget {
		w,
		bg = b,
		shape = rrect(6),--rounded_rect(w, , , 10),
		widget = wibox.container.background
	}
	return wrap
end

local wrap_widget = function(w)
	local wrapped = wibox.widget {
		w,
		top = dpi(3),
		left = dpi(4),
		bottom = dpi(3),
		right = dpi(4),
		widget = wibox.container.margin
	}
	return wrapped
end

-- BATTERY 

--local battery = require("modules.battery")
--local batter_t = battery_time:new(1)

-- 

--[[
local battery_icon = wibox.widget{
	wrap_widget(wrapper({
		spacer(10),
		batt_icon,
		spacer(10), 
		layout = wibox.layout.fixed.horizontal
	}, beautiful.xcolor8)),
	layout = wibox.layout.fixed.horizontal
}
--]]

local time_clock = wibox.widget{
		format = "%H:%M:%S",
		font = font_clock,
		--"%a %b %d, %H:%M",
		timezone = "Europe/Rome",
		refresh = 1,
		widget = wibox.widget.textclock
}

local week_day = wibox.widget{
	format = "%a",
	timezone = "Europe/Rome",
	refresh = 60*60*5,
	align = "center",

	widget = wibox.widget.textclock
}

local day_widget = wibox.widget{
	week_day,
	--forced_width  = dpi(10),
    direction = 'east',
    layout = wibox.container.rotate,
}

-- VOLUME MODULE
--Not used... yet
--[[
local volume_bar = wibox.widget {
    bar_shape           = rrect(3),
    bar_height          = 5,
	forced_width		= dpi(150),
    bar_color           = beautiful.border_color,
    handle_color        = beautiful.bg_normal,
    handle_shape        = gears.shape.circle,
    handle_border_color = beautiful.border_color,
    handle_border_width = 1,
    value               = 25,
    widget              = wibox.widget.slider,
}
--]]

local volume_icon_text = wibox.widget{
	text = "--",
	font = font_icon,
	widget = wibox.widget.textbox
}

awesome.connect_signal("stats::volume", function(status, volume)
	if status == "A" then
		--volume_bar.value = volume
		if volume > 50 then
			volume_icon_text.text = ""
		elseif volume > 30 then
			volume_icon_text.text = ""
		else
			volume_icon_text.text = ""
		end
	else
		--volume_bar.value = volume
		volume_icon_text.text = ""
	end
end
)

local volume_button = wibox.widget{
	{
		spacer(10),
		volume_icon_text,
		spacer(10),
		layout = wibox.layout.fixed.horizontal
	},
	shape = rrect(6),
	bg = beautiful.wibar_bg_module_t,
	layout = wibox.container.background
}

-- NET MODULE

local net_int = wibox.widget {
	text = "--",
	font = font_icon,
	widget = wibox.widget.textbox
}

local net_tx_trigger = wibox.widget{
	shape = gears.shape.circle,
	color = beautiful.xcolor7,
	forced_width = dpi(8),
	layout = wibox.widget.separator
}

local net_rx_trigger = wibox.widget{
	shape = gears.shape.circle,
	color = beautiful.xcolor7,
	forced_width = dpi(8),
	layout = wibox.widget.separator
}

function net_triggers_toggle()

	if net_rx_trigger.color == beautiful.xcolor7 then
		net_rx_trigger.color = beautiful.xcolor10
	else
		net_rx_trigger.color = beautiful.xcolor7
	end
end

awesome.connect_signal("network::int", function(int)
	--int is a table with all ints found with $(ip r)
	net_triggers_toggle()

	net_int.text = ""

	if next(int) == nil then
		net_int.text = ""
	elseif int[1] == "wlan0" then
		net_int.text = "直"
	elseif int[1] == "eth0" then
		net_int.text = ""
	end

end
)

--TEMP MODULE

local temp_value = wibox.widget {
	text = "--",
	widget = wibox.widget.textbox
}

local temp_unit = wibox.widget {
	text = "--",
	widget = wibox.widget.textbox
}

awesome.connect_signal("stats::temps", function(temps)
	local temp = temps[8]
	temp_value.text = math.floor((temp / 1000))
	temp_unit.text = "˚" .. temp_unit_letter
end
)

--CPU MODULE

local cpu_g_color_gr = {
    type = 'linear',
    from = {0, 0},
    to = {10, 20}, -- replace with w,h later
    stops = {{0.2, beautiful.xcolor3}, {0.5, beautiful.xcolor9}}
}

function cpu_g ()
	local pp = wibox.widget{
	max_value 			= 100,
	value 				= 10,
	bar_shape			= rrect(2),
	shape 				= rrect(2),
	forced_height 		= dpi(5),
	forced_width		= dpi(50),
	border_width 		= 0,
	--color 				= beautiful.xcolor3,
	color 				= cpu_g_color_gr,
	background_color 	= beautiful.xbackground,
	border_color 		= beautiful.xcolor8,
	widget 				= wibox.widget.progressbar,
	}
	return pp
end

function rotate_cpus(cpu) 
	local pp = wibox.widget{
		cpu,

		forced_width  = dpi(6),
		direction     = 'east',
    	layout        = wibox.container.rotate
	}
	return pp
end

-- only for aestetic purposes
local min_value = 15

local cpu_pg_p = cpu_g()
local p1 = cpu_g()
local p2 = cpu_g()
local p3 = cpu_g()
local p4 = cpu_g()
local p5 = cpu_g()
local p6 = cpu_g()
local p7 = cpu_g()
local p8 = cpu_g()

local p1r = rotate_cpus(p1)
local p2r = rotate_cpus(p2)
local p3r = rotate_cpus(p3)
local p4r = rotate_cpus(p4)
local p5r = rotate_cpus(p5)
local p6r = rotate_cpus(p6)
local p7r = rotate_cpus(p7)
local p8r = rotate_cpus(p8)

local cpu_gen_label = wibox.widget{
	{
		text = "CPUG",
		font = font_label_cpu .. 8,
		align = "center",
		layout = wibox.widget.textbox
	},
	--forced_width  = dpi(10),
    direction     = 'east',
    layout        = wibox.container.rotate,
}

local cpu_cores_label_tag = wibox.widget{
	{
		text = "CORE",
		font = font_label_cpu .. 8,
		align = "center",
		layout = wibox.widget.textbox
	},
	--forced_width  = dpi(10),
    direction     = 'east',
    layout        = wibox.container.rotate,
}

local cpu_pg_gen = wibox.widget {
	cpu_pg_p,

    forced_width  = dpi(10),
    direction     = 'east',
    layout        = wibox.container.rotate,
}

--first-half
local cpu_cores_label_fh = wibox.widget{
	text = "0-3",
	font = font_label_cpu .. 8,
	align = "center",
	layout = wibox.widget.textbox
}

--second-half
local cpu_cores_label_sh = wibox.widget{
	text = "4-7",
	font = font_label_cpu .. 8,
	align = "center",
	layout = wibox.widget.textbox
}

local cpu_cores_label = wibox.widget{
	cpu_cores_label_fh,
	cpu_cores_label_sh,
	layout = wibox.layout.fixed.vertical
}

local cpu_trigger = wibox.widget{
	shape = gears.shape.circle,
	color = beautiful.xcolor7,
	forced_width = dpi(8),
	layout = wibox.widget.separator
}

local cpu_trigger_f = function()
	if cpu_trigger.color == beautiful.xcolor3 then
		cpu_trigger.color= beautiful.xcolor7
	else cpu_trigger.color = beautiful.xcolor3
	end
end

--first-half
local cpu_pg_cores_fh = wibox.widget {
	p1r,
	spacer(3),
	p2r,
	spacer(3),
	p3r,
	spacer(3),
	p4r,
	layout = wibox.layout.fixed.horizontal --flex.vertical
}

--second-half
local cpu_pg_cores_sh = wibox.widget {
	p5r,
	spacer(3),
	p6r,
	spacer(3),
	p7r,
	spacer(3),
	p8r,
	layout = wibox.layout.fixed.horizontal --flex.vertical
}

local i = 100

awesome.connect_signal("stats::cpu", function(val)

	--if cpu_pg_p == nil then cpu_pg_p.value = 100 end
--[[
	local my_tweened = awestore.tweened(i, {
		duration = 400,
		easing = awestore.easing.back_in_out,
	  })
	  
	my_tweened:subscribe(function(v)
		cpu_pg_p.value = v;
	end) -- prints "1"

	my_tweened:set(val[1] + min_value)
	--cpu_pg_p.value = val[1] + min_value
	i = val[1] + min_value
]]

	cpu_pg_p.value = val[1] + min_value

	p1.value = val[2] + min_value
	p2.value = val[3] + min_value
	p3.value = val[4] + min_value
	p4.value = val[5] + min_value

	p5.value = val[6] + min_value
	p6.value = val[7] + min_value
	p7.value = val[8] + min_value
	p8.value = val[9] + min_value

	cpu_trigger_f()
end
)

--BATTERY MODULE

local battery_time = wibox.widget{
	text = "00h:00m",
	forced_width = dpi(45),
	align = "center",
    valign = "center",
	layout = wibox.widget.textbox
}

local battery_pg_p = wibox.widget {
	max_value 			= 100,
	value 				= 0,
	shape 				= rrect(6),
	bar_shape			= rrect(6),
	forced_height 		= dpi(5),
	forced_width		= dpi(100),
	border_width 		= 0,
	color 				= beautiful.xbackground,
	background_color 	= beautiful.xcolor8,
	border_color 		= beautiful.xcolor8,
	widget 				= wibox.widget.progressbar,
}    

local battery_trigger = wibox.widget{
	shape = gears.shape.circle,
	color = beautiful.xcolor7,
	forced_width = dpi(8),
	layout = wibox.widget.separator
}

local battery_trigger_p = wibox.widget{
	shape = gears.shape.circle,
	color = beautiful.xcolor5,
	forced_width = dpi(8),
	layout = wibox.widget.separator
}

local battery_trigger_f = function()
	if battery_trigger.color == beautiful.xcolor3 then
		battery_trigger.color= beautiful.xcolor7
	else battery_trigger.color = beautiful.xcolor3
	end
end

local battery_trigger_p_f = function()
	if battery_trigger_p.color == beautiful.xcolor5 then
		battery_trigger_p.color = beautiful.xcolor7
	else battery_trigger_p.color = beautiful.xcolor5
	end
end

local battery_pg_label = wibox.widget{
	text = "--%",
	align  = 'center',
    valign = 'center',
	widget = wibox.widget.textbox,
}

local battery_pg = wibox.widget {
	battery_pg_p,
	battery_pg_label,
	layout = wibox.layout.stack
}

local battery_blk = wibox.widget {
	wrap_widget(wrapper({
		--spacer(5),
		battery_time,
		--spacer(5),
		layout = wibox.layout.fixed.horizontal
	}, beautiful.xcolor8)),
	layout = wibox.layout.fixed.horizontal
}

awesome.connect_signal("time::battery", function(h, m)
	battery_time.text = h .. "h:" .. m .. "m"

	battery_trigger_f()
end
)

awesome.connect_signal("battery::general", function(cap, stt)
	battery_pg_p.value = cap
	--battery_pg_label.text = cap

	if stt == "Charging" then
		battery_pg_label.text = ''
		battery_pg_label.fg = beautiful.xbackground
	else 
		battery_pg_label.text = cap .. '%'
	end

	battery_trigger_p_f()
end
)

awful.screen.connect_for_each_screen(function(s)

	local update_tags = function(self, c3)
		local icon = self:get_children_by_id('icon_role')[1]
		if c3.selected then
			icon.image = dot_sel
		else
			icon.image = dot_usel
		end
	end
	
	local layoutbox = awful.widget.layoutbox(s)
	layoutbox:buttons(
		gears.table.join(
			awful.button({ }, 1, function() awful.layout.inc(1) end),
			awful.button({ }, 3, function() awful.layout.inc(-1) end)
		)
	)

	local taglist = awful.widget.taglist {
		screen = s,
		filter = awful.widget.taglist.filter.all,
		style = {shape = gears.shape.circle},
		layout = {spacing = 0, layout = wibox.layout.fixed.horizontal},
		widget_template = {
	        {
				{id = 'icon_role', widget = wibox.widget.imagebox},
				id = 'margin_role',
				top = dpi(8),
				bottom = dpi(8),
				left = dpi(3),
				right = dpi(3),
				widget = wibox.container.margin,
			},
			id = 'background_role',
			widget = wibox.container.background,

			create_callback = function(self, c3, index, objects)
				update_tags(self, c3)

				self:connect_signal('mouse::enter', function()
					local icon = self:get_children_by_id('icon_role')[1]
					
					self.backup     = self.bg
			        self.has_backup = true
					
					if not c3.selected then
						self.bg = beautiful.xcolor7
				    else
						self.bg = beautiful.xcolor3
					end
				end)

				self:connect_signal('mouse::leave', function()
					if self.has_backup then self.bg = self.backup end
				end)
			end,

			update_callback = function(self, c3, index, objects)
				update_tags(self, c3)
			end,
		},
	}

	local taglist_block = wrap_widget(wrapper({
		spacer(10),
		taglist,
		spacer(10),
		layout = wibox.layout.fixed.horizontal
	}, beautiful.xbackground))
	
	local update_tags_dsk = function(self, c3)
		local icon = self:get_children_by_id('icon-role')[1]
		if #c3:clients() == 0 then
			icon.color = beautiful.xcolor7
		else
			icon.color = beautiful.xcolor3
		end
	end

	local act_block = awful.widget.taglist{
		screen = s,
		filter = awful.widget.taglist.filter.all,
		style = { shape = gears.shape.rectangle},
		layout = wibox.layout.fixed.horizontal,

		widget_template = {
			{
				{
					id = 'icon-role',
					shape = rrect(6),
					thickness = dpi(5),
					forced_width = dpi(5),
					orientation = 'vertical',
					widget = wibox.widget.separator
				},
				
				id = 'margin-role',
				top = dpi(6),
				bottom = dpi(6),
				left = dpi(2),
				right = dpi(2),
				widget = wibox.container.margin
			},
			id = 'background-role',
			fg = beautiful.xcolor7,
			widget = wibox.container.background,

			create_callback = function(self, c3, index, objects)
				update_tags_dsk(self, c3)
				--self:get_children_by_id('icon_role')[1].shape = rrect(2)
			end,

			update_callback = function(self, c3, index, objects)
				update_tags_dsk(self, c3)
				--self:get_children_by_id('icon_role')[1].shape = rrect(2)
			end,
		},
	}

	local taglist_wrapper = wrap_widget(wrapper({
		--spacer(10),
		taglist_block,
		spacer(3),
		act_block,
		spacer(10),
		layout = wibox.layout.fixed.horizontal
	}, beautiful.wibar_bg_module_t))

	local wb = awful.wibar { 
		position = "top",
		--height = dpi(37),
		width = dpi(1000),
		stretch = "true",
		--shape = rrect(5),
	}
	
	wb:setup {

		bg = beautiful.wibar_bg .. "ff",
		layout = wibox.container.background,
		{
		layout = wibox.layout.align.horizontal,
		expand = "none",
		{
			--desktop taglist
			taglist_wrapper,

			--battery module
			wrap_widget(wrapper({
				wrap_widget(battery_pg),
				battery_time,
				wrap_widget({
					battery_trigger,
					battery_trigger_p,
					layout = wibox.layout.flex.vertical
				}),
				layout = wibox.layout.fixed.horizontal
			}, beautiful.wibar_bg_module_t)),

			--cpu module
			wrap_widget(wrapper({
				wrap_widget({
					cpu_gen_label,
					spacer(2),
					cpu_pg_gen,
					layout = wibox.layout.fixed.horizontal
				}),
				cpu_trigger,
				spacer(3),
				wrapper({
					spacer(5),
					cpu_cores_label_tag,
					wrapper(wrap_widget(cpu_pg_cores_fh)),
					wrap_widget(wrapper({
							spacer(3),
							{
								cpu_cores_label_fh,
								cpu_cores_label_sh,
								layout = wibox.layout.flex.vertical
							},
							spacer(3),
						layout = wibox.layout.fixed.horizontal
					} )),
					wrap_widget(cpu_pg_cores_sh),
					spacer(5),
					layout = wibox.layout.fixed.horizontal
				}, beautiful.xbackground),
				layout = wibox.layout.fixed.horizontal
			}, beautiful.wibar_bg_module_t)),

			layout = wibox.layout.fixed.horizontal
		},
		{
			--clock
			wrap_widget(wrapper({
					wrapper({
						spacer(5),
						time_clock,
						spacer(5),
						layout = wibox.layout.fixed.horizontal
					}, beautiful.xbackground),
					spacer(3),
					day_widget,
					spacer(3),
					layout = wibox.layout.fixed.horizontal
			}, beautiful.wibar_bg_module_t)),

			layout = wibox.layout.fixed.horizontal,
		},
		{
			--net module
			wrap_widget(wrapper({

				wrap_widget({
					net_tx_trigger,
					net_rx_trigger,
					layout = wibox.layout.flex.vertical
				}),

				wrapper({
					spacer(10),
					net_int,
					spacer(10),
					layout = wibox.layout.fixed.horizontal
				},beautiful.xcolor8),

				layout = wibox.layout.fixed.horizontal
			}, beautiful.wibar_bg_module_t)),--beautiful.xcolor8 .. "33")),

			--volume TOCHANGE
			--[[
			wrap_widget(
				wrapper({
				spacer(10),
				volume_icon_text,
				spacer(10),
				layout = wibox.layout.fixed.horizontal
			}, beautiful.wibar_bg_module_t)),
			--]]

			wrap_widget(volume_button),

			--temp module
			wrap_widget({
				wrapper({
					spacer(5),
					temp_unit,
					spacer(2),
					wrap_widget(wrapper({
						spacer(5),
						temp_value,
						spacer(5),
						layout = wibox.layout.fixed.horizontal
					}, beautiful.xcolor8)),
					layout = wibox.layout.fixed.horizontal
				}, beautiful.wibar_bg_module_t),
				
				layout = wibox.layout.fixed.horizontal
			}),

			--layout
			wrap_widget(wrapper({
				top = dpi(6),
				bottom = dpi(6),
				left = dpi(6),
				right = dpi(6),
				layoutbox,
				layout = wibox.container.margin--wibox.layout.fixed.horizontal,
			}, beautiful.wibar_bg_module_t)),
			
			layout = wibox.layout.fixed.horizontal,
		},
		
		}
	}

	--setting up popups

	local pop_volume = require("popups.volume_pop"):new()
	pop_volume:move_next_to(wb)

	volume_button:connect_signal("button::press", function()
		volume_button.bg = beautiful.xcolor14
	end
	)

	volume_button:connect_signal("button::release", function()
		pop_volume:toggle()
		--ugo:bind_to_widget(volume_icon_text)
		--volume_icon_text.text = "--"
		volume_button.bg = beautiful.wibar_bg_module_t
	end
	)

end)

-- CPU HORIZONTAL BARS
--[[
				wrapper(wrap_widget({
					spacer(3),
					cpu_pg_cores_fh,
					spacer(3),
					layout = wibox.layout.fixed.horizontal
				}), beautiful.xbackground),
				wrap_widget({
					cpu_cores_label_fh,
					cpu_cores_label_sh,
					layout = wibox.layout.fixed.vertical
				}),
				wrapper(wrap_widget({
					spacer(3),
					cpu_pg_cores_sh,
					spacer(3),
					layout = wibox.layout.fixed.horizontal
				}), beautiful.xbackground),
				]]
