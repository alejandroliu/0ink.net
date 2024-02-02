---
title: nginx's auth_request_module howto
tags: authentication, configuration, information, login, password, proxy, python
---

This article tries to supplement the [nginx][nginx] documentations
regarding the [auth_request][ngx_http_auth_request_module] module
and how to [configure][config] it.  In my opinion, that documentation
is a bit incomplete.

# What is the nginx's [auth_request][ngx_http_auth_request_module] module

The documentation for this module says, it implements client
authorization based on the result of a subrequest.

This means that when you make an HTTP request to a protected URL,
[nginx][nginx] performs an internal subrequest to a defined
authorization URL. If the result of the subrequest is HTTP 2xx,
[nginx][nginx] proxies the original HTTP request to the backend server.
If the result of the subrequest is HTTP 401 or 403, access to the
backend server is denied.

By configuring [nginx][nginx], you can redirect those 401s or 403s to
a login page where the user is authenticated and then redirected to
the original destination.

The entire authorization subrequest process is then repeated, but
because the user is now authenticated the subrequest returns HTTP 200
and the original HTTP request is proxied to the backend server.

# Configuring [nginx][nginx]

In your [nginx][nginx] configuration...

This block configures the web server area that will be protected:

```nginx
        location /hello {
          error_page 401 = @error401;	# Specific login page to use
          auth_request /auth;		# The sub-request to use
          auth_request_set $username $upstream_http_x_username;	# Make the sub request data available
          auth_request_set $sid $upstream_http_x_session;	# send what is needed

          proxy_pass http://sample.com:8080/hello;	# actual location of protected data
          proxy_set_header X-Forwarded-Host $host;	# Custom headers with authentication related data
          proxy_set_header X-Remote-User $username;
          proxy_set_header X-Remote-SID $sid;
        }

	location @error401 {
          return 302 /login/?url=http://$http_host$request_uri;
        }

```

- `error_page 401` defines the custom login page to use (if any).
  In theory, for a REST API, would be possible to authenticate
  using a provided `token` header which makes the login page
  unnecesary.
- `auth_request /auth` defines that this location needs authentication
  and defines the sub-request location to use.
- `auth_request_set` can be used to get data from the subrequest
  headers and make it available later (like for instance, to a
  backend content server using custom headers.
- `proxy_pass` defines the actual backend content server.
- `proxy_set_header` defines custom header used to pass information
  to the content backend server.


This block configures the authentication sub-request server:

```nginx
        location = /auth {
          proxy_pass http://auth-server.sample.com:8080/auth;	# authentication server
          proxy_pass_request_body off;				# no data is being transferred...
          proxy_set_header Content-Length '0';
          proxy_set_header Host $host;				# Custom headers with authentication related data
          proxy_set_header X-Origin-URI $request_uri;
          proxy_set_header X-Forwarded-Host $host;
        }
```

- `proxy_pass` where the sub request should be handled.
- `proxy_pass_request_body off` and `proxy_set_header Content-Length 0` are
  used to supress the content body and only sends the headers to the
  authentication server.
- `proxy_set_header` additional details being send to the sub request.
  For example, the `X-Origin-URI`.

This implements the login pager URL

```nginx
        # If the user is not logged in, redirect them to login URL
        location @error401 {
          return 302 https://$host/login/?url=https://$http_host$request_uri;
        }
```
In this example, the login page is on the same reverse proxy, but
it doesn't have to be that way.

The actual login page:

```nginx
        location /login/ {
          proxy_pass http://auth-server.sample.com:8080/login/;	# Where the login happens
          proxy_set_header X-My-Real-IP $remote_addr;		# Additional parameters to send to login page
          proxy_set_header X-My-Real-Port $remote_port;
          proxy_set_header X-My-Server-Port $server_port;
        }
```
- `proxy_pass` points to where the login script runs
- `proxy_set_header` can be used to pass additional fields that may
  be needed by the login script.  To implement for example,
  `$remote_addr` based access rules.

So in this particular example, we are referring to a server with
**TWO** locations:

1. `http://auth-server.sample.com:8080/auth` - The sub-request URI which is not visible
   outside but handles the sub-request.
2. `http://auth-server.sample.com:8080/login/` - The login URI which handles the
   login conversation.

# The Authentication Server

This is where the [nginx][nginx] documentation falls a bit short, there
is no actual authentication server example to refer to.

In my example, we have a simple authentication workflow.  When an
unauthenticated user hits the server, the sub-request is called
and checks (and fails) for a session cookie.

The user is then re-directed to the login page, where the actual
login takes place.  If succesful, a session cookie is set and
the user is redirected to the original URL.

This is implemented using the following script:

<script src="https://tortugalabs.github.io/embed-like-gist/embed.js?style=github&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on&fetchFromJsDelivr=on&target=${SNIPPETS}/2019/nginx_mod_authrequest/auth1.py"></script>

This makes uses of the [bottle][bottlepy] micro framework.

It implements four routes:

1. `GET /hello`
   This is just a demo URL used for testing.  Only shows the request headers.
2. `GET /login/`
   This is the login page entry point.
3. `POST /login/`
   This is the handler for the login page.
4. `GET /auth`
   This is the sub-request handler.

For the demo, we are not really doing any login handling.  You only
need to make the username the same as the password to login.  Anything
else is a login failure.

When the user succesfully logs in, we set a cookie.  Because the
login URL and the protected resource (`/hello` URL) are in the
same cookie scope, we can use cookie set by the login page
as the verification token in the sub-request.

Note that the login page can be as simple or as complex as it is
needed.  For example, it is possible to implement a [SAML][saml],
[OpenID Connect][oidc], or any Single-Sign-On workflow
available.

Alternatively, two factor authentication could be implemented here.
The possibilities are endless.

An interesting use of the [auth_request][ngx_http_auth_request_module]
module would be to delegate [Basic Authentication][basicauth] to a different
server or to even implement authentications not supported by
[nginx][nginx] like for example a simple Token-Bearer header or
[Digest authentication][digest]

## basic authentication

This may seem silly since [nginx][nginx] supports [basic authentication][basicauth]
out of the box.  The use case for this is when you have a cluster of nginx
front ends, and you want all of them to authenticate against a central
identity server.  Furthermore, since the URI can be passed, a more sophisticated
access control can be implemented.  Finally, additional values can be passed
through headers, such as group names, tokens, etc.

### nginx configuration

Protected Resource:

```nginx
        location /hello {
          auth_request /auth;		# The sub-request to use
          auth_request_set $username $upstream_http_x_username;	# Make the sub request data available

          proxy_pass http://sample.com:8080/hello;	# actual location of protected data
          proxy_set_header X-Forwarded-Host $host;	# Custom headers with authentication related data
          proxy_set_header X-Remote-User $username;
        }
```

**NOTE:** unlike the previous example, we do not need to provide a @error401 page.

Sub-request configuration:

```nginx
        location = /auth {
          proxy_pass http://auth-server.sample.com:8080/auth;	# authentication server
          proxy_pass_request_body off;				# no data is being transferred...
          proxy_set_header Content-Length '0';
          proxy_set_header Host $host;				# Custom headers with authentication related data
          proxy_set_header X-Origin-URI $request_uri;
          proxy_set_header X-Forwarded-Host $host;
        }
```

### authentication server

The python implementation (again, using [bottle][bottlepy]):


<script src="https://tortugalabs.github.io/embed-like-gist/embed.js?style=github&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on&fetchFromJsDelivr=on&target=${SNIPPETS}/2019/nginx_mod_authrequest/auth2.py"></script>


Like in the previous example, we are not doing any user/password verification.  We are only
checking if username and password are matching.

Unlike the previous example, all the authentication is handled by a single route (`/auth`).
It returns 'WWW-Authenticate' to prompt the user for a password.  And if it sees
an `Authorization` header, it would validate it.

## digest authentication

This implements [digest][digest] authentication for [nginx][nginx] using the
[auth request module][ngx_http_auth_request_module].  The nginx configuration is the
same as in the [Basic][basicauth] authentication.

The implentation in python (using [bottle][bottlepy] framework):

<script src="https://tortugalabs.github.io/embed-like-gist/embed.js?style=github&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on&fetchFromJsDelivr=on&target=${SNIPPETS}/2019/nginx_mod_authrequest/auth3.py"></script>

* * *

[nginx]: http://nginx.org/en/
[ngx_http_auth_request_module]: http://nginx.org/en/docs/http/ngx_http_auth_request_module.html
[config]: https://docs.nginx.com/nginx/admin-guide/security-controls/configuring-subrequest-authentication/
[bottlepy]: https://bottlepy.org/
[SAML]: https://en.wikipedia.org/wiki/Security_Assertion_Markup_Language
[oidc]: https://openid.net/connect/
[basicauth]: https://en.wikipedia.org/wiki/Basic_access_authentication
[digest]: https://en.wikipedia.org/wiki/Digest_access_authentication

