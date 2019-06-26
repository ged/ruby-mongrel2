#!/usr/bin/env rspec -cfd

require_relative '../helpers'

require 'mongrel2/testing'


describe Mongrel2, "testing library" do


	describe "RequestFactory" do

		let( :described_class ) { Mongrel2::RequestFactory }

		let( :factory ) { described_class.new( route: '/testing' ) }


		it "can be created with reasonable defaults" do
			factory = described_class.new

			expect( factory ).to be_a( described_class )
			expect( factory.sender_id ).to eq( described_class.default_factory_config[:sender_id] )
			expect( factory.host ).to eq( described_class.default_factory_config[:host] )
			expect( factory.port ).to eq( described_class.default_factory_config[:port] )
			expect( factory.route ).to eq( described_class.default_factory_config[:route] )
			expect( factory.conn_id ).to eq( described_class.default_factory_config[:conn_id] )

			expect( factory.headers ).to eq( described_class.default_headers )
		end


		it "can be created with overridden config values" do
			factory = described_class.new( sender_id: 'another_sender_id', conn_id: 202 )

			expect( factory ).to be_a( described_class )
			expect( factory.sender_id ).to eq( 'another_sender_id' )
			expect( factory.host ).to eq( described_class.default_factory_config[:host] )
			expect( factory.port ).to eq( described_class.default_factory_config[:port] )
			expect( factory.route ).to eq( described_class.default_factory_config[:route] )
			expect( factory.conn_id ).to eq( 202 )

			expect( factory.headers ).to eq( described_class.default_headers )
		end


		it "can create a valid OPTIONS request" do
			req = factory.options( '/testing' )

			expect( req ).to be_a( Mongrel2::HTTPRequest )
			expect( req.path ).to eq( '/testing' )
			expect( req.headers[:method] ).to eq( 'OPTIONS' )
			expect( req.body ).to be_a( StringIO ).and( be_eof )
			expect( req.scheme ).to eq( 'http' )
		end


		it "can create a valid GET request" do
			req = factory.get( '/testing' )

			expect( req ).to be_a( Mongrel2::HTTPRequest )
			expect( req.path ).to eq( '/testing' )
			expect( req.headers[:method] ).to eq( 'GET' )
			expect( req.body ).to be_a( StringIO ).and( be_eof )
		end


		it "can create a valid HEAD request" do
			req = factory.head( '/testing' )

			expect( req ).to be_a( Mongrel2::HTTPRequest )
			expect( req.path ).to eq( '/testing' )
			expect( req.headers[:method] ).to eq( 'HEAD' )
			expect( req.body ).to be_a( StringIO ).and( be_eof )
			expect( req.scheme ).to eq( 'http' )
		end


		it "can create a valid POST request" do
			body = <<~END_OF_BODY
			collection=screening
			page=3
			page_size=50
			END_OF_BODY

			req = factory.post( '/testing', body )

			expect( req ).to be_a( Mongrel2::HTTPRequest )
			expect( req.path ).to eq( '/testing' )
			expect( req.headers[:method] ).to eq( 'POST' )
			expect( req.body ).to be_a( StringIO )
			expect( req.body.string ).to eq( body )
			expect( req.scheme ).to eq( 'http' )
		end

	end


	describe "WebSocketRequestFactory" do

		let( :described_class ) { Mongrel2::WebSocketRequestFactory }


		it "can be created with reasonable defaults" do
			factory = described_class.new

			expect( factory ).to be_a( described_class )
			expect( factory.sender_id ).to eq( described_class.default_factory_config[:sender_id] )
			expect( factory.host ).to eq( described_class.default_factory_config[:host] )
			expect( factory.port ).to eq( described_class.default_factory_config[:port] )
			expect( factory.route ).to eq( described_class.default_factory_config[:route] )
			expect( factory.conn_id ).to eq( described_class.default_factory_config[:conn_id] )

			expect( factory.headers ).to eq( described_class.default_headers )
		end


		it "can be created with overridden config values" do
			factory = described_class.new( sender_id: 'another_sender_id', conn_id: 202 )

			expect( factory ).to be_a( described_class )
			expect( factory.sender_id ).to eq( 'another_sender_id' )
			expect( factory.host ).to eq( described_class.default_factory_config[:host] )
			expect( factory.port ).to eq( described_class.default_factory_config[:port] )
			expect( factory.route ).to eq( described_class.default_factory_config[:route] )
			expect( factory.conn_id ).to eq( 202 )

			expect( factory.headers ).to eq( described_class.default_headers )
		end


		it "can create a valid handshake request" do
			factory = described_class.new( route: '/ws_testing' )

			req = factory.handshake( '/ws_testing' )

			expect( req ).to be_a( Mongrel2::WebSocket::ClientHandshake )
		end

	end

end

