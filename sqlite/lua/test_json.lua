local csv  = require('csv')
ngx.say(package.path)
 local file = csv.open("./utils/data/greece_listings.csv",{header=true})
-- local file_data = {}

-- local insert_stmt = db_json:prepare("INSERT INTO host VALUES (NULL, ?)")

-- local function insert(data)
--    local r = insert_stmt:bind_values(data)
--    if r~=0 then
--       ngx.log(ngx.ERR,r)      
--    end
--    insert_stmt:step()
--    insert_stmt:reset()
-- end

-- for field in file:lines() do
--    insert(cjson.encode(field))
--    table.insert(file_data,field)
-- end

-- ngx.header.content_type = "application/json"
ngx.say("done")
