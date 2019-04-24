#!/usr/bin/env rspec -cfd -b

require_relative 'helpers'

require 'rspec'

require 'loggability'
require 'mongrel2'


describe Mongrel2 do

	describe "version methods" do

		it "returns a version string if asked" do
			expect( Mongrel2.version_string ).to match( /\w+ [\d.]+/ )
		end


		it "returns a version string with a build number if asked" do
			expect( Mongrel2.version_string(true) ).to match( /\w+ [\d.]+ \(build [[:xdigit:]]+\)/ )
		end

	end

end

