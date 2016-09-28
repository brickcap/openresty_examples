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

To call these endpoints you can use curl or anyother command line application that makes http calls. Just make sure that there is a provision to pass http certificates to the requests. I'll be using curl

```
curl http://localhost:3000/sign-cert/

Certificates have been created

```

The sign-cert application simply creates the client_new.key, client_new.cst and shail.cert files.  


The app was generated with the help of [restyskeleton](https://github.com/brickcap/restyskeleton), a command line tool  for bootstrapping openresty projects.

MIT