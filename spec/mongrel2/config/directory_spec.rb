#!/usr/bin/env ruby

require_relative '../../helpers'

require 'rspec'
require 'mongrel2'
require 'mongrel2/config'


#####################################################################
###	C O N T E X T S
#####################################################################

describe Mongrel2::Config::Directory, :db do

	before( :each ) do
		@dir = Mongrel2::Config::Directory.new(
			:base          => 'var/www/public/',
			:index_file    => 'index.html',
			:default_ctype => 'text/plain'
		)
	end


	it "is valid if its base, index_file, and default_ctype are all valid" do
		expect( @dir ).to be_valid()
	end


	it "isn't valid if it doesn't have a base" do
		@dir.base = nil
		expect( @dir ).to_not be_valid()
		expect( @dir.errors.full_messages.first ).to match( /missing or nil/i )
	end


	it "isn't valid when its base starts with '/'" do
		@dir.base = '/var/www/public/'
		expect( @dir ).to_not be_valid()
		expect( @dir.errors.full_messages.first ).to match( %r{shouldn't start with '/'}i )
	end


	it "isn't valid when its base doesn't end with '/'" do
		@dir.base = 'var/www/public'
		expect( @dir ).to_not be_valid()
		expect( @dir.errors.full_messages.first ).to match( %r{must end with '/'}i )
	end


	it "isn't valid if it doesn't have an index file" do
		@dir.index_file = nil
		expect( @dir ).to_not be_valid()
		expect( @dir.errors.full_messages.first ).to match( /must not be nil/i )
	end


	it "isn't valid if it doesn't have a default content-type" do
		@dir.default_ctype = nil
		expect( @dir ).to_not be_valid()
		expect( @dir.errors.full_messages.first ).to match( /must not be nil/i )
	end


	it "isn't valid if its cache TTL is set to a negative value" do
		@dir.cache_ttl = -5
		expect( @dir ).to_not be_valid()
		expect( @dir.errors.full_messages.first ).to match( /not a positive integer/i )
	end


	it "is valid if its cache TTL is set to zero" do
		@dir.cache_ttl = 0
		expect( @dir ).to be_valid()
	end

end

