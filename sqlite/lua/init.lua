cjson = require "cjson"
package.path = package.path .. ";./utils/ulua/?/init.lua;"
local sqlite3 = require("./utils/ulua/lsqlite3complete/0_9_4+203/Linux/x64/-lsqlite3complete")

db_json = sqlite3.open("json")
db_json_ptr = db_json:get_ptr()
db_json:exec[[
  CREATE TABLE host (id INTEGER PRIMARY KEY, item TEXT );
]]




