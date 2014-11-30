<h1 id="contents">Contents</h1>

1. [Why openresty](#why_openresty)
2. [Our first openresty script](#hello_world)
3. [The directives](#directives)
4. [The ngx api](#the_ngx_api)

<h1 id="why_openresty">Why openresty?</h1>

<small><a href="#contents">Back to the contents</a></small>

Before we answer the why let us first deal with the what.

"**What is openresty?**"

Openresty is a packaging of nginx together with various useful libraries that can be used
to *write* application servers. Notice the  emphasis on write. Now you will not be limited to just
configuring your server but you can program it. At it's core it's still the nginx that you know. All your configuration
files that work with vanilla nginx will work with openresty. When you install openresty you loose
nothing. But you gain:-

1. An ability to script nginx with an easy to use language, lua.
2. Do things that were impossible or not straightforward with nginx configuration files before.

With that out of the way.. why would you want to learn about open resty at all? Aren't there
enough web frameworks already? Do you need to learn yet another one?

Fair questions. Nginx does web applications really really well. It is light, it is fast and it is
very well documented. People have often reported that just by  configuring nginx
to serve their applications they have gained performance boost. That nginx makes your applications fast is a
well accepted fact. What openresty does is that it takes all the goodness of nginx : it's fast response time and
it's low memory usage and removes the barriers to developing applications with it.

"**And what are these barriers?**"

The configuration files themselves. While they are quite flexible all they do is they limit the power of nginx to the set
that is configurable. Sure you can do a lot but not anything beyond what is allowed. Here is a simple example for instance

Suppose before forwarding the data `POSTed` to your application you want to do certain checks on it so that you can be sure that your application get's only the clean refined data to operate upon. Is there any easy way to validate the data posted to nginx before it is forwarded to your application server? If there is I could not find it. But in open resty this is as simple as

```
content_by_lua '

-- read the request of the body
ngx.req.read_body()

-- give back the body as an easily query-able table data structure
local post_args = ngx.req.get_post_args() 

-- validate the data 
local clean_body_data = require("lib/validate").validate_body(post_args)

'

```

This has the effect of simplifying your architecture by guaranteeing that any data that is posted by the proxy is valid. So your application layer can focus on operating upon it without worrying about cleansing it first. Once you learn open resty you will be able to identify many such functions that can be better delegated to a proxy. It will simplify your application and use nginx and all it's low resource, fast performance goodness to the fullest. Win win.

"**But my application is working. I don't want to change any thing**"

I am not asking you to change. Remember that openresty is still nginx. Everything that was working will continue to
work. Openresty just gives you an opprotunity to make use of nginx in ways that you might not have considerd before. You have nothing to loose and much to gain. 

**What do you need to start learning open resty?**

You need to know lua. BUT BEFORE YOU CLOSE THIS TAB know that you don't need to have a mastery of
the language to start developing openresty applications. All you need is [15 minutes worth of lua](http://tylerneylon.com/a/learn-lua/) and you are all set to go. More specifically you need to have a solid understanding of lua tables,
lua modules, how to write loops and conditional statements and the variable scope in lua. If you have
programmed before you can learn all of this before you finish your first cup of coffee :)

**But wait I don't know any nginx**

Not a problem. Nginx applications are written in what are known as configuration files. You can get
most of it by just reading but if you encounter any problem the [nginx has a very detailed documentation](http://nginx.org/) and tonnes of community support so you should be able to google your way out of any trouble.
The entire guide is written with the assumption that

1. You have no knowledge of nginx
2. You can work with the command line: copy paste the code, run programs etc
3. Read the manual in case you need more detailed information.

All you need therefore to follow this guide is willingness to learn. 

<h1 id="hello_world">Hello world</h1>

<small><a href="#contents">Back to the contents</a></small>

In case you skipped the introduction and jumped to the hello world then first of all good for you! and second a summary of what I said above:-

>Openresty is just an enhancement of nginx. So all you knowledge carries over.

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

```
nginx -p `pwd` -c conf/nginx.conf

```
Here pwd is the path with directory of your configuration file

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

<small><a href="#contents">Back to the contents</a></small>

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

<small><a href="#contents">Back to the contents</a></small>

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
the familliar http interface. Time for an example:-


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

#### location capture FAQS

**Q**:Is location.caputure/capture_multi synchronous?
**A**: Yes. location capture is synchronous but non blocking. Synchronous but non blocking? Well yes.
You see the location capture provides a lua interface over what are known as [subrequests](http://openresty.org/download/agentzh-nginx-tutorials-en.html#nginx-variables-a-detour-to-subrequests) in nginx world. Quoting from the article linked above:-

>Subrequests may look very much like an HTTP request in appearance, their implementation, however, has nothing to do with neither the HTTP protocol nor any kind of socket communication. A subrequest is an abstract invocation for decomposing the task of the main request into smaller "internal requests" that can be served independently by multiple different location blocks, either in series or in parallel.

>when the Nginx core processes a subrequest, it just calls a few C functions behind the scene, without doing any kind of network or UNIX domain socket communication. For this reason, subrequests are extremely efficient.

A single location capture like

```
local res = ngx.location.capture("url")

```


intiates a subrequest at nginx's level and it's equivalent to:-


```
location /main {
    echo_location /url;   
}

location /url{
echo hello_url;
}


```
Where as location.capture_multi sends out a series of parallel subrequests to location blocks. For example

```
local res1,res2 = ngx.location.capture_multi{{"/url1"},{"url2"}}

```

The above lua code initates multiple paralell subrequests to locations `url1`  and `url2`. The results are returned after all the requests have been completed. The equivalent nginx code would be

```
location /main{
echo_location /url1;
echo_location /url2;
}


location /url1{
echo hello_url1;
}


location /url2{
echo hello_url2;
}

```
So by synchronous yet non blocking we mean that location capture waits for the requests to complete. But the requests themselves are executed independantly in their won location blocks.

### req

ngx api exposes a req object that allows us to configure explicitly our req parameters before sending it to
the server. This means that you can easily add/remove http headers and body, configure the method of the
req.

On the other hand the ngx api also provides ability to read an incoming req from the client. Which means
that you can read the http headers and the body check the method of the req and then send the response back.

Quite naturally the req table forms a very important part of ngx api. Let us take a deeper look at it 
then:-

**The headers of the request**

`ngx.req.get_headers()` gives you back a table of headers which you can then query as usual. For example

```
local headers = ngx.req.get_headers()

local cookie = headers["Cookie"]

local etag = headers["Etag"]

local host = headers["Host"]

```

Simillarly it's conter-part `ngx.req.set_header` is used to set a req header for outgoing requests

```
ngx.req.set_header("Content-type","application/json")

```

If for some reason you want the actual headers sent by the client instead of the ones that have been parsed
into a table you can use `ngx.req.raw_header`

To clear a header you can use `ngx.req.clear_header`. Can be very useful when making
a proxy req from the client to the server.


**The body of the request**

ngx provides `ngx.req.read_body()` to read all of the body data. Once the body has been read a convinence method 
is provided in `ngx.req.get_body_data` and `ngx.req.get_post_args` which return a string/lua table.

```
ngx.req.read_body()

local args = ngx.req.get_post_args()

-- just like the headers args is a lua table. 

```

To set the body data you can use `ngx.set_body_data`

**The method of the request**

`ngx.req.get_method ` is used to get the method of an incoming request. `ngx.req.set_method` is used to set
the method for an outgoing request. 

```
local method = ngx.req.get_method

ngx.req.set_method(ngx.HTTP_POST)

```

**The uri of the request**

ngx lua also allows to to change the uri to which the req is initiated by the client.

```
ngx.req.set_uri("/foo")

```

Additionally the set_uri takes in a optional boolean
parameter that tells nginx to keep searching for newly set uri location

```
ngx.req.set_uri("/foo",true)

```
The context of execution  becomes important in this case since it mimicks the behaviour of nginx rewrite directive.
The only allowed location where the optional bool parameter can be used as true is the rewrite_by_lua/rewrite_by_lua_file

**The url arguments**

You can also modify the query string parameters of the req. Here's how:

```
ngx.req.set_uri_args("a=3&b=hello%20world")

ngx.req.set_uri_args({ a = 3, b = {5, 6} })

-- this will be translated as "a=3&b=5&b=6"

```

ngx lua allows setting the uri paramters as query strings and as lua tables.

### The Response

Just like the req the ngx api allows you to modify the response that goes back to client. But
if you have read the `ngx.location.capture` section you should already be familliar with many
of the functions that of a response. Nevertheless we will take a better look here: -


**The headers of the response**

ngx api gives us to ways to deal with the headers that will be sent out in the response. The
`ngx.header` contains a list of headers that will be sent out as the response to the current req.
Using `ngx.header` you can update an existing header or add new headers. You read from `ngx.header` in 
exactly the same way  as you would read from any other lua table.

```
local content_type = ngx.header.content_type -- reads "Content-Type header"

-- any '-' in a header is replaced by a '_'. You can still read the header in the orignal form like so

local content_type_orig = ngx.header["Content-type"]

ngx.header.content_type = "application/json" -- sets the content type header

```

In case you want to set multiple values to a header you just have to pass a list of values:-

```
ngx.header["My-Multi-Value-Header"] = {"1","2"}

```

Simillarly if you read a multivalued header a list will be returned as a response.

```
local multi_val_read  = ngx.header["My-Multi-Value-Header"]

-- multi_val_read = {"1","2"}

```

One important thing
to note here is that if you try to set multiple values to a header that can only contain a single value
the last item from the list will be chosen.

`ngx.header.content_type = {'a', 'b'}` would result in

`ngx.header.content_type = 'b'`

The ngx.header does not return an iteratable lua table. For that purpose use:-

`ngx.resp.get_headers()` which is quite simillar to `ngx.req.get_headers()`.
It simply returns a list of response headers that will be sent to the client. The value returned is a lua
table which can be iterated upon.

```
local resp_headers = ngx.resp.get_headers()

```

Finally if you use the response from  `ngx.location.capture` the headers are found in `res.header`. The result
returned is a proper lua header and can be iterated upon. 

**The body of the response**

The body of the response can only be accessed from the response that you get by issuing a request/subrequeest.
Unlike response headers there is no way to access the response headers that are going to be sent without
having access to the response object first.

```

local res = ngx.location.capture("/res_path")
local body = res.body -- read the data
res.body = "Some arbitrary body data" -- set the data to an aribrary value
res.body = cjson.encode({a=1,b=2}) -- sending json with the body

```

The above snippet shows how you can set the body data of the response. The important thing to note here is that
every time you set the data to a new value the  previous data is over written. So the first res.body statement will
over write the orignial body returned from the response where as the second res.body statement will over write the
first statement. 

**The status of the response**

The response status can be read and updated using the `ngx.status`

```
local status = ngx.status -- read the status of the response being sent

ngx.status = ngx.HTTP_NOT_MODIFIED -- set the status code to 304. Using ngx constant here, but you may supply numerical values	

```

