--[[
	FindShop Reciever Server
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

-- Post the updated shop to MongoDB
function post_shop(message, replyChannel)
	-- Verify received message is valid
	if (message.type) and (message.type == "ShopSync") then
		-- Check to see if this shop already exists in the cache
		local index = nil
		message.findShop = {
			computerID = replyChannel,
			shopIndex = message.info.multiShop,
			lastSeen = os.epoch("utc")
		}

		-- Support for ShopSync >=1.1 computerID field
		if message.info.computerID then
			message.findShop.computerID = message.info.computerID
		end

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

		-- Specific exception for 'infinite prices' coming from umnikos.kst
		-- This took me 4 hours to diagnose and fix
		if (message.info.name) == "umnikos.kst" then
			for i in ipairs(message.items) do
				for v in ipairs(message.items[i].prices) do
					if (message.items[i].prices[v].value == 1/0) then
						message.items[i].prices[v].value = 0
					end
				end
			end
		end

		-- Add (updated?) shop to cache
		if index == nil then
			table.insert(findshop.shops, message)
			print("Found new shop! " .. message.info.name)

			-- Write cache
			local postReq = http.post(
				findshop.api.endpoint .. "/action/insertOne",
				textutils.serializeJSON({
					dataSource = dbSource,
					database = dbName,
					collection = dbCollection,
					document = message
				}),
				{
					["Content-Type"] = "application/json",
					["api-key"] = findshop.api.key
				}
			)
			postReq.close()
		else
			if (message.findShop.lastSeen - findshop.shops[index].findShop.lastSeen) > (30 * 1000) then
				local postReq = http.post(
					findshop.api.endpoint .. "/action/updateOne",
					textutils.serializeJSON({
						dataSource = dbSource,
						database = dbName,
						collection = dbCollection,
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
end

-- Error handler
function err_hndlr(err)
	term.blit("ERROR: ","fffff8f","eeeeeff")
	print(err)
end

-- Fetch the MongoDB API key
findshop = {
	shops = {},
	api = {
		endpoint = "https://us-east-1.aws.data.mongodb-api.com/app/data-wcgdk/endpoint/data/v1",
		key = ""
	}
}
local tempFile = fs.open("/.MDB_API_KEY", "r")
findshop.api.key = tempFile.readAll()
tempFile.close()

dbSource = "Cluster0"
dbName = "SC3"
dbCollection = "RawShops"

-- Load & open modem to ShopSync channel
local modem = peripheral.wrap("top")
modem.open(9773)

-- Print last update
shell.run("clear")
function printHeader()
	paintutils.drawLine(1, 1, 60, 1, colors.lightGray)
	local cacheX, cacheY = term.getCursorPos()
	term.setCursorPos(1, 1)
	term.setBackgroundColor(colors.lightGray)
	term.setTextColor(colors.white)
	term.write(os.date())
	term.setBackgroundColor(colors.black)
	term.setCursorPos(cacheX, cacheY)
end
printHeader()

-- Read cache, if it exists
local fetchReq = http.post(
	findshop.api.endpoint .. "/action/find",
	textutils.serializeJSON({
		dataSource = dbSource,
		database = dbName,
		collection = dbCollection,
		filter = {}
	}),
	{
		["Content-Type"] = "application/json",
		["api-key"] = findshop.api.key
	}
)
local shopList = fetchReq.readAll()
fetchReq.close()
for _, shop in ipairs(textutils.unserializeJSON(shopList).documents) do
	table.insert(findshop.shops, shop)
end
print("Restored " .. #findshop.shops .. " shops from MongoDB.")

-- Loop to check for shops continously
print("Started FindShop Reciever Server")
while true do
	local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

	xpcall(post_shop, err_hndlr, message, replyChannel)
	printHeader()
end