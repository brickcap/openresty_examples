@echo off
SETLOCAL
SET BIN_ROOT=%~dp0
SET BIN_ROOT=%BIN_ROOT:~0,-1%
SET BIN_ROOT=%BIN_ROOT:\=/%
SET LUA_ROOT=%BIN_ROOT%/..
call %LUA_ROOT%/lua.cmd %LUA_ROOT%/wsapi/1_6_1+103/__bin/wsapi.cgi %*
