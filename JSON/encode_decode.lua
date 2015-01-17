local cjson = require "cjson"
local inspect = require "inspect"

local json_with_arrays = '{"admins": { "names": ["superuser"],"roles": ["admins"]},"members": {"names": ["user1","user2"],"roles": ["developers"]}}\n'

local json_with_arrays_decoded = cjson.decode(json_with_arrays)
local members = json_with_arrays_decoded.members -- members table
local admins = json_with_arrays_decoded.admins -- admins table
print("----Encoded JSON----\n")
print(json_with_arrays)
print("----Decoded JSON----\n")
print(inspect(json_with_arrays_decoded)..'\n') -- decoded json
print("----Members----\n")
print(inspect(members)..'\n') --members
print("----Names of members----\n")
print(members.names[1]) --user1
print(members.names[2]) -- user2
print(members.roles[1]) -- the role of the member "developers"