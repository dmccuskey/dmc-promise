# Changelog

## 0.2.0 (2026-10-01)

### Changed

- The promises are now lua-promise 0.2.0's, from DMC-Lua-Library's `lib.dmc_lua.lua_promise` (they were 0.1.1). From lua-promise 0.2.0:
  - A promise settles once: a later `callback()`/`errback()` (`resolve()`/`reject()`) is ignored. Before, it ran the callbacks again.
  - Values after a `nil` reach the callbacks.
  - `maybeDeferred( func, ... )` passes every argument on to `func`, and an error it raises comes back as a rejected `Deferred`.
- The module is a copy of lua-promise's, with the same classes; lua-promise's own module is left as it is.
- Rebuilt with dmc-corona-boot 1.6.0 and the current DMC-Lua-Library.

### Added

- `VERSION` (`__version` is lua-promise's).
- Unit tests: `tests/run_unit.sh`, plain Lua 5.1.

### Removed

- The copy of `Utils.extend()`, which set the global `_extend`; the module uses DMC-Lua-Library's `lua_utils`.

## 0.1.0

- First release: lua-promise packaged for Solar2D.
