Nginx supplied it's own mini programming language in the form of directives. 
These directives we either block level or simple. Simple directives were 
structured as the name of the directive and the name of the parameters, 
the directive and parameters were speerated by a space and the end of the 
directive was marked by a `;`. The block level directives were similar with
the only difference being instead of ending it with a `;` it contained `{` and
`}` brackets. Within a block level directive there could be one of multiple 
simple directives.These directives made up the configuration files.

nginx_lua keeps the same structuring of the configuration files.
As we saw in the last chapter there is little difference between
a vanilla nginx configuration and a nginx_lua configuration. In fact almost
all of the nginx directives can be used as usual in an nginx_lua configuration
file. However nginx_lua adds several new directives that enhance the configurability
of nginx. We already looked at `content_by_lua` and `content_by_lua_file` in the last
chapter. Here we will take a look at a few more intersting ones

####lua_code_cache 

This directives tuns the caching of lua modules on or off. By default this  
the caching is turned on so that the lua modules are loaded once and then 
just refrenced. This is a desirable effect and we would not want to reload 
modules on every request. So when would you want to turn the caching off? 
Yep , you guessed it during the development phase. When caching is turned off 
on every request the module is reloaded so you can just edit and save your file and 
just refresh to see the changes. 
