--[[

	https://github.com/alreadypro/request

]]

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local function pause(n)
	local now = tick()

	local duration = 0

	while now + (n or 0) > duration do
		duration = tick()
		RunService.Heartbeat:Wait()
	end

	return duration - now
end

local request = {}
request.__index = request

local methods = {"GET", "HEAD", "POST", "PUT", "DELETE", "CONNECT", "OPTIONS", "TRACE", "PATCH"}
local retryCodes = {408, 429, 500, 502, 503, 504, 522, 524}

function request.request(method, ...)
	local args = {...}

	local url = args[1]
	local options = args[2]
	local retries = args[3]
	local callback = args[4]

	if not callback then
		if typeof(options) == "function" then
			callback = options
		elseif typeof(retries) == "function" then
			callback = retries
		end
	end

	options = typeof(options) == "function" and {} or typeof(options == "table") and options or {}
	retries = typeof(retries) == "function" and 3 or typeof(retries) == "number" and retries or 3

	options.Url = url
	options.Method = method or "GET"
	options.Headers = options.Headers or {}
	options.Headers["Content-Type"] = options.Headers["Content-Type"] or typeof(options.Body) == "table" and "application/json" or nil
	options.Body = typeof(options.Body) == "table" and request.tojson(options.Body) or options.Body and tostring(options.Body) or nil

	local success, response = pcall(HttpService.RequestAsync, HttpService, options)

	if success and response.Success then
		response.Body = request.fromjson(response.Body)
		return callback and callback(response) or response
	end

	local requestDelay = 1

	local n = 0

	while table.find(retryCodes, response.StatusCode) or retries > n do
		warn("[Request] Retrying "..options.Method.." to "..options.Url..": "..(n + 1))
		success, response = pcall(HttpService.RequestAsync, HttpService, options)

		if success then
			if table.find(retryCodes, response.StatusCode) then
				success = false
			else
				return callback and callback(response) or response
			end
		end

		requestDelay *= 1.5
		n += 1
		pause(requestDelay)
	end

	warn("[Request] "..options.Method.." to "..options.Url.." failed: "..response.StatusMessage or response)

	response.Body = request.fromjson(response.Body)

	return callback and callback(response) or response
end

function request.tojson(arg)
	local success, json = pcall(HttpService.JSONEncode, HttpService, arg)

	if success then
		return json
	else
		return arg
	end
end

function request.fromjson(arg)
	local success, str = pcall(HttpService.JSONDecode, HttpService, arg)

	if success then
		return str
	else
		return arg
	end
end

for _,method in next, methods do
	request[method:lower()] = function(...)
		return request.request(method, ...)
	end
end

setmetatable(request, {
	__call = function(t, ...)
		return request.request(nil, ...)
	end
})

return request
