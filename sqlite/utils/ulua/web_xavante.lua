local xavante = require "xavante"
local xavante_fh = require "xavante.filehandler"
local lsqlite3 = require "lsqlite3complete"

local port = 5000
local udtbl = {}

xavante.HTTP {
   server = { host = "*", port = 5000 },
   defaultHost = {
      rules = {
	 {
	    match = "/$",
	    with = function(req, res)
	       local db_json = lsqlite3.open("json")

	       db_json:exec[[
		     CREATE TABLE host (id INTEGER PRIMARY KEY, item TEXT );
			   ]]
	       db_json:update_hook( function(ud, op, dname, tname, rowid)
		     local print_val = string.format("%s %s %s %s", optbl[op], dname, tname, rowid)
		     print("Sqlite Update Hook:", print_val)
				    end, udtbl)

	       db_json:exec[[
  CREATE TABLE test ( id INTEGER PRIMARY KEY, content VARCHAR );

  INSERT INTO test VALUES (NULL, 'Hello World');
  INSERT INTO test VALUES (NULL, 'Hello Lua');
  INSERT INTO test VALUES (NULL, 'Hello Sqlite3');
  UPDATE test SET content = 'Hello Again World' WHERE id = 1;
  DELETE FROM test WHERE id = 2;
]]

	       res.headers["Content-type"] = "text/html"
	       res.content = "hello world, the time is: " .. os.date()
	       return res
	    end
	 }, {
	    match = ".",
	    with = xavante_fh,
	    params = { baseDir = "static/" }
	    }
      }
   }
}

xavante.start()
