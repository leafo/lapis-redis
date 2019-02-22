package = "lapis-redis"
version = "dev-2"

source = {
  url = "git://github.com/lwhile/lapis-redis.git"
}

description = {
  summary = "Redis integration with lapis",
  license = "MIT",
  maintainer = "lwhile <lwhile521@gmail.com>",
}

dependencies = {
  "lua == 5.1",
  "lapis"
}

build = {
  type = "builtin",
  modules = {
    ["lapis.redis"] = "lapis/redis.lua",
  }
}

