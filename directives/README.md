Nginx supplied it's own mini programming language in the form of directives. 
These directives we either block level or simple. Simple directives were 
structured as the name of the directive and the name of the parameters, 
the directive and parameters were speerated by a space and the end of the 
directive was marked by a `;`. The block level directives were similar with
the only difference being instead of ending it with a `;` it contained `{` and
`}` brackets. Within a block level directive there could be one of multiple 
simple directives.These directives made up the configuration files.

nginx_lua keeps the same structuring of the configuration files. 
