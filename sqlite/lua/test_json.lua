local sqlite3 = require("./utils/ulua/lsqlite3complete/0_9_4+203/Linux/x64/-lsqlite3complete")
local csv  = require("csv/1+103/")
local file = csv.open("./utils/data/greece_listings.csv",{header=true})
local file_data = {}

db_mem = sqlite3.open_memory()

for field in file:lines() do
   table.insert(file_data,field)
end
ngx.header.content_type = "application/json"
ngx.say(cjson.encode(file_data))
