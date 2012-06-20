express = require("express")
routes = require("./routes")
mongoose = require("mongoose")

mongoose.connect("mongodb://localhost/mongo_data");

app = module.exports = express.createServer()
app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(__dirname + "/public")

app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

app.configure "production", ->
  app.use express.errorHandler()

Schema = mongoose.Schema
TodoSchema = new Schema(title: String)

app.get "/", routes.index
app.post "/todos", (req, res) ->
  console.log("todos post")
  console.log(req.body)
  console.log(1)

app.listen 3000, ->
  console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env

