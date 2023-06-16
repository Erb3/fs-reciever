--[[
    FindShop - Maintenance Mode Setup
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
    mx = true
}

function findshop.infoLog(service, text)
    local x, y = term.getCursorPos()
    term.setCursorPos(1, y)
    term.blit("[ INFO ]", "00333300", "ffffffff")
    term.setCursorPos(10, y)
    term.setTextColor(colors.lightGray)
    term.write(service)
    term.setTextColor(colors.white)
    print(": " .. text)
end
findshop.infoLog("FindShop MX", "Initalizing FindShop MX Enviroment")

if fs.exists("/findshop/cache.json") then
    local tempFile = fs.open("/findshop/cache.json", "r")
    local cache = tempFile.readAll()
    tempFile.close()

    findshop.shops = textutils.unserializeJSON(cache)
    findshop.infoLog("FindShop MX", "Restored " .. #findshop.shops .. " shops from cache.")
end