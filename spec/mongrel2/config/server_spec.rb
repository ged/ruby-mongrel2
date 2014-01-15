#!/usr/bin/env ruby

require_relative '../../helpers'

require 'rspec'
require 'mongrel2'
require 'mongrel2/config'


#####################################################################
###	C O N T E X T S
#####################################################################

describe Mongrel2::Config::Server do

	before( :all ) do
		setup_logging()
		setup_config_db()
	end

	before( :each ) do
		@server = Mongrel2::Config::Server.new(
			uuid:         TEST_UUID,
			chroot:       '/usr/local/www',
			access_log:   '/logs/access.log',
			error_log:    '/logs/error.log',
			pid_file:     '/run/mongrel2.pid',
			default_host: 'localhost',
			port:         8118
		)
	end

	after( :all ) do
		reset_logging()
	end


	it "is valid if its access_log, error_log, pid_file, default_host, and port are all valid" do
		expect( @server ).to be_valid()
	end

	it "isn't valid if it doesn't have an access_log path" do
		@server.access_log = nil
		expect( @server ).to_not be_valid()
		expect( @server.errors.full_messages.first ).to match( /missing or nil/i )
	end

	it "isn't valid if it doesn't have an error_log path" do
		@server.error_log = nil
		expect( @server ).to_not be_valid()
		expect( @server.errors.full_messages.first ).to match( /missing or nil/i )
	end

	it "isn't valid if it doesn't have an pid_file path" do
		@server.pid_file = nil
		expect( @server ).to_not be_valid()
		expect( @server.errors.full_messages.first ).to match( /missing or nil/i )
	end

	it "isn't valid if it doesn't have a default_host" do
		@server.default_host = nil
		expect( @server ).to_not be_valid()
		expect( @server.errors.full_messages.first ).to match( /missing or nil/i )
	end

	it "isn't valid if it doesn't specify a port" do
		@server.port = nil
		expect( @server ).to_not be_valid()
		expect( @server.errors.full_messages.first ).to match( /missing or nil/i )
	end


	it "knows where its control socket is if there's no setting for control_port" do
		Mongrel2::Config::Setting.dataset.truncate
		allow( FileTest ).to receive( :socket? ).with( '/usr/local/www/run/control' ).
			and_return( true )
		expect( @server.control_socket_uri ).to eq( 'ipc:///usr/local/www/run/control' )
	end

	it "knows where its control socket is if there is a setting for control_port" do
		Mongrel2::Config::Setting.dataset.truncate
		allow( FileTest ).to receive( :socket? ).with( '/usr/local/www/var/run/control.sock' ).
			and_return( true )
		Mongrel2::Config::Setting.create( key: 'control_port', value: 'ipc://var/run/control.sock' )
		expect( @server.control_socket_uri ).to eq( 'ipc:///usr/local/www/var/run/control.sock' )
	end

	it "raises an error if the control socket path doesn't point to a UNIX socket" do
		expect {
			@server.control_socket
		}.to raise_error( RuntimeError, /unable to find the socket/i )
	end

	it "can create a Mongrel2::Control for its control port" do
		Mongrel2::Config::Setting.dataset.truncate
		allow( FileTest ).to receive( :socket? ).with( '/usr/local/www/run/control' ).
			and_return( true )
		sock = @server.control_socket
		expect( sock ).to be_a( Mongrel2::Control )
		sock.close
	end

	it "knows what the Pathname of its PID file is" do
		pidfile = @server.pid_file_path
		expect( pidfile ).to be_a( Pathname )
		expect( pidfile.to_s ).to eq( '/run/mongrel2.pid' )
	end

	it "has a predicate that understands the use_ssl value" do
		expect( @server.use_ssl ).to be_falsey()
		@server.use_ssl = true
		expect( @server.use_ssl ).to be_truthy()
	end

end

