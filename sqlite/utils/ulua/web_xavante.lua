local xavante = require "xavante"
local xavante_fh = require "xavante.filehandler"

local port = 5000

xavante.HTTP {
  server = { host = "*", port = 5000 },
  defaultHost = {
    rules = {
      {
        match = "/$",
        with = function(req, res)
          res.headers["Content-type"] = "text/html"
          res.content = "hello world, the time is: " .. os.date()
          return res
        end
      }, {
        match = ".",
        with = xavante_fh,
        params = { baseDir = "static/" }
      }
    }
  }
}

xavante.start()
