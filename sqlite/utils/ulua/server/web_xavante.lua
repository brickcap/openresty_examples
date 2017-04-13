package.path = package.path .. "../?/?.lua;"
package.path = package.path .. "./?/?.lua;"


local xavante = require "xavante"
local xavante_fh = require "xavante.filehandler"
local lsqlite3 = require "lsqlite3complete"
local csv = require "csv"
local json = require "json"
local pl = require "pl"
local inspect = require "inspect"
local db_json = lsqlite3.open("json")




local insert =  function (insert_stmt,data)
   insert_stmt:bind_values(data)
   insert_stmt:step()
   insert_stmt:reset()
end


local check_func = function()
   print("Perform maintenance tasks here")
end

local root_handler = function(req,res)
   db_json:exec("Drop Table host;")
   db_json:exec("CREATE TABLE host (id INTEGER PRIMARY KEY, listings TEXT );")   
   local file = csv.open("./data/greece_listings.csv",{header=true})
   db_json:exec("BEGIN TRANSACTION")   
   local insert_stmt = assert(db_json:prepare("INSERT INTO host VALUES (NULL, ?);") )
   for field in file:lines() do
      insert(insert_stmt,json.encode(field))      
   end
   local code = db_json:exec("COMMIT;")
   res.headers["Content-type"] = "text/plain"
   if code == 0 then
      res.content = "done"
   else
      res.content = "failed"
   end   
   return res
end

local query_handler = function(req,res)
   print(inspect(req))
   local data = req.socket:receive(req.headers["content-length"])
   print(inspect(data))
   res.content = "ok"
end

xavante.HTTP {
   server = { host = "*", port = 5000 },
   defaultHost = {
      rules = {
	 {
	    match = "/$",
	    with = root_handler
	 },
	 {
	    match = "/query",
	    with = query_handler
	 },
	 {
	    match = ".",
	    with = xavante_fh,
	    params = { baseDir = "static/" }
	 }
      }
   }
}

xavante.start()
