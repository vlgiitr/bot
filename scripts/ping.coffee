# Description:
#   Utility commands surrounding Hubot uptime.
#
# Commands:
#   hubot die - End hubot process

module.exports = (robot) ->
  robot.respond /DIE$/i, (msg) ->
    msg.send "Goodbye, cruel world."
    process.exit 0
