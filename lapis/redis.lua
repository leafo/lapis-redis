local config = require("lapis.config").get()
local redis
if ngx then
  redis = require("resty.redis")
end
local redis_down = nil
local connect_redis
connect_redis = function()
  if not (config.redis_host) then
    return nil
  end
  local r = redis:new()
  local ok, err = r:connect(config.redis_host, config.redis_port)
  if ok then
    return r
  else
    redis_down = ngx.time()
    return ok, err
  end
end
local get_redis
get_redis = function()
  if not (redis) then
    return 
  end
  if redis_down and redis_down + 60 > ngx.time() then
    return 
  end
  local r = ngx.ctx.redis
  if not (r) then
    local after_dispatch
    do
      local _obj_0 = require("lapis.nginx.context")
      after_dispatch = _obj_0.after_dispatch
    end
    local err
    r, err = connect_redis()
    if r then
      ngx.ctx.redis = r
      after_dispatch(function()
        r:set_keepalive()
        ngx.ctx.redis = nil
      end)
    end
  end
  return r
end
local redis_cache
redis_cache = function(prefix)
  return function(req)
    local r = get_redis()
    return {
      get = function(self, key)
        if not (r) then
          return 
        end
        do
          local out = r:get(tostring(prefix) .. ":" .. tostring(key))
          if out == ngx.null then
            return nil
          end
          return out
        end
      end,
      set = function(self, key, content, expire)
        if not (r) then
          return 
        end
        local r_key = tostring(prefix) .. ":" .. tostring(key)
        return r:setex(r_key, expire, content)
      end
    }
  end
end
return {
  get_redis = get_redis,
  redis_cache = redis_cache
}
