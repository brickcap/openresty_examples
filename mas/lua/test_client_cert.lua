ngx.say(string.format("%s %s","The client dn is: ",ngx.var.ssl_client_s_dn))
ngx.say(string.format("%s %s","The issuer dn is: ",ngx.var.ssl_client_i_dn))
