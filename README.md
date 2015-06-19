# lua-resty-jsonrpc
================
That is a jsonrpc base on openresty(with nginx-tcp-lua-server patch).


Use exmaple
================
Syntax:

```
--> data sent to Server
<-- data sent to Client
```

rpc call with positional parameters:

```
--> {"jsonrpc": "2.0", "method": "subtract", "params": [42, 23], "id": 1}
<-- {"jsonrpc": "2.0", "result": 19, "id": 1}
```

```
--> {"jsonrpc": "2.0", "method": "subtract", "params": [23, 42], "id": 2}
<-- {"jsonrpc": "2.0", "result": -19, "id": 2}
```

Add your interface
================
please take a look with lua/jsonrpc_interface.lua, you can add new interface as the "subtract" in same way

```
local _M = { _VERSION = '1.0' }

local mt = { __index = _M }

function _M.new(self)
    return setmetatable({  }, mt)
end

function _M.call(self, fun_name, params )
	if nil == self[fun_name] then
		return nil, "valid function name"
	end

	return self[fun_name](self, params)
end

function _M.subtract(self, params )
	if "table" ~= type(params) then
		return nil, "param check failed"
	end

	if 2 == #params then
		return params[1]-params[2]
	end

	return nil, "param input valid"
end

return _M
```

The nginx config
================

```
http {
    # set search paths for pure Lua external libraries (';;' is the default path):
    lua_package_path '$prefix/lua/?.lua;;';

    #lua_socket_log_errors off;
    #lua_code_cache off;

    server {
        listen       8000;
        server_name  localhost;
        default_head "GET /jsonrpc HTTP/1.1\r\nHost: 127.0.0.1\r\n\r\n";

        location /jsonrpc {
            lua_check_client_abort on;
            access_by_lua_file lua/entrypoint.lua;
        }
    }

}
```

Pay attention
================
It base on openresty, but you need to make a patch with the original openresty. please take a look at nginx-tcp-lua-server . its the most simple way to get the nginx tcp server. 

provide by membphis@gmail.com

if you have any question, please let me know. 
