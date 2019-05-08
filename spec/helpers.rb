# -*- ruby -*-
# frozen_string_literal: true
# coding: utf-8

# SimpleCov test coverage reporting; enable this using the :coverage rake task
require 'simplecov' if ENV['COVERAGE']

require_relative 'constants'
require_relative 'matchers'

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
	include Mongrel2::Config::DSL

	###############
	module_function
	###############

	### Make an easily-comparable version vector out of +ver+ and return it.
	def vvec( ver )
		return ver.split('.').collect {|char| char.to_i }.pack('N*')
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


	### Provide a default mongrel2 configuration.
	###
	def setup_mongrel2_config
		server 'test-server' do
			chroot Dir.tmpdir
			port 8080
			default_host 'test-host'

			host 'test-host' do
				route '/handler', handler( TEST_RECV_SPEC, 'test-handler' )
			end
		end
	end


	### Make a raw Mongrel2 request from the specified +opts+ and return it as a String.
	def make_request( opts={} )
		setup_mongrel2_config()
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


	### Make a Mongrel2::Request from the specified +opts+ and return it.
	def make_request_object( opts={} )
		data = make_request( opts )
		return Mongrel2::Request.parse( data )
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


	### Make a Mongrel2::JSONRequest from the specified +opts+ and return it.
	def make_json_request_object( opts={} )
		data = make_json_request( opts )
		return Mongrel2::Request.parse( data )
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


	### Make a Mongrel2::XMLRequest from the specified +opts+ and return it.
	def make_xml_request_object( opts={} )
		data = make_xml_request( opts )
		return Mongrel2::Request.parse( data )
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


	### Make a Mongrel2::WebSocket::ClientHandshake from the specified +opts+ and
	### return it.
	def make_websocket_handshake_object( opts={} )
		data = make_websocket_handshake( opts )
		return Mongrel2::Request.parse( data )
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


	### Make a Mongrel2::WebSocket::Frame from the specified +opts+ and return it.
	def make_websocket_frame_object( opts={} )
		data = make_websocket_frame( opts )
		return Mongrel2::Request.parse( data )
	end

end


if defined?( ::Amalgalite )
	$stderr.puts ">>> Using Amalgalite #{Amalgalite::VERSION} for DB access."
else
	$stderr.puts ">>> Using SQLite3 #{SQLite3::VERSION} for DB access."
end

### Mock with RSpec
RSpec.configure do |c|
	include Mongrel2::TestConstants

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

