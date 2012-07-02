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
      

  ExpenseList = Backbone.Collection.extend
    model: Expense
    url: "/expenses"

  Expenses = new ExpenseList
  
  ExpenseView = Backbone.View.extend
    tagName: "li"
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
      
      Expenses.bind "add", @addOne, this
      Expenses.bind 'reset', @addAll, this
      Expenses.bind "all", @render, this

      @footer = $('footer')
      @main = $('#main')
  
      today = new Date()
      yesterday = new Date(today.getTime() - 24*60*60*1000)
      before_yesterday = new Date(today.getTime() - 2*24*60*60*1000)

      $("#selectdate").append($('<option>').text(@getDateToString(today))
      , $('<option>').text(@getDateToString(yesterday))
      , $('<option>').text(@getDateToString(before_yesterday)))

      Expenses.fetch()

    render: ->
      @main.show()
      @footer.show()

      $("#yama").html Expenses.length

    addOne: (expense) ->
      view = new ExpenseView(model: expense)
      @$("#expense-list").append view.render().el

    addTodo: (e) ->
      return  unless e.keyCode is 13
      Todos.create title: @input.val()
      @input.val ""

    addExpense: (e) ->
      return unless e.keyCode is 13
      console.log @display_date.val()
      Expenses.create
        date: @getStringToDate(@display_date.val())
        remark: @remark.val()
        price: @price.val()
      @remark.val ""
      @price.val ""

    addAll: ->
      Expenses.each(@addOne)

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
