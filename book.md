
<h1 id="hello_world">Hello world</h1>

Openresty is just an enhancement of nginx. 
If you are familiar with nginx you will feel right at home with openresty. 
This is a hello_world example to illustrate how to write openresty scripts. 
The first thing to understand here is the file structure. Here is a high level overview 


```
root
 -logs
 -conf

```

All the nginx configuration files go within the `conf` folder and all the logging goes in the `logs` folder. 
Easy right? This structure will not only do for our 
simple demonstration here but will also  hold well for complex examples 
that we will work on later.  Let us examine the configuration file for the hello_world example 


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

This will look very familiar to you if you have used nginx. 
The only thing that is new in this file is the `content_by_lua` statement. 
This statement executes the lua code that within the `''` string. 
The nginx api is provided to lua in the form of a standard package `ngx`. 
Well there are in fact two packages `ngx` and `ndk` but we will focus on `ngx` 
for now as we can get far with just that. What `ngx.say()` does is 
that it sends the concatenated arguments to the client as an http response. 
But enough talk for now. Let us run this example:- 

``` nginx -p `pwd` -c conf/nginx.conf ```

and then 

`curl http://localhost:8080/`

you should see a response 

`<p>hello world</p>`

And congratulations you have written you first openresty script. 
Now I don't know about you but wrapping code scripts 
around string code does not look pretty to me. 
Wouldn't it be nice if we could create a sperate file for 
lua scripts and include it in the nginx configuration files? 
`content_by_lua_file` allows us to do just that. Let us create a seperate directory `lua`  

`mkdir lua`

And now create a lua file called `hello_world.lua` containing just one line of code 

`ngx.say("<p>Hello world from a lua file</p>");`

 
Now we will create another location block in the `nginx.conf` 
file that will use `content_by_lua_file` istead of `content_by_lua`. 
Here is what the final configuration looks like 


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
        content_by_lua_file ./lua/hello_world.lua;
        }

    }
}

```

Before we curl for the `/by_file` location we must reload nginx  

```nginx -p `pwd` -s reload ````

now `curl http://localhost:8080/by_file` should return

`<p>hello world from lua</p>`

-----

<h1 id="directives">Directives</h1>

Nginx comes with it's own mini programming language in which directives form the basic constructs. 
These directives are either block level or simple. Simple directives are 
structured as the name of the directive and the name of the parameters. 
The directive name and the parameters are separated by a space and the end of the 
directive is marked by a `;`. The block level directives were similar with
the only difference being  it was marked by `{` and
`}` brackets. Within a block level directive there could be one or more 
simple directives.These directives made up the configuration files.

```
#location is a block level directive

location /{
#proxy_pass is a simple directive
proxy_pass http://localhost:5984/; 

}


```


`nginx_lua` keeps the same structuring of the configuration files. 
As we saw in the last chapter there is little difference between
a vanilla nginx configuration and an nginx_lua configuration. In fact almost
all of the nginx directives can be used as usual in an `nginx_lua` configuration
file. However nginx_lua adds several new directives that enhances the configurability
of nginx. We already looked at `content_by_lua` and `content_by_lua_file` directives in the last
chapter. Here we will take a look at a few more intersting ones

####lua_code_cache 

This directive turns the caching of lua modules on or off. By default the  
the caching is turned on so that the lua modules are loaded once and then 
just reused. This is a desirable effect and we would not want to reload 
modules on every request. So when would you want to turn the caching off? 
During the developmental phase. It can be a pain 
to edit the configuration file, save it and then do an `nginx -s reload`
over and over agin. 
When caching is turned off  the module is reloaded 
on every request so you can just edit, save your file and then 
"refresh" to see the changes. Just be sure to turn the `lua_code_cache` 
off in production. 


Let us test this by turning `lua_code_cache` off in our hello world example.
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
		lua_code_cache off; #only for development
        content_by_lua_file ./lua/hello_world.lua; #update it with path to your lua file
        }

    }
}

```

Now lets run this by 

`nginx -p 'pwd' -c conf/nginx.conf`

You should see an alert message displayed on your console
 
> lua_code_cache is off; this will hurt performance in ./directives/conf/nginx.conf

Disregard the message for now. But keep in mind to turn on the code cache 
in production.

Then `curl http://localhost:8080/`

you should see

> <p> hello world </p> in response

Now edit the hello_world.lua to

`ngx.say("<b>hello world</b>");` 

and on `curl http://localhost:808/` you should see the response

><b>hello world</b>

This makes our workflow of developing  ngx_lua applications much smoother.

**Note** as you might have already guessed `lua_code_cache` works only for
`*by_lua_file`  directives. It will have no effect upon `by_lua*` directives.

nginx block level rules apply to the `lua_code_cache` directive. Which
means if you set `lua_code_cache` off in a top level directive all the other
lower lever directives will pick up on this configuration. Simillary you can achieve
isolation for particular directives by turning the caching off only
for those directives. 


Also  any changes you make to the nginx.conf file itself 
won't be detected automatically by nginx. And you will have to 
reload the server manually. This automatic reload works only for lua files.




#### init_by_lua 

init_by lua directive runs the lua code
specified by the parameter string on a global level.  
This is most useful when you want to register 
lua global variables or start lua modules during 
the nginx server start up. 

Before we take a look at the example of `init_by_lua` a friendly warning.

Refrain from using lua global variables. For most variables you should use a `local` 
keyword to declare lua variables local to it's scope. And remember any variable declared
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
containing the lua code that will be run in a global context. 
Everything that we talked about in `init_by_lua` 
also applies to `init_by_lua_file`. 
 

```
   location /json{
       content_by_lua '
        ngx.say(cjson.encode({message="hello world",another_message="goodbye world"}));
            ';
   }


```

In the location block above we are using `cjson` global
variable that was declared in an `init_by_lua_file` to encode
lua tables in json. `cjson` was a good contender for the global
varibale declaration because we are going to be using it in many
location blocks. 

####set_by_lua 

`set_by_lua` directive is equivalent to nginx's 
set commands.  
Quite predictably set is used in nginx to 'set' the value for a variable.  
Simillarly `set_by_lua` allows you to set a variable by evaluating a lua code string. 


Once more `set_by_lua` has a _file alternative in `set_by_lua_file` 
that allows you to set a variable 
by executing the code in lua file. 

**Note** `set_by_lua blocks` the nginx's event loop during 
it's execution therefore long time consuming 
code sequences are best avoided here.
So while a few arithmetic computations are fine loops should be 
avoided. 

`set_by_lua` works well with nginx's `set`
command so the two can be used interchangeably. 
The directives will run in the order in which they appear in the code.
Works with set in HttpRewriteModule,  HttpSetMiscModule, and HttpArrayVarModule.


```

 location /set_by_lua{
	    set $nvar 20;
	    set_by_lua $lvar 'return ngx.var.nvar+1';
	    echo "$nvar,$lvar";
    }
       


```


#### content_by_lua

We already discussed this directive in the hello_ world chapter. 
But now that we have more understanding of 
how the directives work we can see content_by_lua in a different light.  

Unlike the set_by_lua command that blocks the nginx's event loop content_by_lua directive
runs in it's own spawned coroutine. Which means that it does not block the nginx's event loop
and runs in a seperate environment. content_by_lua directive belongs to a special class of
directives called the content handler 
( they are not actually called that but you will see what I mean in a minute) directives. 
They execute only in the context of `location` 
directive (which if you recall our discussion at the beginning 
of this chapter is a block level directive).

Anyway, the location directive captures the request for a matching url and
then leaves it to the content handler to service the request. For instance

```
location /me
{
root /data/me;
}


```

if a request is made to `/me` handle the content in `/data/me` would be served.
A location block should have only one content handler. Do not mix nginx's
default content handlers like proxy_pass or directory mappers with ngx_lua's content_by_lua.

And yeah there is a `content_by_lua_file` :)

####rewirte_by_lua

ngnx_lua equivalent of nginx's 
[HttpRewriteModule](http://nginx.org/en/docs/http/ngx_http_rewrite_module.html). 
Like the `content_by_lua` directive `rewrite_by_lua` runs in a spawned coroutine.
The important thing to keep in mind here is that the directive always runs after the
standard `http_rewrite_module`. So if you are using both keep that in mind.

Remember how the `set_by_lua` directive was blocking?

Well you can mitigate that to some extent now 
If you are using `set_by_lua` for the `set` in `http_rewrite_module` 
then you can safely replace it using `rewrite_by_lua`. It is non blocking. 

`rewrite_by_lua` can make api calls 
(we will see how to make api calls in the next chapter). 
So you can issue dynamic rewrites
based on the response returned from your database etc. 

About `rewrite_by_lua_file` : .....

It's same as `rewrite_by_lua` except that it 
executes lua code from a file. 



####access_by_lua

ngx_lua equivalent of
[HttpAccessModule](http://nginx.org/en/docs/http/ngx_http_access_module.html)

Two points to not here

1. It runs in a seperate coroutine.

2. It runs after the standard nginx  `http_access module` so if you are mixing the two
keep that in mind.

Like `rewrite_by_lua` it can make api calls. 

And there is a `access_by_lua_file`


By now you have probably understood what lua directives are and how 
they work. There are a few more directives: some of them are utilities 
and some for tweaking the ngx_lua behaviour.

The ones I have covered though are  ones that you will
be using most of the time. So instead of going on and on about the directives
I will leave a [link to the reference](http://wiki.nginx.org/HttpLuaModule#Directives)
and you can study them at your convenience.  

For now we move on to the meatier stuff. The ngx_lua API.

--------


<h1 id="the_ngx_api">The ngx api</h1>

Ah the nginx API. This is where the magic happens. 
Remember all those `by_lua` directives that we talk about in the last chapter? 
They are all just there to execute lua api for nginx. In the words of the
author of ngx_lua 

> The various *_by_lua and *_by_lua_file configuration directives 
serve as gateways to the Lua API within the nginx.conf file


The nginx api is available in the form of two packages 
`ngx` and `ndk`. These packages are in the global scope by default 
and are always available to the lua directives. Which clears up a few
things for us. Remember how in `*_by_lua_file` directives we
could simply call the methods on `ngx` package even without requiring it?
As you can probably infer, the reason for it was that the `ngx` package
was already availaible to the directive globally. So there
was no need for us to `require` it.

####ngx.arg

Context : `set_by_lua` and `body_filter_by_lua`

We have already seen what `set_by_lua` does in the last chapter.
In the context of `set_by_lua` ngx.arg provides a set of read only 
argumets to the directive.

```


```

`ngx.arg` indices start from 1 instead of 0. So keep that
in mind when you are accessing arguments form it.

`body_filter_by_lua` can be used to filter the response
body and modify what response goes out. `ngx.arg` supplies
the arguments to `body_filter_by_lua`.

`ngx.arg[1]` : contains the acutal data chunk

`ngx.arg[2]`: contains the boolean `eof`. If true it indicates the end of body.   

```


```

The important distinction here is that unlike the args in `set-by_lua`
the args in `body_filter_by_lua` can be modified directly by the lua code.
In fact in the example that we saw above we have modified the response body
to a different value.



#### constants

ngx_lua provides easy to remember "named" constants as an alternative to 
using "numbered" status. For instance instead of sending a 301 redirect 
you can use `ngx.HTTP_MOVED_PERMANENTLY (301)`. Don't worry if you don't understand 
what these contants do. We will learn how to use these constants in later sections. 

**core**

```
ngx.OK (0)
ngx.ERROR (-1)
ngx.AGAIN (-2)
ngx.DONE (-4)
ngx.DECLINED (-5)

```

**HTTP methods**

```
ngx.HTTP_GET
ngx.HTTP_HEAD
ngx.HTTP_PUT
ngx.HTTP_POST
ngx.HTTP_DELETE
ngx.HTTP_OPTIONS   
ngx.HTTP_MKCOL     
ngx.HTTP_COPY      
ngx.HTTP_MOVE      
ngx.HTTP_PROPFIND  
ngx.HTTP_PROPPATCH 
ngx.HTTP_LOCK      
ngx.HTTP_UNLOCK    
ngx.HTTP_PATCH     
ngx.HTTP_TRACE

```

**HTTP STATUS CONSTANTS**

```

ngx.HTTP_OK (200)
ngx.HTTP_CREATED (201)
ngx.HTTP_SPECIAL_RESPONSE (300)
ngx.HTTP_MOVED_PERMANENTLY (301)
ngx.HTTP_MOVED_TEMPORARILY (302)
ngx.HTTP_SEE_OTHER (303)
ngx.HTTP_NOT_MODIFIED (304)
ngx.HTTP_BAD_REQUEST (400)
ngx.HTTP_UNAUTHORIZED (401)
ngx.HTTP_FORBIDDEN (403)
ngx.HTTP_NOT_FOUND (404)
ngx.HTTP_NOT_ALLOWED (405)
ngx.HTTP_GONE (410)
ngx.HTTP_INTERNAL_SERVER_ERROR (500)
ngx.HTTP_METHOD_NOT_IMPLEMENTED (501)
ngx.HTTP_SERVICE_UNAVAILABLE (503)
ngx.HTTP_GATEWAY_TIMEOUT (504) 

```

**Log level constants**

```
ngx.STDERR
ngx.EMERG
ngx.ALERT
ngx.CRIT
ngx.ERR
ngx.WARN
ngx.NOTICE
ngx.INFO
ngx.DEBUG

```

#### ngx.location.capture

Context: rewrite_by_lua, access_by_lua, content_by_lua

`ngx.location.capture` is one of the most powerful methods in the lua ngx api. It allows you
to make subrequests to a uri(location).

What makes it so powerful you ask?

Remember the nginx `location` directive?

What `location` does is: It defines endpoints for clients to make requests to. For instance
a `location /hello` tells the client that if you make a request to `/hello` I will give you
back the results of code excuted inside the `location` directive. And important point
to note here is that any request made by the client to this `location` endpoint is
an `http/tcp` request. 

What `ngx.location.capture` does is that it issues an interal non blocking, syncrhonous request
to a `locaiton`. Unlike the clients request which has to be http the location capture requests involve
no http overhead. It is just a fast and light internal `c` level call while mimicking
the familliar http interface. Time for an example


```


```

See how simple it is. Issue a request to the `uri` already defined somewhere in a
`location` directive and capture it's response.

Now one area where many people are confused (I admit I was too when I was
first learnt about it) is that the uri **must be internal**. If you try to do

```
local res = ngx.location.capture("http://www.google.com/")

```
it won't work. Because the uri is external. However if you do

```
local res = ngx.location.capture("/google_proxy")

```
where `/google_proxy is in the conf as`

```
location /google_proxy{
proxy_pass http://www.google.com/;
}

```

then the request will work. It is important to understand that `ngx.location.capture` works
only on internal requests (or on locations that are defined in the configuration files)
but that location can make an external http request.

So now back to the topic. The `res` returned by `ngx.location.capture` contians ..
well the response of the subrequest. Let us examine it.

1. res.status:- the status code of the completed request.
2. res.header-: the headers returned by the response.
3. res.body:- the body in the response which may be ...
4. res.truncated-: boolean that incaded if the body is truncated or not.

res.status, res.body and res.truncated are pretty straightforwad. res.header require more examination.

The response headers are simply a lua table. Here is what it might look like

```
{
Vary="Accept",
Etag='"E0KG1DRLA505ILRLPEJOPM679"'
}

```
So you access the header the same way in which you access a key from any lua table. For instance to access
the vary header we do `res.header["Vary"]`.

Thus far we have seen how to make only simple requests
the internal uri using the `ngx.location.capture` but the api
is far more flexible. You can pass query strings directly in
the url or by uisng the args option. For instance:-

````
local res= ngx.location.capture("/hello?a=1&b=2")

```

and

```
local res = ngx.location.caputre("/hello",{args={a=1,b=2}}) 

```

are equivalent. In both the cases a subrequest will be made to `/hello?a=1&b=2`


Infact the opitonal table can hold a lot more keys than just an `args`.

```
   local account_page = ngx.location.capture("/get_account",
					     {method=ngx.HTTP_POST,body=
					     json_body,args={user_name=name}
					     })


```

The above sample illustrates the point. Here the `ngx.location.capture` passes in

1. method: You can use the ngx constants that we discussed earlier
2. body: the body to send to the subrequest. Here it is json encoded.
3. args: the query strings that we just discussed.

While method,body and args are th ones that you will find yourself using more frequently just for the
sake of completeness a complete list of all the optional keys that can be passed to the table can be found
in the official docs.


### ngx.location.capture.multi

context: rewrite_by_lua*, access_by_lua*, content_by_lua* 

Oh yes :) Take the `ngx.location.capture` and level it up by lua's superpowers.
One of the unique thigs about lua is that a function can have multiple return values. If this is your
first time wokrig with lua then it might be a bit hard to to figure out when to use this feature. But
luckily ngx lua makes the application of this unique concept quite obvious. Check this out:-

```
local home,about,contact = ngx.location.capture.multi{{"/home"},{"/about"},{"/contact"}}

```
The above snipped of code is just like `ngx.location.capture` that we talked about before. The
only difference here is that instead of making a subrequest to a single uri you can make
subrequests to multiple uris with a single line of code. Two important things to note here is that

1) These multiple subrequests run in parallel.
2) The results are returned when all the subrequests are completed.

So if you were thinking about piping the result of one subrequest into another then you are out of luck.
But multi req are still pretty cool. Why?

Consider this scenario:- It would not be an exxageration to say that all applications today use
some third party apis to as supports for thier main application. Say you have an application where you
aggregate the results of interesting conversations across the internt. You pull in data from various sources like
twitter, facebook and linkedin. In this scenario you have to make atleast three seperate http requests to aggregate
the data. 

So what do you do? Just this:-

```
local statuses,tweets,posts = ngx.location.capture.multi{{"/facebook_graph"},{"/tweets"},{"/lnkedin"}}

```

and it all simply works. Now the application is not limited to external third party data aggregation.
It is quite probable that internally you use many applications that work on secondary tasks and maybe you
want to generate a report  by querying them for updates. All you got to do is issue an `ngx.location.capture.multi` and
you are set.

**Can one use an options table like in the nginx.location.capture?**

Of course you can. Here is how:-


```
local res1,res2 = ngx.location.capture.multi{
	{"/req1",{method=ngx.HTTP_POST}},
	{"req2",{args={a=1,b=2}}}
}

```

Every request in multi is contained within it's own table which can perform all of things that
we saw in a simple `ngx.location.capture`. Cool isn't it?




### req

ngx api exposes a req object that allows us to configure explicitly our req parameters before sending it to
the server. This means that you can easily add/remove http headers and body, configure the method of the
req.

On the other hand the ngx api also provides ability to read an incoming req from the client. Which means
that you can read the http headers and the body check the method of the req and then send the response back.

Quite naturally the req table forms a very important part of ngx api. Let us take a deeper look at it 
then:-

**The headers**

`ngx.req.get_headers()` gives you back a table of headers which you can then query as usual. For example

```
local headers = ngx.req.get_headers()

local cookie = headers["Cookie"]

local etag = headers["Etag"]

local host = headers["Host"]

```

Simillarly it's conter-part `ngx.req.set_header` is used to set a req header for outgoing requests

```
local host = ngx.req.set_header("www.google.com")

```

### what about the body and post arguments?

ngx provides `ngx.req.read_body()` to read all of the body data. Once the body has been read a convinence method 
is provided in `ngx.req.get_body_data` and `ngx.req.get_post_args` which return a string/lua table. 
 

### res
