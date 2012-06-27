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
TodoSchema = new Schema
  title: String
  done: Boolean

Todo = mongoose.model('Todo', TodoSchema)

app.get "/", routes.index

app.get "/todos", (req, res) ->
  Todo.find (error, todos) ->
    if not error
      res.json todos
    else
      res.json success: false

app.post "/todos", (req, res) ->
  todo = new Todo(req.body)
  todo.save (error) ->
    if not error
      res.json success: true
    else
      res.json success: false

app.put "/todos/:id", (req, res) ->
  data = title: req.body.title, done: req.body.done
  Todo.update {_id: req.params.id}, data, (error, todo) ->
    if not error
      res.json success: true
    else
      res.json success: false

app.delete "/todos/:id", (req, res) ->
  Todo.findById req.params.id, (error, todo) ->
    if not error
      todo.remove (delete_error) ->
        if not delete_error
          res.json success: true
        else
          res.json success: false
    else
      res.json success: false

port = process.env.PORT or 3000

app.listen port, ->
  console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env

