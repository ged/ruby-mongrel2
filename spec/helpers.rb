#!/usr/bin/ruby
# coding: utf-8

require_relative 'constants'
require_relative 'matchers'

# SimpleCov test coverage reporting; enable this using the :coverage rake task
require 'simplecov' if ENV['COVERAGE']

begin
	require 'configurability'
rescue LoadError => err
end

require 'pathname'
require 'tmpdir'

require 'rspec'
require 'mongrel2'
require 'mongrel2/config'
require 'mongrel2/testing'

require 'loggability/spechelpers'

require 'sequel'
require 'sequel/model'



### RSpec helper functions that are used to test Mongrel2 itself.
module Mongrel2::SpecHelpers
	include Mongrel2::TestConstants

	###############
	module_function
	###############

	### Make an easily-comparable version vector out of +ver+ and return it.
	def vvec( ver )
		return ver.split('.').collect {|char| char.to_i }.pack('N*')
	end


	### Set up a Mongrel2 configuration database in memory.
	def setup_config_db
		Mongrel2::Config.db ||= Mongrel2::Config.in_memory_db
		Mongrel2::Config.init_database
		Mongrel2::Config.db.tables.collect {|t| Mongrel2::Config.db[t] }.each( &:truncate )
	end


	### Normalize and fill in missing members for the given +opts+.
	def normalize_headers( opts, defaults=TEST_HEADERS )
		headers = defaults.merge( opts[:headers] || {} )

		headers["PATH"]    = opts[:path]
		headers["URI"]     = "#{opts[:path]}?#{opts[:query]}"
		headers["QUERY"]   = opts[:query]
		headers["PATTERN"] = opts[:pattern] || opts[:path]

		return headers
	end


	### Make a raw Mongrel2 request from the specified +opts+ and return it as a String.
	def make_request( opts={} )
		opts = TEST_REQUEST_OPTS.merge( opts )
		headers = normalize_headers( opts )

		headerstring = TNetstring.dump( Yajl::Encoder.encode(headers) )
		bodystring = TNetstring.dump( opts[:body] || '' )

		# UUID ID PATH SIZE:HEADERS,SIZE:BODY,
		data = "%s %d %s %s%s" % [
			opts[:uuid],
			opts[:id],
			opts[:path],
			headerstring,
			bodystring,
		]
		return data.encode( 'binary' )
	end


	### Make a new-style (TNetstring headers) raw Mongrel2 request from the specified +opts+
	### and return it as a String.
	def make_tn_request( opts={} )
		opts = TEST_REQUEST_OPTS.merge( opts )
		headers = normalize_headers( opts )

		headerstring = TNetstring.dump( headers )
		bodystring = TNetstring.dump( opts[:body] || '' )

		# UUID ID PATH SIZE:HEADERS,SIZE:BODY,
		data = "%s %d %s %s%s" % [
			opts[:uuid],
			opts[:id],
			opts[:path],
			headerstring,
			bodystring,
		]
		return data.encode( 'binary' )
	end


	### Make a Mongrel2 request for a JSON route.
	def make_json_request( opts={} )
		opts = TEST_JSON_REQUEST_OPTS.merge( opts )
		headers = normalize_headers( opts, TEST_JSON_HEADERS )
		headers.delete( 'URI' ) # JSON requests don't have one

		Mongrel2.log.debug "JSON request, headers = %p, opts = %p" % [ headers, opts ]

		headerstring = TNetstring.dump( Yajl::Encoder.encode(headers) )
		bodystring = TNetstring.dump( Yajl::Encoder.encode(opts[:body] || []) )

		# UUID ID PATH SIZE:HEADERS,SIZE:BODY,
		data = "%s %d %s %s%s" % [
			opts[:uuid],
			opts[:id],
			opts[:path],
			headerstring,
			bodystring,
		]
		return data.encode( 'binary' )
	end


	### Make a Mongrel2 request for an XML route.
	def make_xml_request( opts={} )
		opts = TEST_XML_REQUEST_OPTS.merge( opts )
		headers = normalize_headers( opts, TEST_XML_HEADERS )
		headers.delete( 'URI' ) # XML requests don't have one

		Mongrel2.log.debug "XML request, headers = %p, opts = %p" % [ headers, opts ]

		headerstring = TNetstring.dump( Yajl::Encoder.encode(headers) )
		bodystring = TNetstring.dump( opts[:body] || "#{TEST_XML_PATH} />" )

		# UUID ID PATH SIZE:HEADERS,SIZE:BODY,
		data = "%s %d %s %s%s" % [
			opts[:uuid],
			opts[:id],
			opts[:path],
			headerstring,
			bodystring,
		]
		return data.encode( 'binary' )
	end

	### Make a Mongrel2 handshake request for a WebSocket route.
	def make_websocket_handshake( opts={} )
		opts = TEST_WEBSOCKET_REQUEST_OPTS.merge( opts )
		headers = normalize_headers( opts, TEST_WEBSOCKET_HANDSHAKE_HEADERS )

		Mongrel2.log.debug "WebSocket start handshake, headers = %p, opts = %p" % [ headers, opts ]

		headerstring = TNetstring.dump( Yajl::Encoder.encode(headers) )
		bodystring = TNetstring.dump( opts[:body] || TEST_WEBSOCKET_BODY )

		# UUID ID PATH SIZE:HEADERS,SIZE:BODY,
		data = "%s %d %s %s%s" % [
			opts[:uuid],
			opts[:id],
			opts[:path],
			headerstring,
			bodystring,
		]
		return data.encode( 'binary' )
	end

	### Make a Mongrel2 frame for a WebSocket route.
	def make_websocket_frame( opts={} )
		opts = TEST_WEBSOCKET_REQUEST_OPTS.merge( opts )
		headers = normalize_headers( opts, TEST_WEBSOCKET_HEADERS )

		Mongrel2.log.debug "WebSocket frame, headers = %p, opts = %p" % [ headers, opts ]

		headerstring = TNetstring.dump( Yajl::Encoder.encode(headers) )
		bodystring = TNetstring.dump( opts[:body] )

		# UUID ID PATH SIZE:HEADERS,SIZE:BODY,
		data = "%s %d %s %s%s" % [
			opts[:uuid],
			opts[:id],
			opts[:path],
			headerstring,
			bodystring,
		]
		return data.encode( 'binary' )
	end

end


abort "You need a version of RSpec >= 2.6.0" unless defined?( RSpec )

if defined?( ::Amalgalite )
	$stderr.puts ">>> Using Amalgalite #{Amalgalite::VERSION} for DB access."
else
	$stderr.puts ">>> Using SQLite3 #{SQLite3::VERSION} for DB access."
end

### Mock with RSpec
RSpec.configure do |c|
	include Mongrel2::TestConstants

	c.treat_symbols_as_metadata_keys_with_true_values = true
	c.run_all_when_everything_filtered = true
	c.filter_run :focus
	c.order = 'random'
	c.mock_with( :rspec ) do |config|
		config.syntax = :expect
	end

	c.extend( Mongrel2::TestConstants )
	c.include( Mongrel2::TestConstants )
	c.include( Mongrel2::SpecHelpers )
	c.include( Mongrel2::Matchers )
	c.include( Loggability::SpecHelpers )

	c.include( Mongrel2::Config::DSL )
end

# vim: set nosta noet ts=4 sw=4:

