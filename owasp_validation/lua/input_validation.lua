ngx.req.read_body()
-- read body as a string
local post_string = ngx.req.read_body_data()
-- read body as a lua table
local post_args = ngx.req.get_post_args()
local headers = ngx.req.get_headers()
local headers_raw = ngx.req.get_headers(100,true)
local utf_validator = require("lua/utf8_vlaidator.lua/utf8_validator")


-- the req headers must be in the ascii range 

local m,e = ngx.re.match(headers, "[[:ascii:]]+")
if e ~=null then 
   ngx.say(ngx.HTTP_BAD_REQUEST)
end

if m[0]==null then
   ngx.say(ngx.HTTP_BAD_REQUEST)
end
-- we'll only accept utf-8 encoding 
if headers.accept_encoding ~= '' then
   ngx.say(ngx.HTTP_BAD_REQUEST)
end

-- we'll only accept utf-8 encoded string
if not utf_validator(post_string) then 
   ngx.say(ngx.HTTP_BAD_REQUEST)
end



