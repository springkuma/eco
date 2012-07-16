$ ->
  dateToKey = (date) ->
    date.getFullYear() + "/" + (date.getMonth()+1) + "/" + date.getDate()
  
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

    initialize: ->
      @modelsForDate = {}

      @on "add", (expense) ->
        key = dateToKey(expense.get("date"))
        this.modelsForDate[key] = expense
        
    parse: (res) ->
      @parseDate(res)
      res

    parseDate: (res) ->
      for obj in res
        expense = new Expense(obj)
        key = dateToKey(expense.get("date"))
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
      i = today.getDate()
      while i > 0
        date = new Date(today.getFullYear(), today.getMonth(), i)
        view  = new DateView(date)
        @addList(view)
        @$el.append view.render().el
        i--

    addList: (view) ->
      date = view.date
      key = date.getFullYear() + "/" + (date.getMonth()+1) + "/" + date.getDate()
      @list[key] = view

  DateView = Backbone.View.extend
    tagName: 'li'
    template: _.template($('#date-template').html())

    events:
      "keypress input" : "addExpense"
  
    initialize: (date) ->
      Expenses.bind 'reset', @addForDate, this
      Expenses.bind "add", @addOne, this
      
      @date = date
      @id = "new-" + (@date.getMonth()+1) + "-" + @date.getDate()
      @total = 0
  
    render: ->
      @$el.attr(id: @id)
      @$el.html @template(@date, @total)
      @remark = @$el.find(".new-remark-field")
      @price = @$el.find(".new-price-field")
      this

    addOne: (expense) ->
      @total += expense.get("price")
      view = new ExpenseView(model: expense)
      @$("#expense-list").append view.render().el
      @$el.children(".total").html("日計: " + @total + "円")

    addForDate: (expenses) ->
      ret = expenses.filter (expense)->
        @date.getMonth() == expense.get("date").getMonth() &&
        @date.getDate() == expense.get("date").getDate()
      , this
      for ex in ret then @addOne(ex)

    addExpense: (e) ->
      return unless e.keyCode is 13
      Expenses.create
        date: @date
        remark: @remark.val()
        price: @price.val()
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
