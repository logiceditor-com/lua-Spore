--
-- lua-Spore : <http://fperrad.github.com/lua-Spore/>
--

--[[
See http://docs.amazonwebservices.com/AmazonS3/latest/dev/index.html?RESTAuthentication.html
]]

local table = require 'table'
local mime = require 'mime'
local evp = require 'crypto'.evp
local hmac = require 'crypto'.hmac
local request = require 'Spore.Protocols'.request
local slurp = require 'Spore.Protocols'.slurp
require 'Spore'.early_validate = false

_ENV = nil
local m = {}

function m:call (req)
    local env = req.env
    local spore = env.spore

    local function get_canonical_headers ()
        local headers_amz = {}
        for k, v in pairs(req.headers) do
            if k:match'^x%-amz%-' then
                headers_amz[#headers_amz+1] = k
            end
        end
        if #headers_amz == 0 then return "" end
        table.sort(headers_amz)
        local lines = {}
        for i = 1, #headers_amz do
            local k = headers_amz[i]
            lines[#lines+1] = k .. ':' .. req.headers[k]
        end
        return table.concat(lines, "\n") .. "\n"
    end -- get_canonical_headers

    local function get_string_to_sign ()
        local bucket = spore.params.bucket or ''
        if bucket ~= '' then
            bucket = '/' .. bucket
        end
        local object = '/' .. (spore.params.object or '')
        local query = env.spore.method.path:sub(2)
        if query ~= '' then
            query = string.gsub(query, "(:%w+)", "")
        end
        return req.method .. "\n"
            .. (req.headers['content-md5'] or '') .. "\n"
            .. (req.headers['content-type'] or '') .. "\n"
            .. (req.headers['date'] or '') .. "\n"
            .. get_canonical_headers()
            .. bucket:lower() .. object:lower() .. query
    end -- get_string_to_sign

    if spore.authentication and self.aws_access_key and self.aws_secret_key then
        for k, v in pairs(spore.params) do
            k = tostring(k)
            if k:match'^x%-amz%-' then
                req.headers[k:lower()] = tostring(v)
                spore.params[k] = nil
            end
        end

        req:finalize()

        if spore.headers and spore.headers['Date'] == 'AWS' then
            req.headers['date'] = os.date("!%a, %d %b %Y %H:%M:%S GMT")
        end

        local payload = spore.payload
        if payload then
            if payload:sub(1, 1) == '@' then
                local fname = payload:sub(2)
                payload = slurp(fname)
            end
            req.headers['content-length'] = payload:len()
            req.headers['content-type'] = req.headers['content-type'] or 'application/x-www-form-urlencoded'
            if spore.headers and spore.headers['Content-MD5'] == 'AWS' then
                req.headers['content-md5'] = evp.digest('md5', payload)
            end
        end

        req.headers['authorization'] = 'AWS '
          .. self.aws_access_key .. ':'
          .. mime.b64(hmac.digest('sha1', get_string_to_sign(), self.aws_secret_key, true))

        return request(req)
    end
end

return m

--
-- Copyright (c) 2011 Francois Perrad
-- Copyright (c) 2011 LogicEditor.com: Alexander Gladysh, Vladimir Fedin
--
-- This library is licensed under the terms of the MIT/X11 license,
-- like Lua itself.
--

