/* _init.js executes once upon server startup (and also anytime you change it)
*/

core.user.auth();

/* Function allowed() is called on every request before processing for authentication purposes.
   The default implementation below denies non-admin users access to anything under /admin/ on the
   site, but keeps the site completely open otherwise.
*/
function allowed( req , res , uri ){
}

/* The following is used by the Ruby smorgasbord example. */

data = {};
data.count = 0;
data.func = function() { return 666; }
data.plus_seven = function(i) { return i + 7; }

MyJSClass = function(foo) {
  this.foo = foo;
}
MyJSClass.prototype.moo = function() {
  return this.foo.reverse();
}
