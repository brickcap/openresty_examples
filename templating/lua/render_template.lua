local template = require("lib/lua-resty-template/lib/resty.template")
local template_string = ngx.location.capture("/templates/template.html")
ngx.say(template_string.body)
