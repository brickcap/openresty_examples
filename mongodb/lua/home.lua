local mongol = require("resty.mongol")
local cjson = require("cjson")
local con = mongol:new()
local ok,err = con:connect("127.0.0.1",27017)
if err then
   ngx.log(ngx.ERR,err)
end
local db = con:new_db_handle("wow")
ngx.say(cjson.encode(con:databases()))
