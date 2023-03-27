--[[
    ShopSync Monitor Daemon

    slimit75 2023
]]--

-- Load & open modem to ShopSync channel
local modem = peripheral.wrap("top")
modem.open(9773)

-- Global table to house the shops (will be accessed by findshopd)
_G.shops = {}

-- Loop to check for shops continously
while true do 
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    
    -- Verify received message is valid
    if (message.type == "ShopSync") then
        -- Check to see if this shop already exists in the cache
        index = nil
        for i = 1, #_G.shops do
            local coord = _G.shops[i].info.location.coordinates
            local scannedCoord = message.info.location.coordinates
            
            local x_check = coord[1] == scannedCoord[1]
            local y_check = coord[2] == scannedCoord[2]
            local z_check = coord[3] == scannedCoord[3]

            if x_check and y_check and z_check then
                index = i
                break
            end
        end
        
        -- Add (updated?) shop to cache
        if index == nil then
            table.insert(_G.shops, message)
        else
            _G.shops[index] = message
        end
    end
end
