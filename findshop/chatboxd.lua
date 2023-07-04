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
local HELP_LINK = "https://github.com/slimit75/FindShop/wiki/Why-are-shops-and-items-missing%3F"

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
    if location then
        if location.coordinates then
            shopLocation = location.coordinates[1] .. ", " .. location.coordinates[2].. ", " .. location.coordinates[3]
        elseif location.description then
            shopLocation = location.description
        end
    end

    return shopLocation
end

findshop.infoLog("chatboxd", "Started chatboxd")
while true do
    local event, user, command, args = os.pullEvent("command")

    if arrayContains({"findshop", "fs", "find"}, command) then
        if #args == 0 or args[1] == "help" then
            chatbox.tell(user, "FindShop is a service to locate any shops buying or selling an item. We have a few subcommands, too: \n`\\fs list` - List detected shops\n`\\fs stats` - Statistics (currently only shop count)\n`\\fs buy <item>` - Finds shops selling *<item>*\n`\\fs sell <item>` - Finds shops buying *<item>*\n`\\fs shop <name>` - Finds shops named *<name>* and their info" , BOT_NAME, nil)
        elseif #findshop.shops == 0 then
            chatbox.tell(user, "**Error!** FindShop was unable to find any shops. Something has to be seriously wrong.", BOT_NAME, nil)
        elseif args[1] == "list" or args[1] == "l" then
            local printResults = ""

            for _, shop in ipairs(findshop.shops) do
                printResults = printResults .. "\n**" .. shop.info.name .. "** at `" .. genCoords(shop.info.location) .. "`"
            end

            chatbox.tell(user, "FindShop found the following shops: \n" .. printResults, BOT_NAME, nil)
        elseif args[1] == "stats" then
            chatbox.tell(user, "We are currently tracking `" .. #findshop.shops .. "` shops.", BOT_NAME, nil)
        elseif args[1] == "buy" or args[1] == "b" or #args == 1 then
            search_item = args[1]
            if #args > 1 then
                search_item = args[2]
            end
            findshop.infoLog("chatboxd", "Searching for a shop with '" .. search_item .. "''...")
            local results = {}

            for _, shop in ipairs(findshop.shops) do
                for _, item in ipairs(shop.items) do
                    if (string.find(item.item.name:lower(), search_item:lower()) or string.find(item.item.displayName:lower(), search_item:lower())) and (not item.shopBuysItem) and (item.stock ~= 0 or item.madeOnDemand) then
                        priceKST = 0
                        for _, price in ipairs(item.prices) do
                            if price.currency == "KST" then
                                priceKST = price.value

                                if (item.dynamicPrice) then
                                    priceKST = priceKST .. "*"
                                end

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
                chatbox.tell(user, "**Error!** FindShop was unable to find any shops with '`" .. search_item .. "`' in stock. [Why are shops and items missing?](" .. HELP_LINK .. ")", BOT_NAME, nil)
            else
                local printResults = ""

                if #results >= 5 then
                    for i, result in ipairs(results) do
                        if i <= 5 then
                            printResults = printResults .. "\n`" .. result.item.item.name .. "` at **" .. result.shop.name .. "** (`" .. result.shop.location .. "`) for `" .. result.price .. "` KST (`" .. result.item.stock .. "` in stock)"
                        end
                    end

                    chatbox.tell(user, "**Note:** Too many results found. Shorting the list to the first 5 results.")
                else
                    for _, result in ipairs(results) do
                        printResults = printResults .. "\n`" .. result.item.item.name .. "` at **" .. result.shop.name .. "** (`" .. result.shop.location .. "`) for `" .. result.price .. "` KST (`" .. result.item.stock .. "` in stock)"
                    end
                end

                chatbox.tell(user, "Here's what we found for '`" .. search_item .. "`': " .. printResults, BOT_NAME, nil)
            end
        elseif args[1] == "sell" or args[1] == "sl" then
            search_item = args[2]
            findshop.infoLog("chatboxd", "Searching for a sellshop with '" .. search_item .. "''...")
            local results = {}

            for _, shop in ipairs(findshop.shops) do
                for _, item in ipairs(shop.items) do
                    if (string.find(item.item.name:lower(), search_item:lower()) or string.find(item.item.displayName:lower(), search_item:lower())) and (item.shopBuysItem) then
                        priceKST = 0
                        for _, price in ipairs(item.prices) do
                            if price.currency == "KST" then
                                priceKST = price.value

                                if (item.dynamicPrice) then
                                    priceKST = priceKST .. "*"
                                end

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
                chatbox.tell(user, "**Error!** FindShop was unable to find any shops with '`" .. search_item .. "`' in stock. [Why are shops and items missing?](" .. HELP_LINK .. ")", BOT_NAME, nil)
            else
                local printResults = ""

                if #results >= 5 then
                    for i, result in ipairs(results) do
                        if i <= 5 then
                            printResults = printResults .. "\n`" .. result.item.item.name .. "` at **" .. result.shop.name .. "** (`" .. result.shop.location .. "`) for `" .. result.price .. "` KST"
                        end
                    end

                    chatbox.tell(user, "**Note:** Too many results found. Shorting the list to the first 5 results.")
                else
                    for _, result in ipairs(results) do
                        printResults = printResults .. "\n`" .. result.item.item.name .. "` at **" .. result.shop.name .. "** (`" .. result.shop.location .. "`) for `" .. result.price .. "` KST"
                    end
                end

                chatbox.tell(user, "Here's what we found for '`" .. search_item .. "`': " .. printResults, BOT_NAME, nil)
            end
        elseif args[1] == "shop" or args[1] == "sh" then
            search_name = args[2]
            findshop.infoLog("chatboxd", "Searching for a shop named '" .. search_name .. "'...")
            local results = {}

            for _, shop in ipairs(findshop.shops) do
                if string.find(shop.info.name:lower(), search_name:lower()) then
                    table.insert(results, shop)
                end
            end

            if #results == 0 then
                chatbox.tell(user, "**Error!** FindShop was unable to find any shops named '`" .. search_name .. "`'. [Why are shops and items missing?](" .. HELP_LINK .. ")", BOT_NAME, nil)
            else
                local printResults = ""

                if (#results > 1 and not args[3]) or (args[3] and (tonumber(args[3]) > #results)) then
                    for i, result in ipairs(results) do
                        printResults = printResults .. "\n(`" .. i .. "`) " .. result.info.name
                    end

                    chatbox.tell(user, "Multiple shops were found. Run `\\fs sh " .. search_name .. " <number>` to see specific information." .. printResults)
                else
                    display_shop_idx = 1
                    if args[3] then
                        display_shop_idx = tonumber(args[3])
                    end

                    display_shop = results[display_shop_idx]

                    printResults = "**" .. display_shop.info.name .. "**"

                    if (display_shop.info.owner) then
                        printResults = printResults .. " *by " .. display_shop.info.owner .. "*"
                    end

                    printResults = printResults .. "\n"

                    if (display_shop.info.location) then
                        printResults = printResults .. "Located at `" .. genCoords(display_shop.info.location) .. "`"

                        if (display_shop.info.location.dimension) then
                            printResults = printResults .. " in the `" .. display_shop.info.location.dimension .. "`"
                        end

                        if (display_shop.info.otherLocations) then
                            printResults = printResults .. " + `" .. #display_shop.info.otherLocations .. "` other locations"
                        end

                        printResults = printResults .. "\n"
                    end

                    if (display_shop.info.software) then
                        printResults = printResults .. "Running `" .. display_shop.info.software.name .. "`"

                        if (display_shop.info.software.version) then
                            printResults = printResults .. " v`" .. display_shop.info.software.version .. "`"
                        end

                        printResults = printResults .. "\n"
                    end

                    printResults = printResults .. "Selling `" .. #display_shop.items .. "` items"

                    chatbox.tell(user, printResults)
                end
            end
        end
     end
end
