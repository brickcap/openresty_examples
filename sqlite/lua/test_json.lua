local sqlite3 = require("./utils/ulua/lsqlite3complete/0_9_4+203/Linux/x64/-lsqlite3complete")
local csv  = require("csv/1+103/")
db_mem = sqlite3.open_memory()

ngx.say("hooray")
