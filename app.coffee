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
startDate = 25

app.get "/", routes.index

app.get "/expenses", (req, res) ->
  q1 = Expense.find()
  q1.where('month').equals(8)
  q1.where('date').gte(25)

  q2 = Expense.find()
  q2.where('month').equals(9)
  q2.where('date').lt(25)

  query = q1.or(q2)

  q1.exec (err1, ex1) ->
    q2.exec (err2, ex2) ->
      if not (err1 & err2)
        ex1.push.apply(ex1, ex2)
        console.log ex1
        res.json ex1
      else
        res.json success: false

app.post "/expenses", (req, res) ->
  expense = new Expense(req.body)
  expense.save (error) ->
    if not error
      res.json expense
    else
      res.json success: false

app.put "/expenses/:id", (req, res) ->
  data =
    year: req.body.year
    month: req.body.month
    date: req.body.date
    remark: req.body.remark
    price: req.body.price
  Expense.update {_id: req.params.id}, data, (error, expense) ->
    if not error
      res.json expense
    else
      res.json success: false

app.delete "/expenses/:id", (req, res) ->
  Expense.findById req.params.id, (error, expense) ->
    if not error
      expense.remove (delete_error) ->
        if not delete_error
          res.json success: true
        else
          res.json success: false
    else
      res.json success: false

port = process.env.PORT or 3000

app.listen port, ->
  console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env

