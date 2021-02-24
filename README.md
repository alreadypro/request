# request
Simple HttpService module that makes dealing with HttpService a breeze

## Features
- Retries request until n >= retries
- Automatically parses outgoing & incoming body to and from JSON
- Callback on response when request has succeeded or n >= retries


### Usage

```lua
request(url [, options = {Method = "GET"}[, retries = 3[,callback = nil]]])
request.get(url[, options = {}[, retries = 3[,callback = nil]]])
request.head(url[, options = {}[, retries = 3[,callback = nil]]])
request.post(url[, options = {}[, retries = 3[,callback = nil]]])
request.put(url[, options = {}[, retries = 3[,callback = nil]]])
request.delete(url[, options = {}[, retries = 3[,callback = nil]]])
request.connect(url[, options = {}[, retries = 3[,callback = nil]]])
request.options(url[, options = {}[, retries = 3[,callback = nil]]])
request.trace(url[, options = {}[, retries = 3[,callback = nil]]])
request.patch(url[, options = {}[, retries = 3[,callback = nil]]])
```

When making a GET request, there is no need to specify a method

```lua
local response = request("https://httpbin.org/get")

print(response)
```

However, if you wish to specify that you're using a GET request for readability, you can do so

```lua
local response = request.get("https://httpbin.org/get")

-- OR

local response = request("https://httpbin.org/get", {Method = "GET"})

print(response)
```

This works the same with POST, and any other HTTP methods you wish to use
```lua
local response = request.post("https://httpbin.org/post", {Body = {foo = "bar"}})

-- OR

local response = request("https://httpbin.org/post", {Method = "POST", Body = {foo = "bar"}})

print(response)
```

### Callbacks

If you prefer callbacks over setting the response as a variable, you're in luck

Simply add the callback function as the last argument of your request, like so

```lua
request("https://httpbin.org/get", function(response)
	print(response)
end)

-- OR

request("https://httpbin.org/post, {Body = {foo = "bar"}}
```
