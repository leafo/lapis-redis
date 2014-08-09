
# `lapis-redis`

This module is used for integrating Redis with Lapis. It uses the `resty-redis`
module.

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

You should only call `get_redis` within an action's request cycle. The Redis
connection will automatically be recycled at the end of the request.

The return value is a connected `resty-redis` object.

```moon
import get_redis from require "lapis.redis"

class App extends lapis.Application
  "/": =>
    redis = get_redis!
    redis\set "hello", "world"

    redis\get "hello"
```


## Redis cache

You can use Redis as a cahe using the Lapis caching API.

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

