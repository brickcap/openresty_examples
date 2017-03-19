local moongoo = require("resty.mongol")
local mg, err = moongoo.new("mongodb://user:password@hostname/?w=2")
if not mg then
  error(err)
end
ngx.say("connected")
