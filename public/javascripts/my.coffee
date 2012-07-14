$ ->
  Todo = Backbone.Model.extend
    idAttribute: "_id"
    defaults: ->
      title: "empty todo..."
      done: false

    initialize: ->
      if not @get("title")
        @set({"title": @defaults().title})


    clear: ->
      @destroy()
      
  Expense = Backbone.Model.extend
    idAttribute: "_id"
    defaults: ->
      date: new Date()
      remark: ""
      price: 0

    initialize: ->
      # ちょっと考える
      if not @get("date")
        @set("date": @defaults().date)
      if @get("date") isnt Date
        @set("date": new Date(@get("date")))

    display_date: ->
      @getDateToString @get("date")
      
    getDateToString: (target) ->
      if target is String  then target = new Date(target)
      "" + (target.getMonth()+1) + "/" + target.getDate()

  ExpenseList = Backbone.Collection.extend
    model: Expense
    url: "/expenses"

  Expenses = new ExpenseList
  
  ExpenseView = Backbone.View.extend
    tagName: "li"
    className: "expense_item"
  
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
      @$el.html @template(_.extend(@model.toJSON(), "display_date": @model.display_date()))
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

  DateView = Backbone.View.extend
    tagName: 'li'
    template: _.template($('#date-template').html())

    events:
      "keypress" : "addExpense"
  
    initialize: (year, month, date) ->
      @date = new Date(year, month, date)
      @id = "new-" + (@date.getMonth()+1) + "-" + @date.getDate()

    render: ->
      @$el.attr(id: @id)
      @$el.html @template(@date)
      @remark = @$el.find(".new-remark-field")
      @price = @$el.find(".new-price-field")
      this

    addOne: (expense) ->
      view = new ExpenseView(model: expense)
      @$("#expense-list").append view.render().el

    addExpense: (e) ->
      return unless e.keyCode is 13
      console.log(@remark.val(), @price.val())
      Expenses.create
        date: @date
        remark: @remark.val()
        price: @price.val()
      @remark.val ""
      @price.val ""

  AppView = Backbone.View.extend
    el: $("#expenseapp")

    events:
      "keypress #remark"  : "addExpense"
      "keypress #price"   : "addExpense"

    initialize: ->
      @input = @$("#new-todo")
      @display_date = @$("#selectdate")
      @remark = @$("#remark")
      @price = @$("#price")
      @dates = new Array()
      
      Expenses.bind "add", @addOne, this
      Expenses.bind 'reset', @addAll, this
      Expenses.bind "all", @render, this

      @footer = $('footer')
      @main = $('#main')

      today = new Date()

      i = 1
      while i <= today.getDate()
        view = new DateView(today.getYear(), today.getMonth(), i)
        @dates.push(view)
        @$("#date-list").append view.render().el
        i++

      Expenses.fetch()
 
    render: ->
      @main.show()
      @footer.show()

      $("#yama").html Expenses.length
      this

    addOne: (expense) ->
      @dates[expense.get("date").getDate()-1].addOne(expense)

    addTodo: (e) ->
      return  unless e.keyCode is 13
      Todos.create title: @input.val()
      @input.val ""

    addExpense: (e) ->
      return unless e.keyCode is 13
      Expenses.create
        date: @getStringToDate(@display_date.val())
        remark: @remark.val()
        price: @price.val()
      @remark.val ""
      @price.val ""

    addAll: ->
      Expenses.each(@addOne, this)

    getDateToString: (date) ->
      "" + (date.getMonth()+1) + "/" + date.getDate()

    getStringToDate: (str) ->
      ary = str.split("/")
      month_date = new Array()
      for date in ary
        month_date.push(parseInt(date))
      date = new Date()
      date.setMonth(month_date[0]-1)
      date.setDate(month_date[1])
      date

  App = new AppView()
