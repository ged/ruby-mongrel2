#!/usr/bin/env ruby
#encoding: utf-8

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.parent

	libdir = basedir + "lib"

	$LOAD_PATH.unshift( basedir ) unless $LOAD_PATH.include?( basedir )
	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
}

require 'rspec'

require 'spec/lib/helpers'

require 'mongrel2'
require 'mongrel2/httprequest'
require 'mongrel2/httpresponse'


#####################################################################
###	C O N T E X T S
#####################################################################

describe Mongrel2::HTTPResponse do

	before( :all ) do
		setup_logging( :fatal )
	end

	before( :each ) do
		@response = Mongrel2::HTTPResponse.new( TEST_UUID, 299, :content_type => 'text/html' )
	end

	after( :all ) do
		reset_logging()
	end


	it "has a headers table" do
		@response.headers.should be_a( Mongrel2::Table )
	end

	it "allows headers to be set when the response is created" do
		@response.headers.content_type.should == 'text/html'
	end

	it "is a No Content response if not set otherwise" do
		@response.status_line.should == 'HTTP/1.1 204 No Content'
	end

	it "sets Date and Content-length headers automatically if they haven't been set" do
		@response << "Some stuff."

		@response.header_data.should =~ /Content-length: 11/i
		@response.header_data.should =~ /Date: #{HTTP_DATE}/i
	end

	it "re-calculates the automatically-added headers when re-rendered" do
		@response.header_data.should =~ /Content-length: 0/i
		@response << "More data!"
		@response.header_data.should =~ /Content-length: 10/i
	end

	it "doesn't have a body" do
		@response.body.should be_empty()
	end

	it "knows it hasn't been handled" do
		@response.should_not be_handled()
	end

	it "stringifies to a valid RFC2616 response string" do
		@response.to_s.should =~ HTTP_RESPONSE
	end

	it "has some default headers" do
		@response.headers['Server'].should == Mongrel2.version_string( true )
	end

	it "can be reset to a pristine state" do
		@response.body << "Some stuff we want to get rid of later"
		@response.headers['x-lunch-packed-by'] = 'Your Mom'
		@response.status = HTTP::OK

		@response.reset

		@response.should_not be_handled()
		@response.body.should == ''
		@response.headers.should have(1).keys
	end

	it "can find the length of its body if it's a String" do
		test_body = 'A string full of stuff'
		@response.body = test_body

		@response.get_content_length.should == test_body.length
	end

	it "can find the length of its body if it's a String with multi-byte characters in it" do
		test_body = 'Хорошая собака, Стрелке! Очень хорошо.'
		@response.body = test_body

		@response.get_content_length.should == test_body.bytesize
	end

	it "can find the length of its body if it's a seekable IO" do
		test_body = File.open( __FILE__, 'r' )
		test_body.seek( 0, IO::SEEK_END )
		length = test_body.tell
		test_body.seek( 0, IO::SEEK_SET )

		@response.body = test_body

		@response.get_content_length.should == length
	end

	it "can find the length of its body even if it's an IO that's been set to do a partial read" do
		test_body = File.open( __FILE__, 'r' )
		test_body.seek( 0, IO::SEEK_END )
		length = test_body.tell
		test_body.seek( 100, IO::SEEK_SET )

		@response.body = test_body

		@response.get_content_length.should == length - 100
	end

	it "knows that it has been handled even if the status is set to NOT_FOUND" do
		@response.status = HTTP::NOT_FOUND
		@response.should be_handled()
	end

	it "knows if it has not yet been handled" do
		@response.should_not be_handled()
		@response.status = HTTP::OK
		@response.should be_handled()
	end


	it "knows what category of response it is" do
		@response.status = HTTP::CREATED
		@response.status_category.should == 2

		@response.status = HTTP::NOT_ACCEPTABLE
		@response.status_category.should == 4
	end


	it "knows if its status indicates it is an informational response" do
		@response.status = HTTP::PROCESSING
		@response.status_category.should == 1
		@response.status_is_informational?.should == true
	end


	it "knows if its status indicates it is a successful response" do
		@response.status = HTTP::ACCEPTED
		@response.status_category.should == 2
		@response.status_is_successful?.should == true
	end


	it "knows if its status indicates it is a redirected response" do
		@response.status = HTTP::SEE_OTHER
		@response.status_category.should == 3
		@response.status_is_redirect?.should == true
	end


	it "knows if its status indicates there was a client error" do
		@response.status = HTTP::GONE
		@response.status_category.should == 4
		@response.status_is_clienterror?.should == true
	end


	it "knows if its status indicates there was a server error" do
		@response.status = HTTP::VERSION_NOT_SUPPORTED
		@response.status_category.should == 5
		@response.status_is_servererror?.should == true
	end


	it "knows what the response content type is" do
		headers = mock( 'headers' )
		@response.stub!( :headers ).and_return( headers )

		headers.should_receive( :[] ).
			with( :content_type ).
			and_return( 'text/erotica' )

		@response.content_type.should == 'text/erotica'
	end


	it "can modify the response content type" do
		headers = mock( 'headers' )
		@response.stub!( :headers ).and_return( headers )

		headers.should_receive( :[]= ).
			with( :content_type, 'image/nude' )

		@response.content_type = 'image/nude'
	end


	it "can find the length of its body if it's an IO" do
		test_body_content = 'A string with some stuff in it'
		test_body = StringIO.new( test_body_content )
		@response.body = test_body

		@response.get_content_length.should == test_body_content.length
	end


	it "raises a descriptive error message if it can't get the body's length" do
		@response.body = Object.new

		lambda {
			@response.get_content_length
		}.should raise_error( Mongrel2::ResponseError, /content length/i )
	end


	it "can build a valid HTTP status line for its status" do
		@response.status = HTTP::SEE_OTHER
		@response.status_line.should == "HTTP/1.1 303 See Other"
	end


	it "has pipelining disabled by default" do
		@response.should_not be_keepalive()
	end


	it "has pipelining disabled if it's explicitly disabled" do
		@response.keepalive = false
		@response.should_not be_keepalive()
	end


	it "can be set to allow pipelining" do
		@response.keepalive = true
		@response.should be_keepalive()
	end

	it "has a puts method for appending objects to the body" do
		@response.puts( :something_to_sable )
		@response.body.should == "something_to_sable\n"
	end

end

