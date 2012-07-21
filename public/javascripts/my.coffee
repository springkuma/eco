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

    display_date: ->
      @get("month") + "/" + @get("date")

  ExpenseList = Backbone.Collection.extend
    model: Expense
    url: "/expenses"

    initialize: ->
      @modelsForDate = {}

      @on "add", (expense) ->
        key = @generate(expense)
        @modelsForDate[key] = expense
        trigger("add-" + key, expense)

      @on "reset", (expenses) ->
        expenses.each (expense) ->
          key = @generate(expense)
          @modelsForDate[key] = expense
        , this

        console.log(typeof @modelsForDate)
        for key, models of @modelsForDate
          console.log key, models
        
    generate: (expense) ->
      expense.get("year") + "/" + expense.get("month") + "/" + expense.get("date")
    
    
    parse: (res) ->
      @parseDate(res)
      res

    parseDate: (res) ->
      for obj in res
        expense = new Expense(obj)
        key = expense.get("year") + "/" + expense.get("month") + "/" + expense.get("date")
        @modelsForDate[key] = expense


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
    list: {}
  
    initialize: ->
      today = new Date()
      year = today.getFullYear()
      month = today.getMonth()+1
      i = today.getDate()
      while i > 0
        view  = new DateView(year, month, i)
        @addList(view)
        @$el.append view.render().el
        i--

    addList: (view) ->
      key = view.month + "/" + view.date
      @list[key] = view

  DateView = Backbone.View.extend
    tagName: 'li'
    template: _.template($('#date-template').html())

    events:
      "keypress .new-price" : "addExpense"
  
    initialize: (year, month, date) ->
      Expenses.bind 'reset', @addForDate, this
      Expenses.bind "add", @addOne, this
      
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
      # ちょっと待てよ。。。addOneとaddForDateで同じ事チェックしてる
      return unless expense.get("year") == @year && expense.get("month") == @month && expense.get("date") == @date
      @total += expense.get("price")
      view = new ExpenseView(model: expense)
      @$("#expense-list").append view.render().el
      @$el.children(".total").html("日計: " + @total + "円")

    addForDate: (expenses) ->
      ret = expenses.filter (expense)->
        @month == expense.get("month") &&
        @date == expense.get("date")
      , this
      for ex in ret then @addOne(ex)

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
      @input = @$("#new-todo")
      @display_date = @$("#selectdate")
      @remark = @$("#remark")
      @price = @$("#price")
      @dates = new Array()
      
      Expenses.bind "all", @render, this

      @footer = $('footer')
      @main = $('#main')

      list = new DateListView()
      list.render()

      Expenses.fetch()
 
    render: ->
      @main.show()
      @footer.show()

      $("#yama").html Expenses.length
      this

    addOne: (expense) ->
      @dates[expense.get("date").getDate()-1].addOne(expense)

  App = new AppView()
