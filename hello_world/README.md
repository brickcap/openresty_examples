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

`nginx -p `pwd` -c conf/nginx.conf`