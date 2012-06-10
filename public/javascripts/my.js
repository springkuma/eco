console.log('tehteh');

var Todo = Backbone.Model.extend({
  initialize: function(){

  },
  defaults: {
    name: 'name',
  }
});

var todo = new Todo({});
console.log(todo.get('name'));
