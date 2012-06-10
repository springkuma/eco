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

var YamaView = Backbone.View.extend({
  tagName: 'div',
  className: 'yama',

  initialize: function(){
    console.log('initialize');
    this.render();
  },
  render: function(){
    console.log($(this.el));

    $(this.el).html('hogehoge');
  }
});

var view = new YamaView();