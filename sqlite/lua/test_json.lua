local sqlite3 = require("./utils/ulua/lsqlite3complete/0_9_4+203/Linux/x64/-lsqlite3complete")
local csv  = require("csv/1+103/")
local file = csv.open("./utils/data/greece_listings.csv",{header=true})
local file_data = {}
local db_ptr = sqlite3.open_ptr(db_json_ptr)

local insert_stmt = db_ptr:prepare("INSERT INTO host VALUES (NULL, ?)")

local function insert(data)
   local r = insert_stmt:bind_values(data)
   if r~=0 then
      ngx.log(ngx.ERR,r)      
   end
   insert_stmt:step()
   insert_stmt:reset()
   ngx.log(ngx.ERR,db_ptr:errmsg())
end

for field in file:lines() do
   insert(cjson.encode(field))
   table.insert(file_data,field)
end

ngx.header.content_type = "application/json"
ngx.say("done")
