coder = require './geocoder'
util = require 'util'
_ = require 'underscore'
iso8601 = require 'iso8601'

exports.receive = (db, req, res)->
  message = req.body
  message.timeStamp = iso8601.fromDate new Date

  db.view 'views/person_by_phone', key: (message.From.replace /[^0-9]/, ''), (err, response)->
    person = response[0]?.value
    message = _.extend message, person

    coder.geocode db, person, message.Body, (location)->
      message.location = location
      console.log util.inspect location

    db.save "sms/#{message.SmsSid}", message, (err, response)->
      if err?
        res.send '<Response><Sms>We are unable to process your request.</Sms></Response>'
      else
        res.send "<Response><Sms>We have received your request.</Sms></Response>"
