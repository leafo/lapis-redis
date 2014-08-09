test:
	busted

lint: build
	moonc -l lapis

local: build
	luarocks make --local lapis-redis-dev-1.rockspec

build:
	moonc lapis
