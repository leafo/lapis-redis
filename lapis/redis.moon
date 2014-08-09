config = require"lapis.config".get!
redis = if ngx then require "resty.redis"

redis_down = nil

connect_redis = ->
  redis_config = config.redis
  return nil, "redis not configured" unless redis_config

  r = redis\new!
  ok, err = r\connect redis_config.host, redis_config.port

  if ok
    r
  else
    redis_down = ngx.time!
    ok, err

get_redis = ->
  return nil, "missing redis library" unless redis
  return nil, "redis down" if redis_down and redis_down + 60 > ngx.time!

  r = ngx.ctx.redis
  unless r
    import after_dispatch from require "lapis.nginx.context"

    r, err = connect_redis!
    return nil, err unless r

    ngx.ctx.redis = r
    after_dispatch ->
      r\set_keepalive!
      ngx.ctx.redis = nil

  r

redis_cache = (prefix) ->
  (req) ->
    r = get_redis!

    {
      get: (key) =>
        return unless r
        with out = r\get "#{prefix}:#{key}"
          return nil if out == ngx.null

      set: (key, content, expire) =>
        return unless r
        r_key = "#{prefix}:#{key}"
        r\setex r_key, expire, content

    }


{ :get_redis, :redis_cache }

