# FindShop
FindShop is a chatbox service for SwitchCraft 3 which monitors for broadcast shop information using the [ShopSync](https://p.sc3.io/7Ae4KxgzAM) protocol. It then caches this information, and when a user calls `\findshop` it returns shops based on the parameters passed.

## Usage
### `\findshop <item>` or `\findshop buy <item>`
Finds shops with `<item>` and returns the shop name, location, item price & quantity in stock.
### `\findshop sell <item>`
Finds shops buying `<item>` and returns the shop name, location and item price.
### `\findshop shop <name>`
Finds shops with `<name>` and returns the owner, location, and other statistics.