-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local vicious = require("vicious")

local fixwidthtextbox = require("fixwidthtextbox")

awful.screen.focus(screen.count())

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
    awesome.connect_signal("debug::error", function (err)
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

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/wdy/.config/awesome/themes/zenburn/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "sakura"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
--    awful.layout.suit.floating,
    awful.layout.suit.tile,
--    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
--    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
--    awful.layout.suit.spiral,
--    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
--    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
    for s = 1, screen.count() do
        gears.wallpaper.maximized("/home/wdy/.config/awesome/themes/zenburn/20125120295722.jpg", s, true)
    end
-- }}}

mywpsmenu =	{ 
	{ "Word", "wps", },
	{ "Excel", "et", },
	{ "Powerpoint", "wpp", }
    }

mymainmenu = awful.menu({ items = 
	{ 
    {"Power Off", "poweroff" },
    {"Reboot", "reboot" },
	{ "Terminal", terminal, beautiful.menu_terminal},
	{ "Chrome", "google-chrome",},
    { "Gvim", "gvim", },
    { "Krusader", "krusader", },
	{ "Win7", "VirtualBox --startvm Win7", },
    { "WPS", mywpsmenu, },
    {"Log Out", awesome.quit },
    }
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox

-- {{{ Volume Controller
function volumectl (mode, widget)
    if mode == "update" then
        local f = io.popen("pamixer --get-volume")
        local volume = f:read("*all")
        f:close()
        if not tonumber(volume) then
            widget:set_markup("<span color='red'>ERR</span>")
            do return end
        end
        volume = string.format("% 3d", volume)

        f = io.popen("pamixer --get-mute")
        local muted = f:read("*all")
        f:close()
        if muted == "false\n" then
            volume = '♫' .. volume .. "%"
        else
            volume = '♫' .. volume .. "<span color='red'>M</span>"
        end
        widget:set_markup(volume)
    elseif mode == "up" then
        local f = io.popen("pamixer --allow-boost --increase 5")
        f:read("*all")
        f:close()
        volumectl("update", widget)
    elseif mode == "down" then
        local f = io.popen("pamixer --allow-boost --decrease 5")
        f:read("*all")
        f:close()
        volumectl("update", widget)
    else
        local f = io.popen("pamixer --toggle-mute")
        f:read("*all")
        f:close()
        volumectl("update", widget)
    end
end
volume_clock = timer({ timeout = 10 })
volume_clock:connect_signal("timeout", function () volumectl("update", volumewidget) end)
volume_clock:start()

volumewidget = fixwidthtextbox('(volume)')
volumewidget.width = 48
volumewidget:set_align('right')
volumewidget:buttons(awful.util.table.join(
    awful.button({ }, 4, function () volumectl("up", volumewidget) end),
    awful.button({ }, 5, function () volumectl("down", volumewidget) end),
    awful.button({ }, 3, function () awful.util.spawn("pavucontrol") end),
    awful.button({ }, 1, function () volumectl("mute", volumewidget) end)
))
volumectl("update", volumewidget)
--}}}

-- Create a textclock widget
mytextclock = awful.widget.textclock(" %a %m月%d日 %H:%M:%S ", 1)

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
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
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
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == screen.count() then right_layout:add(wibox.widget.systray()) end
    right_layout:add(volumewidget)
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ '|1.Term', '|2.Gvim', '|3.Web' ,'|4.Edit', '|5.File', '|6.Win7', '|7.Other' }, s, layouts[3])
end

function setRules(s)
	awful.rules.rules = {
		-- All clients will match this rule.
		{ rule = { },
		  properties = { border_width = beautiful.border_width,
						 border_color = beautiful.border_normal,
						 floating = false,
						 focus = true,
						 keys = clientkeys,
						 floating = false,
						 buttons = clientbuttons,
						 switchtotag = true,
						 tag = tags[s][7]
						 }},
		{ rule = { type = "normal" },
		  properties = {floating = false}
		},
		{ rule = { class = "Sakura" },
		properties = {tag = tags[s][1]}},
		{ rule = { class = "Gvim" },
		properties = {tag = tags[s][2]}},
		{ rule = { class = "Google-chrome" },
		properties = {tag = tags[s][3], floating = true}},
		{ rule = { role = "browser" },
		properties = {tag = tags[s][3], floating = false}},
		{ rule = { class = "Gedit" },
		properties = {tag = tags[s][4]}},
		{ rule = { class = "Evince" },
		properties = {tag = tags[s][4]}},
		{ rule = { class = "Et" },
		properties = {tag = tags[s][4], floating = true}},
		{ rule = { class = "Wpp" },
		properties = {tag = tags[s][4], floating = true}},
		{ rule = { class = "Wps" },
		properties = {tag = tags[s][4], floating = true}},
		{ rule = { class = "Krusader" },
		properties = {tag = tags[s][5]}},
		{ rule = { class = "File-roller" },
		properties = {tag = tags[s][5]}},
		{ rule = { class = "VirtualBox" },
		properties = {tag = tags[s][6], floating = false}}
	}
end

setRules(screen.count())

client.connect_signal("focus", function(c) setRules(c.screen) end)
root.buttons(awful.util.table.join(
    awful.button({ }, 1, function () setRules(mouse.screen) end),
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

-- }}}


-- {{{ Key bindings
key_down = {"1", "2", "3", "4", "q", "w", "e"}

globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    ---awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "s",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "a",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "d", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey,           }, "Tab", function () awful.screen.focus_relative( 1); setRules(mouse.screen) end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey, "Control"   }, "a", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Control"   }, "s", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, }, "p",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey, }, "o",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, }, "p",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, }, "o",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "p",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "o",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey, "Control", "Shift" }, "r",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey, "Control" }, "r", function() menubar.show() end),

    -- Volume
    awful.key({ }, 'XF86AudioRaiseVolume', function () volumectl("up", volumewidget) end),
    awful.key({ }, 'XF86AudioLowerVolume', function () volumectl("down", volumewidget) end),
    awful.key({ }, 'XF86AudioMute', function () volumectl("mute", volumewidget) end),

        awful.key({ modkey }, "`",
                  function ()
			awful.util.spawn_with_shell("sakura")
                  end),
        awful.key({ modkey }, "Escape",
                  function ()
			awful.util.spawn_with_shell("/home/wdy/shot.sh")
                  end)

)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "x",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey, "Control" }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey, "Control" }, "Tab",
        function (c)
            if screen.count() == 1 then
                return
            end
            local tag_idx = awful.tag.getidx(awful.tag.selected(client.focus.screen))
            local c_tag = c:tags()[1]
            local cs_index = client.focus and client.focus.screen or mouse.screen
            local target_screen_index = cs_index % screen:count() + 1
            awful.tag.viewonly(tags[target_screen_index][tag_idx]) -- prepare target tag/screen
                awful.client.movetoscreen(c, target_screen_index) -- default to screen + 1
                awful.client.movetotag(tags[cs_index % screen:count() + 1][tag_idx], c)
            awful.tag.viewonly(tags[client.focus.screen][tag_idx])
        end),
    awful.key({ modkey, "Shift"}, "Tab", function (c)
        if screen.count() == 1 then
            return
        end
        awful.client.movetoscreen(c)
    end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, key_down[i],
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Shift" }, key_down[i],
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end)
				  )
        clientkeys = awful.util.table.join(clientkeys, awful.key({ modkey, "Control" }, key_down[i],
                  function (c)
	awful.client.movetotag(tags[mouse.screen][i], c)
      awful.tag.viewonly(tags[mouse.screen][i])
					  end
                  ))
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
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
 --   c:connect_signal("mouse::enter", function(c)
 --       if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
 --           and awful.client.focus.filter(c) then
 --           client.focus = c
 --       end
 --  end)

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

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}



-- MyScript

--auto run app
--awful.util.spawn_with_shell("feh --bg-scale /home/wdy/background.jpg")
mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

setRules(screen.count())

-- }}}

---awful.util.spawn_with_shell("fcitx")
awful.util.spawn_with_shell("nm-applet")
awful.util.spawn_with_shell("xfce4-power-manager")
awful.util.spawn_with_shell("sleep 1; xmodmap /home/wdy/.Xmodmaprc")
awful.util.spawn_with_shell("wallproxy")
awful.util.spawn_with_shell("mail-notification")
awful.util.spawn("sakura")
