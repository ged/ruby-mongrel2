# -*- ruby -*-
# frozen_string_literal: true
#encoding: utf-8

require_relative '../helpers'

require 'mongrel2'
require 'mongrel2/httprequest'
require 'mongrel2/httpresponse'


#####################################################################
###	C O N T E X T S
#####################################################################

describe Mongrel2::HTTPResponse do

	before( :each ) do
		@response = Mongrel2::HTTPResponse.new( TEST_UUID, 299 )
	end


	it "has a headers table" do
		expect( @response.headers ).to be_a( Mongrel2::Table )
	end


	it "allows headers to be set when the response is created" do
		response = Mongrel2::HTTPResponse.new( TEST_UUID, 299, :content_type => 'image/jpeg' )
		expect( response.headers.content_type ).to eq( 'image/jpeg' )
	end


	it "is a No Content response if not set otherwise" do
		expect( @response.status_line ).to eq( 'HTTP/1.1 204 No Content' )
	end


	it "returns an empty response if its status is set to NO_CONTENT" do
		@response.puts "The response body"
		@response.status = HTTP::NO_CONTENT
		expect( @response.header_data ).to_not match( /Content-length/i )
		expect( @response.header_data ).to_not match( /Content-type/i )
		expect( @response.to_s ).to_not match( /The response body/i )
	end


	it "sets Date, Content-type, and Content-length headers automatically if they haven't been set" do
		@response << "Some stuff."

		expect( @response.header_data ).to match( %r{Content-type: #{Mongrel2::HTTPResponse::DEFAULT_CONTENT_TYPE}}i )
		expect( @response.header_data ).to match( /Content-length: 11/i )
		expect( @response.header_data ).to match( /Date: #{HTTP_DATE}/i )
	end


	it "re-calculates the automatically-added headers when re-rendered" do
		expect( @response.header_data ).to match( /Content-length: 0\b/i )
		@response.status = HTTP::OK
		@response << "More data!"
		expect( @response.header_data ).to match( /Content-length: 10\b/i )
	end


	it "doesn't have a body" do
		expect( @response.body.size ).to eq( 0 )
	end


	it "stringifies to a valid RFC2616 response string" do
		expect( @response.to_s ).to match( HTTP_RESPONSE )
	end


	it "has some default headers" do
		expect( @response.headers['Server'] ).to eq( Mongrel2.version_string( true ) )
	end


	it "can be reset to a pristine state" do
		@response.body << "Some stuff we want to get rid of later"
		@response.headers['x-lunch-packed-by'] = 'Your Mom'
		@response.status = HTTP::OK

		@response.reset

		expect( @response ).to_not be_handled()
		expect( @response.body ).to be_a( StringIO )
		expect( @response.body.size ).to eq( 0 )
		expect( @response.headers.size ).to eq( 1 )
	end


	it "sets its status line to 200 OK if the body is set and the status hasn't yet been set" do
		@response << "Some stuff"
		expect( @response.status_line ).to eq( 'HTTP/1.1 200 OK' )
	end


	it "sets its status line to 204 No Content if the body is set and the status hasn't yet been set" do
		expect( @response.status_line ).to eq( 'HTTP/1.1 204 No Content' )
	end


	it "can find the length of its body if it's a String" do
		test_body = 'A string full of stuff'
		@response.body = test_body

		expect( @response.get_content_length ).to eq( test_body.length )
	end


	it "can find the length of its body if it's a String with multi-byte characters in it" do
		test_body = 'Хорошая собака, Стрелке! Очень хорошо.'
		@response << test_body

		expect( @response.get_content_length ).to eq( test_body.bytesize )
	end


	it "can find the length of its body if it's a seekable IO" do
		test_body = File.open( __FILE__, 'r' )
		test_body.seek( 0, IO::SEEK_END )
		length = test_body.tell
		test_body.seek( 0, IO::SEEK_SET )

		@response.body = test_body

		expect( @response.get_content_length ).to eq( length )
	end


	it "can find the length of its body even if it's an IO that's been set to do a partial read" do
		test_body = File.open( __FILE__, 'r' )
		test_body.seek( 0, IO::SEEK_END )
		length = test_body.tell
		test_body.seek( 100, IO::SEEK_SET )

		@response.body = test_body

		expect( @response.get_content_length ).to eq( length - 100 )
	end


	it "knows whether or not it has been handled" do
		expect( @response ).to_not be_handled()
		@response.status = HTTP::OK
		expect( @response ).to be_handled()
	end


	it "knows that it has been handled even if the status is set to NOT_FOUND" do
		@response.reset
		@response.status = HTTP::NOT_FOUND
		expect( @response ).to be_handled()
	end


	it "knows what category of response it is" do
		@response.status = HTTP::CREATED
		expect( @response.status_category ).to eq( 2 )

		@response.status = HTTP::NOT_ACCEPTABLE
		expect( @response.status_category ).to eq( 4 )
	end


	it "knows if its status indicates it is an informational response" do
		@response.status = HTTP::PROCESSING
		expect( @response.status_category ).to eq( 1 )
		expect( @response.status_is_informational? ).to eq( true )
	end


	it "knows if its status indicates it is a successful response" do
		@response.status = HTTP::ACCEPTED
		expect( @response.status_category ).to eq( 2 )
		expect( @response.status_is_successful? ).to eq( true )
	end


	it "knows if its status indicates it is a redirected response" do
		@response.status = HTTP::SEE_OTHER
		expect( @response.status_category ).to eq( 3 )
		expect( @response.status_is_redirect? ).to eq( true )
	end


	it "knows if its status indicates there was a client error" do
		@response.status = HTTP::GONE
		expect( @response.status_category ).to eq( 4 )
		expect( @response.status_is_clienterror? ).to eq( true )
	end


	it "knows if its status indicates there was a server error" do
		@response.status = HTTP::VERSION_NOT_SUPPORTED
		expect( @response.status_category ).to eq( 5 )
		expect( @response.status_is_servererror? ).to eq( true )
	end


	it "knows that a 100 response shouldn't have a body" do
		@response.status = HTTP::CONTINUE
		expect( @response ).to be_bodiless()
	end


	it "knows that a 204 response shouldn't have a body" do
		@response.status = HTTP::NO_CONTENT
		expect( @response ).to be_bodiless()
	end


	it "knows that a response with a body explicitly set to nil is bodiless" do
		@response.status = HTTP::CREATED
		@response.body = nil
		expect( @response ).to be_bodiless()
	end


	it "knows what the response content type is" do
		@response.headers['Content-Type'] = 'text/erotica'
		expect( @response.content_type ).to eq( 'text/erotica' )
	end


	it "can modify the response content type" do
		@response.content_type = 'image/nude'
		expect( @response.headers['Content-Type'] ).to eq( 'image/nude' )
	end


	it "can find the length of its body if it's an IO" do
		test_body_content = 'A string with some stuff in it'
		test_body = StringIO.new( test_body_content )
		@response.body = test_body

		expect( @response.get_content_length ).to eq( test_body_content.length )
	end


	it "returns a body length of 0 if it's a bodiless status code" do
		@response.puts "Some stuff"
		@response.status = HTTP::NO_CONTENT
		expect( @response.get_content_length ).to eq( 0 )
	end


	it "returns a body length of 0 if it has a nil body" do
		@response.body = nil
		@response.status = HTTP::CREATED
		expect( @response.get_content_length ).to eq( 0 )
	end


	it "doesn't reset the status to 204 NO CONTENT if there's an explicit content-length header" do

		# Simulate a response to a HEAD request
		request_factory = Mongrel2::RequestFactory.new( route: '/foo' )
		@response.request = request_factory.head( '/foo' )

		@response.header.content_length = 2048
		@response.body = ''

		expect( @response.status_line ).to match( /200 OK/i )
	end


	it "can build a valid HTTP status line for its status" do
		@response.status = HTTP::SEE_OTHER
		expect( @response.status_line ).to eq( "HTTP/1.1 303 See Other" )
	end


	it "has pipelining disabled by default" do
		expect( @response ).to_not be_keepalive()
	end


	it "has pipelining disabled if it's explicitly disabled" do
		@response.keepalive = false
		expect( @response ).to_not be_keepalive()
	end


	it "can be set to allow pipelining" do
		@response.keepalive = true
		expect( @response ).to be_keepalive()
	end


	it "has a puts method for appending objects to the body" do
		@response.puts( :something_to_sable )
		@response.body.rewind
		expect( @response.body.read ).to eq( "something_to_sable\n" )
	end

end

