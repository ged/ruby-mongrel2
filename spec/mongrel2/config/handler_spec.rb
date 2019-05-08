# -*- ruby -*-
# frozen_string_literal: true

require_relative '../../helpers'

require 'rspec'
require 'mongrel2'
require 'mongrel2/config'


#####################################################################
###	C O N T E X T S
#####################################################################

describe Mongrel2::Config::Handler, :db do

	before( :each ) do
		Mongrel2::Config::Handler.truncate
		@handler = Mongrel2::Config::Handler.new(
			:send_spec  => TEST_SEND_SPEC,
			:send_ident => TEST_UUID,
			:recv_spec  => TEST_RECV_SPEC,
			:recv_ident => ''
		)
	end


	it "is valid if its specs and identities are all valid" do
		expect( @handler ).to be_valid()
	end


	it "isn't valid if it doesn't have a send_spec" do
		@handler.send_spec = nil
		expect( @handler ).to_not be_valid()
		expect( @handler.errors.full_messages.first ).to match( /must not be nil/i )
	end


	it "isn't valid if it doesn't have a recv_spec" do
		@handler.recv_spec = nil
		expect( @handler ).to_not be_valid()
		expect( @handler.errors.full_messages.first ).to match( /must not be nil/i )
	end


	it "isn't valid if it doesn't have a valid URL in its send_spec" do
		@handler.send_spec = 'carrier pigeon'
		expect( @handler ).to_not be_valid()
		expect( @handler.errors.full_messages.first ).to match( /not a uri/i )
	end


	it "isn't valid if it doesn't have a valid URL in its recv_spec" do
		@handler.recv_spec = 'smoke signals'
		expect( @handler ).to_not be_valid()
		expect( @handler.errors.full_messages.first ).to match( /not a uri/i )
	end


	it "isn't valid if has an unsupported transport in its send_spec" do
		@handler.send_spec = 'inproc://application'
		expect( @handler ).to_not be_valid()
		expect( @handler.errors.full_messages.first ).to match( /invalid 0mq transport/i )
	end


	it "isn't valid if has an unsupported transport in its recv_spec" do
		@handler.recv_spec = 'inproc://application'
		expect( @handler ).to_not be_valid()
		expect( @handler.errors.full_messages.first ).to match( /invalid 0mq transport/i )
	end


	it "isn't valid if it doesn't have a send_ident" do
		@handler.send_ident = nil
		expect( @handler ).to_not be_valid()
		expect( @handler.errors.full_messages.first ).to match( /invalid sender identity/i )
	end


	it "*is* valid if it doesn't have a recv_ident" do
		@handler.recv_ident = nil
		expect( @handler ).to be_valid()
	end


	it "is valid if it has 'json' set as the protocol" do
		@handler.protocol = 'json'
		expect( @handler ).to be_valid()
	end


	it "is valid if it has 'tnetstring' set as the protocol" do
		@handler.protocol = 'tnetstring'
		expect( @handler ).to be_valid()
	end


	it "isn't valid if it has an invalid protocol" do
		@handler.protocol = 'morsecode'
		expect( @handler ).to_not be_valid()
		expect( @handler.errors.full_messages.first ).to match( /invalid/i )
	end


	it "isn't valid if its send_spec isn't unique" do
		dup = @handler.dup
		@handler.save

		expect {
			dup.save
		}.to raise_error( Sequel::ValidationFailed, /is already taken/ )
	end

end

