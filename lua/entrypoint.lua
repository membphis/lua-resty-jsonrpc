local cjson 	= require "cjson"
local jsonrpc 	= require "jsonrpc_interface"
local jsonrpc 	= jsonrpc.new()

local tcpsock, err = ngx.req.socket(true)
if err then
	ngx.log(ngx.ERR, "ngx.req.socket:", err)
	ngx.exit(-1)
end

local function cleanup()
    -- custom cleanup work goes here, like cancelling a pending DB transaction

    -- now abort all the "light threads" running in the current request handler
    ngx.log(ngx.WARN, "do cleanup")
    ngx.exit(-1)
end

local ok, err = ngx.on_abort(cleanup)
if not ok then
    ngx.log(ngx.ERR, "failed to register the on_abort callback: ", err)
    ngx.exit(-1)
end

while true do
	local data, err = tcpsock:receive("*l")
	if err and "timeout" ~= err then
		ngx.log(ngx.WARN, "receive failed:", err)
		break
	end

	if data then
		local req_data = cjson.decode(data)
		if not req_data.jsonrpc and not req_data.id then
			break
		end

		local rep_data = {jsonrpc=req_data.jsonrpc, id=req_data.id}
		rep_data.result, rep_data.err = jsonrpc:call(req_data.method, req_data.params)

		tcpsock:send(cjson.encode(rep_data).."\r\n")
	end
end

cleanup()