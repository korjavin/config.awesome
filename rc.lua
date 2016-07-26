require("pulseaudio")
--require("pintask")
-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- Load Debian menu entries
require("debian.menu")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
monitor_on="/usr/bin/xrandr --output HDMI-0 --auto --primary --output VGA-0 --mode 1280x800 --below HDMI-0"
--monitor_on="/usr/bin/xrandr --output HDMI-0 --auto --primary --output VGA-0 --below HDMI-0"
monitor_off="/usr/bin/xrandr --output VGA-0 --off"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[2])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "firefox", "/home/iv/bin/firefox" },
   { "chrome", "google-chrome" },
   { "shutter", "shutter" },
   { "skype", "skype" },
   { "pavucontrol", "pavucontrol" },
   { "skype-record", "/home/iv/Projects/skype-call-recorder/skype-call-recorder" },
   { "empathy", "empathy" },
   { "calc", "gnome-calculator" },
   { "bg", "/home/iv/.BGBillingClient/bgbilling.sh" },
   { "viber", "/opt/viber/Viber" },
   { "Бюджет", "gnucash" },
   { "pcmanfm", "pcmanfm" },
   { "remmina", "remmina" },
   { "revelation", "revelation" },
--   { "eclipse", "wmname LG3D; /media/Space/tmp/adt-bundle-linux-x86_64-20140702/eclipse/eclipse" },
   { "vlc tv" , "vlc .play.m3u" },
   { "rescuetime", "rescuetime" },
   { "audacity", "/home/iv/bin/audacity" },
   { "pidgin", "pidgin" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "Menu", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

--- pintask
---    pintaskwidget0 = widget({
---        type = "textbox",
---        name = "pintaskwidget0",
---        align = "right"
---    })
---
---    pintaskwidget0:buttons(awful.util.table.join(
---      awful.button({ }, 1, function()
---          local newThread = coroutine.wrap(function()
---              pintask.Start();
---              pintaskwidget0.text = pintask.Status()
---            end)
---        newThread()
---      end),
---      awful.button({ }, 3, function()  pintask.Stop() ; pintaskwidget0.text = pintask.Status() end)
---    ))
---
---    pintaskwidget0.text = " UNK "
-----  pintaskwidget0.text = pintask.Status();
---
---   pintasktimer1 = timer({ timeout = 1201 })
---   pintasktimer1:add_signal("timeout", function() pintaskwidget0.text = pintask.Status() end)
---   pintasktimer1:start()

--- pulse
    volumewidget0 = widget({
        type = "textbox",
        name = "volumewidget0",
        align = "right"
    })

    volumewidget0:buttons(awful.util.table.join(
      awful.button({ }, 1, function() pulseaudio.SwitchTo(0); end),
      awful.button({ }, 3, function() pulseaudio.SwitchTo(0); end),
      awful.button({ }, 4, function() pulseaudio.volumeUp0(); volumewidget0.text = pulseaudio.volumeInfo0() end),
      awful.button({ }, 5, function() pulseaudio.volumeDown0(); volumewidget0.text = pulseaudio.volumeInfo0() end)
    ))

    volumewidget0.text = pulseaudio.volumeInfo0()
    volumetimer = timer({ timeout = 30 })
    volumetimer:add_signal("timeout", function() volumewidget0.text = pulseaudio.volumeInfo0() end)
    volumetimer:start()

    volumewidget1 = widget({
        type = "textbox",
        name = "volumewidget1",
        align = "right"
    })

    volumewidget1:buttons(awful.util.table.join(
      awful.button({ }, 1, function() pulseaudio.SwitchTo(1); end),
      awful.button({ }, 3, function() pulseaudio.SwitchTo(1); end),
      awful.button({ }, 4, function() pulseaudio.volumeUp1(); volumewidget1.text = pulseaudio.volumeInfo1() end),
      awful.button({ }, 5, function() pulseaudio.volumeDown1(); volumewidget1.text = pulseaudio.volumeInfo1() end)
    ))

    volumewidget1.text = pulseaudio.volumeInfo1()
    volumetimer1 = timer({ timeout = 31 })
    volumetimer1:add_signal("timeout", function() volumewidget1.text = pulseaudio.volumeInfo1() end)
    volumetimer1:start()

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 5, awful.tag.viewnext),
                    awful.button({ }, 4, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
        volumewidget0,
        volumewidget1,
--        pintaskwidget0,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft,
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show(true)        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey, "Control" }, "Return",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey, "Control" }, "t", function () awful.util.spawn(monitor_off) end),
    awful.key({ modkey, "Shift" }, "t", function () awful.util.spawn(monitor_on) end),
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),
    awful.key({ modkey,"Shift","Control" },            "z", function () awful.util.spawn('sudo systemctl suspend') end),
    awful.key({ modkey },            "g", function () awful.util.spawn('/usr/bin/shutter -f') end),
    awful.key({ modkey },            "a", function () awful.util.spawn('gnome-calculator') end),
    awful.key({ modkey },            "s", function () awful.util.spawn('pavucontrol') end),

    awful.key({ modkey, "Shift" }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey            }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey,           }, "Tab",    function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
    properties = { border_width = beautiful.border_width,
    border_color = beautiful.border_normal,
    focus = true,
    keys = clientkeys,
    buttons = clientbuttons } },
--    { rule = { class = "Google-chrome" },
--    properties = { tag = tags[1][2] } },
    { rule = { class = "Pidgin" },
    properties = { tag = tags[1][9] } },
--  callback = function(c)
--        c:tags({tags[1][9], tags[2][9]})
--    end },
    { rule = { class = "skype" },
    properties = { tag = tags[1][8] } },
    { rule = { class = "qutecom" },
    properties = { tag = tags[1][9] } },
    { rule = { class = "pcmanfm" },
    properties = { tag = tags[1][6] } },
    { rule = { class = "Gnome-alsamixer" },
    properties = { tag = tags[1][6] } },
    { rule = { class = "Gitg" },
    properties = { tag = tags[1][3] } },
    { rule = { class = "Viber" },
    properties = { tag = tags[1][8] } },
    { rule = { class = "Pavucontrol" },
    properties = { tag = tags[1][6] } },
    { rule = { class = "empathy" },
    properties = { tag = tags[1][8] } },
    { rule = { class = "Pcmanfm" },
    properties = { tag = tags[1][6] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
--    -- Add a titlebar
--    -- awful.titlebar.add(c, { modkey = modkey })
--
--    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Autorun programs
autorun = true
autorunApps =
{
    "rescuetime",
    "x-www-browser",
    "pavucontrol",
    "pidgin",
    "workrave",
    "/opt/viber/Viber",
    "pcmanfm",
    "/usr/bin/xrandr --output HDMI-0 --auto --primary --output VGA-0 --mode 1280x800 --below HDMI-0",
    "/home/iv/bin/xflux -l 60 -g 60 -k 5000",
    "shutter"
}
function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
    findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

if autorun then
   for app = 1, #autorunApps do
       run_once(autorunApps[app])
   end
end
