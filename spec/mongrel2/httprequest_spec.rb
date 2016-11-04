#!/usr/bin/env ruby

require_relative '../helpers'

require 'rspec'
require 'tnetstring'

require 'mongrel2'
require 'mongrel2/httprequest'
require 'mongrel2/httpresponse'


#####################################################################
###	C O N T E X T S
#####################################################################

describe Mongrel2::HTTPRequest do

	before( :all ) do
		@factory = Mongrel2::RequestFactory.new( route: '/glamour' )
	end

	before( :each ) do
		@req = @factory.get( '/glamour/test' )
	end


	it "can create an HTTPResponse for itself" do
		result = @req.response
		expect( result ).to be_a( Mongrel2::HTTPResponse )
		expect( result.sender_id ).to eq( @req.sender_id )
		expect( result.conn_id ).to eq( @req.conn_id )
	end

	it "remembers its corresponding HTTPResponse if it's created it already" do
		result = @req.response
		expect( result ).to be_a( Mongrel2::HTTPResponse )
		expect( result.sender_id ).to eq( @req.sender_id )
		expect( result.conn_id ).to eq( @req.conn_id )
	end

	it "knows that its connection isn't persistent if it's an HTTP/1.0 request" do
		@req.headers.version = 'HTTP/1.0'
		expect( @req ).to_not be_keepalive()
	end

	it "knows that its connection isn't persistent if has a 'close' token in its Connection header" do
		@req.headers.version = 'HTTP/1.1'
		@req.headers[ :connection ] = 'violent, close'
		expect( @req ).to_not be_keepalive()
	end

	it "knows that its connection could be persistent if doesn't have a Connection header, " +
	   "and it's an HTTP/1.1 request" do
		@req.headers.version = 'HTTP/1.1'
		@req.headers.delete( :connection )
		expect( @req ).to be_keepalive()
	end

	it "knows that its connection is persistent if has a Connection header without a 'close' " +
	   "token and it's an HTTP/1.1 request" do
		@req.headers.version = 'HTTP/1.1'
		@req.headers.connection = 'keep-alive'
		expect( @req ).to be_keepalive()
	end

	it "knows what its URL scheme was" do
		expect( @req.scheme ).to eq( 'http' )
	end

	it "falls back to 'http' if the url_scheme isn't provided (mongrel2 <= 1.8.0)" do
		@req.headers.url_scheme = nil
		expect( @req.scheme ).to eq( 'http' )
	end

	it "knows that it was an SSL-encrypted request if its scheme was 'https'" do
		@req.headers.url_scheme = 'https'
		expect( @req ).to be_secure()
	end

	it "doesn't error when inspecting a bodiless instance" do
		# I don't remember what circumstances this is guarding against, so this is a bit
		# artificial
		@req.body = double( "sizeless body", size: nil )
		expect( @req.inspect ).to match( /0.00K body/ )
	end


	describe "header convenience methods" do

		before( :each ) do
			@req.headers.merge!(
				'Content-length' => '28113',
				'Content-type' => 'application/x-pdf',
				'Content-encoding' => 'gzip'
			)
		end

		it "provides a convenience method for fetching the 'Content-type' header" do
			expect( @req.content_type ).to eq( 'application/x-pdf' )
		end

		it "provides a convenience method for resetting the 'Content-type' header" do
			@req.content_type = 'application/json'
			expect( @req.content_type ).to eq( 'application/json' )
		end

		it "provides a convenience method for fetching the 'Content-encoding' header" do
			expect( @req.content_encoding ).to eq( 'gzip' )
		end

		it "provides a convenience method for resetting the 'Content-encoding' header" do
			@req.content_encoding = 'identity'
			expect( @req.content_encoding ).to eq( 'identity' )
		end

		it "provides a convenience method for fetching the request's Content-length header" do
			expect( @req.content_length ).to eq( 28113 )
		end

		it "returns 0 as the content_length if the request doesn't have a Content-length header" do
			@req.headers.delete( :content_length )
			expect( @req.content_length ).to eq( 0 )
		end

		it "raises an exception if the Content-length header contains something other than an integer" do
			@req.headers.content_length = 'Lots'
			expect {
				@req.content_length
			}.to raise_error( ArgumentError, /invalid value for integer/i )
		end

	end

end

