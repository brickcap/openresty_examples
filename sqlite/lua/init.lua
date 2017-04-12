cjson = require "cjson"
local lfs = require "./utils/ulua/lfs/1_6_3+203/Linux/x64/-lfs"
local d_root = "./utils/ulua"
local DIR_SEP="/"
local dirs = {}
function browseFolder(root)
   for entity in lfs.dir(root) do
      if entity~="." and entity~=".." then
	 local fullPath=root..DIR_SEP..entity
	 local mode=lfs.attributes(fullPath,"mode")
	 if mode=="file" then
	    --this is where the processing happens. I print the name of the file and its path but it can be any code
	    table.insert(dirs,root.."/"..entity)
	    print(root.."/"..entity)
	 elseif mode=="directory" then
	    browseFolder(fullPath);
	 end
      end
   end
end
browseFolder(d_root)

-- package.path = package.path .. ";./utils/ulua/?/init.lua"
-- package.path = package.path .. ";./utils/ulua/?/?.lua"
-- package.path = package.path .. ";./utils/ulua/?"
-- package.path = package.path .. ";./?"

ngx.log(ngx.ERR,package.path)
local sqlite3 = require("./utils/ulua/lsqlite3complete/0_9_4+203/Linux/x64/-lsqlite3complete")

db_json = sqlite3.open("json")
db_json_ptr = db_json:get_ptr()
db_json:exec[[
  CREATE TABLE host (id INTEGER PRIMARY KEY, item TEXT );
]]




