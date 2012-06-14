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
  el: $(".yama"),

  initialize: function(){
    console.log('initialize');
    this.render();
  },
  render: function(){
    console.log('render');

//    $(".yama").html('hogehoge');
    this.$el.html('hogehoge');
    return this;
  }
});

var view = new YamaView;
console.log(view.el);
console.log($(view.el).html)