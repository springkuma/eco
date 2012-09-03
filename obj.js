var c = 2;

var o = (function(){
  var a = 'a';
  var b = function(){
    return {
      d: 1,
      func: function(){
        console.log(a);
        console.log(this);
        return this.d;
      }
    };
  }();

  console.log(b.func());
})();

console.log(o.b);
