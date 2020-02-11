# Description:
#   Script for birthdays!.
#
# Configuration:
#   INFO_SPREADSHEET_URL
# 
# Commands:
#   hubot birthday <user>

moment = require 'moment'
cron = require('node-cron')

module.exports = (robot) ->
  robot.respond /(birthday) (.+)$/i, (msg)  ->
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
            if user[4] == ''
              msg.send "#{user[0]} bro birthday add karde yrr!"
            else
              msg.send "Wish #{user[0]} on #{moment(user[4], 'DD/MM/YYYY').format("MMM Do, YYYY")}!"

  #This will run every day at 00:00:05
  cron.schedule '5 0 0 * * *', ()->
    robot.http(process.env.INFO_SPREADSHEET_URL)
      .query({
        output: "csv"
      })
      .get() (err, res, body) ->
        result = parse body, '/'
        for member in result
          try
            dob = moment(member[4], 'DD/MM/YYYY')
            today = moment()
            if(dob.format("D") == today.format("D") && dob.format("M") == today.format("M") && member[7] > 16000000 )
              robot.send room: 'general', "Happy Birthday #{member[0]}:birthday::birthday:!!"
          catch error
            robot.send room: 'general', "Help!! These dates are breaking me!"
          
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