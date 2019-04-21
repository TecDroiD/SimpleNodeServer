# Simple Node Server
The SNS is a simple web server running on NodeMCU in lua. It has scripting simple capability as well as mime type recognition.
feel free to use it and change it - as long as you use it non profit.. otherwise ask me first.

# Usage
## Calling the web server
Minimum files needed are 
* server.lua
* index.html - which can be customized
* 404.html - which also can be customized but doesn't have to

To run the server, require server.lua in your init file:
> `-- initialize web server`
> `require('server')`

You can call any html page which is uploaded on your NodeMCU. Attention: currently, all files are limited to 4kb in size.

## Creating web scripts
Running active server content is possible by simply creating a lua script which finally returns something. For example _hello.lua_.

> `return "<html><body><h1>Hello World</h1></body></html>";`

It is possible to change response code (default is __200 OK__), as well as content-type (default is __text/html__) by setting some global variables.

> `_MIMETYPE = "text/json";` can be useful if you want to response json, eg. to use it with javascript
> `_RESPONSE = "500 Internal Server Error";` just in case ... ;)

Additionally, you can react on GET parameters (Post not yet implemented) which cn be found in the table `_GET`

> `print (_GET['a'] + _GET['b']);`

That's all for now.
Have fun!

