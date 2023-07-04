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
local fetchReq = http.post(
    findshop.api.endpoint .. "/action/find",
    textutils.serializeJSON({
        dataSource = "Cluster0",
        database = "Main_DB",
        collection = "Main DB",
        filter = {}
    }),
    {
      ["Content-Type"] = "application/json",
      ["api-key"] = findshop.api.key
    }
)

local shopList = fetchReq.readAll()
fetchReq.close()

findshop.shops = textutils.unserializeJSON(shopList).documents
findshop.infoLog("monitord", "Restored " .. #findshop.shops .. " shops from MongoDB.")

-- Loop to check for shops continously
findshop.infoLog("monitord", "Started monitord")
while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    -- Verify received message is valid
    if (message.type) and (message.type == "ShopSync") then
        -- Check to see if this shop already exists in the cache
        local index = nil
        message.findShop = {
            computerID = replyChannel,
            shopIndex = message.info.multiShop,
            lastSeen = os.epoch("utc")
        }
        for i, shop in ipairs(findshop.shops) do
            if message.findShop.computerID == shop.findShop.computerID then
                if message.findShop.shopIndex then
                    if message.findShop.shopIndex == shop.findShop.shopIndex then
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
            local postReq = http.post(
                findshop.api.endpoint .. "/action/insertOne",
                textutils.serializeJSON({
                    dataSource = "Cluster0",
                    database = "Main_DB",
                    collection = "Main DB",
                    document = message
                }),
                {
                    ["Content-Type"] = "application/json",
                    ["api-key"] = findshop.api.key
                }
            )
            postReq.close()
        else
            local postReq = http.post(
                findshop.api.endpoint .. "/action/updateOne",
                textutils.serializeJSON({
                    dataSource = "Cluster0",
                    database = "Main_DB",
                    collection = "Main DB",
                    filter = { 
                        _id = { 
                            ["$oid"] = findshop.shops[index]._id 
                        } 
                    },
                    update = {
                        ["$set"] = message
                    }
                }),
                {
                    ["Content-Type"] = "application/json",
                    ["api-key"] = findshop.api.key
                }
            )
            postReq.close()

            findshop.shops[index] = message
        end
    end
end