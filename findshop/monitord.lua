--[[
    FindShop Monitor Daemon
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

-- Load & open modem to ShopSync channel
local modem = peripheral.wrap("top")
modem.open(9773)

-- Read cache, if it exists
local CACHE_FP = "/findshop/cache.json"

if fs.exists(CACHE_FP) then
    local tempFile = fs.open(CACHE_FP, "r")
    local cache = tempFile.readAll()
    tempFile.close()

    findshop.shops = textutils.unserializeJSON(cache)
    findshop.infoLog("monitord", "Restored " .. #findshop.shops .. " shops from cache.")
end

-- Loop to check for shops continously
findshop.infoLog("monitord", "Started monitord")
while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    -- Verify received message is valid
    if (message.type) and (message.type == "ShopSync") then
        -- Check to see if this shop already exists in the cache
        index = nil
        message.findShop = {
            computerID = replyChannel,
            shopIndex = message.info.multiShop
        }
        for i, shop in ipairs(findshop.shops) do
            if (message.findShop.computerID == shop.findShop.computerID) then
                if (message.findShop.shopIndex) then
                    if (message.findShop.shopIndex == shop.findShop.shopIndex) then
                        index = i
                        break
                    end
                else
                    index = i
                    break
                end
            end
        end

        -- Add (updated?) shop to cache
        if index == nil then
            table.insert(findshop.shops, message)
            findshop.infoLog("monitord", "Found new shop! " .. message.info.name)

            -- Write cache
            local tempFile = fs.open(CACHE_FP, "w")
            tempFile.write(textutils.serializeJSON(findshop.shops))
            tempFile.close()
        else
            findshop.shops[index] = message
        end
    end
end