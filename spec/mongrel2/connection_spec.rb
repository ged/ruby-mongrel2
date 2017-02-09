#!/usr/bin/env ruby

require_relative '../helpers'

require 'ostruct'
require 'mongrel2'
require 'mongrel2/connection'


#####################################################################
###	C O N T E X T S
#####################################################################

describe Mongrel2::Connection do
	include Mongrel2::Config::DSL

	before( :all ) do
	end

	# Ensure 0MQ never actually gets called
	before( :each ) do
		@conn = Mongrel2::Connection.new( TEST_UUID, TEST_SEND_SPEC, TEST_RECV_SPEC )
	end


	it "doesn't connect to the endpoints when it's created" do
		expect( @conn.instance_variable_get( :@request_sock ) ).to be_nil()
		expect( @conn.instance_variable_get( :@response_sock ) ).to be_nil()
	end

	it "connects to the endpoints specified on demand" do
		request_sock = double( "request socket", options: OpenStruct.new )
		response_sock = double( "response socket", options: OpenStruct.new )

		expect( CZTop::Socket::PULL ).to receive( :new ).and_return( request_sock )
		expect( request_sock.options ).to receive( :linger= ).with( 0 )
		expect( request_sock ).to receive( :connect ).with( TEST_SEND_SPEC )

		expect( CZTop::Socket::PUB ).to receive( :new ).and_return( response_sock )
		expect( response_sock.options ).to receive( :linger= ).with( 0 )
		expect( response_sock.options ).to_not receive( :identity= )
		expect( response_sock ).to receive( :connect ).with( TEST_RECV_SPEC )

		expect( @conn.request_sock ).to eq( request_sock )
		expect( @conn.response_sock ).to eq( response_sock )
	end

	it "stringifies as a description of the appid and both sockets" do
		expect( @conn.to_s ).to eq( "{#{TEST_UUID}} #{TEST_SEND_SPEC} <-> #{TEST_RECV_SPEC}" )
	end

	context "after a connection has been established" do

		before( :each ) do
			@request_sock = double( "request socket", :options => OpenStruct.new, :connect => nil )
			@response_sock = double( "response socket", :options => OpenStruct.new, :connect => nil )

			allow( CZTop::Socket::PULL ).to receive( :new ).and_return( @request_sock )
			allow( CZTop::Socket::PUB ).to receive( :new ).and_return( @response_sock )

			@conn.connect
		end


		it "closes both of its sockets when closed" do
			expect( @request_sock ).to receive( :close )
			expect( @response_sock ).to receive( :close )

			@conn.close
		end

		it "raises an exception if asked to fetch data after being closed" do
			allow( @request_sock ).to receive( :close )
			allow( @response_sock ).to receive( :close )

			@conn.close

			expect {
				@conn.recv
			}.to raise_error( Mongrel2::ConnectionError, /operation on closed connection/i )
		end

		it "doesn't keep its request and response sockets when duped" do
			request_sock2 = double( "request socket", :options => OpenStruct.new, :connect => nil )
			response_sock2 = double( "response socket", :options => OpenStruct.new, :connect => nil )
			allow( CZTop::Socket::PULL ).to receive( :new ).and_return( request_sock2 )
			allow( CZTop::Socket::PUB ).to receive( :new ).and_return( response_sock2 )

			duplicate = @conn.dup

			expect( duplicate.request_sock ).to eq( request_sock2 )
			expect( duplicate.response_sock ).to eq( response_sock2 )
		end

		it "doesn't keep its closed state when duped" do
			expect( @request_sock ).to receive( :close )
			expect( @response_sock ).to receive( :close )

			@conn.close

			duplicate = @conn.dup
			expect( duplicate ).to_not be_closed()
		end

		it "can read raw request messages off of the request_sock" do
			expect( @request_sock ).to receive( :receive ).and_return( CZTop::Message.new( "the data" ) )
			expect( @conn.recv ).to eq( "the data" )
		end

		it "can read request messages off of the request_sock as Mongrel2::Request objects" do
			msg = make_request()
			expect( @request_sock ).to receive( :receive ).and_return( CZTop::Message.new( msg ) )
			expect( @conn.receive ).to be_a( Mongrel2::Request )
		end

		it "can write raw response messages with a TNetString header onto the response_sock" do
			expect( @response_sock ).to receive( :<< ).with( "#{TEST_UUID} 1:8, the data" )
			@conn.send( TEST_UUID, 8, "the data" )
		end

		it "can write Mongrel2::Responses to the response_sock" do
			expect( @response_sock ).to receive( :<< ).with( "#{TEST_UUID} 1:8, the data" )

			response = Mongrel2::Response.new( TEST_UUID, 8, 'the data' )
			@conn.reply( response )
		end

		it "can write raw response messages to more than one conn_id at the same time" do
			expect( @response_sock ).to receive( :<< ).
				with( "#{TEST_UUID} 15:8 16 44 45 1833, the data" )
			@conn.broadcast( TEST_UUID, [8, 16, 44, 45, 1833], 'the data' )
		end

		it "can write raw response messages to more than one conn_id at the same time" do
			expect( @response_sock ).to receive( :<< ).
				with( "#{TEST_UUID} 15:8 16 44 45 1833, the data" )
			@conn.broadcast( TEST_UUID, [8, 16, 44, 45, 1833], 'the data' )
		end

		it "can write an extended response message" do
			expect( @response_sock ).to receive( :<< ).
				with( "#{TEST_UUID} 3:X 8, 27:8:sendfile,12:the_data.txt,]" )
			@conn.send_extended( TEST_UUID, 8, :sendfile, "the_data.txt" )
		end

		it "can broadcast an extended response message" do
			expect( @response_sock ).to receive( :<< ).
				with( "#{TEST_UUID} 9:X 8 16 32, 27:8:sendfile,12:the_data.txt,]" )
			@conn.broadcast_extended( TEST_UUID, [8,16,32], :sendfile, "the_data.txt" )
		end

		it "can write a Mongrel2::Response with extended reply" do
			expect( @response_sock ).to receive( :<< ).
				with( "#{TEST_UUID} 1:8, " )
			expect( @response_sock ).to receive( :<< ).
				with( "#{TEST_UUID} 3:X 8, 27:8:sendfile,12:the_data.txt,]" )

			response = Mongrel2::Response.new( TEST_UUID, 8, '' )
			response.extended_reply_with( :sendfile )
			response.extended_reply_data << 'the_data.txt'

			@conn.reply( response )
		end

		it "can tell the connection a request or a response was from to close" do
			expect( @response_sock ).to receive( :<< ).with( "#{TEST_UUID} 1:8, " )

			response = Mongrel2::Response.new( TEST_UUID, 8 )
			@conn.reply_close( response )
		end

		it "can broadcast a close to multiple connection IDs" do
			expect( @response_sock ).to receive( :<< ).with( "#{TEST_UUID} 15:8 16 44 45 1833, " )
			@conn.broadcast_close( TEST_UUID, [8, 16, 44, 45, 1833] )
		end

	end

end

