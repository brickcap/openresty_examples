local xavante = require "xavante"
local xavante_fh = require "xavante.filehandler"
local lsqlite3 = require "lsqlite3complete"
local csv = require "csv"
local json = require "json"


local db_json = lsqlite3.open("json")
db_json:exec("CREATE TABLE host (id INTEGER PRIMARY KEY, item TEXT );")      


local insert =  function (insert_stmt,data)
   insert_stmt:bind_values(data)
end

local check_func = function()
   print("Perform maintenance tasks here")
end

local root_handler = function(req,res)
   local file = csv.open("./data/greece_listings.csv",{header=true})
   local insert_stmt = assert(db_json:prepare("INSERT INTO host VALUES (NULL, ?)") )
   for field in file:lines() do
      insert(insert_stmt,json.encode(field))      
   end
   local code = insert_stmt:step()
   res.headers["Content-type"] = "text/plain"
   if code == 101 then
      res.content = "done"
   else
      res.content = "failed"
   end   
   return res
end

xavante.HTTP {
   server = { host = "*", port = 5000 },
   defaultHost = {
      rules = {
	 {
	    match = "/$",
	    with = root_handler
	 }, {
	    match = ".",
	    with = xavante_fh,
	    params = { baseDir = "static/" }
	    }
      }
   }
}

xavante.start(check_func,300)