A = function(){
  this.aaa = "bbb";
  this.bbb = {
    ccc: "ddd",
    ddd: "eee",
    f1: function(){
      console.log(this);
      return true;
    }
  };

  console.log(this);
  this.bbb.f1.apply(this);
};

a = new A();
// console.log(a.bbb.ccc);
