--====================================================================--
-- tests/dmc_promise_spec.lua
--
-- Unit tests for dmc-promise, using Luna Test.
-- Run with tests/run_unit.sh
--
-- lua-promise has the full specs; these check the wrapper, and
-- that lua-promise's fixes come through it
--====================================================================--


module(..., package.seeall)



--====================================================================--
--== Setup


local Promise, LuaPromise

function suite_setup()
	Promise = require 'dmc_corona.dmc_promise'
	LuaPromise = require 'lib.dmc_lua.lua_promise'
end



--====================================================================--
--== Tests


function test_module()
	assert_equal( 'table', type( Promise ) )
	assert_equal( '0.2.0', Promise.VERSION )
	assert_equal( '0.2.0', Promise.__version )
	assert_nil( LuaPromise.VERSION )
end

-- a copy of the module, with the same classes
function test_same_classes()
	assert_equal( LuaPromise.Deferred, Promise.Deferred )
	assert_equal( LuaPromise.Promise, Promise.Promise )
	assert_equal( LuaPromise.maybeDeferred, Promise.maybeDeferred )
	local d = Promise.Deferred:new()
	assert_true( d:isa( LuaPromise.Deferred ) )
end

function test_no_global_extend()
	assert_nil( rawget( _G, '_extend' ) )
end

-- the Quick Start: one request resolves, one rejects, and a callback
-- added after it settled runs at once
function test_quick_start()
	local got, failed = {}, {}
	local function onUser( user ) got[ #got+1 ] = user.name end
	local function onError( reason ) failed[ #failed+1 ] = reason end

	local request = Promise.Deferred:new()
	request:addCallbacks( onUser, onError )
	local other = Promise.Deferred:new()
	other:addCallbacks( onUser, onError )
	assert_equal( 'pending', request.promise.state )

	request:callback( { name='ada' } )
	other:errback( "no user 7" )
	assert_equal( 'resolved', request.promise.state )
	assert_equal( 'rejected', other.promise.state )
	assert_equal( 'ada', got[1] )
	assert_equal( 'no user 7', failed[1] )

	request.promise:done( onUser )
	assert_equal( 2, #got )
	assert_equal( 'ada', got[2] )
end

-- lua-promise 0.2.0: a promise settles once
function test_settles_once()
	local count = 0
	local d = Promise.Deferred:new()
	d:addCallbacks( function() count = count + 1 end,
		function() count = count + 100 end )
	d:callback( 1 )
	d:callback( 2 )
	d:errback( 'late' )
	assert_equal( 1, count )
	assert_equal( 'resolved', d.promise.state )
end

-- lua-promise 0.2.0: values after a nil are kept
function test_values_after_nil()
	local a, b, c
	local d = Promise.Deferred:new()
	d:callback( 1, nil, 3 )
	d.promise:done( function( x, y, z ) a, b, c = x, y, z end )
	assert_equal( 1, a )
	assert_nil( b )
	assert_equal( 3, c )
end

-- lua-promise 0.2.0: maybeDeferred() passes every argument and catches
-- an error as a rejected Deferred
function test_maybe_deferred()
	local value, reason
	local d = Promise.maybeDeferred( function( x, y ) return x + y end, 2, 3 )
	d:addCallbacks( function( v ) value = v end )
	assert_equal( 5, value )

	d = Promise.maybeDeferred( function() error( 'boom', 0 ) end )
	d:addCallbacks( nil, function( r ) reason = r end )
	assert_equal( 'boom', reason )
end
