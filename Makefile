test:
	busted

lint: build
	moonc -l lapis

local: build
	luarocks --lua-version=5.1 make --local lapis-redis-dev-1.rockspec

build:
	moonc lapis
