# -*- ruby -*-
# frozen_string_literal: true

require_relative '../../helpers'

require 'rspec'
require 'mongrel2'
require 'mongrel2/config'


#####################################################################
###	C O N T E X T S
#####################################################################

describe Mongrel2::Config::Route, :db do

	before( :each ) do
		@route = Mongrel2::Config::Route.new( :path => '' )
	end


	it "returns a Mongrel2::Config::Directory if its target_type is 'dir'" do
		dir = Mongrel2::Config::Directory.create(
			:base => 'var/www/',
			:default_ctype => 'text/plain',
			:index_file => 'index.html' )

		@route.target_type = 'dir'
		@route.target_id = dir.id

		expect( @route.target ).to eq( dir )
	end


	it "returns a Mongrel2::Config::Proxy if its target_type is 'proxy'" do
		proxy = Mongrel2::Config::Proxy.create( :addr => '10.2.18.8' )

		@route.target_type = 'proxy'
		@route.target_id = proxy.id

		expect( @route.target ).to eq( proxy )
	end


	it "returns a Mongrel2::Config::Handler if its target_type is 'handler'" do
		handler = Mongrel2::Config::Handler.create(
			:send_ident => TEST_UUID,
			:send_spec => 'tcp://127.0.0.1:9998',
			:recv_spec => 'tcp://127.0.0.1:9997' )

		@route.target_type = 'handler'
		@route.target_id = handler.id

		expect( @route.target ).to eq( handler )
	end


	it "raises an exception if its target_type is set to something invalid" do
		@route.target_type = 'giraffes'

		expect {
			@route.target
		}.to raise_error( ArgumentError, /unknown target type/i )
	end

end

