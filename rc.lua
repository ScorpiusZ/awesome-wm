require("awful")
require("awful.autofocus")
require("awful.rules")
require("beautiful")
require("naughty")
require("vicious")

-- Load Debian menu entries
require("debian.menu")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end


-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

--{{---| Theme |----------------------------------------------------------------------
config_dir = ("/home/scorpius/.config/awesome/")
themes_dir = (config_dir .. "/themes")
beautiful.init(themes_dir .. "/default/theme.lua")

--{{---| Variables |----------------------------------------------------------------------
modkey        = "Mod4"
terminal = "gnome-terminal "
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
browser       = "firefox"

--{{---| Couth Alsa volume applet |-----------------------------------------------------------------

--couth.CONFIG.ALSA_CONTROLS = { 'Master', 'PCM' }

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile.right,
    awful.layout.suit.floating,
    awful.layout.suit.tile.top,
    awful.layout.suit.magnifier
}
-- }}}

--{{---| Naughty theme |----------------------------------------------------------------------

naughty.config.default_preset.font         = beautiful.notify_font
naughty.config.default_preset.fg           = beautiful.notify_fg
naughty.config.default_preset.bg           = beautiful.notify_bg
naughty.config.presets.normal.border_color = beautiful.notify_border
naughty.config.presets.normal.opacity      = 0.8
naughty.config.presets.low.opacity         = 0.8
naughty.config.presets.critical.opacity    = 0.8

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 'Scorpius','Gemini','Cancer','Pisces','Capricorn','Libra'}, s, layouts[1])
end

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
    {" Edit config", "terminal -x vim /home/scorpius/.config/awesome/rc.lua"},
    {" Restart", awesome.restart },
    {" Reboot",  "sudo reboot"},
    {" Quit", "gnome-session-quit" }
}

mydevmenu = {
    {" Eclipse",              "/home/scorpius/Android/eclipse/eclipse", beautiful.eclipse_icon},
    {" Vim",                   "vim", beautiful.emacs_icon},
}

mywebmenu = {
    {" Chrome",               "google-chrome", beautiful.chromium_icon},
    {" Firefox",              "firefox", beautiful.firefox_icon}
}

mymainmenu = awful.menu({ 
    items = {
        {" Awesome", myawesomemenu, beautiful.awesome_icon },
        {" develop", mydevmenu, beautiful.mydevmenu_icon},
        {" web",     mywebmenu, beautiful.mywebmenu_icon},
        {" open terminal", terminal }
    }
})

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
menu = mymainmenu })

--{{---| Wibox |----------------------------------------------------------------------


mysystray = widget({ type = "systray" })
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                        awful.button({ }, 1, awful.tag.viewonly),
                        awful.button({ modkey }, 1, awful.client.movetotag),
                        awful.button({ }, 3, awful.tag.viewtoggle),
                        awful.button({ modkey }, 3, awful.client.toggletag),
                        awful.button({ }, 4, awful.tag.viewnext),
                        awful.button({ }, 5, awful.tag.viewprev)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

-- Time widget
datewidget = widget({ type = "textbox" })
-- Register widget
vicious.register(datewidget, vicious.widgets.date, '<span color="#FFD700" font="Terminus 8"> %m-%d  %a  %T </span>', 1)

-- Mem widget
memwidget = widget({ type = "textbox" })
vicious.register(memwidget, vicious.widgets.mem, 'Mem :<span color="#46A8C3" font="Terminus 8"> $1% </span> ', 10)

-- Cpu widget
cpuwidget = widget({ type = "textbox" })
vicious.register(cpuwidget, vicious.widgets.cpu, '  Cpu :<span color="#7AC82E" font="Terminus 8"> $1% </span>  ')

-- Net widget 
netwidget = widget({ type = "textbox" })
vicious.register(netwidget, 
vicious.widgets.net,
'<span background="#313131" font="Terminus 12"> <span font="Terminus 9" color="#7AC82E">${eth0 down_kb}</span> <span font="Terminus 9" color="#46A8C3">${eth0 up_kb}</span> </span>', 3)
neticon = widget ({type = "imagebox" })
neticon.image = image(beautiful.widget_net)
netwidget:buttons(awful.util.table.join(awful.button({ }, 1,
function () awful.util.spawn_with_shell(iptraf) end)))

--{{---| Music widget |----------------------------------------------------------------------

music = widget ({type = "imagebox" })
music.image = image(beautiful.widget_music)
music:buttons(awful.util.table.join(
  awful.button({ }, 1, function () awful.util.spawn_with_shell(musicplr) end),
  awful.button({ modkey }, 1, function () awful.util.spawn_with_shell("ncmpcpp toggle") end),
  awful.button({ }, 3, function () couth.notifier:notify( couth.alsa:setVolume('Master','toggle')) end),
  awful.button({ }, 4, function () couth.notifier:notify( couth.alsa:setVolume('PCM','2dB+')) end),
  awful.button({ }, 5, function () couth.notifier:notify( couth.alsa:setVolume('PCM','2dB-')) end),
  awful.button({ }, 4, function () couth.notifier:notify( couth.alsa:setVolume('Master','2dB+')) end),
  awful.button({ }, 5, function () couth.notifier:notify( couth.alsa:setVolume('Master','2dB-')) end)))

--{{---| Volume widget |----------------------------------------------------------------------

volumewidget = widget ({type = "imagebox" })
volumewidget.image = image(beautiful.widget_volume)

--{{---| Battery widget |----------------------------------------------------------------------

baticon = widget ({type = "imagebox" })
baticon.image = image(config_dir.."/icons/battery.png")
batwidget = widget({ type = "textbox" })
vicious.register( batwidget, vicious.widgets.bat, ' <span color="#CD69C9" font="Terminus 8"> $2% </span>', 10, "BAT0" )

--{{---| Separators widgets |-----------------------------------------------------------------------

spr = widget({ type = "textbox" })
spr.text = ' '
sprd = widget({ type = "textbox" })
sprd.text = '<span background="#313131" font="Terminus 12"> </span>'
sprdots = widget({ type = "textbox" })
sprdots.text = '⁝'
arrl = widget ({type = "imagebox" })
arrl.image = image(beautiful.arrl)
arrl_dl = widget ({type = "imagebox" })
arrl_dl.image = image(config_dir.."/icons/arrl_dl.png")
arrl_ld = widget ({type = "imagebox" })
arrl_ld.image = image(config_dir.."/icons/arrl_ld.png")
arrl_dfl = widget ({type = "imagebox" })
arrl_dfl.image = image(beautiful.arrl_dfl)
arrl_lfd = widget ({type = "imagebox" })
arrl_lfd.image = image(beautiful.arrl_lfd)

-- Create the wibox
mywibox[s] = awful.wibox({ position = "top",height= "20", screen = s })
-- Add widgets to the wibox - order matters
mywibox[s].widgets = {
    { mylauncher, mytaglist[s], mypromptbox[s], layout = awful.widget.layout.horizontal.leftright
    },
    mylayoutbox[s],
--    arrl_ld,
--    spr,
--    arrl_dl, 
    datewidget,
--    arrl_ld,
    memwidget,
--    arrl_dl, 
    cpuwidget,
--    arrl_ld,
--    neticon,
--    netwidget,
--    arrl_dl, 
    batwidget,
    baticon,
    s == 1 and mysystray or nil,
    mytasklist[s],
    layout = awful.widget.layout.horizontal.rightleft
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
    awful.key({ }, "Print", function ()
        awful.util.spawn("gnome-screenshot") end),
    awful.key({ }, "XF86AudioRaiseVolume", function ()
        awful.util.spawn("amixer set Master 4%+") end),
    awful.key({ }, "XF86AudioLowerVolume", function ()
        awful.util.spawn("amixer set Master 4%-") end),
    awful.key({ }, "XF86AudioMute", function ()
        awful.util.spawn("amixer -D pulse set Master 1+ toggle") end),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "t", function () awful.util.spawn(terminal) end),
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

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
              
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,          }, "q",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
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
    ---Multimedia keys
    --volume keys
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
                     buttons = clientbuttons,
                     size_hints_honor = false } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
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
-- Override awesome.quit when we're using GNOME
_awesome_quit = awesome.quit
awesome.quit = function()
    if os.getenv("DESKTOP_SESSION") ==
        "awesome-gnome" then
        os.execute("/usr/bin/gnome-session-quit")
    else
        _awesome_quit()
    end
end
