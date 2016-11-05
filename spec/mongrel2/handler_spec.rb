#!/usr/bin/env ruby

require_relative '../helpers'

require 'mongrel2'
require 'mongrel2/config'
require 'mongrel2/handler'


#####################################################################
###	C O N T E X T S
#####################################################################

describe Mongrel2::Handler, :db do

	# Make a handler class for testing that only ever handles one request, and
	# keeps track of any requests it handles and their responses.
	class OneShotHandler < Mongrel2::Handler
		def initialize( * )
			@transactions = {}
			super
		end

		attr_reader :transactions

		# Overridden to accept one request and shut down
		def dispatch_request( request )
			response = super
			self.transactions[ request ] = response
			self.shutdown
			return response
		end

	end # class OneShotHandler


	# Ensure 0MQ never actually gets called
	before( :each ) do
		@ctx = double( '0mq context', close: nil )
		@request_sock = double( "request socket", :linger= => nil, :connect => nil, :close => nil )
		@response_sock = double( "response socket", :linger= => nil, :connect => nil, :close => nil )

		allow( @ctx ).to receive( :socket ).with( :PULL ).and_return( @request_sock )
		allow( @ctx ).to receive( :socket ).with( :PUB ).and_return( @response_sock )

		allow( ZMQ ).to receive( :select ).and_return([ [@request_sock], [], [] ])

		Mongrel2.instance_variable_set( :@zmq_ctx, @ctx )
	end

	after( :each ) do
		Mongrel2.instance_variable_set( :@zmq_ctx, nil )
	end



	context "with a Handler entry in the config database" do

		before( :each ) do
			@handler_config = {
				:send_spec  => TEST_SEND_SPEC,
				:send_ident => TEST_UUID,
				:recv_spec  => TEST_RECV_SPEC,
			}

			Mongrel2::Config::Handler.dataset.truncate
			Mongrel2::Config::Handler.create( @handler_config )
		end

		after( :each ) do
			clean_config_db
		end


		it "can look up connection information given an application ID" do
			expect(
				Mongrel2::Handler.connection_info_for(TEST_UUID)
			).to eq([ TEST_SEND_SPEC, TEST_RECV_SPEC ])
		end

		it "has a convenience method for instantiating and running a Handler given an " +
		   "application ID" do

			req = make_request()
			expect( @request_sock ).to receive( :recv ).and_return( req )

			res = OneShotHandler.run( TEST_UUID )

			# It should have pulled its connection info from the Handler entry in the database
			expect( res.conn.app_id ).to eq( TEST_UUID )
			expect( res.conn.sub_addr ).to eq( TEST_SEND_SPEC )
			expect( res.conn.pub_addr ).to eq( TEST_RECV_SPEC )
		end

		it "knows what handler config corresponds to its" do
			req = make_request()
			expect( @request_sock ).to receive( :recv ).and_return( req )

			res = OneShotHandler.run( TEST_UUID )

			expect( res.handler_config ).to be_a( Mongrel2::Config::Handler )
			expect( res.handler_config.send_spec ).to eq( TEST_SEND_SPEC )
			expect( res.handler_config.recv_spec ).to eq( TEST_RECV_SPEC )
		end

	end


	context "without a Handler entry for it in the config database" do

		before( :each ) do
			Mongrel2::Config::Handler.dataset.truncate
		end

		it "raises an exception if no handler with its appid exists in the config DB" do
			Mongrel2::Config::Handler.dataset.truncate
			expect {
				Mongrel2::Handler.connection_info_for( TEST_UUID )
			}.to raise_error( ArgumentError )
		end

	end


	it "dispatches HTTP requests to the #handle method" do
		req = make_request()
		expect( @request_sock ).to receive( :recv ).and_return( req )

		res = OneShotHandler.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC ).run

		expect( res.transactions.size ).to eq(  1  )
		request, response = res.transactions.first
		expect( request ).to be_a( Mongrel2::HTTPRequest )
		expect( response ).to be_a( Mongrel2::HTTPResponse )
		expect( response.status ).to eq( 204 )
	end

	it "ignores JSON messages by default" do
		req = make_json_request()
		expect( @request_sock ).to receive( :recv ).and_return( req )

		res = OneShotHandler.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC ).run

		expect( res.transactions.size ).to eq(  1  )
		request, response = res.transactions.first
		expect( request ).to be_a( Mongrel2::JSONRequest )
		expect( response ).to be_nil()
	end

	it "dispatches JSON message to the #handle_json method" do
		json_handler = Class.new( OneShotHandler ) do
			def handle_json( request )
				return request.response
			end
		end

		req = make_json_request()
		expect( @request_sock ).to receive( :recv ).and_return( req )

		res = json_handler.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC ).run

		expect( res.transactions.size ).to eq(  1  )
		request, response = res.transactions.first
		expect( request ).to be_a( Mongrel2::JSONRequest )
		expect( response ).to be_a( Mongrel2::Response )
	end

	it "ignores XML messages by default" do
		req = make_xml_request()
		expect( @request_sock ).to receive( :recv ).and_return( req )

		res = OneShotHandler.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC ).run

		expect( res.transactions.size ).to eq(  1  )
		request, response = res.transactions.first
		expect( request ).to be_a( Mongrel2::XMLRequest )
		expect( response ).to be_nil()
	end

	it "dispatches XML message to the #handle_xml method" do
		xml_handler = Class.new( OneShotHandler ) do
			def handle_xml( request )
				return request.response
			end
		end

		req = make_xml_request()
		expect( @request_sock ).to receive( :recv ).and_return( req )

		res = xml_handler.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC ).run

		expect( res.transactions.size ).to eq(  1  )
		request, response = res.transactions.first
		expect( request ).to be_a( Mongrel2::XMLRequest )
		expect( response ).to be_a( Mongrel2::Response )
	end

	it "dispatches WebSocket opening handshakes to the #handle_websocket_handshake method" do
		ws_handler = Class.new( OneShotHandler ) do
			def handle_websocket_handshake( handshake )
				return handshake.response
			end
		end

		req = make_websocket_handshake()
		expect( @request_sock ).to receive( :recv ).and_return( req )

		res = ws_handler.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC ).run

		expect( res.transactions.size ).to eq(  1  )
		request, response = res.transactions.first
		expect( request ).to be_a( Mongrel2::WebSocket::ClientHandshake )
		expect( response ).to be_a( Mongrel2::WebSocket::ServerHandshake )
	end

	it "dispatches WebSocket protocol frames to the #handle_websocket method" do
		ws_handler = Class.new( OneShotHandler ) do
			def handle_websocket( frame )
				return frame.response
			end
		end

		req = make_websocket_frame()
		expect( @request_sock ).to receive( :recv ).and_return( req )

		res = ws_handler.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC ).run

		expect( res.transactions.size ).to eq(  1  )
		request, response = res.transactions.first
		expect( request ).to be_a( Mongrel2::WebSocket::Frame )
		expect( response ).to be_a( Mongrel2::WebSocket::Frame )
	end

	it "continues when a ZMQ::Error is received but the connection remains open" do
		req = make_request()

		expect( @request_sock ).to receive( :recv ).and_raise( ZMQ::Error.new("Interrupted system call.") )
		expect( @request_sock ).to receive( :recv ).and_return( req )

		res = OneShotHandler.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC ).run

		expect( res.transactions.size ).to eq(  1  )
		request, response = res.transactions.first
		expect( request ).to be_a( Mongrel2::HTTPRequest )
		expect( response ).to be_a( Mongrel2::HTTPResponse )
		expect( response.status ).to eq( 204 )
	end

	it "ignores disconnect notices by default" do
		req = make_json_request( :path => '@*', :body => {'type' => 'disconnect'} )
		expect( @request_sock ).to receive( :recv ).and_return( req )

		res = OneShotHandler.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC ).run

		expect( res.transactions.size ).to eq(  1  )
		request, response = res.transactions.first
		expect( request ).to be_a( Mongrel2::JSONRequest )
		expect( response ).to be_nil()
	end

	it "dispatches disconnect notices to the #handle_disconnect method" do
		disconnect_handler = Class.new( OneShotHandler ) do
			def handle_disconnect( request )
				self.log.debug "Doing stuff for disconnected connection %d" % [ request.conn_id ]
			end
		end

		req = make_json_request( :path => '@*', :body => {'type' => 'disconnect'} )
		expect( @request_sock ).to receive( :recv ).and_return( req )

		res = disconnect_handler.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC ).run

		expect( res.transactions.size ).to eq(  1  )
		request, response = res.transactions.first
		expect( request ).to be_a( Mongrel2::JSONRequest )
		expect( response ).to be_nil()
	end

	it "cancels async upload notices by default" do
		req = make_request( 'METHOD' => 'POST', :headers => {'x-mongrel2-upload-start' => 'uploadfile.XXX'} )
		expect( @request_sock ).to receive( :recv ).and_return( req )
		expect( @response_sock ).to receive( :send ).with( "#{TEST_UUID} 1:8, " )

		res = OneShotHandler.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC ).run

		expect( res.transactions.size ).to eq(  1  )
		request, response = res.transactions.first
		expect( response ).to be_nil()
	end

	it "re-establishes its connection when told to restart" do
		res = OneShotHandler.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC )
		original_conn = res.conn
		res.restart
		expect( res.conn ).to_not equal( original_conn )
	end

	it "cleans any mongrel2 request spool files after sending a response" do
		spoolfile = Pathname.new( Dir.tmpdir + '/mongrel2.uskd8l1' )
		spoolfile.write( "Hi!" )

		req = make_request( 'METHOD' => 'POST', :headers => {
			'x-mongrel2-upload-start' => spoolfile.basename,
			'x-mongrel2-upload-done'  => spoolfile.basename
		})
		expect( @request_sock ).to receive( :recv ).and_return( req )

		res = OneShotHandler.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC ).run
		expect( spoolfile ).to_not exist
	end
end

