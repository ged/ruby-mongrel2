#!/usr/bin/env ruby

require_relative '../helpers'

require 'ostruct'
require 'cztop'

require 'mongrel2'
require 'mongrel2/config'
require 'mongrel2/handler'


#####################################################################
###	C O N T E X T S
#####################################################################

describe Mongrel2::Handler, :db do

	# Make a handler class for testing
	class TestingHandler < Mongrel2::Handler
	end # class TestingHandler


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


		it "has a convenience method for instantiating and running a Handler given an application ID" do
			reactor = instance_double( CZTop::Reactor )
			expect( CZTop::Reactor ).to receive( :new ).and_return( reactor )
			expect( reactor ).to receive( :register ).at_least( :once )
			expect( reactor ).to receive( :unregister ).at_least( :once )
			expect( reactor ).to receive( :start_polling ).with( ignore_interrupts: true )

			handler = TestingHandler.run( TEST_UUID )

			# It should have pulled its connection info from the Handler entry in the database
			expect( handler.conn.app_id ).to eq( TEST_UUID )
			expect( handler.conn.sub_addr ).to eq( TEST_SEND_SPEC )
			expect( handler.conn.pub_addr ).to eq( TEST_RECV_SPEC )
		end


		it "knows what handler config corresponds to its app UUID" do
			reactor = instance_double( CZTop::Reactor )
			expect( CZTop::Reactor ).to receive( :new ).and_return( reactor )
			expect( reactor ).to receive( :register ).at_least( :once )
			expect( reactor ).to receive( :unregister ).at_least( :once )
			expect( reactor ).to receive( :start_polling ).with( ignore_interrupts: true )

			handler = TestingHandler.run( TEST_UUID )

			expect( handler.handler_config ).to be_a( Mongrel2::Config::Handler )
			expect( handler.handler_config.send_spec ).to eq( TEST_SEND_SPEC )
			expect( handler.handler_config.recv_spec ).to eq( TEST_RECV_SPEC )
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


	it "responds to HTTP requests with a 204 No Content response by default" do
		request = make_request_object()
		handler = TestingHandler.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC )

		response = handler.dispatch_request( request )

		expect( response ).to be_a( Mongrel2::HTTPResponse )
		expect( response.status ).to eq( 204 )
	end


	it "ignores JSON messages by default" do
		request = make_json_request_object()
		handler = TestingHandler.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC )

		response = handler.dispatch_request( request )

		expect( response ).to be_nil
	end


	it "dispatches JSON message to the #handle_json method" do
		json_handler_class = Class.new( TestingHandler ) do
			def handle_json( request )
				return request.response
			end
		end
		request = make_json_request_object()
		handler = json_handler_class.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC )

		response = handler.dispatch_request( request )

		expect( response ).to be_a( Mongrel2::Response )
	end


	it "ignores XML messages by default" do
		request = make_xml_request_object()
		handler = TestingHandler.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC )

		response = handler.dispatch_request( request )

		expect( response ).to be_nil
	end


	it "dispatches XML message to the #handle_xml method" do
		xml_handler_class = Class.new( TestingHandler ) do
			def handle_xml( request )
				return request.response
			end
		end
		request = make_xml_request_object()
		handler = xml_handler_class.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC )

		response = handler.dispatch_request( request )

		expect( response ).to be_a( Mongrel2::Response )
	end


	it "drops the connection on websocket opening handshakes by default" do
		request = make_websocket_handshake_object()
		handler = TestingHandler.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC )

		expect( handler.conn ).to receive( :reply_close ).with( request )

		response = handler.dispatch_request( request )

		expect( response ).to be_nil
	end


	it "dispatches WebSocket opening handshakes to the #handle_websocket_handshake method" do
		ws_handler_class = Class.new( TestingHandler ) do
			def handle_websocket_handshake( handshake )
				return handshake.response
			end
		end
		request = make_websocket_handshake_object()
		handler = ws_handler_class.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC )

		response = handler.dispatch_request( request )

		expect( response ).to be_a( Mongrel2::WebSocket::ServerHandshake )
	end


	it "directly closes the connection on websocket frames with a protocol violation by default" do
		request = make_websocket_frame_object()
		handler = TestingHandler.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC )

		expect( handler.conn ).to receive( :reply_close ).with( request )
		expect( handler.conn ).to receive( :reply ) do |reply|
			expect( reply ).to be_a( Mongrel2::WebSocket::Frame )
			expect( reply.opcode ).to eq( :close )
			reply.payload.rewind
			expect( reply.payload.read ).to start_with( '1008 ' )
		end

		response = handler.dispatch_request( request )

		expect( response ).to be_nil
	end


	it "dispatches WebSocket protocol frames to the #handle_websocket method" do
		ws_handler_class = Class.new( TestingHandler ) do
			def handle_websocket( frame )
				return frame.response
			end
		end
		request = make_websocket_frame_object()
		handler = ws_handler_class.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC )

		response = handler.dispatch_request( request )

		expect( response ).to be_a( Mongrel2::WebSocket::Frame )
	end


	it "ignores disconnect notices by default" do
		request = make_json_request_object( :path => '@*', :body => {'type' => 'disconnect'} )
		handler = TestingHandler.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC )

		response = handler.dispatch_request( request )

		expect( response ).to be_nil
	end


	it "dispatches disconnect notices to the #handle_disconnect method" do
		disconnect_handler_class = Class.new( TestingHandler ) do
			def initialize( * )
				super
				@handled_disconnect = false
			end

			attr_reader :handled_disconnect

			def handle_disconnect( request )
				@handled_disconnect = true
				self.log.debug "Doing stuff for disconnected connection %d" % [ request.conn_id ]
			end
		end
		request = make_json_request_object( :path => '@*', :body => {'type' => 'disconnect'} )
		handler = disconnect_handler_class.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC )

		response = handler.dispatch_request( request )

		expect( response ).to be_nil
		expect( handler.handled_disconnect ).to eq( true )
	end


	it "cancels async upload notices by default" do
		request = make_request_object(
			'METHOD' => 'POST',
			headers: {'x-mongrel2-upload-start' => 'uploadfile.XXX'}
		)
		handler = TestingHandler.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC )
		expect( handler.conn ).to receive( :reply_close ).with( request )

		response = handler.dispatch_request( request )

		expect( response ).to be_nil
	end


	it "re-establishes its connection when told to restart" do
		handler = TestingHandler.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC )
		original_conn = handler.conn

		expect( handler.reactor ).to receive( :unregister ).with( original_conn.request_sock )
		expect( handler.reactor ).to receive( :register ) do |request_sock, mode, &callback|
			expect( request_sock ).to be_a( CZTop::Socket )
			expect( request_sock ).to_not equal( original_conn.request_sock )
			expect( mode ).to eq( :read )
		end

		handler.restart

		expect( handler.conn ).to_not equal( original_conn )
	end


	it "cleans any mongrel2 request spool files after sending a response" do
		spoolfile = Pathname.new( Dir.tmpdir + '/mongrel2.uskd8l1' )
		spoolfile.write( "Hi!" )

		request = make_request_object(
			'METHOD' => 'POST',
			headers: {
				'x-mongrel2-upload-start' => spoolfile.basename,
				'x-mongrel2-upload-done'  => spoolfile.basename
			}
		)
		handler = TestingHandler.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC )

		expect( handler.conn ).to receive( :reply ).with( a_kind_of(Mongrel2::Response) )
		response = handler.accept_request( request )

		expect( request.body ).to be_closed
		expect( spoolfile ).to_not exist
	end
end

