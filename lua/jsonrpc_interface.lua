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
