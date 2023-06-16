--[[
    FindShop
    Copyright (C) 2023 slimit75

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]--

function infoLog(service, text)
    local x, y = term.getCursorPos()
    term.setCursorPos(1, y)
    term.blit("[ INFO ]", "00333300", "ffffffff")
    term.setCursorPos(10, y)
    term.setTextColor(colors.lightGray)
    term.write(service)
    term.setTextColor(colors.white)
    print(": " .. text)
end
infoLog("FindShop", "Starting FindShop")

local fs_env = {
    term = term,
    paintutils = paintutils,
    next = next,
    pairs = pairs,
    ipairs = ipairs,
    pcall = pcall,
    select = select,
    tonumber = tonumber,
    tostring = tostring,
    type = type,
    unpack = unpack,
    xpcall = xpcall,
    string = string,
    table = table,
    math = math,
    textutils = textutils,
    colors = colors,
    io = io,
    print = print,
    os = os,
    fs = fs,
    chatbox = chatbox,
    peripheral = peripheral,
    findshop = {
        shops = {},
        infoLog = infoLog
    }
}

local function fs_run(filePath)
    local file = fs.open(filePath, "r")
    local code = file.readAll()
    file.close()

    local func, msg = load(code, nil, 't', fs_env)
    if not func then
        return nil, msg
    end
    return xpcall(func, function(err) error(err) end)
end

parallel.waitForAny(
    function()
        fs_run("/findshop/chatboxd.lua")
        print("Chatbox Crashed!")
    end,
    function()
        fs_run("/findshop/monitord.lua")
        print("Shop Sniffer Crashed!")
    end
)