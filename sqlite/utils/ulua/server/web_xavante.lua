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
local res = db_json:load_extension("./json1")

if res then
   print("json1 extension loaded")
end



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
   print(db_json:changes())
   local r_val = {}
   local data = json.decode(req.socket:receive(req.headers["content-length"]))
   print(inspect(data))
   local q_smt = assert(db_json:prepare([[
	    SELECT listings from host, 
	    json_tree(host.listings)
	    WHERE json_tree.key=?
	       and json_tree.value=?;]]))

   q_smt:bind_values(data.query.key,data.query.value)
   
   for row in q_smt:nrows() do 
      table.insert(r_val,row.listings)
   end
   res.headers["Content-type"] = "application/json"
   res.content = r_val
   return res
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
