local csv  = require("csv/1+103/")
local file = csv.open("./utils/data/greece_listings.csv",{header=true})
local file_data = {}

db_json:exec[[
  CREATE TABLE host (id INTEGER PRIMARY KEY, item TEXT );
]]

local insert_stmt = db_json:prepare("INSERT INTO host VALUES (NULL, ?)")

local function insert(data)
  insert_stmt:bind_values(data)
  insert_stmt:step()
  insert_stmt:reset()
end

for field in file:lines() do
   insert(cjson.encode(data_field))
   table.insert(file_data,field)
end

ngx.header.content_type = "application/json"
ngx.say(cjson.encode(file_data))
