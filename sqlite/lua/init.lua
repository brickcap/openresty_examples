cjson = require "cjson"
local lfs = require "./utils/ulua/lfs/1_6_3+203/Linux/x64/-lfs"
local d_root = "./utils/ulua"
local DIR_SEP="/"

function browseFolder(root)
   for entity in lfs.dir(root) do
      if entity~="." and entity~=".." then
	 local fullPath=root..DIR_SEP..entity
	 local mode=lfs.attributes(fullPath,"mode")
	 local win,osx,x86,doc,ex,man,t = root:find("Windows"),
	 root:find("OSX"),
	 root:find("x86"),
	 root:find("__doc"),
	 root:find("__examples"),
	 root:find("manual"),
	 root:find("__t")
	 local f_cond = win or osx or x86 or doc or ex or man or  t
	 if mode=="file" and not f_cond then
	    --this is where the processing happens. I print the name of the file and its path but it can be any code    
	    local p_path = ";"..root.."/?.lua"..";"..root.."/?.so"
	    local p_cond = package.path:find(p_path)
	    
	    if not p_cond then
	       package.path = package.path ..p_path
	    end
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
local sqlite3 = require("csv")

db_json = sqlite3.open("json")
db_json_ptr = db_json:get_ptr()
db_json:exec[[
  CREATE TABLE host (id INTEGER PRIMARY KEY, item TEXT );
]]




