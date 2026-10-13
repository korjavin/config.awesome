-- ============================================================================
-- Modern Pill-Style Widgets for Awesome WM (Nerd Font + Nord Palette)
-- ============================================================================
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local vicious = require("vicious")
local naughty = require("naughty")

local terminal = "kitty"

local widgets = {}

-- Typography
local icon_font = "FiraCode Nerd Font 10"
local text_font = "sans 9"

-- Color Palette (Nord-inspired)
local colors = {
    bg_pill   = "#2E3440", -- Dark capsule background
    fg_text   = "#ECEFF4", -- Crisp text
    cyan      = "#88C0D0", -- Frost cyan
    blue      = "#81A1C1", -- Frost blue
    purple    = "#B48EAD", -- Aurora purple
    green     = "#A3BE8C", -- Aurora green
    yellow    = "#EBCB8B", -- Aurora yellow
    orange    = "#D08770", -- Aurora orange
    red       = "#BF616A", -- Aurora red
    gray      = "#4C566A", -- Muted gray
}

widgets.colors = colors

-- Helper function to wrap any inner widget into a styled pill container
local function make_pill(content_widget, bg_color)
    local pill_inner = wibox.widget {
        {
            content_widget,
            left   = 8,
            right  = 8,
            top    = 1,
            bottom = 1,
            widget = wibox.container.margin,
        },
        bg     = bg_color or colors.bg_pill,
        shape  = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 4)
        end,
        widget = wibox.container.background,
    }

    return wibox.widget {
        pill_inner,
        top    = 2,
        bottom = 2,
        widget = wibox.container.margin,
    }
end

widgets.make_pill = make_pill

-- ============================================================================
-- 1. CPU Widget ()
-- ============================================================================
local cpu_text = wibox.widget {
    align  = "center",
    valign = "center",
    widget = wibox.widget.textbox,
}
local cpu_box = wibox.container.constraint(cpu_text, "exact", 44)
widgets.cpu = make_pill(cpu_box)

local cpu_tooltip = awful.tooltip {
    objects = { widgets.cpu },
    mode    = "outside",
    align   = "top",
}

vicious.register(cpu_text, vicious.widgets.cpu, function(widget, args)
    local usage = args[1] or 0
    local color = colors.blue
    if usage > 80 then
        color = colors.red
    elseif usage > 60 then
        color = colors.yellow
    end

    local tip = string.format("Загрузка ЦП: %d%%", usage)
    if #args > 1 then
        tip = tip .. "\nПо ядрам:"
        for i = 2, #args do
            tip = tip .. string.format(" [%d: %d%%]", i - 1, args[i])
        end
    end
    tip = tip .. "\nКлик: открыть htop"
    cpu_tooltip:set_text(tip)

    return string.format(
        "<span font='%s' color='%s'></span> <span font='%s' color='%s'>%d%%</span>",
        icon_font, color, text_font, colors.fg_text, usage
    )
end, 2)

widgets.cpu:buttons(gears.table.join(
    awful.button({}, 1, function()
        awful.spawn(terminal .. " -e htop")
    end)
))

-- ============================================================================
-- 2. Memory Widget (󰍛)
-- ============================================================================
local mem_text = wibox.widget {
    align  = "center",
    valign = "center",
    widget = wibox.widget.textbox,
}
local mem_box = wibox.container.constraint(mem_text, "exact", 44)
widgets.mem = make_pill(mem_box)

local mem_tooltip = awful.tooltip {
    objects = { widgets.mem },
    mode    = "outside",
    align   = "top",
}

vicious.register(mem_text, vicious.widgets.mem, function(widget, args)
    local use_p      = args[1] or 0
    local used_mb    = args[2] or 0
    local total_mb   = args[3] or 0
    local free_mb    = args[4] or 0
    local swap_p     = args[5] or 0
    local swap_used  = args[6] or 0
    local swap_total = args[7] or 0

    local color = colors.purple
    if use_p > 85 then
        color = colors.red
    elseif use_p > 70 then
        color = colors.yellow
    end

    mem_tooltip:set_text(string.format(
        "ОЗУ: %.1f ГБ / %.1f ГБ (%d%%)\nСвободно: %.1f ГБ\nSwap: %.1f ГБ / %.1f ГБ (%d%%)\nКлик: открыть htop",
        used_mb / 1024, total_mb / 1024, use_p,
        free_mb / 1024,
        swap_used / 1024, swap_total / 1024, swap_p
    ))

    return string.format(
        "<span font='%s' color='%s'>󰍛</span> <span font='%s' color='%s'>%d%%</span>",
        icon_font, color, text_font, colors.fg_text, use_p
    )
end, 5)

widgets.mem:buttons(gears.table.join(
    awful.button({}, 1, function()
        awful.spawn(terminal .. " -e htop")
    end)
))

-- ============================================================================
-- 3. Network Widget ( / ) - Fixed width, zero jitter
-- ============================================================================
local net_down_text = wibox.widget {
    align  = "left",
    valign = "center",
    widget = wibox.widget.textbox,
}

local net_up_text = wibox.widget {
    align  = "left",
    valign = "center",
    widget = wibox.widget.textbox,
}

local net_box = wibox.widget {
    {
        net_down_text,
        strategy = "exact",
        width    = 58,
        widget   = wibox.container.constraint,
    },
    {
        net_up_text,
        strategy = "exact",
        width    = 58,
        widget   = wibox.container.constraint,
    },
    spacing = 6,
    layout  = wibox.layout.fixed.horizontal,
}

widgets.net = make_pill(net_box)

local net_tooltip = awful.tooltip {
    objects = { widgets.net },
    mode    = "outside",
    align   = "top",
}

local function format_speed(kb)
    if kb >= 1024 * 1024 then
        return string.format("%.1fG", kb / (1024 * 1024))
    elseif kb >= 1024 then
        return string.format("%.1fM", kb / 1024)
    else
        return string.format("%.0fK", kb)
    end
end

vicious.register(net_down_text, vicious.widgets.net, function(widget, args)
    -- Auto-detect active interface (Wi-Fi or Ethernet)
    local iface = "wlp2s0"
    if not args["{" .. iface .. " carrier}"] or args["{" .. iface .. " carrier}"] == 0 then
        for name, val in pairs(args) do
            local dev = name:match("^{([%w]+) carrier}$")
            if dev and dev ~= "lo" and val == 1 then
                iface = dev
                break
            end
        end
    end

    local down_kb = tonumber(args["{" .. iface .. " down_kb}"]) or 0
    local up_kb   = tonumber(args["{" .. iface .. " up_kb}"]) or 0

    net_tooltip:set_text(string.format(
        "Интерфейс: %s\nПриём: %.1f KB/s\nОтдача: %.1f KB/s",
        iface, down_kb, up_kb
    ))

    net_up_text:set_markup(string.format(
        "<span font='%s' color='%s'></span> <span font='%s' color='%s'>%s</span>",
        icon_font, colors.cyan, text_font, colors.fg_text, format_speed(up_kb)
    ))

    return string.format(
        "<span font='%s' color='%s'></span> <span font='%s' color='%s'>%s</span>",
        icon_font, colors.green, text_font, colors.fg_text, format_speed(down_kb)
    )
end, 2)

-- ============================================================================
-- 4. Thermal Widget ()
-- ============================================================================
local therm_text = wibox.widget {
    align  = "center",
    valign = "center",
    widget = wibox.widget.textbox,
}
local therm_box = wibox.container.constraint(therm_text, "exact", 48)
widgets.therm = make_pill(therm_box)

local therm_tooltip = awful.tooltip {
    objects = { widgets.therm },
    mode    = "outside",
    align   = "top",
}

vicious.register(therm_text, vicious.widgets.thermal, function(widget, args)
    local temp = args[1] or 0
    local color = colors.cyan
    if temp >= 75 then
        color = colors.red
    elseif temp >= 60 then
        color = colors.yellow
    end

    therm_tooltip:set_text(string.format("Температура ЦП: %d °C\nЗона: thermal_zone0", temp))

    return string.format(
        "<span font='%s' color='%s'></span> <span font='%s' color='%s'>%d°C</span>",
        icon_font, color, text_font, colors.fg_text, temp
    )
end, 10, "thermal_zone0")

-- ============================================================================
-- 5. Battery Widget (󰁹 / 󰂄)
-- ============================================================================
local bat_text = wibox.widget {
    align  = "center",
    valign = "center",
    widget = wibox.widget.textbox,
}
local bat_box = wibox.container.constraint(bat_text, "exact", 48)
widgets.bat = make_pill(bat_box)

local bat_tooltip = awful.tooltip {
    objects = { widgets.bat },
    mode    = "outside",
    align   = "top",
}

local last_bat_info = { status = "N/A", percent = 0, time = "N/A" }

vicious.register(bat_text, vicious.widgets.bat, function(widget, args)
    local state   = args[1] or "N/A"
    local percent = tonumber(args[2]) or 0
    local time    = args[3] or "N/A"
    local wear    = args[4] or 0
    local power   = args[5] or "N/A"

    local icon = "󰁹"
    local icon_color = colors.green

    if state == "+" then
        icon = "󰂄"
        icon_color = colors.cyan
    else
        if percent <= 15 then
            icon = "󰂃"
            icon_color = colors.red
        elseif percent <= 30 then
            icon = "󰁻"
            icon_color = colors.yellow
        elseif percent <= 50 then
            icon = "󰁽"
            icon_color = colors.yellow
        elseif percent <= 70 then
            icon = "󰁿"
            icon_color = colors.green
        elseif percent <= 90 then
            icon = "󰂀"
            icon_color = colors.green
        else
            icon = "󰁹"
            icon_color = colors.green
        end
    end

    local status_str = "Разрядка"
    if state == "+" then status_str = "Зарядка"
    elseif state == "↯" then status_str = "Полный заряд"
    elseif state == "⌁" then status_str = "Неизвестно" end

    last_bat_info = { status = status_str, percent = percent, time = time, wear = wear, power = power }

    bat_tooltip:set_text(string.format(
        "Батарея: BAT0\nСтатус: %s\nЗаряд: %d%%\nВремя: %s\nИзнос: %s%%\nМощность: %s W\nКлик: показать уведомление",
        status_str, percent, time, wear, power
    ))

    return string.format(
        "<span font='%s' color='%s'>%s</span> <span font='%s' color='%s'>%d%%</span>",
        icon_font, icon_color, icon, text_font, colors.fg_text, percent
    )
end, 15, "BAT0")

widgets.bat:buttons(gears.table.join(
    awful.button({}, 1, function()
        naughty.notify({
            title = "Батарея",
            text  = string.format("Заряд: %d%%\nСтатус: %s\nОсталось: %s",
                last_bat_info.percent, last_bat_info.status, last_bat_info.time),
            timeout = 5,
        })
    end)
))

-- ============================================================================
-- 6. Clock Widget (󰥔) & Calendar Popup
-- ============================================================================
local clock_widget = wibox.widget.textclock(
    "<span font='" .. icon_font .. "' color='" .. colors.cyan .. "'>󰥔</span> <span font='" .. text_font .. "' color='" .. colors.fg_text .. "'>%a %d %b, %H:%M</span>"
)
widgets.clock = make_pill(clock_widget)

local month_calendar = awful.widget.calendar_popup.month({
    start_sunday = false,
    spacing      = 3,
    margin       = 4,
    font         = "FiraCode Nerd Font 10",
    style_month  = {
        border_width = 1,
        border_color = colors.blue,
        bg_color     = colors.bg_pill,
        shape        = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 6) end,
        padding      = 6,
    },
    style_header = {
        fg_color = colors.cyan,
        markup   = function(t) return "<b>" .. t .. "</b>" end,
    },
    style_weekday = {
        fg_color = colors.yellow,
    },
    style_normal = {
        fg_color = colors.fg_text,
    },
    style_focus = {
        fg_color = colors.bg_pill,
        bg_color = colors.cyan,
        shape    = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 4) end,
    },
})
month_calendar:attach(widgets.clock, "tr", { on_hover = false })
widgets.calendar = month_calendar

-- ============================================================================
-- 7. Keyboard Layout Widget (󰌌)
-- ============================================================================
local kbd_layout = awful.widget.keyboardlayout()
local kbd_box = wibox.widget {
    {
        markup = "<span font='" .. icon_font .. "' color='" .. colors.yellow .. "'>󰌌</span>",
        widget = wibox.widget.textbox,
    },
    kbd_layout,
    spacing = 2,
    layout = wibox.layout.fixed.horizontal,
}
widgets.keyboard = make_pill(kbd_box)

-- ============================================================================
-- 8. Volume Widget (󰕾 / 󰝟) & OSD
-- ============================================================================
local vol_text = wibox.widget {
    align  = "center",
    valign = "center",
    widget = wibox.widget.textbox,
}
local vol_box = wibox.container.constraint(vol_text, "exact", 50)
widgets.volume = make_pill(vol_box)

local vol_tooltip = awful.tooltip {
    objects = { widgets.volume },
    mode    = "outside",
    align   = "top",
}

local osd_notification = nil
function widgets.show_osd(osd_type, val, is_mute)
    local icon, title, progress_str
    if osd_type == "volume" then
        title = "Громкость"
        if is_mute then
            icon = "󰝟"
            progress_str = "MUTE"
        else
            icon = val > 50 and "󰕾" or (val > 0 and "󰖀" or "󰕿")
            progress_str = val .. "%"
        end
    elseif osd_type == "brightness" then
        title = "Яркость"
        icon = "󰃠"
        progress_str = val .. "%"
    end

    local text = string.format(
        "<span font='%s 14'>%s</span>  <span font='%s 12' font_weight='bold'>%s</span>",
        icon_font, icon, text_font, progress_str
    )

    osd_notification = naughty.notify {
        title = title,
        text = text,
        timeout = 1.5,
        replaces_id = osd_notification and osd_notification.id or nil,
        position = "top_middle",
    }
end

function widgets.parse_volume(stdout, show_osd)
    local vol = tonumber(stdout:match("(%d+)%%")) or 0
    local is_mute = stdout:match("Mute:%s+(%w+)") == "yes"

    local icon = "󰕾"
    local color = colors.cyan
    if is_mute then
        icon = "󰝟"
        color = colors.red
    elseif vol <= 25 then
        icon = "󰕿"
    elseif vol <= 60 then
        icon = "󰖀"
    end

    vol_text:set_markup(string.format(
        "<span font='%s' color='%s'>%s</span> <span font='%s' color='%s'>%s</span>",
        icon_font, color, icon,
        text_font, colors.fg_text,
        is_mute and "MUTE" or string.format("%d%%", vol)
    ))

    vol_tooltip:set_text(string.format(
        "Громкость: %s\nСтатус: %s\nЛКМ: Mute | Скролл: Регулировка\nПКМ: pavucontrol",
        vol .. "%", is_mute and "Выключен" or "Включен"
    ))

    if show_osd then
        widgets.show_osd("volume", vol, is_mute)
    end
end

function widgets.update_volume(show_osd)
    awful.spawn.easy_async_with_shell(
        "pactl get-sink-volume @DEFAULT_SINK@ && pactl get-sink-mute @DEFAULT_SINK@",
        function(stdout)
            widgets.parse_volume(stdout, show_osd)
        end
    )
end

function widgets.change_volume(step)
    local cmd
    if step == "toggle" then
        cmd = "pactl set-sink-mute @DEFAULT_SINK@ toggle"
    elseif step > 0 then
        cmd = "pactl set-sink-mute @DEFAULT_SINK@ 0 && pactl set-sink-volume @DEFAULT_SINK@ +" .. step .. "%"
    else
        cmd = "pactl set-sink-mute @DEFAULT_SINK@ 0 && pactl set-sink-volume @DEFAULT_SINK@ -" .. math.abs(step) .. "%"
    end
    awful.spawn.easy_async_with_shell(
        cmd .. " && pactl get-sink-volume @DEFAULT_SINK@ && pactl get-sink-mute @DEFAULT_SINK@",
        function(stdout)
            widgets.parse_volume(stdout, true)
        end
    )
end

-- ============================================================================
-- 9. Brightness Widget (󰃠) & OSD
-- ============================================================================
local bright_text = wibox.widget {
    align  = "center",
    valign = "center",
    widget = wibox.widget.textbox,
}
local bright_box = wibox.container.constraint(bright_text, "exact", 50)
widgets.brightness = make_pill(bright_box)

local bright_tooltip = awful.tooltip {
    objects = { widgets.brightness },
    mode    = "outside",
    align   = "top",
}

function widgets.parse_brightness(stdout, show_osd)
    local pct = tonumber(stdout:match(",([%d]+)%%,")) or 0

    bright_text:set_markup(string.format(
        "<span font='%s' color='%s'>󰃠</span> <span font='%s' color='%s'>%d%%</span>",
        icon_font, colors.yellow, text_font, colors.fg_text, pct
    ))

    bright_tooltip:set_text(string.format(
        "Яркость экрана: %d%%\nСкролл: Регулировка (±5%%)", pct
    ))

    if show_osd then
        widgets.show_osd("brightness", pct)
    end
end

function widgets.update_brightness(show_osd)
    awful.spawn.easy_async("brightnessctl -m", function(stdout)
        widgets.parse_brightness(stdout, show_osd)
    end)
end

function widgets.change_brightness(step)
    local cmd = step > 0 and ("brightnessctl -q set +" .. step .. "%") or ("brightnessctl -q set " .. math.abs(step) .. "%- -n")
    awful.spawn.easy_async_with_shell(cmd .. " && brightnessctl -m", function(stdout)
        widgets.parse_brightness(stdout, true)
    end)
end

widgets.brightness:buttons(gears.table.join(
    awful.button({}, 1, function() widgets.update_brightness(true) end),
    awful.button({}, 4, function() widgets.change_brightness(5) end),
    awful.button({}, 5, function() widgets.change_brightness(-5) end)
))

widgets.update_brightness(false)
gears.timer {
    timeout = 15,
    autostart = true,
    callback = function() widgets.update_brightness(false) end,
}

widgets.volume:buttons(gears.table.join(
    awful.button({}, 1, function() widgets.change_volume("toggle") end),
    awful.button({}, 3, function() awful.spawn("pavucontrol") end),
    awful.button({}, 4, function() widgets.change_volume(5) end),
    awful.button({}, 5, function() widgets.change_volume(-5) end)
))

widgets.update_volume(false)
gears.timer {
    timeout = 10,
    autostart = true,
    callback = function() widgets.update_volume(false) end,
}

return widgets
