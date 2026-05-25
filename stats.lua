-- claudefm — reads a stats file every second and updates force-media-title
-- The bash poller writes a status line (e.g. "🎧 556 ▁▂▃▅▇▆▅  ·  on for 23h 14m")
-- which this script surfaces into mpv's `${media-title}` for the terminal status line.

local status_file = mp.get_opt("statspath")
if not status_file or status_file == "" then return end

mp.add_periodic_timer(1, function()
    local f = io.open(status_file, "r")
    if not f then return end
    local line = f:read("*l")
    f:close()
    if line and line ~= "" then
        mp.set_property("force-media-title", line)
    end
end)
