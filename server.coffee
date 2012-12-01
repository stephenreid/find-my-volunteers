express = require 'express'
util = require 'util'
cradle = require 'cradle'

connect = ()->
  prod = !!process.env.CLOUDANT_URL
  url = 'http://127.0.0.1'
  url = process.env.CLOUDANT_URL if prod
  port = 5984
  port = 443 if prod

  (new cradle.Connection url, port, {
    cache: true
    raw: false
  }).database 'db'

app = express()
app.enable 'trust proxy'

app.configure(->
  app.use(express.logger())
  app.use(express.bodyParser())
  app.use(app.router)
  app.use(express.static(__dirname + '/public'))
)

app.get '/', (req, res)->
  res.sendfile(__dirname + '/public/index.html')

app.get '/api/hello', (req, res)->
  db = connect()
  db.save 'hello', world: 'here!', (err, response)->
    res.send 500, util.inspect err if err?
    res.send 'hello world!'

app.post '/api/sms/receive', (req, res)->
  db = connect()
  db.save "/#{req.body.SmsSid}", req.body, (err, response)->
    if err?
      res.send '<Response><Sms>We are unable to process your request.</Sms></Response>'
    else
      res.send "<Response><Sms>We have received your request.</Sms></Response>"

app.post '/api/register', (req, res)->
  reg = req.body

  person =
    id: reg.vid
    name: reg.name
    phone: reg.phone
    group: reg.group

  res.send 204

app.listen process.env.PORT or 5000

console.log "listening..."
console.log "Settings #{util.inspect app.settings}"
