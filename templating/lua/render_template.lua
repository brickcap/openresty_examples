local template = require("lib/lua-resty-template/lib/resty.template")
local template_string = ngx.location.capture("/templates/template.html")
--ngx.log(ngx.ERR,ngx.var.uri)
template.render(template_string.body,{message="hello world"})
