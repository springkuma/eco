$ ->
  Todo = Backbone.Model.extend(
    defaults: ->
      title: "empty todo..."
    url: "/todos/"

    initialize: ->
  )
  TodoList = Backbone.Collection.extend(
    model: Todo
    url: "/todos/"
  )
  Todos = new TodoList
  TodoView = Backbone.View.extend(
    tagName: "li"
    initialize: ->
      @render()

    render: ->
      @$el.html "<li>" + @model.get("title") + "</li>"
      this
  )
  AppView = Backbone.View.extend(
    el: $("#todoapp")
    events:
      "keypress #new-todo": "addTodo"

    initialize: ->
      @input = @$("#new-todo")
      Todos.bind "add", @addOne, this
      Todos.bind "all", @render, this
      @render()

    render: ->
      if Todos.length

      else

      $("#yama").html Todos.length

    addOne: (todo) ->
      view = new TodoView(model: todo)
      @$("#todo-list").append view.render().el

    addTodo: (e) ->
      return  unless e.keyCode is 13
      Todos.create title: @input.val()
      @input.val ""
  )
  App = new AppView

  Workspace = Backbone.Router.extend(
    routes:
      "help": ""
  )