pcall(require, "luarocks.loader")
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = os.getenv("nvim") or "nvim"

modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
   awful.layout.suit.tile
}

awful.screen.connect_for_each_screen(function(s)
    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
 end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "o",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),

    
    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey }, "Right", function () awful.tag.incmwfact( 0.01) end),
    awful.key({ modkey }, "Left",  function () awful.tag.incmwfact(-0.01) end),
    awful.key({ modkey }, "Up", function ()  awful.client.incwfact(-0.01) end),
    awful.key({ modkey }, "Down", function ()  awful.client.incwfact(0.01) end),

    -- Prompt
    awful.key({ modkey },            "r",     function () 
        awful.util.spawn("rofi -show drun") end,
              {description = "run prompt", group = "launcher"}),

    -- Screenshot
    awful.key({},                    "Print", function()
    awful.util.spawn("flameshot gui -p /home/ellie/Pictures") end,
    	        {description = "screenshot", group = "launcher"}),

    -- Browser
    awful.key({ modkey },             "b",      function ()
    awful.util.spawn("firefox") end,
              {description = "browser", group = "launcher"}),

    -- Spotify
    awful.key({ modkey },             "s",      function ()
        awful.util.spawn("spotify") end,
                  {description = "spotify ad-block", group = "launcher"}),

    -- Media
    awful.key( { "Shift" },                  "F9",     function()
        awful.util.spawn("playerctl play-pause") end,
                {description = "pause/ play media", group = "launcher"}),

    awful.key( { "Shift" },                  "F10",     function()
        awful.util.spawn("playerctl stop") end,
                {description = "stop media", group = "launcher"}),

    awful.key( { "Shift" },                  "F11",     function()
        awful.util.spawn("playerctl previous") end,
                {description = "previous media", group = "launcher"}),

    awful.key( { "Shift" },                  "F12",     function()
        awful.util.spawn("playerctl next") end,
                {description = "pause/ play media", group = "launcher"})

    )


clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),

    awful.key({ modkey,    }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "client"})
    )

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"})
           )
end

root.keys(globalkeys)

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = 3,
                     border_color = "#cba6f7",
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    {
        rule_any = { class = {"Polybar"}},
        properties = { border_width = false }
    },

    -- Floating clients.
    { rule_any = {
        instance = {},
        class = {},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

  }


-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

-- Gaps
beautiful.useless_gap = 12

-- Auto
autorunApps = {
    "feh --bg-scale Pictures/celeste.png",
    "picom --experimental-backends",
    "unclutter -idle 3 &",
    "redshift -l 54:-1",
    "polkit-dumb-agent &",
    "dunst &"
}

for app = 1, #autorunApps do
    awful.spawn.single_instance(autorunApps[app], {})
end

