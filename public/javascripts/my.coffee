$ ->
  Todo = Backbone.Model.extend(
    defaults: ->
      title: "empty todo..."
      done: false
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
    template: _.template($('#item-template').html()),
    
    initialize: ->
      @render()

    render: ->
      @$el.html @template(@model.toJSON())
      @$el.toggleClass('done', @model.get('done'))
      @input = @$('.edit')
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

      @footer = $('footer')
      @main = $('main')
      @render()

    render: ->
      @main.show;
      @footer.show;

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