connect = require 'connect'

module.exports = (port)->

  connect.createServer(
    connect.static "#{__dirname}/_dev"
  ).listen port

  console.log "serving assets on http://localhost:#{port}"
