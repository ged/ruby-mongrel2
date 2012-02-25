#!/usr/bin/env ruby

BEGIN {
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.parent.parent

	libdir = basedir + "lib"

	$LOAD_PATH.unshift( basedir ) unless $LOAD_PATH.include?( basedir )
	$LOAD_PATH.unshift( libdir ) unless $LOAD_PATH.include?( libdir )
}

require 'rspec'

require 'spec/lib/helpers'

require 'mongrel2'
require 'mongrel2/config'


#####################################################################
###	C O N T E X T S
#####################################################################

describe Mongrel2::Config::Server do

	before( :all ) do
		setup_logging( :fatal )
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
		@server.should be_valid()
	end

	it "isn't valid if it doesn't have an access_log path" do
		@server.access_log = nil
		@server.should_not be_valid()
		@server.errors.full_messages.first.should =~ /missing or nil/i
	end

	it "isn't valid if it doesn't have an error_log path" do
		@server.error_log = nil
		@server.should_not be_valid()
		@server.errors.full_messages.first.should =~ /missing or nil/i
	end

	it "isn't valid if it doesn't have an pid_file path" do
		@server.pid_file = nil
		@server.should_not be_valid()
		@server.errors.full_messages.first.should =~ /missing or nil/i
	end

	it "isn't valid if it doesn't have a default_host" do
		@server.default_host = nil
		@server.should_not be_valid()
		@server.errors.full_messages.first.should =~ /missing or nil/i
	end

	it "isn't valid if it doesn't specify a port" do
		@server.port = nil
		@server.should_not be_valid()
		@server.errors.full_messages.first.should =~ /missing or nil/i
	end


	it "knows where its control socket is if there's no setting for control_port" do
		Mongrel2::Config::Setting.dataset.truncate
		@server.control_socket_uri.should == 'ipc:///usr/local/www/run/control'
	end

	it "knows where its control socket is if there is a setting for control_port" do
		Mongrel2::Config::Setting.dataset.truncate
		Mongrel2::Config::Setting.create( key: 'control_port', value: 'ipc://var/run/control.sock' )
		@server.control_socket_uri.should == 'ipc:///usr/local/www/var/run/control.sock'
	end

	it "can create a Mongrel2::Control for its control port" do
		Mongrel2::Config::Setting.dataset.truncate
		sock = @server.control_socket
		sock.should be_a( Mongrel2::Control )
		sock.close
	end

	it "knows what the Pathname of its PID file is" do
		pidfile = @server.pid_file_path
		pidfile.should be_a( Pathname )
		pidfile.to_s.should == '/usr/local/www/run/mongrel2.pid'
	end

end

