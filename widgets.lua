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
-- 1. CPU Widget ()
-- ============================================================================
local cpu_text = wibox.widget.textbox()
widgets.cpu = make_pill(cpu_text)

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
        "<span font='%s' color='%s'></span> <span font='%s' color='%s'>%d%%</span>",
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
local mem_text = wibox.widget.textbox()
widgets.mem = make_pill(mem_text)

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
-- 3. Network Widget ( / )
-- ============================================================================
local net_text = wibox.widget.textbox()
widgets.net = make_pill(net_text)

local net_tooltip = awful.tooltip {
    objects = { widgets.net },
    mode    = "outside",
    align   = "top",
}

local function format_speed(kb)
    if kb >= 1024 then
        return string.format("%.1fM", kb / 1024)
    else
        return string.format("%.0fK", kb)
    end
end

vicious.register(net_text, vicious.widgets.net, function(widget, args)
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

    return string.format(
        "<span font='%s' color='%s'></span> <span font='%s' color='%s'>%s</span>  <span font='%s' color='%s'></span> <span font='%s' color='%s'>%s</span>",
        icon_font, colors.green, text_font, colors.fg_text, format_speed(down_kb),
        icon_font, colors.cyan, text_font, colors.fg_text, format_speed(up_kb)
    )
end, 2)

-- ============================================================================
-- 4. Thermal Widget ()
-- ============================================================================
local therm_text = wibox.widget.textbox()
widgets.therm = make_pill(therm_text)

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
local bat_text = wibox.widget.textbox()
widgets.bat = make_pill(bat_text)

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
-- 6. Clock Widget (󰥔)
-- ============================================================================
local clock_widget = wibox.widget.textclock(
    "<span font='" .. icon_font .. "' color='" .. colors.cyan .. "'>󰥔</span> <span font='" .. text_font .. "' color='" .. colors.fg_text .. "'>%a %d %b, %H:%M</span>"
)
widgets.clock = make_pill(clock_widget)

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

return widgets
