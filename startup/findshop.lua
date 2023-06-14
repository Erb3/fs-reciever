parallel.waitForAny(
    function()
        shell.run("/findshop/chatbox.lua")
        print("Chatbox Crashed!")
    end,
    function()
        shell.run("/findshop/shop_sniffer.lua")
        print("Shop Sniffer Crashed!")
    end
)