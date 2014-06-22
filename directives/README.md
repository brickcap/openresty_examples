Nginx supplied it's own mini programming language in the form of directives. 
These directives we either block level or simple. Simple directives were 
structured as the name of the directive and the name of the parameters, 
the directive and parameters were separated by a space and the end of the 
directive was marked by a `;`. The block level directives were similar with
the only difference being instead of ending it with a `;` it contained `{` and
`}` brackets. Within a block level directive there could be one of multiple 
simple directives.These directives made up the configuration files.

nginx_lua keeps the same structuring of the configuration files. 
As we saw in the last chapter there is little difference between
a vanilla nginx configuration and a nginx_lua configuration. In fact almost
all of the nginx directives can be used as usual in an nginx_lua configuration
file. However nginx_lua adds several new directives that enhances the configurability
of nginx. We already looked at `content_by_lua` and `content_by_lua_file` in the last
chapter. Here we will take a look at a few more intersting ones

####lua_code_cache 

This directives tuns the caching of lua modules on or off. By default the  
the caching is turned on so that the lua modules are loaded once and then 
just refrenced. This is a desirable effect and we would not want to reload 
modules on every request. So when would you want to turn the caching off? 
Yep , you guessed it during the development phase. When caching is turned off 
on every request the module is reloaded so you can just edit and save your file and 
just refresh to see the changes. Just be sure to turn the lua_code_cache off in production. 


Let us test this by turning lua_code_cache off in our hello world example.
After the changes our configuration file should look something like this. 

```
worker_processes  1;
error_log /dev/stderr;
events {
    worker_connections 1024;
}
http {
    server {
        listen 8080;

	location /by_file {
        default_type text/html;
		lua_code_cache off; --only for development
        content_by_lua_file /lua/hello_world.lua; --update it with path to your lua file
        }

    }
}

```

Now lets run this by 

`nginx -p 'pwd' -c conf/nginx.conf` -- use -s reload if you are already running nginx. 

and then `curl http://localhost:8080/`

you should see

> <p> hello world </p> in response

Now edit the hello_world.lua to

`ngx.say("<b>hello world</b>");` 

and on `curl http://localhost:808/` you should see the response

><b>hello world</b>

This makes our workflow of developing  ngx_lua applications much smoother.

**Note** as you might have already guessed lua_code_cache works only for
`content_by_lua_file`  directive. It will have no effect upon `content_by_lua` directive.


#### init_by_lua 

init_by lua directive runs the lua code  specified by the parameter string on a global level. 
This is most useful when you want to register lua global variables or start lua modules during
the nginx server start up.

Before we take a look at the example of init_by_lua a friendly warning.

Refrain from using lua global variables. For most variables you should use a `local` 
keyword to make lua variables local to it's scope. And remember any variable declared
without a `local` keyword is global in lua.

```
local cat = "meow" -- use this form most of the time
dog = "woof" -- avoid this form except for when it makes sense

```

When does it make sense to use global varialbes?

Suppose you want to use a module that parses JSON which will be used  
in many handlers, or a database client that will be used in many handlers
or any other module that will be used across many handlers then it makes sense
to declare the variable global and even then init_by_lua should be the only place
where you do it.


`init_by_lua` has a variant in `init_by_lua_file` where you can supply a file
containing the lua code that will be run in a global context. Everything that we talked about in `init_by_lua`
also applies to `init_by_lua_file`. 


####set_by_lua 

set_by_lua directive is equivalent to nginx's [set](http://nginx.org/en/docs/http/ngx_http_rewrite_module.html#set)
directive in the http_rewrite_module. Quite predictably set was use to 'set' the value for a variable.
set_by_lua allows you to set the variable by evaluating a lua code string.


Once more set_by_lua has a _file alternative in `set_by_lua_file` that allows you to set a variable
by executing the code in lua file.

**Note** set_by_lua blocks the nginx's event loop during it's execution therefore long time consuming 
code sequence are best avoided here. So while a few arithmetic computations are fine loops should be 
avoided.

`set_by_lua` works well with nginx's set command so the two can be used interchangeably. The directives
will run in the order in which they appear in the code.





#### content_by_lua

We already discussed this directive in the hello_chapter. But now that we have taken a look at
at how the directives work we can see content_by_lua in a different light.  

Unlike the set_by_lua command that blocks the nginx's event loop content_by_lua directive
runs in it's own spawned coroutine. Which means that it does not block the nginx'e event loop
and runs in a seperate environment. content_by_lua directive belongs to a special class of
directives called the content handler directives. They execute only in the context of `location`
directive (which if you recall our discussion at the beginning of this chapter is a block level directive).

Anyway, the location directive captures the request to a particular handle and
then leaves it to the content handler to service the request. For instance

```
location /me
{
root /data/me;
}


```
if a request is made to `/me` handle the files in `/data/me` would be served.
A location block should have one content handler only. Do not mix nginx's
default content handlers like proxy_pass or directory mappers with ngx_lua's  content_by_lua.

