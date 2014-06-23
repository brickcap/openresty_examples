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
