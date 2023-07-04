local repo = "https://raw.githubusercontent.com/slimit75/FindShop/main/"

function install_file(path)
    local fetchReq = http.get(repo .. path)
    contents = fetchReq.readAll()
    fetchReq.close()

    local file = fs.open(path, "w")
    file.write(contents)
    file.close()
end

print("Updating/Installing FindShop Server...")
install_file("LICENSE")
install_file("README.md")
install_file("findshop/chatboxd.lua")
install_file("findshop/monitord.lua")
install_file("startup/findshop.lua")
