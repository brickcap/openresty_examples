Openresty is just an enhancement of nginx. If you are familiar with nginx you will feel right at home with openresty. This is a hello_world example to illustrate how to write openresty scripts. The first thing to understand here is the file structure. Here is a high level overview


```
root
 -logs
 -conf

``` 
All the nginx configuration files go within the `conf` folder and all the logging goes in the `logs` folder. Easy right? This structure will not only do for our simple demonstration here but will also  hold well for complex examples that we will work on later.  Let us examine the configuration file for the hello_world example


```
worker_processes  1;
error_log logs/error.log;
events {
    worker_connections 1024;
}
http {
    server {
        listen 8080;
        location / {
            default_type text/html;
            content_by_lua '
                ngx.say("<p>hello, world</p>")
            ';
        }
    }
}

```

This will look very familiar to you if you have used nginx. The only thing that is new in this file is the `content_by_lua` statement. This statement executes the lua code that within the `''` string. The nginx api is provided to lua in the form of a standard package `ngx`. Well there are in fact two packages `ngx` and `ndk` but we will focus on `ngx` for now as we can get far with just that. What `ngx.say()` does is that it sends the concatenated arguments to the client as an http response. But enough talk for now. Let us run this example:- 

``` nginx -p `pwd` -c conf/nginx.conf ```

and then 

`curl http://localhost:8080/`

you should see a response 

`<p>hello world</p>`

And congratulations you have written you first openresty script. Now I don't know about you but wrapping code scripts around string code does not look pretty to me. Wouldn't it be nice if we could create a sperate file for lua scripts and include it in the nginx configuration files? `content_by_lua_file` allows us to do just that. Let us create a seperate directory `lua` 

`mkdir lua`

And now create a lua file called `hello_world.lua` containing just one line of code

`ngx.say("<p>Hello world from a lua file</p>");`

 
Now we will create another location block in the `nginx.conf` file that will use `content_by_lua_file` istead of `content_by_lua`. Here is what the final configuration looks like


```
worker_processes  1;
error_log logs/error.log;
events {
    worker_connections 1024;
}
http {
    server {
        listen 8080;
        location / {
            default_type text/html;
            content_by_lua '
                ngx.say("<p>hello, world</p>")
            ';
        }

	location /by_file {
        default_type text/html;
        content_by_lua_file /lua/hello_world.lua;
        }

    }
}

```

Before we curl for the `/by_file` location we must reload nginx 

```nginx -p `pwd` -s reload ````

now `curl http://localhost:8080/by_file` should return

`<p>hello world from lua</p>`
