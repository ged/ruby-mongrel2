#!/usr/bin/env ruby

require_relative '../../helpers'

require 'rspec'

require 'socket'
require 'mongrel2'
require 'mongrel2/config'


#####################################################################
###	C O N T E X T S
#####################################################################

describe Mongrel2::Config::Log, :db do

	it "has a convenience method for writing to the commit log" do
		what  = 'load etc/mongrel2.conf'
		why   = 'updating'
		where = 'localhost'
		how   = 'm2sh'

		log = Mongrel2::Config::Log.log_action( what, why, where, how )

		expect( log.what ).to eq( what )
		expect( log.why ).to eq( why )
		expect( log.location ).to eq( where )
		expect( log.how ).to eq( how )
	end

	it "has reasonable defaults for 'where' and 'how'" do
		what  = 'load etc/mongrel2.conf'
		why   = 'updating'

		log = Mongrel2::Config::Log.log_action( what, why )

		expect( log.location ).to eq( Socket.gethostname )
		expect( log.how ).to eq( File.basename( $0 ) )
	end

	describe "an entry" do

		before( :each ) do
			@log = Mongrel2::Config::Log.new(
				who:         'who',
				what:        'what',
				location:    'location',
				happened_at: Time.at( 1315598592 ),
				how:         'how'
			)
		end


		it "stringifies as a readable log file line" do

			# 2011-09-09 20:29:47 -0700 [mgranger] @localhost m2sh: load etc/mongrel2.conf (updating)
			expect( @log.to_s ).to match(%r{
				^
				(?-x:\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [\+\-]\d{4} )
				\[who\] \s
				@location \s
				how: \s
				what
				$
			}x)
		end

		it "stringifies with a reason if it has one" do
			@log.why = 'Because'

			# 2011-09-09 20:29:47 -0700 [mgranger] @localhost m2sh: load etc/mongrel2.conf (updating)
			expect( @log.to_s ).to match(%r{
				^
				(?-x:\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [\+\-]\d{4} )
				\[who\] \s
				@location \s
				how: \s
				what \s
				\(Because\)
				$
			}x)
		end

	end

end

