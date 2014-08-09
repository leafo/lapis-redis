
# `lapis-redis`

This module is used for integrating [Redis](http://redis.io) with
[Lapis](http://leafo.net/lapis). It uses the
[`lua-resty-redis`](https://github.com/openresty/lua-resty-redis) module.

## Installing

```bash
$ luarocks install lapis-redis
```

## Configuring

```moonscript
-- config.moon

config "development", ->
  redis {
    host: "127.0.0.1"
    port: 6379
  }

```

## Connecting

The function `get_redis` can be used to get the current request's Redis
connection. If there's not connection established for the request a new one
will be opened. After the request completes the Redis connection will
automatically be recycled for future requests.

The return value of `get_redis` is a connected
[`lua-resty-redis`](https://github.com/openresty/lua-resty-redis#methods)
object.

```moon
import get_redis from require "lapis.redis"

class App extends lapis.Application
  "/": =>
    redis = get_redis!
    redis\set "hello", "world"

    redis\get "hello"
```


## Redis cache

You can use Redis as a cache using the [Lapis caching
API](http://leafo.net/lapis/reference/utilities.html#caching-cachedfn_or_tbl).

```moon
import cached from require "lapis.cache"
import redis_cache from require "lapis.redis"

class App extends lapis.Application
  "/hello": cached {
    dict: redis_cache "cache-prefix"
    =>
      @html ->
        div "hello"
  }
```

