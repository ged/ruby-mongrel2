#!/usr/bin/env ruby

require_relative '../helpers'

require 'mongrel2'
require 'mongrel2/config'


#####################################################################
###	C O N T E X T S
#####################################################################

describe Mongrel2::Config do

	before( :all ) do
		setup_logging()
		setup_config_db()
	end

	after( :all ) do
		reset_logging()
		File.delete( 'config-spec.sqlite' ) if File.exist?( 'config.spec.sqlite' )
	end


	it "has a factory method for creating derivative classes" do
		begin
			model_class = Mongrel2::Config( :hookers )
			expect( model_class ).to satisfy {|klass| klass < Mongrel2::Config }
			expect( model_class.dataset.first_source ).to eq( :hookers )
		ensure
			# Remove the example class from the list of subclasses so it
			# doesn't affect later tests
			Mongrel2::Config.subclasses.delete( model_class ) if model_class
		end
	end

	it "can reset the database handle for the config classes" do
		db = Mongrel2::Config.in_memory_db
		Mongrel2::Config.db = db
		expect( Mongrel2::Config::Directory.db ).to equal( db )
	end

	it "has a convenience method for fetching an Array of all of its configured servers" do
		Mongrel2::Config.init_database
		Mongrel2::Config::Server.truncate

		Mongrel2::Config::Server.create(
			uuid: TEST_UUID,
			access_log: '/log/access.log',
			error_log: '/log/error.log',
			pid_file: '/run/m2.pid',
			default_host: 'localhost',
			port: 8275
		  )
		expect( Mongrel2::Config.servers.size ).to eq(  1  )
		expect( Mongrel2::Config.servers.first.uuid ).to eq( TEST_UUID )
	end

	it "has a convenience method for getting a setting's value" do
		Mongrel2::Config.init_database
		Mongrel2::Config::Setting.dataset.truncate
		Mongrel2::Config::Setting.create( key: 'control_port', value: 'ipc://var/run/control.sock' )
		expect( Mongrel2::Config.settings ).to respond_to( :[] )
		expect( Mongrel2::Config.settings.size ).to eq(  1  )
		expect( Mongrel2::Config.settings[ :control_port ] ).to eq( 'ipc://var/run/control.sock' )
	end

	it "can read the configuration schema from a data file" do
		expect( Mongrel2::Config.load_config_schema ).to match( /create table server/i )
	end

	it "knows whether or not its database has been initialized" do
		Mongrel2::Config.db = Mongrel2::Config.in_memory_db
		expect( Mongrel2::Config.database_initialized? ).to be_falsey()
		Mongrel2::Config.init_database!
		expect( Mongrel2::Config.database_initialized? ).to be_truthy()
	end

	it "doesn't re-initialize the database if the non-bang version of init_database is used" do
		Mongrel2::Config.db = Mongrel2::Config.in_memory_db
		Mongrel2::Config.init_database

		expect( Mongrel2::Config ).to_not receive( :load_config_schema )
		Mongrel2::Config.init_database
	end

	it "can return the path to the config DB as a Pathname if it's pointing at a file" do
		Mongrel2::Config.db = Sequel.
			connect( adapter: Mongrel2::Config.sqlite_adapter, database: 'config-spec.sqlite' )
		expect( Mongrel2::Config.dbname ).to eq( 'config-spec.sqlite' )
	end

	it "returns nil if asked for the pathname to an in-memory database" do
		Mongrel2::Config.db = Mongrel2::Config.in_memory_db
		expect( Mongrel2::Config.dbname ).to be_nil()
	end

	describe "Configurability support", :if => defined?( Configurability ) do
		require 'configurability/behavior'

		it_should_behave_like "an object with Configurability"

		it "uses the 'mongrel2' config section" do
			expect( Mongrel2::Config.config_key ).to eq( :mongrel2 )
		end

	end

end

