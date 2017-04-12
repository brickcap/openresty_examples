cjson = require "cjson"
package.path = package.path .. ";./utils/ulua/compiled_libs/?/?.lua"
package.path = package.path .. ";./utils/ulua/compiled_libs/?/init.lua"
package.path = package.path .. ";./utils/ulua/compiled_libs/?/?.so"
-- package.path = package.path .. ";./utils/ulua/?/init.lua"
-- package.path = package.path .. ";./utils/ulua/?/?.lua"
-- package.path = package.path .. ";./utils/ulua/?"
-- package.path = package.path .. ";./?"

--local lsqlite = require("ljsqlite3")

-- local sqlite3 = require("-lsqlite3complete")

-- db_json = sqlite3.open("json")
-- db_json_ptr = db_json:get_ptr()
-- db_json:exec[[
--   CREATE TABLE host (id INTEGER PRIMARY KEY, item TEXT );
-- ]]




