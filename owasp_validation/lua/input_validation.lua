ngx.req.read_body()
-- read body as a string
local post_string = ngx.req.read_body_data()
-- read body as a lua table
local post_args = ngx.req.get_post_args()
local headers = ngx.req.get_headers()
local utf_validator = require("lua/utf8_vlaidator.lua/utf8_validator")

-- we'll only accept utf-8 encoding
if headers.accept_encoding ~= '' then
   ngx.say(ngx.HTTP_BAD_REQUEST)
end

-- 
