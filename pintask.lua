local io = io
local string=string
local coroutine=coroutine
local json = require ("dkjson")

module("pintask")

function Start()
    local g = io.popen("/usr/bin/curl -m 5 https://pintask.me/api/v1/R2zjfLefCgm4uwySt4zGkgpePkyGe6bKnM/timetracking/set/on")
    local mute = g:read()
    g:close()
end

function Stop()
    local g = io.popen("/usr/bin/curl -m 5 https://pintask.me/api/v1/R2zjfLefCgm4uwySt4zGkgpePkyGe6bKnM/timetracking/set/off")
    local mute = g:read()
    g:close()
end

function Status()
    local sts=" UNK "
    local g = io.popen("/usr/bin/curl -s -m 5  https://pintask.me/api/v1/R2zjfLefCgm4uwySt4zGkgpePkyGe6bKnM/timetracking/status ")
    local mute = g:read()
    g:close()
    local obj, pos, err = json.decode (mute, 1, nil)
    if obj.paused==false then
        local name = obj.card.name
        if name:len()>15 then
            sts=  "[ " .. string.sub(name,1,12) .. " .. ]"
        else
            sts=  "[ " .. name .. " ]"
        end
    else
        sts= " STP "
    end
    if sts=="" then
        sts=" UNK "
    end
    return sts
end
