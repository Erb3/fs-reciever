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

_G.findshop = {
    shops = {},
    api = {
        endpoint = "https://us-east-1.aws.data.mongodb-api.com/app/data-wcgdk/endpoint/data/v1",
        key = ""
    }
}

function _G.findshop.infoLog(service, text)
    local x, y = term.getCursorPos()
    term.setCursorPos(1, y)
    term.blit("[ INFO ]", "00333300", "ffffffff")
    term.setCursorPos(10, y)
    term.setTextColor(colors.lightGray)
    term.write(service)
    term.setTextColor(colors.white)
    print(": " .. text)
end
findshop.infoLog("FindShop", "Starting FindShop")

local tempFile = fs.open("/findshop/.MDB_API_KEY", "r")
findshop.api.key = tempFile.readAll()
tempFile.close()

local function fs_run(filePath)
    local file = fs.open(filePath, "r")
    local code = file.readAll()
    file.close()

    local func, msg = load(code, nil, 't', _G)
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