#!/bin/bash
BIN_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LUA_ROOT="$BIN_ROOT""/.."
source "$LUA_ROOT"/lua "$LUA_ROOT""/""wsapi/1_6_1+103/__bin/wsapi.cgi" $@
