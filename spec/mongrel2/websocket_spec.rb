#!/usr/bin/env ruby
#encoding: utf-8

require_relative '../helpers'

require 'rspec'

require 'tnetstring'
require 'securerandom'

require 'mongrel2'
require 'mongrel2/websocket'


#####################################################################
###	C O N T E X T S
#####################################################################

describe Mongrel2::WebSocket do

	before( :all ) do
		setup_logging()
		@factory = Mongrel2::WebSocketFrameFactory.new( route: '/websock' )
	end

	after( :all ) do
		reset_logging()
	end

	# Data for testing payload of binary frames
	BINARY_DATA =
		"\a\xBD\xB3\xFE\x87\xEB\xA9\x0En2q\xCE\x85\xAF)\x88w_d\xD6M" +
		"\x9E\xAF\xCB\x89\x8F\xC8\xA0\x80ZL+\a\x9C\xF7{`\x9E'\xCF\xD9" +
		"\xE8\xA5\x9C\xF7T\xE2\xDD\xF5\xE9\x14\x1F,?\xD2\nQ\f\x06\x96" +
		"\x19\xB7\x06\x9F\xCD+*\x01\xC7\x98\xFE\x8A\x81\x04\xFF\xA7.J" +
		"\xF1\x9F\x9E\xEB$<;\x99>q\xBA\x12\xB3&i\xCCaE}\xAA\x87>ya\x0E" +
		"\xB0n\xD8lN\xE5\b\x83\xBB\x1D1\xFD\e\x84\xC1\xB4\x99\xC7\xCA" +
		"\xF8}C\xF2\xC6\x04\xA208\xA1\xCF\xB9\xFF\xF2\x9C~mbi\xBC\xE0" +
		"\xBE\xFER\xB5B#\xF1Z^\xB6\x80\xD2\x8E=t\xC6\x86`\xFAY\xD9\x01" +
		"\xBF\xA7\x88\xE1rf?C\xB8XC\xEF\x9F\xB1j,\xC7\xE4\x9E\x86)7\"f0" +
		"\xA0FH\xFC\x99\xCA\xB3D\x06ar\x9C\xEC\xE9\xAEj:\xFD\x1C\x06H\xF0" +
		"\xF1w~\xEC\r\x7F\x00\xED\xD88\x81\xF0/\x99\xD7\x9D\xA9C\x06\xEF" +
		"\x9B\xF3\x17\a\xDB\v{\e\xA3\tKTPV\xB8\xCB\xBB\xC9\x87f\\\xD0\x165"
	BINARY_DATA.force_encoding( Encoding::ASCII_8BIT )


	describe 'ClientHandshake' do

		it "is the registered request type for WEBSOCKET_HANDSHAKE requests" do
			expect( Mongrel2::Request.request_types[:WEBSOCKET_HANDSHAKE] ).to eq( Mongrel2::WebSocket::ClientHandshake )
		end

		it "knows what subprotocols were requested" do
			handshake = @factory.handshake( '/websock', 'echo', 'superecho' )
			expect( handshake.protocols ).to eq( ['echo', 'superecho'] )
		end

		it "doesn't error if no subprotocols were requested" do
			handshake = @factory.handshake( '/websock' )
			expect( handshake.protocols ).to eq( [] )
		end

		it "can create a response WebSocket::ServerHandshake for itself" do
			handshake = @factory.handshake( '/websock' )
			result = handshake.response
			handshake.body.rewind

			expect( result ).to be_a( Mongrel2::WebSocket::ServerHandshake )
			expect( result.sender_id ).to eq( handshake.sender_id )
			expect( result.conn_id ).to eq( handshake.conn_id )
			expect( result.header.sec_websocket_accept ).to eq( handshake.body.string )
			expect( result.status ).to eq( HTTP::SWITCHING_PROTOCOLS )
			expect( result.header.connection ).to match( /upgrade/i )
			expect( result.header.upgrade ).to match( /websocket/i )

			result.body.rewind
			expect( result.body.read ).to eq( '' )
		end

		it "can create a response WebSocket::ServerHandshake with a valid sub-protocol for itself" do
			handshake = @factory.handshake( '/websock', 'echo', 'superecho' )
			result = handshake.response( :superecho )
			handshake.body.rewind

			expect( result ).to be_a( Mongrel2::WebSocket::ServerHandshake )
			expect( result.sender_id ).to eq( handshake.sender_id )
			expect( result.conn_id ).to eq( handshake.conn_id )
			expect( result.header.sec_websocket_accept ).to eq( handshake.body.string )
			expect( result.status ).to eq( HTTP::SWITCHING_PROTOCOLS )
			expect( result.header.connection ).to match( /upgrade/i )
			expect( result.header.upgrade ).to match( /websocket/i )
			expect( result.protocols ).to eq( ['superecho'] )

			result.body.rewind
			expect( result.body.read ).to eq( '' )
		end

		it "raises an exception if the specified protocol is not one of the client's advertised ones" do
			handshake = @factory.handshake( '/websock', 'echo', 'superecho' )

			expect {
				handshake.response( :map_updates )
			}.to raise_error( Mongrel2::WebSocket::HandshakeError, /map_updates/i )
		end

		it "has a socket identifier" do
			handshake = @factory.handshake( '/websock', 'echo', 'superecho' )
			expect( handshake.socket_id ).to eq( "#{handshake.sender_id}:#{handshake.conn_id}" )
		end

	end



	describe 'Frame' do

		it "is the registered request type for WEBSOCKET requests" do
			expect( Mongrel2::Request.request_types[:WEBSOCKET] ).to eq( Mongrel2::WebSocket::Frame )
		end

		it "knows that its FIN flag is not set if its FLAG header doesn't include that bit" do
			frame = @factory.text( '/websock', 'Hello!' )
			frame.flags ^= ( frame.flags & Mongrel2::WebSocket::FIN_FLAG )
			expect( frame ).to_not be_fin()
		end

		it "knows that its FIN flag is set if its FLAG header includes that bit" do
			frame = @factory.text( '/websock', 'Hello!', :fin )
			expect( frame ).to be_fin()
		end

		it "can unset its FIN flag" do
			frame = @factory.text( '/websock', 'Hello!', :fin )
			frame.fin = false
			expect( frame ).to_not be_fin()
		end

		it "can set its FIN flag" do
			frame = @factory.text( '/websock', 'Hello!' )
			frame.fin = true
			expect( frame ).to be_fin()
		end

		it "knows that its opcode is continuation if its opcode is 0x0" do
			expect( @factory.continuation( '/websock' ).opcode ).to eq( :continuation )
		end

		it "knows that is opcode is 'text' if its opcode is 0x1" do
			expect( @factory.text( '/websock', 'Hello!' ).opcode ).to eq( :text )
		end

		it "knows that is opcode is 'binary' if its opcode is 0x2" do
			expect( @factory.binary( '/websock', 'Hello!' ).opcode ).to eq( :binary )
		end

		it "knows that is opcode is 'close' if its opcode is 0x8" do
			expect( @factory.close( '/websock' ).opcode ).to eq( :close )
		end

		it "knows that is opcode is 'ping' if its opcode is 0x9" do
			expect( @factory.ping( '/websock' ).opcode ).to eq( :ping )
		end

		it "knows that is opcode is 'pong' if its opcode is 0xA" do
			expect( @factory.pong( '/websock' ).opcode ).to eq( :pong )
		end

		it "knows that its opcode is one of the reserved ones if it's 0x3" do
			expect( @factory.create( '/websocket', '', 0x3 ).opcode ).to eq( :reserved )
		end

		it "knows that its opcode is one of the reserved ones if it's 0x4" do
			expect( @factory.create( '/websocket', '', 0x4 ).opcode ).to eq( :reserved )
		end

		it "knows that its opcode is one of the reserved ones if it's 0xB" do
			expect( @factory.create( '/websocket', '', 0xB ).opcode ).to eq( :reserved )
		end

		it "knows that its opcode is one of the reserved ones if it's 0xD" do
			expect( @factory.create( '/websocket', '', 0xD ).opcode ).to eq( :reserved )
		end

		it "knows that its opcode is one of the reserved ones if it's 0xF" do
			expect( @factory.create( '/websocket', '', 0xF ).opcode ).to eq( :reserved )
		end

		it "allows its opcode to be set Symbolically" do
			frame = @factory.text( '/websocket', 'data' )
			frame.opcode = :binary
			expect( frame.numeric_opcode ).to eq( OPCODE[:binary] )
		end

		it "allows its opcode to be set Numerically" do
			frame = @factory.binary( '/websocket', 'data' )
			frame.opcode = :text
			expect( frame.numeric_opcode ).to eq( OPCODE[:text] )
		end

		it "allows its opcode to be set to one of the reserved opcodes Numerically" do
			frame = @factory.binary( '/websocket', 'data' )
			frame.opcode = 0xC
			expect( frame.opcode ).to eq( :reserved )
			expect( frame.numeric_opcode ).to eq( 0xC )
		end

		it "knows that its RSV1 flag is set if its FLAG header includes that bit" do
			expect( @factory.ping( '/websock', 'test', :rsv1 ) ).to be_rsv1()
		end

		it "knows that its RSV2 flag is set if its FLAG header includes that bit" do
			expect( @factory.ping( '/websock', 'test', :rsv2 ) ).to be_rsv2()
		end

		it "knows that its RSV3 flag is set if its FLAG header includes that bit" do
			expect( @factory.ping( '/websock', 'test', :rsv3 ) ).to be_rsv3()
		end

		it "knows that one of its RSV flags is set if its FLAG header includes RSV1" do
			expect( @factory.ping( '/websock', 'test', :rsv1 ) ).to have_rsv_flags()
		end

		it "knows that one of its RSV flags is set if its FLAG header includes RSV2" do
			expect( @factory.ping( '/websock', 'test', :rsv2 ) ).to have_rsv_flags()
		end

		it "knows that one of its RSV flags is set if its FLAG header includes RSV3" do
			expect( @factory.ping( '/websock', 'test', :rsv3 ) ).to have_rsv_flags()
		end

		it "knows that no RSV flags are set if its FLAG header doesn't have any RSV bits" do
			expect( @factory.ping( '/websock', 'test' ) ).to_not have_rsv_flags()
		end

		it "can create a response WebSocket::Frame for itself" do
			frame = @factory.text( '/websock', "Hi, here's a message!", :fin )

			result = frame.response

			expect( result ).to be_a( Mongrel2::WebSocket::Frame )
			expect( result.sender_id ).to eq( frame.sender_id )
			expect( result.conn_id ).to eq( frame.conn_id )
			expect( result.opcode ).to eq( :text )

			result.payload.rewind
			expect( result.payload.read ).to eq( '' )
		end

		it "creates PONG responses with the same payload for PING frames" do
			frame = @factory.ping( '/websock', "WOO" )

			result = frame.response

			expect( result ).to be_a( Mongrel2::WebSocket::Frame )
			expect( result.sender_id ).to eq( frame.sender_id )
			expect( result.conn_id ).to eq( frame.conn_id )
			expect( result.opcode ).to eq( :pong )

			result.payload.rewind
			expect( result.payload.read ).to eq( 'WOO' )
		end

		it "allows header flags and/or opcode to be specified when creating a response" do
			frame = @factory.text( '/websock', "some bad data" )

			result = frame.response( :close, :fin )

			expect( result ).to be_a( Mongrel2::WebSocket::Frame )
			expect( result.sender_id ).to eq( frame.sender_id )
			expect( result.conn_id ).to eq( frame.conn_id )
			expect( result.opcode ).to eq( :close )
			expect( result ).to be_fin()

			result.payload.rewind
			expect( result.payload.read ).to eq( '' )
		end

		it "allows reserved opcodes to be specified when creating a response" do
			frame = @factory.text( '/websock', "some bad data" )

			result = frame.response( 0xB )

			expect( result ).to be_a( Mongrel2::WebSocket::Frame )
			expect( result.sender_id ).to eq( frame.sender_id )
			expect( result.conn_id ).to eq( frame.conn_id )
			expect( result.opcode ).to eq( :reserved )
			expect( result.numeric_opcode ).to eq( 0xB )

			result.payload.rewind
			expect( result.payload.read ).to eq( '' )
		end

		it "can be streamed in chunks instead of read all at once" do
			data = BINARY_DATA * 256
			binary = @factory.binary( '/websock', data, :fin )

			binary.chunksize = 16
			expect( binary.each_chunk.to_a[0,2] ).to eq([
				"\x82\x7F\x00\x00\x00\x00\x00\x01\x00\x00\a\xBD\xB3\xFE\x87\xEB".force_encoding('binary'),
				"\xA9\x0En2q\xCE\x85\xAF)\x88w_d\xD6M\x9E".force_encoding('binary'),
			])
		end

		it "has a socket identifier" do
			frame = @factory.text( '/websock', "data" )
			expect( frame.socket_id ).to eq( "#{frame.sender_id}:#{frame.conn_id}" )
		end

	end


	describe "a WebSocket text frame" do

		before( :each ) do
			@frame = @factory.text( '/websock', '', :fin )
		end

		it "automatically transcodes its payload to UTF8" do
			text = "Стрелке!".encode( Encoding::KOI8_U )
			@frame << text

			# 2-byte header
			expect( @frame.bytes.to_a[ 2..-1 ] ).
				to eq([0xD0, 0xA1, 0xD1, 0x82, 0xD1, 0x80, 0xD0, 0xB5, 0xD0, 0xBB, 0xD0,
				 0xBA, 0xD0, 0xB5, 0x21])
		end

	end


	describe "a WebSocket binary frame" do
		before( :each ) do
			@frame = @factory.binary( '/websock', BINARY_DATA, :fin )
		end

		it "doesn't try to transcode non-UTF8 data" do
			# 4-byte header
			expect( @frame.bytes.to_a[ 4, 16 ] ).
				to eq([ 0x07, 0xbd, 0xb3, 0xfe, 0x87, 0xeb, 0xa9, 0x0e, 0x6e, 0x32, 0x71,
				  0xce, 0x85, 0xaf, 0x29, 0x88 ])
		end
	end


	describe "a WebSocket close frame" do
		before( :each ) do
			@frame = @factory.close( '/websock' )
		end

		it "has convenience methods for setting its payload via integer status code" do
			@frame.set_status( CLOSE_BAD_DATA )
			@frame.payload.rewind
			expect( @frame.payload.read ).
				to eq( "%d %s\n" % [CLOSE_BAD_DATA, CLOSING_STATUS_DESC[CLOSE_BAD_DATA]] )
		end

	end


	describe "WebSocket control frames" do
		before( :each ) do
			@frame = @factory.close( '/websock', "1002 Protocol error" )
		end


		it "raises an exception if its payload is bigger than 125 bytes" do
			@frame.body << "x" * 126
			expect {
				@frame.validate
			}.to raise_error( Mongrel2::WebSocket::FrameError, /cannot exceed 125 bytes/i )
		end

		it "raises an exception if it's fragmented" do
			@frame.fin = false
			expect {
				@frame.validate
			}.to raise_error( Mongrel2::WebSocket::FrameError, /fragmented/i )
		end

	end


	describe "RFC examples (the applicable ones, anyway)" do

		it "generates a single-frame unmasked text message correctly" do
			raw_response = @factory.text( '/websock', "Hello", :fin ).to_s
			expect( raw_response.bytes.to_a ).to eq( [ 0x81, 0x05, 0x48, 0x65, 0x6c, 0x6c, 0x6f ] )
			expect( raw_response.encoding ).to eq( Encoding::BINARY )
		end

		it "generates both parts of a fragmented unmasked text message correctly" do
			first = @factory.text( '/websock', 'Hel' )
			last = @factory.continuation( '/websock', 'lo', :fin )

			expect( first.bytes.to_a ).to eq( [ 0x01, 0x03, 0x48, 0x65, 0x6c ] )
			expect( last.bytes.to_a ).to eq( [ 0x80, 0x02, 0x6c, 0x6f ] )
		end

		# The RFC's example is a masked response, but we're never a client, so never
		# generate masked payloads.
		it "generates a unmasked Ping request and (un)masked Ping response correctly" do
			ping = @factory.ping( '/websock', 'Hello' )
			pong = @factory.pong( '/websock', 'Hello' )

			expect( ping.bytes.to_a ).to eq( [ 0x89, 0x05, 0x48, 0x65, 0x6c, 0x6c, 0x6f ] )
			expect( pong.bytes.to_a ).to eq( [ 0x8a, 0x05, 0x48, 0x65, 0x6c, 0x6c, 0x6f ] )
		end


		it "generates a 256-byte binary message in a single unmasked frame" do
			binary = @factory.binary( '/websock', BINARY_DATA, :fin )

			# 1 + 1 + 2
			expect( binary.bytes.to_a[0,4] ).to eq( [ 0x82, 0x7E, 0x01, 0x00 ] )
			expect( binary.to_s[4..-1] ).to eq( BINARY_DATA )
		end

		it "generates a 64KiB binary message in a single unmasked frame correctly" do
			data = BINARY_DATA * 256

			binary = @factory.binary( '/websock', data, :fin )

			# 1 + 1 + 8
			expect( binary.bytes.to_a[0,10] ).
				to eq([ 0x82, 0x7F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00 ])
			expect( binary.to_s[10..-1] ).to eq( data )
		end

	end


end

