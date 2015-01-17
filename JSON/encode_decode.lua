local cjson = require "cjson"
local inspect = require "inspect"

local json_with_arrays = '{"admins": { "names": ["superuser"],"roles": ["admins"]},"members": {"names": ["user1","user2"],"roles": ["developers"]}}'
local json_with_arrays_decoded = cjson.decode(json_with_arrays)
print(inspect(json_with_arrays)) -- decoded json
print(json_with_arrays_decoded.admins.names) --members
