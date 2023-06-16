--[[
    FindShop
    Copyright (C) 2023  slimit75

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
    colours = colours,
    io = io,
    print = print,
    os = os,
    chatbox = chatbox,
    peripheral = peripheral,
    findshop = {
        shops = {}
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