// Generated by CoffeeScript 1.3.3
(function() {

  $(function() {
    var App, AppView, DateView, Expense, ExpenseList, ExpenseView, Expenses, Todo;
    Todo = Backbone.Model.extend({
      idAttribute: "_id",
      defaults: function() {
        return {
          title: "empty todo...",
          done: false
        };
      },
      initialize: function() {
        if (!this.get("title")) {
          return this.set({
            "title": this.defaults().title
          });
        }
      },
      clear: function() {
        return this.destroy();
      }
    });
    Expense = Backbone.Model.extend({
      idAttribute: "_id",
      defaults: function() {
        return {
          date: new Date(),
          remark: "",
          price: 0
        };
      },
      initialize: function() {
        if (!this.get("date")) {
          this.set({
            "date": this.defaults().date
          });
        }
        if (this.get("date") !== Date) {
          return this.set({
            "date": new Date(this.get("date"))
          });
        }
      },
      display_date: function() {
        return this.getDateToString(this.get("date"));
      },
      getDateToString: function(target) {
        if (target === String) {
          target = new Date(target);
        }
        return "" + (target.getMonth() + 1) + "/" + target.getDate();
      }
    });
    ExpenseList = Backbone.Collection.extend({
      model: Expense,
      url: "/expenses"
    });
    Expenses = new ExpenseList;
    ExpenseView = Backbone.View.extend({
      tagName: "li",
      className: "expense_item",
      template: _.template($('#item-template').html()),
      events: {
        "click a.destroy": "clear",
        "dblclick .view": "edit",
        "keypress .edit": "updateOnEnter",
        "blur .edit": "close"
      },
      initialize: function() {
        this.model.bind('change', this.render, this);
        return this.model.bind('destroy', this.remove, this);
      },
      render: function() {
        this.$el.html(this.template(_.extend(this.model.toJSON(), {
          "display_date": this.model.display_date()
        })));
        this.input = this.$('.edit');
        return this;
      },
      edit: function() {
        this.$el.addClass("editing");
        return this.input.focus();
      },
      updateOnEnter: function(e) {
        if (e.keyCode === 13) {
          return this.close();
        }
      },
      close: function() {
        var value;
        value = this.input.val();
        if (!value) {
          this.clear();
        }
        this.model.save({
          title: value
        });
        return this.$el.removeClass("editing");
      },
      clear: function() {
        return this.model.clear();
      }
    });
    DateView = Backbone.View.extend({
      tagName: 'li',
      template: _.template($('#date-template').html()),
      events: {
        "keypress": "addExpense"
      },
      initialize: function(year, month, date) {
        this.date = new Date(year, month, date);
        return this.id = "new-" + (this.date.getMonth() + 1) + "-" + this.date.getDate();
      },
      render: function() {
        this.$el.attr({
          id: this.id
        });
        this.$el.html(this.template(this.date));
        this.remark = this.$el.find(".new-remark-field");
        this.price = this.$el.find(".new-price-field");
        return this;
      },
      addOne: function(expense) {
        var view;
        view = new ExpenseView({
          model: expense
        });
        return this.$("#expense-list").append(view.render().el);
      },
      addExpense: function(e) {
        if (e.keyCode !== 13) {
          return;
        }
        console.log(this.remark.val(), this.price.val());
        Expenses.create({
          date: this.date,
          remark: this.remark.val(),
          price: this.price.val()
        });
        this.remark.val("");
        return this.price.val("");
      }
    });
    AppView = Backbone.View.extend({
      el: $("#expenseapp"),
      events: {
        "keypress #remark": "addExpense",
        "keypress #price": "addExpense"
      },
      initialize: function() {
        var i, today, view;
        this.input = this.$("#new-todo");
        this.display_date = this.$("#selectdate");
        this.remark = this.$("#remark");
        this.price = this.$("#price");
        this.dates = new Array();
        Expenses.bind("add", this.addOne, this);
        Expenses.bind('reset', this.addAll, this);
        Expenses.bind("all", this.render, this);
        this.footer = $('footer');
        this.main = $('#main');
        today = new Date();
        i = 1;
        while (i <= today.getDate()) {
          view = new DateView(today.getYear(), today.getMonth(), i);
          this.dates.push(view);
          this.$("#date-list").append(view.render().el);
          i++;
        }
        return Expenses.fetch();
      },
      render: function() {
        this.main.show();
        this.footer.show();
        $("#yama").html(Expenses.length);
        return this;
      },
      addOne: function(expense) {
        return this.dates[expense.get("date").getDate() - 1].addOne(expense);
      },
      addTodo: function(e) {
        if (e.keyCode !== 13) {
          return;
        }
        Todos.create({
          title: this.input.val()
        });
        return this.input.val("");
      },
      addExpense: function(e) {
        if (e.keyCode !== 13) {
          return;
        }
        Expenses.create({
          date: this.getStringToDate(this.display_date.val()),
          remark: this.remark.val(),
          price: this.price.val()
        });
        this.remark.val("");
        return this.price.val("");
      },
      addAll: function() {
        return Expenses.each(this.addOne, this);
      },
      getDateToString: function(date) {
        return "" + (date.getMonth() + 1) + "/" + date.getDate();
      },
      getStringToDate: function(str) {
        var ary, date, month_date, _i, _len;
        ary = str.split("/");
        month_date = new Array();
        for (_i = 0, _len = ary.length; _i < _len; _i++) {
          date = ary[_i];
          month_date.push(parseInt(date));
        }
        date = new Date();
        date.setMonth(month_date[0] - 1);
        date.setDate(month_date[1]);
        return date;
      }
    });
    return App = new AppView();
  });

}).call(this);
