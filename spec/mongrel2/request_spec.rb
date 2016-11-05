#!/usr/bin/env ruby

require_relative '../helpers'

require 'rspec'

require 'tnetstring'
require 'tmpdir'
require 'tempfile'

require 'mongrel2'
require 'mongrel2/request'


#####################################################################
###	C O N T E X T S
#####################################################################

describe Mongrel2::Request, :db do

	before( :all ) do

		# Set up a test server config so the request can find the server's chroot
		server 'specs' do
			default_host 'localhost'
			access_log   'access.log'
			error_log    'error.log'
			chroot       Dir.tmpdir
			pid_file     '/var/run/mongrel2.pid'
			port         8113

			host 'localhost' do
				route '/form', handler( 'tcp://127.0.0.1:9900', 'upload-handler' )
				route TEST_JSON_PATH, handler( 'tcp://127.0.0.1:9902', 'json-handler' )
			end
		end

		@factory = Mongrel2::RequestFactory.new( route: '/form' )
	end

	before( :each ) do
		Mongrel2::Config::Server.first.update( chroot: Dir.tmpdir )
	end


	it "can parse a request message" do

		message = make_request()
		req = Mongrel2::Request.parse( message )

		expect( req ).to be_a( Mongrel2::Request )
		expect( req.sender_id ).to eq( TEST_UUID )
		expect( req.conn_id ).to eq( TEST_ID )

		expect( req.headers ).to be_a( Mongrel2::Table )
		expect( req.headers['Host'] ).to eq( TEST_HEADERS['host'] )
	end

	it "can parse a request message with TNetstring headers" do

		message = make_tn_request()
		req = Mongrel2::Request.parse( message )

		expect( req ).to be_a( Mongrel2::Request )
		expect( req.sender_id ).to eq( TEST_UUID )
		expect( req.conn_id ).to eq( TEST_ID )

		expect( req.headers ).to be_a( Mongrel2::Table )
		expect( req.headers.host ).to eq( TEST_HEADERS['host'] )
	end

	it "can parse a request message with a JSON body" do

		message = make_json_request()
		req = Mongrel2::Request.parse( message )

		expect( req ).to be_a( Mongrel2::JSONRequest )
		expect( req.sender_id ).to eq( TEST_UUID )
		expect( req.conn_id ).to eq( TEST_ID )

		expect( req.headers ).to be_a( Mongrel2::Table )
		expect( req.headers.path ).to eq( TEST_JSON_PATH )

		expect( req.data ).to eq( TEST_JSON_BODY )
	end

	it "raises an UnhandledMethodError with the name of the method for METHOD verbs that " +
	   "don't look like HTTP ones" do

		message = make_request( :headers => {'METHOD' => '!DIVULGE'} )
		expect { Mongrel2::Request.parse(message) }.to raise_error( Mongrel2::UnhandledMethodError, /!DIVULGE/ )
	end

	it "knows what kind of response it should return" do
		expect( Mongrel2::Request.response_class ).to eq( Mongrel2::Response )
	end


	describe "instances" do

		before( :each ) do
			message = make_json_request() # HTTPRequest overrides the #response method
			@req = Mongrel2::Request.parse( message )
		end

		it "can return an appropriate response instance for themselves" do
			result = @req.response
			expect( result ).to be_a( Mongrel2::Response )
			expect( result.sender_id ).to eq( @req.sender_id )
			expect( result.conn_id ).to eq( @req.conn_id )
		end

		it "remembers its response if it's already made one" do
			expect( @req.response ).to equal( @req.response )
		end

		it "allows the entity body to be replaced by assigning a String" do
			@req.body = 'something else'
			expect( @req.body ).to be_a( StringIO )
			expect( @req.body.string ).to eq( 'something else' )
		end

		it "doesn't try to wrap non-stringish entity body replacements in a StringIO" do
			testobj = Object.new
			@req.body = testobj
			expect( @req.body ).to be( testobj )
		end

		it "provides a convenience method for fetching the requestor's IP address" do
			@req.headers.merge!(
				'X-Forwarded-For' => '127.0.0.1'
			)
			expect( @req.remote_ip.to_s ).to eq( '127.0.0.1' )
		end

		it "fetching the requestor's IP address even when travelling via proxies" do
			@req.headers.merge!(
				'X-Forwarded-For' => [ '127.0.0.1', '8.8.8.8', '4.4.4.4' ]
			)
			expect( @req.remote_ip.to_s ).to eq( '127.0.0.1' )
		end

		it "can look up the chroot directory of the server the request is from" do
			Mongrel2::Config::Server.first.update( chroot: '/usr/local/www' )
			expect( @req.server_chroot ).to be_a( Pathname )
			expect( @req.server_chroot.to_s ).to eq( '/usr/local/www' )
		end


		it "returns '/' as the chroot directory if the server isn't chrooted" do
			Mongrel2::Config::Server.first.update( chroot: '' )
			expect( @req.server_chroot ).to be_a( Pathname )
			expect( @req.server_chroot.to_s ).to eq( '/' )
		end

	end


	describe "content-type charset support" do

		it "uses the charset in the content-type header, if present" do
			body = "some data".encode( 'binary' )
			req = @factory.post( '/form', body, content_type: 'text/plain; charset=iso-8859-1' )

			expect( req.body.string.encoding ).to be( Encoding::ISO_8859_1 )
		end

		it "keeps the data as ascii-8bit if no charset is in the content-type header" do
			body = "some data".encode( 'binary' )
			req = @factory.post( '/form', body, content_type: 'application/octet-stream' )

			expect( req.body.string.encoding ).to be( Encoding::ASCII_8BIT )
		end

		it "keeps the data as ascii-8bit if there is no content-type header" do
			body = "some data".encode( 'binary' )
			req = @factory.post( '/form', body )

			expect( req.body.string.encoding ).to be( Encoding::ASCII_8BIT )
		end

	end


	describe "framework support" do

		before( :all ) do
			@oldtypes = Mongrel2::Request.request_types.dup
			@original_default_proc = Mongrel2::Request.request_types.default_proc
		end

		before( :each ) do
			Mongrel2::Request.request_types.default_proc = @original_default_proc
			Mongrel2::Request.request_types.clear
		end

		after( :all ) do
			Mongrel2::Request.request_types.default_proc = @original_default_proc
			Mongrel2::Request.request_types.replace( @oldtypes )
		end


		it "includes a mechanism for overriding the default Request subclass" do
			subclass = Class.new( Mongrel2::Request ) do
				register_request_type self, :__default
			end

			expect( Mongrel2::Request.subclass_for_method( 'GET' ) ).to eq( subclass )
			expect( Mongrel2::Request.subclass_for_method( 'POST' ) ).to eq( subclass )
			expect( Mongrel2::Request.subclass_for_method( 'JSON' ) ).to eq( subclass )
		end

		it "includes a mechanism for overriding the Request subclass for a particular request " +
		   "method" do
			subclass = Class.new( Mongrel2::Request ) do
				register_request_type self, :GET
			end

			expect( Mongrel2::Request.subclass_for_method( 'GET' ) ).to eq( subclass )
			expect( Mongrel2::Request.subclass_for_method( 'POST' ) ).to_not eq( subclass )
			expect( Mongrel2::Request.subclass_for_method( 'JSON' ) ).to_not eq( subclass )
		end

		it "clears any cached method -> subclass lookups when the default subclass changes" do
			Mongrel2::Request.subclass_for_method( 'OPTIONS' ) # cache OPTIONS -> Mongrel2::Request

			subclass = Class.new( Mongrel2::Request ) do
				register_request_type self, :__default
			end

			expect( Mongrel2::Request.subclass_for_method( 'OPTIONS' ) ).to eq( subclass )
		end

	end


	describe "async upload support" do

		before( :each ) do
			@spoolfile = Tempfile.new( 'mongrel2.upload', Dir.tmpdir )
			@spoolfile.print( File.read(__FILE__) )
			@spoolpath = @spoolfile.path.slice( Dir.tmpdir.length + 1..-1 )
		end

		it "knows if it's an 'async upload started' notification" do
			req = @factory.post( '/form', '', x_mongrel2_upload_start: @spoolpath )

			expect( req ).to be_upload_started()
			expect( req ).to_not be_upload_done()
		end

		it "knows if it's an 'async upload done' notification" do
			req = @factory.post( '/form', '',
				x_mongrel2_upload_start: @spoolpath,
				x_mongrel2_upload_done: @spoolpath )

			expect( req ).to_not be_upload_started()
			expect( req ).to be_upload_done()
			expect( req ).to be_valid_upload()
		end

		it "knows if it's not a valid 'async upload done' notification" do
			req = @factory.post( '/form', '',
				x_mongrel2_upload_start: @spoolpath,
				x_mongrel2_upload_done: '/etc/passwd' )

			expect( req ).to_not be_upload_started()
			expect( req ).to be_upload_done()
			expect( req ).to_not be_valid_upload()
		end

		it "raises an exception if the uploaded file fetched with mismatched headers" do
			req = @factory.post( '/form', '',
				x_mongrel2_upload_start: @spoolpath,
				x_mongrel2_upload_done: '/etc/passwd' )

			expect {
				req.uploaded_file
			}.to raise_error( Mongrel2::UploadError, /upload headers/i )
		end

		it "can return a Pathname object for the uploaded file if it's valid" do
			req = @factory.post( '/form', '',
				x_mongrel2_upload_start: @spoolpath,
				x_mongrel2_upload_done:  @spoolpath )

			expect( req ).to be_valid_upload()

			expect( req.uploaded_file ).to be_a( Pathname )
			expect( req.uploaded_file.to_s ).to eq( @spoolfile.path )
		end

		it "sets the body of the request to the uploaded File if it's valid" do
			req = @factory.post( '/form', '',
				x_mongrel2_upload_start: @spoolpath,
				x_mongrel2_upload_done:  @spoolpath )

			expect( req ).to be_valid_upload()

			expect( req.body ).to be_a( File )
			expect( req.body.path ).to eq( @spoolfile.path )
		end

	end

end

