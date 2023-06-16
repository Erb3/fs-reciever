--[[
    FindShop Chatbox Daemon
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

local BOT_NAME = "&6&lFindShop"
local HELP_LINK = "https://github.com/sc-sdc/FindShop/wiki/Why-can't-I-find-X-or-Why-isn't-my-shop-appearing%3F"
local aliases = {"findshop", "fs", "find"}

function arrayContains(array, value)
    for i, item in ipairs(array) do
        if item == value then
            return true
        end
    end

    return false
end

while true do
    local event, user, command, args = os.pullEvent("command")

    if arrayContains(aliases, command) then
        if (#args == 0) or (args[1] == "help") then
            chatbox.tell(user, "FindShop is a service to locate any shops buying or selling an item. It won't find all shops though, so read [here](" .. HELP_LINK .. ") about how FindShop works and how shop owners can get their shops added." , BOT_NAME, nil)
        elseif #args > 1 then
            chatbox.tell(user, "**Error!** FindShop does not currently support multiple search parameters.", BOT_NAME,  nil)
        elseif findshop.shops == {} then
            chatbox.tell(user, "**Error!** FindShop was unable to find any shops. Read [here](" .. HELP_LINK .. ") about why this may be the case.", BOT_NAME, nil, "format")
        elseif args[1] == "list" then
            local printResults = ""

            for i = 1, #findshop.shops do
                local shopLocation = "Unknown"
                if (findshop.shops[i].info.location) then
                    shopLocation = findshop.shops[i].info.location.coordinates[1] .. ", " .. findshop.shops[i].info.location.coordinates[3]
                end

                printResults = printResults .. "\n**" .. findshop.shops[i].info.name .. "** at `" .. shopLocation .. "`"
            end

            chatbox.tell(user, "FindShop found the following shops: \n" .. printResults, BOT_NAME, nil)
        elseif args[1] == "stats" then
            chatbox.tell(user, "We are currently tracking `" .. #findshop.shops .. "` shops, with `" .. #findshop.uniqueItems .. "` unique items.", BOT_NAME, nil)
        else
            print("[DEBUG] Searching for " .. args[1] .. "...")
            results = {}

            for i = 1, #findshop.shops do
                for z = 1, #findshop.shops[i].items do
                    if string.find(findshop.shops[i].items[z].item.name, args[1]) and (findshop.shops[i].items[z].shopBuysItem ~= true) then
                        priceKST = 0
                        for y = 1, #findshop.shops[i].items[z].prices do
                            if findshop.shops[i].items[z].prices[y].currency == "KST" then
                                priceKST = findshop.shops[i].items[z].prices[y].value
                                break
                            end
                        end

                        local shopLocation = "Unknown"
                        if findshop.shops[i].info.location then
                            shopLocation = findshop.shops[i].info.location.coordinates[1] .. ", " .. findshop.shops[i].info.location.coordinates[3]
                        end

                        table.insert(results, {
                            shop = {
                                name = findshop.shops[i].info.name,
                                owner = findshop.shops[i].info.owner,
                                location = shopLocation
                            },
                            price = priceKST,
                            stock = findshop.shops[i].items[z].stock
                        })
                        break
                    end
                end
            end

            if #results == 0 then
                chatbox.tell(user, "**Error!** FindShop was unable to find any shops with the item: '" .. args[1] .. "'. Read [here](" .. HELP_LINK .. ") about why this may be the case.", BOT_NAME, nil)
            else
                local printResults = ""

                for i = 1, #results do
                    printResults = printResults .. "\n&3" .. results[i].shop.name .. " &o&7(" .. results[i].shop.location .. ") &a" .. results[i].price .. " KST &fx" .. results[i].stock
                end

                chatbox.tell(user, "FindShop found the following: " .. printResults, BOT_NAME, nil, "format")
            end
        end
     end
end
