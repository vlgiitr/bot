# Description:
#   gets core member's info from google doc
#   Type a partial name to get all matches
#
# Configuration:
#   INFO_SPREADSHEET_URL
#
# Commands:
#   hubot info <partial name> - Get information about a person

moment = require 'moment'

module.exports = (robot) ->
  robot.respond /(info) (.+)$/i, (msg)  ->
    query = msg.match[2].toLowerCase()
    robot.http(process.env.INFO_SPREADSHEET_URL)
      .query({
        output: "csv"
      })
      .get() (err, res, body) ->
        result = parse body, query
        if not result 
          msg.send "I could not find a user matching `"+query.toString()+"`"
        else
          msg.send result.length+" user(s) found matching `"+query.toString()+"`"
          for user in result
            msg.send(
              attachments: [
                {
                  "fallback": user.join ' \t '
                  "color": randomColor()
                  "title": user[0]
                  "title_link": "https://facebook.com/#{user[10]}"
                  "text": "Github: <https://github.com/#{user[9]}|#{user[9]}>"+
                  "\nRoom No: #{user[8]}"
                  "fields": [
                      "title": "Mobile #1"
                      "value": "<tel:#{user[1]}|#{user[1]}>"
                      "short": true
                    ,
                      "title": "Mobile #2"
                      "value": "<tel:#{user[2]}|#{user[2]}>"
                      "short": true
                    ,
                      "title": "Email"
                      "value": "<mailto:#{user[3]}|#{user[3]}>"
                      "short": true
                    ,
                  ]
                  "footer": "#{user[5]} #{user[6]} (#{user[7]})"
                  "ts": moment(user[4], 'DD/MM/YYYY').format("X")
                }

              ]
            )


parse = (json, query) ->
  result = []
  for line in json.toString().split '\n'
    y = line.toLowerCase().indexOf query
    if y != -1
      result.push line.split(',').map Function.prototype.call, String.prototype.trim
  if result != ""
    result
  else
    false

randomColor = () ->
  return '#'+(0x1000000+(Math.random())*0xffffff).toString(16).substr(1,6);
