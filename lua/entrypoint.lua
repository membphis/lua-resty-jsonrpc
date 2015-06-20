local cjson 	= require "cjson"
local jsonrpc 	= require "jsonrpc_interface"
local jsonrpc 	= jsonrpc.new()

local tcpsock, err = ngx.req.socket(true)
if err then
	ngx.log(ngx.ERR, "ngx.req.socket:", err)
	ngx.exit(-1)
end

local function cleanup()
    ngx.log(ngx.WARN, "do cleanup")
    ngx.exit(-1)
end

local ok, err = ngx.on_abort(cleanup)
if not ok then
    ngx.log(ngx.ERR, "failed to register the on_abort callback: ", err)
    ngx.exit(-1)
end

local function response(tcpsock, data)
    local req_data = cjson.decode(data)
	if not req_data.jsonrpc and not req_data.id then
		return
	end

	local rep_data = {jsonrpc=req_data.jsonrpc, id=req_data.id}
	rep_data.result, rep_data.err = jsonrpc:call(req_data.method, req_data.params)

	tcpsock:send(cjson.encode(rep_data).."\n")
	return 
end

while true do
	local data, err = tcpsock:receive("*l")
	if err and "timeout" ~= err then
		ngx.log(ngx.WARN, "receive failed:", err)
		break
	end

	if data then
		ngx.thread.spawn(response, tcpsock, data)
	end
end

cleanup()