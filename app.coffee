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
ExpenseSchema = new Schema
  year: Number
  month: Number
  date: Number
  remark: String
  price: Number

Expense = mongoose.model('Expense', ExpenseSchema)

app.get "/", routes.index

app.get "/expenses", (req, res) ->
  query = Expense.find({})
  query.sort("date", 1)
  query.exec (error, expenses) ->
    if not error
      res.json expenses
    else
      res.json success: false

app.post "/expenses", (req, res) ->
  expense = new Expense(req.body)
  expense.save (error) ->
    if not error
      res.json success: true
    else
      res.json success: false

app.put "/expenses/:id", (req, res) ->
  data = req.body
  Expense.update {_id: req.params.id}, data, (error, expense) ->
    if not error
      res.json success: true
    else
      console.log(error)
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

