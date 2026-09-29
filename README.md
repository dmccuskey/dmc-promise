# dmc-promise

Deliver the result of work that finishes later, such as a network request, in a Solar2D (formerly Corona SDK) app: a `Deferred` that the producer resolves or rejects, and a `Promise` that callers attach their callbacks to.

dmc-promise is [lua-promise](https://github.com/dmccuskey/lua-promise) packaged like the other DMC Solar2D libraries. Its names come from Twisted's `defer` module:

```lua
local Promise = require 'dmc_corona.dmc_promise'

local d = Promise.Deferred:new()
d:addCallbacks( function( value ) print( value ) end )
d:callback( 'done' )  --> done
```

## Features

- `Deferred`: the producer's side; resolves or rejects its promise
- `Promise`: `done()` and `fail()` callbacks, any number of each; a callback added after the promise settled runs at once
- Resolve and reject with any number of values; the callbacks get them all
- The futures of [dmc-wamp](https://github.com/dmccuskey/dmc-wamp)
- Pure Lua, no plugins needed; MIT licensed

It isn't Promises/A+: callbacks don't chain, and their return values and errors aren't passed on (lua-promise's [Known Issues](https://github.com/dmccuskey/lua-promise#known-issues)).

## Quick Start

The following code will get you up and running in about 10 minutes in the Solar2D Simulator on macOS or Windows. It makes a pretend request that answers a second later, and watches one request succeed and one fail.

Prerequisites: the [Solar2D](https://solar2d.com/) Simulator and a copy of this repository (`git clone https://github.com/dmccuskey/dmc-promise.git`, or download the ZIP from GitHub).

### 1. Copy the Library into Your Project

Copy these from this repository into the root of your project folder:

```text
dmc_corona_boot.lua     loader for the DMC libraries
dmc_corona.cfg          configuration
dmc_corona/             dmc-promise and the modules it needs
```

**Going further:** keep the libraries in a subfolder, or combine several DMC libraries ([dmc-corona-boot Configuration](https://github.com/dmccuskey/dmc-corona-boot/blob/master/docs/configuration.md)).

### 2. Make a Request That Answers Later

Create `main.lua` in the project folder:

```lua
local Promise = require 'dmc_corona.dmc_promise'

-- a request that answers a second later
local function fetchUser( id )
	local d = Promise.Deferred:new()
	timer.performWithDelay( 1000, function()
		if id == 1 then
			d:callback( { name='ada' } )
		else
			d:errback( "no user " .. id )
		end
	end )
	return d
end

local function onUser( user ) print( "got", user.name ) end
local function onError( reason ) print( "failed:", reason ) end

local request = fetchUser( 1 )
request:addCallbacks( onUser, onError )
fetchUser( 7 ):addCallbacks( onUser, onError )
print( request.promise.state )

-- later, the request has answered: a callback added now runs at once
timer.performWithDelay( 2000, function()
	print( request.promise.state )
	request.promise:done( function( user ) print( "still", user.name ) end )
end )
```

Open the project in the Simulator. The screen stays black; the console shows `pending` at once, the next two lines a second later, and the last two a second after that:

```text
pending
got	ada
failed:	no user 7
resolved
still	ada
```

If the console shows `module 'dmc_corona.dmc_promise' not found` instead, `dmc_corona/` is missing from the root of the project folder.

`fetchUser()` returns its `Deferred` at once and keeps it. When the answer comes, it calls `callback()` to resolve the promise or `errback()` to reject it, and the callbacks added with `addCallbacks( onUser, onError )` run. `d.promise` is the caller's side: its `state` is `pending` until then, and a callback added with `done()` after it settled runs straight away with the same values.

To update, copy `dmc_corona_boot.lua` and `dmc_corona/` again from the newer version. Keep your own `dmc_corona.cfg` if you have changed it.

## Documentation

`require 'dmc_corona.dmc_promise'` returns lua-promise's module, so its documentation applies as written:

- [Reference](https://github.com/dmccuskey/lua-promise#reference): `Deferred`, `Promise`, `maybeDeferred()`
- [Known Issues](https://github.com/dmccuskey/lua-promise#known-issues): what it doesn't do that other promise libraries do (chaining, settling once, catching errors)

## Configuration

dmc-promise has no settings: `dmc_corona.cfg` needs no section for it, only the `[DMC_CORONA]` section that tells the loader where the libraries are. See [dmc-corona-boot Configuration](https://github.com/dmccuskey/dmc-corona-boot/blob/master/docs/configuration.md).

## Known Issues

The bugs of the promises themselves are in lua-promise's [Known Issues](https://github.com/dmccuskey/lua-promise#known-issues). In `dmc_promise.lua`:

- It sets the global `_extend` (its copy of `Utils.extend()` declares the inner function without `local`).
- Its version (`0.1.0`) isn't available to code; `Promise.__version` is lua-promise's.

## Development

Only `dmc_corona/dmc_promise.lua` is written in this repository. It loads the DMC boot loader and returns lua-promise's module from `lib.dmc_lua.lua_promise`. Everything else is a generated copy; fix it in its own repository, then rebuild:

| file | owner |
|---|---|
| every file in `dmc_corona/lib/dmc_lua/` | [DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library), which copies them from the `lua-*` repositories ([lua-promise](https://github.com/dmccuskey/lua-promise), [lua-class](https://github.com/dmccuskey/lua-class), ...) |
| `dmc_corona_boot.lua` | [dmc-corona-boot](https://github.com/dmccuskey/dmc-corona-boot) |

The copies are made by Snakemake from sibling checkouts of the repositories above (`../DMC-Lua-Library`, `../dmc-corona-boot`, `../DMC-Corona-Library` for the shared rules). From this repository's root folder:

```sh
snakemake --cores 1 build_all
```

dmc-promise has no tests of its own; lua-promise's are in its `spec/`. The Quick Start is the check that the package loads in Solar2D.

## License

dmc-promise is released under the [MIT License](LICENSE).
