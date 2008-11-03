NewClass3 = function(foo) {
  print("Hi! I am in NewClass3 function; this = " + this + " and the argument is " + foo + "\n");
  this.foo = foo;
}
NewClass3.prototype.moo = function() {
  print("Hi! I am in NewClass3 function moo; this = " + this + "; this.foo = \"" + this.foo + "\"\n");
  return this.foo.reverse();
}
