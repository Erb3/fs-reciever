--[[
    FindShop Chatbox Daemon
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

function genCoords(location)
    local shopLocation = "Unknown"
    if (location) then
        if (location.coordinates) then
            shopLocation = location.coordinates[1] .. ", " .. location.coordinates[3]
        elseif (location.description) then
            shopLocation = "'" .. location.description .. "'"
        end
    end

    return shopLocation
end

findshop.infoLog("chatboxd", "Started chatboxd")
while true do
    local event, user, command, args = os.pullEvent("command")

    if arrayContains(aliases, command) then
        if (findshop.mx) then
            chatbox.tell(user, "*WARNING: FindShop is in maintenance mode. Something is probably being added or debugged, so don't be surprised if anything breaks!*", BOT_NAME, nil)
        end

        if (#args == 0) or (args[1] == "help") then
            chatbox.tell(user, "FindShop is a service to locate any shops buying or selling an item. We have a few subcommands, too: \n`\\fs list` - List detected shops\n`\\fs stats` - Statistics (currently only shop count)\n`\\fs <item>` - Finds *<item>*" , BOT_NAME, nil)
        elseif #args > 1 then
            chatbox.tell(user, "**Error!** FindShop does not currently support multiple search parameters.", BOT_NAME,  nil)
        elseif findshop.shops == {} then
            chatbox.tell(user, "**Error!** FindShop was unable to find any shops. Read [here](" .. HELP_LINK .. ") about why this may be the case.", BOT_NAME, nil)
        elseif args[1] == "list" then
            local printResults = ""

            for _, shop in ipairs(findshop.shops) do
                printResults = printResults .. "\n**" .. shop.info.name .. "** at `" .. genCoords(shop.info.location) .. "`"
            end

            chatbox.tell(user, "FindShop found the following shops: \n" .. printResults, BOT_NAME, nil)
        elseif args[1] == "stats" then
            chatbox.tell(user, "We are currently tracking `" .. #findshop.shops .. "` shops.", BOT_NAME, nil)
        else
            findshop.infoLog("chatboxd", "Searching for " .. args[1] .. "...")
            results = {}

            for _, shop in ipairs(findshop.shops) do
                for _, item in ipairs(shop.items) do
                    if string.find(item.item.name, args[1]) and (item.shopBuysItem ~= true) then
                        priceKST = 0
                        for _, price in ipairs(item.prices) do
                            if price.currency == "KST" then
                                priceKST = price.value
                                break
                            end
                        end

                        table.insert(results, {
                            shop = {
                                name = shop.info.name,
                                owner = shop.info.owner,
                                location = genCoords(shop.info.location)
                            },
                            price = priceKST,
                            item = item
                        })
                    end
                end
            end

            if #results == 0 then
                chatbox.tell(user, "**Error!** FindShop was unable to find any shops with '`" .. args[1] .. "`'. Read [here](" .. HELP_LINK .. ") about why this may be the case.", BOT_NAME, nil)
            elseif #results >= 5 then
                local printResults = ""

                for i, result in ipairs(results) do
                    if i <= 5 then
                        printResults = printResults .. "\n`" .. result.item.item.name .. "` at **" .. result.shop.name .. "** (`" .. result.shop.location .. "`) for `" .. result.price .. "` KST (`" .. result.item.stock .. "` in stock)"
                    end
                end

                chatbox.tell(user, "**Note:** Too many results found. Shorting the list to the first 5 results.\nHere's what we found for '`" .. args[1] .. "`': " .. printResults, BOT_NAME, nil)
            else
                local printResults = ""

                for _, result in ipairs(results) do
                    printResults = printResults .. "\n`" .. result.item.item.name .. "` at **" .. result.shop.name .. "** (`" .. result.shop.location .. "`) for `" .. result.price .. "` KST (`" .. result.item.stock .. "` in stock)"
                end

                chatbox.tell(user, "Here's what we found for '`" .. args[1] .. "`': " .. printResults, BOT_NAME, nil)
            end
        end
     end
end
