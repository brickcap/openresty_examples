This project is a POC on Mutual authentication systems.

## Usage

You need to have [openresty installed](https://openresty.org/en/installation.html) to use this application.The theory and the principles of mutual authentication systems are explained in the posts [client side and proxy ssl certificates in nginx](http://staticshin.com/programming/proxy-ssl-cert-in-nginx.html) and [building mutual authentication systems with openresty](http://staticshin.com/programming/mutual_authentication_systems.html) Please check them out before trying this example.

To run this example `cd` into the directory and type


```
nginx  -p ./  -c ./dev.ngx.conf

```
If everything works out you should have the application should be running on ports 3000 and 4000 for http and https connections respectively.  Feel free to change the ports if the defaults are being used by some other application(s) on your system.

This application exposes two relevant endpoints:-

1. `/sign-cert` - Spawns a shell process to create a certificate for the client. After which it digitally signs it using a CA certificate present in the utils/test_certs/ directory. Please note that the distinguished name requred for the client certificate is hard coded. Further the errors the output from the shell process is not checked for errors. This example is only meant to be used as an illustration of concept. Please review and modify the code to suit your requirements. 

2. `/test-client-cert` is ,as the name suggests, used to test the client certificate. If a correct client certificate is passed to the endpoint it responds with the distiniguished name of both the client certificate and the CA that was used to sign this certificate.

You can check out the definition of these endpoints in the routes/app_routes.conf file.

**Calling the endpoints**

To call these endpoints you can use curl or any other command line application that makes http calls. Just make sure that there is a provision to pass http certificates to the requests. I'll be using curl

```
curl http://localhost:3000/sign-cert/

Certificates have been created

```

A successful call to the /sign-cert endpoint simply creates the client_new.key, client_new.cst and shail.cert files in the utils/test_certs directory.

Now make a curl request to the /test-client-cert endpoint passing the key and certificate files that we generated in the previous step

```
curl -v -s -k --key ./utils/test_certs/client_new.key --cert ./utils/test_certs/shail.cert:abba https://localhost:4000/test-client-cert

```
and you should see the following output

```
The client dn is:  /C=IN/ST=HR/L=GGN/O=wrinq/CN=www.wrinq.com/emailAddress=akshat@wrinq.com
The issuer dn is:  /C=IN/ST=HR/L=GGN/O=wrinq/CN=www.wrinq.com

```

To verfiy that the application only accepts client certificates that are signed by the CA we need ensure that all other certificates are rejected by the server. This can be done by performing two simple tests:- 

1. That a self signed certificate is rejected by our server
2. That a certificate in the crl (certificate revocation list) is also rejected by the server.


Let's try with the self signed certificate first:- 

```
curl -v -s -k --key ./utils/test_certs/client_self.key --cert ./utils/test_certs/client_self.pem https://localhost:4000/test-client-cert

```
You should see the following headers returned by openresty

```

< HTTP/1.1 400 Bad Request
< Server: openresty
< Date: Wed, 28 Sep 2016 06:11:35 GMT
< Content-Type: text/html
< Content-Length: 193
< Connection: close
< ETag: "57e0d65a-c1"

```
A bad request(400) indicates that the certificate has been rejected.

Let's see what happens when we try with a certificate that has been added to a crl

```
curl -v -s -k --key ./utils/test_certs/client.key --cert ./utils/test_certs/client.cert:rocks https://localhost:4000/test-client-cert

```

Here's the response:-

```

< HTTP/1.1 400 Bad Request
< Server: openresty
< Date: Wed, 28 Sep 2016 06:14:40 GMT
< Content-Type: text/html
< Content-Length: 193
< Connection: close
< ETag: "57e0d65a-c1"

```

Once more a bad request indicates that the certificate has been rejected.

Feel free to go through the code and the configuration files to understand how the nginx server can be configured to accept client certificates. How a parsed certificate can be used to perform additional checks on the certificate holder using just a few lines of openresty. Also don't forget to check out detailed explainations in the posts [client side and proxy ssl certificates in nginx](http://staticshin.com/programming/proxy-ssl-cert-in-nginx.html) and [building mutual authentication systems with openresty](http://staticshin.com/programming/mutual_authentication_systems.html)


-------

The app was generated with the help of [restyskeleton](https://github.com/brickcap/restyskeleton), a command line tool  for bootstrapping openresty projects.

