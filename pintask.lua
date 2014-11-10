local io = io
local string=string
module("pintask")

function Start()
    local g = io.popen("/usr/bin/curl -m 15 https://pintask.me/api/v1/R2zjfLefCgm4uwySt4zGkgpePkyGe6bKnM/timetracking/set/on")
    local mute = g:read()
    g:close()
end

function Stop()
    local g = io.popen("/usr/bin/curl -m 15 https://pintask.me/api/v1/R2zjfLefCgm4uwySt4zGkgpePkyGe6bKnM/timetracking/set/off")
    local mute = g:read()
    g:close()
end

function Status()
    local g = io.popen("/usr/bin/curl -s -m 15  https://pintask.me/api/v1/R2zjfLefCgm4uwySt4zGkgpePkyGe6bKnM/timetracking/status | jq .paused")
    local mute = g:read()
    g:close()
    if mute=="false" then
        local b = io.popen("/usr/bin/curl -s -m 15  https://pintask.me/api/v1/R2zjfLefCgm4uwySt4zGkgpePkyGe6bKnM/timetracking/status | jq .card.name")
        local name = b:read()
        b:close()
        return  "[ " .. string.sub(name,1,15) .. " \"]"
    else
        return " STP "
   end
end
