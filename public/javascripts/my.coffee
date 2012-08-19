$ ->
  Expense = Backbone.Model.extend
    idAttribute: "_id"
    defaults: ->
      year: 0
      month: 0
      date: 0
      remark: ""
      price: 0

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

      @on "change:price", (expense, value) ->
        key = @generate(expense)
        @trigger("refreshTotal-" + key, expense, value)
      , this

      @on "destroy", (expense) ->
        console.log expense
        key = @generate(expense)
        @trigger("refreshTotal-" + key, expense)
      , this

      @on "reset", (expenses) ->
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
      "keypress .edit input": "updateOnEnter"
      "blur .edit input"    : "close"
    
    initialize: ->
      @model.bind 'change', @render, this
      @model.bind 'destroy', @remove, this

    render: ->
      @$el.html @template(@model.toJSON())
      @input = @$('.edit')
      @remark = @$('.remark-field')
      @price = @$('.price-field')
      this

    edit: ->
      @$el.addClass("editing")
      @input.focus()

    updateOnEnter: (e) ->
      if e.keyCode == 13 then @close()

    close: ->
      @model.save
        remark: @remark.val()
        price: parseInt(@price.val(), 10)
      @$el.removeClass("editing")

    clear: ->
      @model.destroy()

  DateListView = Backbone.View.extend
    el: $('#date-list')
    startDate: 25  # TODO サーバへ

    initialize: ->
      today = new Date()
      i = @startDate
      while true
        target = new Date(today.getFullYear(), today.getMonth(), i)
        view  = new DateView(target.getFullYear(), target.getMonth()+1, target.getDate())
        @$el.prepend view.render().el
        i = target.getDate() + 1
        break if i == today.getDate()
        
  DateView = Backbone.View.extend
    tagName: 'li'
    template: _.template($('#date-template').html())

    events:
      "keypress .new-remark-field + .new-price-field" : "addExpense"

    # 引数はhashで受け取ろう
    initialize: (year, month, date) ->
      Expenses.bind "add-" + year + "/" + month + "/" + date, @addOne, this
      Expenses.bind "refreshTotal-" + year + "/" + month + "/" + date, @culcTotal, this
      
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
      console.log expense
      view = new ExpenseView(model: expense)
      @$("#expense-list").append view.render().el
      @total += expense.get("price")
      @$el.children(".total").html("日計: " + @total + "円")

    culcTotal: ->
      # うーん。むっちゃ計算量が多い・・・
      # expenseに紐付いているdatelistからとるようにしよう
      expenses = Expenses.filter (expense)->
        expense.get("year") == @year &&
        expense.get("month") == @month &&
        expense.get("date") == @date
      , this
      @total = expenses.reduce (num, expense) ->
        num + expense.get("price")
      , 0
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

  App = new AppView()
