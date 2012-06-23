$ ->
  Todo = Backbone.Model.extend(
    idAttribute: "_id"
    defaults: ->
      title: "empty todo..."
      done: false

    initialize: ->
      if not @get("title")
        @set({"title": @defaults().title})

    clear: ->
      @destroy()
  )
  TodoList = Backbone.Collection.extend(
    model: Todo
    url: "/todos"
  )
  Todos = new TodoList
  TodoView = Backbone.View.extend(
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
      @$el.toggleClass('done', @model.get('done'))
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
  )
  AppView = Backbone.View.extend(
    el: $("#todoapp")

    events:
      "keypress #new-todo": "addTodo"

    initialize: ->
      @input = @$("#new-todo")
      
      Todos.bind "add", @addOne, this
      Todos.bind 'reset', @addAll, this
      Todos.bind "all", @render, this

      @footer = $('footer')
      @main = $('#main')
      Todos.fetch()

    render: ->
      @main.show()
      @footer.show()

      $("#yama").html Todos.length

    addOne: (todo) ->
      view = new TodoView(model: todo)
      @$("#todo-list").append view.render().el

    addTodo: (e) ->
      return  unless e.keyCode is 13
      Todos.create title: @input.val()
      @input.val ""

    addAll: ->
      Todos.each(@addOne)
  )
  App = new AppView

  Workspace = Backbone.Router.extend(
    routes:
      "help": ""
  )