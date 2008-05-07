core.user.auth();
core.blog.urls();
core.core.routes();

routes = new Routes();


/* Function allowed() is called on every request before processing for authentication purposes.
   The default implementation below denies non-admin users access to anything under /admin/ on the
   site, but keeps the site completely open otherwise.
*/
function allowed( req , res , uri ){
    user = Auth.getUser( req );
}

allowModule = { blog: {} };

routes.setDefault( "index.jxp" );

