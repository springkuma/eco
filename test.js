var Person = function() {
};
Person.prototype = {
    
    hello: function () {
	console.log('Hello');
	this.hoge();
    },
    hoge: function() {
        console.log('ho ge !');
    }

};
var bob = new Person();
bob.hello();
bob.hoge();
