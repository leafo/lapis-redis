local config = require("lapis.config").get()
local redis
if ngx then
  redis = require("resty.redis")
end
local redis_down = nil
local connect_redis
connect_redis = function(confKey)
  if confKey == nil then
    confKey = nil
  end
  local redis_config
  if confKey ~= nil then
    redis_config = config.redis[confKey]
  else
    redis_config = config.redis
  end
  if not (redis_config) then
    return nil, "redis not configured"
  end
  local r = redis:new()
  local ok, err = r:connect(redis_config.host, redis_config.port)
  if ok then
    return r
  else
    redis_down = ngx.time()
    return ok, err
  end
end
local get_redis
get_redis = function(confKey)
  if confKey == nil then
    confKey = nil
  end
  if not (redis) then
    return nil, "missing redis library"
  end
  if redis_down and redis_down + 60 > ngx.time() then
    return nil, "redis down"
  end
  local r
  if confKey then
    if ngx.ctx.redisClients ~= nil then
      r = ngx.ctx.redisClients[confKey]
    else
      r = nil
    end
  else
    r = ngx.ctx.redis
  end
  if not (r) then
    local after_dispatch
    do
      local _obj_0 = require("lapis.nginx.context")
      after_dispatch = _obj_0.after_dispatch
    end
    local err
    r, err = connect_redis()
    if not (r) then
      return nil, err
    end
    if not confKey then
      ngx.ctx.redis = r
    else
      if not ngx.ctx.redisClients then
        ngx.ctx.redisClients = { }
      end
      ngx.ctx.redisClients[confKey] = r
    end
    after_dispatch(function()
      r:set_keepalive()
      if not confKey then
        ngx.ctx.redis = nil
      end
      if confKey then
        ngx.ctx.redisClients[confKey] = nil
      end
    end)
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
