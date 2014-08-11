local io = io
module("pintask")

function Start()
    local g = io.popen("/usr/bin/curl https://pintask.me/api/v1/R2zjfLefCgm4uwySt4zGkgpePkyGe6bKnM/timetracking/set/on")
    local mute = g:read()
    g:close()
end

function Stop()
    local g = io.popen("/usr/bin/curl https://pintask.me/api/v1/R2zjfLefCgm4uwySt4zGkgpePkyGe6bKnM/timetracking/set/off")
    local mute = g:read()
    g:close()
end
