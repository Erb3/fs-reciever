# FindShop Reciever Server
FindShop is a chatbox service for [SwitchCraft](https://github.com/slimit75/fs-chatbox) which monitors for broadcast shop information using the [ShopSync](https://p.sc3.io/7Ae4KxgzAM) standard. It stores this information, then when a user calls `\findshop` it returns shops and items based on the parameters passed.

This is the in-game server which reads the broadcast messages and saves them. This does *not* handle the chatbox commands, that function is handled by [fs-chatbox](https://github.com/slimit75/fs-chatbox).