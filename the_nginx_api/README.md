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



