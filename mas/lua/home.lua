local page = ngx.location.capture("/docs/index.html")
local cjson = require("cjson")
ngx.header.content_type =
   "text/html; charset=utf-8"
ngx.header["ETag"] = page.header["ETag"]
ngx.log(ngx.NOTICE,cjson.encode({hello="dolly"}))
ngx.say(page.body)
