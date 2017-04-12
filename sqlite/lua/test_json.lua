local csv  = require('csv')
local file = csv.open("./utils/data/greece_listings.csv",{header=true})

con_json:exec[[
  CREATE TABLE if not exists host (id INTEGER PRIMARY KEY, item TEXT );
]] 
   


local stmt = con_json:prepare("INSERT INTO host VALUES(NULL, ?)")

local function insert(data)
   stmt:reset():bind(data):step()
end

for field in file:lines() do
   insert(cjson.encode(field))
   table.insert(file_data,field)
end

ngx.header.content_type = "application/json"
ngx.say("done")
