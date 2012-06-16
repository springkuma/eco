$(function(){
  var Todo = Backbone.Model.extend({
    defaults: function(){
      return {
        title: "empty todo..."
      };
    },

    initialize: function(){
    },
  });

  var TodoList = Backbone.Collection.extend({
    model: Todo,
    localStorage: new Store("todos-backbone"),
  });

  var Todos = new TodoList;

  var TodoView = Backbone.View.extend({
    tagName: "li",

    initialize: function(){
      this.render();
    },

    render: function(){
      this.$el.html('<li>' + this.model.get("title")  + '</li>');
      return this;
    }
      
  });

  var AppView = Backbone.View.extend({
    el: $("#todoapp"),

    events: {
      "keypress #new-todo": "addTodo"
    },

    initialize: function(){
      this.input = this.$("#new-todo");

      Todos.bind("add", this.addOne, this);
      Todos.bind("all", this.render, this);

      this.render();
    },

    render: function(){
      if (Todos.length){

      } else{

      }
      $("#yama").html(Todos.length);
    },

    addOne: function(todo){
      var view = new TodoView({model: todo});
      this.$("#todo-list").append(view.render().el);
    },

    addTodo: function(e){
      if(e.keyCode != 13) return;
      Todos.create({title: this.input.val()});
      this.input.val('');
    },
  });

  var App = new AppView;  
})
