$ ->
  Expense = Backbone.Model.extend
    idAttribute: "_id"
    defaults: ->
      year: 0
      month: 0
      date: 0
      remark: ""
      price: 0

    initialize: ->

  DateList = Backbone.Collection.extend
    dates: {}

    setDate: (key, expense) ->
      @dates[key] = expense

    getDate: (key) ->
      @dates[key]
  
  ExpenseList = Backbone.Collection.extend
    model: Expense
    url: "/expenses"

    initialize: ->
      @dateList = new DateList()
      
      @on "add", (expense) ->
        key = @generate(expense)
        @dateList.setDate(key, expense)
        @trigger("add-" + key, expense)
      , this

      @bind "reset", (expenses) ->
        expenses.each (expense) ->
          key = @generate(expense)
          @dateList.setDate(key, expense)
          @trigger("add-" + key, expense)
        , this
      , this
        
    generate: (expense) ->
      expense.get("year") + "/" + expense.get("month") + "/" + expense.get("date")

  Expenses = new ExpenseList()

  ExpenseView = Backbone.View.extend
    tagName: "li"
    className: "expense-item"
  
    template: _.template($('#item-template').html()),
    events:
      "click a.destroy": "clear"
      "dblclick .view": "edit"
      "keypress .edit": "updateOnEnter"
      "blur .edit"    : "close"
    
    initialize: ->
      @model.bind 'change', @render, this
      @model.bind 'destroy', @remove, this

    render: ->
      @$el.html @template(@model.toJSON())
#       @$el.toggleClass('done', @model.get('done'))
      @input = @$('.edit')
      this

    edit: ->
      @$el.addClass("editing")
      @input.focus()

    updateOnEnter: (e) ->
      if e.keyCode == 13 then @close()

    close: ->
      value = @input.val()
      if not value then @clear()
      @model.save({title: value})
      @$el.removeClass("editing")

    clear: ->
      @model.clear()

  DateListView = Backbone.View.extend
    el: $('#date-list')
  
    initialize: ->
      today = new Date()
      year = today.getFullYear()
      month = today.getMonth()+1
      i = today.getDate()
      while i > 0
        view  = new DateView(year, month, i)
        @$el.append view.render().el
        i--

  DateView = Backbone.View.extend
    tagName: 'li'
    template: _.template($('#date-template').html())

    events:
      "keypress .new-price" : "addExpense"
  
    initialize: (year, month, date) ->
      Expenses.bind "add-" + year + "/" + month + "/" + date, @addOne, this
      
      @year = year
      @month = month
      @date = date
      @id = "new-" + @month + "-" + @date
      @total = 0
  
    render: ->
      @$el.attr(id: @id)
      @$el.html @template(@total)
      @remark = @$el.find(".new-remark-field")
      @price = @$el.find(".new-price-field")
      this

    addOne: (expense) ->
      @total += expense.get("price")
      view = new ExpenseView(model: expense)
      @$("#expense-list").append view.render().el
      @$el.children(".total").html("日計: " + @total + "円")

    addExpense: (e) ->
      return unless e.keyCode is 13
      Expenses.create
        year: @year
        month: @month
        date: @date
        remark: @remark.val()
        price: parseInt(@price.val(), 10)
      @remark.val ""
      @price.val ""

  AppView = Backbone.View.extend
    el: $("#expenseapp")

    initialize: ->
      Expenses.bind "all", @render, this

      @footer = $('footer')
      @main = $('#main')

      list = new DateListView()

      Expenses.fetch()
 
    render: ->
      @main.show()
      @footer.show()
      this

    addOne: (expense) ->
      @dates[expense.get("date").getDate()-1].addOne(expense)

  App = new AppView()
